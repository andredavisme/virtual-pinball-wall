# SupabaseClient.gd
# Singleton (AutoLoad) — shared Supabase config used by ConfigLoader and ScoreService.
# Register as AutoLoad in Project Settings: name = "SupabaseClient"
# Values are loaded from config/game.json at startup or set directly here for dev.

extends Node

# Override these at startup from game.json, or set environment-specific values.
var BASE_URL: String = ""  # e.g. https://hhyhulqngdkwsxhymmcd.supabase.co
var ANON_KEY: String = ""  # Supabase anon/public key

func configure(url: String, key: String) -> void:
	BASE_URL = url
	ANON_KEY = key

func get_headers() -> Array:
	return [
		"Content-Type: application/json",
		"apikey: " + ANON_KEY,
		"Authorization: Bearer " + ANON_KEY
	]
