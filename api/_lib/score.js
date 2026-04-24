// api/lib/score.js
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic();

/**
 * Phase 3: Score deals using the /find-deals skill's tiered rubric.
 *
 * Stage A — Sonnet: classify strategy match + rate risk factors
 * Gate: drop MISS deals
 * Stage B — Opus: write mitigations for high-risk factors (3+)
 * Stage C — Code: compute priority score (0-100)
 *
 * Reference: ~/.claude/skills/find-deals/scoring-rubric.md
 */

// ── Stage A: Sonnet classification ──────────────────────────────────

async function classifyWithSonnet(deals, buyBox) {
  const results = [];
  const batchSize = 10; // conservative for reliability

  for (let i = 0; i < deals.length; i += batchSize) {
    const batch = deals.slice(i, i + batchSize);

    const prompt = `You are a real estate investment analyst. Classify these ${batch.length} properties against the investor's buy box.

BUY BOX:
- Locations: ${(buyBox.locations || []).join(', ')}
- Price: ${buyBox.price_min && buyBox.price_min !== 'null' ? '$' + Number(buyBox.price_min).toLocaleString() : 'No min'} – $${Number(buyBox.price_max).toLocaleString()}
- Property types: ${(buyBox.property_types || []).join(', ').replace(/_/g, ' ')}
- Revenue requirement: ${(buyBox.revenue_requirement || 'any').replace(/_/g, ' ')}

PROPERTIES:
${batch.map((d, idx) => `[${idx + 1}] ${d.title}
  Location: ${d.location} | Price: ${d.price ? '$' + d.price.toLocaleString() : 'unknown'}
  Acreage: ${d.acreage || 'unknown'} | Source: ${d.source}
  Description: ${(d.description || d.raw_description || '').substring(0, 200)}`).join('\n\n')}

For each property return a JSON array. Each element:
{
  "index": 1,
  "strategy": {
    "market_match": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "revenue_match": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "property_fit": "STRONG MATCH | MATCH | PARTIAL | MISS",
    "unit_economics": "$Xk/key or $Xk/acre or unknown",
    "seller_motivation": "HIGH | MODERATE | LOW | UNKNOWN",
    "overall": "worst of market/revenue/property_fit"
  },
  "risk": {
    "capital_risk": 0-5,
    "market_risk": 0-5,
    "revenue_risk": 0-5,
    "execution_risk": 0-5,
    "information_risk": 0-5
  },
  "brief": "2-3 sentence analysis"
}

IMPORTANT: When uncertain between PARTIAL and MISS, default to PARTIAL. Only use MISS when a deal clearly fails.

Return ONLY the JSON array.`;

    try {
      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 3000,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response.content[0]?.text || '[]';
      const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const scores = JSON.parse(jsonStr);

      for (const score of scores) {
        const deal = batch[score.index - 1];
        if (!deal) continue;
        results.push({ ...deal, ...score, _original_index: i + score.index - 1 });
      }
    } catch (e) {
      console.error('Sonnet scoring failed:', e.message);
      // Fallback: include deals with default scores
      for (const deal of batch) {
        results.push({
          ...deal,
          strategy: {
            market_match: 'PARTIAL', revenue_match: 'PARTIAL', property_fit: 'PARTIAL',
            unit_economics: 'unknown', seller_motivation: 'UNKNOWN', overall: 'PARTIAL',
          },
          risk: { capital_risk: 3, market_risk: 3, revenue_risk: 3, execution_risk: 3, information_risk: 5 },
          brief: 'Scoring unavailable — review manually.',
        });
      }
    }
  }

  return results;
}

// ── Gate: filter MISS deals ─────────────────────────────────────────

function gateMissDeals(scoredDeals) {
  const survivors = [];
  const missed = [];

  for (const deal of scoredDeals) {
    if (deal.strategy?.overall === 'MISS') {
      missed.push({ ...deal, passed_hard_filters: false, miss_reason: 'strategy_miss' });
    } else {
      survivors.push(deal);
    }
  }

  return { survivors, missed };
}

// ── Stage B: Opus mitigations ───────────────────────────────────────

