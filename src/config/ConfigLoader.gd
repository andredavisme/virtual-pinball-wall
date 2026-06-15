# ConfigLoader.gd (extends Node)
# M5 — Table Config System
# Pseudocode reference: pseudocode/05-config-loader.md
# STATUS: STUB — implement from pseudocode
extends Node

func load_game_config(filepath: String) -> Dictionary:
	# TODO: read JSON config (balls_per_game, resolution, active_table_id)
	return {}

func load_table_config(table_id: String) -> Dictionary:
	# TODO: fetch from Supabase `tables` WHERE id = table_id, parse layout JSONB
	return {}

func load_input_config(filepath: String) -> Node:
	# TODO: read adapter_type + keymap/pin_map, instantiate correct adapter
	return null
