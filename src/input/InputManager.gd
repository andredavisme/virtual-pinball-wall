# InputManager.gd
# Singleton (AutoLoad) — manages the active input adapter.
# Register as AutoLoad in Project Settings: name = "InputManager"
# Pseudocode source: pseudocode/03-input-abstraction.md

extends Node

const InputEvent = InputAdapter.InputEvent

var active_adapter: InputAdapter = null

func set_adapter(adapter: InputAdapter) -> void:
	if active_adapter != null:
		active_adapter.disconnect_adapter()
	active_adapter = adapter
	active_adapter.connect_adapter()

func get_event() -> InputAdapter.InputEvent:
	if active_adapter == null:
		return InputAdapter.InputEvent.NONE
	return active_adapter.poll()
