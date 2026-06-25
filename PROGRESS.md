# Project Progress — Virtual Pinball Wall

This file is the canonical handoff document. At the start of any new session, read this file first to understand what is done, what is next, and what the active context is.

---

## Space Instructions (from Perplexity Space)

1. Review the Design repository objectives
2. Review the pseudocode files
3. Review the data schema map
4. Cross-check all resources against each other for consistency and feasibility
5. Create a testing environment to conduct and log functionality tests
6. Create databases per the data schema map
7. Create code files per the pseudocode
8. Create testing scripts to be run in the testing environment

---

## Step Status

| # | Step | Status | Completed |
|---|---|---|---|
| 1 | Review design repository objectives | ✅ Done | 2026-06-15 Session 1 |
| 2 | Review pseudocode files | ✅ Done | 2026-06-15 Session 1 |
| 3 | Review data schema map | ✅ Done | 2026-06-15 Session 1 |
| 4 | Cross-check resources for consistency & feasibility | ✅ Done | 2026-06-15 Session 1 |
| 5 | Create testing environment (test runner + suites) | ✅ Done | 2026-06-15 Session 1 |
| 6 | Create databases per schema map | ✅ Done | 2026-06-15 Session 1 |
| 7 | Create code files per pseudocode | ✅ Done | 2026-06-15 Session 1 |
| 8 | Create testing scripts & run them | ✅ Done | 2026-06-15 Session 1 |

> **All 8 Space instruction steps complete as of 2026-06-15.**
> Next work phase is Godot editor tasks — follow `docs/godot-setup-guide.md`.

---

## Session Log

### Session 1 — 2026-06-15
- Reviewed design objectives, pseudocode (6 files), and schema map
- Cross-checked pseudocode ↔ schema ↔ design for consistency; no blocking conflicts found
- Created Supabase DB tables: `tables`, `scores`, `test_log`
- Applied RLS policies: anon SELECT on `tables`; anon INSERT/SELECT/DELETE on `scores`; anon INSERT/SELECT on `test_log`
- Seeded "Classic Wall Table" into `public.tables` (UUID: `29bf4788-e1c3-4b62-9caf-fc2dfb33456f`)
- Created all 16 source code files under `src/` and `config/`
- Wired `config/game.json` with live Supabase URL, publishable key, and active table UUID
- Created unit test suites under `tests/suites/` and integration scripts under `tests/integration/`
- Ran `run_db_tests.py` against live Supabase — **6/6 tests passed**
- Created `PROGRESS.md` (this file) for session handoff tracking

### Session 2 — 2026-06-15
- Created `docs/godot-setup-guide.md` — full beginner-friendly, step-by-step Godot 4 editor walkthrough
- Guide covers: project import, AutoLoad registration, display config (1080×1920 portrait), InputMap setup, Main scene construction, main scene assignment, smoke test execution, and full game run
- Includes 8 checkpoints and troubleshooting sections for each major step
- Updated `PROGRESS.md` (this file)

### Session 3 — 2026-06-25
- Created `docs/asset-spec.md` — full asset specification: 13 sprites, 10 sounds, 3 fonts with sizes, formats, styles, pivot notes, usage context, and a 26-item completion checklist
- Added OpenDyslexic as an optional OFL-licensed accessibility font (`ui_font_dyslexic.ttf`) alongside Rajdhani Bold (`ui_font.ttf`)
- Created `tools/generate_placeholders.py` — Pillow-based script that generates all 13 placeholder PNGs at spec-correct sizes into `assets/sprites/`
- Created `docs/placeholder-setup.md` — guide covering both Option A (generator script) and Option B (Godot `PlaceholderTexture2D`) approaches
- Updated `config/game.json` — added `accessibility.dyslexic_font` flag (default `false`)
- Updated `src/ui/UIRenderer.gd` — wired `_apply_accessibility_font()` in `_ready()`; reads flag from `game.json` via ConfigLoader; applies `ui_font_dyslexic.ttf` theme override to all static labels and dynamically created leaderboard rows; graceful fallback with `push_warning()` if font file missing
- Created `src/scenes/Main.tscn` — fully wired Godot 4 scene file; includes all game nodes (Ball, FlipperLeft/Right, Bumper×3, Target×2, DrainZone, TableBounds, UIRenderer) with collision shapes, physics material, and correct script references; no manual node building required in editor
- Fixed `tests/integration/test_game_loop_smoke.gd` — corrected scene load path from `res://scenes/Main.tscn` to `res://src/scenes/Main.tscn`
- Updated `PROGRESS.md` (this file)

