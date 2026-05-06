# Quickstart — 5 steps, ~5 minutes

This walks you through running the plugin against the bundled demo project. No real credentials needed.

## 1. Install the plugin

```bash
git clone https://github.com/luccaromanelli-nu/amplitude-event-mapper.git
cd amplitude-event-mapper
cp .env.example .env
claude --plugin-dir .
```

You should see the plugin loaded. Run `/help` and look for the `amplitude-event-mapper:` namespace.

## 2. Run the demo

In Claude:

```
/amplitude-event-mapper:propose --demo
```

The orchestrator skill spawns four gather agents in parallel (Figma walker, Miro fetcher, Confluence fetcher, Databricks prober), each reading from `examples/demo-ppf-mx/fixtures/`. After ~30 seconds you should see four files generated under `projects/demo-ppf-mx/`.

Expected stdout (abbreviated):

```
[orchestrate] gathering from 4 sources in parallel...
[figma-walker] 6 screens, 14 interactions enumerated
[miro-event-fetcher] 11 events documented
[confluence-event-fetcher] 1 RFC, 2 tech assessments scanned
[databricks-amplitude-prober] 9 events firing in production
[cross-check] 3 gaps, 2 mismatches
[event-proposer] 8 proposed events across 3 cells
[format-proposal] projects/demo-ppf-mx/proposed-events.md (5.4 KB)
done.
```

## 3. Inspect the output

Open `projects/demo-ppf-mx/proposed-events.md`. You should see:

- One section per event
- Comparison tables for cells (control / soft / hard) where they share an event
- `[NEW]` tags on every property value not yet in production
- `[CONFIRM]` tags on values needing engineer validation
- A consolidated open-questions checklist at the bottom

Diff against the expected snapshot to confirm fidelity:

```bash
diff projects/demo-ppf-mx/proposed-events.md \
     examples/demo-ppf-mx/expected/proposed-events.md
```

(Should be empty.)

## 4. Approve and finalize

The plugin never writes the final event map automatically. Engineers must approve:

```bash
touch projects/demo-ppf-mx/APPROVED
```

Re-run the propose command:

```
/amplitude-event-mapper:propose demo-ppf-mx
```

The orchestrator detects the marker, skips re-generation, and promotes `proposed-events.md` to `final-event-map.md`. Or call finalize directly:

```
/amplitude-event-mapper:finalize demo-ppf-mx
```

## 5. Map your real project

Scaffold the project interactively:

```
/amplitude-event-mapper:create-project <your-project>
```

This asks for country, scope, Figma URL, A/B cells (if any), Miro and Confluence URLs, then writes `projects/<your-project>/input.yaml`. See [`docs/inputs.md`](docs/inputs.md) for the full schema.

Then run the pipeline:

```
/amplitude-event-mapper:propose <your-project>
```

You'll need real auth for this step. See [`docs/auth.md`](docs/auth.md).

Prefer to scaffold by hand? Copy the demo input as a starting point:

```bash
mkdir -p projects/<your-project>
cp examples/demo-ppf-mx/input.yaml projects/<your-project>/input.yaml
$EDITOR projects/<your-project>/input.yaml
```

## Troubleshooting

- **"Skill not found"** — run `/reload-plugins` or restart Claude with `--plugin-dir`.
- **MCP auth errors** — see [`docs/auth.md`](docs/auth.md).
- **Empty Figma walk** — your token may not have read access to the file. Confirm in Figma's UI first.
- **Empty Databricks prober** — confirm `NU_DATABRICKS_*` env vars and Mantiqueira BU group membership.
- **Hook denied a tool call** — that's the side-effect guard. If the denied call was legitimate, file a bug.

See [`docs/faq.md`](docs/faq.md) for more.
