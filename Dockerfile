FROM alpine:3.20

RUN apk add --no-cache ffmpeg shfmt

WORKDIR /app

COPY . .

RUN chmod +x scripts/*.sh

CMD ["sh", "scripts/run-forever.sh"]

