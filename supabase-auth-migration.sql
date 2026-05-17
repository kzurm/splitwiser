-- Splitwiser RLS migration — tightens the open policies to an authenticated allowlist.
-- Run this in Supabase → SQL Editor AFTER running supabase-schema.sql.
--
-- Effect: only requests carrying a Supabase Auth JWT whose email is in the allowlist
-- can read or write any of the three tables. Unauthenticated requests (anon key alone)
-- are rejected. Update the allowlist below if you add/remove members.

-- Drop the wide-open policies created by supabase-schema.sql.
drop policy if exists "open" on public.transactions;
drop policy if exists "open" on public.comments;
drop policy if exists "open" on public.settlements;

-- Tight allowlist policies — same predicate on every table.
create policy "allowlist_all" on public.transactions for all
  using     ((auth.jwt() ->> 'email') in ('karimruz@gmail.com', 'austinharris@gmail.com'))
  with check((auth.jwt() ->> 'email') in ('karimruz@gmail.com', 'austinharris@gmail.com'));

create policy "allowlist_all" on public.comments for all
  using     ((auth.jwt() ->> 'email') in ('karimruz@gmail.com', 'austinharris@gmail.com'))
  with check((auth.jwt() ->> 'email') in ('karimruz@gmail.com', 'austinharris@gmail.com'));

create policy "allowlist_all" on public.settlements for all
  using     ((auth.jwt() ->> 'email') in ('karimruz@gmail.com', 'austinharris@gmail.com'))
  with check((auth.jwt() ->> 'email') in ('karimruz@gmail.com', 'austinharris@gmail.com'));
