import { describe, it, expect } from 'vitest';
import { tierFromStrategy, fmtPrice, tierLabel } from './utils.js';

// ---------------------------------------------------------------------------
// tierFromStrategy — full path coverage
// ---------------------------------------------------------------------------

describe('tierFromStrategy — null / falsy inputs', () => {
  it('returns watch for null', () => {
    expect(tierFromStrategy(null)).toBe('watch');
  });

  it('returns watch for undefined', () => {
    expect(tierFromStrategy(undefined)).toBe('watch');
  });

  it('returns watch for empty string', () => {
    expect(tierFromStrategy('')).toBe('watch');
  });
});

describe('tierFromStrategy — string branch (legacy pipeline shape)', () => {
  it('"STRONG MATCH" → hot', () => {
    expect(tierFromStrategy('STRONG MATCH')).toBe('hot');
  });

  it('"MATCH" → strong', () => {
    expect(tierFromStrategy('MATCH')).toBe('strong');
  });

  it('"NO MATCH" → pass', () => {
    expect(tierFromStrategy('NO MATCH')).toBe('pass');
  });

  it('unknown string → watch (default branch)', () => {
    expect(tierFromStrategy('PENDING')).toBe('watch');
    expect(tierFromStrategy('UNKNOWN')).toBe('watch');
  });

  it('case-insensitive string match: lower-case "match" → strong', () => {
    expect(tierFromStrategy('match')).toBe('strong');
  });

  it('case-insensitive string match: mixed-case "Strong Match" → hot', () => {
    expect(tierFromStrategy('Strong Match')).toBe('hot');
  });
});

describe('tierFromStrategy — flat tier field (new pipeline shape)', () => {
  it('tier:"HOT" → hot', () => {
    expect(tierFromStrategy({ tier: 'HOT' })).toBe('hot');
  });

  it('tier:"STRONG" → strong', () => {
    expect(tierFromStrategy({ tier: 'STRONG' })).toBe('strong');
  });

  it('tier:"WATCH" → watch', () => {
    expect(tierFromStrategy({ tier: 'WATCH' })).toBe('watch');
  });

  it('tier:"PASS" → pass', () => {
    expect(tierFromStrategy({ tier: 'PASS' })).toBe('pass');
  });

  // Case insensitivity on the object tier field
  it('tier:"hot" (lower-case) → hot', () => {
    expect(tierFromStrategy({ tier: 'hot' })).toBe('hot');
  });

  it('tier:"Strong" (mixed-case) → strong', () => {
    expect(tierFromStrategy({ tier: 'Strong' })).toBe('strong');
  });

  it('tier:"pass" (lower-case) → pass', () => {
    expect(tierFromStrategy({ tier: 'pass' })).toBe('pass');
  });
});

describe('tierFromStrategy — nested strategy.overall (old breakdown shape)', () => {
  it('strategy.overall:"STRONG MATCH" with no tier field → hot', () => {
    expect(tierFromStrategy({ strategy: { overall: 'STRONG MATCH' } })).toBe('hot');
  });

  it('strategy.overall:"MATCH" → strong', () => {
    expect(tierFromStrategy({ strategy: { overall: 'MATCH' } })).toBe('strong');
  });

  it('strategy.overall:"NO MATCH" → pass', () => {
    expect(tierFromStrategy({ strategy: { overall: 'NO MATCH' } })).toBe('pass');
  });

  it('strategy.overall:"unknown" → watch (recursive default)', () => {
    expect(tierFromStrategy({ strategy: { overall: 'unknown' } })).toBe('watch');
  });

  it('direct tier field takes precedence over strategy.overall', () => {
    // tier:"HOT" wins over strategy.overall:"NO MATCH"
    expect(tierFromStrategy({ tier: 'HOT', strategy: { overall: 'NO MATCH' } })).toBe('hot');
  });
});

describe('tierFromStrategy — score-based fallback', () => {
  it('score >= 70 → hot', () => {
    expect(tierFromStrategy({ score: 70 })).toBe('hot');
    expect(tierFromStrategy({ score: 85 })).toBe('hot');
    expect(tierFromStrategy({ score: 100 })).toBe('hot');
  });

  it('score >= 50 and < 70 → strong', () => {
    expect(tierFromStrategy({ score: 50 })).toBe('strong');
    expect(tierFromStrategy({ score: 69 })).toBe('strong');
  });

  it('score >= 30 and < 50 → watch', () => {
    expect(tierFromStrategy({ score: 30 })).toBe('watch');
    expect(tierFromStrategy({ score: 49 })).toBe('watch');
  });

  it('score < 30 → pass', () => {
    expect(tierFromStrategy({ score: 0 })).toBe('pass');
    expect(tierFromStrategy({ score: 29 })).toBe('pass');
    expect(tierFromStrategy({ score: -5 })).toBe('pass');
  });

  it('exact boundary: score === 70 → hot (not strong)', () => {
    expect(tierFromStrategy({ score: 70 })).toBe('hot');
  });

  it('exact boundary: score === 50 → strong (not watch)', () => {
    expect(tierFromStrategy({ score: 50 })).toBe('strong');
  });

  it('exact boundary: score === 30 → watch (not pass)', () => {
    expect(tierFromStrategy({ score: 30 })).toBe('watch');
  });

  it('tier field takes precedence over score', () => {
    // tier:"PASS" with score 95 — tier wins
    expect(tierFromStrategy({ tier: 'PASS', score: 95 })).toBe('pass');
  });

  it('strategy.overall takes precedence over score', () => {
    // strategy.overall:"NO MATCH" with score 90 — strategy wins
    expect(tierFromStrategy({ strategy: { overall: 'NO MATCH' }, score: 90 })).toBe('pass');
  });

  it('unknown tier string falls through to score', () => {
    // tier value not in HOT/STRONG/WATCH/PASS triggers fall-through to score branch
    expect(tierFromStrategy({ tier: 'UNKNOWN', score: 75 })).toBe('hot');
    expect(tierFromStrategy({ tier: 'UNKNOWN', score: 25 })).toBe('pass');
  });
});

