create table if not exists waitlist (
  email      text primary key,
  signed_up_at timestamptz not null default now()
);

alter table waitlist enable row level security;

-- Only service role can read/write (no public access)
create policy "service only" on waitlist
  using (false)
  with check (false);
