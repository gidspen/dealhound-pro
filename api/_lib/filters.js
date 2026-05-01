export function applyHardFilters(listings, buyBox) {
  const priceMax = Number(buyBox.price_max);
  const priceMin = Number(buyBox.price_min);
  const acreageMin = Number(buyBox.acreage_min);
  const exclusions = (buyBox.exclusions || []).map(e => e.toLowerCase());

  const results = listings.map(listing => ({
    ...listing,
    flags: [],
    passed_hard_filters: true,
  }));

  for (const r of results) {
    if (r.price === null || r.price === undefined) {
      r.flags.push('price_unknown');
    } else {
      if (r.price > priceMax) r.passed_hard_filters = false;
      if (r.price < priceMin) r.passed_hard_filters = false;
    }

    if (r.acreage === null || r.acreage === undefined) {
      r.flags.push('acreage_unknown');
    } else {
      if (r.acreage < acreageMin) r.passed_hard_filters = false;
    }

    const text = `${r.title || ''} ${r.description || ''}`.toLowerCase();
    for (const excl of exclusions) {
      if (text.includes(excl)) {
        r.passed_hard_filters = false;
        break;
      }
    }
  }

  // Dedup helpers
  function normalizeAddr(addr) {
    if (!addr) return '';
    return addr.toLowerCase()
      .replace(/\bdrive\b/g, 'dr').replace(/\bstreet\b/g, 'st')
      .replace(/\bavenue\b/g, 'ave').replace(/\broad\b/g, 'rd')
      .replace(/\bboulevard\b/g, 'blvd').replace(/\bcourt\b/g, 'ct')
      .replace(/\blane\b/g, 'ln').replace(/\bway\b/g, 'wy')
      .replace(/[^a-z0-9]/g, '');
  }

  function city(location) {
    return (location || '').split(',')[0].trim().toLowerCase();
  }

  function priceClose(a, b) {
    if (a == null || b == null) return false;
    return Math.abs(a - b) / Math.max(a, b) <= 0.03;
  }

  function titleSim(a, b) {
    const words = s => new Set(s.toLowerCase().split(/\s+/).filter(w => w.length > 2));
    const wa = words(a), wb = words(b);
    const inter = [...wa].filter(w => wb.has(w)).length;
    const union = new Set([...wa, ...wb]).size;
    return union > 0 ? inter / union : 0;
  }

  function countNonNull(obj) {
    return Object.values(obj).filter(v => v !== null && v !== undefined).length;
  }

  const passedIdxs = results.map((r, i) => r.passed_hard_filters ? i : -1).filter(i => i >= 0);
  const dropped = new Set();

  for (let pi = 0; pi < passedIdxs.length; pi++) {
    const i = passedIdxs[pi];
    if (dropped.has(i)) continue;
    const a = results[i];

    for (let pj = pi + 1; pj < passedIdxs.length; pj++) {
      const j = passedIdxs[pj];
      if (dropped.has(j)) continue;
      const b = results[j];

      const cityA = city(a.location), cityB = city(b.location);
      const addrA = normalizeAddr(a.address), addrB = normalizeAddr(b.address);

      let tier = 0;

      if (addrA && addrB && addrA === addrB && cityA === cityB) {
        tier = 1;
      } else if (priceClose(a.price, b.price) && cityA === cityB) {
        tier = titleSim(a.title || '', b.title || '') >= 0.5 ? 2 : 3;
      }

      if (tier === 1 || tier === 2) {
        const keepA = countNonNull(a) >= countNonNull(b);
        const kept = keepA ? i : j;
        const drop = keepA ? j : i;
        dropped.add(drop);
        if (!results[kept].also_listed_on) results[kept].also_listed_on = [];
        results[kept].also_listed_on.push(results[drop].source);
      } else if (tier === 3) {
        a.possible_duplicate = true;
        b.possible_duplicate = true;
      }
    }
  }

  return results.filter((_, i) => !dropped.has(i));
}
