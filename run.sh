#!/usr/bin/env bash
# Run from the project root so Godot finds project.godot.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
GODOT=""
if command -v godot >/dev/null 2>&1; then
	GODOT="godot"
elif command -v godot4 >/dev/null 2>&1; then
	GODOT="godot4"
else
	echo "Godot 4.x not found. Install Godot and put it on PATH as 'godot' or 'godot4'." >&2
	exit 1
fi
exec "$GODOT" --path "$DIR" "$@"
