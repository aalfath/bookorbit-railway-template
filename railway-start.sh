#!/bin/sh
# Small Railway wrapper around BookOrbit's own entrypoint.
set -e

export APP_DATA_PATH="${APP_DATA_PATH:-/data}"
mkdir -p "$APP_DATA_PATH/books"

# Railway's public domain, used for links in e-mails, Kobo sync and OPDS, when APP_URL isn't set.
if [ -z "${APP_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export APP_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

exec sh /app/entrypoint.sh
