import { describe, it, expect } from 'vitest';
import { deriveCounts } from './ScanProgress.jsx';

function makeStep(step, listing_count) {
  return { step, listing_count, status: 'complete', id: Math.random() };
}

describe('deriveCounts', () => {
  it('returns zeros for empty steps', () => {
    expect(deriveCounts([])).toEqual({ reviewed: 0, scored: 0 });
  });

  it('sums scrape:*:done rows when no enrich:done', () => {
    const steps = [
      makeStep('scrape:landsearch:done', 100),
      makeStep('scrape:naiohb:done', 50),
    ];
    expect(deriveCounts(steps)).toEqual({ reviewed: 150, scored: 0 });
  });

  it('prefers enrich:done over scrape sum when present', () => {
    const steps = [
      makeStep('scrape:landsearch:done', 100),
      makeStep('scrape:naiohb:done', 50),
      makeStep('enrich:done', 130), // deduped: less than raw sum
    ];
    expect(deriveCounts(steps)).toEqual({ reviewed: 130, scored: 0 });
  });

  it('captures score:done as scored', () => {
    const steps = [
      makeStep('scrape:landsearch:done', 100),
      makeStep('score:done', 12),
    ];
    expect(deriveCounts(steps)).toEqual({ reviewed: 100, scored: 12 });
  });

  it('captures apply_buybox:done as scored when no score:done', () => {
    const steps = [
      makeStep('scrape:landsearch:done', 80),
      makeStep('apply_buybox:done', 8),
    ];
    expect(deriveCounts(steps)).toEqual({ reviewed: 80, scored: 8 });
  });

  it('takes the higher value when both score:done and apply_buybox:done present', () => {
    const steps = [
      makeStep('apply_buybox:done', 20),
      makeStep('score:done', 15),
    ];
    // score:done and apply_buybox:done both contribute to scored — take max
    expect(deriveCounts(steps)).toEqual({ reviewed: 0, scored: 20 });
  });

  it('ignores rows with null listing_count', () => {
    const steps = [
      { step: 'scrape:landsearch:start', listing_count: null, status: 'running', id: 1 },
      makeStep('scrape:landsearch:done', 75),
    ];
    expect(deriveCounts(steps)).toEqual({ reviewed: 75, scored: 0 });
  });

  it('ignores unknown step prefixes', () => {
    const steps = [
      makeStep('discover:done', 99),
      makeStep('scrape:landsearch:done', 50),
    ];
    expect(deriveCounts(steps)).toEqual({ reviewed: 50, scored: 0 });
  });
});
