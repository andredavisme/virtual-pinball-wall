# Pseudocode: Score Service (M4)

## File: `src/engine/score_service`

```
FUNCTION post_score(player_initials, score, table_id):
  # player_initials: 3-character string entered by player at GAME_OVER
  # Triggered by on_initials_confirmed() in GameLoop — never called directly from render loop
  # `created_at` is NOT included in payload — DB column has DEFAULT now() and auto-populates
  VALIDATE player_initials (non-empty, max 3 chars, alphanumeric)
  PAYLOAD = { player_initials, score, table_id, played_at: now() }
  POST to Supabase `scores` table
  RETURN success | error

FUNCTION get_leaderboard(table_id, limit = 10):
  # Called once on GAME_OVER state entry and cached in GameLoop
  # Result passed to UIRenderer as cached_leaderboard — not fetched per frame
  FETCH from Supabase `scores`
    WHERE table_id = table_id
    ORDER BY score DESC
    LIMIT limit
  RETURN list of { player_initials, score, played_at }
```
