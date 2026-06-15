# Pseudocode: Game Loop (M1)

## File: `src/engine/game_loop`

```
INITIALIZE display (vertical resolution)
LOAD table config from Supabase or local file
INITIALIZE physics world (gravity, boundaries)
INITIALIZE ball at launch position
SET game_state = ATTRACT

LOOP:
  READ InputEvent from active InputAdapter

  IF game_state == ATTRACT:
    IF InputEvent == LAUNCH:
      SET game_state = PLAYING
      LAUNCH ball

  IF game_state == PLAYING:
    IF InputEvent == LEFT_FLIPPER_DOWN:  activate left flipper
    IF InputEvent == LEFT_FLIPPER_UP:    release left flipper
    IF InputEvent == RIGHT_FLIPPER_DOWN: activate right flipper
    IF InputEvent == RIGHT_FLIPPER_UP:   release right flipper
    IF InputEvent == TILT:               trigger tilt penalty
    IF InputEvent == PAUSE:              SET game_state = PAUSED

    UPDATE physics (ball position, velocity, collisions)
    CHECK collisions (bumpers, targets, flippers, walls, drain)
    UPDATE score

    IF ball drained AND balls_remaining == 0:
      SET game_state = GAME_OVER
      POST score to Supabase

    IF ball drained AND balls_remaining > 0:
      DECREMENT balls_remaining
      RESET ball to launch position

  IF game_state == PAUSED:
    IF InputEvent == PAUSE: SET game_state = PLAYING

  IF game_state == GAME_OVER:
    DISPLAY score + leaderboard
    WAIT for input
    RESET game
    SET game_state = ATTRACT

  RENDER frame to vertical display
  SLEEP until next frame tick
END LOOP
```
