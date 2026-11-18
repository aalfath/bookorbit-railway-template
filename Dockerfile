# BookOrbit for Railway. Upstream image pinned by version and digest.
# Bump both the tag and the digest together, and add a CHANGELOG.md entry.
FROM ghcr.io/bookorbit/bookorbit:3.8.0@sha256:d318f7732f6f6330312e2c5f854f7899f858b54cc4b18a13cde1f43b5bea0515

COPY railway-start.sh /app/railway-start.sh

# Railway gives each service one volume, mounted at /data. Book files live there too
# (/data/books, the only folder the library picker offers), so they survive redeploys.
ENV NODE_ENV=production \
    PORT=3000 \
    APP_DATA_PATH=/data \
    LIBRARY_BROWSE_ROOT=/data/books

EXPOSE 3000

# tini stays PID 1 as upstream; the wrapper prepares /data/books, then runs upstream's entrypoint
# (file-env, ownership fix, database migrations, server start).
ENTRYPOINT ["/sbin/tini", "-s", "--"]
CMD ["sh", "/app/railway-start.sh"]
