// api/lib/filters.js
function applyHardFilters(listings, buyBox) {
  return listings.map(listing => {
    const reasons = [];

    if (buyBox.price_max && listing.price && listing.price > buyBox.price_max) {
      reasons.push(`Price $${listing.price.toLocaleString()} exceeds max $${buyBox.price_max.toLocaleString()}`);
    }
    if (buyBox.price_min && buyBox.price_min !== 'null' && listing.price && listing.price < Number(buyBox.price_min)) {
      reasons.push(`Price $${listing.price.toLocaleString()} below min $${Number(buyBox.price_min).toLocaleString()}`);
    }
    if (buyBox.acreage_min && buyBox.acreage_min !== 'null' && listing.acreage && listing.acreage < buyBox.acreage_min) {
      reasons.push(`Acreage ${listing.acreage} below min ${buyBox.acreage_min}`);
    }
    if (buyBox.exclusions && buyBox.exclusions.length > 0) {
      const text = `${listing.title || ''} ${listing.description || ''}`.toLowerCase();
      for (const excl of buyBox.exclusions) {
        if (text.includes(excl.toLowerCase())) {
          reasons.push(`Matches exclusion: "${excl}"`);
        }
      }
    }

    return {
      ...listing,
      passed_hard_filters: reasons.length === 0,
      miss_reason: reasons.length > 0 ? reasons.join('; ') : null,
    };
  });
}

module.exports = { applyHardFilters };
