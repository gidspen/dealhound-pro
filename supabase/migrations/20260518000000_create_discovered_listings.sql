-- Off-market discovery: discovered_listings table
-- Idempotent insert key: (source, url)
-- Maps 1:1 to offmarket.discovery.base.Listing dataclass

create table if not exists discovered_listings (
  id              bigint generated always as identity primary key,
  source          text    not null,
  url             text    not null,
  title           text    not null,
  location        text,
  asking_price    bigint,                        -- null = call for price / undisclosed
  asset_type      text    not null,              -- rv_park|campground|boutique_hotel|glamping|self_storage|inn
  size_metric     text,                          -- "39 Lots", "84.2 acres", etc.
  description     text,
  posted_date     date,
  broker_name     text,
  broker_phone    text,
  broker_email    text,
  scraped_at      timestamptz not null default now(),
  created_at      timestamptz not null default now(),

  constraint discovered_listings_source_url_key unique (source, url)
);

-- Indexes for common query patterns
create index if not exists idx_discovered_listings_asset_type
  on discovered_listings (asset_type);

create index if not exists idx_discovered_listings_scraped_at
  on discovered_listings (scraped_at desc);

create index if not exists idx_discovered_listings_asking_price
  on discovered_listings (asking_price)
  where asking_price is not null;

create index if not exists idx_discovered_listings_source
  on discovered_listings (source);

-- RLS: same pattern as deals tables (PR #78)
alter table discovered_listings enable row level security;

-- Service role has full access (used by the pipeline)
create policy "service_role_full_access"
  on discovered_listings
  for all
  to service_role
  using (true)
  with check (true);

-- Authenticated users can read
create policy "authenticated_read"
  on discovered_listings
  for select
  to authenticated
  using (true);

comment on table discovered_listings is
  'Off-market property/business listings scraped from niche broker sites. '
  'Deduped on (source, url). Populated by offmarket/discovery/run.py.';
