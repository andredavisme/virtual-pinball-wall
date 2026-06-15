# GameLoop.gd
# Main game controller. extends Node — attach to root scene node.
# Pseudocode source: pseudocode/01-game-loop.md

extends Node

enum GameState { ATTRACT, PLAYING, PAUSED, GAME_OVER }

# --- Child node references (assign in Inspector or via $path) ---
@onready var ball: RigidBody2D             = $Ball
@onready var flipper_left: AnimatableBody2D  = $FlipperLeft
@onready var flipper_right: AnimatableBody2D = $FlipperRight
@onready var drain_zone: Area2D             = $DrainZone
@onready var ui: CanvasLayer                = $UIRenderer

# --- State ---
var game_config: Dictionary = {}
var table_config: Dictionary = {}
var game_state: GameState = GameState.ATTRACT
var balls_remaining: int = 3
var current_score: int = 0
var initials_confirmed: bool = false
var cached_leaderboard: Array = []

func _ready() -> void:
	game_config = ConfigLoader.load_game_config("res://config/game.json")
	table_config = await ConfigLoader.load_table_config(game_config.get("active_table_id", ""))

	var input_adapter = ConfigLoader.load_input_config("res://config/input.json")
	InputManager.set_adapter(input_adapter)

	_init_physics()

	balls_remaining = game_config.get("balls_per_game", 3)
	current_score   = 0
	game_state      = GameState.ATTRACT

	drain_zone.ball_drained.connect(on_ball_drained)

	ui.show_attract_screen(cached_leaderboard)

func _physics_process(_delta: float) -> void:
	var input_event = InputManager.get_event()

	match game_state:
		GameState.ATTRACT:
			if input_event == InputManager.InputEvent.LAUNCH:
				game_state = GameState.PLAYING
				_launch_ball()

		GameState.PLAYING:
			if input_event == InputManager.InputEvent.LEFT_FLIPPER_DOWN:
				flipper_left.activate()
			elif input_event == InputManager.InputEvent.LEFT_FLIPPER_UP:
				flipper_left.release()
			elif input_event == InputManager.InputEvent.RIGHT_FLIPPER_DOWN:
				flipper_right.activate()
			elif input_event == InputManager.InputEvent.RIGHT_FLIPPER_UP:
				flipper_right.release()
			elif input_event == InputManager.InputEvent.TILT:
				_trigger_tilt()
			elif input_event == InputManager.InputEvent.PAUSE:
				game_state = GameState.PAUSED
				ui.show_pause_overlay(true)

		GameState.PAUSED:
			if input_event == InputManager.InputEvent.PAUSE:
				game_state = GameState.PLAYING
				ui.show_pause_overlay(false)

		GameState.GAME_OVER:
			if input_event != null and initials_confirmed:
				_reset_game()
				game_state = GameState.ATTRACT
				ui.show_attract_screen(cached_leaderboard)

	ui.update_frame(game_state, ball, [flipper_left, flipper_right],
		table_config.get("targets", []), table_config.get("bumpers", []),
		current_score, balls_remaining, cached_leaderboard)

func on_ball_drained() -> void:
	balls_remaining -= 1
	if balls_remaining <= 0:
		game_state = GameState.GAME_OVER
		cached_leaderboard = await ScoreService.get_leaderboard(
			game_config.get("active_table_id", ""))
		ui.show_initials_prompt()
	else:
		_reset_ball_to_launch_position()

func on_initials_confirmed(player_initials: String) -> void:
	initials_confirmed = true
	await ScoreService.post_score(
		player_initials, current_score, game_config.get("active_table_id", ""))

func on_score_hit(value: int) -> void:
	current_score += value

# --- Private helpers ---

func _init_physics() -> void:
	var launch_pos = table_config.get("launch_position", {"x": 0, "y": 0})
	ball.position = Vector2(launch_pos.get("x", 0), launch_pos.get("y", 0))

	var flippers = table_config.get("flippers", [])
	for f in flippers:
		if f.get("side") == "LEFT":
			flipper_left.init(f)
		elif f.get("side") == "RIGHT":
			flipper_right.init(f)

func _launch_ball() -> void:
	ball.visible = true
	ball.freeze   = false
	ball.apply_central_impulse(Vector2(0, -800))

func _reset_ball_to_launch_position() -> void:
	var launch_pos = table_config.get("launch_position", {"x": 0, "y": 0})
	ball.freeze    = true
	ball.linear_velocity = Vector2.ZERO
	ball.position  = Vector2(launch_pos.get("x", 0), launch_pos.get("y", 0))
	ball.freeze    = false

func _trigger_tilt() -> void:
	# Tilt: freeze ball briefly and penalise
	ball.linear_velocity = Vector2.ZERO


func _reset_game() -> void:
	current_score     = 0
	balls_remaining   = game_config.get("balls_per_game", 3)
	initials_confirmed = false
	_reset_ball_to_launch_position()
