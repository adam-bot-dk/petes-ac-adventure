#!/bin/bash

# Pete's AC Adventure - Quick Start Script
# This script checks setup and prepares the project

echo "========================================"
echo "  Pete's AC Adventure - Quick Setup"
echo "========================================"
echo ""

# Project path
PROJECT_DIR="$HOME/.hermes/games/petes-ac-adventure"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project directory not found!"
    echo "   Expected at: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Check for Godot
if command -v godot &> /dev/null; then
    echo "✅ Godot found"
    GODOT_CMD="godot"
else
    echo "⚠️  Godot CLI not found"
    echo "   Please install Godot or use the GUI"
    GODOT_CMD=""
fi

echo ""
echo "📁 Project Structure:"
echo "---------------------"
tree -L 2 --dirsfirst -I 'assets|audio' 2>/dev/null || \
    find . -maxdepth 2 -type d ! -path '*/.*' | head -20

echo ""
echo "📄 Key Files:"
echo "-------------"
echo "  - project.godot       (Project configuration)"
echo "  - README.md           (Full documentation)"
echo "  - GAME_DESIGN.md      (Game design document)"
echo "  - scenes/main/Main.tscn (Main game scene)"
echo "  - scenes/managers/GameManager.gd (Game state)"

echo ""
echo "🎮 Next Steps:"
echo "--------------"
echo "1. Open project in Godot Editor:"
echo "   $ $GODOT_CMD --path $PROJECT_DIR"
echo ""
echo "2. Replace placeholder assets:"
echo "   - assets/sprites/pete/       (Pete character)"
echo "   - assets/sprites/obstacles/  (Game obstacles)"
echo "   - assets/sprites/collectibles/ (Coins, stars, power-ups)"
echo "   - assets/sprites/backgrounds/ (Parallax layers)"
echo "   - assets/audio/music/        (BGM tracks)"
echo "   - assets/audio/sfx/          (Sound effects)"
echo ""
echo "3. Add GameManager as Autoload:"
echo "   Project → Project Settings → Autoload"
echo "   Class: GameManager"
echo "   Path: res://scenes/managers/GameManager.gd"
echo ""
echo "4. Export for iOS:"
echo "   Project → Export → Add iOS platform"
echo "   Export as .ipa file"
echo ""
echo "📱 App Store Info:"
echo "------------------"
echo "Title: Pete's AC Adventure"
echo "Description: Help Pete deliver cool air! Earn real AC discounts."
echo "Keywords: hvac, heating, cooling, penguin, game, free, service"
echo ""
echo "✅ Ready to build!"
