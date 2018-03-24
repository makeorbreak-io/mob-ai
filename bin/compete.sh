#!/usr/bin/env bash

docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --rm -it mob-ai-compete:latest \
  bundle exec bin/compete.rb boards/10x10.json
