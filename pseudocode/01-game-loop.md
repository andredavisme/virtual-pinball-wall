# Pseudocode: Game Loop (M1)

## Engine: Godot 4.x | File: `src/GameLoop.gd` (extends Node)

```
ON _ready():
  LOAD game_config from local file (balls_per_game, resolution, active_table_id)
  LOAD table_config from Supabase via load_table_config(game_config.active_table_id)
  INITIALIZE physics world (Godot handles gravity via RigidBody2D)
  INITIALIZE ball (RigidBody2D) at table_config.launch_position
  INITIALIZE flipper_left  (AnimatableBody2D) with table_config.flippers[LEFT]
  INITIALIZE flipper_right (AnimatableBody2D) with table_config.flippers[RIGHT]
  INITIALIZE bumpers/targets (Area2D) from table_config.bumpers / table_config.targets
  CONNECT InputAdapter signals
  SET balls_remaining = game_config.balls_per_game
  SET current_score = 0
  SET game_state = ATTRACT
  CALL show_attract_screen()

ON _physics_process(delta):
  READ input_event from InputManager.get_event()

  MATCH game_state:

    ATTRACT:
      IF input_event == LAUNCH:
        SET game_state = PLAYING
        CALL launch_ball()

    PLAYING:
      IF input_event == LEFT_FLIPPER_DOWN:  CALL flipper_left.activate()
      IF input_event == LEFT_FLIPPER_UP:    CALL flipper_left.release()
      IF input_event == RIGHT_FLIPPER_DOWN: CALL flipper_right.activate()
      IF input_event == RIGHT_FLIPPER_UP:   CALL flipper_right.release()
      IF input_event == TILT:               CALL trigger_tilt()
      IF input_event == PAUSE:              SET game_state = PAUSED
      # Physics update handled automatically by Godot each tick
      # Collision signals emitted by Area2D nodes (bumpers, drain, targets)

    PAUSED:
      IF input_event == PAUSE: SET game_state = PLAYING

    GAME_OVER:
      # Initials entry handled by UI overlay (non-blocking)
      # Score POST triggered after initials confirmed
      IF input_event == any AND initials_confirmed:
        CALL reset_game()
        SET game_state = ATTRACT

FUNCTION on_ball_drained():
  # Connected to DrainZone.ball_drained signal
  DECREMENT balls_remaining
  IF balls_remaining == 0:
    SET game_state = GAME_OVER
    CALL fetch_and_cache_leaderboard(game_config.active_table_id)
    CALL show_initials_prompt()  # non-blocking UI overlay
  ELSE:
    CALL reset_ball_to_launch_position()

FUNCTION on_initials_confirmed(player_initials):
  # Triggered by initials UI overlay on confirm
  SET initials_confirmed = true
  CALL post_score(player_initials, current_score, game_config.active_table_id)

# Godot renders each frame automatically via SceneTree
# No manual SLEEP or RENDER call needed
```
