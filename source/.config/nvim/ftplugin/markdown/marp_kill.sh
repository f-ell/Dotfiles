#!/bin/sh
# This script is called by marp.lua when executing a user command.
# It's used to shut down the containers spawned by marp_spawn.sh.

err() {
  printf 'marp_kill: %s\n' "$2"
  [ $1 -gt 0 ] && exit $1
}

docker stop -t1 marp-watch-pdf-$1
[ $? -ne 0 ] && err 1 'docker stop fatal, container still running.'
