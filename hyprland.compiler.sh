#!/bin/bash

SRC_FILE=$1
NODE_ID=$2
COMPILED_DIR=$3
TMP_CONF_DIR=$4
HYPR_CONF_DIR=$5

if [ "$1" = "-recover-hyprland" ]; then
  if [ -d "$COMPILED_DIR/.copy.hyprland" ]; then
    mkdir -p "$HOME/.config/hypr"
    cp -r "$COMPILED_DIR/.copy.hyprland/"* "$HOME/.config/hypr/"
    echo "Restored Hyprland config from .copy.hyprland"
  else
    echo "No .copy.hyprland found"
  fi
  exit 0
fi

mkdir -p "$COMPILED_DIR" "$TMP_CONF_DIR" "$(dirname "$HYPR_CONF_DIR")"

COPY_DIR="$COMPILED_DIR/.copy"
mkdir -p "$COPY_DIR"
COPY_CONF="$COPY_DIR/hyprland_generated.conf"

SNAPSHOT_DIR="$COMPILED_DIR/.copy.hyprland"
if [ -d "$HOME/.config/hypr" ]; then
  mkdir -p "$SNAPSHOT_DIR"
  cp -r "$HOME/.config/hypr/"* "$SNAPSHOT_DIR/" 2>/dev/null
fi

if [ -d "$COMPILED_DIR" ] && [ -f ".gitignore" ]; then
  if ! grep -qxF "$(basename "$COMPILED_DIR")/" .gitignore; then
    echo "$(basename "$COMPILED_DIR")/" >> .gitignore
  fi
fi

BASENAME=$(basename "$SRC_FILE")

node -e "
import { pathToFileURL } from 'url';
import fs from 'fs';

const mod = await import(pathToFileURL('$SRC_FILE').href);
if (!('hyprBindings' in mod)) throw new Error('hyprBindings not exported');

const output = typeof mod.hyprBindings.compile === 'function'
  ? mod.hyprBindings.compile()
  : mod.hyprBindings;

const marker = '\$compiled_$NODE_ID';
const finalOutput = marker + '\n' + output;

const compiledConf = '$TMP_CONF_DIR/hyprland_generated.conf';
const copyConf = '$COPY_CONF';
fs.mkdirSync('$COPY_DIR', { recursive: true });
if (!fs.existsSync(copyConf)) fs.writeFileSync(copyConf, finalOutput);
fs.writeFileSync(compiledConf, finalOutput);

const hyprConfContent = \`# Auto-generated Hyprland config
source "\${compiledConf}"
exec-once echo 'Hyprland config loaded'
\`;
fs.writeFileSync('$HYPR_CONF_DIR', hyprConfContent);

console.log('Generated compiled conf at', compiledConf);
console.log('Generated hyprland.conf at', '$HYPR_CONF_DIR');
console.log('Backup copy at', copyConf);
"

echo "Done."
