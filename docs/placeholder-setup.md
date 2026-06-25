# Placeholder Sprite Setup

This guide covers two approaches to get the Godot project running before final art is ready.

---

## Option A — Generate PNG Placeholders (Recommended)

Run the included generator script to produce all 13 sprites as labeled, color-coded PNGs at the correct sizes.

### Prerequisites

```bash
pip install Pillow
```

### Run

From the repo root:

```bash
python tools/generate_placeholders.py
```

This writes all files into `assets/sprites/`:

| File | Color | Label |
|---|---|---|
| `ball.png` | Silver-grey | BALL |
| `flipper_left.png` | Dark grey | FLIP L |
| `flipper_right.png` | Dark grey | FLIP R |
| `bumper_default.png` | Light grey | BUMPER |
| `bumper_lit.png` | Yellow | BUMPER! |
| `target_active.png` | Red | TGT ON |
| `target_inactive.png` | Grey | TGT OFF |
| `table_bg.png` | Dark green | TABLE BG |
| `hud_panel.png` | Black (semi-transparent) | HUD |
| `ball_indicator.png` | Silver-grey | BALL |
| `leaderboard_bg.png` | Dark navy | LEADERBOARD |
| `attract_logo.png` | Dark blue | LOGO |
| `attract_bg.png` | Very dark blue | ATTRACT BG |

After running, commit the generated files:

```bash
git add assets/sprites/
git commit -m "assets: add generated placeholder sprites"
```

---

## Option B — Godot PlaceholderTexture2D (No Script Needed)

Use this if you want to open the project in Godot immediately without running any scripts.

### Steps

1. Open your scene in the Godot editor
2. Select a node that has a `Texture` or `Texture2D` property (e.g., the `Sprite2D` child of `Ball`)
3. In the **Inspector**, click the texture slot
4. Choose **New PlaceholderTexture2D**
5. Set `Width` and `Height` to match the asset spec sizes (e.g., 32×32 for the ball)
6. Godot renders a magenta rectangle in the editor and at runtime

### Sizes Quick Reference

| Node | Texture Property | Size |
|---|---|---|
| Ball > Sprite2D | `texture` | 32 × 32 |
| Flipper (left) > Sprite2D | `texture` | 160 × 40 |
| Flipper (right) > Sprite2D | `texture` | 160 × 40 |
| Bumper > Sprite2D | `texture` | 80 × 80 |
| Target > Sprite2D | `texture` | 48 × 64 |
| Main > TextureRect (bg) | `texture` | 1080 × 1920 |
| UIRenderer > HUD panel | `texture` | 1080 × 200 |
| UIRenderer > Leaderboard bg | `texture` | 800 × 960 |

> **Note:** `PlaceholderTexture2D` values are **not** saved with the scene if you later replace them with real textures. This approach is fine for smoke testing but Option A is better for version-controlled iteration.

---

## Swapping in Final Art

When final sprites are ready:

1. Place the final PNG in the same path (e.g., `assets/sprites/ball.png`)
2. Godot auto-reimports on next editor open — no scene edits needed if the path hasn't changed
3. Check import settings: set **Filter = Nearest** for ball, flipper sprites to avoid blurring
4. Run the smoke test again to confirm no visual regressions

---

## Related

- Full asset sizes and styles: `docs/asset-spec.md`
- Godot editor setup: `docs/godot-setup-guide.md`
- Placeholder generator: `tools/generate_placeholders.py`
