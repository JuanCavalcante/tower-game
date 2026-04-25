# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4 2D platformer where the player climbs floors, kills enemies in waves, and advances through an exit portal. Currently has 3 floors: floor 1 uses wave-based spawning, floors 2 and 3 use pre-placed enemies.

## Running the Game

Open and run via the Godot 4 editor — there is no CLI build command. Use **F5** to run the main scene or **F6** to run the current scene. There are no automated tests.

## Architecture

### Autoloads (Singletons)
- `autoload/GameManager.gd` — floor loading, save/load (`user://savegame.json`), player position reset. Floors are registered in a dictionary keyed by floor number pointing to scene paths.
- `autoload/PlayerStats.gd` — health, XP, and level state. Level-up increases `max_health` by 20 and multiplies `xp_to_next_level` by 1.5.

### Scene Tree
```
Main (main.gd)
└── Game              ← floor scenes are instantiated here
└── UI
    ├── MainMenu
    ├── PauseMenu
    └── HUD
```
`GameManager.load_floor()` looks up `Main/Game` by absolute node path and adds the floor scene as a child.

### Floor Contract
Every floor script must:
- Extend `Node2D`
- Implement `enemy_killed(enemy)` — enemies call this on death by walking up the scene tree until they find a node with this method
- Call `portal.activate()` when the floor is cleared
- Have an `ExitPortal` node (child)

Floor 1 adds wave spawning on top of this contract (`scripts/floor_01.gd`). Floors 2 and 3 use pre-placed enemies only.

### Enemy Contract
Every enemy must:
- Add itself to the `"enemies"` group in `_ready()`
- Implement `take_damage(amount, source_position: Vector2)`
- On death, call `PlayerStats.add_xp(amount)` then notify the floor via `_find_floor_node()` (walks `get_parent()` chain)

### Player Combat
Attack uses `get_tree().get_nodes_in_group("enemies")` with distance + facing direction checks. The hit detection fires mid-animation (after a 0.45s timer), not at animation end.

## Adding a New Floor

1. Create scene at `res://scenes/world/floor_0N.tscn`
2. Write `scripts/floor_0N.gd` implementing the floor contract above
3. Register the scene in `GameManager.floors` dictionary
