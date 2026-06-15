# Data Schema Map

## Entity Relationship Overview

```
+------------------+         +------------------+
|     tables       |         |     scores       |
+------------------+         +------------------+
| id (uuid) PK     |<---+    | id (uuid) PK     |
| name (text)      |    +----| table_id (uuid)FK|
| description(text)|         | player_initials  |
| layout (jsonb)   |         | score (int)      |
| is_active (bool) |         | played_at(tstz)  |
| created_at(tstz) |         | created_at(tstz) DEFAULT now()|
+------------------+         +------------------+

+------------------+
|  project_files   |
+------------------+
| id (uuid) PK     |
| path (text)      |
| type (text)      |
| description(text)|
| milestone (text) |
| created_at(tstz) |
| updated_at(tstz) |
+------------------+
```

## Table Descriptions

### `tables`
Stores pinball table configurations. The `layout` JSONB column holds all spatial data:
```json
{
  "bumpers": [{"x": 200, "y": 400, "radius": 30, "score_value": 100}],
  "targets": [{"x": 150, "y": 600, "width": 40, "height": 10, "score_value": 50, "active": true}],
  "flippers": [
    {"side": "LEFT", "pivot": {"x": 180, "y": 1800}, "length": 120, "angle_rest": -30, "angle_active": 30},
    {"side": "RIGHT", "pivot": {"x": 540, "y": 1800}, "length": 120, "angle_rest": 30, "angle_active": -30}
  ],
  "walls": [{"start": {"x": 0, "y": 0}, "end": {"x": 0, "y": 1920}}],
  "launch_position": {"x": 600, "y": 1700},
  "drain_y": 1920
}
```

> **Note on `targets[].active`:** This field is persisted in the JSONB layout as the default/reset state for each target. At runtime, `active` is also managed as in-engine state (toggled on hit); it is re-loaded from this config on each new ball or game reset. `load_table_config()` must parse and include this field.

> **Note on `bumper.hit_animation_active`:** This is a purely runtime, in-memory field managed by the Godot physics engine. It is not persisted to the database.

### `scores`
Persists every completed game. Linked to a table via `table_id`. Used to render leaderboards. `created_at` has `DEFAULT now()` — do not include it in INSERT payloads from the game client.

### `project_files`
Internal catalog table — tracks all files in the repository with type and milestone tags. **Population strategy: seeded via a migration script, updated manually or via CI whenever new source files are added.** Not read or written by the game client at runtime.

---

## Local Config Files (Not in Supabase)

The following game settings are stored in `config/game.json` and loaded by `ConfigLoader.load_game_config()`. They are intentionally local (not database-driven) as they are environment/hardware-specific:

| Field | Default | Description |
|---|---|---|
| `balls_per_game` | 3 | Number of balls per game session |
| `target_display_resolution` | 1080×1920 | Portrait resolution of the wall-mounted display |
| `active_table_id` | (uuid) | FK reference to `tables.id` — determines which table config is loaded from Supabase |

---

## Migrations

| # | Migration Name | Description | Status |
|---|----------------|-------------|--------|
| 1 | `create_project_files_catalog` | Project file index | ✅ Done (2026-06-15) |
| 2 | `create_tables` | Pinball table configs with JSONB layout | ✅ Done (2026-06-15) |
| 3 | `create_scores` | Game scores with FK to tables | ✅ Done (2026-06-15) |
