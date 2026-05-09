'use strict';

const Anthropic = require('@anthropic-ai/sdk');
const { readFileSync } = require('fs');
const { join } = require('path');

// Read the prompt template once at module load
const PROMPT_TEMPLATE = readFileSync(join(__dirname, 'sba-outreach.prompt.txt'), 'utf8');

const FALLBACK_OUTREACH = {
  subject: 'A conversation about your practice\'s future',
  body: 'I came across your practice and wanted to reach out with genuine respect for what you\'ve built over the years. Many owners at this stage in their career are beginning to think about transition planning and finding the right steward to carry their legacy forward — and that\'s exactly the kind of conversation I facilitate as a broker specializing in SBA-backed succession. If you\'re open to it, I\'d love a 15-minute call, no strings attached, just to understand where you are in your thinking.',
  angle: 'succession',
};

/**
 * Fill template variables in the prompt string.
 * @param {string} template
 * @param {Record<string, string>} vars
 * @returns {string}
 */
function fillTemplate(template, vars) {
  return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
    return vars[key] !== undefined ? String(vars[key]) : match;
  });
}

/**
 * Generate an SBA acquisition outreach email for a lead.
 *
 * @param {{
 *   business_name: string,
 *   owner_name: string,
 *   city: string,
 *   state: string,
 *   years_in_business: number,
 *   retirement_score: number,
 *   signals: string[],
 *   vertical: string
 * }} lead
 * @returns {Promise<{ subject: string, body: string, angle: string }>}
 */
async function generateOutreach(lead) {
  if (!process.env.ANTHROPIC_API_KEY) {
    console.warn('[sba-outreach] ANTHROPIC_API_KEY not set — returning static fallback');
    return FALLBACK_OUTREACH;
  }

  const vars = {
    business_name: lead.business_name || 'the practice',
    owner_name: lead.owner_name || 'there',
    city: lead.city || '',
    state: lead.state || '',
    years_in_business: lead.years_in_business != null ? lead.years_in_business : 'many',
    retirement_score: lead.retirement_score != null ? lead.retirement_score : '',
    top_signals: Array.isArray(lead.signals) ? lead.signals.join(', ') : (lead.signals || ''),
    vertical: lead.vertical || 'professional services',
  };

  const filledPrompt = fillTemplate(PROMPT_TEMPLATE, vars);

  const client = new Anthropic();

  let rawText;
  try {
    const message = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 300,
      messages: [
        {
          role: 'user',
          content: filledPrompt,
        },
      ],
    });

    rawText = message.content[0]?.text ?? '';
  } catch (err) {
    console.error('[sba-outreach] Anthropic API error:', err.message);
    return FALLBACK_OUTREACH;
  }

  // Strip any markdown code fences before parsing
  const cleaned = rawText.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '').trim();

  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch (parseErr) {
    console.error('[sba-outreach] JSON parse error. Raw response:', rawText);
    return FALLBACK_OUTREACH;
  }

  const validAngles = ['succession', 'legacy', 'transition'];
  return {
    subject: typeof parsed.subject === 'string' ? parsed.subject : FALLBACK_OUTREACH.subject,
    body: typeof parsed.body === 'string' ? parsed.body : FALLBACK_OUTREACH.body,
    angle: validAngles.includes(parsed.angle) ? parsed.angle : 'succession',
  };
}

module.exports = { generateOutreach };
