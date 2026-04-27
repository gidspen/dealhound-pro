// api/_lib/filters.js
// Null-safe filtering + three-tier cross-source deduplication.
// Ported from the /find-deals skill's apply-buybox.md logic.

/**
 * Normalize an address for dedup comparison.
 * "123 Lake Dr" → "123 lake drive"
 */
function normalizeAddress(addr) {
  if (!addr) return null;
  const abbrevs = {
    'st': 'street', 'st.': 'street',
    'dr': 'drive', 'dr.': 'drive',
    'ave': 'avenue', 'ave.': 'avenue',
    'blvd': 'boulevard', 'blvd.': 'boulevard',
    'ln': 'lane', 'ln.': 'lane',
    'rd': 'road', 'rd.': 'road',
    'ct': 'court', 'ct.': 'court',
    'pl': 'place', 'pl.': 'place',
    'cir': 'circle', 'cir.': 'circle',
    'hwy': 'highway', 'hwy.': 'highway',
    'pkwy': 'parkway', 'pkwy.': 'parkway',
    'trl': 'trail', 'trl.': 'trail',
  };

  let normalized = addr.toLowerCase().trim();
  // Replace abbreviations
  for (const [abbr, full] of Object.entries(abbrevs)) {
    const regex = new RegExp(`\\b${abbr.replace('.', '\\.')}\\b`, 'gi');
    normalized = normalized.replace(regex, full);
  }
  // Remove extra whitespace, punctuation
  normalized = normalized.replace(/[.,#]/g, '').replace(/\s+/g, ' ').trim();
  return normalized;
}

/**
 * Extract city from a location string like "Austin, TX" or "Austin, Texas".
 */
function extractCity(location) {
  if (!location) return null;
  const parts = location.split(',');
  return parts[0].trim().toLowerCase();
}

/**
 * Get significant words from a title (3+ chars, no stopwords).
 */
function significantWords(title) {
  if (!title) return [];
  const stops = new Set(['the', 'and', 'for', 'with', 'near', 'from']);
  return title.toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .split(/\s+/)
    .filter(w => w.length >= 3 && !stops.has(w));
}

/**
 * Count non-null fields in a listing object.
 */
function nonNullCount(listing) {
  const fields = ['title', 'price', 'location', 'address', 'url', 'acreage',
    'rooms_keys', 'revenue_hint', 'dom_hint', 'condition_hint', 'description',
    'property_type'];
  return fields.filter(f => listing[f] != null && listing[f] !== '').length;
}

/**
 * Three-tier cross-source deduplication.
 *
 * Tier 1: Normalized address match → definitive dupe
 * Tier 2: Price within 5% + same city + 2+ shared title words → probable dupe
 * Tier 3: Price within 5% + same city (only) → flag, keep both
 *
 * Returns listings with dedup metadata attached:
 *   - _is_dupe: true if this listing should be removed (tier 1 or 2 loser)
 *   - also_listed_on: [{source, url}] from merged dupes
 *   - possible_duplicate: true if tier 3 match
 */
function deduplicateListings(listings) {
  if (!listings || listings.length <= 1) return listings;

  // Index for dedup lookups
  const addressMap = new Map(); // normalizedAddr → [indices]
  const cityMap = new Map(); // city → [indices]

  for (let i = 0; i < listings.length; i++) {
    const l = listings[i];

    // Build address index
    const normAddr = normalizeAddress(l.address);
    if (normAddr) {
      if (!addressMap.has(normAddr)) addressMap.set(normAddr, []);
      addressMap.get(normAddr).push(i);
    }

    // Build city index for pairwise price comparison
    const city = extractCity(l.location);
    if (city) {
      if (!cityMap.has(city)) cityMap.set(city, []);
      cityMap.get(city).push(i);
    }
  }

  const removed = new Set();
  const alsoListedOn = {}; // index → [{source, url}]
  const possibleDupes = new Set();

  // Tier 1: Address match
  for (const [, indices] of addressMap) {
    if (indices.length <= 1) continue;
    // Keep the listing with most non-null fields
    let bestIdx = indices[0];
    let bestCount = nonNullCount(listings[bestIdx]);
    for (let k = 1; k < indices.length; k++) {
      const c = nonNullCount(listings[indices[k]]);
      if (c > bestCount) {
        bestIdx = indices[k];
        bestCount = c;
      }
    }
    // Mark others as dupes
    for (const idx of indices) {
      if (idx !== bestIdx) {
        removed.add(idx);
        if (!alsoListedOn[bestIdx]) alsoListedOn[bestIdx] = [];
        alsoListedOn[bestIdx].push({
          source: listings[idx].source,
          url: listings[idx].url,
        });
      }
    }
  }

  // Tier 2 + 3: Price within 5% + same city (pairwise comparison)
  for (const [, indices] of cityMap) {
    if (indices.length <= 1) continue;
    for (let a = 0; a < indices.length; a++) {
      for (let b = a + 1; b < indices.length; b++) {
        const idxA = indices[a];
        const idxB = indices[b];

        // Skip if already removed by tier 1
        if (removed.has(idxA) || removed.has(idxB)) continue;
        // Skip if same source
        if (listings[idxA].source === listings[idxB].source) continue;

        const priceA = listings[idxA].price;
        const priceB = listings[idxB].price;
        if (!priceA || !priceB) continue;

        const priceDiff = Math.abs(priceA - priceB) / Math.max(priceA, priceB);
        if (priceDiff > 0.05) continue; // More than 5% apart

        // Check shared title words (Tier 2 check)
        const wordsA = significantWords(listings[idxA].title);
        const wordsB = significantWords(listings[idxB].title);
        const shared = wordsA.filter(w => wordsB.includes(w));

        if (shared.length >= 2) {
          // Tier 2: Probable dupe — merge
          const keepIdx = nonNullCount(listings[idxA]) >= nonNullCount(listings[idxB]) ? idxA : idxB;
          const dropIdx = keepIdx === idxA ? idxB : idxA;
          removed.add(dropIdx);
          if (!alsoListedOn[keepIdx]) alsoListedOn[keepIdx] = [];
          alsoListedOn[keepIdx].push({
            source: listings[dropIdx].source,
            url: listings[dropIdx].url,
          });
        } else {
          // Tier 3: Possible dupe — flag both, keep both
          possibleDupes.add(idxA);
          possibleDupes.add(idxB);
        }
      }
    }
  }

  // Attach metadata
  return listings.map((l, i) => ({
    ...l,
    _is_dupe: removed.has(i),
    also_listed_on: alsoListedOn[i] || [],
    possible_duplicate: possibleDupes.has(i),
  }));
}

/**
 * Apply hard filters with null-safe logic.
 *
 * Rule: null = pass with flag. Only fail on a known-bad value.
 * This matches the /find-deals skill's conservative approach.
 */
function applyHardFilters(listings, buyBox) {
  // Step 1: Deduplicate across sources
  const deduped = deduplicateListings(listings);

  // Step 2: Filter each listing
  return deduped.map(listing => {
    // If already marked as a dupe, fail it
    if (listing._is_dupe) {
      return {
        ...listing,
        passed_hard_filters: false,
        miss_reason: 'Duplicate listing (merged with cross-source match)',
        flags: [],
      };
    }

    const reasons = [];
    const flags = [];

    // Price checks — null = pass with flag
    if (listing.price == null) {
      flags.push('price_unknown');
    } else {
      if (buyBox.price_max && listing.price > Number(buyBox.price_max)) {
        reasons.push(`Price $${listing.price.toLocaleString()} exceeds max $${Number(buyBox.price_max).toLocaleString()}`);
      }
      if (buyBox.price_min && buyBox.price_min !== 'null' && listing.price < Number(buyBox.price_min)) {
        reasons.push(`Price $${listing.price.toLocaleString()} below min $${Number(buyBox.price_min).toLocaleString()}`);
      }
    }

    // Acreage check — null = pass with flag
    if (listing.acreage == null) {
      flags.push('acreage_unknown');
    } else {
      if (buyBox.acreage_min && buyBox.acreage_min !== 'null' && listing.acreage < Number(buyBox.acreage_min)) {
        reasons.push(`Acreage ${listing.acreage} below min ${buyBox.acreage_min}`);
      }
    }

    // Exclusion keywords (case-insensitive on title + description)
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
      flags,
    };
  });
}

module.exports = { applyHardFilters, deduplicateListings, normalizeAddress };
