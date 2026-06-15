# KeyboardAdapter.gd
# Maps keyboard keys to InputEvents via a loaded keymap.
# Pseudocode source: pseudocode/03-input-abstraction.md

class_name KeyboardAdapter
extends InputAdapter

# keymap: { "action_name": InputEvent }
# action_names must match Godot's InputMap (Project Settings > Input Map)
var keymap: Dictionary = {
	"flip_left":   InputEvent.LEFT_FLIPPER_DOWN,
	"flip_right":  InputEvent.RIGHT_FLIPPER_DOWN,
	"launch":      InputEvent.LAUNCH,
	"pause":       InputEvent.PAUSE,
	"tilt":        InputEvent.TILT,
}

func connect_adapter() -> void:
	pass  # Keyboard is always active in Godot — no setup needed

func disconnect_adapter() -> void:
	pass

func poll() -> InputEvent:
	if Input.is_action_just_pressed("flip_left"):    return InputEvent.LEFT_FLIPPER_DOWN
	if Input.is_action_just_released("flip_left"):   return InputEvent.LEFT_FLIPPER_UP
	if Input.is_action_just_pressed("flip_right"):   return InputEvent.RIGHT_FLIPPER_DOWN
	if Input.is_action_just_released("flip_right"):  return InputEvent.RIGHT_FLIPPER_UP
	if Input.is_action_just_pressed("launch"):       return InputEvent.LAUNCH
	if Input.is_action_just_pressed("pause"):        return InputEvent.PAUSE
	if Input.is_action_just_pressed("tilt"):         return InputEvent.TILT
	return InputEvent.NONE
