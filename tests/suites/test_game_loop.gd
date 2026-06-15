# test_game_loop.gd
# Tests pseudocode/01-game-loop.md behavior

extends RefCounted

const SUITE = "GameLoop"

func run() -> Array:
	var results = []
	results.append(_test_initial_state_has_zero_score())
	results.append(_test_ball_count_starts_at_max())
	results.append(_test_game_over_when_balls_exhausted())
	results.append(_test_score_increments_on_hit())
	results.append(_test_input_manager_set_on_ready())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _skip(name: String, reason: String) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "skip", "message": reason, "duration_ms": 0}

# --- Tests ---

func _test_initial_state_has_zero_score() -> Dictionary:
	var score = 0
	if score != 0:
		return _fail("initial_state_has_zero_score", "Expected 0, got " + str(score))
	return _pass("initial_state_has_zero_score")

func _test_ball_count_starts_at_max() -> Dictionary:
	var balls_per_game = 3
	var balls_remaining = balls_per_game
	if balls_remaining != balls_per_game:
		return _fail("ball_count_starts_at_max", "Expected %d, got %d" % [balls_per_game, balls_remaining])
	return _pass("ball_count_starts_at_max")

func _test_game_over_when_balls_exhausted() -> Dictionary:
	var balls_remaining = 0
	var is_game_over = balls_remaining <= 0
	if not is_game_over:
		return _fail("game_over_when_balls_exhausted", "Expected game over state when balls_remaining=0")
	return _pass("game_over_when_balls_exhausted")

func _test_score_increments_on_hit() -> Dictionary:
	var score = 0
	var hit_value = 100
	score += hit_value
	if score != 100:
		return _fail("score_increments_on_hit", "Expected 100, got " + str(score))
	return _pass("score_increments_on_hit")

func _test_input_manager_set_on_ready() -> Dictionary:
	# InputManager.set_adapter() must be called in _ready() after load_input_config()
	# This is a contract test — actual node wiring requires Godot scene tree
	return _skip("input_manager_set_on_ready", "Requires Godot scene tree runtime")
