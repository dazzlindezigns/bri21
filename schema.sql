-- Bri's 21st: RSVP table. Safe to run in a shared Supabase project.
create table if not exists public.bri21_rsvps (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  guests int not null default 1 check (guests between 1 and 12),      -- ages 9+ (they pay)
  kids int not null default 0 check (kids between 0 and 12),          -- under 9 (free)
  status text not null default 'thinking'
    check (status in ('thinking','coins','pending','in','paid','gift')),
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
  with check (status in ('thinking','coins','pending','gift'));

revoke all on public.bri21_rsvps from anon, authenticated;
grant select (id, name, guests, kids, status, note, created_at) on public.bri21_rsvps to anon;
grant insert (name, guests, kids, status, note) on public.bri21_rsvps to anon;

-- Statuses: thinking = Interested, coins = Checking coins, pending = Coming,
--           in = Locked in (deposit paid), paid = Paid in full,
--           gift = Can't make it, sending a gift (not a rider, never counted in the van split)

-- ALREADY RAN THE OLD VERSION? Run just this instead:
-- alter table public.bri21_rsvps drop constraint if exists bri21_rsvps_status_check;
-- alter table public.bri21_rsvps add constraint bri21_rsvps_status_check
--   check (status in ('thinking','coins','pending','in','paid'));
-- drop policy if exists "bri21 rsvp" on public.bri21_rsvps;
-- create policy "bri21 rsvp" on public.bri21_rsvps for insert to anon
--   with check (status in ('thinking','coins','pending'));

-- ADDING THE "CAN'T MAKE IT, SENDING LOVE" OPTION (Oct 2026). Run this once on the live table:
-- alter table public.bri21_rsvps drop constraint if exists bri21_rsvps_status_check;
-- alter table public.bri21_rsvps add constraint bri21_rsvps_status_check
--   check (status in ('thinking','coins','pending','in','paid','gift'));
-- drop policy if exists "bri21 rsvp" on public.bri21_rsvps;
-- create policy "bri21 rsvp" on public.bri21_rsvps for insert to anon
--   with check (status in ('thinking','coins','pending','gift'));

-- ============================================================
-- ADMIN (/admin.html). Only Dani's login can read payments or change rows.
-- Everything here is scoped to bri21_rsvps. Safe to re-run.
-- ============================================================
grant select on public.bri21_rsvps to authenticated;
grant update (status, amount_paid) on public.bri21_rsvps to authenticated;
grant delete on public.bri21_rsvps to authenticated;

drop policy if exists "bri21 admin read"   on public.bri21_rsvps;
drop policy if exists "bri21 admin update" on public.bri21_rsvps;
drop policy if exists "bri21 admin delete" on public.bri21_rsvps;
create policy "bri21 admin read" on public.bri21_rsvps for select to authenticated
  using (lower(auth.jwt()->>'email') = 'danielle.washington21@gmail.com');
create policy "bri21 admin update" on public.bri21_rsvps for update to authenticated
  using (lower(auth.jwt()->>'email') = 'danielle.washington21@gmail.com')
  with check (lower(auth.jwt()->>'email') = 'danielle.washington21@gmail.com' and amount_paid >= 0);
create policy "bri21 admin delete" on public.bri21_rsvps for delete to authenticated
  using (lower(auth.jwt()->>'email') = 'danielle.washington21@gmail.com');

-- ============================================================
-- ONE ROW PER PERSON (Oct 2026). Every person in a party gets their own row
-- with a name and age. party_id groups a family. guests/kids stay as 1/0 per
-- row (9+ pays = guests 1; under 9 = kids 1) so the money math is unchanged.
-- Ages are private: the public can submit an age but can't read it back.
-- Safe to re-run.
-- ============================================================
alter table public.bri21_rsvps add column if not exists age int;
alter table public.bri21_rsvps add column if not exists party_id uuid;
alter table public.bri21_rsvps drop constraint if exists bri21_rsvps_age_check;
alter table public.bri21_rsvps add constraint bri21_rsvps_age_check check (age is null or age between 0 and 120);
alter table public.bri21_rsvps drop constraint if exists bri21_rsvps_guests_check;
alter table public.bri21_rsvps add constraint bri21_rsvps_guests_check check (guests between 0 and 12);
alter table public.bri21_rsvps drop constraint if exists bri21_rsvps_heads_check;
alter table public.bri21_rsvps add constraint bri21_rsvps_heads_check check (
  guests + kids >= 1
  and (age is null or (age >= 9 and guests = 1 and kids = 0) or (age < 9 and guests = 0 and kids = 1))
);
create index if not exists bri21_rsvps_party_idx on public.bri21_rsvps (party_id);
grant insert (age, party_id) on public.bri21_rsvps to anon;
grant select (party_id) on public.bri21_rsvps to anon;

-- ============================================================
-- NOTES FOR BRI (Oct 2026). People can add notes after they RSVP.
-- Add-only for the public (no edits or deletes). Dani can read and remove.
-- Notes disappear automatically if the person's RSVP is removed. Safe to re-run.
-- ============================================================
create table if not exists public.bri21_notes (
  id uuid primary key default gen_random_uuid(),
  rsvp_id uuid not null references public.bri21_rsvps(id) on delete cascade,
  note text not null check (char_length(note) between 1 and 140),
  created_at timestamptz not null default now()
);
create index if not exists bri21_notes_rsvp_idx on public.bri21_notes (rsvp_id);
alter table public.bri21_notes enable row level security;
revoke all on public.bri21_notes from anon, authenticated;
grant select (id, rsvp_id, note, created_at) on public.bri21_notes to anon;
grant insert (rsvp_id, note) on public.bri21_notes to anon;
grant select, delete on public.bri21_notes to authenticated;
drop policy if exists "bri21 notes read"         on public.bri21_notes;
drop policy if exists "bri21 notes add"          on public.bri21_notes;
drop policy if exists "bri21 notes admin read"   on public.bri21_notes;
drop policy if exists "bri21 notes admin delete" on public.bri21_notes;
create policy "bri21 notes read" on public.bri21_notes for select to anon using (true);
create policy "bri21 notes add"  on public.bri21_notes for insert to anon with check (true);
create policy "bri21 notes admin read" on public.bri21_notes for select to authenticated
  using (lower(auth.jwt()->>'email') = 'danielle.washington21@gmail.com');
create policy "bri21 notes admin delete" on public.bri21_notes for delete to authenticated
  using (lower(auth.jwt()->>'email') = 'danielle.washington21@gmail.com');
