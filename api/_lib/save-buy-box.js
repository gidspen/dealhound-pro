// api/_lib/save-buy-box.js
//
// Core buy-box persistence logic used by chat.js save_buy_box handler.
// Exported as a standalone function so it can be unit-tested without
// the Anthropic streaming machinery in chat.js.
//
// Behaviour:
//   - If user has an active buy_box: compare criteria via JSON.stringify.
//     - Criteria changed → UPDATE (bump version, update criteria_updated_at).
//     - Only name differs or nothing differs → no version bump.
//   - If user has no active buy_box: INSERT status='active', version=1.
//   - Returns { buyBoxId, buyBoxVersion } for stamping onto deal_searches.

const { deriveBuyBoxName } = require('./buy-box-name');

/**
 * Upsert the user's active buy box.
 *
 * @param {string} email
 * @param {object} criteria  — raw criteria object from the AI tool call
 * @param {object} supabase  — supabase client
 * @returns {{ buyBoxId: string, buyBoxVersion: number }}
 */
async function saveBuyBox(email, criteria, supabase) {
  if (!email) throw new Error('saveBuyBox: email is required');
  if (!criteria) throw new Error('saveBuyBox: criteria is required');
  if (!supabase) throw new Error('saveBuyBox: supabase is required');

  const name = deriveBuyBoxName(criteria);

  // Look for existing active buy box for this user
  const { data: existing, error: fetchError } = await supabase
    .from('buy_boxes')
    .select('id, version, criteria, name')
    .eq('user_email', email)
    .eq('status', 'active')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (fetchError) {
    throw new Error(`saveBuyBox: fetch failed: ${fetchError.message}`);
  }

  if (existing) {
    // Active box found — check if criteria changed
    const criteriaChanged = JSON.stringify(criteria) !== JSON.stringify(existing.criteria);

    const updates = {};
    if (criteriaChanged) {
      updates.criteria = criteria;
      updates.version = existing.version + 1;
      updates.criteria_updated_at = new Date().toISOString();
      // Regenerate name when criteria change
      updates.name = name;
    }
    // If only name would differ (no criteria change), we don't touch name either —
    // the AI-derived name is cosmetic and not a versioning trigger.

    if (criteriaChanged) {
      const { data: updated, error: updateError } = await supabase
        .from('buy_boxes')
        .update(updates)
        .eq('id', existing.id)
        .select('id, version')
        .single();

      if (updateError) {
        throw new Error(`saveBuyBox: update failed: ${updateError.message}`);
      }

      return { buyBoxId: updated.id, buyBoxVersion: updated.version };
    }

    // No change — return existing id/version
    return { buyBoxId: existing.id, buyBoxVersion: existing.version };
  }

  // No active box — insert a new one with status='active'
  const { data: inserted, error: insertError } = await supabase
    .from('buy_boxes')
    .insert({
      user_email: email,
      name,
      criteria,
      status: 'active',
      version: 1,
      criteria_updated_at: new Date().toISOString(),
    })
    .select('id, version')
    .single();

  if (insertError) {
    throw new Error(`saveBuyBox: insert failed: ${insertError.message}`);
  }

  return { buyBoxId: inserted.id, buyBoxVersion: inserted.version };
}

module.exports = { saveBuyBox };
