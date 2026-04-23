import { describe, it, expect } from 'vitest';
import { getTestSupabase } from '../helpers/supabase.js';

describe('Health check (Supabase connectivity)', () => {
  it('can query the users table', async () => {
    const supabase = getTestSupabase();
    const { data, error } = await supabase.from('users').select('email').limit(1);
    expect(error).toBeNull();
    expect(data).toBeDefined();
  });

  it('can query the deal_searches table', async () => {
    const supabase = getTestSupabase();
    const { data, error } = await supabase.from('deal_searches').select('id').limit(1);
    expect(error).toBeNull();
    expect(data).toBeDefined();
  });
});
