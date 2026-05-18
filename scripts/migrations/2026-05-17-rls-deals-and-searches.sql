-- Enable RLS on deal_searches and deals, matching the policy pattern
-- already in use on conversations and scan_progress.
-- All real access goes through the service key (bypasses RLS).
-- These policies close the gap where the anon key could be used directly.

ALTER TABLE public.deal_searches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;

-- deal_searches
CREATE POLICY service_all_deal_searches ON public.deal_searches
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY anon_read_deal_searches ON public.deal_searches
  FOR SELECT USING (true);

-- deals
CREATE POLICY service_all_deals ON public.deals
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY anon_read_deals ON public.deals
  FOR SELECT USING (true);
