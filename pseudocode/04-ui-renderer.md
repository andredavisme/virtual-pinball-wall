# Pseudocode: UI Renderer (M3)

## File: `src/ui/renderer`

```
INITIALIZE display in portrait mode (e.g. 1080x1920)
LOAD table background image (scaled to display)
LOAD sprite assets (ball, flippers, bumpers, targets)

FUNCTION render_frame(game_state, ball, flippers, targets, bumpers, score, balls_remaining):

  DRAW background

  FOR EACH bumper:
    IF bumper.hit_animation_active:
      DRAW bumper_lit sprite at bumper.position
    ELSE:
      DRAW bumper sprite at bumper.position

  FOR EACH target:
    IF target.active:
      DRAW target_active sprite
    ELSE:
      DRAW target_inactive sprite

  FOR EACH flipper:
    DRAW flipper sprite rotated to flipper.current_angle at flipper.pivot_point

  DRAW ball sprite at ball.position

  -- HUD (top of vertical screen) --
  DRAW score text (top-center)
  DRAW ball count indicator (top-right)

  IF game_state == PAUSED:
    DRAW pause overlay

  IF game_state == GAME_OVER:
    DRAW game_over overlay
    FETCH leaderboard from Supabase
    DRAW leaderboard table

  IF game_state == ATTRACT:
    DRAW attract screen animation
    DRAW high score display

  PRESENT frame to display
```
