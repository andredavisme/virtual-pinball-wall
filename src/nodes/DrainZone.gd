# DrainZone.gd
# Area2D — full-width zone at the bottom of the table.
# Emits ball_drained signal when ball enters.
# Pseudocode source: pseudocode/02-physics-engine.md

extends Area2D

signal ball_drained

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("ball"):
		body.visible = false
		body.freeze  = true
		emit_signal("ball_drained")
