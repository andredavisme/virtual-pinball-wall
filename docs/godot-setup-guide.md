# Godot Setup Guide — Virtual Pinball Wall
### *A hobby developer's step-by-step walkthrough*

This guide picks up where the automated setup left off. Everything in the database, config files, and scripts is already built. Your job is to open the Godot editor and wire it all together — no coding required.

---

## Before You Begin

**What you need:**
- A computer (Windows, Mac, or Linux)
- The project files downloaded from GitHub
- Godot 4 installed (free at [godotengine.org](https://godotengine.org/download))
- About 60–90 minutes

**How to get the project files:**
1. Go to https://github.com/andredavisme/virtual-pinball-wall
2. Click the green **Code** button → **Download ZIP**
3. Unzip it to a folder you'll remember, like `Documents/virtual-pinball-wall`

---

## Part 1 — Open the Project in Godot

1. Launch Godot 4. You'll see the **Project Manager** screen.
2. Click **Import** (top-right area of the project list).
3. Click **Browse** and navigate to the folder where you unzipped the project.
4. Select the file named `project.godot` and click **Open**.
5. Click **Import & Edit**.

> The editor will open. You'll see a dark interface with panels. Don't worry — you won't need to understand all of it.

### ✅ Checkpoint 1
Look at the top of the screen. You should see a toolbar with play buttons (▶). In the bottom panel, there should be a **FileSystem** tab showing folders like `src`, `config`, `tests`, and `assets`.

**If you don't see the FileSystem tab:** Look at the bottom-left of the screen and click the tab labeled **FileSystem**. If it's completely missing, go to menu **Editor → Editor Layout → Default**.

---

## Part 2 — Register the AutoLoads

AutoLoads are scripts that run automatically in the background throughout the entire game — things like loading your config and talking to the database. Think of them like always-on helpers.

1. In the top menu bar, click **Project** → **Project Settings**.
2. A window will open. Look for the **AutoLoad** tab. It's near the top of the window in a row of tabs. Click it.
3. You'll see two columns: **Path** and **Name**. You need to add 4 entries, one at a time.

**For each entry below, do this:**
- Click the folder icon 📁 next to the **Path** field
- Navigate to the file listed and double-click it
- In the **Name** field, type the name exactly as shown (capitalization matters)
- Click **Add**

| Name | File Path |
|---|---|
| `SupabaseClient` | `src/engine/SupabaseClient.gd` |
| `InputManager` | `src/input/InputManager.gd` |
| `ConfigLoader` | `src/config/ConfigLoader.gd` |
| `ScoreService` | `src/engine/ScoreService.gd` |

> ⚠️ **Order matters.** Add them in the order listed above, top to bottom.

### ✅ Checkpoint 2
After adding all 4, your AutoLoad list should show exactly these 4 names in this order:
- `SupabaseClient`
- `InputManager`
- `ConfigLoader`
- `ScoreService`

**Troubleshooting:**
- *Can't find the AutoLoad tab?* Make sure you clicked **Project Settings**, not **Editor Settings**. They're both under the Project menu.
- *Name field is greyed out?* Click the path field first and browse to a file — the name field activates after a file is selected.
- *Added them in the wrong order?* You can drag the rows up/down using the ↕ handles on the left side of each row.

Click **Close** when done.

---

## Part 3 — Configure the Display (Portrait Mode)

Your pinball machine is designed to run on a vertical screen — tall like a phone, not wide like a TV. We need to tell Godot that.

1. Go to **Project** → **Project Settings** again.
2. This time, click the **General** tab (it's usually selected by default).
3. In the search box at the top of the settings window, type: `window`
4. Look for a section called **Display > Window**. Expand it if needed.

Set these values:

| Setting | Value |
|---|---|
| **Width** | `1080` |
| **Height** | `1920` |
| **Stretch > Mode** | `canvas_items` |
| **Stretch > Aspect** | `keep` |

5. Now search for `orientation` in the same search box.
6. Find **Display > Window > Handheld > Orientation** and set it to `portrait`.

### ✅ Checkpoint 3
After this step, if you click the **2D** button at the top of the editor, the viewport (the gray canvas area) should be taller than it is wide.

**Troubleshooting:**
- *Can't find "Stretch Mode"?* Try typing `stretch` in the search box instead of `window`. The setting may be nested under **Display > Window > Stretch**.
- *The viewport still looks wide after changing settings?* Close and reopen Project Settings — sometimes changes need a moment to apply to the view.

---

## Part 4 — Set Up Input Actions

Input actions are named controls that the game listens for — like "left flipper pressed." We need to define 5 of them.

1. Go to **Project** → **Project Settings** → click the **Input Map** tab.
2. At the top of the Input Map tab, there's a text field labeled **Add New Action**. Type an action name and click **Add**.

Add all 5 actions:

| Action Name | Key to Assign |
|---|---|
| `flip_left` | `Z` key |
| `flip_right` | `/` key (forward slash) |
| `launch` | `Space` bar |
| `pause` | `Escape` key |
| `tilt` | `T` key |

**For each action, after clicking Add:**
- Click the **+** button that appears to the right of the action name
- A dialog will appear asking you to press a key
- Press the key listed above
- Click **OK**

### ✅ Checkpoint 4
Each action should appear in the list with its key shown to the right. For example:
- `flip_left` → `Z`
- `flip_right` → `/`
- `launch` → `Space`
- `pause` → `Escape`
- `tilt` → `T`

**Troubleshooting:**
- *I accidentally assigned the wrong key.* Click the small **x** button next to the wrong key binding to remove it, then click **+** again to re-add the correct one.
- *The action name has a typo.* Action names are case-sensitive — `flip_left` is not the same as `Flip_Left`. Click the pencil/edit icon next to the name to rename it, or delete it with the trash icon and re-add it.

Click **Close** when done.

---

## Part 5 — Build the Main Scene

This is the most involved step. You're going to create the game's scene — think of it as the stage where all the pieces (ball, flippers, walls, etc.) live.

### 5a — Create the scene file

1. In the **FileSystem** panel (bottom-left), right-click the `src/scenes` folder → **New Scene**.

   > *Can't see a `src/scenes` folder?* In the FileSystem, click the small arrow next to `src` to expand it. If `scenes` doesn't exist, right-click `src` → **New Folder** → type `scenes`.

2. A new empty scene opens. In the **Scene** panel (top-left), you'll see one empty node.
3. Click that node, then in the top toolbar look for **+** or right-click it → **Change Type**.
4. Search for `Node` and select plain **Node** (not Node2D or anything else).
5. Rename it: click the node name once to select it, press **F2**, and type `GameLoop`. Press **Enter**.

### 5b — Attach the GameLoop script

1. With the `GameLoop` node selected, look at the **Inspector** panel on the right side.
2. Near the top of the Inspector, look for a **Script** field with an empty icon.
3. Click the folder icon next to it and navigate to `src/GameLoop.gd`. Double-click it to attach it.

> ✅ You should see the script icon next to the node name in the Scene panel turn into a small scroll 📜 icon.

### 5c — Add child nodes

Now you'll add the game pieces as children of `GameLoop`. For each one, right-click the `GameLoop` node in the Scene panel → **Add Child Node**, search for the type listed, then rename it and attach its script.

Add these child nodes in order:

---

**1. Ball**
- Type: `RigidBody2D`
- Rename to: `Ball`
- Attach script: `src/nodes/Ball.gd`
- After adding: right-click `Ball` → **Add Child Node** → search `CircleShape2D` → add it. This gives the ball its collision shape.

---

**2. FlipperLeft**
- Type: `AnimatableBody2D`
- Rename to: `FlipperLeft`
- Attach script: `src/nodes/Flipper.gd`

---

**3. FlipperRight**
- Type: `AnimatableBody2D`
- Rename to: `FlipperRight`
- Attach script: `src/nodes/Flipper.gd`

---

**4. DrainZone**
- Type: `Area2D`
- Rename to: `DrainZone`
- Attach script: `src/nodes/DrainZone.gd`
- After adding: right-click `DrainZone` → **Add Child Node** → search `CollisionShape2D` → add it.

---

**5. TableBounds**
- Type: `StaticBody2D`
- Rename to: `TableBounds`
- Attach script: `src/nodes/TableBounds.gd`

---

**6. UIRenderer**
- Type: `CanvasLayer`
- Rename to: `UIRenderer`
- Attach script: `src/ui/UIRenderer.gd`

Now add these as children **of UIRenderer** (right-click `UIRenderer` to add them):

| Node Type | Rename To |
|---|---|
| `Label` | `ScoreLabel` |
| `Label` | `BallCountLabel` |
| `Control` | `PauseOverlay` |
| `Control` | `GameOverOverlay` |
| `Control` | `AttractScreen` |
| `Control` | `InitialsPrompt` |

### ✅ Checkpoint 5
Your Scene panel tree should look like this:
```
GameLoop (Node + GameLoop.gd)
├── Ball (RigidBody2D + Ball.gd)
│   └── CircleShape2D
├── FlipperLeft (AnimatableBody2D + Flipper.gd)
├── FlipperRight (AnimatableBody2D + Flipper.gd)
├── DrainZone (Area2D + DrainZone.gd)
│   └── CollisionShape2D
├── TableBounds (StaticBody2D + TableBounds.gd)
└── UIRenderer (CanvasLayer + UIRenderer.gd)
    ├── ScoreLabel
    ├── BallCountLabel
    ├── PauseOverlay
    ├── GameOverOverlay
    ├── AttractScreen
    └── InitialsPrompt
```

**Troubleshooting:**
- *I can't find `AnimatableBody2D` in the search.* Make sure you're using Godot 4, not Godot 3. In Godot 3, this type doesn't exist.
- *The script attach dialog doesn't show my file.* Make sure you're browsing from `res://` (the project root). The path should look like `res://src/nodes/Ball.gd`.
- *I accidentally added a node in the wrong place.* You can drag nodes up/down or in/out of parent nodes directly in the Scene panel.

### 5d — Save the scene

Press **Ctrl+S** (Windows/Linux) or **Cmd+S** (Mac). Save it as `Main.tscn` inside the `src/scenes/` folder.

---

## Part 6 — Set the Main Scene

Godot needs to know which scene to open when the game starts.

1. Go to **Project** → **Project Settings** → **General** tab.
2. Search for `main scene` or look under **Application > Run**.
3. Find the **Main Scene** field and click the folder icon.
4. Navigate to `src/scenes/Main.tscn` and select it.

### ✅ Checkpoint 6
The Main Scene field should now show `res://src/scenes/Main.tscn`.

---

## Part 7 — Run the Smoke Test

This is your first real test to make sure everything connects correctly.

1. In the **FileSystem** panel, navigate to `tests/integration/`.
2. Find `test_game_loop_smoke.gd`.
3. Create a quick test scene: go to **Scene** → **New Scene** → add a plain `Node` root → rename it `SmokeTest` → attach `test_game_loop_smoke.gd` as its script.
4. Press **F6** to run the current scene (not the whole game).
5. Look at the **Output** panel at the bottom of the editor.

### ✅ Checkpoint 7 — What to look for
You should see lines in the Output panel confirming:
- `[PASS] ATTRACT → PLAYING on LAUNCH`
- `[PASS] balls_remaining decrements on drain`
- `[PASS] GAME_OVER on last drain`

**Troubleshooting:**
- *Output shows errors in red.* The most common cause is a missing AutoLoad. Go back to Part 2 and confirm all 4 are listed and spelled correctly.
- *"Node not found" error mentioning `$Ball` or `$FlipperLeft`.* The node names in your scene don't match what the script expects. Go back to Part 5 and confirm the names are spelled exactly as listed — capital letters included.
- *Output panel is empty or not visible.* Click the **Output** tab at the very bottom of the editor window. If it's not there, go to **Editor → Bottom Panel → Output**.

---

## Part 8 — Run the Full Game

1. Press **F5** (or click the ▶ play button at the top).
2. A game window should open showing the attract screen.
3. Press **Space** to launch the ball.
4. Press **Z** for the left flipper, **/** for the right flipper.

### ✅ Final Checkpoint
The game window opens, the attract screen is visible, and pressing Space starts a game. The ball launches upward. Pressing Z and / moves the flippers.

**Troubleshooting:**
- *Black screen on launch.* The Main Scene isn't set. Revisit Part 6.
- *Ball launches but falls straight through.* The DrainZone CollisionShape2D needs a shape assigned. Click `DrainZone → CollisionShape2D` in the Scene panel, then in the Inspector set **Shape** to `new RectangleShape2D` and resize it to span the bottom of the screen.
- *No error but nothing happens when pressing Space.* The `launch` input action may be missing or misspelled. Revisit Part 4.

---

## What's Next

Once the game runs, the remaining work is adding visual and audio assets to make it look and sound like a pinball machine. Place files in your `assets/` folder:

- **Sprites** — ball, left/right flipper, bumper (normal + lit up), target (active/inactive), table background image
- **Audio** — bumper hit sound, flipper sound, drain sound, game-over jingle

These can be free assets from [itch.io](https://itch.io/game-assets/free) or [kenney.nl](https://kenney.nl/assets). Once placed in `assets/`, you'll connect them to nodes via the Inspector's **Texture** and **Stream** fields on the respective nodes.
