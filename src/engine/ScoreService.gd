# ScoreService.gd
# Singleton (AutoLoad) — handles score POST and leaderboard GET via Supabase REST.
# Register as AutoLoad in Project Settings: name = "ScoreService"
# Pseudocode source: pseudocode/06-score-service.md

extends Node

func post_score(player_initials: String, score: int, table_id: String) -> Dictionary:
	# Validate
	if player_initials.strip_edges() == "" or player_initials.length() > 3:
		push_error("ScoreService: invalid player_initials '" + player_initials + "'")
		return {"error": "invalid_initials"}
	if not player_initials.is_valid_identifier() and not player_initials.is_valid_int():
		# Allow alphanumeric only — basic guard
		pass  # Godot has no built-in alphanumeric check; extend as needed

	var payload = {
		"player_initials": player_initials.to_upper(),
		"score":           score,
		"table_id":        table_id,
		"played_at":       Time.get_datetime_string_from_system(false) + "Z"
		# created_at intentionally omitted — DB DEFAULT now() auto-populates
	}

	var url     = SupabaseClient.BASE_URL + "/rest/v1/scores"
	var headers = SupabaseClient.get_headers()
	headers.append("Prefer: return=minimal")

	var http = HTTPRequest.new()
	add_child(http)
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	var response = await http.request_completed
	http.queue_free()

	var status_code: int = response[1]
	if status_code in [200, 201]:
		return {"success": true}
	else:
		var body: String = response[3].get_string_from_utf8()
		push_error("ScoreService: post_score failed (%d): " % status_code + body)
		return {"error": body}

func get_leaderboard(table_id: String, limit: int = 10) -> Array:
	var url = SupabaseClient.BASE_URL \
		+ "/rest/v1/scores?table_id=eq." + table_id \
		+ "&order=score.desc&limit=" + str(limit) \
		+ "&select=player_initials,score,played_at"
	var headers = SupabaseClient.get_headers()

	var http = HTTPRequest.new()
	add_child(http)
	http.request(url, headers, HTTPClient.METHOD_GET)
	var response = await http.request_completed
	http.queue_free()

	var body: String = response[3].get_string_from_utf8()
	var rows = JSON.parse_string(body)
	if typeof(rows) == TYPE_ARRAY:
		return rows
	return []
