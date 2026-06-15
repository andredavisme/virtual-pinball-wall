# Flipper.gd
# AnimatableBody2D — left or right flipper.
# Pseudocode source: pseudocode/02-physics-engine.md

extends AnimatableBody2D

var rest_angle: float   = 0.0
var active_angle: float = 0.0

func init(flipper_config: Dictionary) -> void:
	rest_angle   = deg_to_rad(flipper_config.get("angle_rest", 0.0))
	active_angle = deg_to_rad(flipper_config.get("angle_active", 0.0))
	rotation     = rest_angle

func activate() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", active_angle, 0.08)

func release() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", rest_angle, 0.12)
