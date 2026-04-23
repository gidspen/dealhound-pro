import { useRef, useEffect } from 'preact/hooks';
import { view, agentName, chatMessages, chatStreaming, activeThreadId, scans, currentDeal } from '../lib/state.js';
import { sendMessage, loadUserData, switchThread } from '../lib/api.js';
import { parseBreakdown, tierFromStrategy } from '../lib/utils.js';

function TypingIndicator() {
  return (
    <div class="msg msg-assistant">
      <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
      <div class="typing"><span /><span /><span /></div>
    </div>
  );
}

function WatchPlaceholder({ deal }) {
  const startBreakdown = () => {
    const scan = scans.value.find(s => s.id === deal.search_id);
    sendMessage('Break down this deal for me.', '/api/deal-chat', { deal, buy_box: scan?.buy_box || {} });
  };

  return (
    <div class="msg msg-assistant">
      <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
      <div class="msg-body">
        This deal is on the watch list — I didn't write a full brief for it since it's not a strong match for your buy box. Let me know if you want me to break it down anyway.
      </div>
      <button class="btn-breakdown" onClick={startBreakdown}>Break down this deal</button>
    </div>
  );
}

export function Chat() {
  const msgsRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    if (msgsRef.current) {
      msgsRef.current.scrollTop = msgsRef.current.scrollHeight;
    }
  }, [chatMessages.value]);

  // Auto-trigger for onboarding and scan debrief (NOT deal view)
  useEffect(() => {
    if (view.value === 'onboarding' && chatMessages.value.length === 0) {
      sendMessage('Hi, I want to set up my buy box.', '/api/chat', { mode: 'buy_box_intake' });
    } else if (view.value === 'scan' && chatMessages.value.length === 0 && activeThreadId.value) {
      sendMessage('Show me my scan results.', '/api/chat', { mode: 'scan_debrief', search_id: activeThreadId.value });
    }
    // Deal view: do NOT auto-trigger — brief or watch placeholder handles it
  }, [view.value, activeThreadId.value]);

  useEffect(() => {
    const handler = async (e) => {
      const { search_id } = e.detail;
      const msgs = [...chatMessages.value];
      msgs.push({ role: 'system', content: 'Buy box saved. Starting your scan...' });
      chatMessages.value = msgs;

      try {
        await fetch('/api/scan-start', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ search_id })
        });
      } catch { /* scan-start may not be fully wired yet */ }

      await loadUserData();
      view.value = 'scan';
      await switchThread(search_id, 'scan', null);
    };
    window.addEventListener('buybox-saved', handler);
    return () => window.removeEventListener('buybox-saved', handler);
  }, []);

  const handleSend = () => {
    if (chatStreaming.value) return;
    const text = inputRef.current?.value?.trim();
    if (!text) return;
    inputRef.current.value = '';

    if (view.value === 'deal' && currentDeal.value) {
      const scan = scans.value.find(s => s.id === currentDeal.value.search_id);
      sendMessage(text, '/api/deal-chat', { deal: currentDeal.value, buy_box: scan?.buy_box || {} });
    } else {
      const extra = {};
      if (view.value === 'scan' && activeThreadId.value) {
        extra.mode = 'scan_debrief';
        extra.search_id = activeThreadId.value;
      }
      sendMessage(text, '/api/chat', extra);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  // Determine if we should show a pre-generated brief or watch placeholder
  const deal = currentDeal.value;
  const showBrief = view.value === 'deal' && deal && deal.brief && chatMessages.value.length === 0;
  const showWatch = view.value === 'deal' && deal && !deal.brief && chatMessages.value.length === 0;

  return (
    <div id="chat-panel">
      <div class="chat-messages" ref={msgsRef}>
        <div class="chat-messages-inner">
          {/* Pre-generated brief for HOT/STRONG deals */}
          {showBrief && (
            <div class="msg msg-assistant">
              <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
              <div class="msg-body">{deal.brief}</div>
            </div>
          )}

          {/* Watch list placeholder */}
          {showWatch && <WatchPlaceholder deal={deal} />}

          {/* Regular conversation messages */}
          {chatMessages.value.map((msg, i) => (
            <div key={i} class={`msg msg-${msg.role}`}>
              {msg.role === 'assistant' ? (
                <>
                  <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
                  <div class="msg-body">{msg.content}</div>
                </>
              ) : msg.role === 'system' ? (
                <div class="msg-system">{msg.content}</div>
              ) : (
                msg.content
              )}
            </div>
          ))}
          {chatStreaming.value && chatMessages.value[chatMessages.value.length - 1]?.role !== 'assistant' && (
            <TypingIndicator />
          )}
        </div>
      </div>

      <div class="chat-input-bar">
        <div class="chat-input-inner">
          <input
            ref={inputRef}
            type="text"
            placeholder={view.value === 'deal' ? 'Ask about this deal...' : 'Talk to your agent...'}
            autocomplete="off"
            onKeyDown={handleKeyDown}
          />
          <button class="btn-send" onClick={handleSend} disabled={chatStreaming.value}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="22" y1="2" x2="11" y2="13" /><polygon points="22 2 15 22 11 13 2 9 22 2" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}
