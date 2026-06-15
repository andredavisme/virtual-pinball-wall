# ScoreService.gd (extends Node)
# M4 — Persistent Scoreboard
# Pseudocode reference: pseudocode/06-score-service.md
# STATUS: STUB — implement from pseudocode
extends Node

const SUPABASE_URL: String = ""  # Set via environment / config
const SUPABASE_KEY: String = ""  # Set via environment / config

func post_score(player_initials: String, score: int, table_id: String) -> void:
	# TODO: validate initials (3 chars, alphanumeric)
	# TODO: HTTP POST to Supabase scores table
	pass

func get_leaderboard(table_id: String, limit: int = 10) -> Array:
	# TODO: HTTP GET from Supabase scores table, ORDER BY score DESC
	return []
