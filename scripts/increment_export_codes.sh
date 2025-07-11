#!/bin/bash
set -e

FILE="export_presets.cfg"

if [[ ! -f "$FILE" ]]; then
  echo "Error: $FILE not found"
  exit 1
fi

# Utilisation awk pour incrémenter tous les version/code=X
awk '
  /^version\/code=[0-9]+$/ {
    split($0, a, "=")
    printf("version/code=%d\n", a[2] + 1)
    next
  }
  { print }
' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"
