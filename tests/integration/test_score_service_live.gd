# test_score_service_live.gd
# Integration test: full ScoreService cycle.
# Posts a test score, reads it back via leaderboard, then deletes it.
# Requires ScoreService and SupabaseClient AutoLoads.

extends RefCounted

const SUITE = "ScoreServiceLive"
const TEST_INITIALS = "ZZZ"  # Unlikely to collide with real scores

func run(table_id: String) -> Array:
	var results = []
	results.append(await _test_post_score(table_id))
	results.append(await _test_get_leaderboard(table_id))
	results.append(await _test_post_invalid_initials(table_id))
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _test_post_score(table_id: String) -> Dictionary:
	var t = Time.get_ticks_msec()
	var result = await ScoreService.post_score(TEST_INITIALS, 9999, table_id)
	var ms = Time.get_ticks_msec() - t
	if result.has("error"):
		return _fail("post_score", "post_score returned error: " + str(result["error"]), ms)
	# Cleanup: delete test score
	var del_url = SupabaseClient.BASE_URL \
		+ "/rest/v1/scores?player_initials=eq." + TEST_INITIALS \
		+ "&table_id=eq." + table_id
	var http = HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http)
	http.request(del_url, SupabaseClient.get_headers(), HTTPClient.METHOD_DELETE)
	await http.request_completed
	http.queue_free()
	return _pass("post_score", ms)

func _test_get_leaderboard(table_id: String) -> Dictionary:
	var t = Time.get_ticks_msec()
	var board = await ScoreService.get_leaderboard(table_id, 10)
	var ms = Time.get_ticks_msec() - t
	if typeof(board) != TYPE_ARRAY:
		return _fail("get_leaderboard", "Expected array, got: " + str(typeof(board)), ms)
	# Verify sort order if more than one entry
	if board.size() > 1:
		for i in range(board.size() - 1):
			if board[i].get("score", 0) < board[i + 1].get("score", 0):
				return _fail("get_leaderboard",
					"Leaderboard not sorted descending at index %d" % i, ms)
	# Verify each entry has required fields
	for entry in board:
		for key in ["player_initials", "score", "played_at"]:
			if not entry.has(key):
				return _fail("get_leaderboard", "Entry missing field: " + key, ms)
	return _pass("get_leaderboard", ms)

func _test_post_invalid_initials(table_id: String) -> Dictionary:
	var t = Time.get_ticks_msec()
	# Empty initials should return error, not crash
	var result = await ScoreService.post_score("", 100, table_id)
	var ms = Time.get_ticks_msec() - t
	if not result.has("error"):
		return _fail("post_invalid_initials",
			"Expected error for empty initials, got success", ms)
	# 4-char initials should also be rejected
	var result2 = await ScoreService.post_score("ABCD", 100, table_id)
	if not result2.has("error"):
		return _fail("post_invalid_initials",
			"Expected error for 4-char initials, got success", ms)
	return _pass("post_invalid_initials", ms)
