# Pseudocode: Score Service (M4)

## File: `src/engine/score_service`

```
FUNCTION post_score(player_initials, score, table_id):
  PAYLOAD = { player_initials, score, table_id, played_at: now() }
  POST to Supabase `scores` table
  RETURN success | error

FUNCTION get_leaderboard(table_id, limit = 10):
  FETCH from Supabase `scores`
    WHERE table_id = table_id
    ORDER BY score DESC
    LIMIT limit
  RETURN list of { player_initials, score, played_at }
```
