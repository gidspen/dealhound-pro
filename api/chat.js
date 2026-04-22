const Anthropic = require('@anthropic-ai/sdk');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const SYSTEM_PROMPT = `You are an AI deal hunting agent. You scan 30+ marketplaces and private broker listings daily, assess and score every property, and surface only the deals that match an investor's exact strategy and buy box.

Your personality: High energy, excited to get to work, but sharp and knowledgeable. You're a deal analyst who genuinely loves finding great deals. Warm but direct — never fluffy or generic.

## ONBOARDING FLOW

**Step 1: Introduction + Open-Ended Dump**

Start with an energetic introduction, then ask ONE big open-ended question that encourages the user to share everything at once:

"Hey! I'm [YOUR NAME], your personal AI deal hunting agent. I'm going to scan marketplaces and private broker listings every day, score every property against YOUR specific criteria, and surface only the deals worth your time. The more I know about what you're looking for, the better I hunt.

So tell me everything — what's your ideal deal look like? Markets you love, property types, price range, your investment strategy, how many units or keys, what kind of returns you're targeting, what you absolutely don't want — dump it all on me. The more specific and nuanced you are, the sharper my searches will be."

**Step 2: Clarifying Questions for Searchable Filters**

After the user shares their criteria, ask focused clarifying questions about details that map to marketplace search filters. These make scanning dramatically faster:

- Price range (exact min/max) — if they said "under $2M", confirm: "So $0 to $2M, or is there a floor?"
- Specific locations — if they said "Southeast", narrow it: "Any specific states? Texas, Florida, Carolinas? Or truly the whole Southeast?"
- Property type specifics — if they said "hospitality", clarify: "Hotels, glamping, RV parks, B&Bs — which ones specifically?"
- Acreage minimums — if relevant to their asset class
- Revenue requirements — cash flow from day 1 vs. value-add vs. development plays
- Hard exclusions — things to never show

Ask these as a natural follow-up conversation, ONE question at a time. Only ask about things the user didn't already cover in their initial dump.

**Step 3: Confirm and Save**

After you have enough detail, confirm the buy box back in plain English:
"Here's what I'll hunt for: [detailed summary]. Ready to run your first scan?"

When the user confirms, call the save_buy_box tool with the structured data.

## RULES
- Start with the energetic intro + open-ended question
- Let the user rant — the more detail the better
- Only ask clarifying questions about things they didn't cover or that were too vague to search on
- Keep clarifying questions to 2-4 max — don't interrogate
- Be excited about their criteria — react to what they share ("Love it — Hill Country is a great market right now")
- But stay sharp — if something is too vague to search on, push for specifics
- Never say "Great question!" — instead react to the substance of what they shared`;

const TOOLS = [
  {
    name: 'save_buy_box',
    description: 'Save the user\'s buy box criteria after they confirm. Call this ONLY after the user explicitly confirms the buy box summary.',
    input_schema: {
      type: 'object',
      properties: {
        locations: {
          type: 'array',
          items: { type: 'string' },
          description: 'Target markets/locations (e.g., ["Texas", "Hill Country, TX", "Southeast US"])'
        },
        price_min: {
          type: 'number',
          description: 'Minimum price in dollars (null if no minimum)'
        },
        price_max: {
          type: 'number',
          description: 'Maximum price in dollars'
        },
        property_types: {
          type: 'array',
          items: { type: 'string' },
          description: 'Specific asset types the investor wants (e.g., ["micro_resort", "glamping", "boutique_hotel", "multifamily", "self_storage", "mobile_home_park", "laundromat", "car_wash", "retail_strip", "industrial", "land", "str_portfolio", "cash_flowing_business"])'
        },
        revenue_requirement: {
          type: 'string',
          enum: ['cash_flow_day_1', 'value_add_ok', 'development_ok', 'any'],
          description: 'Revenue requirement level'
        },
        acreage_min: {
          type: 'number',
          description: 'Minimum acreage (null or 0 if no minimum)'
        },
        exclusions: {
          type: 'array',
          items: { type: 'string' },
          description: 'Hard exclusions (things to never show)'
        }
      },
      required: ['locations', 'price_max', 'property_types', 'revenue_requirement']
    }
  }
];

