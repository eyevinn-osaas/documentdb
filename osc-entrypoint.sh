#!/bin/bash
set -e

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "ERROR: POSTGRES_PASSWORD must be set (database superuser password)." >&2
  exit 1
fi

# FerretDB requires the database to be named "postgres"
export POSTGRES_DB="${POSTGRES_DB:-postgres}"
export PGDATA="${PGDATA:-/var/lib/postgresql/data/pgdata}"

# Dummy HTTP listener: the platform probes port 8080
mkdir -p /tmp/health
python3 -m http.server 8080 --directory /tmp/health >/dev/null 2>&1 &

# Optional extra SQL, run once on first initialization (after the DocumentDB extension setup)
if [ -n "$POSTGRES_INITDB_SQL" ]; then
  mkdir -p /docker-entrypoint-initdb.d
  echo "$POSTGRES_INITDB_SQL" > /docker-entrypoint-initdb.d/30-osc-init.sql
fi

exec /usr/local/bin/docker-entrypoint.sh "$@"
