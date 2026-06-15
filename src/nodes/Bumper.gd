# Bumper.gd
# Area2D — circular bumper that applies an impulse to the ball on contact.
# Pseudocode source: pseudocode/02-physics-engine.md

extends Area2D

const BOUNCE_FORCE: float = 400.0

@export var score_value: int = 100  # Override via table config at runtime

signal bumper_hit(value: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("ball"):
		var direction: Vector2 = (body.global_position - global_position).normalized()
		body.apply_central_impulse(direction * BOUNCE_FORCE)
		emit_signal("bumper_hit", score_value)
		_play_hit_feedback()

func _play_hit_feedback() -> void:
	# Trigger animation and sound — assets wired in scene
	# Animator node named "AnimationPlayer" expected as child
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("hit")
