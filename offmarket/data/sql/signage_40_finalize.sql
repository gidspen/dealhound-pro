UPDATE offmarket.score_runs
SET business_count = 95,
    notes = COALESCE(notes,'') || ' [persisted ' || now()::text || ']'
WHERE id = '0b92ff99-cec4-4878-8c30-99378609acbb';
