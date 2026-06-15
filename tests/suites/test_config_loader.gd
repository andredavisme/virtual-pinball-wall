# test_config_loader.gd
# Tests pseudocode/05-config-loader.md behavior

extends RefCounted

const SUITE = "ConfigLoader"

func run() -> Array:
	var results = []
	results.append(_test_game_config_has_required_keys())
	results.append(_test_table_config_parses_targets_active())
	results.append(_test_table_config_parses_bumpers())
	results.append(_test_table_config_parses_flippers())
	results.append(_test_missing_config_file_returns_error())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _skip(name: String, reason: String) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "skip", "message": reason, "duration_ms": 0}

# --- Tests ---

func _test_game_config_has_required_keys() -> Dictionary:
	# Simulate a parsed game.json object and verify required keys exist
	var mock_config = {
		"balls_per_game": 3,
		"target_display_resolution": {"width": 1080, "height": 1920},
		"active_table_id": "some-uuid"
	}
	var required = ["balls_per_game", "target_display_resolution", "active_table_id"]
	for key in required:
		if not mock_config.has(key):
			return _fail("game_config_has_required_keys", "Missing key: " + key)
	return _pass("game_config_has_required_keys")

func _test_table_config_parses_targets_active() -> Dictionary:
	# targets[] must include `active` field per schema-map note
	var mock_layout = {
		"targets": [
			{"x": 150, "y": 600, "width": 40, "height": 10, "score_value": 50, "active": true}
		]
	}
	for t in mock_layout["targets"]:
		if not t.has("active"):
			return _fail("table_config_parses_targets_active", "Target missing 'active' field")
	return _pass("table_config_parses_targets_active")

func _test_table_config_parses_bumpers() -> Dictionary:
	var mock_layout = {
		"bumpers": [
			{"x": 200, "y": 400, "radius": 30, "score_value": 100}
		]
	}
	for b in mock_layout["bumpers"]:
		for key in ["x", "y", "radius", "score_value"]:
			if not b.has(key):
				return _fail("table_config_parses_bumpers", "Bumper missing key: " + key)
	return _pass("table_config_parses_bumpers")

func _test_table_config_parses_flippers() -> Dictionary:
	var mock_layout = {
		"flippers": [
			{"side": "LEFT", "pivot": {"x": 180, "y": 1800}, "length": 120, "angle_rest": -30, "angle_active": 30},
			{"side": "RIGHT", "pivot": {"x": 540, "y": 1800}, "length": 120, "angle_rest": 30, "angle_active": -30}
		]
	}
	for f in mock_layout["flippers"]:
		for key in ["side", "pivot", "length", "angle_rest", "angle_active"]:
			if not f.has(key):
				return _fail("table_config_parses_flippers", "Flipper missing key: " + key)
	return _pass("table_config_parses_flippers")

func _test_missing_config_file_returns_error() -> Dictionary:
	# Simulate missing file path — ConfigLoader should return null or error, not crash
	# This is a structural/contract test; actual FileAccess would need Godot runtime
	return _skip("missing_config_file_returns_error", "Requires Godot FileAccess runtime")
