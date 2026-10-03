-- Bri's 21st: RSVP table. Safe to run in a shared Supabase project.
create table if not exists public.bri21_rsvps (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  guests int not null default 1 check (guests between 1 and 12),      -- ages 9+ (they pay)
  kids int not null default 0 check (kids between 0 and 12),          -- under 9 (free)
  status text not null default 'thinking'
    check (status in ('thinking','coins','pending','in','paid')),
  note text check (char_length(note) <= 140),
  amount_paid numeric not null default 0,                             -- private, you edit this
  created_at timestamptz not null default now()
);

alter table public.bri21_rsvps enable row level security;

-- Public can see the list and add themselves. Only you (dashboard/service role) change status or payments.
drop policy if exists "bri21 read" on public.bri21_rsvps;
drop policy if exists "bri21 rsvp" on public.bri21_rsvps;
create policy "bri21 read" on public.bri21_rsvps for select to anon using (true);
create policy "bri21 rsvp" on public.bri21_rsvps for insert to anon
  with check (status in ('thinking','coins','pending'));

revoke all on public.bri21_rsvps from anon, authenticated;
grant select (id, name, guests, kids, status, note, created_at) on public.bri21_rsvps to anon;
grant insert (name, guests, kids, status, note) on public.bri21_rsvps to anon;

-- Statuses: thinking = Interested, coins = Checking coins, pending = Coming,
--           in = Locked in (deposit paid), paid = Paid in full

-- ALREADY RAN THE OLD VERSION? Run just this instead:
-- alter table public.bri21_rsvps drop constraint if exists bri21_rsvps_status_check;
-- alter table public.bri21_rsvps add constraint bri21_rsvps_status_check
--   check (status in ('thinking','coins','pending','in','paid'));
-- drop policy if exists "bri21 rsvp" on public.bri21_rsvps;
-- create policy "bri21 rsvp" on public.bri21_rsvps for insert to anon
--   with check (status in ('thinking','coins','pending'));
