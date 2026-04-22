import { useRef, useEffect } from 'preact/hooks';
import { view, agentName, chatMessages, chatStreaming, activeThreadId, scans, currentDeal } from '../lib/state.js';
import { sendMessage, loadUserData } from '../lib/api.js';

function TypingIndicator() {
  return (
    <div class="msg msg-assistant">
      <div class="msg-label"><span class="msg-dot" />{agentName.value || 'Agent'}</div>
      <div class="typing"><span /><span /><span /></div>
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

  useEffect(() => {
    if (view.value === 'onboarding' && chatMessages.value.length === 0) {
      sendMessage('Hi, I want to set up my buy box.', '/api/chat', { mode: 'buy_box_intake' });
    } else if (view.value === 'scan' && chatMessages.value.length === 0 && activeThreadId.value) {
      sendMessage('Show me my scan results.', '/api/chat', { mode: 'scan_debrief', search_id: activeThreadId.value });
    } else if (view.value === 'deal' && chatMessages.value.length === 0 && currentDeal.value) {
      const scan = scans.value.find(s => s.id === currentDeal.value.search_id);
      const buyBox = scan?.buy_box || {};
      sendMessage('Break down this deal for me.', '/api/deal-chat', { deal: currentDeal.value, buy_box: buyBox });
    }
  }, [view.value, activeThreadId.value]);

  useEffect(() => {
    const handler = async () => {
      await loadUserData();
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

  return (
    <div id="chat-panel">
      <div class="chat-messages" ref={msgsRef}>
        <div class="chat-messages-inner">
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
