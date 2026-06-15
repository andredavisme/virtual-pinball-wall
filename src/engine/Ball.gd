# Ball.gd (extends RigidBody2D)
# M1 — Physics: Ball
# Pseudocode reference: pseudocode/02-physics-engine.md
# STATUS: STUB — implement from pseudocode
extends RigidBody2D

func _ready() -> void:
	add_to_group("ball")
	# Physics material (bounce, friction) set in Godot editor or via PhysicsMaterial resource
