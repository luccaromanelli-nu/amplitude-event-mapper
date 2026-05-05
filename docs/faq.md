# FAQ

## "Skill not found" in Claude Code

Run `/reload-plugins` or restart with `--plugin-dir .`. Verify the plugin loaded with `/help` — you should see a `amplitude-event-mapper:` namespace.

## The proposer is asking me a question instead of generating

You probably did not provide enough input. Verify `projects/<project>/input.yaml`:

- `scope` is at least 2 sentences
- `country` is `BR`, `MX`, or `CO`
- `sources.figma` has at least one URL or fixture path
- If `ab_test: true`: `cells` includes `control`, and `expr_id` is set

## Empty Figma walk

Possible causes:

- Token does not have read access to the file → check Figma UI as your user
- File URL is wrong → open the URL manually
- File is empty → confirm in Figma UI

## Empty Databricks prober output

Possible causes:

- `NU_BU` does not match a Mantiqueira group with workspace access → verify in Mantiqueira
- `NU_DATABRICKS_HOST` / `NU_DATABRICKS_TOKEN` missing or invalid → re-issue the token
- `country` does not match the catalog (e.g. table doesn't exist for that country) → check Databricks catalog UI

## A hook denied my tool call

That is the side-effect guard. If the call was legitimate (e.g. you wanted to read a Confluence page using a tool that wasn't whitelisted), file a bug. Do NOT bypass the guard — the plugin's read-only guarantee depends on it.

## I want to add a new MCP source

1. Add it to `.mcp.json`.
2. Create a new agent file in `agents/<name>.md` (read-only).
3. Create a new skill in `skills/gather-<name>/SKILL.md`.
4. Update `skills/orchestrate/SKILL.md` to spawn the new agent in the gather step.
5. Update `docs/workflow.md` and `README.md`.

## I want to share my plugin with the team

Two paths:

1. **Personal repo** (current setup) — push to GitHub, teammates clone and `claude --plugin-dir .`.
2. **Marketplace entry** — once the plugin is stable, add an entry to your team's marketplace `marketplace.json`. Teammates install with `/plugin install amplitude-event-mapper@<marketplace>`.

For the Nubank internal marketplace, see `nubank-ai-agents-plugins/.claude-plugin/marketplace.json` for the entry format.

## How do I know if my smoke test passes?

```bash
./bin/smoke-test.sh
```

Exit code 0 means the demo run produced output identical to `examples/demo-ppf-mx/expected/`. Non-zero means there is a diff — inspect with:

```bash
diff -ru projects/demo-ppf-mx/ examples/demo-ppf-mx/expected/
```

## I want to change the decision tree rules

Edit BOTH:

- `skills/decision-tree/SKILL.md` (the agent-loaded copy)
- `docs/decision-tree.md` (the human-facing reference)

Keep them in sync. Re-run the smoke test after.

## What if I want to generate code from the final event map?

Out of scope for this plugin. Build a separate skill that reads `projects/<project>/final-event-map.md` and produces code. Engineers on the consuming team have signaled they want to do this — the proposal format is designed to be machine-parseable.

## Why no Jira / Confluence / Slack writes?

The plugin's value is in the cross-checked, delta-only proposal — not in side effects. Writing to external systems makes the plugin harder to trust ("what if it pushes the wrong proposal?"), harder to reproduce, and harder to undo. Engineers can copy the markdown into a Jira ticket or a Slack thread themselves; that is one paste, one person, one decision.

If a future feature genuinely needs writes, it should be opt-in (per-command `--allow-write` flag) and gated by an explicit confirm step.
