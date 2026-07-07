# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Seiva** — a survival/base-building game for a single, personal, offline iPhone install. Not published, not subject to App Store rules, no deadline. It is developed continuously over months/years by one person pairing with Claude.

**`docs/GDD.md` is the source of truth for design.** Every system in `game/` traces back to a decision recorded there. Before implementing a new system, read the relevant GDD section. If a design decision changes during implementation, update `docs/GDD.md` in the same change — don't let code and doc drift apart.

Core identity (see GDD for full detail): sobrevivência real (fome/sede/sono only — no temperature/disease/sanity, deliberately cut) is co-equal with bonding to a small cast of individually-simulated creatures (~15 total, not a large "catch 'em all" roster). Creatures use Utility AI (needs + personality weights + a memory-flag log), never a trained ML model — this is a deliberate constraint, not a placeholder to be upgraded later.

## Repository layout

- `docs/GDD.md` — the full game design document (vision, loops, survival, creatures, combat, roadmap, etc.)
- `game/` — the Godot 4 project (`game/project.godot` is the project root for the engine)
- `game/README.md` — current implementation state and how to open/run the project

## Commands

There is no build/lint/test tooling in this repo yet — it's a Godot project, not a typical package-managed codebase.

- **Open/run:** Godot 4.3+ editor, import `game/project.godot`, press F5 (runs `run/main_scene`, currently `scenes/world/Main.tscn`).
- **Headless check (if a Godot binary is available):** `godot --path game --headless --quit` will load the project and exit, surfacing script/scene parse errors without opening a window.
- **iOS export:** via Godot's `Project > Export` with an iOS preset, producing an Xcode project that is then built/signed/installed from Xcode. This step requires a Mac; the rest of development does not.

No Godot binary is available in this remote/cloud session's environment — code and `.tscn` files here have been reviewed by hand, not run. Validate with a real Godot instance when working locally.

## Architecture

### Autoloads (singletons, registered in `project.godot` in this load order)
`GameState` → `CreatureRegistry` → `TimeManager` → `SaveManager`. Order matters: later autoloads reference earlier ones directly by name (e.g. `TimeManager` calls `GameState.drain_survival_stats(...)`, `SaveManager` reads/writes both `GameState` and `CreatureRegistry`).

- `GameState` — in-memory player survival stats (hunger/thirst/sleep) and day count; emits change signals the HUD listens to.
- `TimeManager` — drives the day/night cycle on a real-time timer and ticks `GameState` once per in-game hour.
- `CreatureRegistry` — a runtime dictionary of `CreatureData` keyed by `creature_id`; creatures self-register in `CreatureAI._ready()`.
- `SaveManager` — serializes `GameState` + all registered creatures to a single JSON file in `user://saves/`. No server, no network.

### Creatures are data, not code
`CreatureData` (`game/scripts/creatures/creature_data.gd`) is a `Resource` — each individual creature is a `.tres` file (the MVP cast lives in `game/resources/creatures/`: `vix.tres`, `brum.tres`, `lume.tres`) holding visual palette (`body_color`, `accent_color`), personality weights (`explore_weight`, `rest_weight`, `help_weight`, `flee_weight`), thresholds (`flee_threshold`, `bond_threshold`), and runtime state (`trust`, `hunger`, `fatigue`, `is_bonded`, `is_injured`, `has_left`, `memory_flags`). Adding a new creature to the game means adding a new `.tres` resource, not writing new behavior code — behavior lives once in `CreatureAI`.

`CreatureAI` (`game/scripts/creatures/creature_ai.gd`) is the Utility AI: every `decision_interval` seconds it scores each possible `Action` (wander/rest/follow/help/flee) from need + personality weight + trust, and executes the highest-scoring one. `adjust_trust()` is the single entry point gameplay code should call to move a relationship forward or back (feeding, rescuing, ignoring, attacking) — crossing `bond_threshold` triggers the bond moment and calls `GameState.mark_creature_bonded()`.

### The world and all visuals are Minecraft-style blocks, generated in code
Art direction (GDD §16, decided 2026-07): a voxel/blocky look — deliberately "a copy of Minecraft's visual" with Seiva's own content. `BlockWorld` (`game/scripts/world/block_world.gd`) generates the whole island at `_ready()` from a **fixed seed** (`WORLD_SEED`): heightmap terrain as one vertex-colored `SurfaceTool` mesh (only visible faces, per-face shading, per-column tint jitter), a trimesh collision, translucent water, trees, and scattered collectible props (`berry_bush.gd`, `mushroom.gd`). Because the seed is fixed, the world is identical every session and is intentionally **not** saved. Characters are box-people: `BlockyPlayerVisual` / `BlockyCreatureVisual` (`game/scripts/visuals/`) build `BoxMesh` limbs via the `BlockBuilder` helper and swing them while moving; creature colors come from `CreatureData`. `day_night_cycle.gd` (on the `DirectionalLight3D`) drives sun angle/energy and procedural-sky colors from `TimeManager.game_hour`. No external art assets anywhere — keep it that way unless the GDD changes.

Two physics conventions that exist because of the block world: characters auto-jump 1-block steps (`is_on_floor() and is_on_wall()` → vertical impulse, like Minecraft mobile), and anything falling below y = -10 teleports back (the island floats over void). Also: the Player body must never rotate (only its `Visual` child does) — the camera pivot is a child of the body and would swing with it.

### Scenes are minimal shells; UI is built in code
`.tscn` files here are deliberately thin (root node + script, occasionally a collision/mesh sub-resource). Touch UI (`VirtualJoystick`, HUD bars, action button) is constructed procedurally in each script's `_ready()` rather than laid out in the scene file. This was a hand-authoring risk tradeoff (plain GDScript is easier to get right without a running editor than nested `.tscn` node/resource trees) — it is not a pattern to abandon reflexively, but replacing procedural UI with editor-authored scenes is reasonable once someone is iterating inside the Godot editor.

### Controls (touch, no physical input assumed)
Left half of the screen: virtual joystick (`VirtualJoystick`, drawn via `_draw()`, no texture assets). Right half: drag-to-orbit camera, handled directly in `player_controller.gd`'s `_unhandled_input`. Both are touch-index-tracked so they don't interfere with each other (see the `viewport_width * 0.5` split). Bottom-right buttons (`touch_controls.gd`): "Agir" calls `player.try_interact()` — contextual priority is creature (feed, favorite food first, else calm-approach) > berry bush/mushroom collect > drink water; "Comer" calls `player.try_eat()`. Interaction feedback goes through `call_group("hud", "flash_message", text)`.
