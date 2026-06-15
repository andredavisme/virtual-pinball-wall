# Target.gd
# Area2D — drop target or standup target.
# `active` mirrors the persisted default from table config (schema-map note).
# At runtime, active is toggled on hit; reset on new ball via reset_targets().
# Pseudocode source: pseudocode/02-physics-engine.md

extends Area2D

@export var score_value: int = 50
var active: bool = true

signal target_hit(value: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.is_in_group("ball") and active:
		active = false
		emit_signal("target_hit", score_value)

func reset() -> void:
	active = true
