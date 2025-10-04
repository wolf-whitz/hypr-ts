#!/bin/bash

SRC_FILE=$1
NODE_ID=$2
COMPILED_DIR=$3
TMP_CONF_DIR=$4
HYPR_CONF_DIR=$5

NODE_DIR="$COMPILED_DIR/.node"
mkdir -p "$NODE_DIR"
mkdir -p "$TMP_CONF_DIR"
mkdir -p "$(dirname "$HYPR_CONF_DIR")"

copy_and_patch() {
  local SRC=$1
  local DEST_DIR=$2
  local DEST="$DEST_DIR/$(basename "$SRC")"

  if [[ -f "$DEST" ]]; then
    return
  fi

  sed -E "s|from \"\.\./compiler/(.*)\.ts\"|from \"../../src/compiler/\1.ts\"|" "$SRC" > "$DEST"

  grep -oP '\.include\(\s*["'\'']\K[^"'\'']+(?=["'\'']\s*\))' "$SRC" | while read -r INC; do
    local FULL_INC=$(realpath "$(dirname "$SRC")/$INC")
    copy_and_patch "$FULL_INC" "$DEST_DIR"
  done
}

copy_and_patch "$SRC_FILE" "$NODE_DIR"

BASENAME=$(basename "$SRC_FILE")

echo "Compiling $SRC_FILE and all includes..."
npx ts-node --esm "$NODE_DIR/$BASENAME"
STATUS=$?
if [[ $STATUS -ne 0 ]]; then
  echo "Compilation failed!"
  exit $STATUS
fi

COMPILED_CONF="$TMP_CONF_DIR/hyprland_generated.conf"
HYPR_CONF="$HYPR_CONF_DIR"

node -e "
import { pathToFileURL } from 'url';
import fs from 'fs';

const mod = await import(pathToFileURL(process.argv[1]).href);

if ('hyprBindings' in mod) {
  const output =
    typeof mod.hyprBindings.compile === 'function'
      ? mod.hyprBindings.compile()
      : mod.hyprBindings;
  const marker = '\$compiled_$NODE_ID';
  const finalOutput = marker + '\n' + output;
  fs.writeFileSync('$COMPILED_CONF', finalOutput);

  const hyprConfContent = \`# Auto-generated Hyprland config
# Only includes compiled keybindings
source \"$COMPILED_CONF\"
exec-once echo 'Hyprland config loaded'
\`;
  fs.writeFileSync('$HYPR_CONF', hyprConfContent);

  console.log('Generated compiled conf at $COMPILED_CONF');
  console.log('Generated hyprland.conf at $HYPR_CONF');
}
" "$NODE_DIR/$BASENAME"

echo "Node folder created at $NODE_DIR"
