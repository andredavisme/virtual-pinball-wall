# Pseudocode: Input Abstraction Layer (M2)

## File: `src/input/input_adapter`

```
ENUM InputEvent:
  LEFT_FLIPPER_DOWN
  LEFT_FLIPPER_UP
  RIGHT_FLIPPER_DOWN
  RIGHT_FLIPPER_UP
  LAUNCH
  PAUSE
  TILT

INTERFACE InputAdapter:
  FUNCTION poll() -> InputEvent | NONE
  FUNCTION connect()
  FUNCTION disconnect()

-- Keyboard Adapter --
CLASS KeyboardAdapter IMPLEMENTS InputAdapter:
  LOAD keymap from config (e.g. LEFT_SHIFT -> LEFT_FLIPPER_DOWN)
  FUNCTION poll():
    READ keyboard state
    MAP key press/release -> InputEvent
    RETURN InputEvent or NONE

-- GPIO Button Box Adapter --
CLASS GPIOAdapter IMPLEMENTS InputAdapter:
  LOAD pin_map from config (e.g. GPIO_PIN_4 -> LEFT_FLIPPER_DOWN)
  FUNCTION poll():
    READ GPIO pin states
    MAP pin HIGH/LOW -> InputEvent
    RETURN InputEvent or NONE

-- Bluetooth Adapter --
CLASS BluetoothAdapter IMPLEMENTS InputAdapter:
  SCAN for paired device matching config device_id
  FUNCTION connect():
    ESTABLISH BT connection
  FUNCTION poll():
    READ BT input packet
    MAP packet signal -> InputEvent
    RETURN InputEvent or NONE

-- Input Manager --
CLASS InputManager:
  active_adapter: InputAdapter

  FUNCTION set_adapter(adapter: InputAdapter):
    IF active_adapter exists: active_adapter.disconnect()
    active_adapter = adapter
    active_adapter.connect()

  FUNCTION get_event() -> InputEvent | NONE:
    RETURN active_adapter.poll()
```
