# Decisions Log

## 2026-06-15 — Initiation

### Input Modularity
- **Decision:** Implement an abstracted input layer that decouples the game engine from the physical control device.
- **Rationale:** Player should be able to swap between keyboard, custom button box (GPIO/USB), Bluetooth controller, or other wireless protocols without modifying game logic.
- **Approach:** Define a standard `InputEvent` interface. Each input adapter (keyboard, BT, GPIO) translates device signals into `InputEvent` objects consumed by the game engine.

### Display Orientation
- **Decision:** Design UI natively for vertical (portrait) orientation.
- **Rationale:** Wall-mounted display replaces a traditional cabinet's vertical playfield.

### Database
- **Decision:** Use existing Supabase project `andredavisme's Project`.
- **Rationale:** Avoids unnecessary new project overhead; suitable for scoreboard and config storage.
