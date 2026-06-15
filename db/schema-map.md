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
| created_at(tstz) |         | created_at(tstz) |
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
  "targets": [{"x": 150, "y": 600, "width": 40, "height": 10, "score_value": 50}],
  "flippers": [
    {"side": "LEFT", "pivot": {"x": 180, "y": 1800}, "length": 120, "angle_rest": -30, "angle_active": 30},
    {"side": "RIGHT", "pivot": {"x": 540, "y": 1800}, "length": 120, "angle_rest": 30, "angle_active": -30}
  ],
  "walls": [{"start": {"x": 0, "y": 0}, "end": {"x": 0, "y": 1920}}],
  "launch_position": {"x": 600, "y": 1700},
  "drain_y": 1920
}
```

### `scores`
Persists every completed game. Linked to a table via `table_id`. Used to render leaderboards.

### `project_files`
Internal catalog table — tracks all files in the repository with type and milestone tags.

---

## Planned Migrations

| # | Migration Name | Description |
|---|----------------|-------------|
| 1 | `create_project_files_catalog` | ✅ Done — project file index |
| 2 | `create_tables` | Pinball table configs with JSONB layout |
| 3 | `create_scores` | Game scores with FK to tables |
