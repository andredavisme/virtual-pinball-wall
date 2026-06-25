# Milestones & Tasks

Last updated: 2026-06-25 (Session 3)

> **Legend:** ✅ = complete | 🔧 = requires Godot editor (local) | ⬜ = not started

---

## Milestone 1 — Core Game Engine

- ✅ Select game framework — **Godot 4** (GDScript, 2D physics)
- ✅ Implement ball physics — `src/nodes/Ball.gd` (RigidBody2D, bounce=0.6, friction=0.05)
- ✅ Implement flipper mechanics — `src/nodes/Flipper.gd` (AnimatableBody2D, tween-driven, config-loaded angles)
- ✅ Implement bumper/target collision logic — `src/nodes/Bumper.gd`, `src/nodes/Target.gd`
- ✅ Basic game loop (ball launch, drain, score increment) — `src/GameLoop.gd` (state machine: ATTRACT/PLAYING/PAUSED/GAME_OVER)
- ✅ Unit test physics interactions — `tests/suites/` + `tests/integration/test_game_loop_smoke.gd`

---

## Milestone 2 — Input Abstraction Layer

- ✅ Define `InputEvent` interface/schema — `src/input/InputAdapter.gd` (FLIP_LEFT, FLIP_RIGHT, LAUNCH, PAUSE, TILT)
- ✅ Implement keyboard adapter — `src/input/KeyboardAdapter.gd`
- ✅ Implement GPIO/button box adapter — `src/input/GPIOAdapter.gd`
- ✅ Implement Bluetooth adapter — `src/input/BluetoothAdapter.gd`
- ✅ Implement input config file — `config/input.json` (adapter selection)
- ✅ Input manager AutoLoad — `src/input/InputManager.gd`
- 🔧 Test hot-swap between input adapters — requires editor + hardware

---

## Milestone 3 — Vertical Display Layout

- ✅ Design portrait-mode UI layout — `src/ui/UIRenderer.gd` (CanvasLayer, HUD + overlays)
- ✅ Scale table to vertical resolution — 1080×1920 set in `docs/godot-setup-guide.md` (Project Settings)
- ✅ HUD (score, ball count) positioned for vertical screen — `UIRenderer/HUD/ScoreLabel`, `BallCountLabel` in `Main.tscn`
- ✅ Accessibility font option — OpenDyslexic wired via `accessibility.dyslexic_font` in `game.json`
- ✅ Asset specification — `docs/asset-spec.md` (13 sprites, 10 sounds, 3 fonts)
- ✅ Placeholder sprite generator — `tools/generate_placeholders.py`
- 🔧 Test on target display hardware — requires physical hardware

---

## Milestone 4 — Persistent Scoreboard

- ✅ Create `scores` table in Supabase — live, RLS policies applied (anon INSERT/SELECT/DELETE)
- ✅ POST score on game over — `src/engine/ScoreService.gd` (`post_score()`)
- ✅ GET top scores for leaderboard display — `src/engine/ScoreService.gd` (`get_leaderboard()`)
- ✅ Display leaderboard on attract/game-over screen — `UIRenderer.gd` + `GameOverOverlay/LeaderboardTable` in `Main.tscn`
- ✅ Integration tests — `tests/integration/test_score_service_live.gd` + `run_db_tests.py` (6/6 passed 2026-06-15)

---

## Milestone 5 — Table Config System

- ✅ Define table config schema — `db/` schema map
- ✅ Create `tables` table in Supabase — live, seeded with "Classic Wall Table"
- ✅ Load active table config at game start — `src/config/ConfigLoader.gd` (AutoLoad)
- ✅ Build default table config — UUID `29bf4788-e1c3-4b62-9caf-fc2dfb33456f` in `config/game.json`
- ✅ Config round-trip integration test — `tests/integration/test_config_roundtrip.gd`

---

## Milestone 6 — Godot Editor Wiring *(in progress)*

> All code and scene files are committed. These tasks require opening the project in Godot 4 locally.

- ✅ Main scene file created — `src/scenes/Main.tscn` (all nodes, shapes, scripts pre-wired)
- 🔧 Register 4 AutoLoads in Project Settings
- 🔧 Configure InputMap (flip_left, flip_right, launch, pause, tilt)
- 🔧 Configure display settings (1080×1920 portrait)
- 🔧 Set Main Scene → `res://src/scenes/Main.tscn`
- 🔧 Run smoke test (F6) — expect 6 PASSes in Output panel
- 🔧 Run full game (F5) — confirm attract → play → game over flow

---

## Milestone 7 — Final Assets & Polish *(not started)*

- ⬜ Source/create final sprites (replace placeholders) — see `docs/asset-spec.md`
- ⬜ Source/create audio SFX and music loops — 10 files, OGG format
- ⬜ Download and place final fonts — Press Start 2P, Share Tech Mono, Rajdhani Bold, OpenDyslexic (optional)
- ⬜ Wire sprites to nodes via Godot Inspector (Texture fields)
- ⬜ Wire audio streams to nodes via Godot Inspector (Stream fields)
- ⬜ Test full game with final assets
- ⬜ Test on physical wall-mounted display
- ⬜ Re-run all integration tests after final wiring
