# GameLoop.gd (extends Node)
# M1 — Core Game Engine
# Pseudocode reference: pseudocode/01-game-loop.md
# STATUS: STUB — implement from pseudocode
extends Node

enum GameState { ATTRACT, PLAYING, PAUSED, GAME_OVER }

var game_state: GameState = GameState.ATTRACT
var current_score: int = 0
var balls_remaining: int = 3
var initials_confirmed: bool = false
var cached_leaderboard: Array = []

var game_config  # GameConfig resource
var table_config # TableConfig resource

func _ready() -> void:
	pass # TODO: load configs, initialize nodes, connect signals

func _physics_process(delta: float) -> void:
	pass # TODO: read InputManager, match game_state, dispatch actions

func on_ball_drained() -> void:
	pass # TODO: decrement balls, handle GAME_OVER or respawn

func on_initials_confirmed(player_initials: String) -> void:
	pass # TODO: validate, call ScoreService.post_score()

func reset_game() -> void:
	pass # TODO: reset score, balls, state
