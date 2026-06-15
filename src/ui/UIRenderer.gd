# UIRenderer.gd
# CanvasLayer — manages all UI elements: HUD, overlays, leaderboard.
# Called by GameLoop each _physics_process tick via update_frame().
# Pseudocode source: pseudocode/04-ui-renderer.md

extends CanvasLayer

# HUD labels (assign in Inspector)
@onready var score_label: Label       = $HUD/ScoreLabel
@onready var ball_count_label: Label  = $HUD/BallCountLabel

# Overlays
@onready var pause_overlay: Control      = $PauseOverlay
@onready var game_over_overlay: Control  = $GameOverOverlay
@onready var attract_screen: Control     = $AttractScreen
@onready var initials_prompt: Control    = $InitialsPrompt
@onready var high_score_label: Label     = $AttractScreen/HighScoreLabel
@onready var leaderboard_table: VBoxContainer = $GameOverOverlay/LeaderboardTable

signal initials_confirmed(player_initials: String)

func _ready() -> void:
	# Portrait mode — set in Project Settings: Display > Window > Size
	pause_overlay.visible     = false
	game_over_overlay.visible = false
	attract_screen.visible    = false
	initials_prompt.visible   = false

func update_frame(
		game_state,
		ball: RigidBody2D,
		flippers: Array,
		targets: Array,
		bumpers: Array,
		score: int,
		balls_remaining: int,
		cached_leaderboard: Array
	) -> void:

	score_label.text      = str(score)
	ball_count_label.text = str(balls_remaining)

	# State overlays
	pause_overlay.visible = (game_state == GameLoop.GameState.PAUSED)

	if game_state == GameLoop.GameState.GAME_OVER:
		game_over_overlay.visible = true
		initials_prompt.visible   = true
		_populate_leaderboard(cached_leaderboard)
	else:
		game_over_overlay.visible = false
		initials_prompt.visible   = false

	if game_state == GameLoop.GameState.ATTRACT:
		attract_screen.visible = true
		if cached_leaderboard.size() > 0:
			high_score_label.text = str(cached_leaderboard[0].get("score", 0))
		else:
			high_score_label.text = "---"
	else:
		attract_screen.visible = false

func show_attract_screen(leaderboard: Array) -> void:
	attract_screen.visible = true
	if leaderboard.size() > 0:
		high_score_label.text = str(leaderboard[0].get("score", 0))

func show_pause_overlay(visible: bool) -> void:
	pause_overlay.visible = visible

func show_initials_prompt() -> void:
	initials_prompt.visible = true

func _populate_leaderboard(leaderboard: Array) -> void:
	# Clear existing rows
	for child in leaderboard_table.get_children():
		child.queue_free()
	# Add a label row per entry
	for entry in leaderboard:
		var row = Label.new()
		row.text = "%s  %d" % [entry.get("player_initials", "???"), entry.get("score", 0)]
		leaderboard_table.add_child(row)
