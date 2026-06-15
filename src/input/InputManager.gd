# InputManager.gd (extends Node)
# M2 — Input Abstraction Layer
# Pseudocode reference: pseudocode/03-input-abstraction.md
# STATUS: STUB — implement from pseudocode
extends Node

enum InputEvent { NONE, LEFT_FLIPPER_DOWN, LEFT_FLIPPER_UP, RIGHT_FLIPPER_DOWN, RIGHT_FLIPPER_UP, LAUNCH, PAUSE, TILT }

var active_adapter = null

func set_adapter(adapter) -> void:
	if active_adapter:
		active_adapter.disconnect_adapter()
	active_adapter = adapter
	active_adapter.connect_adapter()

func get_event() -> InputEvent:
	if active_adapter:
		return active_adapter.poll()
	return InputEvent.NONE
