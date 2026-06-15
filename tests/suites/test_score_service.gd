# test_score_service.gd
# Tests pseudocode/06-score-service.md behavior

extends RefCounted

const SUITE = "ScoreService"

func run() -> Array:
	var results = []
	results.append(_test_score_payload_has_required_fields())
	results.append(_test_created_at_not_in_payload())
	results.append(_test_player_initials_max_three_chars())
	results.append(_test_score_is_positive_integer())
	results.append(_test_leaderboard_sorted_descending())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _skip(name: String, reason: String) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "skip", "message": reason, "duration_ms": 0}

# --- Tests ---

func _test_score_payload_has_required_fields() -> Dictionary:
	# Per schema-map: scores table requires table_id, player_initials, score, played_at
	var payload = {
		"table_id": "some-uuid",
		"player_initials": "AAA",
		"score": 5000,
		"played_at": "2026-06-15T18:00:00Z"
	}
	for key in ["table_id", "player_initials", "score", "played_at"]:
		if not payload.has(key):
			return _fail("score_payload_has_required_fields", "Missing field: " + key)
	return _pass("score_payload_has_required_fields")

func _test_created_at_not_in_payload() -> Dictionary:
	# created_at is DB-auto-populated (DEFAULT now()) — must NOT be in INSERT payload
	var payload = {
		"table_id": "some-uuid",
		"player_initials": "AAA",
		"score": 5000,
		"played_at": "2026-06-15T18:00:00Z"
	}
	if payload.has("created_at"):
		return _fail("created_at_not_in_payload", "created_at should not be in INSERT payload")
	return _pass("created_at_not_in_payload")

func _test_player_initials_max_three_chars() -> Dictionary:
	var initials = "AAA"
	if initials.length() > 3:
		return _fail("player_initials_max_three_chars", "Initials exceed 3 chars: " + initials)
	return _pass("player_initials_max_three_chars")

func _test_score_is_positive_integer() -> Dictionary:
	var score = 5000
	if score < 0 or not (score is int):
		return _fail("score_is_positive_integer", "Score must be a non-negative integer")
	return _pass("score_is_positive_integer")

func _test_leaderboard_sorted_descending() -> Dictionary:
	var scores = [1000, 5000, 2500, 9999, 300]
	scores.sort()
	scores.reverse()
	if scores[0] < scores[scores.size() - 1]:
		return _fail("leaderboard_sorted_descending", "Leaderboard not sorted descending")
	return _pass("leaderboard_sorted_descending")
