# DrainZone.gd (extends Area2D)
# M1 — Physics: Drain
# Pseudocode reference: pseudocode/02-physics-engine.md
# STATUS: STUB — implement from pseudocode
extends Area2D

signal ball_drained

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("ball"):
		body.hide()
		emit_signal("ball_drained")
