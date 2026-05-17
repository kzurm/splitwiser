-- Splitwiser schema — run once in Supabase SQL Editor
-- Project → SQL Editor → New query → paste → Run

create extension if not exists "uuid-ossp";

-- ── Tables ────────────────────────────────────────────────
create table public.transactions (
  id uuid primary key default uuid_generate_v4(),
  date timestamptz not null,
  merchant text not null,
  amount numeric not null,
  currency text not null check (currency in ('KSH', 'USD')),
  paid_by text not null check (paid_by in ('austin', 'kari')),
  split_mode jsonb not null,
  category text not null,
  note text,
  code text,
  settled boolean default false,
  created_at timestamptz default now()
);

create table public.comments (
  id uuid primary key default uuid_generate_v4(),
  txn_id uuid references public.transactions(id) on delete cascade,
  by_user text not null check (by_user in ('austin', 'kari')),
  text text not null,
  at timestamptz default now()
);

create table public.settlements (
  id uuid primary key default uuid_generate_v4(),
  by_user text not null check (by_user in ('austin', 'kari')),
  amount numeric not null,
  currency text not null check (currency in ('KSH', 'USD')),
  note text,
  at timestamptz default now()
);

-- ── Indexes ───────────────────────────────────────────────
create index transactions_date_idx on public.transactions (date desc);
create index comments_txn_idx on public.comments (txn_id, at);
create index settlements_at_idx on public.settlements (at desc);

-- ── Realtime ──────────────────────────────────────────────
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.comments;
alter publication supabase_realtime add table public.settlements;

-- ── Row Level Security ────────────────────────────────────
-- 2-person private app: open policy with anon key. The anon key sits in the
-- deployed HTML, so the deploy URL itself is effectively the password. If the
-- key ever leaks, rotate it in Project Settings → API and redeploy.
alter table public.transactions enable row level security;
alter table public.comments     enable row level security;
alter table public.settlements  enable row level security;

create policy "open" on public.transactions for all using (true) with check (true);
create policy "open" on public.comments     for all using (true) with check (true);
create policy "open" on public.settlements  for all using (true) with check (true);
