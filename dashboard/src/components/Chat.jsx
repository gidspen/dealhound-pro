import { useRef, useEffect, useState } from 'preact/hooks';
import { batch } from '@preact/signals';
import { view, agentName, chatMessages, chatStreaming, activeThreadId, scans, deals, currentDeal, previewOpen, email } from '../lib/state.js';
import { sendMessage, loadUserData, switchThread } from '../lib/api.js';
import { parseBreakdown, tierFromStrategy } from '../lib/utils.js';
import { ScanProgress } from './ScanProgress.jsx';

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
  const [activeScanId, setActiveScanId] = useState(null);

  useEffect(() => {
    const onSaved = (e) => setActiveScanId(e.detail?.search_id || null);
    window.addEventListener('buybox-saved', onSaved);
    return () => window.removeEventListener('buybox-saved', onSaved);
  }, []);

  // Always mount ScanProgress while the user is on the scan view, even after
  // a page reload. Without this the live log only renders right after a
  // buybox-saved event and the user has no idea the scan is still running.
  useEffect(() => {
    if (view.value === 'scan' && activeThreadId.value) {
      setActiveScanId(activeThreadId.value);
    } else if (view.value !== 'scan') {
      setActiveScanId(null);
    }
  }, [view.value, activeThreadId.value]);

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
      // The server-side prompt detects scan-in-progress and replies with a
      // "still hunting" message instead of fabricating "0 deals found."
      // When the scan completes, the scan-complete listener below re-fires
      // this same call to deliver the real debrief.
      sendMessage('Show me my scan results.', '/api/chat', { mode: 'scan_debrief', search_id: activeThreadId.value });
    }
    // Deal view: do NOT auto-trigger — brief or watch placeholder handles it
  }, [view.value, activeThreadId.value]);

  // When ScanProgress detects the scan flipped to complete, re-fire the
  // debrief so the agent reports the actual deals it found.
  useEffect(() => {
    const onComplete = async (e) => {
      const completedId = e.detail?.searchId;
      if (!completedId || completedId !== activeThreadId.value) return;
      if (view.value !== 'scan') return;
      if (chatStreaming.value) return;
      // Refresh deals/scans cache before the debrief reads them.
      await loadUserData();
      sendMessage('The scan is done — show me what you found.', '/api/chat', {
        mode: 'scan_debrief',
        search_id: completedId,
      });
    };
    window.addEventListener('scan-complete', onComplete);
    return () => window.removeEventListener('scan-complete', onComplete);
  }, []);

  useEffect(() => {
    const handler = async (e) => {
      const { search_id } = e.detail;
      const msgs = [...chatMessages.value];

      msgs.push({ role: 'system', content: 'Buy box saved. Your agent is scanning the market...' });
      chatMessages.value = msgs;

      await loadUserData();

      // Always go to scan view — every buy box save triggers a fresh scan
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

  // "View My Results" — used in scan debrief when 0 deals from the scan
  // itself but the pool has deals. Reloads user data and goes to deal view.
  const handleViewResults = async () => {
    await loadUserData();
    if (deals.value.length > 0) {
      const topDeal = deals.value[0];
      batch(() => {
        activeThreadId.value = topDeal.id;
        view.value = 'deal';
        previewOpen.value = true;
      });
      await switchThread(topDeal.id, 'deal', null);
    } else {
      // Still nothing — tell the user honestly
      const msgs = [...chatMessages.value];
      msgs.push({ role: 'system', content: 'No deals in the pool yet for your buy box. The scanner will find new matches daily — check back tomorrow.' });
      chatMessages.value = msgs;
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

      {activeScanId && <ScanProgress searchId={activeScanId} />}

      {/* View My Results CTA — shown in scan view once Quinn has responded */}
      {view.value === 'scan' && !chatStreaming.value && chatMessages.value.some(m => m.role === 'assistant') && (
        <div class="scan-cta-bar">
          <button class="btn-view-results" onClick={handleViewResults}>
            View My Results →
          </button>
        </div>
      )}

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
