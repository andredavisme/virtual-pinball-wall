# BluetoothAdapter.gd
# Maps Bluetooth HID input packets to InputEvents.
# Requires a BT GDExtension plugin for actual BT access.
# Pseudocode source: pseudocode/03-input-abstraction.md

class_name BluetoothAdapter
extends InputAdapter

var device_id: String = ""
var _connected: bool  = false
var _pending_event: InputEvent = InputEvent.NONE

func init_from_config(config: Dictionary) -> void:
	device_id = config.get("device_id", "")

func connect_adapter() -> void:
	if device_id == "":
		push_error("BluetoothAdapter: no device_id configured")
		return
	# Replace with actual BT plugin call: BTManager.connect(device_id)
	_connected = true

func disconnect_adapter() -> void:
	# BTManager.disconnect(device_id)
	_connected = false

func poll() -> InputEvent:
	if not _connected:
		return InputEvent.NONE
	# Replace with actual BT packet read:
	# var packet = BTManager.read(device_id)
	# MAP packet signal -> InputEvent
	return InputEvent.NONE
