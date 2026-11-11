#!/bin/sh
set -eu

: "${SCRAPER_API_KEY:?SCRAPER_API_KEY is required}"

case "$SCRAPER_API_KEY" in
  *[!a-fA-F0-9]*|"")
    echo "SCRAPER_API_KEY must be hexadecimal" >&2
    exit 1
    ;;
esac

if [ "${#SCRAPER_API_KEY}" -ne 64 ]; then
  echo "SCRAPER_API_KEY must contain 64 characters" >&2
  exit 1
fi


mkdir -p /gmapsdata /run/nginx

google-maps-scraper -web -addr 127.0.0.1:8080 -data-folder /gmapsdata &
SCRAPER_PID=$!

envsubst '${PORT} ${SCRAPER_API_KEY}' \
  < /etc/nginx/templates/scraper.conf.template \
  > /etc/nginx/conf.d/default.conf

nginx -t
nginx -g 'daemon off;' &
NGINX_PID=$!

trap 'kill "$SCRAPER_PID" "$NGINX_PID" 2>/dev/null || true' TERM INT

wait "$SCRAPER_PID" "$NGINX_PID"
