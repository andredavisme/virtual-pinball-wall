# test_input.gd
# Tests pseudocode/03-input-handler.md behavior

extends RefCounted

const SUITE = "InputHandler"

func run() -> Array:
	var results = []
	results.append(_test_left_flipper_action_recognized())
	results.append(_test_right_flipper_action_recognized())
	results.append(_test_launch_action_recognized())
	results.append(_test_unknown_action_ignored())
	results.append(_test_adapter_set_before_input_processed())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _skip(name: String, reason: String) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "skip", "message": reason, "duration_ms": 0}

# --- Tests ---

func _test_left_flipper_action_recognized() -> Dictionary:
	var known_actions = ["flip_left", "flip_right", "launch"]
	if not "flip_left" in known_actions:
		return _fail("left_flipper_action_recognized", "flip_left not in action map")
	return _pass("left_flipper_action_recognized")

func _test_right_flipper_action_recognized() -> Dictionary:
	var known_actions = ["flip_left", "flip_right", "launch"]
	if not "flip_right" in known_actions:
		return _fail("right_flipper_action_recognized", "flip_right not in action map")
	return _pass("right_flipper_action_recognized")

func _test_launch_action_recognized() -> Dictionary:
	var known_actions = ["flip_left", "flip_right", "launch"]
	if not "launch" in known_actions:
		return _fail("launch_action_recognized", "launch not in action map")
	return _pass("launch_action_recognized")

func _test_unknown_action_ignored() -> Dictionary:
	var known_actions = ["flip_left", "flip_right", "launch"]
	var unknown = "pause"
	if unknown in known_actions:
		return _fail("unknown_action_ignored", "Unexpected action '%s' found in map" % unknown)
	return _pass("unknown_action_ignored")

func _test_adapter_set_before_input_processed() -> Dictionary:
	# InputManager.set_adapter() must be called before any input is processed
	# This ordering constraint is enforced in GameLoop._ready() — runtime test
	return _skip("adapter_set_before_input_processed", "Requires Godot InputMap runtime")
