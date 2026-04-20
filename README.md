# Pete's AC Adventure - Godot Mobile Game

A one-thumb endless runner game for Pure Heating and Air featuring their penguin mascot Pete. Built with Godot 4.x for iOS App Store.

## Project Overview

**Title:** Pete's AC Adventure  
**Genre:** Endless Runner  
**Engine:** Godot 4.x  
**Platform:** iOS (Android later)  
**Target:** <50MB download  
**Controls:** One-thumb (tap, hold, double-tap)

---

## 📁 Project Structure

```
petes-ac-adventure/
├── project.godot              # Godot project configuration
├── icon.svg                   # App store icon
├── README.md                  # This file
├── addons/
│   ├── google_game_services/  # Game Center integration
│   └── coupon_manager/        # Custom coupon system
├── assets/
│   ├── sprites/
│   │   ├── pete/              # Pete mascot sprites
│   │   ├── obstacles/         # Game obstacles
│   │   ├── collectibles/      # Coins, stars, power-ups
│   │   └── backgrounds/       # Parallax layers
│   ├── audio/
│   │   ├── music/             # BGM tracks
│   │   └── sfx/               # Sound effects
│   └── fonts/
├── scenes/
│   ├── main/
│   │   ├── Main.tscn          # Main game scene
│   │   ├── HUD.tscn           # Heads-up display
│   │   ├── GameOver.tscn      # Game over screen
│   │   ├── PauseMenu.tscn     # Pause overlay
│   │   ├── Shop.tscn          # Vehicle shop
│   │   └── Background.tscn    # Parallax background
│   ├── gameplay/
│   │   ├── Player.tscn        # Pete character
│   │   ├── Obstacle_*.tscn    # Obstacle types
│   │   ├── Collectible_*.tscn # Collectibles
│   │   └── PowerUp.tscn       # Power-ups
│   └── managers/
│       └── GameManager.gd     # Game state singleton
└── scripts/
    ├── GameManager.gd         # Singleton game manager
    ├── Player.gd              # Player controller
    └── ObstacleSpawner.gd     # Spawning system
```

---

## 🎮 Controls

| Input | Action |
|-------|--------|
| Tap / Space | Jump |
| Hold Down | Slide |
| Double-Tap | Dash (unlocked) |
| P | Pause |

---

## 🚀 Quick Start

### 1. Open Project in Godot

```bash
cd ~/.hermes/games/petes-ac-adventure
godot --path .
```

### 2. Replace Placeholder Assets

The project has placeholder textures. Replace them with real art:

- `assets/sprites/pete/` - Pete character sprites (idle, run, jump, slide, hit)
- `assets/sprites/obstacles/` - Pothole, puddle, AC unit, bird, cone, truck
- `assets/sprites/collectibles/` - Coin, star, power-up icons
- `assets/sprites/backgrounds/` - 3 parallax layers (wide format)
- `assets/audio/music/` - Main theme, pause menu, game over music
- `assets/audio/sfx/` - Jump, slide, collect, hit sounds

### 3. Export for iOS

1. Open Godot → Project → Export
2. Add iOS template if not installed
3. Export as .ipa file

---

## 🛠 Development Notes

### GameManager.gd (Autoload)
This singleton manages all game state:
- Score, coins, stars, lives
- Game running/paused state
- Power-up tracking
- Vehicle unlocks

Add it to Project → Project Settings → Autoload:
- Class: GameManager
- Path: res://scenes/managers/GameManager.gd

### Scene Connections

Main.tscn expects these children:
- Player (CharacterBody2D)
- Background (Node2D with ParallaxBackground)
- ObstacleSpawner (Node2D)
- Camera2D
- HUD (Control)
- AudioStreamPlayer2D

---

## 💰 Monetization Strategy

**Brand Promotion Model:**
- Free to download (no paywall)
- No forced ads
- Goal: Customer loyalty & HVAC leads

**Coupon System:**
- 1000 coins = $1 off service
- 5000 coins = $5 off + priority service
- Coupon codes generated in GameOver.gd

**In-App Purchases:**
- Cosmetic only (Pete skins, vehicle trails)
- Never affects gameplay

---

## 📱 App Store Requirements

### Icon Sizes
- 1024x1024 (Store)
- 180x180 (iPhone)
- 120x120 (iPhone)

### Screenshots
- iPhone 6.7": 2796x1290
- iPhone 6.1": 2556x1179
- iPhone 5.5": 2208x1242

### Description
"Help Pete deliver cool air in this fun endless runner! Earn real discounts on AC service by playing."

### Keywords
hvac, heating, cooling, penguin, game, free, service, pure heating

---

## 🎯 Game Mechanics

### Obstacles (ordered by difficulty)
1. **Pothole** - Jump over
2. **Hot Puddle** - Jump over or slide under
3. **AC Unit** - High obstacle, jump only
4. **Bird** - Low flying, slide under
5. **Cone** - Small, can dodge
6. **Truck** - Slow but large

### Collectibles
- **Coins** - 10 points each
- **Stars** - 1 point each + HVAC tip popup
- **Power-ups** - Ice Burst, Turbo Vents, Service Van, Pete Clone

### Vehicles (unlocked by total coins)
- Foot (start)
- Scooter (500)
- Van (2000)
- Truck (5000)
- Drone (10000)

---

## 🔧 Troubleshooting

### Import Errors
Make sure all .tscn scene files can find their referenced resources. Check:
- Sprite2D textures
- CollisionShape2D shapes
- Script references

### iOS Export Issues
- Ensure you have Apple Developer account
- Install iOS templates in Godot
- Check signing certificates

### Performance
- Keep assets under 50MB total
- Use compressed textures
- Limit particle effects on mobile

---

## 📦 Next Steps

1. **Add Real Artwork** - Replace placeholder textures
2. **Add Audio** - Import music and SFX files
3. **Test on Device** - Export to TestFlight
4. **Implement Analytics** - Add session tracking
5. **App Store Submission** - Final review and publish

---

## 👤 Development Team

- **Project Lead:** Jonah Tillman (Digital Kingsmen)
- **Engine:** Godot 4.x
- **Target Date:** TBA

---

## 📞 Support

For questions or updates, contact:
- Email: jonah@digitalkingsmen.com
- Company: Digital Kingsmen
- Client: Pure Heating and Air

---

## 📄 License

Proprietary - All rights reserved to Digital Kingsmen
