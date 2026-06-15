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
    # Signals connected by GameLoop, not self
    # DrainZone and Bumpers connect via body_entered(body)
```

### Flipper Node: `AnimatableBody2D`
```
NODE Flipper (AnimatableBody2D):
  SHAPE: CapsuleShape2D or custom polygon (flipper profile)
  # Angles loaded from TableConfig at game start — not hardcoded
  rest_angle:   float  # e.g. -30 degrees (down position)
  active_angle: float  # e.g. +30 degrees (up position)

  FUNCTION init(flipper_config):
    rest_angle   = flipper_config.angle_rest
    active_angle = flipper_config.angle_active
    rotation     = rest_angle

  FUNCTION activate():
    TWEEN rotation from rest_angle to active_angle over 0.08s

  FUNCTION release():
    TWEEN rotation from active_angle to rest_angle over 0.12s
```

### Bumper Node: `Area2D`
```
NODE Bumper (Area2D):
  SHAPE: CircleShape2D
  BOUNCE_FORCE = 400  # impulse magnitude (tune per feel)
  score_value: int    # loaded from TableConfig

  ON body_entered(body):
    # `body` is the object that entered — must verify it is the Ball
    IF body is RigidBody2D AND body.is_in_group("ball"):
      direction = (body.global_position - self.global_position).normalized()
      body.apply_central_impulse(direction * BOUNCE_FORCE)
      EMIT signal: bumper_hit(score_value)
      PLAY bumper animation + sound
```

### Drain Zone: `Area2D`
```
NODE DrainZone (Area2D):
  SHAPE: RectangleShape2D (full width, bottom of table)
  # drain_y position loaded from TableConfig

  ON body_entered(body):
    IF body is RigidBody2D AND body.is_in_group("ball"):
      EMIT signal: ball_drained
      HIDE ball (GameLoop handles respawn or game over)
```

### Walls / Table Boundary
```
NODE TableBounds (StaticBody2D):
  SHAPE: Polygon2D tracing table outline  # coordinates from TableConfig.walls[]
  PHYSICS MATERIAL: bounce = 0.4, friction = 0.1
```
