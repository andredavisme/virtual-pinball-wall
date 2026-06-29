/**
 * config.js
 * Local game configuration -- mirrors config/game.json from the Godot project.
 * Environment/hardware-specific settings; not stored in Supabase.
 */
export const GAME_CONFIG = {
  balls_per_game: 3,
  target_display_resolution: { width: 1080, height: 1920 },
  // active_table_id can be overridden to load a different table from Supabase
  active_table_id: null,
};

/**
 * Default table layout -- mirrors the JSONB `layout` column from the `tables` schema.
 * Coordinates are in logical canvas units (720 wide x 1280 tall).
 * Scaled to actual canvas pixel size at runtime by the physics module.
 */
export const DEFAULT_TABLE_LAYOUT = {
  bumpers: [
    { x: 260, y: 420, radius: 28, score_value: 100 },
    { x: 460, y: 380, radius: 28, score_value: 100 },
    { x: 360, y: 310, radius: 28, score_value: 150 },
  ],
  targets: [
    { x: 160, y: 620, width: 60, height: 12, score_value: 50,  active: true },
    { x: 300, y: 600, width: 60, height: 12, score_value: 50,  active: true },
    { x: 440, y: 620, width: 60, height: 12, score_value: 50,  active: true },
    { x: 560, y: 580, width: 60, height: 12, score_value: 75,  active: true },
  ],
  flippers: [
    {
      side: "LEFT",
      pivot: { x: 200, y: 1140 },
      length: 130,
      angle_rest: 30,     // degrees, down position
      angle_active: -25,  // degrees, up position
    },
    {
      side: "RIGHT",
      pivot: { x: 520, y: 1140 },
      length: 130,
      angle_rest: 150,    // degrees, down position (mirrored)
      angle_active: 205,  // degrees, up position
    },
  ],
  walls: [
    { start: { x: 60,  y: 0    }, end: { x: 60,  y: 1100 } },
    { start: { x: 660, y: 0    }, end: { x: 660, y: 1100 } },
    { start: { x: 60,  y: 1000 }, end: { x: 160, y: 1100 } },
    { start: { x: 660, y: 1000 }, end: { x: 560, y: 1100 } },
    { start: { x: 60,  y: 0    }, end: { x: 360, y: 0    } },
    { start: { x: 360, y: 0    }, end: { x: 660, y: 0    } },
  ],
  launch_position: { x: 630, y: 1060 },
  drain_y: 1200,
};