async function buildDebriefPrompt(searchId, agentName) {
  const { data: deals } = await supabase
    .from('deals')
    .select('title, location, price, acreage, rooms_keys, score_breakdown, source, url, passed_hard_filters')
    .eq('search_id', searchId)
    .eq('passed_hard_filters', true)
    .order('id', { ascending: false });

  const { data: search } = await supabase
    .from('deal_searches')
    .select('buy_box')
    .eq('id', searchId)
    .single();

  const dealSummaries = (deals || []).map((d, i) => {
    const bd = typeof d.score_breakdown === 'string' ? JSON.parse(d.score_breakdown) : (d.score_breakdown || {});
    const tier = bd.strategy?.overall || 'UNKNOWN';
    const risk = bd.risk?.level || 'UNKNOWN';
    return `Deal ${i + 1}: ${d.title || 'Unnamed'}
  Location: ${d.location || '?'} | Price: ${d.price ? '$' + Number(d.price).toLocaleString() : '?'} | Acreage: ${d.acreage || '?'} | Keys: ${d.rooms_keys || '?'}
  Source: ${d.source || '?'} | Tier: ${tier} | Risk: ${risk}
  Listing: ${d.url || 'N/A'}
  Score: ${JSON.stringify(bd)}`;
  }).join('\n\n');

  const buyBox = search?.buy_box ? JSON.stringify(search.buy_box, null, 2) : 'Not available';

  return `You are ${agentName}, an AI deal hunting agent. You just finished scanning marketplaces and are debriefing the investor on what you found.

Your personality: Direct, knowledgeable, confident. You sound like a sharp deal analyst sitting across the table. Keep responses concise.

INVESTOR'S BUY BOX:
${buyBox}

DEALS FOUND (${(deals || []).length} survived the buy box filter):
${dealSummaries || 'No deals survived the filter.'}

Instructions:
- Present the deals with your honest assessment. Lead with the strongest match.
- For each deal, give a one-liner on why it made the cut and what the main risk is.
- End with a clear recommendation: which one to call about first and why.
- If the investor asks to compare deals, be specific — reference numbers, not generalities.
- If they ask to drill into a deal, give detailed analysis using the score breakdown.
- Be brief. No filler. No cheerleading. Sharp opinions backed by data.
${(deals || []).length === 0 ? '\nNo deals matched. Suggest adjusting the buy box — be specific about which criteria are too narrow.' : ''}`;
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

  const { email, messages, conversation_id, mode, search_id, agent_name } = req.body;

  if (!email || !messages || !Array.isArray(messages)) {
    return res.status(400).json({ error: 'Missing email or messages' });
  }

  try {
    const client = new Anthropic();

    // Stream the response
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    // Build system prompt based on mode
    const isDebrief = mode === 'scan_debrief';
    let systemPrompt = SYSTEM_PROMPT;
    let tools = TOOLS;

    if (isDebrief) {
      if (!search_id) {
        return res.status(400).json({ error: 'search_id required for scan_debrief mode' });
      }
      systemPrompt = await buildDebriefPrompt(search_id, agent_name || 'Scout');
      tools = undefined;
    } else if (agent_name) {
      systemPrompt = SYSTEM_PROMPT.replace(
        'You are Deal Hound, an AI deal hunting agent',
        `You are ${agent_name}, an AI deal hunting agent`
      );
    }

    const stream = await client.messages.stream({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      system: systemPrompt,
      ...(tools ? { tools } : {}),
      messages: messages.map(m => ({
        role: m.role,
        content: m.content
      }))
    });

    let fullText = '';
    let toolUse = null;

    for await (const event of stream) {
      if (event.type === 'content_block_delta') {
        if (event.delta.type === 'text_delta') {
          fullText += event.delta.text;
          res.write(`data: ${JSON.stringify({ type: 'text', text: event.delta.text })}\n\n`);
        } else if (event.delta.type === 'input_json_delta') {
          // Accumulate tool input JSON
          if (!toolUse) toolUse = { partial: '' };
          toolUse.partial += event.delta.partial_json;
        }
      } else if (event.type === 'content_block_start') {
        if (event.content_block.type === 'tool_use') {
          toolUse = {
            id: event.content_block.id,
            name: event.content_block.name,
            partial: ''
          };
        }
      } else if (event.type === 'content_block_stop' && toolUse && toolUse.name === 'save_buy_box') {
        // Tool call complete — save the buy box
        const buyBox = JSON.parse(toolUse.partial);

        // Create the deal_search record
        const { data: search, error: searchError } = await supabase
          .from('deal_searches')
          .insert({
            user_email: email,
            buy_box: buyBox,
            status: 'ready',
            run_at: new Date().toISOString()
          })
          .select('id')
          .single();

        if (searchError) {
          res.write(`data: ${JSON.stringify({ type: 'error', error: 'Failed to save buy box' })}\n\n`);
        } else {
          res.write(`data: ${JSON.stringify({
            type: 'buy_box_saved',
            search_id: search.id,
            buy_box: buyBox
          })}\n\n`);
        }

        toolUse = null;
      }
    }

    // Save conversation
    if (conversation_id) {
      await supabase
        .from('conversations')
        .update({
          messages: [...messages, { role: 'assistant', content: fullText, timestamp: new Date().toISOString() }],
          updated_at: new Date().toISOString()
        })
        .eq('id', conversation_id);
    } else {
      const { data: convo } = await supabase
        .from('conversations')
        .insert({
          user_email: email,
          conversation_type: isDebrief ? 'scan_debrief' : 'buy_box_intake',
          messages: [...messages, { role: 'assistant', content: fullText, timestamp: new Date().toISOString() }],
          ...(isDebrief && search_id ? { search_id } : {})
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
    console.error('Chat error:', err.message, err.status, JSON.stringify({ name: err.name, cause: err.cause, stack: err.stack?.slice(0, 300) }));
    if (!res.headersSent) {
      return res.status(500).json({ error: err.message || 'Internal server error' });
    }
    res.write(`data: ${JSON.stringify({ type: 'error', error: err.message })}\n\n`);
    res.end();
  }
};
