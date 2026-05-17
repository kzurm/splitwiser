# Splitwiser

A homemade Splitwise for two — paste-based M-Pesa parsing, manual entry for everything else, multi-currency balances, richer reporting than Splitwise. Built for Kari & Austin.

## Run it

Deployed via GitHub Pages from this repo's `main` branch.

- **You're Austin**: open the deploy URL as-is, or `?me=austin`
- **You're Kari**: open the deploy URL with `?me=kari`

Identity is per-device (stored only in the URL).

## Stack

- One static HTML file (`index.html`) — React + Babel via CDN, Supabase JS via CDN.
- Supabase Postgres backs `transactions`, `comments`, and `settlements` tables. Live updates via Supabase Realtime.
- Free FX rates from `fawazahmed0/currency-api` via jsDelivr.

## Database

Schema is in [`supabase-schema.sql`](supabase-schema.sql). Run it once in Supabase → SQL Editor.

The Supabase publishable key in `index.html` is intentional — RLS policies are open by design (this is a two-person private app, the deploy URL itself is the password). If the key ever leaks, rotate it in Supabase → Project Settings → API and update `index.html`.

## Local dev

```sh
python3 -m http.server 3001
# open http://localhost:3001/index.html
```
