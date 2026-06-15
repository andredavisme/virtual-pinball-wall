# Flipper.gd (extends AnimatableBody2D)
# M1 — Physics: Flipper
# Pseudocode reference: pseudocode/02-physics-engine.md
# STATUS: STUB — implement from pseudocode
extends AnimatableBody2D

var rest_angle: float = 0.0
var active_angle: float = 0.0

func init(flipper_config: Dictionary) -> void:
	rest_angle   = flipper_config.get("angle_rest", -30.0)
	active_angle = flipper_config.get("angle_active", 30.0)
	rotation_degrees = rest_angle

func activate() -> void:
	pass # TODO: tween rotation to active_angle over 0.08s

func release() -> void:
	pass # TODO: tween rotation to rest_angle over 0.12s
