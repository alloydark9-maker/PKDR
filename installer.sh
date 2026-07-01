#!/data/data/com.termux/files/usr/bin/bash

echo "[PKDR] Installing..."

PKDR_DIR="$HOME/PKDR"
BIN="$PREFIX/bin/pkdr"

MANIFESTS="$PKDR_DIR/manifests"
RUNTIME="$PKDR_DIR/runtime"
DEPS="$RUNTIME/dependencies"

mkdir -p "$PKDR_DIR" "$MANIFESTS" "$RUNTIME/env" "$DEPS"

cp -r ./core "$PKDR_DIR/"
cp -r ./utils "$PKDR_DIR/"
[ -f "./VERSION" ] && cp ./VERSION "$PKDR_DIR/"

if ! command -v node >/dev/null 2>&1; then
    echo "[PKDR] Installing nodejs..."
    pkg install nodejs-lts -y || {
        echo "[PKDR] Node install failed"
        exit 1
    }
fi

echo "[PKDR] Installing runtime dependencies..."

while read -r tool || [ -n "$tool" ]; do
    [ -z "$tool" ] || [[ "$tool" =~ ^# ]] && continue

    if [[ "$tool" == system:* ]]; then
        name="${tool#system:}"
        path=$(command -v "$name")

        if [ -n "$path" ]; then
            ln -sf "$path" "$DEPS/$name"
            echo "[PKDR] system linked: $name"
        else
            echo "[PKDR] missing system tool: $name"
        fi
        continue
    fi

    if [ "$tool" = "pkdr" ]; then
        ln -sf "$BIN" "$DEPS/pkdr"
        echo "[PKDR] linked pkdr"
        continue
    fi

    if command -v "$tool" >/dev/null 2>&1; then
        ln -sf "$(command -v "$tool")" "$DEPS/$tool"
        echo "[PKDR] linked: $tool"
    else
        echo "[PKDR] installing package: $tool"
        pkg install "$tool" -y || echo "[PKDR] failed: $tool"
    fi

done < ./utils/runtime-tools

mkdir -p "$PREFIX/bin"
cp bin/pkdr "$BIN"
chmod +x "$BIN"

echo "[PKDR] Installation complete"
echo "[PKDR] Run: pkdr"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installed PKDR" >> "$RUNTIME/events.log"