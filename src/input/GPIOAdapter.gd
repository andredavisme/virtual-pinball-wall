# GPIOAdapter.gd
# Maps Raspberry Pi GPIO pin states to InputEvents.
# Requires a GDExtension or gdgpio plugin for actual GPIO access.
# Pseudocode source: pseudocode/03-input-abstraction.md

class_name GPIOAdapter
extends InputAdapter

# pin_map: { gpio_pin_number: InputEvent }
var pin_map: Dictionary = {}
var _prev_states: Dictionary = {}

func init_from_config(config: Dictionary) -> void:
	# config.pin_map: { "4": "LEFT_FLIPPER_DOWN", ... }
	for pin_str in config.get("pin_map", {}).keys():
		var pin = int(pin_str)
		var event_name: String = config["pin_map"][pin_str]
		pin_map[pin] = InputAdapter.InputEvent.get(event_name, InputAdapter.InputEvent.NONE)
		_prev_states[pin] = false

func connect_adapter() -> void:
	# GPIO initialization handled by gdgpio plugin
	for pin in pin_map.keys():
		pass  # GPIO.setup(pin, GPIO.IN)

func disconnect_adapter() -> void:
	pass  # Cleanup if needed

func poll() -> InputAdapter.InputEvent:
	# Read each registered pin; return first state-change event
	for pin in pin_map.keys():
		var current_high: bool = false  # Replace with GPIO.input(pin)
		if current_high and not _prev_states[pin]:
			_prev_states[pin] = true
			return pin_map[pin]
		elif not current_high and _prev_states[pin]:
			_prev_states[pin] = false
			# Map release events for flippers
			var evt = pin_map[pin]
			if evt == InputAdapter.InputEvent.LEFT_FLIPPER_DOWN:
				return InputAdapter.InputEvent.LEFT_FLIPPER_UP
			if evt == InputAdapter.InputEvent.RIGHT_FLIPPER_DOWN:
				return InputAdapter.InputEvent.RIGHT_FLIPPER_UP
	return InputAdapter.InputEvent.NONE
