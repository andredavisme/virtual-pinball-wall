# Integration Tests

These scripts test **live system behavior** — real Supabase calls, real file reads, real singleton wiring. They require:

- A running Godot 4.x project with AutoLoads registered
- `config/game.json` populated with a valid `supabase_url`, `supabase_key`, and `active_table_id`
- Network access to Supabase

## Files

| File | What it tests |
|---|---|
| `test_db_live.gd` | INSERT + SELECT on `scores`; SELECT on `tables`; INSERT on `test_log` |
| `test_config_roundtrip.gd` | Load `game.json` → fetch table config from Supabase → verify layout fields |
| `test_score_service_live.gd` | Full `post_score()` + `get_leaderboard()` cycle via ScoreService |
| `test_game_loop_smoke.gd` | Instantiates GameLoop scene, simulates LAUNCH → drain → GAME_OVER state transitions |
| `run_db_tests.py` | Standalone Python script — hits Supabase REST directly, no Godot required |

## Running in Godot

Attach any integration test as a tool script or add to `run_tests.gd` suites list. Results are logged to `test_log` in Supabase.

## Running DB tests outside Godot

```bash
pip install requests
python tests/integration/run_db_tests.py \
  --url https://hhyhulqngdkwsxhymmcd.supabase.co \
  --key <your-anon-key> \
  --table-id <active_table_id>
```
