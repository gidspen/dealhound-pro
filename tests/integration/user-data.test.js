import { describe, it, expect, afterAll } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';
import { TEST_EMAIL, TEST_AGENT_NAME } from '../helpers/test-constants.js';

describe('User data operations', () => {
  const supabase = getTestSupabase();

  afterAll(async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);
  });

  it('creates a user with agent_name', async () => {
    await supabase.from('users').delete().eq('email', TEST_EMAIL);

    const { data, error } = await supabase
      .from('users')
      .insert({ email: TEST_EMAIL, agent_name: TEST_AGENT_NAME })
      .select('email, agent_name')
      .single();

    expect(error).toBeNull();
    expect(data.email).toBe(TEST_EMAIL);
    expect(data.agent_name).toBe(TEST_AGENT_NAME);
  });

  it('retrieves an existing user', async () => {
    const { data, error } = await supabase
      .from('users')
      .select('email, agent_name')
      .eq('email', TEST_EMAIL)
      .single();

    expect(error).toBeNull();
    expect(data.email).toBe(TEST_EMAIL);
    expect(data.agent_name).toBe(TEST_AGENT_NAME);
  });
});
