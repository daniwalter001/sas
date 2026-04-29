#!/bin/sh
# Bridge Koyeb's injected $PORT to stremio-service's hardcoded 11470.
# Port is hardcoded in the binary — no --port flag exists (issue #43 open since 2023).
#socat TCP-LISTEN:${PORT:-11470},fork,reuseaddr TCP:127.0.0.1:11470 &
RUST_LOG=info exec /usr/local/bin/stremio-service
