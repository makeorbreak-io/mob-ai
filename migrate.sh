#!/usr/bin/env bash

function create_database {
  DBNAME="$(echo "$DATABASE_URL" | sed -e 's/.*\/\(.*\)\(\?.*\)\?/\1/')"

  createdb "$DBNAME" || true
}

function run_migration {
  MIGRATION="$1"

  if test -z "$(psql -tA "$DATABASE_URL" -c "SELECT 1 FROM migrations WHERE name='$MIGRATION';")"; then
    psql "$DATABASE_URL" -f "$MIGRATION"
    psql "$DATABASE_URL" -c "INSERT INTO migrations(name) VALUES('$MIGRATION')"
  fi
}

function run_migrations {
  psql "$DATABASE_URL" -f "migrations/000-meta.sql"

  find migrations -type f |
    sort -n |
    grep -v "000-meta.sql" |
    while read MIGRATION; do run_migration "$MIGRATION"; done
}

create_database
run_migrations
