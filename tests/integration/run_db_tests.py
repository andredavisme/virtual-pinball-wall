#!/usr/bin/env python3
"""
run_db_tests.py
Standalone integration test runner for the virtual-pinball-wall Supabase DB.
No Godot required. Hits the REST API directly.

Usage:
  pip install requests
  python tests/integration/run_db_tests.py \\
    --url https://hhyhulqngdkwsxhymmcd.supabase.co \\
    --key <anon-key> \\
    --table-id <uuid>
"""

import argparse
import json
import sys
import time
import uuid
import requests

PASS = "\033[92m\u2705 PASS\033[0m"
FAIL = "\033[91m\u274c FAIL\033[0m"
SKIP = "\033[93m\u23ed SKIP\033[0m"

results = []


def log(suite, name, status, message=None, duration_ms=0):
    icon = PASS if status == "pass" else (SKIP if status == "skip" else FAIL)
    print(f"  {icon}  [{suite}] {name}" + (f"\n         → {message}" if message else ""))
    results.append({
        "test_suite": suite,
        "test_name": name,
        "status": status,
        "message": message,
        "duration_ms": duration_ms,
    })


def headers(key):
    return {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
    }


# ---------------------------------------------------------------------------
# Suite: tables table
# ---------------------------------------------------------------------------

def test_tables_row_exists(url, key, table_id):
    suite = "DBLive"
    t = time.time()
    r = requests.get(
        f"{url}/rest/v1/tables",
        headers=headers(key),
        params={"id": f"eq.{table_id}", "select": "id,name,layout,is_active"},
    )
    ms = int((time.time() - t) * 1000)
    if r.status_code != 200 or len(r.json()) == 0:
        log(suite, "tables_row_exists", "fail",
            f"HTTP {r.status_code}: {r.text[:200]}", ms)
        return None
    row = r.json()[0]
    for col in ["id", "name", "layout", "is_active"]:
        if col not in row:
            log(suite, "tables_row_exists", "fail", f"Missing column: {col}", ms)
            return None
    log(suite, "tables_row_exists", "pass", duration_ms=ms)
    return row


def test_layout_shape(url, key, table_id):
    suite = "DBLive"
    t = time.time()
    r = requests.get(
        f"{url}/rest/v1/tables",
        headers=headers(key),
        params={"id": f"eq.{table_id}", "select": "layout"},
    )
    ms = int((time.time() - t) * 1000)
    if r.status_code != 200 or len(r.json()) == 0:
        log(suite, "layout_shape", "fail", f"HTTP {r.status_code}", ms)
        return
    layout = r.json()[0]["layout"]
    if isinstance(layout, str):
        layout = json.loads(layout)
    for key_name in ["bumpers", "targets", "flippers", "walls", "launch_position", "drain_y"]:
        if key_name not in layout:
            log(suite, "layout_shape", "fail", f"Missing layout key: {key_name}", ms)
            return
    # targets must have `active` field
    for target in layout.get("targets", []):
        if "active" not in target:
            log(suite, "layout_shape", "fail", "Target missing 'active' field", ms)
            return
    log(suite, "layout_shape", "pass", duration_ms=ms)


# ---------------------------------------------------------------------------
# Suite: scores table
# ---------------------------------------------------------------------------

