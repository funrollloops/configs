#!/usr/bin/env bash

set -eufx -o pipefail

function save {
  local OUTPUT=${1:-/tmp/home.tar.zst.gpg}
  (
    cd ~ &&
    tar \
      --exclude Downloads \
      --exclude .local/share/Steam \
      --exclude .cache \
      --exclude .factorio \
      --exclude .rustup \
      -cf - .
  ) |
    zstd -10 -T0 |
    time gpg -o "$OUTPUT" -c
  ls -lh "$OUTPUT"
}

function restore {
  if [ ! -e "$1" ]; then
    echo "$1" does not exist
    return
  fi
  # Replace with xpf to extract.
  gpg -d "$1" | unzstd -T0 | time tar -tpf -
}


CMD=$1
shift
"$CMD" "$@"
