# Virtual Pinball Wall — Browser Prototype

A GitHub Pages-compatible browser version of the virtual pinball machine.
Built with HTML5 Canvas + Matter.js physics, aligned to the existing pseudocode and schema.

## Architecture Alignment

| Pseudocode File | JS Module | Notes |
|---|---|---|
| `01-game-loop.md` | `js/engine.js` | State machine: ATTRACT → PLAYING → PAUSED → GAME_OVER |
| `02-physics-engine.md` | `js/physics.js` | Matter.js bodies mirroring RigidBody2D / AnimatableBody2D |
| `03-input-abstraction.md` | `js/input.js` | InputEvent enum, KeyboardAdapter + touch equivalent |
| `04-ui-renderer.md` | `js/renderer.js` | `drawFrame()` = `update_frame()`, canvas draw calls |
| `05-config-loader.md` | `js/config.js` | `GAME_CONFIG` + `DEFAULT_TABLE_LAYOUT` matching schema JSONB |
| `06-score-service.md` | `js/supabase.js` | `postScore()` + `getLeaderboard()`, schema-aligned payloads |

## Schema Alignment

- `DEFAULT_TABLE_LAYOUT` in `config.js` mirrors the `tables.layout` JSONB schema exactly
- `postScore()` does NOT include `created_at` (DB `DEFAULT now()`)
- `getLeaderboard()` returns `{ player_initials, score, played_at }` matching `scores` table
- `active_table_id` in `GAME_CONFIG` is the FK to `tables.id`

## Controls

| Action | Keyboard | Touch |
|---|---|---|
| Left flipper | `Z` / `ArrowLeft` / `Shift Left` | LEFT button |
| Right flipper | `/` / `ArrowRight` / `Shift Right` | RIGHT button |
| Launch | `Space` or tap canvas | Tap canvas |
| Pause | `P` | — |

## Running Locally

Open `index.html` directly in a browser — no build step required.

## GitHub Pages

Enable Pages from **Settings → Pages → Deploy from branch: main**, root `/`.
Or push to `gh-pages` branch. The `index.html` entry point is GitHub Pages ready.

## Connecting Supabase (Optional)

Edit `js/supabase.js`:
```js
const SUPABASE_URL      = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```
The `scores` and `tables` tables are already migrated (see `db/schema-map.md`).
