import { describe, it, expect } from 'vitest';
import { applyHardFilters } from '../../api/_lib/filters.js';

const baseBuyBox = {
  price_max: 3000000,
  price_min: '300000',
  acreage_min: 1.0,
  exclusions: ['mobile home'],
};

describe('null-safe filtering', () => {
  it('passes listing with null price (flags it)', () => {
    const listings = [{ title: 'Resort', price: null, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(true);
    expect(result[0].flags).toContain('price_unknown');
  });

  it('passes listing with null acreage (flags it)', () => {
    const listings = [{ title: 'Resort', price: 500000, acreage: null, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(true);
    expect(result[0].flags).toContain('acreage_unknown');
  });

  it('fails listing with price over max', () => {
    const listings = [{ title: 'Resort', price: 5000000, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });

  it('fails listing with price below min', () => {
    const listings = [{ title: 'Resort', price: 100000, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });

  it('fails listing with acreage below min', () => {
    const listings = [{ title: 'Resort', price: 500000, acreage: 0.3, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });

  it('fails listing matching exclusion keyword', () => {
    const listings = [{ title: 'Mobile Home Park', price: 500000, acreage: 5, location: 'TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });

  it('fails listing matching exclusion in description', () => {
    const listings = [{ title: 'Nice Park', price: 500000, acreage: 5, location: 'TX', description: 'This is a mobile home community' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(false);
  });

  it('passes clean listing with all fields present', () => {
    const listings = [{ title: 'Lakefront Resort', price: 1200000, acreage: 10, location: 'Austin, TX' }];
    const result = applyHardFilters(listings, baseBuyBox);
    expect(result[0].passed_hard_filters).toBe(true);
    expect(result[0].flags).toEqual([]);
  });
});

describe('cross-source deduplication', () => {
  it('deduplicates by address (tier 1)', () => {
    const listings = [
      { title: 'Lake Resort A', price: 500000, location: 'Austin, TX', address: '123 Lake Dr', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Lake Resort B', price: 500000, location: 'Austin, TX', address: '123 Lake Drive', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(1);
    expect(passed[0].also_listed_on).toBeTruthy();
    expect(passed[0].also_listed_on.length).toBeGreaterThan(0);
  });

  it('keeps the listing with more non-null fields on dupe', () => {
    const listings = [
      { title: 'Resort A', price: 500000, location: 'Austin, TX', address: '456 Oak St', url: 'https://a.com/1', source: 'bizbuysell', acreage: null, revenue_hint: null },
      { title: 'Resort B', price: 500000, location: 'Austin, TX', address: '456 Oak Street', url: 'https://b.com/1', source: 'landwatch', acreage: 10, revenue_hint: '$80k/yr' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(1);
    // The one with more data (landwatch) should be kept
    expect(passed[0].source).toBe('landwatch');
  });

  it('deduplicates by price+city+title (tier 2)', () => {
    const listings = [
      { title: 'Lakefront Glamping Resort', price: 1200000, location: 'Austin, TX', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Glamping Resort Lakefront', price: 1230000, location: 'Austin, TX', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(1);
  });

  it('flags possible dupes by price+city only (tier 3)', () => {
    const listings = [
      { title: 'Resort Investment', price: 1200000, location: 'Austin, TX', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Commercial Property', price: 1230000, location: 'Austin, TX', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(2);  // Both kept
    expect(passed[0].possible_duplicate).toBe(true);
    expect(passed[1].possible_duplicate).toBe(true);
  });

  it('does not flag listings with very different prices as dupes', () => {
    const listings = [
      { title: 'Resort A', price: 500000, location: 'Austin, TX', url: 'https://a.com/1', source: 'bizbuysell' },
      { title: 'Resort B', price: 2000000, location: 'Austin, TX', url: 'https://b.com/1', source: 'landwatch' },
    ];
    const result = applyHardFilters(listings, baseBuyBox);
    const passed = result.filter(r => r.passed_hard_filters);
    expect(passed.length).toBe(2);
    expect(passed[0].possible_duplicate).toBeFalsy();
    expect(passed[1].possible_duplicate).toBeFalsy();
  });
});
