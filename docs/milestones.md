# Milestones & Tasks

## Milestone 1 — Core Game Engine

**Tasks:**
- [ ] Select game framework (e.g., Pygame, Godot, or web-based canvas)
- [ ] Implement ball physics (gravity, bounce, velocity)
- [ ] Implement flipper mechanics
- [ ] Implement bumper/target collision logic
- [ ] Basic game loop (ball launch, drain, score increment)
- [ ] Unit test physics interactions

---

## Milestone 2 — Input Abstraction Layer

**Tasks:**
- [ ] Define `InputEvent` interface/schema (LEFT_FLIPPER, RIGHT_FLIPPER, LAUNCH, PAUSE, etc.)
- [ ] Implement keyboard adapter
- [ ] Implement GPIO/button box adapter
- [ ] Implement Bluetooth adapter
- [ ] Implement input config file (map device signals → InputEvents)
- [ ] Test hot-swap between input adapters

---

## Milestone 3 — Vertical Display Layout

**Tasks:**
- [ ] Design portrait-mode UI layout
- [ ] Scale table to vertical resolution
- [ ] HUD (score, ball count) positioned for vertical screen
- [ ] Test on target display hardware

---

## Milestone 4 — Persistent Scoreboard

**Tasks:**
- [ ] Create `scores` table in Supabase
- [ ] POST score on game over
- [ ] GET top scores for leaderboard display
- [ ] Display leaderboard on attract screen

---

## Milestone 5 — Table Config System

**Tasks:**
- [ ] Define table config schema (bumpers, targets, layout coordinates)
- [ ] Create `tables` table in Supabase
- [ ] Load active table config at game start
- [ ] Build default table config
