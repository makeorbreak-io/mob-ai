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

source "functions.sh"

setup_images
setup_database
