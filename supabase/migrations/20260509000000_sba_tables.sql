-- SBA acquisition lead tables
-- Run A foundation — 2026-05-09

-- sba_scans must be created first (sba_leads references it)
create table if not exists public.sba_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  vertical text not null default 'dental',
  state text not null default 'TX',
  city text,
  target_lead_count integer not null default 20,
  status text not null default 'scanning' check (status in ('scanning','complete','error')),
  deal_count integer not null default 0,
  conversation_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sba_leads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete set null,
  scan_id uuid references public.sba_scans(id) on delete cascade,

  -- business identity
  business_name text not null,
  vertical text not null default 'dental',
  address text,
  city text,
  state text not null default 'TX',
  zip text,
  phone text,
  website text,

  -- owner identity (nullable — partial enrichment)
  owner_name text,
  owner_email text,
  owner_phone text,
  owner_linkedin text,

  -- business facts
  years_in_business integer,
  license_year integer,

  -- scoring
  retirement_score integer not null check (retirement_score between 0 and 100),
  retirement_tier text not null check (retirement_tier in ('HOT','STRONG','WATCH','DISCARD')),
  signals jsonb not null default '[]'::jsonb,

  -- outreach
  outreach_angle text,
  outreach_subject text,
  outreach_body text,

  -- lifecycle
  status text not null default 'new' check (status in ('new','contacted','responded','rejected','in_progress','snoozed')),
  scored_at timestamptz not null default now(),
  last_refreshed timestamptz not null default now(),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists sba_leads_user_id_idx on public.sba_leads(user_id);
create index if not exists sba_leads_tier_idx on public.sba_leads(retirement_tier);
create index if not exists sba_leads_score_idx on public.sba_leads(retirement_score desc);
create index if not exists sba_scans_user_id_idx on public.sba_scans(user_id);
