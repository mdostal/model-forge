#!/usr/bin/env bash
# Installs lib/model-forge into OpenSCAD's user library folder, the same
# way BOSL2/MCAD are installed — so `use <model-forge/panel.scad>` (and
# future model-forge modules) resolve from ANY .scad file you write by
# hand, not just this repo's own render pipeline (which sets OPENSCADPATH
# itself and doesn't need this step).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_SRC="$REPO_ROOT/lib/model-forge"
LIB_DEST="$HOME/Documents/OpenSCAD/libraries/model-forge"

mkdir -p "$(dirname "$LIB_DEST")"

if [ -L "$LIB_DEST" ]; then
  echo "Already linked: $LIB_DEST -> $(readlink "$LIB_DEST")"
elif [ -e "$LIB_DEST" ]; then
  echo "Refusing to overwrite existing non-symlink at $LIB_DEST" >&2
  exit 1
else
  ln -s "$LIB_SRC" "$LIB_DEST"
  echo "Linked $LIB_DEST -> $LIB_SRC"
fi

echo "Verify in OpenSCAD: Help > Library Info should list this under User Library Path."
