# ConfigLoader.gd
# Singleton (AutoLoad) — loads game config (local JSON) and table config (Supabase).
# Register as AutoLoad in Project Settings: name = "ConfigLoader"
# Pseudocode source: pseudocode/05-config-loader.md

extends Node

func load_game_config(filepath: String) -> Dictionary:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_error("ConfigLoader: could not open " + filepath)
		return {"balls_per_game": 3, "active_table_id": ""}
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("ConfigLoader: invalid JSON in " + filepath)
		return {"balls_per_game": 3, "active_table_id": ""}
	return parsed

func load_table_config(table_id: String) -> Dictionary:
	if table_id == "":
		push_error("ConfigLoader: empty table_id")
		return {}
	var url = SupabaseClient.BASE_URL + "/rest/v1/tables?id=eq." + table_id + "&select=*"
	var headers = SupabaseClient.get_headers()
	var http = HTTPRequest.new()
	add_child(http)
	http.request(url, headers, HTTPClient.METHOD_GET)
	var response = await http.request_completed
	http.queue_free()
	var body: String = response[3].get_string_from_utf8()
	var rows = JSON.parse_string(body)
	if typeof(rows) != TYPE_ARRAY or rows.size() == 0:
		push_error("ConfigLoader: no table found for id=" + table_id)
		return {}
	var row: Dictionary = rows[0]
	var layout = row.get("layout", {})
	if typeof(layout) == TYPE_STRING:
		layout = JSON.parse_string(layout)
	return {
		"name":            row.get("name", ""),
		"bumpers":         layout.get("bumpers", []),
		"targets":         layout.get("targets", []),
		"flippers":        layout.get("flippers", []),
		"walls":           layout.get("walls", []),
		"launch_position": layout.get("launch_position", {"x": 0, "y": 0}),
		"drain_y":         layout.get("drain_y", 1920),
	}

func load_input_config(filepath: String) -> InputAdapter:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_warning("ConfigLoader: no input.json found, defaulting to KeyboardAdapter")
		return KeyboardAdapter.new()
	var text = file.get_as_text()
	file.close()
	var config = JSON.parse_string(text)
	if typeof(config) != TYPE_DICTIONARY:
		return KeyboardAdapter.new()
	var adapter_type: String = config.get("adapter_type", "keyboard")
	match adapter_type:
		"keyboard":
			return KeyboardAdapter.new()
		"gpio":
			var adapter = GPIOAdapter.new()
			adapter.init_from_config(config)
			return adapter
		"bluetooth":
			var adapter = BluetoothAdapter.new()
			adapter.init_from_config(config)
			return adapter
		_:
			push_warning("ConfigLoader: unknown adapter_type '" + adapter_type + "', defaulting to keyboard")
			return KeyboardAdapter.new()
