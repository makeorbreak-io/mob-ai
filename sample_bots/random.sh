#!/usr/bin/env bash

# no sdk, sorry :(
# requires `jq(1)` to run.

ACTIONS=(shoot walk)
DIRECTIONS=([-1,-1] [-1,0] [-1,1] [0,-1] [0,1] [1,-1] [1,0] [1,1])

read msg
PLAYER_ID="$(echo "$msg" | jq .player_id)"

echo '{"ready":true}'

while read msg; do
  TURNS_LEFT="$(echo "$msg" | jq .turns_left)"

  ACTION="${ACTIONS[$RANDOM % 2]}"
  DIRECTION="${DIRECTIONS[$RANDOM % 8]}"
  
  echo "{\"turns_left\":$TURNS_LEFT,\"type\":\"$ACTION\",\"direction\":$DIRECTION}"
done
