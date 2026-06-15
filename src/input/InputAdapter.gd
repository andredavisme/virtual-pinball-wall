# InputAdapter.gd
# Base class (interface) for all input adapters.
# Pseudocode source: pseudocode/03-input-abstraction.md

class_name InputAdapter
extends RefCounted

enum InputEvent {
	LEFT_FLIPPER_DOWN,
	LEFT_FLIPPER_UP,
	RIGHT_FLIPPER_DOWN,
	RIGHT_FLIPPER_UP,
	LAUNCH,
	PAUSE,
	TILT,
	NONE
}

func connect_adapter() -> void:
	pass  # Override in subclass

func disconnect_adapter() -> void:
	pass  # Override in subclass

func poll() -> InputEvent:
	return InputEvent.NONE  # Override in subclass
