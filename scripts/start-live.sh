#!/bin/sh
set -eu

IMAGE_FILE="${IMAGE_FILE:-assets/background.png}"
AUDIO_FILE="${AUDIO_FILE:-assets/music.mp3}"
WIDTH="${WIDTH:-1920}"
HEIGHT="${HEIGHT:-1080}"
FPS="${FPS:-30}"
VIDEO_BITRATE="${VIDEO_BITRATE:-3500k}"
AUDIO_BITRATE="${AUDIO_BITRATE:-192k}"
DURATION_SECONDS="${DURATION_SECONDS:-}"

if [ -n "${FULL_RTMP_URL:-}" ]; then
  OUTPUT_URL="$FULL_RTMP_URL"
else
  if [ -z "${RTMP_URL:-}" ] || [ -z "${STREAM_KEY:-}" ]; then
    echo "Missing RTMP_URL/STREAM_KEY or FULL_RTMP_URL." >&2
    exit 2
  fi
  OUTPUT_URL="${RTMP_URL%/}/$STREAM_KEY"
fi

if [ ! -f "$IMAGE_FILE" ]; then
  echo "Image file not found: $IMAGE_FILE" >&2
  exit 2
fi

if [ ! -f "$AUDIO_FILE" ]; then
  echo "Audio file not found: $AUDIO_FILE" >&2
  exit 2
fi

GOP_SIZE=$((FPS * 2))
BUF_SIZE="${VIDEO_BITRATE%k}k"

echo "Starting livestream..."
echo "Image: $IMAGE_FILE"
echo "Audio: $AUDIO_FILE"
echo "Video: ${WIDTH}x${HEIGHT} ${FPS}fps ${VIDEO_BITRATE}"
if [ -n "$DURATION_SECONDS" ]; then
  echo "Duration: ${DURATION_SECONDS}s"
fi

set -- ffmpeg \
  -hide_banner \
  -loglevel info \
  -re \
  -loop 1 \
  -framerate "$FPS" \
  -i "$IMAGE_FILE" \
  -stream_loop -1 \
  -i "$AUDIO_FILE" \
  -vf "scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=decrease,pad=${WIDTH}:${HEIGHT}:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
  -c:v libx264 \
  -preset veryfast \
  -tune stillimage \
  -b:v "$VIDEO_BITRATE" \
  -maxrate "$VIDEO_BITRATE" \
  -bufsize "$BUF_SIZE" \
  -g "$GOP_SIZE" \
  -keyint_min "$GOP_SIZE" \
  -c:a aac \
  -b:a "$AUDIO_BITRATE" \
  -ar 48000 \
  -ac 2

if [ -n "$DURATION_SECONDS" ]; then
  set -- "$@" -t "$DURATION_SECONDS"
fi

exec "$@" -f flv "$OUTPUT_URL"
