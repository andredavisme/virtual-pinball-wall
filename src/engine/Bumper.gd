# Bumper.gd (extends Area2D)
# M1 — Physics: Bumper
# Pseudocode reference: pseudocode/02-physics-engine.md
# STATUS: STUB — implement from pseudocode
extends Area2D

const BOUNCE_FORCE: float = 400.0
var score_value: int = 100

signal bumper_hit(points: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("ball"):
		var direction = (body.global_position - global_position).normalized()
		body.apply_central_impulse(direction * BOUNCE_FORCE)
		emit_signal("bumper_hit", score_value)
		# TODO: play animation + sound
