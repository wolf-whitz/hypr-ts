#!/bin/sh

# Do not edit. This file is only a permission handler for compiler.sh.
# If you encounter any errors within this file, please contact the repository owner
# and provide details about your device.


TARGET_FILE="$1"
MANUAL_BUILD=${2:-false}

if [ ! -x "$TARGET_FILE" ]; then
  if [ "$MANUAL_BUILD" = "true" ]; then
    echo "Permission denied. Please manually run: chmod +x $TARGET_FILE"
    exit 1
  fi

  OS=$(uname -s)
  case "$OS" in
    Linux|Darwin)
      echo "Trying to chmod +x $TARGET_FILE ..."
      echo -n "Proceed? [y/N] "
      read CONFIRM
      case "$CONFIRM" in
        y|Y)
          chmod +x "$TARGET_FILE"
          ;;
        *)
          echo "Please manually run: chmod +x $TARGET_FILE"
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Permission denied. Ensure $TARGET_FILE is executable."
      exit 1
      ;;
  esac
fi
