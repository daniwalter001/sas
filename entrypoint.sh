#!/bin/sh
# Bridge Koyeb's injected $PORT to stremio-service's hardcoded 11470.
# Port is hardcoded in the binary — no --port flag exists (issue #43 open since 2023).
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
# Then run your command
socat TCP-LISTEN:${PORT:-11470},fork,reuseaddr TCP:127.0.0.1:11470 &
RUST_LOG=info exec /usr/local/bin/stremio-service
