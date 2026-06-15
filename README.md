# Virtual Pinball Wall

> **Initiated:** June 15, 2026

A wall-mounted vertical display running a digital pinball game with realistic physics — designed for venues and enthusiasts with limited floor space.

---

## Vision

Deliver a true-to-life pinball experience without requiring a full-footprint cabinet. Mount a vertical display on a wall, let players control the game through any input device they prefer, and bring the magic of pinball to spaces that couldn't fit a traditional machine.

---

## Objective Priority

1. **Playability** — Realistic digital physics, responsive controls
2. **Space Efficiency** — Wall-mounted, zero floor footprint
3. **Input Modularity** — Easy swap between keyboard, custom button box, Bluetooth, or other wireless devices via an abstracted input layer
4. **Novelty & Visual Appeal** — Video game flair layered on top of classic pinball feel

---

## MVP Milestones (Priority Order)

| # | Milestone | Description |
|---|-----------|-------------|
| 1 | Core Game Engine | Physics-based pinball running on screen |
| 2 | Input Abstraction Layer | Unified input interface switchable between keyboard, GPIO buttons, BT, etc. |
| 3 | Vertical Display Layout | UI scaled and oriented for wall-mounted vertical screen |
| 4 | Persistent Scoreboard | Scores saved to Supabase DB |
| 5 | Table Config System | Configurable table layouts stored and loaded from DB |

---

## Resources

- **GitHub:** [andredavisme/virtual-pinball-wall](https://github.com/andredavisme/virtual-pinball-wall)
- **Database:** Supabase — `andredavisme's Project` (`hhyhulqngdkwsxhymmcd`)

---

## Repository Structure

```
virtual-pinball-wall/
├── src/                  # Game source code
│   ├── engine/           # Physics and game loop
│   ├── input/            # Input abstraction layer
│   ├── ui/               # Display and rendering
│   └── config/           # Table and game configuration
├── pseudocode/           # Pre-implementation logic sketches
├── docs/                 # Design decisions, architecture notes
│   └── knowledgebase/    # Research, references, decisions log
├── assets/               # Sprites, sounds, table images
├── db/                   # Schema files and migrations
└── README.md
```
