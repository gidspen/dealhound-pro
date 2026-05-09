// api/sba-deal-chat.js
const Anthropic = require('@anthropic-ai/sdk');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

function buildSbaLeadPrompt(lead) {
  const signals = Array.isArray(lead.signals) ? lead.signals : [];
  const firedSignals = signals.filter(s => s.fired);
  const signalSummary = firedSignals.map(s => `- ${s.key} (weight: ${s.weight}): ${s.evidence}`).join('\n');

  return `You are an SBA acquisition analyst helping a buyer evaluate a dental practice acquisition target.

PRACTICE CONTEXT:
Business: ${lead.business_name || 'Unknown'}
Owner: ${lead.owner_name || 'Unknown'}
Location: ${lead.city || ''}, ${lead.state || 'TX'}
Years in business: ${lead.years_in_business || 'Unknown'}
License year: ${lead.license_year || 'Unknown'}
Retirement Score: ${lead.retirement_score}/100 (${lead.retirement_tier})

FIRED SIGNALS (${firedSignals.length} of 13):
${signalSummary || 'None'}

OUTREACH DRAFT:
Subject: ${lead.outreach_subject || 'Not generated'}
Body: ${lead.outreach_body || 'Not generated'}

Rules:
- You are a sharp SBA acquisition analyst, not a chatbot
- Reference specific signals and scores when answering
- Frame everything around succession planning and practice transition (never "selling" or "exit")
- Keep responses concise — 2-4 sentences unless more detail requested
- If asked about signals you don't have data for (e.g., LinkedIn signals), explain they're pending integration
- When asked "Why HOT/STRONG/WATCH?", walk through the fired signals and their weights`;
}

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
  res.setHeader('Access-Control-Allow-Origin', '*');

  const { email, lead, messages, conversation_id } = req.body;
  if (!email || !lead || !messages || !Array.isArray(messages)) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const client = new Anthropic();

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const stream = await client.messages.stream({
      model: 'claude-sonnet-4-6',
      max_tokens: 1024,
      system: buildSbaLeadPrompt(lead),
      messages: messages.map(m => ({ role: m.role, content: m.content }))
    });

    let fullText = '';

    for await (const event of stream) {
      if (event.type === 'content_block_delta' && event.delta.type === 'text_delta') {
        fullText += event.delta.text;
        res.write(`data: ${JSON.stringify({ type: 'text', text: event.delta.text })}\n\n`);
      }
    }

    // Save conversation
    const allMsgs = [...messages, { role: 'assistant', content: fullText, timestamp: new Date().toISOString() }];

    if (conversation_id) {
      await supabase
        .from('conversations')
        .update({ messages: allMsgs, updated_at: new Date().toISOString() })
        .eq('id', conversation_id);
    } else {
      const { data: convo } = await supabase
        .from('conversations')
        .insert({
          user_email: email,
          conversation_type: 'sba_lead_qa',
          messages: allMsgs,
          deal_id: lead.id || null
        })
        .select('id')
        .single();

      if (convo) {
        res.write(`data: ${JSON.stringify({ type: 'conversation_id', id: convo.id })}\n\n`);
      }
    }

    res.write(`data: ${JSON.stringify({ type: 'done' })}\n\n`);
    res.end();

  } catch (err) {
    console.error('sba-deal-chat error:', err.message);
    if (!res.headersSent) {
      return res.status(500).json({ error: err.message || 'Internal server error' });
    }
    res.write(`data: ${JSON.stringify({ type: 'error', error: err.message })}\n\n`);
    res.end();
  }
};
