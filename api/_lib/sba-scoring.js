'use strict';

const SIGNALS = [
  { key: 'license_25y',          category: 'owner_age',         weight: 15 },
  { key: 'business_reg_25y',     category: 'owner_age',         weight: 10 },
  { key: 'linkedin_grad_pre85',  category: 'owner_age',         weight: 10 }, // LinkedIn — pending
  { key: 'solo_practitioner',    category: 'succession_vacuum', weight: 15 },
  { key: 'no_associate',         category: 'succession_vacuum', weight: 10 }, // partly LinkedIn — pending
  { key: 'no_family_in_biz',     category: 'succession_vacuum', weight:  5 },
  { key: 'website_stale_3y',     category: 'digital_decay',     weight:  8 },
  { key: 'outdated_tech',        category: 'digital_decay',     weight:  4 },
  { key: 'dead_social',          category: 'digital_decay',     weight:  5 },
  { key: 'review_velocity_drop', category: 'activity_decline',  weight:  8 },
  { key: 'last_review_60d',      category: 'activity_decline',  weight:  5 },
  { key: 'no_jobs_12mo',         category: 'no_growth',         weight:  3 }, // LinkedIn — pending
  { key: 'flat_staff_5y',        category: 'no_growth',         weight:  2 }, // LinkedIn — pending
];
// total = 100

/**
 * Score a lead from an array of signal results.
 *
 * @param {Array<{key: string, fired: boolean, evidence: string, source: string, source_url: string|null}>} signalResults
 * @returns {{ score: number, tier: string, signals: Array }}
 */
function scoreLead(signalResults) {
  const resultsByKey = {};
  for (const r of signalResults) {
    resultsByKey[r.key] = r;
  }

  let score = 0;
  const signals = SIGNALS.map((def) => {
    const result = resultsByKey[def.key] || {
      fired: false,
      evidence: null,
      source: null,
      source_url: null,
    };
    if (result.fired) {
      score += def.weight;
    }
    return {
      key: def.key,
      category: def.category,
      weight: def.weight,
      fired: result.fired,
      evidence: result.evidence || null,
      source: result.source || null,
      source_url: result.source_url || null,
    };
  });

  let tier;
  if (score >= 80) {
    tier = 'HOT';
  } else if (score >= 60) {
    tier = 'STRONG';
  } else if (score >= 40) {
    tier = 'WATCH';
  } else {
    tier = 'DISCARD';
  }

  return { score, tier, signals };
}

/**
 * Evaluate signals from a raw business record and score the lead.
 *
 * @param {Object} business
 * @returns {{ score: number, tier: string, signals: Array }}
 */
function scoreLeadFromBusiness(business) {
  const currentYear = new Date().getFullYear();

  const signalResults = [];

  // --- owner_age ---

  // license_25y
  if (business.license_year != null) {
    const yearsAgo = currentYear - Number(business.license_year);
    const fired = yearsAgo >= 25;
    signalResults.push({
      key: 'license_25y',
      fired,
      evidence: fired
        ? `License issued in ${business.license_year} — ${yearsAgo} years ago`
        : `License issued in ${business.license_year} — only ${yearsAgo} years ago`,
      source: 'tx_dental_board',
      source_url: null,
    });
  } else {
    signalResults.push({
      key: 'license_25y',
      fired: false,
      evidence: 'License year not available',
      source: 'tx_dental_board',
      source_url: null,
    });
  }

  // business_reg_25y
  {
    const yib = Number(business.years_in_business);
    const fired = Number.isFinite(yib) && yib >= 25;
    signalResults.push({
      key: 'business_reg_25y',
      fired,
      evidence: Number.isFinite(yib)
        ? `Business registered ${yib} years ago`
        : 'Years in business not available',
      source: 'business_registration',
      source_url: null,
    });
  }

  // linkedin_grad_pre85 — LinkedIn not yet integrated
  signalResults.push({
    key: 'linkedin_grad_pre85',
    fired: false,
    evidence: 'LinkedIn data not yet integrated',
    source: 'pending',
    source_url: null,
  });

  // --- succession_vacuum ---

  // solo_practitioner
  {
    const fired = business.solo_practitioner === true;
    signalResults.push({
      key: 'solo_practitioner',
      fired,
      evidence: fired ? 'Listed as solo practitioner' : 'Solo practitioner status not confirmed',
      source: 'website_analysis',
      source_url: null,
    });
  }

  // no_associate
  {
    const fired = business.no_associate === true;
    signalResults.push({
      key: 'no_associate',
      fired,
      evidence: fired ? 'No associate dentist found' : 'Associate status not confirmed',
      source: 'website_analysis',
      source_url: null,
    });
  }

  // no_family_in_biz
  {
    const fired = business.no_family_in_biz === true;
    signalResults.push({
      key: 'no_family_in_biz',
      fired,
      evidence: fired ? 'No family members found in practice' : 'Family-in-business status not confirmed',
      source: 'website_analysis',
      source_url: null,
    });
  }

  // --- digital_decay ---

  // website_stale_3y
  {
    const staleYears = Number(business.website_stale_years);
    const fired = Number.isFinite(staleYears) && staleYears >= 3;
    signalResults.push({
      key: 'website_stale_3y',
      fired,
      evidence: Number.isFinite(staleYears)
        ? `Website last updated ${staleYears} year(s) ago`
        : 'Website staleness not available',
      source: 'website_analysis',
      source_url: business.website || null,
    });
  }

  // outdated_tech
  {
    const fired = business.outdated_tech === true;
    signalResults.push({
      key: 'outdated_tech',
      fired,
      evidence: fired ? 'Outdated website technology detected' : 'Website technology not flagged as outdated',
      source: 'website_analysis',
      source_url: business.website || null,
    });
  }

  // dead_social
  {
    const fired = business.dead_social === true;
    signalResults.push({
      key: 'dead_social',
      fired,
      evidence: fired ? 'Social media presence is inactive or absent' : 'Social media not flagged as dead',
      source: 'social_analysis',
      source_url: null,
    });
  }

  // --- activity_decline ---

  // review_velocity_drop
  {
    const fired = business.review_velocity_drop === true;
    signalResults.push({
      key: 'review_velocity_drop',
      fired,
      evidence: fired ? 'Review velocity has declined significantly' : 'No review velocity drop detected',
      source: 'review_analysis',
      source_url: null,
    });
  }

  // last_review_60d
  {
    const days = business.last_review_days != null ? Number(business.last_review_days) : null;
    const fired = days != null && days >= 60;
    signalResults.push({
      key: 'last_review_60d',
      fired,
      evidence: days != null
        ? `Last review was ${days} day(s) ago`
        : 'Last review date not available',
      source: 'review_analysis',
      source_url: null,
    });
  }

  // --- no_growth ---

  // no_jobs_12mo — LinkedIn not yet integrated
  signalResults.push({
    key: 'no_jobs_12mo',
    fired: false,
    evidence: 'LinkedIn data not yet integrated',
    source: 'pending',
    source_url: null,
  });

  // flat_staff_5y — LinkedIn not yet integrated
  signalResults.push({
    key: 'flat_staff_5y',
    fired: false,
    evidence: 'LinkedIn data not yet integrated',
    source: 'pending',
    source_url: null,
  });

  return scoreLead(signalResults);
}

module.exports = { SIGNALS, scoreLead, scoreLeadFromBusiness };