async function writeMitigations(deals, buyBox) {
  // Only send deals with risk factors rated 3+
  const needsMitigation = deals.filter(d => {
    const r = d.risk || {};
    return Object.values(r).some(v => typeof v === 'number' && v >= 3);
  });

  if (needsMitigation.length === 0) return deals;

  const batchSize = 5;

  for (let i = 0; i < needsMitigation.length; i += batchSize) {
    const batch = needsMitigation.slice(i, i + batchSize);

    const prompt = `You are an experienced hospitality real estate investor. For each property below, write specific mitigation prescriptions for risk factors rated 3 or higher. Not generic advice — specific to what the listing data tells you.

${batch.map((d, idx) => `[${idx + 1}] ${d.title} | ${d.location} | ${d.price ? '$' + d.price.toLocaleString() : 'unknown'}
  Risk: Capital=${d.risk.capital_risk} Market=${d.risk.market_risk} Revenue=${d.risk.revenue_risk} Execution=${d.risk.execution_risk} Info=${d.risk.information_risk}
  Description: ${(d.description || d.raw_description || d.brief || '').substring(0, 200)}`).join('\n\n')}

Return a JSON array. Each element:
{"index": 1, "mitigations": ["Capital risk (4): specific advice...", "Info risk (3): specific advice..."]}

Only include mitigations for factors rated 3+. Return ONLY the JSON array.`;

    try {
      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response.content[0]?.text || '[]';
      const jsonStr = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const mitigations = JSON.parse(jsonStr);

      for (const m of mitigations) {
        const deal = batch[m.index - 1];
        if (deal) deal.mitigations = m.mitigations;
      }
    } catch (e) {
      console.error('Mitigation writing failed:', e.message);
    }
  }

  return deals;
}

// ── Stage C: Priority score arithmetic ──────────────────────────────

function computePriorityScore(deal, buyBox) {
  const strategy = deal.strategy || {};
  const risk = deal.risk || {};

  // Type alignment (30 pts)
  const primaryTypes = (buyBox.property_types || []).slice(0, 1);
  const secondaryTypes = (buyBox.property_types || []).slice(1, 3);
  const dealType = (deal.property_type || '').toLowerCase().replace(/_/g, ' ');
  let typeScore = 10; // tertiary default
  if (primaryTypes.some(t => dealType.includes(t.replace(/_/g, ' ')))) typeScore = 30;
  else if (secondaryTypes.some(t => dealType.includes(t.replace(/_/g, ' ')))) typeScore = 20;

  // Revenue readiness (25 pts)
  const revenueMap = { 'STRONG MATCH': 25, 'MATCH': 22, 'PARTIAL': 12, 'MISS': 5 };
  const revenueScore = revenueMap[strategy.revenue_match] || 12;

  // Market fit (25 pts)
  const marketMap = { 'STRONG MATCH': 25, 'MATCH': 18, 'PARTIAL': 8, 'MISS': 0 };
  const marketScore = marketMap[strategy.market_match] || 8;

  // Risk offset (20 pts)
  const totalRisk = (risk.capital_risk || 0) + (risk.market_risk || 0) +
    (risk.revenue_risk || 0) + (risk.execution_risk || 0) + (risk.information_risk || 0);
  const riskOffset = Math.max(0, 20 - totalRisk);

  const total = typeScore + revenueScore + marketScore + riskOffset;

  // Risk level label
  const riskLevel = totalRisk <= 5 ? 'LOW' : totalRisk <= 12 ? 'MODERATE' :
    totalRisk <= 18 ? 'HIGH' : 'VERY HIGH';

  return {
    score: total,
    breakdown: { type_alignment: typeScore, revenue_readiness: revenueScore, market_fit: marketScore, risk_offset: riskOffset },
    total_risk: totalRisk,
    risk_level: riskLevel,
  };
}

// ── Main scoring pipeline ───────────────────────────────────────────

async function scoreDeals(survivors, buyBox) {
  if (survivors.length === 0) return { scored: [], missed: [] };

  // Stage A: Sonnet classify + rate
  const classified = await classifyWithSonnet(survivors, buyBox);

  // Gate: drop MISS deals
  const { survivors: passed, missed } = gateMissDeals(classified);

  // Stage B: Opus mitigations for high-risk factors
  const withMitigations = await writeMitigations(passed, buyBox);

  // Stage C: Priority score arithmetic
  const scored = withMitigations.map(deal => {
    const priority = computePriorityScore(deal, buyBox);
    return {
      ...deal,
      priority_score: priority.score,
      score_breakdown: {
        strategy: deal.strategy,
        risk: {
          ...deal.risk,
          total_risk: priority.total_risk,
          risk_level: priority.risk_level,
          mitigations: deal.mitigations || [],
        },
        priority: priority.breakdown,
      },
    };
  });

  // Sort by priority score descending
  scored.sort((a, b) => (b.priority_score || 0) - (a.priority_score || 0));

  return { scored, missed };
}

module.exports = { scoreDeals };
