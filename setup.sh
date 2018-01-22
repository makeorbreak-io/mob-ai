#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function setup_images {
  find base-images -name Dockerfile |
    while read dockerfile; do
      DOCKERPATH=$(dirname $dockerfile);
      IMAGENAME="mob-ai-$(basename "$DOCKERPATH")"

      pushd $DOCKERPATH
      docker build -t "$IMAGENAME" .
      echo $IMAGENAME
      popd
    done
  }

function setup_network {
  DROP="DOCKER-ISOLATION -i docker1 -j DROP"
  RETURN="DOCKER-ISOLATION -j RETURN"

  docker network inspect no-egress > /dev/null 2>&1 ||
  docker network create --subnet 10.1.1.0/24 -o "com.docker.network.bridge.name=docker1" no-egress > /dev/null

  sudo iptables-save | grep "$DROP" > /dev/null || (
    sudo iptables -D $RETURN
    sudo iptables -A $DROP
    sudo iptables -A $RETURN
  )
}

function setup_database {
  createdb "mob-ai" || true

  psql "mob-ai" -f "migrations/000-meta.sql";

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

setup_images
setup_network
setup_database
