environment_exists() {
  [ -f "$(manifest_file "$1")" ]
}

package_exists() {
  local file
  file=$(manifest_file "$1")

  grep -q "\"$2\"" "$file"
}

package_installed() {
  [ -e "$BIN/$1" ]
}

is_runtime_command() {
  case "$1" in
    pkdr|bash)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}