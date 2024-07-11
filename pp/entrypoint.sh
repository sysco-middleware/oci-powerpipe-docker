#!/usr/bin/env bash
set -Eeo pipefail
# copy bundled files to writeable location
SRC_DIR="$HOME/.powerpipe"
RUN_DIR="$HOME/run/.powerpipe"
POWERPIPE_INSTALL_DIR="${RUN_DIR}"
mkdir -p "${HOME}/run"
cp -a "${SRC_DIR}" "${RUN_DIR}"
exec "$@"