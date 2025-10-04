#!/bin/sh

SRC_DIR="./src"
NODE_ROOT="./compileds"
MANUAL_BUILD=false
TMP_CONF_DIR="$NODE_ROOT"
HYPR_CONF_DIR="$NODE_ROOT/hyprland.conf"

safe_run() {
  SCRIPT="$1"
  shift
  if [ ! -x "$SCRIPT" ]; then
    echo "Permission denied for $SCRIPT. Trying to chmod +x ..."
    OS=$(uname -s)
    case "$OS" in
      Linux|Darwin)
        chmod +x "$SCRIPT" || {
          echo "Failed to chmod $SCRIPT. Use -manual to handle manually."
          exit 1
        }
        ;;
      *)
        echo "Cannot auto-chmod $SCRIPT on this OS. Use -manual."
        exit 1
        ;;
    esac
  fi
  "$SCRIPT" "$@"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -manual)
      MANUAL_BUILD=true
      shift
      ;;
    -output)
      NODE_ROOT="$2"
      TMP_CONF_DIR="$NODE_ROOT"
      HYPR_CONF_DIR="$NODE_ROOT/hyprland.conf"
      shift 2
      ;;
    -tmp_conf_dir)
      TMP_CONF_DIR="$2"
      shift 2
      ;;
    -hypr_conf_dir)
      HYPR_CONF_DIR="$2"
      shift 2
      ;;
    -src_dic)
      SRC_DIR="$2"
      shift 2
      ;;
    -h|-man|--help)
      safe_run ./help.menu.sh
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      safe_run ./help.menu.sh
      exit 1
      ;;
  esac
done

INDEX=1
FILES=""
TREE=""

mkdir -p "$NODE_ROOT"

build_tree() {
  DIR="$1"
  PREFIX="$2"
  for FILE in "$DIR"/*; do
    if [ -d "$FILE" ]; then
      case "$FILE" in
        "$SRC_DIR/compiler") continue ;;
      esac
      build_tree "$FILE" "$PREFIX  "
    else
      case "$FILE" in
        *.ts)
          FILES="$FILES $FILE"
          TREE="$TREE$PREFIX$INDEX) $(realpath --relative-to=$SRC_DIR "$FILE")\n"
          INDEX=$((INDEX + 1))
          ;;
      esac
    fi
  done
}

build_tree "$SRC_DIR" ""

if [ -z "$FILES" ]; then
  echo "No .ts files found in src."
  exit 1
fi

printf "$TREE"
echo
echo -n "Select a file to compile & run: "
read CHOICE

i=1
for f in $FILES; do
  if [ "$i" -eq "$CHOICE" ]; then
    FILE="$f"
    break
  fi
  i=$((i+1))
done

if [ -z "$FILE" ]; then
  echo "Invalid selection"
  exit 1
fi

NODE_ID=$(date +%s)

safe_run ./hyprland.compiler.sh "$FILE" "$NODE_ID" "$NODE_ROOT" "$TMP_CONF_DIR" "$HYPR_CONF_DIR" "$SRC_DIR"

echo -n "Reload Hyprland with this config? [y/N] "
read RELOAD
case "$RELOAD" in
  y|Y)
    cp "$HYPR_CONF" ~/.config/hypr/hyprland.conf
    hyprctl reload
    echo "Hyprland reloaded."
    ;;
esac

echo "Done."
