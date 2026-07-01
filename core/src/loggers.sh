log_run() {
  local tag

  case "$1" in
    -e) tag="[ERROR]" ;;
    -w) tag="[WARN]" ;;
    -i) tag="[INFO]" ;;
    *) tag="[INFO]" ;;
  esac

  echo "[$DATENOW] $tag $2" >> "$PKDR_ROOT/runtime/$3.log"
}