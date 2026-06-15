# test_db_live.gd
# Integration test: live Supabase REST calls.
# Tests INSERT/SELECT on scores and test_log, SELECT on tables.
# Requires SupabaseClient to be configured before running.

extends RefCounted

const SUITE = "DBLive"

func run(table_id: String) -> Array:
	var results = []
	results.append(await _test_select_tables(table_id))
	results.append(await _test_insert_and_select_score(table_id))
	results.append(await _test_insert_test_log())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

# --- Tests ---

func _test_select_tables(table_id: String) -> Dictionary:
	var t = Time.get_ticks_msec()
	var url = SupabaseClient.BASE_URL + "/rest/v1/tables?id=eq." + table_id + "&select=id,name,layout,is_active"
	var http = HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http)
	http.request(url, SupabaseClient.get_headers(), HTTPClient.METHOD_GET)
	var resp = await http.request_completed
	http.queue_free()
	var ms = Time.get_ticks_msec() - t
	var body = JSON.parse_string(resp[3].get_string_from_utf8())
	if typeof(body) != TYPE_ARRAY or body.size() == 0:
		return _fail("select_tables", "No table row returned for id=" + table_id, ms)
	var row = body[0]
	for key in ["id", "name", "layout", "is_active"]:
		if not row.has(key):
			return _fail("select_tables", "Missing column: " + key, ms)
	return _pass("select_tables", ms)

func _test_insert_and_select_score(table_id: String) -> Dictionary:
	var t = Time.get_ticks_msec()
	# INSERT
	var payload = {
		"player_initials": "TST",
		"score": 1,
		"table_id": table_id,
		"played_at": Time.get_datetime_string_from_system(false) + "Z"
	}
	var post_url = SupabaseClient.BASE_URL + "/rest/v1/scores"
	var headers = SupabaseClient.get_headers()
	headers.append("Prefer: return=representation")
	var http_post = HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http_post)
	http_post.request(post_url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	var post_resp = await http_post.request_completed
	http_post.queue_free()
	if post_resp[1] not in [200, 201]:
		return _fail("insert_and_select_score",
			"POST failed: " + str(post_resp[1]) + " " + post_resp[3].get_string_from_utf8(),
			Time.get_ticks_msec() - t)
	# Parse inserted row id for cleanup
	var inserted = JSON.parse_string(post_resp[3].get_string_from_utf8())
	var inserted_id = ""
	if typeof(inserted) == TYPE_ARRAY and inserted.size() > 0:
		inserted_id = inserted[0].get("id", "")
	# SELECT back
	var get_url = SupabaseClient.BASE_URL + "/rest/v1/scores?player_initials=eq.TST&table_id=eq." + table_id + "&order=played_at.desc&limit=1"
	var http_get = HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http_get)
	http_get.request(get_url, SupabaseClient.get_headers(), HTTPClient.METHOD_GET)
	var get_resp = await http_get.request_completed
	http_get.queue_free()
	var rows = JSON.parse_string(get_resp[3].get_string_from_utf8())
	var ms = Time.get_ticks_msec() - t
	if typeof(rows) != TYPE_ARRAY or rows.size() == 0:
		return _fail("insert_and_select_score", "Inserted score not found on SELECT", ms)
	# Cleanup test row
	if inserted_id != "":
		var del_url = SupabaseClient.BASE_URL + "/rest/v1/scores?id=eq." + inserted_id
		var http_del = HTTPRequest.new()
		Engine.get_main_loop().root.add_child(http_del)
		http_del.request(del_url, SupabaseClient.get_headers(), HTTPClient.METHOD_DELETE)
		await http_del.request_completed
		http_del.queue_free()
	return _pass("insert_and_select_score", ms)

func _test_insert_test_log() -> Dictionary:
	var t = Time.get_ticks_msec()
	var payload = {
		"test_suite": "DBLive",
		"test_name":  "test_log_write",
		"status":     "pass",
		"message":    "integration test log write",
		"duration_ms": 0
	}
	var url = SupabaseClient.BASE_URL + "/rest/v1/test_log"
	var http = HTTPRequest.new()
	Engine.get_main_loop().root.add_child(http)
	http.request(url, SupabaseClient.get_headers(), HTTPClient.METHOD_POST, JSON.stringify(payload))
	var resp = await http.request_completed
	http.queue_free()
	var ms = Time.get_ticks_msec() - t
	if resp[1] not in [200, 201]:
		return _fail("insert_test_log", "POST failed: " + str(resp[1]), ms)
	return _pass("insert_test_log", ms)
