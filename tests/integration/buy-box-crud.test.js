import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import handler from '../../api/buy-box.js'
import listHandler from '../../api/buy-boxes.js'
import { getTestSupabase } from '../helpers/supabase.js'
import { TEST_EMAIL } from '../helpers/test-constants.js'

function makeRes() {
  const res = {
    statusCode: 200,
    body: null,
    status(code) {
      this.statusCode = code
      return this
    },
    json(b) {
      this.body = b
      return this
    },
    send(b) {
      this.body = b
      return this
    },
    setHeader() {
      return this
    },
    end() {
      return this
    },
  }
  return res
}

async function call(h, { method, query = {}, body = {} }) {
  const req = { method, query, body, headers: {} }
  const res = makeRes()
  await h(req, res)
  return res
}

const ts = Date.now()
const TEST_EMAIL_A = `${TEST_EMAIL.replace('@', `-buybox-a-${ts}@`)}`
const TEST_EMAIL_B = `${TEST_EMAIL.replace('@', `-buybox-b-${ts}@`)}`

const supabase = getTestSupabase()

const CRITERIA_V1 = { markets: ['Austin TX'], price_max: 1000000, property_types: ['boutique_hotel'] }
const CRITERIA_V2 = { markets: ['Denver CO'], price_max: 2000000, property_types: ['micro_resort'] }

describe('buy-box CRUD', () => {
  beforeAll(async () => {
    // Clean up any leftover test data
    await supabase.from('buy_boxes').delete().eq('user_email', TEST_EMAIL_A)
    await supabase.from('buy_boxes').delete().eq('user_email', TEST_EMAIL_B)
    await supabase.from('users').delete().eq('email', TEST_EMAIL_A)
    await supabase.from('users').delete().eq('email', TEST_EMAIL_B)

    // Ensure users rows exist with founding tier
    await supabase.from('users').upsert([
      { email: TEST_EMAIL_A, subscription_tier: 'founding', agent_runs_used: 0, agent_name: 'Scout' },
      { email: TEST_EMAIL_B, subscription_tier: 'founding', agent_runs_used: 0, agent_name: 'Scout' },
    ])
  })

  afterAll(async () => {
    await supabase.from('buy_boxes').delete().eq('user_email', TEST_EMAIL_A)
    await supabase.from('buy_boxes').delete().eq('user_email', TEST_EMAIL_B)
    await supabase.from('users').delete().eq('email', TEST_EMAIL_A)
    await supabase.from('users').delete().eq('email', TEST_EMAIL_B)
  })

  it('POST /api/buy-box creates a draft buy box', async () => {
    const res = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'Test Box', criteria: CRITERIA_V1 },
    })

    expect(res.statusCode).toBe(200)
    expect(res.body.id).toBeDefined()
    expect(res.body.status).toBe('draft')
    expect(res.body.version).toBe(1)
    expect(res.body.criteria_updated_at).toBeTruthy()
  })

  it('PATCH /api/buy-box/:id updates criteria and bumps version', async () => {
    // Create box first
    const create = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'Version Test', criteria: CRITERIA_V1 },
    })
    const id = create.body.id

    const res = await call(handler, {
      method: 'PATCH',
      query: { id },
      body: { email: TEST_EMAIL_A, criteria: CRITERIA_V2 },
    })

    expect(res.statusCode).toBe(200)
    expect(res.body.version).toBe(2)
    expect(res.body.criteria).toEqual(CRITERIA_V2)
  })

  it('PATCH /api/buy-box/:id renames without bumping version', async () => {
    const create = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'Original Name', criteria: CRITERIA_V1 },
    })
    const id = create.body.id

    const res = await call(handler, {
      method: 'PATCH',
      query: { id },
      body: { email: TEST_EMAIL_A, name: 'Renamed Box' },
    })

    expect(res.statusCode).toBe(200)
    expect(res.body.version).toBe(1)
    expect(res.body.name).toBe('Renamed Box')
  })

  it('POST /api/buy-box/:id/activate succeeds when under limit', async () => {
    const create = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'Activate Me', criteria: CRITERIA_V1 },
    })
    const id = create.body.id

    const res = await call(handler, {
      method: 'POST',
      query: { _action: 'activate', id },
      body: { email: TEST_EMAIL_A },
    })

    expect(res.statusCode).toBe(200)
    expect(res.body.status).toBe('active')
  })

  it('POST /api/buy-box/:id/activate returns 409 when at limit with upgrade CTA', async () => {
    // Pre-create 3 active boxes via raw supabase insert
    await supabase.from('buy_boxes').insert([
      { user_email: TEST_EMAIL_B, name: 'Active 1', criteria: CRITERIA_V1, status: 'active' },
      { user_email: TEST_EMAIL_B, name: 'Active 2', criteria: CRITERIA_V1, status: 'active' },
      { user_email: TEST_EMAIL_B, name: 'Active 3', criteria: CRITERIA_V1, status: 'active' },
    ])

    // Create a 4th as draft
    const create = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_B, name: 'Draft 4', criteria: CRITERIA_V2 },
    })
    const id = create.body.id

    const res = await call(handler, {
      method: 'POST',
      query: { _action: 'activate', id },
      body: { email: TEST_EMAIL_B },
    })

    expect(res.statusCode).toBe(409)
    expect(res.body.reason).toBe('active_box_limit')
    expect(res.body.checkoutUrl).toBe('/api/create-checkout')
    expect(res.body.error).toMatch(/active monitors/)
  })

  it('POST /api/buy-box/:id/pause flips to draft', async () => {
    const create = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'Pause Me', criteria: CRITERIA_V1 },
    })
    const id = create.body.id

    // Activate first
    await call(handler, {
      method: 'POST',
      query: { _action: 'activate', id },
      body: { email: TEST_EMAIL_A },
    })

    const res = await call(handler, {
      method: 'POST',
      query: { _action: 'pause', id },
      body: { email: TEST_EMAIL_A },
    })

    expect(res.statusCode).toBe(200)
    expect(res.body.status).toBe('draft')
  })

  it('POST /api/buy-box/:id/archive flips to archived', async () => {
    const create = await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'Archive Me', criteria: CRITERIA_V1 },
    })
    const id = create.body.id

    const res = await call(handler, {
      method: 'POST',
      query: { _action: 'archive', id },
      body: { email: TEST_EMAIL_A },
    })

    expect(res.statusCode).toBe(200)
    expect(res.body.status).toBe('archived')
  })

  it('GET /api/buy-boxes lists for authenticated user only', async () => {
    // Create boxes for both emails
    await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_A, name: 'A Box', criteria: CRITERIA_V1 },
    })
    await call(handler, {
      method: 'POST',
      query: {},
      body: { email: TEST_EMAIL_B, name: 'B Box', criteria: CRITERIA_V2 },
    })

    const resA = await call(listHandler, {
      method: 'GET',
      query: { email: TEST_EMAIL_A },
      body: {},
    })

    expect(resA.statusCode).toBe(200)
    expect(Array.isArray(resA.body.buy_boxes)).toBe(true)
    // All returned rows should belong to TEST_EMAIL_A
    for (const box of resA.body.buy_boxes) {
      expect(box.user_email).toBe(TEST_EMAIL_A)
    }

    const resB = await call(listHandler, {
      method: 'GET',
      query: { email: TEST_EMAIL_B },
      body: {},
    })
    expect(resB.statusCode).toBe(200)
    for (const box of resB.body.buy_boxes) {
      expect(box.user_email).toBe(TEST_EMAIL_B)
    }
  })
})
