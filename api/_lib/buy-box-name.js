// api/_lib/buy-box-name.js
//
// Shared helper for deriving a human-readable buy box name from criteria.
// Used by free-scan-start.js and chat.js save_buy_box handler.

/**
 * Derive a human-readable name from buy box criteria.
 * Accepts either the free-scan shape (assetType/market) or the chat shape
 * (asset_type/market, or property_types/locations).
 *
 * @param {object} criteria
 * @returns {string}
 */
function deriveBuyBoxName(criteria) {
  if (!criteria) return 'Buy Box';

  // Free-scan shape: { asset_type, market }
  const assetType = criteria.asset_type || (criteria.property_types && criteria.property_types[0]);
  const market = criteria.market || (criteria.locations && criteria.locations[0]);

  if (assetType && market) return `${assetType} in ${market}`;
  if (assetType) return assetType;
  if (market) return market;
  return 'Buy Box';
}

module.exports = { deriveBuyBoxName };
