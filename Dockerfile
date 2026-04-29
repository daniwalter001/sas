# stremio-service — multi-stage build from source, targeting Koyeb deployment
# Build deps: libgtk-3-dev, libayatana-appindicator3-dev, libssl-dev (required by tao/tray crates)
# Runtime: same GTK/ayatana libs must be present — they are GUI libs but run without a display
# Port 11470 is HARDCODED in the binary. socat bridges Koyeb's $PORT to it.
# Koyeb terminates TLS — container serves plain HTTP, Koyeb URL exposes HTTPS.
# Clone with: git clone --recurse-submodules https://github.com/Stremio/stremio-service

FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    curl \
    ca-certificates \
    git \
    libgtk-3-dev \
    libssl-dev \
    libayatana-appindicator3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /build
RUN git clone --recurse-submodules https://github.com/Stremio/stremio-service .

RUN cargo build --release

FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk-3-0 \
    libayatana-appindicator3-1 \
    libssl3 \
    socat \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/sh stremio
COPY --from=builder /build/target/release/stremio-service /usr/local/bin/stremio-service
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER stremio
WORKDIR /home/stremio

EXPOSE 11470

ENTRYPOINT ["/entrypoint.sh"]
