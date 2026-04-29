# Stremio Service v0.1.21 — built for Koyeb deployment
# Koyeb injects $PORT; we forward it to stremio-service via --port flag
# If stremio-service does not support --port, replace entrypoint with socat bridge:
#   socat TCP-LISTEN:$PORT,fork TCP:127.0.0.1:11470
# Koyeb exposes HTTPS automatically — no TLS config needed here

FROM debian:bookworm-slim

ARG STREMIO_SERVICE_URL=https://dl.strem.io/stremio-service/v0.1.21/stremio-service_amd64.deb
ARG STREMIO_DEB=/tmp/stremio-service.deb

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates socat && \
    curl -fsSL "$STREMIO_SERVICE_URL" -o "$STREMIO_DEB" && \
    dpkg -i "$STREMIO_DEB" || apt-get install -f -y && \
    rm -f "$STREMIO_DEB" && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash stremio
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER stremio
WORKDIR /home/stremio

EXPOSE 11470

ENTRYPOINT ["/entrypoint.sh"]
