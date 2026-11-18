# Changelog

Each entry lists breaking changes first. Railway shows deployers an update notice when a change is merged to `main`; read the entry before you apply it.

## 3.8.0-railway.1 (2026-11-18)

First version.

- BookOrbit 3.8.0 (`ghcr.io/bookorbit/bookorbit:3.8.0@sha256:d318f7732f6f6330312e2c5f854f7899f858b54cc4b18a13cde1f43b5bea0515`).
- Railway Postgres 18 (with pgvector) over the private network.
- All app state on one Railway volume at `/data`, book files in `/data/books`.
- Generated setup token, JWT secret and three hex encryption keys; no prompts.
- Start script waits for Postgres on a first deploy and derives `APP_URL` from the Railway domain.
- `TRUST_PROXY` includes Railway's edge proxy, so HTTPS cookies, HSTS and client IPs work.
- Health check `/api/v1/health`.
