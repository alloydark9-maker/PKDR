#!/data/data/com.termux/files/usr/bin/bash

PKDR_ROOT="$HOME/PKDR"
MANIFEST="$PKDR_ROOT/manifests"
UTILS="$PKDR_ROOT/utils"
STATE="$PKDR_ROOT/state/log.txt"

show_help () {
  cat "$UTILS/help"
}
show_banner () {
  cat "$UTILS/banner"
}
show_version () {
  version=$(cat "$PKDR_ROOT/VERSION")
  echo "[PKDR] $version"
}
pkdr_remove () {
  while true; do
  read -p "This action will delete all your envs, are you sure to remove PKDR?(y/n): " yn
      case $yn in
          [Yy]*)
             echo "[PKDR] Removing pkdr..."
             $(rm -rf ~/PKDR)
             echo "[PKDR] Removed pkdr"
             break
             ;;
          [Nn]*)
             echo "[PKDR] Exiting..."
             return 1 # Use return instead of exit inside a function
             ;;
          *)
             echo "Please answer y or n."
             ;;
       esac
    done
}
pkdr_update () {
  echo "[PKDR] Updating pkdr..."

  # 1. Fallback to current directory if PKDR_ROOT is empty/unset
  local root_dir="${PKDR_ROOT:-$HOME/.pkdr}" 
  
  # 2. Safety Check: If it somehow still resolves to just '/', abort!
  if [ -z "$root_dir" ] || [ "$root_dir" = "/" ]; then
    echo "[PKDR] Error: Invalid PKDR_ROOT path!"
    return 1
  fi

  # 3. Clean up old core safely
  rm -rf "$root_dir/core"

  # 4. Copy and verify success before printing the success message
  if cp -r ./core "$root_dir/" && cp -r ./utils "$root_dir/"; then
    echo "[PKDR] Updated successfully"
  else
    echo "[PKDR] Update failed during file copy!"
    return 1
  fi
}

extract_packages () {
  file="$1"

  sed -n '/"packages"/,/\]/p' "$file" \
    | tr -d '",[]' \
    | grep -v 'packages:' \
    | tr '\n' ' '
}

allowed_commands () {
  extract_packages "$file"
}

init_env_bin () {
  env="$1"
  dir="$PKDR_ROOT/env/$env/bin"

  mkdir -p "$dir"
}

build_env_bin () {
  env="$1"
  file="$MANIFEST/$env.json"

  dir="$PKDR_ROOT/env/$env/bin"
  rm -rf "$dir"
  mkdir -p "$dir"

  pkgs=$(extract_packages "$file")

  for pkg in $pkgs; do
    path=$(command -v "$pkg")

    if [ -n "$path" ]; then
      ln -s "$path" "$dir/$pkg"
    fi
  done
}

enter_env () {
  env="$1"
  file="$MANIFEST/$env.json"

  if [ ! -f "$file" ]; then
    echo "[PKDR] Environment not found: $env"
    exit 1
  fi

  echo "[PKDR] Building environment: $env"

  build_env_bin "$env"

  ENV_PATH="$PKDR_ROOT/env/$env/bin"

  echo "[PKDR] Entering isolated environment"
  echo "[PKDR] Available tools:"
  ls "$ENV_PATH"
  echo "[PKDR] Type exit to leave the environment"

  bash --rcfile <(cat <<EOF
PS1='(pkdr:$env) \w \$ '

export PATH="$ENV_PATH"
export PKDR_ENV="$env"

unset command_not_found_handle

command_not_found_handle() {
  echo "[PKDR] Command not in environment: \$1"
  echo "[PKDR] Hint: use 'pkdr add $env \$1'"
  return 127
}

exit_env() {
  echo "[PKDR] Exiting environment: $PKDR_ENV"
  exit
}

clear_env() {
  printf '\e[H\e[2J\e[3J'
}

alias exit='exit_env'
alias clear='clear_env'
EOF
)
}

install_env () {
  file="$MANIFEST/$1.json"

  if [ ! -f "$file" ]; then
    echo "[PKDR] Environment not found: $1"
    exit 1
  fi

  echo "[PKDR] Installing environment: $1 ..."

  pkgs=$(extract_packages "$file")

  echo "[PKDR] Packages: $pkgs"

  pkg install -y $pkgs

  echo "[PKDR] Installed $1 at $(date)" >> "$STATE"
}

list_envs () {
  echo "[PKDR] Available environments:"
  ls "$MANIFEST" | sed 's/.json//'
}

