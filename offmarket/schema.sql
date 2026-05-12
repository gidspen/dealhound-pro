-- Off-market small-business acquisition DB — Supabase schema `offmarket`
-- Project: gggmmjvwbbfvrtjjlqvr (incredible-ai-deals). Applied 2026-05-12 via migration
-- `create_offmarket_acquisitions_schema`. This file is the canonical snapshot — keep it
-- in sync if the schema changes.
--
-- Purpose: internal (not public/licensed) targeting of healthy, long-tenured, *coasting*
-- Texas small-business owners likely to sell in 1–3 years. Distressed businesses are
-- excluded by filter, not scored low. Each business carries a 4-layer composite score
-- (base rate / sellability / behavioral trigger / market pull) with per-layer commentary
-- and a final tier: A_acquire_self | B_forward | C_watch | D_pass.

create schema if not exists offmarket;

create table if not exists offmarket.businesses (
  id uuid primary key default gen_random_uuid(),
  vertical text not null default 'dental',
  legal_name text not null,
  dba_name text,
  naics_code text,
  address text,
  city text,
  county text,
  state text not null default 'TX',
  zip text,
  phone text,
  website text,
  license_number text,
  license_type text,
  license_status text,
  license_issue_date date,
  license_holder_name text,            -- named responsible professional (dentist of record / RME)
  entity_sos_file_number text,
  entity_formation_date date,
  entity_status text,
  registered_agent text,
  years_in_business int,
  employee_count_estimate int,
  provider_count_estimate int,
  employee_count_source text,
  owner_name text,
  owner_age_estimate int,
  owner_age_source text,               -- ov65_exemption | voter_file_dob | license_tenure_proxy | linkedin_gradyear | dmv | ...
  owner_tenure_years int,
  owner_homestead_address text,
  owner_property_deed_date date,
  is_distressed boolean not null default false,
  distress_reasons jsonb not null default '[]'::jsonb,
  data_sources jsonb not null default '[]'::jsonb,    -- [{source,url,fetched_at,fields:[...]}]
  raw_enrichment jsonb not null default '{}'::jsonb,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (vertical, legal_name, city, state)
);

create table if not exists offmarket.score_runs (
  id uuid primary key default gen_random_uuid(),
  run_label text not null,
  model_version text not null,
  weights jsonb not null,              -- {"layer1":0.30,"layer2":0.25,"layer3":0.30,"layer4":0.15}
  vertical text not null default 'dental',
  geography text,
  business_count int not null default 0,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists offmarket.business_signals (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references offmarket.businesses(id) on delete cascade,
  layer int not null check (layer between 1 and 4),
  signal_key text not null,
  direction text not null check (direction in ('positive','negative','disqualifying')),
  weight numeric,
  evidence text not null,
  source text,
  source_url text,
  observed_at date,
  created_at timestamptz not null default now()
);

create table if not exists offmarket.business_scores (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references offmarket.businesses(id) on delete cascade,
  score_run_id uuid not null references offmarket.score_runs(id) on delete cascade,
  layer1_base_rate numeric not null check (layer1_base_rate between 0 and 100),
  layer1_comment text not null,
  layer2_sellability numeric not null check (layer2_sellability between 0 and 100),
  layer2_comment text not null,
  layer3_behavioral_trigger numeric not null check (layer3_behavioral_trigger between 0 and 100),
  layer3_comment text not null,
  layer4_market_pull numeric not null check (layer4_market_pull between 0 and 100),
  layer4_comment text not null,
  final_score numeric not null check (final_score between 0 and 100),
  final_tier text not null check (final_tier in ('A_acquire_self','B_forward','C_watch','D_pass')),
  final_comment text not null,
  value_add_thesis text,
  confidence text not null check (confidence in ('high','medium','low')),
  data_completeness numeric,
  created_at timestamptz not null default now(),
  unique (business_id, score_run_id)
);

create or replace view offmarket.scored_targets as
select b.*,
       s.layer1_base_rate, s.layer1_comment,
       s.layer2_sellability, s.layer2_comment,
       s.layer3_behavioral_trigger, s.layer3_comment,
       s.layer4_market_pull, s.layer4_comment,
       s.final_score, s.final_tier, s.final_comment, s.value_add_thesis,
       s.confidence, s.data_completeness, s.score_run_id,
       s.created_at as scored_at
from offmarket.businesses b
join lateral (
  select * from offmarket.business_scores bs
  where bs.business_id = b.id
  order by bs.created_at desc
  limit 1
) s on true;

create index if not exists businesses_vertical_county_idx on offmarket.businesses (vertical, county);
create index if not exists businesses_distressed_idx on offmarket.businesses (is_distressed);
create index if not exists business_signals_business_idx on offmarket.business_signals (business_id);
create index if not exists business_scores_run_score_idx on offmarket.business_scores (score_run_id, final_score desc);
create index if not exists business_scores_tier_idx on offmarket.business_scores (final_tier);

alter table offmarket.businesses       enable row level security;
alter table offmarket.score_runs       enable row level security;
alter table offmarket.business_signals enable row level security;
alter table offmarket.business_scores  enable row level security;
