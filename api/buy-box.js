const { createClient } = require('@supabase/supabase-js')
const { TIER_ACTIVE_BOX_LIMITS } = require('./_lib/buy-box-limits')

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
)

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

  if (req.method === 'OPTIONS') {
    return res.status(200).end()
  }

  const { _action, id } = req.query
  const body = req.body || {}

  // POST /api/buy-box — create draft
  if (req.method === 'POST' && !_action && !id) {
    const { email, name, criteria } = body
    if (!email) return res.status(400).json({ error: 'Missing email' })
    if (!criteria) return res.status(400).json({ error: 'Missing criteria' })

    const { data, error } = await supabase
      .from('buy_boxes')
      .insert({
        user_email: email,
        name: name || 'Buy Box',
        criteria,
        status: 'draft',
        version: 1,
        criteria_updated_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json({ id: data.id, ...data })
  }

  // All remaining routes require an id
  if (!id) return res.status(400).json({ error: 'Missing id' })

  // PATCH /api/buy-box?id=... — update name and/or criteria
  if (req.method === 'PATCH') {
    const { email, name, criteria } = body
    if (!email) return res.status(400).json({ error: 'Missing email' })

    const { data: existing, error: fetchError } = await supabase
      .from('buy_boxes')
      .select('*')
      .eq('id', id)
      .eq('user_email', email)
      .single()

    if (fetchError || !existing) return res.status(404).json({ error: 'Buy box not found' })

    const updates = {}
    if (name !== undefined) updates.name = name

    if (criteria !== undefined) {
      const criteriaChanged =
        JSON.stringify(criteria) !== JSON.stringify(existing.criteria)
      updates.criteria = criteria
      if (criteriaChanged) {
        updates.version = existing.version + 1
        updates.criteria_updated_at = new Date().toISOString()
      }
    }

    const { data, error } = await supabase
      .from('buy_boxes')
      .update(updates)
      .eq('id', id)
      .eq('user_email', email)
      .select()
      .single()

    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json({ id: data.id, ...data })
  }

  // POST /api/buy-box?_action=activate&id=...
  if (req.method === 'POST' && _action === 'activate') {
    const { email } = body
    if (!email) return res.status(400).json({ error: 'Missing email' })

    const { data: buyBox, error: fetchError } = await supabase
      .from('buy_boxes')
      .select('*')
      .eq('id', id)
      .eq('user_email', email)
      .single()

    if (fetchError || !buyBox) return res.status(404).json({ error: 'Buy box not found' })

    // Get user's subscription tier
    const { data: user } = await supabase
      .from('users')
      .select('subscription_tier')
      .eq('email', email)
      .single()

    const tier = (user && user.subscription_tier) || 'founding'
    const limit = TIER_ACTIVE_BOX_LIMITS[tier] ?? TIER_ACTIVE_BOX_LIMITS.founding

    // Count current active boxes (excluding this one if already active)
    const { count } = await supabase
      .from('buy_boxes')
      .select('id', { count: 'exact', head: true })
      .eq('user_email', email)
      .eq('status', 'active')

    if (count >= limit) {
      return res.status(409).json({
        error: `You're using ${count} of ${limit} active monitors. Pause one or upgrade to add another.`,
        reason: 'active_box_limit',
        checkoutUrl: '/api/create-checkout',
      })
    }

    const { data, error } = await supabase
      .from('buy_boxes')
      .update({ status: 'active' })
      .eq('id', id)
      .eq('user_email', email)
      .select()
      .single()

    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json({ id: data.id, ...data })
  }

  // POST /api/buy-box?_action=pause&id=...
  if (req.method === 'POST' && _action === 'pause') {
    const { email } = body
    if (!email) return res.status(400).json({ error: 'Missing email' })

    const { data: existing, error: fetchError } = await supabase
      .from('buy_boxes')
      .select('id')
      .eq('id', id)
      .eq('user_email', email)
      .single()

    if (fetchError || !existing) return res.status(404).json({ error: 'Buy box not found' })

    const { data, error } = await supabase
      .from('buy_boxes')
      .update({ status: 'draft' })
      .eq('id', id)
      .eq('user_email', email)
      .select()
      .single()

    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json({ id: data.id, ...data })
  }

  // POST /api/buy-box?_action=archive&id=...
  if (req.method === 'POST' && _action === 'archive') {
    const { email } = body
    if (!email) return res.status(400).json({ error: 'Missing email' })

    const { data: existing, error: fetchError } = await supabase
      .from('buy_boxes')
      .select('id')
      .eq('id', id)
      .eq('user_email', email)
      .single()

    if (fetchError || !existing) return res.status(404).json({ error: 'Buy box not found' })

    const { data, error } = await supabase
      .from('buy_boxes')
      .update({ status: 'archived' })
      .eq('id', id)
      .eq('user_email', email)
      .select()
      .single()

    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json({ id: data.id, ...data })
  }

  return res.status(405).json({ error: 'Method not allowed' })
}
