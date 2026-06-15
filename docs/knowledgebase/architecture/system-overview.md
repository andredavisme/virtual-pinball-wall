# System Architecture Overview

## High-Level Components

```
+-------------------+       +----------------------+
|   Input Adapter   | ----> |  Input Abstraction   |
| (KB / GPIO / BT)  |       |  Layer (InputEvent)  |
+-------------------+       +----------+-----------+
                                        |
                                        v
                             +----------+-----------+
                             |    Game Engine       |
                             |  (Physics / Loop)    |
                             +----------+-----------+
                                        |
                          +-------------+-------------+
                          |                           |
                 +--------+-------+        +----------+--------+
                 |   UI / Render  |        |   Config Loader   |
                 | (Vertical Disp)|        | (Table / Settings)|
                 +----------------+        +----------+--------+
                                                      |
                                           +----------+--------+
                                           |   Supabase DB     |
                                           | scores / tables   |
                                           +-------------------+
```

## Input Abstraction Layer

All physical input devices implement a common adapter interface that emits `InputEvent` objects:
- `LEFT_FLIPPER_DOWN / UP`
- `RIGHT_FLIPPER_DOWN / UP`
- `LAUNCH`
- `PAUSE`
- `TILT`

Adapters: `KeyboardAdapter`, `GPIOAdapter`, `BluetoothAdapter`
Active adapter is set via config file — no game engine changes required to swap.

## Data Flow

1. Player triggers input device
2. Adapter translates → `InputEvent`
3. Game engine processes event → updates physics state
4. Renderer draws updated frame to vertical display
5. On game over → score POST to Supabase
6. Leaderboard pulled from Supabase on attract screen
