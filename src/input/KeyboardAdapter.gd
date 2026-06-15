# KeyboardAdapter.gd (extends Node)
# M2 — Input Abstraction: Keyboard
# Pseudocode reference: pseudocode/03-input-abstraction.md
# STATUS: STUB — implement from pseudocode
extends Node

var keymap: Dictionary = {}

func connect_adapter() -> void:
	pass # TODO: load keymap from config file

func disconnect_adapter() -> void:
	pass

func poll() -> int:
	# TODO: read Godot Input singleton, map keys to InputManager.InputEvent
	return 0 # InputEvent.NONE
