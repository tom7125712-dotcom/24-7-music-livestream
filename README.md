# 24/7 Music Livestream

Use one still image and one looping MP3 to run a 24-hour music livestream through any RTMP destination, such as YouTube Live, Twitch, Facebook Live, or a private RTMP server.

This project includes a GitHub Actions workflow for scheduled livestreaming.

## Project Files

- `assets/background.png` - the livestream image.
- `assets/music.mp3` - the looping music track.
- `scripts/start-live.sh` - starts one FFmpeg livestream session.
- `scripts/run-forever.sh` - restarts the stream if FFmpeg exits.
- `scripts/run-github-actions.sh` - reconnects FFmpeg inside one GitHub Actions run.
- `.github/workflows/livestream.yml` - runs the livestream from GitHub Actions.
- `.env.example` - copy this to `.env` and add your stream settings.
- `docker-compose.yml` - recommended 24/7 runner.

## GitHub Actions Setup

GitHub-hosted Actions jobs are time-limited, so the workflow streams in segments and starts again on a schedule.

1. Push this repository to GitHub.

2. Open the repository settings:

   `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`

3. Add either these two secrets:

   ```sh
   RTMP_URL=rtmp://a.rtmp.youtube.com/live2
   STREAM_KEY=your-stream-key
   ```

   Or add one full URL secret:

   ```sh
   FULL_RTMP_URL=rtmp://example.com/app/your-stream-key
   ```

4. Open `Actions` -> `24/7 Music Livestream` -> `Run workflow`.

5. The schedule runs at `00:17`, `05:17`, `10:17`, `15:17`, and `20:17` UTC. Each run streams up to 340 minutes, reconnects if FFmpeg exits early, and waits for the previous run instead of canceling it.

## Local Quick Start

1. Copy the environment file:

   ```sh
   cp .env.example .env
   ```

2. Edit `.env` and set your livestream target:

   ```sh
   RTMP_URL=rtmp://a.rtmp.youtube.com/live2
   STREAM_KEY=your-stream-key
   ```

3. Start the stream with Docker:

   ```sh
   docker compose up -d --build
   ```

4. Watch logs:

   ```sh
   docker compose logs -f livestream
   ```

5. Stop the stream:

   ```sh
   docker compose down
   ```

## Local FFmpeg Run

If FFmpeg is already installed on your computer:

```sh
cp .env.example .env
sh scripts/run-forever.sh
```

## Configuration

The defaults are tuned for a stable still-image music stream:

```sh
WIDTH=1920
HEIGHT=1080
FPS=30
VIDEO_BITRATE=3500k
AUDIO_BITRATE=192k
RESTART_DELAY=10
```

You can lower `VIDEO_BITRATE` to `2500k` if your upload bandwidth is limited.

## Notes For 24/7 Streaming

- Run this on a VPS or always-on computer, not GitHub Actions. GitHub Actions is not designed for continuous 24-hour livestreaming.
- Keep your `.env` file private. Never commit your stream key.
- For YouTube, create the livestream in YouTube Studio first, then copy the RTMP URL and stream key into `.env`.
- If the RTMP connection drops, `scripts/run-forever.sh` waits and starts it again.
