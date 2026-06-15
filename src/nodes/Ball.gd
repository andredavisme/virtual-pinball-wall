# Ball.gd
# RigidBody2D — pinball ball.
# Pseudocode source: pseudocode/02-physics-engine.md
# Physics properties match schema-map physics material spec.

extends RigidBody2D

func _ready() -> void:
	# Group membership lets bumpers/drain verify collision body type
	add_to_group("ball")

	# Physics material values per pseudocode spec
	# Set in Inspector or via PhysicsMaterial resource:
	#   bounce    = 0.6
	#   friction  = 0.05
	# The following are set directly on the node:
	gravity_scale = 1.0
	linear_damp   = 0.1
