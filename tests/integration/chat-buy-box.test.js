// tests/integration/chat-buy-box.test.js
//
// Tests the saveBuyBox helper extracted from the chat.js save_buy_box handler.
// Uses approach (a): imports the extracted function directly, bypassing the
// Anthropic streaming machinery entirely.
//
// Coverage:
//   A. First save creates active buy_box + deal_searches row stamped with id+version
//   B. Second save with SAME criteria does NOT bump version
//   C. Save with CHANGED criteria bumps version on the SAME buy_box row

import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createRequire } from 'module';
import { getTestSupabase } from '../helpers/supabase.js';

const require = createRequire(import.meta.url);
const { saveBuyBox } = require('../../api/_lib/save-buy-box.js');

const supabase = getTestSupabase();

const ts = Date.now();
const EMAIL = `test-ci+chat-buybox-${ts}@dealhound.dev`;

const CRITERIA_A = {
  markets: ['Austin TX'],
  price_max: 1000000,
  property_types: ['boutique_hotel'],
};

const CRITERIA_B = {
  markets: ['Denver CO'],
  price_max: 2000000,
  property_types: ['micro_resort'],
};

async function insertDealSearch(email, buyBoxId, buyBoxVersion, criteria) {
  const { data, error } = await supabase
    .from('deal_searches')
    .insert({
      user_email: email,
      buy_box: criteria,
      status: 'ready',
      run_at: new Date().toISOString(),
      test_data: true,
      ...(buyBoxId ? { buy_box_id: buyBoxId, buy_box_version: buyBoxVersion } : {}),
    })
    .select('id, buy_box_id, buy_box_version')
    .single();
  if (error) throw new Error('insertDealSearch failed: ' + error.message);
  return data;
}

beforeAll(async () => {
  // Ensure users row exists (buy_boxes.user_email is FK'd to users.email)
  await supabase
    .from('users')
    .upsert(
      { email: EMAIL, subscription_tier: 'founding', agent_runs_used: 0, agent_name: 'Scout' },
      { onConflict: 'email' }
    );
});

afterAll(async () => {
  // Clean up in dependency order
  const { data: searches } = await supabase
    .from('deal_searches')
    .select('id')
    .eq('user_email', EMAIL)
    .eq('test_data', true);
  const ids = (searches || []).map((s) => s.id);
  if (ids.length) {
    await supabase.from('deals').delete().in('search_id', ids);
    await supabase.from('deal_searches').delete().in('id', ids);
  }
  await supabase.from('buy_boxes').delete().eq('user_email', EMAIL);
  await supabase.from('users').delete().eq('email', EMAIL);
});

describe('chat → buy box wiring (saveBuyBox helper)', () => {
  let firstBuyBoxId;

  it('Test A: first save creates active buy_box; deal_searches stamped with id+version', async () => {
    const { buyBoxId, buyBoxVersion } = await saveBuyBox(EMAIL, CRITERIA_A, supabase);

    expect(buyBoxId).toBeDefined();
    expect(buyBoxVersion).toBe(1);
    firstBuyBoxId = buyBoxId;

    // Verify the buy_boxes row
    const { data: box } = await supabase
      .from('buy_boxes')
      .select('status, version, criteria')
      .eq('id', buyBoxId)
      .single();

    expect(box.status).toBe('active');
    expect(box.version).toBe(1);
    expect(box.criteria).toEqual(CRITERIA_A);

    // Simulate what chat.js does: insert deal_searches with buy_box_id+version
    const search = await insertDealSearch(EMAIL, buyBoxId, buyBoxVersion, CRITERIA_A);
    expect(search.buy_box_id).toBe(buyBoxId);
    expect(search.buy_box_version).toBe(1);
  });

  it('Test B: second save with SAME criteria does NOT bump version', async () => {
    const { buyBoxId, buyBoxVersion } = await saveBuyBox(EMAIL, CRITERIA_A, supabase);

    // Must be the SAME row, same version
    expect(buyBoxId).toBe(firstBuyBoxId);
    expect(buyBoxVersion).toBe(1);

    const { data: box } = await supabase
      .from('buy_boxes')
      .select('version')
      .eq('id', buyBoxId)
      .single();
    expect(box.version).toBe(1);
  });

  it('Test C: save with changed criteria bumps version on same buy_box row', async () => {
    const { buyBoxId, buyBoxVersion } = await saveBuyBox(EMAIL, CRITERIA_B, supabase);

    // Same row ID, version incremented
    expect(buyBoxId).toBe(firstBuyBoxId);
    expect(buyBoxVersion).toBe(2);

    const { data: box } = await supabase
      .from('buy_boxes')
      .select('version, criteria')
      .eq('id', buyBoxId)
      .single();
    expect(box.version).toBe(2);
    expect(box.criteria).toEqual(CRITERIA_B);

    // deal_searches stamped with new version
    const search = await insertDealSearch(EMAIL, buyBoxId, buyBoxVersion, CRITERIA_B);
    expect(search.buy_box_id).toBe(buyBoxId);
    expect(search.buy_box_version).toBe(2);
  });
});
