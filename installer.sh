#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "[PKDR] Installing..."

PKDR_DIR="$HOME/PKDR"
BIN="$PREFIX/bin/pkdr"

MANIFESTS="$PKDR_DIR/manifests"
RUNTIME="$PKDR_DIR/runtime"

if [ -f "./VERSION" ]; then
    VERSION=$(cat "./VERSION")
else
    VERSION="unknown"
fi

mkdir -p "$PKDR_DIR"
mkdir -p "$MANIFESTS" "$RUNTIME" "$RUNTIME/env"
mkdir -p "$RUNTIME/dependencies"

cp -r ./core "$PKDR_DIR/"
cp -r ./utils "$PKDR_DIR/"
[ -f "./VERSION" ] && cp ./VERSION "$PKDR_DIR/"

if [ -z "$(ls -A "$MANIFESTS" 2>/dev/null)" ]; then
    compgen -G "./templates/*.json" > /dev/null && cp ./templates/*.json "$MANIFESTS" || echo "[PKDR] No templates found to copy."
fi


if ! command -v node >/dev/null 2>&1; then
    echo "[PKDR] Installing nodejs..."
    pkg install nodejs-lts -y
fi

echo "[PKDR] Installing runtime dependencies..."

while read -r tool || [ -n "$tool" ]; do
    [ -z "$tool" ] || [[ "$tool" =~ ^# ]] && continue
    if [ "$tool" = "pkdr" ]; then
        ln -sf "$BIN" "$RUNTIME/dependencies/pkdr"
    else
        path=$(command -v "$tool")
        if [ -n "$path" ]; then
            ln -sf "$path" "$RUNTIME/dependencies/$tool"
        else
            echo "[PKDR] Installing not present tool $tool" 
            pkg install $tool -y # Very fragile (will get fixed in v1.0.1)
        fi
    fi
done < ./utils/runtime-tools

mkdir -p "$PREFIX/bin"
cp bin/pkdr "$BIN"
chmod +x "$BIN"

echo "[PKDR] Installation complete.
[PKDR] Runtime: $HOME/PKDR
[PKDR] Command : pkdr
[PKDR] Start with: pkdr --help"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Installed PKDR $VERSION" >> "$RUNTIME/events.log"
