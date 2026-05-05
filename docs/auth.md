# Auth — per MCP

The plugin vendors three MCP servers in `.mcp.json`: Figma, Miro, Databricks. Atlassian and Glean are assumed to be available from the user's Claude Code environment.

## Figma

Use a Figma personal access token (read-only is enough).

1. https://www.figma.com/developers/api#access-tokens — generate a token.
2. Add to `.env`:
   ```
   FIGMA_TOKEN=figd_<token>
   ```
3. Restart Claude Code with `--plugin-dir .`.

Test with the demo first; once that works, point the figma-walker at a real file.

## Miro

OAuth. On the first call to a Miro tool, Claude Code prompts you to authorize in the browser. Accept the prompt; the token is stored in your Claude Code keychain.

If you have never used the Miro MCP in this Claude Code install, run any read action against a Miro board to trigger the flow.

## Atlassian (Confluence + Jira)

Built into Claude Code — no extra setup if you have already used `mcp__Atlassian__*` tools elsewhere. If you have not, the first call prompts an OAuth flow.

The plugin only uses read methods (`getConfluencePage`, `searchConfluenceUsingCql`, `search`, `fetch`, `getJiraIssue`, `searchJiraIssuesUsingJql`). The hook layer denies every write method (`create*`, `edit*`, `addComment*`, `addWorklog*`, `transition*`, `update*`).

## Databricks

Use a personal access token with read-only permissions on the relevant catalog/schema.

1. In Databricks: Settings → User Settings → Developer → Access tokens → Generate new token.
2. Get your workspace URL (Settings → Workspace) and SQL warehouse ID.
3. Add to `.env`:
   ```
   NU_DATABRICKS_HOST=https://<workspace>.cloud.databricks.com
   NU_DATABRICKS_TOKEN=dapi<token>
   NU_DATABRICKS_WAREHOUSE_ID=<warehouse-id>
   ```
4. Confirm Mantiqueira BU access:
   - Per Nubank's CC Financing Databricks doc, workspace permissions follow Mantiqueira BU groups.
   - If `NU_BU=cc-financing`, you must be in the CC Financing BU group.
   - If outside CC Financing, set `NU_BU` to your BU and verify membership.

If you see "access denied" in `source-docs.md`, your BU group does not match the workspace.

## Glean

Built into Claude Code. OAuth on first use. The plugin only uses Glean as a fallback for taxonomy lookups; no writes.

## Demo mode bypasses everything

Run `/amplitude-event-mapper:propose --demo` to validate the plugin without auth. The fixture readers replace every MCP call.
