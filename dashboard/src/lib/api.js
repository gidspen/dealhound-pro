import {
  email, agentName, scans, deals, activeThreads, starredDealIds,
  viewedDealIds, archivedDealIds,
  chatMessages, chatConversationId, chatStreaming,
  cacheGet, cacheSet, activeThreadId
} from './state.js';

const API_BASE = '';

export async function loadUserData() {
  const res = await fetch(`${API_BASE}/api/user-data?email=${encodeURIComponent(email.value)}`);
  if (!res.ok) throw new Error('Failed to load user data');
  const data = await res.json();

  agentName.value = data.agent_name;
  scans.value = data.scans || [];
  deals.value = data.deals || [];
  activeThreads.value = data.active_threads || [];
  starredDealIds.value = new Set(data.deals.filter(d => d.starred).map(d => d.id));
  viewedDealIds.value = new Set(data.deals.filter(d => d.viewed).map(d => d.id));
  archivedDealIds.value = new Set(data.deals.filter(d => d.archived).map(d => d.id));
}

export async function loadConversation(conversationId) {
  const res = await fetch(
    `${API_BASE}/api/conversation?id=${conversationId}&email=${encodeURIComponent(email.value)}`
  );
  if (!res.ok) throw new Error('Conversation not found');
  return res.json();
}

export async function switchThread(threadId, type, conversationId) {
  activeThreadId.value = threadId;

  // Auto-mark deal as viewed when selected
  if (type === 'deal') {
    viewDeal(threadId);
  }

  const cached = cacheGet(threadId);
  if (cached) {
    chatMessages.value = cached.messages;
    chatConversationId.value = cached.conversationId;
    return;
  }

  if (conversationId) {
    try {
      const data = await loadConversation(conversationId);
      chatMessages.value = data.messages || [];
      chatConversationId.value = conversationId;
      cacheSet(threadId, { messages: data.messages || [], conversationId });
    } catch {
      chatMessages.value = [];
      chatConversationId.value = null;
    }
  } else {
    chatMessages.value = [];
    chatConversationId.value = null;
  }
}

export async function sendMessage(text, endpoint, extraBody = {}) {
  const userMsg = { role: 'user', content: text };
  chatMessages.value = [...chatMessages.value, userMsg];
  chatStreaming.value = true;

  const allMessages = chatMessages.value.map(m => ({ role: m.role, content: m.content }));

  try {
    const res = await fetch(`${API_BASE}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: email.value,
        messages: allMessages,
        conversation_id: chatConversationId.value,
        agent_name: agentName.value,
        ...extraBody
      })
    });

    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let assistantText = '';
    let buffer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop();

      for (const line of lines) {
        if (!line.startsWith('data: ')) continue;
        try {
          const event = JSON.parse(line.slice(6));

          if (event.type === 'text') {
            assistantText += event.text;
            const msgs = [...chatMessages.value];
            const lastMsg = msgs[msgs.length - 1];
            if (lastMsg && lastMsg.role === 'assistant' && lastMsg._streaming) {
              msgs[msgs.length - 1] = { role: 'assistant', content: assistantText, _streaming: true };
            } else {
              msgs.push({ role: 'assistant', content: assistantText, _streaming: true });
            }
            chatMessages.value = msgs;
          } else if (event.type === 'conversation_id') {
            chatConversationId.value = event.id;
          } else if (event.type === 'buy_box_saved') {
            window.dispatchEvent(new CustomEvent('buybox-saved', { detail: event }));
          } else if (event.type === 'error') {
            const msgs = [...chatMessages.value];
            msgs.push({ role: 'assistant', content: 'Error: ' + event.error });
            chatMessages.value = msgs;
          }
        } catch { /* skip malformed JSON */ }
      }
    }

    if (assistantText) {
      const msgs = [...chatMessages.value];
      const lastMsg = msgs[msgs.length - 1];
      if (lastMsg && lastMsg._streaming) {
        msgs[msgs.length - 1] = { role: 'assistant', content: assistantText };
      }
      chatMessages.value = msgs;
    }

    cacheSet(activeThreadId.value, {
      messages: chatMessages.value,
      conversationId: chatConversationId.value
    });

  } catch (err) {
    const msgs = [...chatMessages.value];
    msgs.push({ role: 'system', content: 'Connection lost. Try again.' });
    chatMessages.value = msgs;
  }

  chatStreaming.value = false;
}

export async function toggleStar(dealId) {
  const currentlyStarred = starredDealIds.value.has(dealId);
  const newStarred = !currentlyStarred;

  const updated = new Set(starredDealIds.value);
  if (newStarred) updated.add(dealId); else updated.delete(dealId);
  starredDealIds.value = updated;

  try {
    const res = await fetch(`${API_BASE}/api/star-deal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, deal_id: dealId, starred: newStarred })
    });
    if (!res.ok) throw new Error();
  } catch {
    const reverted = new Set(starredDealIds.value);
    if (currentlyStarred) reverted.add(dealId); else reverted.delete(dealId);
    starredDealIds.value = reverted;
  }
}

export async function viewDeal(dealId) {
  if (viewedDealIds.value.has(dealId)) return;

  const updated = new Set(viewedDealIds.value);
  updated.add(dealId);
  viewedDealIds.value = updated;

  try {
    const res = await fetch(`${API_BASE}/api/view-deal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, deal_id: dealId })
    });
    if (!res.ok) throw new Error();
  } catch {
    const reverted = new Set(viewedDealIds.value);
    reverted.delete(dealId);
    viewedDealIds.value = reverted;
  }
}

export async function archiveDeal(dealId) {
  const currentlyArchived = archivedDealIds.value.has(dealId);
  const newArchived = !currentlyArchived;

  const updated = new Set(archivedDealIds.value);
  if (newArchived) updated.add(dealId); else updated.delete(dealId);
  archivedDealIds.value = updated;

  try {
    const res = await fetch(`${API_BASE}/api/archive-deal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, deal_id: dealId, archived: newArchived })
    });
    if (!res.ok) throw new Error();
  } catch {
    const reverted = new Set(archivedDealIds.value);
    if (currentlyArchived) reverted.add(dealId); else reverted.delete(dealId);
    archivedDealIds.value = reverted;
  }
}
