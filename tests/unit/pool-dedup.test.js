import { describe, it, expect } from 'vitest';

// Extract the dedup logic into a testable function
// This mirrors the logic in api/user-data.js
function dedupPoolDeals(userDeals, poolDeals) {
  const userUrls = new Set(userDeals.map(d => d.url).filter(Boolean));
  return poolDeals.filter(d => !d.url || !userUrls.has(d.url));
}

describe('pool deal dedup', () => {
  it('removes pool deals with URLs matching user deals', () => {
    const userDeals = [
      { id: '1', url: 'https://rvparkstore.com/listing/123', title: 'RV Park A' },
      { id: '2', url: 'https://campground-marketplace.com/456', title: 'Camp B' },
    ];
    const poolDeals = [
      { id: '3', url: 'https://rvparkstore.com/listing/123', title: 'RV Park A' },
      { id: '4', url: 'https://rvparkstore.com/listing/789', title: 'RV Park C' },
      { id: '5', url: 'https://campground-marketplace.com/456', title: 'Camp B' },
    ];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('4');
  });

  it('keeps pool deals with null URLs', () => {
    const userDeals = [{ id: '1', url: 'https://example.com/1' }];
    const poolDeals = [{ id: '2', url: null, title: 'No URL Deal' }];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
  });

  it('returns all pool deals when user has no deals', () => {
    const poolDeals = [
      { id: '1', url: 'https://example.com/1' },
      { id: '2', url: 'https://example.com/2' },
    ];

    const result = dedupPoolDeals([], poolDeals);
    expect(result).toHaveLength(2);
  });

  it('handles day-over-day duplicates (same URL different days)', () => {
    const userDeals = [
      { id: '1', url: 'https://rvparkstore.com/listing/123', title: 'Park A (Monday)' },
    ];
    const poolDeals = [
      { id: '2', url: 'https://rvparkstore.com/listing/123', title: 'Park A (Tuesday)' },
      { id: '3', url: 'https://rvparkstore.com/listing/456', title: 'Park B (new)' },
    ];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
    expect(result[0].title).toBe('Park B (new)');
  });

  it('handles empty pool deals', () => {
    const userDeals = [{ id: '1', url: 'https://example.com/1' }];
    const result = dedupPoolDeals(userDeals, []);
    expect(result).toHaveLength(0);
  });

  it('handles both user and pool having no URLs', () => {
    const userDeals = [{ id: '1', url: null }];
    const poolDeals = [{ id: '2', url: null }];

    const result = dedupPoolDeals(userDeals, poolDeals);
    expect(result).toHaveLength(1);
  });
});