describe('tierFromStrategy — object with no tier / strategy / score', () => {
  it('empty object → watch', () => {
    expect(tierFromStrategy({})).toBe('watch');
  });

  it('object with only unrelated keys → watch', () => {
    expect(tierFromStrategy({ risk: { level: 'HIGH' } })).toBe('watch');
  });

  it('strategy object with no overall → watch', () => {
    expect(tierFromStrategy({ strategy: {} })).toBe('watch');
  });

  it('strategy.overall is null → falls to score/watch', () => {
    // strategy?.overall is null, not truthy, so skips recursive call
    expect(tierFromStrategy({ strategy: { overall: null }, score: 60 })).toBe('strong');
  });
});

describe('tierFromStrategy — Preview.jsx call-site shape { ...bd, score: deal.score }', () => {
  it('spread bd with strategy.overall + score — strategy.overall wins', () => {
    const bd = { strategy: { overall: 'STRONG MATCH' }, risk: {} };
    const dealScore = 40; // would be 'watch' alone
    expect(tierFromStrategy({ ...bd, score: dealScore })).toBe('hot');
  });

  it('spread bd with tier field + score — tier wins', () => {
    const bd = { tier: 'PASS', strategy: {} };
    const dealScore = 95;
    expect(tierFromStrategy({ ...bd, score: dealScore })).toBe('pass');
  });

  it('spread bd with no tier or strategy.overall — falls through to score', () => {
    const bd = { risk: { level: 'LOW' } };
    const dealScore = 55;
    expect(tierFromStrategy({ ...bd, score: dealScore })).toBe('strong');
  });

  it('spread bd with empty strategy + score — score is used', () => {
    const bd = { strategy: {}, risk: {} };
    const dealScore = 25;
    expect(tierFromStrategy({ ...bd, score: dealScore })).toBe('pass');
  });

  it('spread bd with all undefined fields + score 0 → pass', () => {
    expect(tierFromStrategy({ score: 0 })).toBe('pass');
  });
});

// ---------------------------------------------------------------------------
// Regression guard: pass bucket in Preview.jsx grouped map
// The grouped object in ScanDealList includes `pass`, so tierFromStrategy
// must return exactly the string 'pass' for it to land in that bucket.
// ---------------------------------------------------------------------------
describe('tierFromStrategy — pass tier bucket regression', () => {
  it('returns exact string "pass" (not "PASS") for grouped[tier] keying', () => {
    expect(tierFromStrategy({ tier: 'PASS' })).toBe('pass');
    expect(tierFromStrategy('NO MATCH')).toBe('pass');
    expect(tierFromStrategy({ score: 0 })).toBe('pass');
  });
});

// ---------------------------------------------------------------------------
// fmtPrice — sanity checks (pre-existing, non-DB)
// ---------------------------------------------------------------------------
describe('fmtPrice', () => {
  it('null → em-dash', () => {
    expect(fmtPrice(null)).toBe('—');
  });

  it('undefined → em-dash', () => {
    expect(fmtPrice(undefined)).toBe('—');
  });

  it('millions formatted with 1 decimal', () => {
    expect(fmtPrice(1500000)).toBe('$1.5M');
  });

  it('thousands rounded', () => {
    expect(fmtPrice(250000)).toBe('$250k');
  });

  it('sub-1000 passed through as-is', () => {
    expect(fmtPrice(500)).toBe('$500');
  });
});

// ---------------------------------------------------------------------------
// tierLabel — maps tier to uppercase display label
// ---------------------------------------------------------------------------
describe('tierLabel', () => {
  it('hot → HOT', () => {
    expect(tierLabel('hot')).toBe('HOT');
  });

  it('strong → STRONG', () => {
    expect(tierLabel('strong')).toBe('STRONG');
  });

  it('watch → WATCH', () => {
    expect(tierLabel('watch')).toBe('WATCH');
  });

  it('pass → PASS', () => {
    expect(tierLabel('pass')).toBe('PASS');
  });

  it('unknown → WATCH (fallback)', () => {
    expect(tierLabel('garbage')).toBe('WATCH');
  });
});
