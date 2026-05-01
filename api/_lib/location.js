// Shared location matching logic used by user-data.js and chat.js

const STATE_ABBREVS = {
  'alabama':'al','alaska':'ak','arizona':'az','arkansas':'ar','california':'ca',
  'colorado':'co','connecticut':'ct','delaware':'de','florida':'fl','georgia':'ga',
  'hawaii':'hi','idaho':'id','illinois':'il','indiana':'in','iowa':'ia','kansas':'ks',
  'kentucky':'ky','louisiana':'la','maine':'me','maryland':'md','massachusetts':'ma',
  'michigan':'mi','minnesota':'mn','mississippi':'ms','missouri':'mo','montana':'mt',
  'nebraska':'ne','nevada':'nv','new hampshire':'nh','new jersey':'nj','new mexico':'nm',
  'new york':'ny','north carolina':'nc','north dakota':'nd','ohio':'oh','oklahoma':'ok',
  'oregon':'or','pennsylvania':'pa','rhode island':'ri','south carolina':'sc',
  'south dakota':'sd','tennessee':'tn','texas':'tx','utah':'ut','vermont':'vt',
  'virginia':'va','washington':'wa','west virginia':'wv','wisconsin':'wi','wyoming':'wy',
};

const STOP_WORDS = new Set(['in','of','the','and','within','near','from','hours','minutes','hour','minute']);

/**
 * Returns true if dealLocation matches any of the buyer's target locations.
 * @param {string} dealLocation  - e.g. "Austin, TX"
 * @param {string[]} locations   - buy box locations, e.g. ["texas", "austin", "nashville"]
 */
function dealMatchesLocations(dealLocation, locations) {
  if (!locations || locations.length === 0) return true;
  if (!dealLocation) return false;

  const dealLoc = dealLocation.toLowerCase();

  return locations.some(loc => {
    if (loc === 'us' || loc === 'usa' || loc === 'nationwide') return true;
    if (dealLoc.includes(loc)) return true;

    const abbrev = STATE_ABBREVS[loc];
    if (abbrev && dealLoc.includes(`, ${abbrev}`)) return true;

    // Word-level match for free-text entries like "2 hours from Nashville"
    const words = loc.replace(/[,]/g, ' ').split(/\s+/).filter(w => w.length >= 2 && !STOP_WORDS.has(w));
    return words.some(w => dealLoc.includes(w));
  });
}

/**
 * Filter a pool of deals against a buy box (price + location).
 * Returns only the deals that match.
 */
function filterDealsByBuyBox(deals, buyBox) {
  if (!buyBox) return deals;

  const priceMax = buyBox.price_max ?? null;
  const priceMin = buyBox.price_min ?? null;
  const locations = (buyBox.locations || []).map(l => l.toLowerCase());

  return deals.filter(d => {
    if (d.price && priceMax && Number(d.price) > priceMax) return false;
    if (d.price && priceMin && Number(d.price) < priceMin) return false;
    if (!dealMatchesLocations(d.location, locations)) return false;
    return true;
  });
}

module.exports = { dealMatchesLocations, filterDealsByBuyBox };
