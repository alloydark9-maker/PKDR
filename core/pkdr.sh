#!/data/data/com.termux/files/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/src"

SRC="$SCRIPT_DIR/src"

for module in \
    constants \
    loggers \
    helpers \
    utils \
    display \
    environment \
    transfer \
    commands \
    dispatch
do
    source "$SRC/$module.sh"
done

dispatch "$@"