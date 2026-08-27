# Ferncliff Farms

The website for Ferncliff Farms, run by the Forest Heights Homestead Collective —
a public agritourism site plus a set of private field tools for planning the farm,
all on one Cloudflare deployment.

## Live

- **Public site** — https://ferncliff.farm (also `www.ferncliff.farm`)
- **Ferncliff Farms Field Card** (parcel scoring) — https://ferncliff.farm/scorecard
- **Readiness Checklist** (prep tracker) — https://ferncliff.farm/checklist

The two field tools sit behind a shared passphrase (checked server-side; enter it
once per device). Signing into either authorizes the other. Both are offline-first
and keep a local cache in the browser, syncing to a shared database when online.

## Architecture

Everything runs on Cloudflare, deployed from this repo:

- **Public pages** — [Bridgetown](https://www.bridgetownrb.com/) 2 (ERB, Tailwind v4,
  Turbo/Stimulus), Ruby 3.4.4. Built to `output/`.
- **Field tools** — `src/scorecard.html` and `src/checklist.html`, dropped in as
  static passthrough (no front matter → copied verbatim), so they keep their own
  "field card" look independent of the marketing theme.
- **API** — Cloudflare Pages Functions under `functions/api/` (`login`, `session`,
  `logout`, `properties`, `checklist`) with an `/api/*` auth guard in `_middleware.js`.
- **Database** — Cloudflare D1 (SQLite). Schema in `migrations/`. Sync is
  last-write-wins per record (`updated_at`), with tombstones for deletes.
- **Auth** — the passphrase is compared server-side; a signed, HttpOnly cookie
  authorizes API calls. Secrets (`APP_PASSPHRASE`, `AUTH_SECRET`) are stored as
  Cloudflare Pages secrets, never in the repo.

## Running locally

Toolchain is pinned via `mise.toml` (Node 22.22.2 + Ruby 3.4.4) and `.ruby-version`.

```sh
mise install
bundle install && npm install
npm run db:migrate:local   # one time: set up the local D1 database
npm run cf:dev             # builds Bridgetown, serves output/ + Functions + local D1
```

`cf:dev` runs the full stack (static site + Pages Functions + D1) via
`wrangler pages dev`. For content-only work, `bin/bridgetown start` is faster but
does not run the Functions/database.

Create a `.dev.vars` file (git-ignored) with local secrets:

```
APP_PASSPHRASE="your local passphrase"
AUTH_SECRET="any-random-string-for-local-dev"
```

## Deployment

Pushes to `main` are built and deployed by GitHub Actions
(`.github/workflows/deploy.yml`): it builds Bridgetown (Ruby pinned by
`.ruby-version`) and runs `wrangler pages deploy output` to the `fhhc-farmsite`
Pages project. The D1 binding comes from `wrangler.jsonc`.

Requires a `CLOUDFLARE_API_TOKEN` repo secret (Cloudflare Pages: Edit).

To deploy by hand:

```sh
npm run db:migrate   # apply new migrations to the remote D1 (when the schema changes)
npm run cf:deploy    # build + wrangler pages deploy
```

Production secrets are set once with
`wrangler pages secret put APP_PASSPHRASE --project-name fhhc-farmsite` (and
`AUTH_SECRET`).
