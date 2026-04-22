import { signal, computed } from '@preact/signals';

export const email = signal(null);
export const agentName = signal(null);
export const view = signal('gate');
export const activeThreadId = signal(null);
export const settingsOpen = signal(false);
export const previewOpen = signal(false);

export const scans = signal([]);
export const deals = signal([]);
export const activeThreads = signal([]);
export const starredDealIds = signal(new Set());

export const chatMessages = signal([]);
export const chatConversationId = signal(null);
export const chatStreaming = signal(false);

const MAX_CACHE = 8;
const cache = new Map();

export function cacheGet(threadId) {
  const entry = cache.get(threadId);
  if (entry) {
    entry.lastAccessed = Date.now();
    return entry;
  }
  return null;
}

export function cacheSet(threadId, data) {
  cache.set(threadId, { ...data, lastAccessed: Date.now() });
  if (cache.size > MAX_CACHE) {
    let oldestKey = null, oldestTime = Infinity;
    for (const [key, val] of cache) {
      if (key !== activeThreadId.value && val.lastAccessed < oldestTime) {
        oldestTime = val.lastAccessed;
        oldestKey = key;
      }
    }
    if (oldestKey) cache.delete(oldestKey);
  }
}

export const activeDeals = computed(() => {
  const threadDealIds = new Set(activeThreads.value.map(t => t.deal_id));
  return deals.value.filter(d => threadDealIds.has(d.id));
});

export const currentScan = computed(() => {
  if (view.value !== 'scan') return null;
  return scans.value.find(s => s.id === activeThreadId.value) || null;
});

export const currentDeal = computed(() => {
  if (view.value !== 'deal') return null;
  return deals.value.find(d => d.id === activeThreadId.value) || null;
});

export const dealsForCurrentScan = computed(() => {
  const scan = currentScan.value;
  if (!scan) return [];
  return deals.value.filter(d => d.search_id === scan.id);
});
