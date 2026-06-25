# Asset Specification — Virtual Pinball Wall

This document defines every asset required by the project, its file path, format, dimensions/duration, and usage context. All assets live under `assets/`.

---

## Project Display Context

- **Resolution:** 1080 × 1920 px (portrait)
- **Renderer:** Godot 4 — 2D (CanvasItem)
- **Coordinate origin:** Top-left
- **Pixel density:** 1:1 (no DPI scaling assumed)

---

## Sprites (`assets/sprites/`)

All sprites are **PNG**, RGBA, unless noted. Export at 1× pixel size; Godot handles scaling via `scale` property.

### Ball

| Property | Value |
|---|---|
| File | `assets/sprites/ball.png` |
| Size | 32 × 32 px |
| Style | Metallic silver sphere with subtle radial gradient and specular highlight |
| Used by | `src/nodes/Ball.gd` — `Sprite2D` child node |

### Flippers

| File | Size | Style |
|---|---|---|
| `assets/sprites/flipper_left.png` | 160 × 40 px | Rounded-end paddle, dark grey with chrome edge, pivot at left end |
| `assets/sprites/flipper_right.png` | 160 × 40 px | Mirror of left, pivot at right end |

- Used by `src/nodes/Flipper.gd`
- Pivot point must align with the rotation origin in the sprite (left flipper: pixel 0,20 / right flipper: pixel 160,20)

### Bumpers

| File | Size | Style |
|---|---|---|
| `assets/sprites/bumper_default.png` | 80 × 80 px | Circular, white/light grey with bold black outline |
| `assets/sprites/bumper_lit.png` | 80 × 80 px | Same shape; bright yellow/orange fill with glow effect — shown on hit |

- Used by `src/nodes/Bumper.gd`
- Swap between states on `bumper_hit` signal (lit for ~150 ms, then revert)

### Drop Targets

| File | Size | Style |
|---|---|---|
| `assets/sprites/target_active.png` | 48 × 64 px | Upright rectangular target, bright red with white stripe |
| `assets/sprites/target_inactive.png` | 48 × 64 px | Same shape, flattened/greyed — shown when target is knocked down |

- Used by `src/nodes/Target.gd`
- Toggle on `target_hit` signal

### Table Background

| Property | Value |
|---|---|
| File | `assets/sprites/table_bg.png` |
| Size | 1080 × 1920 px |
| Style | Dark felt texture (deep green or black), subtle lane markings, decorative side art panels |
| Used by | `Main.tscn` — bottom-most `Sprite2D` or `TextureRect` node |
| Notes | Full bleed; no alpha channel needed (use RGB PNG or JPG at Q90+) |

### HUD Overlay Elements

| File | Size | Description |
|---|---|---|
| `assets/sprites/hud_panel.png` | 1080 × 200 px | Semi-transparent dark bar for score/ball display at top of screen |
| `assets/sprites/ball_indicator.png` | 32 × 32 px | Small ball icon used to show remaining balls in HUD |
| `assets/sprites/leaderboard_bg.png` | 800 × 960 px | Background panel for leaderboard overlay |

- Used by `src/ui/UIRenderer.gd`

### Attract Screen

| File | Size | Description |
|---|---|---|
| `assets/sprites/attract_logo.png` | 800 × 400 px | Game logo / title art displayed during ATTRACT state |
| `assets/sprites/attract_bg.png` | 1080 × 1920 px | Full-screen background for attract mode (can be animated via `AnimatedSprite2D`) |

---

## Sounds (`assets/sounds/`)

All audio files: **OGG Vorbis** (`.ogg`) — Godot's preferred streaming format. Mono unless noted.

| File | Duration | Loop | Description |
|---|---|---|---|
| `assets/sounds/bumper_hit.ogg` | ~0.1 s | No | Short, sharp pop/click on bumper contact |
| `assets/sounds/flipper_up.ogg` | ~0.05 s | No | Quick mechanical clack — flipper raising |
| `assets/sounds/flipper_down.ogg` | ~0.05 s | No | Soft thud — flipper returning to rest |
| `assets/sounds/ball_launch.ogg` | ~0.2 s | No | Spring/plunger snap on ball launch |
| `assets/sounds/ball_drain.ogg` | ~0.5 s | No | Descending tone or hollow "thunk" on drain |
| `assets/sounds/target_hit.ogg` | ~0.15 s | No | Plastic clap — drop target knocked down |
| `assets/sounds/score_tick.ogg` | ~0.05 s | No | Single tick used when score counter animates |
| `assets/sounds/game_over.ogg` | ~3.0 s | No | Short jingle / descending fanfare |
| `assets/sounds/attract_music.ogg` | 60–90 s | Yes | Background loop for ATTRACT state (stereo OK) |
| `assets/sounds/game_music.ogg` | 60–120 s | Yes | Upbeat background loop during active play (stereo OK) |

