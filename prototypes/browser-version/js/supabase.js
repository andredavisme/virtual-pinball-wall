/**
 * supabase.js -- Optional leaderboard integration
 * Mirrors pseudocode/06-score-service.md
 *
 * Set SUPABASE_URL and SUPABASE_ANON_KEY to enable.
 * Schema: scores(id, table_id FK, player_initials, score, played_at, created_at DEFAULT now())
 * Do NOT include created_at in INSERT payloads.
 */

const SUPABASE_URL      = '';  // e.g. 'https://xyzxyz.supabase.co'
const SUPABASE_ANON_KEY = '';  // public anon key

let _client = null;

function getClient() {
  if (_client) return _client;
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) return null;
  if (typeof window.supabase !== 'undefined') {
    _client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }
  return _client;
}

/**
 * postScore -- mirrors score_service.post_score()
 * VALIDATE: non-empty, max 3 chars, alphanumeric
 * created_at NOT included (DB DEFAULT now())
 */
export async function postScore(playerInitials, score, tableId) {
  const initials = playerInitials.trim().toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 3);
  if (!initials) return { error: 'Invalid initials' };
  const client = getClient();
  if (!client) { console.info('[supabase.js] No credentials -- score not persisted.'); return { data: null, error: null }; }
  const payload = {
    player_initials: initials,
    score,
    played_at: new Date().toISOString(),
    ...(tableId ? { table_id: tableId } : {}),
  };
  const { data, error } = await client.from('scores').insert(payload);
  if (error) console.warn('[supabase.js] postScore error:', error.message);
  return { data, error };
}

/**
 * getLeaderboard -- mirrors score_service.get_leaderboard()
 * Called once on GAME_OVER entry, result cached. NOT called per frame.
 */
export async function getLeaderboard(tableId, limit = 10) {
  const client = getClient();
  if (!client) return [];
  let query = client.from('scores')
    .select('player_initials, score, played_at')
    .order('score', { ascending: false })
    .limit(limit);
  if (tableId) query = query.eq('table_id', tableId);
  const { data, error } = await query;
  if (error) { console.warn('[supabase.js] getLeaderboard error:', error.message); return []; }
  return data ?? [];
}
