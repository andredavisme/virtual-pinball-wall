# TableBounds.gd
# StaticBody2D — outer walls of the pinball table.
# Wall coordinates are loaded from TableConfig.walls[] at game start.
# Pseudocode source: pseudocode/02-physics-engine.md

extends StaticBody2D

func build_from_config(walls: Array) -> void:
	# Each wall is { start: {x,y}, end: {x,y} }
	# Creates a CollisionPolygon2D from the wall segments
	for wall in walls:
		var seg = CollisionShape2D.new()
		var shape = SegmentShape2D.new()
		shape.a = Vector2(wall["start"]["x"], wall["start"]["y"])
		shape.b = Vector2(wall["end"]["x"],   wall["end"]["y"])
		seg.shape = shape
		add_child(seg)