def test_score_insert_and_select(url, key, table_id):
    suite = "ScoreServiceLive"
    t = time.time()
    payload = {
        "player_initials": "ZZZ",
        "score": 1,
        "table_id": table_id,
        "played_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    r = requests.post(f"{url}/rest/v1/scores", headers=headers(key), json=payload)
    ms = int((time.time() - t) * 1000)
    if r.status_code not in (200, 201):
        log(suite, "score_insert", "fail", f"HTTP {r.status_code}: {r.text[:200]}", ms)
        return
    inserted = r.json()
    inserted_id = inserted[0]["id"] if inserted else None
    # SELECT
    r2 = requests.get(
        f"{url}/rest/v1/scores",
        headers=headers(key),
        params={"player_initials": "eq.ZZZ", "table_id": f"eq.{table_id}",
                "order": "played_at.desc", "limit": "1"},
    )
    if r2.status_code != 200 or len(r2.json()) == 0:
        log(suite, "score_insert", "fail", "Inserted score not found on SELECT", ms)
    else:
        log(suite, "score_insert", "pass", duration_ms=ms)
    # Cleanup
    if inserted_id:
        requests.delete(
            f"{url}/rest/v1/scores",
            headers=headers(key),
            params={"id": f"eq.{inserted_id}"},
        )


def test_score_validation(url, key, table_id):
    """Supabase won't enforce initials length — that's a client-side guard.
    This test verifies we can't bypass the table FK constraint with a bad table_id."""
    suite = "ScoreServiceLive"
    t = time.time()
    bad_payload = {
        "player_initials": "ZZZ",
        "score": 1,
        "table_id": str(uuid.uuid4()),  # nonexistent FK
        "played_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    r = requests.post(f"{url}/rest/v1/scores", headers=headers(key), json=bad_payload)
    ms = int((time.time() - t) * 1000)
    if r.status_code in (200, 201):
        log(suite, "score_fk_constraint", "fail",
            "Expected FK violation but insert succeeded", ms)
    else:
        log(suite, "score_fk_constraint", "pass", duration_ms=ms)


def test_leaderboard_sort(url, key, table_id):
    suite = "ScoreServiceLive"
    t = time.time()
    r = requests.get(
        f"{url}/rest/v1/scores",
        headers=headers(key),
        params={"table_id": f"eq.{table_id}", "order": "score.desc",
                "limit": "10", "select": "player_initials,score,played_at"},
    )
    ms = int((time.time() - t) * 1000)
    if r.status_code != 200:
        log(suite, "leaderboard_sort", "fail", f"HTTP {r.status_code}", ms)
        return
    rows = r.json()
    for i in range(len(rows) - 1):
        if rows[i]["score"] < rows[i + 1]["score"]:
            log(suite, "leaderboard_sort", "fail",
                f"Not sorted desc at index {i}", ms)
            return
    log(suite, "leaderboard_sort", "pass", duration_ms=ms)


# ---------------------------------------------------------------------------
# Suite: test_log table
# ---------------------------------------------------------------------------

def test_test_log_insert(url, key):
    suite = "DBLive"
    t = time.time()
    payload = {
        "test_suite": "DBLive",
        "test_name":  "python_runner_write",
        "status":     "pass",
        "message":    "written by run_db_tests.py",
        "duration_ms": 0,
    }
    r = requests.post(f"{url}/rest/v1/test_log", headers=headers(key), json=payload)
    ms = int((time.time() - t) * 1000)
    if r.status_code not in (200, 201):
        log(suite, "test_log_insert", "fail", f"HTTP {r.status_code}: {r.text[:200]}", ms)
    else:
        log(suite, "test_log_insert", "pass", duration_ms=ms)


# ---------------------------------------------------------------------------
# Log all results back to test_log
# ---------------------------------------------------------------------------

def push_results_to_supabase(url, key):
    print("\nLogging results to Supabase test_log...")
    for r in results:
        requests.post(f"{url}/rest/v1/test_log",
                      headers=headers(key), json=r)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Virtual Pinball Wall — DB integration tests")
    parser.add_argument("--url",      required=True, help="Supabase project URL")
    parser.add_argument("--key",      required=True, help="Supabase anon key")
    parser.add_argument("--table-id", required=True, help="UUID of a row in the tables table")
    args = parser.parse_args()

    print("=== Virtual Pinball Wall — DB Integration Tests ===")
    print(f"  URL:      {args.url}")
    print(f"  Table ID: {args.table_id}\n")

    # tables suite
    test_tables_row_exists(args.url, args.key, args.table_id)
    test_layout_shape(args.url, args.key, args.table_id)

    # scores suite
    test_score_insert_and_select(args.url, args.key, args.table_id)
    test_score_validation(args.url, args.key, args.table_id)
    test_leaderboard_sort(args.url, args.key, args.table_id)

    # test_log suite
    test_test_log_insert(args.url, args.key)

    # Summary
    passed  = sum(1 for r in results if r["status"] == "pass")
    failed  = sum(1 for r in results if r["status"] == "fail")
    skipped = sum(1 for r in results if r["status"] == "skip")
    print(f"\n--- {passed} passed  {failed} failed  {skipped} skipped ---")

    push_results_to_supabase(args.url, args.key)

    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
