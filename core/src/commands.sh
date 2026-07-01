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

  local root_dir="${PKDR_ROOT:-$HOME/.pkdr}"

  if [ -z "$root_dir" ] || [ "$root_dir" = "/" ]; then
    echo "[PKDR] Error: Invalid PKDR_ROOT path!"
    log_run -e "Failed to update PKDR to $VERSION" "events"
    return 1
  fi

  rm -rf "$root_dir/core"

  if cp -r ./core "$root_dir/" && cp -r ./utils "$root_dir/" && cp ./VERSION "$root_dir/"; then
    echo "[PKDR] Updated successfully to $VERSION"
    log_run -i "PKDR updated to latest version $VERSION" "events"
  else
    echo "[PKDR] Update failed during file copy!"
    return 1
  fi
}
