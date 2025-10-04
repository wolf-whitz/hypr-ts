#!/bin/bash

SRC_FILE=$1
NODE_ID=$2
COMPILED_DIR=$3
TMP_CONF_DIR=$4
HYPR_CONF_DIR=$5

log_info() { echo "[INFO] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

mkdir -p "$COMPILED_DIR" || { log_error "Failed to create $COMPILED_DIR"; exit 1; }
mkdir -p "$TMP_CONF_DIR" || { log_error "Failed to create $TMP_CONF_DIR"; exit 1; }
mkdir -p "$(dirname "$HYPR_CONF_DIR")" || { log_error "Failed to create directory for $HYPR_CONF_DIR"; exit 1; }

COPY_DIR="$COMPILED_DIR/.copy"
mkdir -p "$COPY_DIR" || { log_warn "Failed to create copy backup directory $COPY_DIR"; }

COPY_CONF="$COPY_DIR/hyprland_generated.conf"

BASENAME=$(basename "$SRC_FILE")

if [ -d "$COMPILED_DIR" ] && [ -f ".gitignore" ]; then
  if ! grep -qxF "$(basename "$COMPILED_DIR")/" .gitignore; then
    echo "$(basename "$COMPILED_DIR")/" >> .gitignore || log_warn "Could not append $COMPILED_DIR to .gitignore"
    log_info "Added $COMPILED_DIR to .gitignore"
  fi
fi

log_info "Compiling $SRC_FILE to .conf..."

node -e "
import { pathToFileURL } from 'url';
import fs from 'fs';

try {
  const mod = await import(pathToFileURL('$SRC_FILE').href);

  if (!('hyprBindings' in mod)) throw new Error('hyprBindings not exported in $SRC_FILE');

  const output =
    typeof mod.hyprBindings.compile === 'function'
      ? mod.hyprBindings.compile()
      : mod.hyprBindings;

  const marker = '\$compiled_$NODE_ID';
  const finalOutput = marker + '\n' + output;

  const compiledConf = '$TMP_CONF_DIR/hyprland_generated.conf';
  const copyConf = '$COPY_CONF';

  if (!fs.existsSync(copyConf)) fs.writeFileSync(copyConf, finalOutput);

  fs.writeFileSync(compiledConf, finalOutput);

  const hyprConfContent = \`# Auto-generated Hyprland config
# Includes compiled keybindings
source "\${compiledConf}"
exec-once echo 'Hyprland config loaded'
\`;
  fs.writeFileSync('$HYPR_CONF_DIR', hyprConfContent);

  console.log('[INFO] Generated compiled conf at', compiledConf);
  console.log('[INFO] Generated hyprland.conf at', '$HYPR_CONF_DIR');
  console.log('[INFO] Backup copy at', copyConf);

} catch (e) {
  console.error('[ERROR]', e.message);
  process.exit(1);
}
"

STATUS=$?
if [ $STATUS -ne 0 ]; then
  log_error "Node.js compilation failed for $SRC_FILE"
  exit $STATUS
fi

log_info "Done."
