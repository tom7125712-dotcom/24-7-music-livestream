#!/bin/sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

RESTART_DELAY="${RESTART_DELAY:-10}"

while :; do
  set +e
  sh scripts/start-live.sh
  status=$?
  set -e
  echo "Livestream exited with status $status. Restarting in ${RESTART_DELAY}s..." >&2
  sleep "$RESTART_DELAY"
done
