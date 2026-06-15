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
| 1 | Review design repository objectives | ✅ Done | Session 1 |
| 2 | Review pseudocode files | ✅ Done | Session 1 |
| 3 | Review data schema map | ✅ Done | Session 1 |
| 4 | Cross-check resources for consistency & feasibility | ✅ Done | Session 1 |
| 5 | Create testing environment (test runner + suites) | ✅ Done | Session 1 |
| 6 | Create databases per schema map | ✅ Done | Session 1 |
| 7 | Create code files per pseudocode | ✅ Done | Session 1 |
| 8 | Create testing scripts & run them | ✅ Done | Session 1 |

> **All 8 steps complete as of 2026-06-15.**

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
| `src/ui/UIRenderer.gd` | CanvasLayer — HUD, overlays, leaderboard display |
| `src/config/ConfigLoader.gd` | AutoLoad — loads `game.json` + fetches table config from Supabase |
| `src/engine/ScoreService.gd` | AutoLoad — `post_score()` + `get_leaderboard()` via Supabase REST |
| `src/engine/SupabaseClient.gd` | AutoLoad — shared URL + key + headers |

### Config (`config/`)
| File | Notes |
|---|---|
| `config/game.json` | `active_table_id`, `supabase_url`, `supabase_key`, `balls_per_game` — **fully wired** |
| `config/input.json` | Default: keyboard adapter |

### Tests (`tests/`)
| Path | Type |
|---|---|
| `tests/run_tests.gd` | Godot test runner |
| `tests/suites/` | Unit/contract test suites |
| `tests/integration/test_db_live.gd` | Live Supabase INSERT/SELECT/DELETE |
| `tests/integration/test_config_roundtrip.gd` | game.json → Supabase table config round-trip |
| `tests/integration/test_score_service_live.gd` | Full score POST + leaderboard GET cycle |
| `tests/integration/test_game_loop_smoke.gd` | Scene instantiation + state machine simulation |
| `tests/integration/run_db_tests.py` | Standalone Python runner (no Godot required) |

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

### Integration Test Results (last run: 2026-06-15)
| Test | Result |
|---|---|
| `tables_row_exists` | ✅ pass |
| `layout_shape` | ✅ pass |
| `score_insert` | ✅ pass |
| `score_fk_constraint` | ✅ pass |
| `leaderboard_sort` | ✅ pass |
| `test_log_insert` | ✅ pass |

---

## What Comes Next

The code and DB are complete. The remaining work is **inside Godot 4** (cannot be done via GitHub/Supabase MCP — requires local editor):

1. **Register AutoLoads** in Project Settings > AutoLoad:
   - `SupabaseClient` → `src/engine/SupabaseClient.gd`
   - `InputManager` → `src/input/InputManager.gd`
   - `ConfigLoader` → `src/config/ConfigLoader.gd`
   - `ScoreService` → `src/engine/ScoreService.gd`

2. **Build `res://scenes/Main.tscn`** — scene tree:
   ```
   Node (GameLoop.gd)
   ├── Ball (RigidBody2D + Ball.gd)
   ├── FlipperLeft (AnimatableBody2D + Flipper.gd)
   ├── FlipperRight (AnimatableBody2D + Flipper.gd)
   ├── DrainZone (Area2D + DrainZone.gd)
   ├── Bumper_1..N (Area2D + Bumper.gd)
   ├── Target_1..N (Area2D + Target.gd)
   ├── TableBounds (StaticBody2D + TableBounds.gd)
   └── UIRenderer (CanvasLayer + UIRenderer.gd)
       ├── HUD/ScoreLabel
       ├── HUD/BallCountLabel
       ├── PauseOverlay
       ├── GameOverOverlay/LeaderboardTable
       ├── AttractScreen/HighScoreLabel
       └── InitialsPrompt
   ```

3. **Configure InputMap** (Project Settings > Input Map):
   - `flip_left`, `flip_right`, `launch`, `pause`, `tilt`

4. **Set display to portrait** (Project Settings > Display > Window):
   - Width: 1080, Height: 1920, Orientation: Portrait

5. **Wire `SupabaseClient.configure()`** — call at startup from `GameLoop._ready()` using values from `game.json`.

6. **Run Godot smoke test** — attach `tests/integration/test_game_loop_smoke.gd` to a test scene and confirm all state transitions pass.

7. **Add sprites/audio assets** to `assets/` for ball, flippers, bumpers, targets, backgrounds.

---

## Key References

- **Repo:** https://github.com/andredavisme/virtual-pinball-wall
- **Supabase project:** https://supabase.com/dashboard/project/hhyhulqngdkwsxhymmcd
- **Pseudocode:** `pseudocode/01-game-loop.md` through `06-score-service.md`
- **Schema map:** `db/schema-map.md` (or `docs/`)
- **Python test runner:** `python tests/integration/run_db_tests.py --url ... --key ... --table-id 29bf4788-e1c3-4b62-9caf-fc2dfb33456f`
