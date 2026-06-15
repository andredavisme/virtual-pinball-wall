# test_config_roundtrip.gd
# Integration test: full config round-trip.
# Loads game.json → fetches table config from Supabase → validates layout shape.
# Requires ConfigLoader and SupabaseClient AutoLoads.

extends RefCounted

const SUITE = "ConfigRoundtrip"

func run() -> Array:
	var results = []
	results.append(_test_game_config_loads())
	results.append(await _test_table_config_from_supabase())
	return results

func _pass(name: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "pass", "message": null, "duration_ms": ms}

func _fail(name: String, msg: String, ms: int = 0) -> Dictionary:
	return {"test_suite": SUITE, "test_name": name, "status": "fail", "message": msg, "duration_ms": ms}

func _test_game_config_loads() -> Dictionary:
	var t = Time.get_ticks_msec()
	var config = ConfigLoader.load_game_config("res://config/game.json")
	var ms = Time.get_ticks_msec() - t
	for key in ["balls_per_game", "active_table_id", "supabase_url"]:
		if not config.has(key):
			return _fail("game_config_loads", "Missing key: " + key, ms)
	if config.get("balls_per_game", 0) <= 0:
		return _fail("game_config_loads", "balls_per_game must be > 0", ms)
	return _pass("game_config_loads", ms)

func _test_table_config_from_supabase() -> Dictionary:
	var t = Time.get_ticks_msec()
	var game_config = ConfigLoader.load_game_config("res://config/game.json")
	var table_id: String = game_config.get("active_table_id", "")
	if table_id == "":
		return _fail("table_config_from_supabase",
			"active_table_id is empty in game.json — seed a table row first")
	var table_config = await ConfigLoader.load_table_config(table_id)
	var ms = Time.get_ticks_msec() - t
	if table_config.is_empty():
		return _fail("table_config_from_supabase", "Empty table config returned", ms)
	for key in ["bumpers", "targets", "flippers", "walls", "launch_position", "drain_y"]:
		if not table_config.has(key):
			return _fail("table_config_from_supabase", "Missing layout key: " + key, ms)
	# Validate targets include `active` field per schema-map note
	for target in table_config.get("targets", []):
		if not target.has("active"):
			return _fail("table_config_from_supabase",
				"Target missing 'active' field in layout JSON", ms)
	# Validate flippers have both sides
	var sides = table_config.get("flippers", []).map(func(f): return f.get("side", ""))
	if not "LEFT" in sides or not "RIGHT" in sides:
		return _fail("table_config_from_supabase",
			"Flippers must include both LEFT and RIGHT", ms)
	return _pass("table_config_from_supabase", ms)
