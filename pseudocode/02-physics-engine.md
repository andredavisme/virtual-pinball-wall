# Pseudocode: Physics Engine (M1)

## File: `src/engine/physics`

```
STRUCT Ball:
  position (x, y)
  velocity (vx, vy)
  radius
  mass

STRUCT Flipper:
  pivot_point (x, y)
  length
  angle_rest
  angle_active
  current_angle
  side (LEFT | RIGHT)

FUNCTION update_physics(ball, flippers, obstacles, dt):
  APPLY gravity to ball.velocity
  UPDATE ball.position += ball.velocity * dt

  FOR EACH wall boundary:
    IF ball intersects wall:
      REFLECT ball.velocity off wall normal
      APPLY restitution coefficient

  FOR EACH flipper:
    IF ball intersects flipper surface:
      CALCULATE collision normal from flipper angle
      APPLY impulse to ball based on flipper angular velocity

  FOR EACH bumper:
    IF ball intersects bumper:
      APPLY outward impulse to ball
      INCREMENT bumper hit score
      TRIGGER bumper animation

  FOR EACH target:
    IF ball intersects target AND target.active:
      SET target.active = FALSE
      INCREMENT target score
      TRIGGER target animation

  IF ball.position.y > drain_boundary:
    RETURN DRAINED

  RETURN ball
```
