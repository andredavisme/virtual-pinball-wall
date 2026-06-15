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
> Next work phase is Godot editor tasks (see “What Comes Next” below).

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

All MCP-accessible work is complete. The remaining work requires **Godot 4 editor** (local machine):

### 1. Register AutoLoads
Project Settings > AutoLoad — add in this order:

| Name | Path |
|---|---|
| `SupabaseClient` | `res://src/engine/SupabaseClient.gd` |
| `InputManager` | `res://src/input/InputManager.gd` |
| `ConfigLoader` | `res://src/config/ConfigLoader.gd` |
| `ScoreService` | `res://src/engine/ScoreService.gd` |

### 2. Wire SupabaseClient at startup
In `GameLoop._ready()`, add before all other calls:
```gdscript
var cfg = ConfigLoader.load_game_config("res://config/game.json")
SupabaseClient.configure(cfg.get("supabase_url", ""), cfg.get("supabase_key", ""))
```

### 3. Build `res://scenes/Main.tscn`
Scene tree structure:
```
Node (GameLoop.gd)
├── Ball               (RigidBody2D + Ball.gd)
├── FlipperLeft        (AnimatableBody2D + Flipper.gd)
├── FlipperRight       (AnimatableBody2D + Flipper.gd)
├── DrainZone          (Area2D + DrainZone.gd)
├── Bumper_1..N        (Area2D + Bumper.gd)
├── Target_1..N        (Area2D + Target.gd)
├── TableBounds        (StaticBody2D + TableBounds.gd)
└── UIRenderer         (CanvasLayer + UIRenderer.gd)
    ├── HUD/ScoreLabel
    ├── HUD/BallCountLabel
    ├── PauseOverlay
    ├── GameOverOverlay/LeaderboardTable
    ├── AttractScreen/HighScoreLabel
    └── InitialsPrompt
```

### 4. Configure Project Settings
- **InputMap:** add actions `flip_left`, `flip_right`, `launch`, `pause`, `tilt`
- **Display > Window:** Width 1080, Height 1920, Orientation: Portrait

### 5. Run Godot Smoke Test
Attach `tests/integration/test_game_loop_smoke.gd` to a test scene and run. Confirms:
- ATTRACT → PLAYING on LAUNCH
- balls_remaining decrements on drain
- GAME_OVER on last drain

### 6. Add Visual & Audio Assets
Place in `assets/`:
- Sprites: ball, flipper (left/right), bumper (default + lit), target (active/inactive), table background
- Audio: bumper hit SFX, flipper SFX, drain SFX, game over jingle

### 7. Re-run Integration Tests After Scene Build
```bash
python tests/integration/run_db_tests.py \
  --url https://hhyhulqngdkwsxhymmcd.supabase.co \
  --key sb_publishable_haKvwV0M7KMj4Qz69M6WGg_KmIfU-aI \
  --table-id 29bf4788-e1c3-4b62-9caf-fc2dfb33456f
```

---

## Key References

- **Repo:** https://github.com/andredavisme/virtual-pinball-wall
- **Supabase project:** https://supabase.com/dashboard/project/hhyhulqngdkwsxhymmcd
- **Pseudocode:** `pseudocode/01-game-loop.md` through `06-score-service.md`
- **Schema map:** `db/` directory
- **Supabase URL:** `https://hhyhulqngdkwsxhymmcd.supabase.co`
- **Supabase publishable key:** `sb_publishable_haKvwV0M7KMj4Qz69M6WGg_KmIfU-aI`
- **Active table UUID:** `29bf4788-e1c3-4b62-9caf-fc2dfb33456f`
