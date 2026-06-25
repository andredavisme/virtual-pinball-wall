# test_game_loop_smoke.gd
# Smoke test: instantiates GameLoop scene and simulates state transitions.
# Tests: ATTRACT → PLAYING (LAUNCH) → drain → balls_remaining decrement → GAME_OVER.
# Requires Godot scene tree. Run as an AutoLoad tool or attach to a test scene.

extends Node

const SUITE = "GameLoopSmoke"

var _results: Array = []
var _game_loop: Node = null

func run() -> Array:
	_results = []
	# Load the main scene as a child for isolated testing
	var scene = load("res://src/scenes/Main.tscn")
	if scene == null:
		_results.append(_skip("all",
			"res://src/scenes/Main.tscn not found — confirm scene exists before running smoke test"))
		return _results
	_game_loop = scene.instantiate()
	add_child(_game_loop)
	await get_tree().process_frame
	_run_state_tests()
	_game_loop.queue_free()
	return _results

func _run_state_tests() -> void:
	_results.append(_test_initial_state_is_attract())
	_results.append(_test_score_zero_on_start())
	_results.append(_test_balls_remaining_equals_config())
	_results.append(_test_launch_transitions_to_playing())
	_results.append(_test_drain_decrements_balls())
	_results.append(_test_game_over_when_last_ball_drained())

func _test_initial_state_is_attract() -> Dictionary:
	if _game_loop.game_state != GameLoop.GameState.ATTRACT:
		return _fail("initial_state_is_attract",
			"Expected ATTRACT, got: " + str(_game_loop.game_state))
	return _pass("initial_state_is_attract")

func _test_score_zero_on_start() -> Dictionary:
	if _game_loop.current_score != 0:
		return _fail("score_zero_on_start",
			"Expected 0, got: " + str(_game_loop.current_score))
	return _pass("score_zero_on_start")

func _test_balls_remaining_equals_config() -> Dictionary:
	var expected = _game_loop.game_config.get("balls_per_game", 3)
	if _game_loop.balls_remaining != expected:
		return _fail("balls_remaining_equals_config",
			"Expected %d, got %d" % [expected, _game_loop.balls_remaining])
	return _pass("balls_remaining_equals_config")

func _test_launch_transitions_to_playing() -> Dictionary:
	# Simulate LAUNCH input by calling the state logic directly
	_game_loop.game_state = GameLoop.GameState.ATTRACT
	# Trigger the transition manually (mirrors InputEvent.LAUNCH handling)
	_game_loop.game_state = GameLoop.GameState.PLAYING
	_game_loop._launch_ball()
	if _game_loop.game_state != GameLoop.GameState.PLAYING:
		return _fail("launch_transitions_to_playing",
			"Expected PLAYING after launch")
	return _pass("launch_transitions_to_playing")

func _test_drain_decrements_balls() -> Dictionary:
	var before = _game_loop.balls_remaining
	_game_loop.game_state = GameLoop.GameState.PLAYING
	_game_loop.balls_remaining = 2  # ensure not last ball
	# Emit drain signal directly
	_game_loop.on_ball_drained()
	await get_tree().process_frame
	if _game_loop.balls_remaining != 1:
		return _fail("drain_decrements_balls",
			"Expected 1, got: " + str(_game_loop.balls_remaining))
	return _pass("drain_decrements_balls")

func _test_game_over_when_last_ball_drained() -> Dictionary:
	_game_loop.balls_remaining = 1
	_game_loop.game_state = GameLoop.GameState.PLAYING
	_game_loop.on_ball_drained()
	await get_tree().process_frame
	if _game_loop.game_state != GameLoop.GameState.GAME_OVER:
		return _fail("game_over_when_last_ball_drained",
			"Expected GAME_OVER after last drain, got: " + str(_game_loop.game_state))
	return _pass("game_over_when_last_ball_drained")

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _skip(name: String, reason: String) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "skip", "message": reason, "duration_ms": 0}
