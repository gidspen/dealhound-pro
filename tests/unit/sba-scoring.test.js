import { describe, it, expect } from 'vitest';
import { scoreLead, SIGNALS } from '../../api/_lib/sba-scoring.js';

/**
 * Build a full signalResults array from SIGNALS, firing only the keys listed.
 * Every signal not in firedKeys gets fired: false.
 */
function buildSignalResults(firedKeys) {
  return SIGNALS.map(({ key }) => ({
    key,
    fired: firedKeys.includes(key),
    evidence: firedKeys.includes(key) ? `Test: ${key} fired` : `Test: ${key} not fired`,
    source: 'test',
    source_url: null,
  }));
}

describe('scoreLead', () => {
  it('returns tier HOT and score 85 when the right signals fire', () => {
    // license_25y(15) + solo_practitioner(15) + business_reg_25y(10) + no_associate(10)
    // + website_stale_3y(8) + review_velocity_drop(8) + dead_social(5)
    // + no_family_in_biz(5) + last_review_60d(5) + outdated_tech(4) = 85
    const firedKeys = [
      'license_25y',
      'solo_practitioner',
      'business_reg_25y',
      'no_associate',
      'website_stale_3y',
      'review_velocity_drop',
      'dead_social',
      'no_family_in_biz',
      'last_review_60d',
      'outdated_tech',
    ];
    const result = scoreLead(buildSignalResults(firedKeys));
    expect(result.score).toBe(85);
    expect(result.tier).toBe('HOT');
    expect(result.signals).toHaveLength(SIGNALS.length);
  });

  it('returns tier STRONG and score 68 when the right signals fire', () => {
    // license_25y(15) + solo_practitioner(15) + business_reg_25y(10)
    // + website_stale_3y(8) + review_velocity_drop(8) + dead_social(5)
    // + last_review_60d(5) + flat_staff_5y(2) = 68
    const firedKeys = [
      'license_25y',
      'solo_practitioner',
      'business_reg_25y',
      'website_stale_3y',
      'review_velocity_drop',
      'dead_social',
      'last_review_60d',
      'flat_staff_5y',
    ];
    const result = scoreLead(buildSignalResults(firedKeys));
    expect(result.score).toBe(68);
    expect(result.tier).toBe('STRONG');
  });

  it('returns tier WATCH and score 45 when the right signals fire', () => {
    // license_25y(15) + solo_practitioner(15) + business_reg_25y(10)
    // + no_family_in_biz(5) = 45
    const firedKeys = [
      'license_25y',
      'solo_practitioner',
      'business_reg_25y',
      'no_family_in_biz',
    ];
    const result = scoreLead(buildSignalResults(firedKeys));
    expect(result.score).toBe(45);
    expect(result.tier).toBe('WATCH');
  });

  it('returns tier DISCARD and score 25 when only weak signals fire', () => {
    // license_25y(15) + business_reg_25y(10) = 25
    const firedKeys = [
      'license_25y',
      'business_reg_25y',
    ];
    const result = scoreLead(buildSignalResults(firedKeys));
    expect(result.score).toBe(25);
    expect(result.tier).toBe('DISCARD');
  });

  it('returns tier HOT at the exact threshold of 80 (boundary condition)', () => {
    // license_25y(15) + solo_practitioner(15) + business_reg_25y(10) + no_associate(10)
    // + website_stale_3y(8) + review_velocity_drop(8) + dead_social(5)
    // + last_review_60d(5) + outdated_tech(4) = 80
    const firedKeys = [
      'license_25y',
      'solo_practitioner',
      'business_reg_25y',
      'no_associate',
      'website_stale_3y',
      'review_velocity_drop',
      'dead_social',
      'last_review_60d',
      'outdated_tech',
    ];
    const result = scoreLead(buildSignalResults(firedKeys));
    expect(result.score).toBe(80);
    expect(result.tier).toBe('HOT'); // 80 is the lower bound — must be HOT, not STRONG
  });
});