show_env () {
  file="$MANIFEST/$1.json"

  if [ ! -f "$file" ]; then
    echo "[PKDR] Environment not found: $1"
    exit 1
  fi

  echo "[PKDR] Environment: $1"
  echo "----------------------"

  extract_packages "$file"
  echo ""
}

add_pkg () {
  local env="$1"
  local pkgname="$2"
  local file="$MANIFEST/$env.json"

  # 1. Handle missing environment file
  if [ ! -f "$file" ]; then
    echo "[PKDR] Environment '$env' not found"

    while true; do
      read -p "Would you like to create it? (y/n): " yn
      case $yn in
          [Yy]*)
             echo "[PKDR] Creating environment..."
             # Create a clean, valid empty JSON structure
             echo '{"name": "'"$env"'", "packages": []}' > "$file"
             echo "[PKDR] Environment $env created, view by 'pkdr list'"
             break
             ;;
          [Nn]*)
             echo "[PKDR] Exiting..."
             return 1 # Use return instead of exit inside a function
             ;;
          *)
             echo "Please answer y or n."
             ;;
       esac
    done
  fi

  # 2. Exit early if no package name was provided (FIXED SPACING)
  if [ -z "$pkgname" ]; then
    return 0
  fi

  # 3. Prompt to install or just record the package
  while true; do
      read -p "Would you like to install the package '$pkgname'? (y/n): " yn
      case $yn in
          [Yy]*)
             echo "[PKDR] Installing '$pkgname' for environment '$env' ..."
             output=$(pkg install -y "$pkgname" 2>&1)
             status=$?

             if [ $status -ne 0 ]; then
               echo "$output"
               echo "[PKDR] Install failed"
               return 1
             fi

             echo "[PKDR] Install successful"
             
             # Prevent duplicate manifest entries
             if grep -q "\"$pkgname\"" "$file"; then
               echo "[PKDR] Package already exists in manifest"
               return 0
             fi

             # Safely inject package into JSON using python/node or basic logic
             # This keeps your JSON syntactically valid without trailing commas
             if command -v node >/dev/null 2>&1; then
               node -e "const fs=require('fs'); const d=JSON.parse(fs.readFileSync('$file')); if(!d.packages.includes('$pkgname')){d.packages.push('$pkgname');} fs.writeFileSync('$file', JSON.stringify(d, null, 2));"
             elif command -v python3 >/dev/null 2>&1; then
               python3 -c "import json; f='$file'; d=json.load(open(f)); d['packages'].append('$pkgname') if '$pkgname' not in d['packages'] else None; json.dump(d, open(f, 'w'), indent=2)"
             else
               # Fallback crude sed string manipulation (might require tweaking based on OS)
               sed -i "s/\"packages\": \[\s*\]/\"packages\": [\"$pkgname\"]/g" "$file" 2>/dev/null || \
               sed -i "s/\"packages\": \[\s*/\"packages\": [\n    \"$pkgname\",/g" "$file"
             fi

             echo "[PKDR] Installed and Added '$pkgname' to $env"
             echo "[PKDR] Run 'pkdr show $env' to view"
             break
             ;;
          [Nn]*)
             if grep -q "\"$pkgname\"" "$file"; then
               echo "[PKDR] Package already exists in manifest"
               return 0
             fi
             # Fallback array append logic
             if command -v python3 >/dev/null 2>&1; then
               python3 -c "import json; f='$file'; d=json.load(open(f)); d['packages'].append('$pkgname'); json.dump(d, open(f, 'w'), indent=2)"
             else
               sed -i "s/\"packages\": \[\s*/\"packages\": [\n    \"$pkgname\",/g" "$file"
             fi
             echo "[PKDR] Added '$pkgname' to $env without installing"
             break
             ;;
          *)
             echo "Please answer y or n."
             ;;
      esac
  done
}


case "$1" in
  -v|--version)
    show_version
    ;;
  update)
    shift
    pkdr_update
    ;;
  remove)
    shift
    pkdr_remove
    ;;
  install)
    shift
    if [ "$1" = "-a" ]; then
      for f in "$MANIFEST"/*.json; do
        name=$(basename "$f" .json)
        install_env "$name"
      done
    else
      install_env "$1"
    fi
    ;;
  list)
    list_envs
    ;;
  show)
    shift
    show_env "$1"
    ;;
  add)
    shift
    add_pkg "$1" "$2"
    ;;
  enter)
    shift
    enter_env "$1"
    ;;
  --help)
    show_help
    ;;
   *)
    show_banner
    ;;
esac
