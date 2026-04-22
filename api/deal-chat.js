const Anthropic = require('@anthropic-ai/sdk');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

function buildDealPrompt(deal, buyBox, agentName) {
  const bb = buyBox ? JSON.stringify(buyBox, null, 2) : 'Not provided';
  const bd = deal.score_breakdown
    ? (typeof deal.score_breakdown === 'string' ? deal.score_breakdown : JSON.stringify(deal.score_breakdown, null, 2))
    : 'Not available';

  return `You are ${agentName}, an AI deal hunting agent. You're helping an investor evaluate a specific hospitality deal.

Your personality: Direct, knowledgeable, confident. You sound like a sharp deal analyst, not a chatbot. Keep responses concise — 2-4 sentences unless more detail is explicitly requested.

DEAL CONTEXT:
Name: ${deal.title || 'Unknown'}
Location: ${deal.location || 'Unknown'}
Price: ${deal.price ? '$' + Number(deal.price).toLocaleString() : 'Unknown'}
Acreage: ${deal.acreage ? deal.acreage + ' acres' : 'Unknown'}
Keys/Rooms: ${deal.rooms_keys || 'Unknown'}
Source: ${deal.source || 'Unknown'}
Listing URL: ${deal.url || 'Not provided'}

SCORE BREAKDOWN:
${bd}

INVESTOR BUY BOX:
${bb}

Rules:
- Stay focused on this deal and this investor's criteria
- Reference specific numbers when answering
- If asked something you don't have data for, say so clearly
- No filler. No encouragement. Be a sharp analyst.
- When the user shares new information (broker call notes, financials), acknowledge and analyze it immediately`;
}

module.exports = async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  res.setHeader('Access-Control-Allow-Origin', '*');

  const { email, deal, buy_box, messages, conversation_id, agent_name } = req.body;

  if (!email || !deal || !messages || !Array.isArray(messages)) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const client = new Anthropic();

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const stream = await client.messages.stream({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      system: buildDealPrompt(deal, buy_box, agent_name || 'Scout'),
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
          conversation_type: 'deal_qa',
          messages: allMsgs,
          deal_id: deal.id || null
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
    console.error('deal-chat error:', err.message);
    if (!res.headersSent) {
      return res.status(500).json({ error: err.message || 'Internal server error' });
    }
    res.write(`data: ${JSON.stringify({ type: 'error', error: err.message })}\n\n`);
    res.end();
  }
};
