# UIRenderer.gd (extends CanvasLayer)
# M3 — Vertical Display Layout
# Pseudocode reference: pseudocode/04-ui-renderer.md
# STATUS: STUB — implement from pseudocode
extends CanvasLayer

func _ready() -> void:
	pass # TODO: load and position all UI nodes for 1080x1920 portrait layout

func update_frame(game_state: int, ball: Node, flippers: Array, targets: Array,
		bumpers: Array, score: int, balls_remaining: int, cached_leaderboard: Array) -> void:
	pass # TODO: update all node visibility, labels, sprite positions per state
