-- Splitwiser allowlist via private `members` table.
-- Run this in Supabase → SQL Editor. Idempotent — safe to re-run.
-- After running, populate the members table from a separate query (don't commit
-- emails to git). See the comment at the bottom for the insert statement.

-- ── Drop any prior policies (open or email-hardcoded) ────────
drop policy if exists "open"           on public.transactions;
drop policy if exists "open"           on public.comments;
drop policy if exists "open"           on public.settlements;
drop policy if exists "allowlist_all"  on public.transactions;
drop policy if exists "allowlist_all"  on public.comments;
drop policy if exists "allowlist_all"  on public.settlements;
drop policy if exists "members_only"   on public.transactions;
drop policy if exists "members_only"   on public.comments;
drop policy if exists "members_only"   on public.settlements;

-- ── Members table — private allowlist, source of truth ───────
create table if not exists public.members (
  email  text primary key,
  person text not null check (person in ('austin', 'kari'))
);
alter table public.members enable row level security;

-- A logged-in user can only see their own row.
drop policy if exists "members_self_read" on public.members;
create policy "members_self_read" on public.members for select
  using (email = (auth.jwt() ->> 'email'));

-- ── Data-table policies — membership check ───────────────────
create policy "members_only" on public.transactions for all
  using     (exists (select 1 from public.members m where m.email = (auth.jwt() ->> 'email')))
  with check(exists (select 1 from public.members m where m.email = (auth.jwt() ->> 'email')));

create policy "members_only" on public.comments for all
  using     (exists (select 1 from public.members m where m.email = (auth.jwt() ->> 'email')))
  with check(exists (select 1 from public.members m where m.email = (auth.jwt() ->> 'email')));

create policy "members_only" on public.settlements for all
  using     (exists (select 1 from public.members m where m.email = (auth.jwt() ->> 'email')))
  with check(exists (select 1 from public.members m where m.email = (auth.jwt() ->> 'email')));

-- ── Populate the table — DO THIS IN A SEPARATE QUERY ─────────
-- Don't commit the emails to git. In a fresh SQL editor query, run:
--
--   insert into public.members (email, person) values
--     ('you@example.com',     'kari'),
--     ('partner@example.com', 'austin')
--   on conflict (email) do update set person = excluded.person;
