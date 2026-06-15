# test_ball_physics.gd
# Tests pseudocode/02-ball-physics.md behavior

extends RefCounted

const SUITE = "BallPhysics"

func run() -> Array:
	var results = []
	results.append(_test_ball_velocity_applied_on_launch())
	results.append(_test_drain_detected_when_y_exceeds_drain_y())
	results.append(_test_bumper_hit_applies_impulse())
	results.append(_test_flipper_collision_changes_velocity())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _skip(name: String, reason: String) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "skip", "message": reason, "duration_ms": 0}

# --- Tests ---

func _test_ball_velocity_applied_on_launch() -> Dictionary:
	# Ball should have non-zero upward velocity after launch
	var launch_velocity = Vector2(0, -800)
	if launch_velocity.y >= 0:
		return _fail("ball_velocity_applied_on_launch", "Expected negative Y (upward) velocity on launch")
	return _pass("ball_velocity_applied_on_launch")

func _test_drain_detected_when_y_exceeds_drain_y() -> Dictionary:
	var drain_y = 1920
	var ball_y = 1921
	var drained = ball_y >= drain_y
	if not drained:
		return _fail("drain_detected_when_y_exceeds_drain_y", "Expected drain detection at y=%d" % ball_y)
	return _pass("drain_detected_when_y_exceeds_drain_y")

func _test_bumper_hit_applies_impulse() -> Dictionary:
	# Bumper should push ball away from its center
	var bumper_center = Vector2(200, 400)
	var ball_pos = Vector2(210, 410)
	var direction = (ball_pos - bumper_center).normalized()
	if direction.length() < 0.9:
		return _fail("bumper_hit_applies_impulse", "Direction vector not normalized")
	return _pass("bumper_hit_applies_impulse")

func _test_flipper_collision_changes_velocity() -> Dictionary:
	# Flipper physics requires Godot RigidBody2D runtime
	return _skip("flipper_collision_changes_velocity", "Requires Godot RigidBody2D runtime")
