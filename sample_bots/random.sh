#!/usr/bin/env bash

ACTIONS=(shoot walk)
DIRECTIONS=([-1,-1] [-1,0] [-1,1] [0,-1] [0,1] [1,-1] [1,0] [1,1])

read
while read; do
  ACTION="${ACTIONS[$RANDOM % 2]}"
  DIRECTION="${DIRECTIONS[$RANDOM % 8]}"
  
  echo "{\"type\":\"$ACTION\","direction":$DIRECTION}"
done
