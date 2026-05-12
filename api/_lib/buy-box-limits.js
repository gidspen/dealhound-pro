const TIER_ACTIVE_BOX_LIMITS = {
  founding: 3,
  hunter: 3,
  investor: 8,
  operator: Infinity,
};

const TIER_SCAN_INTERVAL_MS = {
  founding: 24 * 60 * 60 * 1000,
  hunter: 24 * 60 * 60 * 1000,
  investor: 60 * 60 * 1000,
  operator: 15 * 60 * 1000,
};

module.exports = { TIER_ACTIVE_BOX_LIMITS, TIER_SCAN_INTERVAL_MS };
