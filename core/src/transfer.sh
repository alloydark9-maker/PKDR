pkdr_export() {
    local target="$2"
    local temp="$PKDR_ROOT/runtime/export"

    [ -z "$target" ] && {
        echo "[PKDR] Missing export path."
        return 1
    }

    rm -rf "$temp"
    mkdir -p "$temp/manifests"

    if [ "$1" = "-a" ]; then

        cp -r "$MANIFEST"/. "$temp/manifests/" || return 1

        for file in "$temp"/manifests/*.json; do
            manifest_export_prepare "$file"
        done

        manifest_export_json "$temp/manifests" "$temp" || return 1

        tar -czf "$target/manifest.pkdr" -C "$temp" . || return 1

        echo "[PKDR] All environments exported successfully."
        log_run -i "All environments exported" "events"

    else

        local file

        file=$(manifest_file "$1")

        if [ ! -f "$file" ]; then
            echo "[PKDR] Environment '$1' not found."
            log_run -e "Environment not found to export"
            rm -rf "$temp"
            return 1
        fi

        cp "$file" "$temp/manifests/" || return 1

        manifest_export_prepare "$temp/manifests/$1.json"

        manifest_export_json "$temp/manifests" "$temp" || return 1

        tar -czf "$target/$1.pkdr" -C "$temp" . || return 1

        echo "[PKDR] $1 exported successfully."
        log_run -i "$1 exported" "events"
    fi

    rm -rf "$temp"
}

pkdr_import() {
  local archive="$1"
  local temp="$PKDR_ROOT/runtime/import"

  if [ ! -f "$archive" ]; then
    echo "[PKDR] Archive not found."
    return 1
  fi

  rm -rf "$temp"
  mkdir -p "$temp"

  if ! tar -xzf "$archive" -C "$temp"; then
    echo "[PKDR] Invalid archive."
    rm -rf "$temp"
    return 1
  fi

  if [ ! -f "$temp/pkdr.json" ] || [ ! -d "$temp/manifests" ]; then
    echo "[PKDR] Invalid PKDR archive."
    rm -rf "$temp"
    return 1
  fi

  manifest_import_info "$temp/pkdr.json"

  local mode="merge"

  if ls "$temp/manifests"/*.json >/dev/null 2>&1; then
    for file in "$temp"/manifests/*.json; do
      env=$(basename "$file" .json)

      if [ -f "$MANIFEST/$env.json" ]; then
        while true; do
          echo
          echo "[PKDR] Existing environments detected."
          read -p "[M] Merge  [R] Replace  [S] Skip : " ans

          case "$ans" in
            [Mm]*) mode="merge"; break ;;
            [Rr]*) mode="replace"; break ;;
            [Ss]*) mode="skip"; break ;;
            *) echo "[PKDR] Invalid option." ;;
          esac
        done

        break
      fi
    done
  fi

  for file in "$temp"/manifests/*.json; do

    env=$(basename "$file")

    if [ ! -f "$MANIFEST/$env" ]; then
      cp "$file" "$MANIFEST/"
      continue
    fi

    case "$mode" in

      merge)
        manifest_merge "$MANIFEST/$env" "$file"
        ;;

      replace)
        cp "$file" "$MANIFEST/$env"
        ;;

      skip)
        ;;
    esac

  done

  rm -rf "$temp"

  echo "[PKDR] Import completed."
  log_run -i "Imported PKDR manifest" "events"
}

add_pkg() {
  local env="$1"
  local pkgname="$2"
  local file

  if [ -z "$env" ]; then
    echo "[PKDR] Provide environment name 'pkdr add <env>'"
    return 1
  fi

  file=$(manifest_file "$env")

  if is_runtime_command "$pkgname"; then
    echo "[PKDR] '$pkgname' is a runtime command."
    echo "[PKDR] It is available automatically in every environment."
    return 0
  fi

  if ! environment_exists "$env"; then
    echo "[PKDR] Environment '$env' not found"

    while true; do
      read -p "Would you like to create it? (y/n): " yn

      case $yn in
        [Yy]*)
          echo "[PKDR] Creating environment..."
          echo '{"name":"'"$env"'","packages":[]}' > "$file"
          echo "[PKDR] Environment $env created, view by 'pkdr list'"
          log_run -i "Environment $env created" "history"
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
  fi

  [ -z "$pkgname" ] && return 0

  if package_exists "$env" "$pkgname"; then
    echo "[PKDR] Package already exists in $env"
    log_run -w "Package $pkgname already exists in $env" "history"
    return 0
  fi

  if package_installed "$pkgname"; then
    echo "[PKDR] Package is already installed in termux"
    log_run -w "Package $pkgname is already installed in termux" "history"
  else
    while true; do
      read -p "Would you like to install the package '$pkgname'? (y/n): " yn

      case $yn in
        [Yy]*)
          echo "[PKDR] Installing '$pkgname' for '$env' ..."
          log_run -i "Installing $pkgname for $env" "history"

          output=$(pkg install -y "$pkgname" 2>&1)
          status=$?

          if [ $status -ne 0 ]; then
            echo "$output"
            echo "[PKDR] Install failed"
            log_run -e "$pkgname installation failed for $env" "history"
            return 1
          fi

          echo "[PKDR] Install successful"
          log_run -i "Installed package: $pkgname" "history"
          break
          ;;
        [Nn]*)
          break
          ;;
        *)
          echo "Please answer y or n."
          ;;
      esac
    done
  fi

  manifest_add_package "$file" "$pkgname"

  echo "[PKDR] Added '$pkgname' to $env"
  echo "[PKDR] Run 'pkdr show $env' to view"

  log_run -i "Added package: $pkgname to $env" "history"

  if [ -n "$PKDR_ENV" ]; then
    echo "[PKDR] Rebuilding environment: $env"
    build_env_bin "$PKDR_ENV"
    echo "[PKDR] Environment rebuilt."
    echo "[PKDR] Restart the environment to use new commands."
    echo "[PKDR] Hint: exit and use 'pkdr enter $env'"
  fi
}

remove_pkg() {
  local env="$1"
  local pkgname="$2"
  local file

  file=$(manifest_file "$env")

  if [ -z "$env" ] && [ -z "$pkgname" ]; then
    echo "[PKDR] Include environment & package name to remove"
    log_run -e "No environment and package name was provided to remove" "history"

  elif [ -z "$pkgname" ]; then

    if rm -f "$file"; then
      echo -e "[PKDR] Removed environment $env\n[PKDR] Use 'pkdr list' to view"
      log_run -i "Removed environment $env" "history"
    else
      echo "[PKDR] Couldn't remove environment $env"
      log_run -e "Error removing environment $env" "history"
    fi

  elif ! environment_exists "$env"; then

    echo "[PKDR] Environment '$env' not found to remove $pkgname"
    log_run -e "Environment '$env' not found to remove $pkgname" "history"

  else

    if ! package_exists "$env" "$pkgname"; then
      echo -e "[PKDR] Package does not exist in $env\n[PKDR] Use 'pkdr show $env' to view"
      log_run -e "Package $pkgname does not exist in $env" "history"
      return 0
    fi

    if manifest_remove_package "$file" "$pkgname"; then
      echo "[PKDR] Package $pkgname removed from $env"
      log_run -i "Package $pkgname removed from $env" "history"
    else
      echo "[PKDR] Couldn't remove $pkgname from $env"
      log_run -e "Error removing $pkgname from $env" "history"
    fi
  fi
}