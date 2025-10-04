#!/bin/sh

clear
cat <<'EOF'
========================================================
                 Hypr-TS Compiler Help
========================================================

USAGE:
  ./main.sh [OPTIONS]

OPTIONS:
  -manual
      Skip automatic chmod for hyprland.compiler.sh.
      You must manually make it executable if needed.

  -output DIR
      Override the default compileds folder.
      Default: ./compileds

  -tmp_conf_dir DIR
      Override the temporary compiled conf directory.
      Default: same as output folder.

  -hypr_conf_dir FILE
      Override the final hyprland.conf file path.
      Default: ./compileds/hyprland.conf

  -src_dic DIR
      Override the source directory for TS files.
      Default: ./src

  -recover
      Recover all .conf files from backup copies in .copy folder.

  -h, --help
      Show this help message and exit.

--------------------------------------------------------
COMPILER BEHAVIOR:

  - Scans the source directory for .ts files (excluding compiler folder)
  - Builds a tree for user selection
  - Copies selected file and all .include() files if needed
  - Adds a marker $compiled_{node_id} to prevent recompilation
  - Generates hyprland_generated.conf in the output folder
  - Generates hyprland.conf pointing to the compiled config
  - Creates a backup copy in .copy folder
  - Supports reloading Hyprland automatically

--------------------------------------------------------
EXAMPLES:

  # Compile and run the example.keybinds.ts
  ./main.sh

  # Override output folder
  ./main.sh -output ./my_builds

  # Manual build if chmod fails
  ./main.sh -manual

  # Override temp conf and final conf locations
  ./main.sh -tmp_conf_dir ./tmp -hypr_conf_dir ./hyprland.conf

  # Use custom source directory
  ./main.sh -src_dic ./my_ts_src

  # Recover from backup copies
  ./main.sh -recover

EOF

echo
echo "Press ENTER to exit help..."
read _
clear
