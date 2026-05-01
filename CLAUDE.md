# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4 2D action RPG where the player progresses through tower floors, fights enemies, and advances via exit portals.

## Running the Game

Run through Godot editor (`F5` main scene, `F6` current scene).  
For smoke validation in headless mode:

```powershell
& "C:\Users\juanc\Desktop\Godot_v4.6.2-stable_win64.exe\Godot.exe" --headless --path D:\projeto_game_mvp\tower-game --quit
```

## Architecture

### Core Paths
- Main script: `res://scripts/core/main.gd`
- Autoloads:
  - `res://scripts/autoload/GameManager.gd`
  - `res://scripts/autoload/PlayerStats.gd`
- World scripts:
  - `res://scripts/world/base_floor.gd`
  - `res://scripts/world/exit_portal.gd`
  - `res://scripts/world/floors/floor_XX.gd`

### Floor Scene Organization
- Hub/city: `res://scenes/world/floor_00_city.tscn`
- Floors 1-10: `res://scenes/world/floors/floor_01_10/floor_XX.tscn`
- Convention for next batches:
  - `floor_11_20`
  - `floor_21_30`
  - and so on

### Scene Tree Contract
`GameManager.load_floor()` loads floor scenes under `Main/Game`.

### Floor Contract
Every floor script must:
- Extend `Node2D`
- Implement `enemy_killed(enemy)`
- Activate `ExitPortal` when floor is cleared
- Keep compatible enemy grouping (`"enemies"`)

### Enemy Contract
Every enemy must:
- Join `"enemies"` in `_ready()`
- Implement `take_damage(amount, source_position: Vector2)`
- Notify floor completion flow after death

## Agent Workflow

When changing structure/paths:
- Follow `.agents/skills/towergame-folder-structure-standardizer`.
- Run post-change validation with `.agents/skills/towergame-post-change-mechanics-guard`.
- Follow cross-agent governance in `.agents/skills/towergame-cross-agent-governance`.
