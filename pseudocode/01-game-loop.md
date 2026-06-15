# Pseudocode: Game Loop (M1)

## Engine: Godot 4.x | File: `src/GameLoop.gd` (extends Node)

```
ON _ready():
  LOAD table config from Supabase or local JSON
  INITIALIZE physics world (Godot handles gravity via RigidBody2D)
  INITIALIZE ball (RigidBody2D) at launch position
  INITIALIZE flippers (AnimatableBody2D x2)
  INITIALIZE bumpers/targets (Area2D + CollisionShape2D)
  CONNECT InputAdapter signals
  SET game_state = ATTRACT
  CALL show_attract_screen()

ON _physics_process(delta):
  READ InputEvent from active InputAdapter

  MATCH game_state:

    ATTRACT:
      IF InputEvent == LAUNCH:
        SET game_state = PLAYING
        CALL launch_ball()

    PLAYING:
      IF InputEvent == LEFT_FLIPPER_DOWN:  CALL flipper_left.activate()
      IF InputEvent == LEFT_FLIPPER_UP:    CALL flipper_left.release()
      IF InputEvent == RIGHT_FLIPPER_DOWN: CALL flipper_right.activate()
      IF InputEvent == RIGHT_FLIPPER_UP:   CALL flipper_right.release()
      IF InputEvent == TILT:               CALL trigger_tilt()
      IF InputEvent == PAUSE:              SET game_state = PAUSED

      # Physics update handled automatically by Godot engine each tick
      # Collision signals emitted by Area2D nodes (bumpers, drain, targets)

      IF drain_zone.body_entered(ball):
        DECREMENT balls_remaining
        IF balls_remaining == 0:
          SET game_state = GAME_OVER
          CALL post_score_to_supabase(current_score)
        ELSE:
          CALL reset_ball_to_launch_position()

    PAUSED:
      IF InputEvent == PAUSE: SET game_state = PLAYING

    GAME_OVER:
      CALL show_leaderboard()
      IF InputEvent == any:
        CALL reset_game()
        SET game_state = ATTRACT

# Godot renders each frame automatically via SceneTree
# No manual SLEEP or RENDER call needed
```
