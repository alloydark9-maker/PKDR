pkdr_uninstall() {
  while true; do
    read -p "[PKDR] This will permanently remove:
  • All PKDR environments
  • All manifests
  • Runtime logs
  • PKDR itself

Continue? (y/n):" yn

    case $yn in
      [Yy]*)
        echo "[PKDR] Uninstalling pkdr..."

        if rm -rf "$HOME/PKDR" && rm -f "$PREFIX/bin/pkdr"; then
          echo "[PKDR] Uninstalled PKDR successfully"
        else
          echo "[PKDR] Failed to uninstall completely"
          return 1
        fi

        break
        ;;

      [Nn]*)
        echo "[PKDR] Exiting..."
        return 1
        ;;

      *)
        echo "Please answer y or n."
        ;;
    esac
  done
}

pkdr_update() {
  echo "[PKDR] Updating pkdr..."

  local temp="$PKDR_ROOT/runtime/update"
  local repo="https://github.com/alloydark9-maker/PKDR.git"

  rm -rf "$temp"

  if ! git clone --depth 1 "$repo" "$temp"; then
    echo "[PKDR] Failed to fetch latest version."
    log_run -e "Failed to fetch latest PKDR version" "events"
    return 1
  fi

  if cp -r "$temp/core" "$PKDR_ROOT/" &&
     cp -r "$temp/utils" "$PKDR_ROOT/" &&
     cp "$temp/VERSION" "$PKDR_ROOT/"; then

    echo "[PKDR] Updated successfully to $(cat "$PKDR_ROOT/VERSION")"
    log_run -i "PKDR updated successfully" "events"

  else
    echo "[PKDR] Update failed."
    log_run -e "Failed while replacing PKDR files" "events"

    rm -rf "$temp"
    return 1
  fi

  rm -rf "$temp"
}

