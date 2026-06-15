# Pseudocode: UI Renderer (M3)

## Engine: Godot 4.x | File: `src/ui/UIRenderer.gd` (extends CanvasLayer)
## Note: Godot renders automatically each frame via SceneTree.
## There is NO manual `PRESENT frame` call. Sprites and Labels update their
## own draw state. This pseudocode maps to Node properties + _draw() overrides.

```
ON _ready():
  INITIALIZE display in portrait mode (e.g. 1080x1920)
  LOAD table background (TextureRect scaled to display)
  LOAD sprite assets (ball, flippers, bumpers, targets)
  # Leaderboard data is NOT fetched here — cached externally on GAME_OVER entry

FUNCTION update_frame(game_state, ball, flippers, targets, bumpers, score, balls_remaining, cached_leaderboard):
  # Called by GameLoop each _process() tick to sync visual state

  -- Background --
  background.visible = true

  -- Bumpers --
  FOR EACH bumper in bumpers:
    IF bumper.hit_animation_active:
      bumper_sprite.texture = bumper_lit_texture
    ELSE:
      bumper_sprite.texture = bumper_default_texture
    bumper_sprite.position = bumper.position

  -- Targets --
  FOR EACH target in targets:
    target_sprite.texture = target_active_texture IF target.active ELSE target_inactive_texture
    target_sprite.position = target.position

  -- Flippers --
  FOR EACH flipper in flippers:
    flipper_sprite.rotation = flipper.current_angle
    flipper_sprite.position = flipper.pivot_point

  -- Ball --
  ball_sprite.position = ball.position

  -- HUD (top of vertical screen) --
  score_label.text    = str(score)
  ball_count_label.text = str(balls_remaining)

  -- State Overlays --
  IF game_state == PAUSED:
    pause_overlay.visible = true
  ELSE:
    pause_overlay.visible = false

  IF game_state == GAME_OVER:
    game_over_overlay.visible = true
    initials_prompt.visible   = true
    # Draw leaderboard from pre-cached data — no network call here
    POPULATE leaderboard_table with cached_leaderboard
  ELSE:
    game_over_overlay.visible = false
    initials_prompt.visible   = false

  IF game_state == ATTRACT:
    attract_screen.visible  = true
    high_score_label.text   = str(cached_leaderboard[0].score) IF cached_leaderboard not empty
  ELSE:
    attract_screen.visible  = false
```
