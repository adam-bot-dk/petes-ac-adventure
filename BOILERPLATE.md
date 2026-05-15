# Boilerplate template

This repository is a **copy of the Pete's AC Adventure Godot 4.6 project** intended as a starting point for similar mobile endless-runner games.

## Quick start

```bash
git clone https://github.com/adam-bot-dk/petes-ac-adventure-boilerplate.git
cd petes-ac-adventure-boilerplate
./run.sh          # play
./run.sh -e       # editor
```

## What you get

- Main menu, pause overlay, game over, fish shop (wallet consumables)
- 3D Temple Run-style runner (`scenes/runner/TempleRunMain.tscn`)
- `GameManager` + `SaveManager` autoloads, Pure HVAC UI theme
- Portrait 720×1280 mobile layout

## Customize for a new game

1. Rename in `project.godot` (`config/name`, `run/main_scene`).
2. Swap branding in `themes/pure_hvac_theme.tres`, `MainMenu.tscn`, and HUD copy.
3. Tune consumables in `GameManager.CONSUMABLES`.
4. Replace placeholder art under `scenes/runner/` and `icon.svg`.

The live game repo (if you forked from production) may be [petes-ac-adventure](https://github.com/adam-bot-dk/petes-ac-adventure).
