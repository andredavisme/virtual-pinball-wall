# run_tests.gd
# Master test runner. Executes all suites and logs results to Supabase.

extends Node

const SUPABASE_URL = "" # Set via ConfigLoader or env
const SUPABASE_KEY = "" # Set via ConfigLoader or env

var suites = [
	"res://tests/suites/test_config_loader.gd",
	"res://tests/suites/test_game_loop.gd",
	"res://tests/suites/test_ball_physics.gd",
	"res://tests/suites/test_input.gd",
	"res://tests/suites/test_score_service.gd",
	"res://tests/suites/test_db_schema.gd",
]

var results = []

func run_all() -> void:
	print("=== Virtual Pinball Wall Test Run ===")
	for suite_path in suites:
		var suite_script = load(suite_path)
		if suite_script == null:
			print("[SKIP] Could not load: ", suite_path)
			continue
		var suite = suite_script.new()
		if suite.has_method("run"):
			var suite_results = suite.run()
			results.append_array(suite_results)
			_print_suite_results(suite_results)
	_print_summary()
	_log_to_supabase()

func _print_suite_results(suite_results: Array) -> void:
	for r in suite_results:
		var icon = "✅" if r["status"] == "pass" else ("⏭" if r["status"] == "skip" else "❌")
		print("%s [%s] %s" % [icon, r["test_suite"], r["test_name"]])
		if r.get("message"):
			print("   → ", r["message"])

func _print_summary() -> void:
	var passed = results.filter(func(r): return r["status"] == "pass").size()
	var failed = results.filter(func(r): return r["status"] == "fail").size()
	var skipped = results.filter(func(r): return r["status"] == "skip").size()
	print("\n--- Results: %d passed, %d failed, %d skipped ---" % [passed, failed, skipped])

func _log_to_supabase() -> void:
	if SUPABASE_URL == "" or SUPABASE_KEY == "":
		print("[TEST RUNNER] Supabase credentials not set — skipping remote log.")
		return
	var http = HTTPRequest.new()
	add_child(http)
	for r in results:
		var body = JSON.stringify(r)
		var headers = [
			"Content-Type: application/json",
			"apikey: " + SUPABASE_KEY,
			"Authorization: Bearer " + SUPABASE_KEY
		]
		http.request(SUPABASE_URL + "/rest/v1/test_log", headers, HTTPClient.METHOD_POST, body)
		await http.request_completed
	http.queue_free()
