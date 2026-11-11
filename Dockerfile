
FROM gosom/google-maps-scraper:v1.18.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY render/nginx.conf.template /etc/nginx/templates/scraper.conf.template
COPY render/start.sh /usr/local/bin/start-render.sh

RUN chmod +x /usr/local/bin/start-render.sh

ENV PORT=10000
EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/start-render.sh"]
