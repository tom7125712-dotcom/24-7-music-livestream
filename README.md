# 24/7 Music Livestream

Use one still image and one looping MP3 to run a 24-hour music livestream through any RTMP destination, such as YouTube Live, Twitch, Facebook Live, or a private RTMP server.

This project includes a short GitHub Actions smoke test and a self-hosted service deploy workflow.

## Project Files

- `assets/background.png` - the livestream image.
- `assets/music.mp3` - the looping music track.
- `scripts/start-live.sh` - starts one FFmpeg livestream session.
- `scripts/run-forever.sh` - restarts the stream if FFmpeg exits.
- `scripts/run-github-actions.sh` - reconnects FFmpeg inside one short GitHub Actions test run.
- `scripts/install-systemd-user-service.sh` - installs the stream as a restartable Linux user service.
- `.github/workflows/livestream.yml` - manually tests the stream for a short window.
- `.github/workflows/deploy-self-hosted.yml` - installs or restarts the 24/7 service on a self-hosted runner.
- `.env.example` - copy this to `.env` and add your stream settings.
- `docker-compose.yml` - recommended 24/7 runner.

## GitHub Actions Smoke Test

GitHub-hosted Actions jobs are not reliable for 24/7 livestreaming. Use this workflow only for a short test that verifies the image, audio, FFmpeg command, and RTMP secrets.

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

4. Open `Actions` -> `Manual Livestream Smoke Test` -> `Run workflow`.

5. Keep the default `30` minutes unless you only need a shorter test.

## 24/7 Self-hosted Service

For a real 24/7 livestream, run the stream on a VPS or an always-on computer. GitHub Actions should install or restart that service, then exit.

1. Add a Linux self-hosted runner to this repository.

2. Add the same `RTMP_URL` and `STREAM_KEY` secrets in GitHub.

3. Open `Actions` -> `Deploy 24/7 Livestream Service` -> `Run workflow`.

4. The workflow writes a private `.env` file on the self-hosted runner and installs a `music-livestream` systemd user service.

5. Check the service on the runner:

   ```sh
   systemctl --user status music-livestream
   journalctl --user -u music-livestream -f
   ```

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
- The GitHub-hosted smoke test is intentionally manual-only, so it will not create overlapping scheduled runs.
- Keep your `.env` file private. Never commit your stream key.
- For YouTube, create the livestream in YouTube Studio first, then copy the RTMP URL and stream key into `.env`.
- If the RTMP connection drops, `scripts/run-forever.sh` waits and starts it again.
