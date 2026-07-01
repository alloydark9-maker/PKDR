init_env_bin() {
  local env="$1"
  local dir="$PKDR_ROOT/env/$env/bin"

  mkdir -p "$dir"
}

build_env_bin() {
  local env="$1"
  local file
  local dir
  local pkgs
  local pkg
  local path

  file=$(manifest_file "$env")
  dir="$PKDR_ROOT/runtime/env/$env/bin"

  rm -rf "$dir"
  mkdir -p "$dir"

  log_run -i "Built environment $env runtime" "history"

  pkgs=$(manifest_extract_packages "$file")

  for pkg in $pkgs; do
    path=$(command -v "$pkg")

    if [ -n "$path" ]; then
      ln -sf "$path" "$dir/$pkg"
    fi
  done
}

enter_env() {
  local env="$1"
  local file
  local runtime_path
  local env_path

  file=$(manifest_file "$env")

  if ! environment_exists "$env"; then
    echo "[PKDR] Environment not found: $env"
    log_run -e "Environment $env not found to enter" "history"
    exit 1
  fi

  echo "[PKDR] Building environment: $env"
  build_env_bin "$env"

  runtime_path="$PKDR_ROOT/runtime/dependencies"
  env_path="$PKDR_ROOT/runtime/env/$env/bin"
  init_state=$(manifest_init "$file" -val)
  
  echo "[PKDR] Entering environment"
  echo "[PKDR] Initialized: $init_state"
  if [ "$init_state" = "false" ]; then
    echo "[PKDR] Exit and use 'pkdr init $env'"
  fi
  echo "[PKDR] Available tools:"

  if [ -n "$PREFIX" ]; then
    "$PREFIX/bin/ls" "$env_path"
  else
    /bin/ls "$env_path"
  fi

  log_run -i "Entered environment $env" "history"

  echo "[PKDR] Type 'exit' to leave the environment"

  isolated_env "$env"

  log_run -i "Exited environment $env" "history"
}

init_env() {
  local env="$1"
  local file
  local pkgs

  if [ -z "$env" ]; then
    echo "[PKDR] Missing environment name."
    echo "        Hint: use 'pkdr init <env>' or 'pkdr init -a'"
    return 1
  fi

  file=$(manifest_file "$env")

  if ! environment_exists "$env"; then
    echo "[PKDR] Environment not found: $env"
    echo "        Hint: run 'pkdr add $env <pkg>'"
    return 1
  fi

  echo "[PKDR] Initializing environment: $env ..."

  pkgs=$(manifest_extract_packages "$file")

  if [[ -z "${pkgs// /}" ]]; then
    echo "[PKDR] No packages found to install."
    return 0
  fi

  echo "[PKDR] Packages: $pkgs"

  if pkg install -y $pkgs; then
    manifest_init "$file"
    echo "[PKDR] Initialized environment $env"
    log_run -i "Initialized environment $env" "history"
  else
    echo "[PKDR] Couldn't initialize environment $env"
    log_run -e "Error in initializing environment $env" "history"
    return 1
  fi
}

list_envs() {
  echo "[PKDR] Available environments:"

  if ! ls "$MANIFEST"/*.json >/dev/null 2>&1; then
    echo "None"
    echo "[PKDR] Use 'pkdr add <env>' to create one."
    return 0
  fi

  ls "$MANIFEST" | sed 's/.json//'
  echo "[PKDR] Use 'pkdr show <env>'"
}

show_env() {
  local env="$1"
  local file

  if [ -z "$env" ]; then
    echo "[PKDR] Missing environment name."
    echo "        Hint: use 'pkdr show <env>'"
    return 1
  fi

  file=$(manifest_file "$env")

  if ! environment_exists "$env"; then
    echo "[PKDR] Environment not found: $env"
    echo "        Hint: use 'pkdr add $env'"
    return 1
  fi

  echo "[PKDR] Environment: $env"
  echo "----------------------"

  manifest_extract_packages "$file"

  echo
  echo "[PKDR] Use 'pkdr enter $env' to enter"
}