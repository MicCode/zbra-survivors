#!/bin/bash
set -e

VERSION="$1"
FILE="project.godot"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Error: $FILE not found"
  exit 1
fi

# Remplace la ligne config/version="..."
sed -i.bak -E "s/^config\/version=\"[^\"]*\"$/config\/version=\"$VERSION\"/" "$FILE"
rm -f "${FILE}.bak"
