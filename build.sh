#!/bin/bash

# Pete's AC Adventure - Build Script
# Exports the game for iOS

PROJECT_DIR="$HOME/.hermes/games/petes-ac-adventure"
OUTPUT_DIR="$PROJECT_DIR/export/release"

echo "========================================"
echo "  Building Pete's AC Adventure"
echo "========================================"
echo ""

cd "$PROJECT_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check for Godot
if ! command -v godot &> /dev/null; then
    echo "❌ Godot not found!"
    echo "   Please install Godot or run manually:"
    echo "   godot --export-release \"iOS\" \"$OUTPUT_DIR/petes-ac-adventure.ipa\""
    exit 1
fi

echo "📦 Exporting for iOS..."
echo "   Path: $OUTPUT_DIR"
echo ""

# Build command (will run in background or require manual execution)
echo "Run this command to export:"
echo ""
echo "  godot --headless --path . --export-release \"iOS\" $OUTPUT_DIR/petes-ac-adventure.ipa"
echo ""
echo "Or open Godot and use: Project → Export → iOS"
echo ""

# List what was built
echo "📁 Project ready at: $PROJECT_DIR"
ls -la "$PROJECT_DIR" | head -10

echo ""
echo "✅ Build script complete!"
