const {
  recordComputeUsed,
  INPUT_COST_PER_TOKEN,
  OUTPUT_COST_PER_TOKEN,
} = require('../../worker/cost-guardrails');

function costFromUsage(usage) {
  if (!usage) return 0;
  const inputTokens = Number(usage.input_tokens) || 0;
  const outputTokens = Number(usage.output_tokens) || 0;
  return inputTokens * INPUT_COST_PER_TOKEN + outputTokens * OUTPUT_COST_PER_TOKEN;
}

async function recordChatComputeFromUsage({ email, usage, supabase, endpoint }) {
  try {
    if (!email || !usage || !supabase) return 0;
    const cost = costFromUsage(usage);
    if (cost <= 0) return 0;
    await recordComputeUsed(email, cost, supabase);
    return cost;
  } catch (err) {
    console.warn(
      `[chat-compute] Failed to record compute${endpoint ? ' (' + endpoint + ')' : ''} for ${email}: ${err.message}`
    );
    return 0;
  }
}

module.exports = { costFromUsage, recordChatComputeFromUsage };
