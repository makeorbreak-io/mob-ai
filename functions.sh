#!/usr/bin/env bash

function setup_database {
  createdb "mob-ai" || true

  psql "$DATABASE_URL" -f "migrations/000-meta.sql";

  find migrations -type f |
    sort -n |
    grep -v "000-meta.sql" |
    while read migrationname; do
      psql -tA "mob-ai" -c "SELECT 1 FROM migrations WHERE name='$migrationname';" | grep . > /dev/null || (
      psql "mob-ai" -f "$migrationname"
      psql "mob-ai" -c "INSERT INTO migrations(name) VALUES('$migrationname')"
      )
    done
}
