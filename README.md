# Amplitude Event Mapper

AI-assisted Amplitude event proposal from **Figma** (primary) + Miro + Confluence + Databricks. Read-only by design — outputs markdown for engineer review. No Slack messages, no Jira tickets, no Confluence writes.

## What it does

For a given project, the plugin walks every screen / button / row / interaction in your Figma file, cross-checks against your squad's Miro event board and live production data in Databricks, and produces a delta-only event proposal:

- Reuses NuDS# events (`widget__loaded`, `widget__clicked`, `screen__viewed`, `button__clicked`, `deeplink_clicked`) wherever possible
- Defines new property values rather than new event types
- For A/B tests, defines every event for every cell (control + variants) with a `variant` property
- Tags every new value with `[NEW]` and every value needing engineer validation with `[CONFIRM]`
- Produces a single open-questions checklist engineers can sign off per item

## Install (60 seconds)

```bash
git clone https://github.com/luccaromanelli-nu/amplitude-event-mapper.git
cd amplitude-event-mapper
cp .env.example .env       # edit NU_BU, NU_COUNTRY, FIGMA_TOKEN, NU_DATABRICKS_*
claude --plugin-dir .
```

## Demo run (no creds needed)

```
/amplitude-event-mapper:propose --demo
```

Reads `examples/demo-ppf-mx/fixtures/` and writes to `projects/demo-ppf-mx/`. Compare with `examples/demo-ppf-mx/expected/`.

Or run the smoke test:

```bash
./bin/smoke-test.sh
```

## Real project

In Claude, scaffold the project interactively:

```
/amplitude-event-mapper:create-project <your-project>
```

This asks for country, scope, Figma URL, A/B cells (if any), Miro and Confluence URLs, and writes `projects/<your-project>/input.yaml`. Then run the pipeline:

```
/amplitude-event-mapper:propose <your-project>
```

Prefer to scaffold by hand? Copy the template instead:

```bash
mkdir -p projects/<your-project>
cp templates/input-template.yaml projects/<your-project>/input.yaml
$EDITOR projects/<your-project>/input.yaml
```

Review `projects/<your-project>/proposed-events.md`. When ready:

```bash
touch projects/<your-project>/APPROVED
```

Rerun `/amplitude-event-mapper:propose <your-project>` (auto-promotes) or run `/amplitude-event-mapper:finalize <your-project>` to copy the approved proposal to `final-event-map.md`.

## Slash commands

| Command | Use |
|---------|-----|
| `/amplitude-event-mapper:create-project <project>` | Interactive scaffold of `projects/<project>/input.yaml` |
| `/amplitude-event-mapper:propose <project>` | Full pipeline: gather → cross-check → propose → format |
| `/amplitude-event-mapper:propose --demo` | Same, using bundled fixtures |
| `/amplitude-event-mapper:gather <project>` | Gather only (refresh inputs) |
| `/amplitude-event-mapper:cross-check <project>` | Re-run the gap matrix |
| `/amplitude-event-mapper:propose-only <project>` | Regenerate proposal from existing gather output |
| `/amplitude-event-mapper:finalize <project>` | Promote approved proposal to `final-event-map.md` |

## Side-effect guarantee

The plugin's hook layer denies every write tool (Slack send, Jira create, Confluence create, Atlassian comment, Google Workspace create, Bash) by default. All MCP calls are read-only.

If you see the plugin attempting a write tool, report it as a bug.

## Project layout

```
amplitude-event-mapper/
├── .claude-plugin/plugin.json
├── .mcp.json                # vendored: figma + miro + databricks
├── CLAUDE.md                # workflow, decision tree, side-effect rules
├── commands/                # slash commands
├── skills/                  # model-invokable skills
├── agents/                  # subagents (one per data source + analysis step)
├── hooks/hooks.json         # PreToolUse deny list
├── catalog/                 # seed catalog of NuDS# events + naming conventions
├── templates/               # event/proposal/cross-check templates
├── examples/demo-ppf-mx/    # bundled demo project
├── docs/                    # workflow, inputs, outputs, env vars, auth, FAQ
└── projects/                # (gitignored) per-project run outputs
```

## Documentation

- [`QUICKSTART.md`](QUICKSTART.md) — 5-step demo walk
- [`docs/workflow.md`](docs/workflow.md) — pipeline diagram, subagent responsibilities
- [`docs/inputs.md`](docs/inputs.md) — `input.yaml` schema, every field explained
- [`docs/outputs.md`](docs/outputs.md) — every output file annotated
- [`docs/decision-tree.md`](docs/decision-tree.md) — NuDS# reuse rules, A/B-cell rule, PPF learnings
- [`docs/env-vars.md`](docs/env-vars.md) — every environment variable
- [`docs/auth.md`](docs/auth.md) — how to authenticate each MCP
- [`docs/faq.md`](docs/faq.md) — troubleshooting

## Status

v0.1.0 — pilot. Validated end-to-end via `bin/smoke-test.sh` on the bundled PPF MX demo project. Real-project validation pending PPF Awareness Optimization (MX) pilot run.
