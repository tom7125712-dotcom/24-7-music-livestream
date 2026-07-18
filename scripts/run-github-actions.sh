#!/bin/sh
set -eu

STREAM_MINUTES="${STREAM_MINUTES:-350}"
RESTART_DELAY="${RESTART_DELAY:-15}"
MIN_REMAINING_SECONDS="${MIN_REMAINING_SECONDS:-30}"

case "$STREAM_MINUTES" in
  ''|*[!0-9]*)
    echo "STREAM_MINUTES must be a positive integer." >&2
    exit 2
    ;;
esac

if [ "$STREAM_MINUTES" -le 0 ]; then
  echo "STREAM_MINUTES must be greater than zero." >&2
  exit 2
fi

END_AT=$(( $(date +%s) + STREAM_MINUTES * 60 ))

echo "GitHub Actions livestream window: ${STREAM_MINUTES} minutes"

while :; do
  NOW=$(date +%s)
  REMAINING=$((END_AT - NOW))

  if [ "$REMAINING" -le "$MIN_REMAINING_SECONDS" ]; then
    echo "Livestream window finished."
    exit 0
  fi

  export DURATION_SECONDS="$REMAINING"
  echo "Starting FFmpeg. Remaining window: ${DURATION_SECONDS}s"

  set +e
  sh scripts/start-live.sh
  STATUS=$?
  set -e

  NOW=$(date +%s)
  if [ "$NOW" -ge "$END_AT" ]; then
    echo "Livestream window finished after FFmpeg exit."
    exit 0
  fi

  echo "FFmpeg exited with status $STATUS. Reconnecting in ${RESTART_DELAY}s..." >&2
  sleep "$RESTART_DELAY"
done

