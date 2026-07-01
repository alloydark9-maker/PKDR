dispatch() {
  case "$1" in
    -v|--version)
      show_version
      ;;

    export)
      shift
      pkdr_export "$1" "$2"
      ;;
      
    import)
      shift
      pkdr_import "$1"
      ;;

    update)
      shift
      pkdr_update
      ;;

    uninstall)
      shift
      pkdr_uninstall
      ;;

    init)
      shift

      if [ "$1" = "-a" ]; then
        for f in "$MANIFEST"/*.json; do
          name=$(basename "$f" .json)
          init_env "$name"
        done
      else
        init_env "$1"
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

    remove)
      shift
      remove_pkg "$1" "$2"
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
}