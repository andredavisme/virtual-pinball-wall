# Virtual Pinball Wall — Test Suite

This directory contains the testing environment for the virtual pinball wall project.

## Structure

```
tests/
  README.md              — This file
  run_tests.gd           — Master test runner (GDScript)
  suites/
    test_game_loop.gd    — Tests for 01-game-loop pseudocode
    test_ball_physics.gd — Tests for 02-ball-physics pseudocode
    test_input.gd        — Tests for 03-input-handler pseudocode
    test_score_service.gd— Tests for 06-score-service pseudocode
    test_config_loader.gd— Tests for 05-config-loader pseudocode
    test_db_schema.gd    — Tests for DB schema integrity
```

## Running Tests

From the Godot editor, run `tests/run_tests.gd` as a tool script, or attach it to an AutoLoad node and call `TestRunner.run_all()`.

Results are written to:
- Console output
- Supabase `test_log` table (requires valid config with `SUPABASE_URL` and `SUPABASE_KEY`)

## Test Status Codes
- `pass` — test passed
- `fail` — test failed (with message)
- `skip` — test intentionally skipped (feature not yet implemented)

## Logging

Each test result is posted to the `test_log` table:
```json
{
  "test_suite": "GameLoop",
  "test_name": "ball_launches_on_ready",
  "status": "pass",
  "message": null,
  "duration_ms": 12
}
```
