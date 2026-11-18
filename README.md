[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/bookorbit-1?utm_medium=integration&utm_source=button&utm_campaign=bookorbit)

# BookOrbit on Railway

A one-click [Railway](https://railway.com) template for [BookOrbit](https://bookorbit.app) ([GitHub](https://github.com/bookorbit/bookorbit)), the self-hosted library and reading platform for ebooks, PDFs, comics and audiobooks: built-in web readers, metadata from 12 providers, reading stats, OPDS, Kobo and KOReader sync, and multi-user access.

**Version:** BookOrbit `3.8.0` (2026-11-11), official image `ghcr.io/bookorbit/bookorbit:3.8.0`, pinned by digest `sha256:d318f7732f6f6330312e2c5f854f7899f858b54cc4b18a13cde1f43b5bea0515` in the [`Dockerfile`](Dockerfile).

## What the template deploys

| Service | Built from | Role | Public | State |
|---|---|---|---|---|
| `BookOrbit` | this repository ([`Dockerfile`](Dockerfile)) | Web app, readers, API, OPDS, Kobo/KOReader sync, background jobs | yes, port 3000 | Railway volume at `/data`: book files (`/data/books`), covers, uploads, Book Dock, caches |
| `Postgres` | Railway's Postgres 18 (includes pgvector) | Library, users, reading progress, settings | no | Railway volume |

- The BookOrbit service builds from this repository, so Railway offers deployers an update when a new version is merged here.
- [`railway-start.sh`](railway-start.sh) creates `/data/books`, fills `APP_URL` from the Railway domain when it's empty, waits up to 2 minutes for Postgres on a first deploy, then runs BookOrbit's own entrypoint (database migrations, permission fix, server start).
- The Dockerfile sets `LIBRARY_BROWSE_ROOT=/data/books`, so the library folder picker only offers folders on the volume, and `TRUST_PROXY` to include Railway's edge proxy range (`100.64.0.0/10`), so BookOrbit sees HTTPS (secure cookies, HSTS) and real client IPs (login rate limits).
- Health check: `GET /api/v1/health` (checks the database, no login).

## Variables

Nothing to fill in: every value is a reference or generated per deploy.

| Variable | Value | Notes |
|---|---|---|
| `PORT` | `3000` | Port BookOrbit listens on; the public domain targets it |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Private-network connection to Postgres |
| `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public address used in e-mails, OPDS and Kobo links. Change it if you add a custom domain |
| `SETUP_BOOTSTRAP_TOKEN` | random, 32 characters | One-time token for the first-run setup page, where you create the owner account |
| `JWT_SECRET` | random, 64 characters | Signs login tokens |
| `EMAIL_ENCRYPTION_KEY` | random, 64 hex characters | Encrypts stored SMTP passwords |
| `MIGRATION_ENCRYPTION_KEY` | random, 64 hex characters | Encrypts credentials for imports from other library apps |
| `BOOK_REQUEST_ENCRYPTION_KEY` | random, 64 hex characters | Encrypts download-client, indexer and metadata-provider credentials |

Keep the three encryption keys: changing one makes the values it protects unreadable.

Optional features are set in the app's admin settings (SMTP and Send-to-Kindle, OIDC sign-in, metadata providers) or with extra variables from BookOrbit's [installation guide](https://bookorbit.app/installation) (for example `GITHUB_RELEASES_TOKEN`). Read-aloud generation needs BookOrbit's separate worker and isn't part of this template.

## After deploying

1. Open the service's public URL. BookOrbit shows its setup page.
2. Copy `SETUP_BOOTSTRAP_TOKEN` from the BookOrbit service's **Variables** tab, paste it on the setup page, and create the owner (admin) account.
3. Create a library. Pick `/data/books` (or a folder inside it) as the library folder.
4. Upload books from the browser (drag and drop), or drop files into the Book Dock. Everything lands on the volume.

Without the token nobody else can claim a fresh instance: the setup endpoint answers 403. Public sign-up is off by default.

## Updates

When a new BookOrbit release is out, this repository bumps the `FROM` tag and digest and adds a [`CHANGELOG.md`](CHANGELOG.md) entry. Railway then shows an update notice on your project, and you choose when to apply it. Database migrations run automatically on the next start. Read the changelog first: breaking changes are listed at the top of each entry.

## Run it locally

```sh
docker build -t bookorbit-railway .
docker run -d --name bo-db -e POSTGRES_PASSWORD=change-me pgvector/pgvector:pg18
docker run -d -p 3000:3000 --link bo-db -v bookorbit-data:/data \
  -e DATABASE_URL=postgres://postgres:change-me@bo-db:5432/postgres \
  -e JWT_SECRET=$(openssl rand -hex 32) -e SETUP_BOOTSTRAP_TOKEN=$(openssl rand -hex 16) \
  -e APP_URL=http://localhost:3000 bookorbit-railway
```

## Licence

BookOrbit is licensed under [AGPL-3.0](https://github.com/bookorbit/bookorbit/blob/main/LICENSE). The wrapper files in this repository (Dockerfile, start script, docs) are MIT licensed.
