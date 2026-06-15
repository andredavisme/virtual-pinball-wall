# Pseudocode: Physics Engine (M1)

## Engine: Godot 4.x | Godot handles physics natively via PhysicsServer2D

### Ball Node: `RigidBody2D`
```
NODE Ball (RigidBody2D):
  SHAPE: CircleShape2D (radius = table scale units)
  PHYSICS MATERIAL:
    bounce = 0.6       # realistic pinball rebound
    friction = 0.05    # low friction on playfield
  gravity_scale = 1.0  # Godot default gravity applies
  linear_damp = 0.1    # slight air resistance

  ON _ready():
    CONNECT Area2D.body_entered signals from bumpers, targets, drain
```

### Flipper Node: `AnimatableBody2D`
```
NODE Flipper (AnimatableBody2D):
  SHAPE: CapsuleShape2D or custom polygon (flipper profile)
  REST_ANGLE   = -30 degrees (down position)
  ACTIVE_ANGLE = +30 degrees (up position)

  FUNCTION activate():
    TWEEN rotation from REST_ANGLE to ACTIVE_ANGLE over 0.08s

  FUNCTION release():
    TWEEN rotation from ACTIVE_ANGLE to REST_ANGLE over 0.12s
```

### Bumper Node: `Area2D`
```
NODE Bumper (Area2D):
  SHAPE: CircleShape2D
  BOUNCE_FORCE = 400  # impulse magnitude (tune per feel)

  ON body_entered(ball):
    direction = (ball.global_position - self.global_position).normalized()
    ball.apply_central_impulse(direction * BOUNCE_FORCE)
    EMIT signal: bumper_hit(points_value)
    PLAY bumper animation + sound
```

### Drain Zone: `Area2D`
```
NODE DrainZone (Area2D):
  SHAPE: RectangleShape2D (full width, bottom of table)

  ON body_entered(ball):
    EMIT signal: ball_drained
    REMOVE ball from scene or teleport to launch position
```

### Walls / Table Boundary
```
NODE TableBounds (StaticBody2D):
  SHAPE: Polygon2D tracing table outline
  PHYSICS MATERIAL: bounce = 0.4, friction = 0.1
```
