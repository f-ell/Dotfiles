#!/bin/sh
# This script is called by marp.lua when executing a user command.
# It's used to spin up a docker container from the marpteam/marp-cli image in
# watch mode, to continuosly convert a *.slides.md file to a PDF.

err() {
  printf 'marp_spawn: %s\n' "$2" 1>&2
  [ $1 -gt 0 ] && exit $1
}
dep() {
  local missing_c=0 missing_d

  for dep in "$@"; do
    if ! command -v $dep 1>/dev/null; then
      missing_c=$((missing_c + 1))
      missing_d="$missing_d, $dep"
    fi
  done
  [ $missing_c -gt 0 ] && err 2 "dependency not met - ${missing_d#, }"
}

# container variables
[ $1 -eq 1 ] && WATCH=-w || unset WATCH
SUFFIX=$2
DATA="$3"
THEME="$4"
FILE="$5"
# script variables
groups=`groups`
uid=`id -u`
gid=`id -g`

# check prerequisites
dep dockerd docker

[ "${groups#*docker}" = "$groups" -a $uid -ne 0 ] \
  && err 1 'user is not in `docker` group.' || unset groups

[ -z `pidof dockerd` ] && err 1 'dockerd is not running.'

# download image
image=marpteam/marp-cli
if [ ! `docker inspect --type=image $image 1>/dev/null 2>&1` ]; then
  err 0 'image not found locally, trying docker pull...'
  docker pull -q $image 2>/dev/null || err 1 'docker pull fatal.'
fi

# TODO: pass config file as argument
# start container
docker run --rm --name marp-watch-pdf-$SUFFIX\
  -e MARP_USER=$uid:$gid\
  -v "$PWD":/home/marp/app -v "$DATA":/home/marp/data\
  $image --config-file /home/marp/data/marp.config.js\
  --theme /home/marp/data/"$THEME" $WATCH --pdf "$FILE" 1>/dev/null 2>&1

[ $? -ne 0 ] && err 1 'docker run fatal'

exit 0