### Usage in Code

- `bumper_hit.ogg` — triggered in `Bumper.gd` on `bumper_hit` signal
- `flipper_up/down.ogg` — triggered in `Flipper.gd` on tween start/end
- `ball_drain.ogg` — triggered in `GameLoop.gd` on `ball_drained` signal
- `game_over.ogg` — triggered in `GameLoop.gd` on state transition to `GAME_OVER`
- `attract_music.ogg` / `game_music.ogg` — managed by `UIRenderer.gd` or a dedicated `AudioManager` AutoLoad

---

## Fonts (`assets/fonts/`)

Godot 4 uses `.ttf` / `.otf` files imported as `FontFile` resources.

| File | Usage | Recommended Style |
|---|---|---|
| `assets/fonts/score_font.ttf` | Score display, ball counter in HUD | Bold, wide, arcade-style (e.g., Press Start 2P, Orbitron Bold) |
| `assets/fonts/leaderboard_font.ttf` | Leaderboard name/score rows | Monospace or semi-condensed for alignment |
| `assets/fonts/ui_font.ttf` | General UI labels, attract screen prompts | Clean sans-serif |
| `assets/fonts/ui_font_dyslexic.ttf` | *(Optional)* Accessibility alternative for `ui_font.ttf` | Dyslexia-friendly weighted letterforms |

### Recommended Free Fonts (OFL License)

| Asset | Suggested Font | URL |
|---|---|---|
| `score_font.ttf` | Press Start 2P | https://fonts.google.com/specimen/Press+Start+2P |
| `leaderboard_font.ttf` | Share Tech Mono | https://fonts.google.com/specimen/Share+Tech+Mono |
| `ui_font.ttf` | Rajdhani Bold | https://fonts.google.com/specimen/Rajdhani |
| `ui_font_dyslexic.ttf` *(optional)* | OpenDyslexic | https://opendyslexic.org/ |

All fonts are OFL (Open Font License) — free for commercial and personal use.

### Accessibility Font Swap

To enable the OpenDyslexic variant at runtime, `UIRenderer.gd` can load `ui_font_dyslexic.ttf` instead of `ui_font.ttf` based on a player preference flag. A suggested config key in `game.json`:

```json
"accessibility": {
  "dyslexic_font": false
}
```

When `dyslexic_font` is `true`, substitute `ui_font_dyslexic.ttf` wherever `ui_font.ttf` is applied in the Theme.

---

## Asset Checklist

Use this to track completion before first Godot smoke test with full scene:

### Sprites
- [ ] `ball.png`
- [ ] `flipper_left.png`
- [ ] `flipper_right.png`
- [ ] `bumper_default.png`
- [ ] `bumper_lit.png`
- [ ] `target_active.png`
- [ ] `target_inactive.png`
- [ ] `table_bg.png`
- [ ] `hud_panel.png`
- [ ] `ball_indicator.png`
- [ ] `leaderboard_bg.png`
- [ ] `attract_logo.png`
- [ ] `attract_bg.png`

### Sounds
- [ ] `bumper_hit.ogg`
- [ ] `flipper_up.ogg`
- [ ] `flipper_down.ogg`
- [ ] `ball_launch.ogg`
- [ ] `ball_drain.ogg`
- [ ] `target_hit.ogg`
- [ ] `score_tick.ogg`
- [ ] `game_over.ogg`
- [ ] `attract_music.ogg`
- [ ] `game_music.ogg`

### Fonts
- [ ] `score_font.ttf`
- [ ] `leaderboard_font.ttf`
- [ ] `ui_font.ttf`
- [ ] `ui_font_dyslexic.ttf` *(optional — accessibility)*

---

## Notes

- **Placeholder assets:** For initial Godot editor setup, use Godot's built-in `PlaceholderTexture2D` for sprites and the default `Theme` font. Replace with final assets before any public demo.
- **Import settings:** For sprites used on physics bodies (Ball, Flipper), ensure `Filter` is set to `Nearest` in the Godot import panel to avoid blurring at small sizes.
- **Audio bus:** Route all SFX through an `SFX` bus and music through a `Music` bus in Godot's Audio panel to allow independent volume control.