---

## What Was Built

### Source Code (`src/`)
| File | Role |
|---|---|
| `src/GameLoop.gd` | Root scene controller — state machine, ball lifecycle, score wiring |
| `src/nodes/Ball.gd` | RigidBody2D — pinball ball with physics group |
| `src/nodes/Flipper.gd` | AnimatableBody2D — tween-driven flipper with config-loaded angles |
| `src/nodes/Bumper.gd` | Area2D — impulse bumper, emits `bumper_hit` signal |
| `src/nodes/DrainZone.gd` | Area2D — emits `ball_drained` signal |
| `src/nodes/Target.gd` | Area2D — toggleable drop target, emits `target_hit` signal |
| `src/nodes/TableBounds.gd` | StaticBody2D — wall segments built from TableConfig |
| `src/input/InputAdapter.gd` | Base class + `InputEvent` enum |
| `src/input/KeyboardAdapter.gd` | Keyboard → InputEvent mapping |
| `src/input/GPIOAdapter.gd` | GPIO pin → InputEvent mapping (Raspberry Pi) |
| `src/input/BluetoothAdapter.gd` | BT packet → InputEvent mapping |
| `src/input/InputManager.gd` | AutoLoad — manages active adapter |
| `src/ui/UIRenderer.gd` | CanvasLayer — HUD, overlays, leaderboard; **accessibility font wiring added** |
| `src/config/ConfigLoader.gd` | AutoLoad — loads `game.json` + fetches table config from Supabase |
| `src/engine/ScoreService.gd` | AutoLoad — `post_score()` + `get_leaderboard()` via Supabase REST |
| `src/engine/SupabaseClient.gd` | AutoLoad — shared URL + key + headers |

### Scenes (`src/scenes/`)
| File | Notes |
|---|---|
| `src/scenes/Main.tscn` | Fully wired main scene — all nodes, collision shapes, physics material, scripts pre-attached |

### Config (`config/`)
| File | Notes |
|---|---|
| `config/game.json` | `active_table_id`, `supabase_url`, `supabase_key`, `balls_per_game`, `accessibility.dyslexic_font` — **fully wired** |
| `config/input.json` | Default: keyboard adapter |

### Tools (`tools/`)
| File | Notes |
|---|---|
| `tools/generate_placeholders.py` | Generates all 13 placeholder sprites into `assets/sprites/` (requires Pillow) |

### Tests (`tests/`)
| Path | Type |
|---|---|
| `tests/run_tests.gd` | Godot test runner |
| `tests/suites/` | Unit/contract test suites |
| `tests/integration/test_db_live.gd` | Live Supabase INSERT/SELECT/DELETE |
| `tests/integration/test_config_roundtrip.gd` | game.json → Supabase table config round-trip |
| `tests/integration/test_score_service_live.gd` | Full score POST + leaderboard GET cycle |
| `tests/integration/test_game_loop_smoke.gd` | Scene instantiation + state machine simulation (**path fixed**) |
| `tests/integration/run_db_tests.py` | Standalone Python runner (no Godot required) |

### Documentation (`docs/`)
| File | Notes |
|---|---|
| `docs/godot-setup-guide.md` | Beginner-friendly Godot 4 editor setup guide with 8 checkpoints |
| `docs/asset-spec.md` | Full asset specification — 13 sprites, 10 sounds, 3 fonts + OpenDyslexic option; includes checklist |
| `docs/placeholder-setup.md` | Placeholder sprite setup guide — generator script and Godot PlaceholderTexture2D approaches |
| `docs/file-catalog.md` | Project file catalog |
| `docs/milestones.md` | Project milestones |

### Database (Supabase — project: `hhyhulqngdkwsxhymmcd`)
| Table | Status |
|---|---|
| `public.tables` | ✅ Created + seeded (1 row: "Classic Wall Table") |
| `public.scores` | ✅ Created, RLS policies applied |
| `public.test_log` | ✅ Created, integration test results written |

