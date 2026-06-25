# File Catalog

A reference index of all project files and their purpose. Last updated: 2026-06-25 (Session 3).

---

## Root

| Path | Type | Description |
|---|---|---|
| `README.md` | doc | Project overview, vision, objectives, milestones |
| `PROGRESS.md` | doc | Canonical session handoff document — what's done, what's next |
| `project.godot` | config | Godot 4 project file — open this to launch the editor |

---

## `src/` — Source Code

### Game Engine
| Path | Type | Description |
|---|---|---|
| `src/GameLoop.gd` | script | Root scene controller — state machine (ATTRACT/PLAYING/PAUSED/GAME_OVER), ball lifecycle, score wiring |
| `src/engine/SupabaseClient.gd` | script | AutoLoad — shared Supabase URL, key, and HTTP headers |
| `src/engine/ScoreService.gd` | script | AutoLoad — `post_score()` and `get_leaderboard()` via Supabase REST |

### Physics Nodes
| Path | Type | Description |
|---|---|---|
| `src/nodes/Ball.gd` | script | RigidBody2D — pinball ball; bounce=0.6, friction=0.05, gravity_scale=1.0 |
| `src/nodes/Flipper.gd` | script | AnimatableBody2D — tween-driven flipper; loads angles from TableConfig |
| `src/nodes/Bumper.gd` | script | Area2D — impulse bumper; emits `bumper_hit` signal |
| `src/nodes/DrainZone.gd` | script | Area2D — emits `ball_drained` signal on ball entry |
| `src/nodes/Target.gd` | script | Area2D — toggleable drop target; emits `target_hit` signal |
| `src/nodes/TableBounds.gd` | script | StaticBody2D — builds wall collision segments from TableConfig |

### Input Layer
| Path | Type | Description |
|---|---|---|
| `src/input/InputAdapter.gd` | script | Base class + `InputEvent` enum (FLIP_LEFT, FLIP_RIGHT, LAUNCH, PAUSE, TILT) |
| `src/input/KeyboardAdapter.gd` | script | Maps Godot `InputEvent` key presses to `InputEvent` enum |
| `src/input/GPIOAdapter.gd` | script | Maps Raspberry Pi GPIO pin states to `InputEvent` enum |
| `src/input/BluetoothAdapter.gd` | script | Maps BT packet data to `InputEvent` enum |
| `src/input/InputManager.gd` | script | AutoLoad — manages active adapter; dispatches input to GameLoop |

### UI
| Path | Type | Description |
|---|---|---|
| `src/ui/UIRenderer.gd` | script | CanvasLayer — HUD, overlays (pause/game over/attract/initials), leaderboard rows; accessibility font wiring via `game.json` |

### Config
| Path | Type | Description |
|---|---|---|
| `src/config/ConfigLoader.gd` | script | AutoLoad — loads `game.json` from disk; fetches active table config from Supabase |

### Scenes
| Path | Type | Description |
|---|---|---|
| `src/scenes/Main.tscn` | scene | Fully wired Godot 4 main scene — all nodes, collision shapes, physics material, and script references pre-configured |

---

## `config/` — Configuration

| Path | Type | Description |
|---|---|---|
| `config/game.json` | config | Runtime config: `active_table_id`, `supabase_url`, `supabase_key`, `balls_per_game`, `accessibility.dyslexic_font` |
| `config/input.json` | config | Input adapter selection (default: keyboard) |

---

## `assets/` — Game Assets

> See `docs/asset-spec.md` for full size, format, and style specs.
> See `docs/placeholder-setup.md` for placeholder generation instructions.

| Path | Type | Description |
|---|---|---|
| `assets/sprites/` | dir | 13 PNG sprites — ball, flippers, bumpers, targets, table bg, HUD, attract screen |
| `assets/sounds/` | dir | 10 OGG audio files — SFX and music loops |
| `assets/fonts/` | dir | 3–4 TTF fonts — score, leaderboard, UI (+ optional OpenDyslexic) |

---

## `db/` — Database Schema

| Path | Type | Description |
|---|---|---|
| `db/` | dir | Schema map files and Supabase migration definitions |

### Live Supabase Tables (project: `hhyhulqngdkwsxhymmcd`)
| Table | Description |
|---|---|
| `public.tables` | Pinball table definitions; seeded with "Classic Wall Table" (UUID: `29bf4788-e1c3-4b62-9caf-fc2dfb33456f`) |
| `public.scores` | Player scores with FK to `tables`; RLS: anon INSERT/SELECT/DELETE |
| `public.test_log` | Integration test run results; RLS: anon INSERT/SELECT |

---

## `pseudocode/` — Design Sketches

| Path | Type | Description |
|---|---|---|
| `pseudocode/01-game-loop.md` | doc | Game loop state machine and ball lifecycle logic |
| `pseudocode/02-physics-engine.md` | doc | Ball physics, flipper mechanics, collision rules |
| `pseudocode/03-input-adapter.md` | doc | Input abstraction layer design |
| `pseudocode/04-ui-renderer.md` | doc | HUD, overlay, and leaderboard rendering logic |
| `pseudocode/05-config-loader.md` | doc | Config loading and Supabase table fetch flow |
| `pseudocode/06-score-service.md` | doc | Score post and leaderboard retrieval flow |

---

## `tests/` — Test Suites

| Path | Type | Description |
|---|---|---|
| `tests/run_tests.gd` | script | Godot test runner — discovers and executes all test suites |
| `tests/suites/` | dir | Unit and contract test suites for individual scripts |
| `tests/integration/test_db_live.gd` | script | Live Supabase INSERT/SELECT/DELETE test |
| `tests/integration/test_config_roundtrip.gd` | script | `game.json` → Supabase table config round-trip test |
| `tests/integration/test_score_service_live.gd` | script | Full score POST + leaderboard GET cycle test |
| `tests/integration/test_game_loop_smoke.gd` | script | Scene instantiation + state machine simulation (loads `res://src/scenes/Main.tscn`) |
| `tests/integration/run_db_tests.py` | script | Standalone Python test runner — no Godot required; requires `--url`, `--key`, `--table-id` args |

---

## `tools/` — Developer Utilities

| Path | Type | Description |
|---|---|---|
| `tools/generate_placeholders.py` | script | Generates all 13 placeholder PNG sprites into `assets/sprites/` using Pillow; correct sizes per `docs/asset-spec.md` |

---

## `docs/` — Documentation

| Path | Type | Description |
|---|---|---|
| `docs/godot-setup-guide.md` | doc | Step-by-step Godot 4 editor setup guide with 8 checkpoints and troubleshooting |
| `docs/asset-spec.md` | doc | Full asset specification — 13 sprites, 10 sounds, 3 fonts; sizes, formats, styles, pivot notes, 26-item checklist |
| `docs/placeholder-setup.md` | doc | Placeholder sprite setup guide — Option A (generator script) and Option B (Godot PlaceholderTexture2D) |
| `docs/file-catalog.md` | doc | This file — index of all project files |
| `docs/milestones.md` | doc | Milestone definitions and task checklists |
| `docs/knowledgebase/` | dir | Architecture decisions, system overview, design notes |
