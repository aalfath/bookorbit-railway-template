#!/bin/sh
# Small Railway wrapper around BookOrbit's own entrypoint.
set -e

export APP_DATA_PATH="${APP_DATA_PATH:-/data}"
mkdir -p "$APP_DATA_PATH/books"

# Railway's public domain, used for links in e-mails, Kobo sync and OPDS, when APP_URL isn't set.
if [ -z "${APP_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export APP_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

# Wait up to 2 minutes for Postgres, so a first deploy doesn't crash while the database boots.
i=0
while [ -n "${DATABASE_URL:-}" ] && ! node -e '
const { Client } = require("/app/node_modules/pg");
const c = new Client({ connectionString: process.env.DATABASE_URL, connectionTimeoutMillis: 3000 });
c.connect().then(() => c.end()).then(() => process.exit(0), () => process.exit(1));
' 2>/dev/null; do
  i=$((i + 1))
  if [ "$i" -ge 40 ]; then
    echo "railway-start: database not reachable after 2 minutes, starting anyway" >&2
    break
  fi
  echo "railway-start: waiting for the database ($i)" >&2
  sleep 3
done

exec sh /app/entrypoint.sh
