#!/data/data/com.termux/files/usr/bin/bash

echo "[PKDR] Installing..."

PKDR_DIR="$HOME/PKDR"
BIN="$PREFIX/bin/pkdr"

CORE="$PKDR_DIR/core"
UTILS="$PKDR_DIR/utils"
MANIFESTS="$PKDR_DIR/manifests"
STATE="$PKDR_DIR/state"
RUNTIME="$PKDR_DIR/runtime"

mkdir -p "$PKDR_DIR"
mkdir -p {"$MANIFESTS","$RUNTIME","$STATE"}

# clone or copy core
cp -r ./core "$PKDR_DIR/"
cp -r ./utils "$PKDR_DIR/"
cp -r ./VERSION "$PKDR_DIR/"
if [ -z "$(ls -A "$MANIFESTS" 2>/dev/null)" ]; then
    cp ./templates/*.json "$MANIFESTS"
fi

cat > "$BIN" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec bash "$HOME/PKDR/core/pkdr.sh" "$@"
EOF

chmod +x "$BIN"

echo "[PKDR] Installed successfully"
echo "[PKDR] Run: pkdr"
