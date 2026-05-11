import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createClient } from '@supabase/supabase-js';
import {
  costFromUsage,
  recordChatComputeFromUsage,
} from '../../api/_lib/chat-compute.js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
const missingEnv = !SUPABASE_URL || !SUPABASE_SERVICE_KEY;

describe.skipIf(missingEnv)('chat-compute helper', () => {
  let supabase;
  const ts = Date.now();
  const emails = {
    writeOnce: `test-chat-compute-${ts}-1@dealhound.dev`,
    writeTwice: `test-chat-compute-${ts}-2@dealhound.dev`,
    noUsage: `test-chat-compute-${ts}-3@dealhound.dev`,
  };

  beforeAll(async () => {
    supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const { error } = await supabase.from('users').insert([
      { email: emails.writeOnce, agent_name: 'Scout', monthly_compute_used: 0 },
      { email: emails.writeTwice, agent_name: 'Scout', monthly_compute_used: 0 },
      { email: emails.noUsage, agent_name: 'Scout', monthly_compute_used: 0 },
    ]);
    if (error) throw new Error(`beforeAll insert failed: ${error.message}`);
  });

  afterAll(async () => {
    const { error } = await supabase
      .from('users')
      .delete()
      .in('email', Object.values(emails));
    if (error) console.error('afterAll cleanup failed:', error.message);
  });

  it('costFromUsage: 1000 input + 500 output tokens = $0.0105', () => {
    expect(costFromUsage({ input_tokens: 1000, output_tokens: 500 })).toBeCloseTo(
      0.0105,
      6
    );
  });

  it('costFromUsage: missing/null usage returns 0', () => {
    expect(costFromUsage(null)).toBe(0);
    expect(costFromUsage(undefined)).toBe(0);
    expect(costFromUsage({})).toBe(0);
  });

  it('recordChatComputeFromUsage writes monthly_compute_used to Supabase', async () => {
    const cost = await recordChatComputeFromUsage({
      email: emails.writeOnce,
      usage: { input_tokens: 1000, output_tokens: 500 },
      supabase,
      endpoint: 'test',
    });
    expect(cost).toBeCloseTo(0.0105, 6);

    const { data } = await supabase
      .from('users')
      .select('monthly_compute_used')
      .eq('email', emails.writeOnce)
      .single();
    expect(parseFloat(data.monthly_compute_used)).toBeCloseTo(0.0105, 6);
  });

  it('recordChatComputeFromUsage accumulates across multiple calls', async () => {
    await recordChatComputeFromUsage({
      email: emails.writeTwice,
      usage: { input_tokens: 1000, output_tokens: 500 },
      supabase,
      endpoint: 'test',
    });
    await recordChatComputeFromUsage({
      email: emails.writeTwice,
      usage: { input_tokens: 2000, output_tokens: 1000 },
      supabase,
      endpoint: 'test',
    });

    const { data } = await supabase
      .from('users')
      .select('monthly_compute_used')
      .eq('email', emails.writeTwice)
      .single();
    // 0.0105 + 0.021 = 0.0315
    expect(parseFloat(data.monthly_compute_used)).toBeCloseTo(0.0315, 6);
  });

  it('recordChatComputeFromUsage is a no-op when usage is missing', async () => {
    const cost = await recordChatComputeFromUsage({
      email: emails.noUsage,
      usage: null,
      supabase,
      endpoint: 'test',
    });
    expect(cost).toBe(0);

    const { data } = await supabase
      .from('users')
      .select('monthly_compute_used')
      .eq('email', emails.noUsage)
      .single();
    expect(parseFloat(data.monthly_compute_used)).toBe(0);
  });

  it('recordChatComputeFromUsage swallows DB errors (non-fatal)', async () => {
    const cost = await recordChatComputeFromUsage({
      email: 'nonexistent-user-that-cannot-exist@dealhound.dev',
      usage: { input_tokens: 1000, output_tokens: 500 },
      supabase,
      endpoint: 'test',
    });
    // The user doesn't exist, but the helper must NOT throw. recordComputeUsed itself
    // is non-fatal — we just confirm no exception propagates.
    expect(typeof cost).toBe('number');
  });
});
