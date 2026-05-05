#!/usr/bin/env bash
# Smoke test for amplitude-event-mapper.
#
# Verifies the demo project's expected output is well-formed and consistent
# with the bundled fixtures. Does NOT spawn Claude — that requires user
# interaction and an active session. Instead, checks that:
#
#   1. Every required file exists in examples/demo-ppf-mx/expected/
#   2. The expected proposal references all cells declared in input.yaml
#   3. The expected proposal includes a [CONFIRM] checklist
#   4. The expected final-event-map.md has no [CONFIRM] tags (they were stripped)
#   5. The expected final-event-map.md retains [NEW] tags
#
# Run from repo root:
#   ./bin/smoke-test.sh
#
# Exit codes:
#   0 — all checks passed
#   1 — at least one check failed

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_DIR="${REPO_ROOT}/examples/demo-ppf-mx"
EXPECTED_DIR="${DEMO_DIR}/expected"

fail() {
  echo "[smoke-test] FAIL: $1" >&2
  exit 1
}

pass() {
  echo "[smoke-test] OK: $1"
}

# 1. Required files
for f in source-docs.md existing-events.md cross-check.md proposed-events.md final-event-map.md; do
  if [[ ! -f "${EXPECTED_DIR}/${f}" ]]; then
    fail "missing expected/${f}"
  fi
  pass "found expected/${f}"
done

# 2. Cells referenced in proposed-events.md
PROPOSAL="${EXPECTED_DIR}/proposed-events.md"
for cell in control soft hard; do
  if ! grep -q "\b${cell}\b" "${PROPOSAL}"; then
    fail "proposed-events.md does not reference cell: ${cell}"
  fi
done
pass "proposed-events.md references control, soft, hard"

# 3. Open-questions checklist
if ! grep -q '## Open questions' "${PROPOSAL}"; then
  fail "proposed-events.md is missing the Open questions section"
fi
if ! grep -qE '^\- \[ \] [0-9]+\. ' "${PROPOSAL}"; then
  fail "proposed-events.md has no numbered checklist items"
fi
pass "proposed-events.md has a numbered Open questions checklist"

# 4. final-event-map.md has no [CONFIRM] tags
FINAL="${EXPECTED_DIR}/final-event-map.md"
if grep -q '\[CONFIRM\]' "${FINAL}"; then
  fail "final-event-map.md still contains [CONFIRM] tags (should have been stripped)"
fi
pass "final-event-map.md has no [CONFIRM] tags"

# 5. final-event-map.md retains [NEW] tags
if ! grep -q '\[NEW\]' "${FINAL}"; then
  fail "final-event-map.md is missing [NEW] tags (they should be preserved)"
fi
pass "final-event-map.md retains [NEW] tags"

# 6. Side-effect guard sanity — hooks/hooks.json must contain the four deny matchers
HOOKS="${REPO_ROOT}/hooks/hooks.json"
for matcher in "slack_send_" "Atlassian__create" "google-workspace" "Bash"; do
  if ! grep -q "${matcher}" "${HOOKS}"; then
    fail "hooks/hooks.json is missing matcher containing: ${matcher}"
  fi
done
pass "hooks/hooks.json contains the four deny matchers"

# 7. plugin.json well-formed
PLUGIN="${REPO_ROOT}/.claude-plugin/plugin.json"
if ! python3 -c "import json,sys; json.load(open('${PLUGIN}'))" 2>/dev/null; then
  fail "plugin.json is not valid JSON"
fi
pass "plugin.json is valid JSON"

# 8. .mcp.json well-formed
MCP="${REPO_ROOT}/.mcp.json"
if ! python3 -c "import json,sys; json.load(open('${MCP}'))" 2>/dev/null; then
  fail ".mcp.json is not valid JSON"
fi
pass ".mcp.json is valid JSON"

echo
echo "[smoke-test] all checks passed"
exit 0
