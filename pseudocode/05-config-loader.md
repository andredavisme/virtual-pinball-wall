# Pseudocode: Config Loader (M5)

## File: `src/config/config_loader`

```
FUNCTION load_input_config(filepath) -> InputAdapter:
  READ config file (JSON or TOML)
  EXTRACT adapter_type ("keyboard" | "gpio" | "bluetooth")
  EXTRACT keymap or pin_map or device_id
  INSTANTIATE appropriate adapter with mappings
  RETURN adapter

FUNCTION load_table_config(table_id) -> TableConfig:
  FETCH table record from Supabase WHERE id = table_id
  PARSE layout JSON:
    bumpers[]  -> { position, radius, score_value }
    targets[]  -> { position, width, height, score_value, active }  # active = default/reset state
    flippers[] -> { side, pivot, length, angle_rest, angle_active }
    walls[]    -> { start_point, end_point }
    launch_position -> { x, y }
    drain_y    -> numeric
  RETURN TableConfig

FUNCTION load_game_config(filepath) -> GameConfig:
  READ config file
  EXTRACT balls_per_game (default: 3)
  EXTRACT target_display_resolution
  EXTRACT active_table_id
  RETURN GameConfig
```