**Active table UUID:** `29bf4788-e1c3-4b62-9caf-fc2dfb33456f`

### RLS Policies Applied
- `tables`: anon SELECT
- `scores`: anon INSERT, SELECT, DELETE
- `test_log`: anon INSERT, SELECT (pre-existing)

### Integration Test Results (last run: 2026-06-15 ~15:38 EDT)
| Test | Suite | Result |
|---|---|---|
| `tables_row_exists` | DBLive | ✅ pass |
| `layout_shape` | DBLive | ✅ pass |
| `score_insert` | ScoreServiceLive | ✅ pass |
| `score_fk_constraint` | ScoreServiceLive | ✅ pass |
| `leaderboard_sort` | ScoreServiceLive | ✅ pass |
| `test_log_insert` | DBLive | ✅ pass |

---

## What Comes Next

Remaining work requires the **Godot 4 editor** on your local machine.

### 1. Get the Project Running Locally
1. Clone or re-pull the repo (all scene and config files are now committed)
2. Run `python tools/generate_placeholders.py` to generate placeholder sprites
3. Download fonts from Google Fonts (Press Start 2P, Share Tech Mono, Rajdhani Bold) — place in `assets/fonts/`
4. Open `project.godot` in Godot 4

### 2. Register AutoLoads (one-time editor setup)
Project Settings > AutoLoad — add in this order:

| Name | Path |
|---|---|
| `SupabaseClient` | `res://src/engine/SupabaseClient.gd` |
| `InputManager` | `res://src/input/InputManager.gd` |
| `ConfigLoader` | `res://src/config/ConfigLoader.gd` |
| `ScoreService` | `res://src/engine/ScoreService.gd` |

### 3. Configure Project Settings (one-time editor setup)
- **InputMap:** add actions `flip_left` (Z), `flip_right` (/), `launch` (Space), `pause` (Escape), `tilt` (T)
- **Display > Window:** Width 1080, Height 1920, Orientation: Portrait
- **Application > Run > Main Scene:** `res://src/scenes/Main.tscn`

### 4. Run the Godot Smoke Test
Create a test scene, attach `tests/integration/test_game_loop_smoke.gd`, press **F6**.

Expected Output panel results:
```
[PASS] initial_state_is_attract
[PASS] score_zero_on_start
[PASS] balls_remaining_equals_config
[PASS] launch_transitions_to_playing
[PASS] drain_decrements_balls
[PASS] game_over_when_last_ball_drained
```

### 5. Run Full Game (F5)
Press Space to launch, Z / / for flippers. Confirm attract screen → play → game over flow.

### 6. Re-run Integration Tests
```bash
python tests/integration/run_db_tests.py \
  --url https://hhyhulqngdkwsxhymmcd.supabase.co \
  --key sb_publishable_haKvwV0M7KMj4Qz69M6WGg_KmIfU-aI \
  --table-id 29bf4788-e1c3-4b62-9caf-fc2dfb33456f
```

### 7. Replace Placeholder Assets
Once the game runs with placeholders, source final sprites, sounds, and fonts per `docs/asset-spec.md`.

---

## Key References

- **Repo:** https://github.com/andredavisme/virtual-pinball-wall
- **Supabase project:** https://supabase.com/dashboard/project/hhyhulqngdkwsxhymmcd
- **Main scene:** `src/scenes/Main.tscn`
- **Godot setup guide:** `docs/godot-setup-guide.md`
- **Asset spec:** `docs/asset-spec.md`
- **Placeholder setup:** `docs/placeholder-setup.md`
- **Placeholder generator:** `tools/generate_placeholders.py`
- **Pseudocode:** `pseudocode/01-game-loop.md` through `06-score-service.md`
- **Schema map:** `db/` directory
- **Supabase URL:** `https://hhyhulqngdkwsxhymmcd.supabase.co`
- **Supabase publishable key:** `sb_publishable_haKvwV0M7KMj4Qz69M6WGg_KmIfU-aI`
- **Active table UUID:** `29bf4788-e1c3-4b62-9caf-fc2dfb33456f`
