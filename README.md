# Roo SPARCâ€“Agileâ€“DevOps Boomerang Starter

This repo is a **turnkey Roo Code project scaffold**: Boomerang Tasks, a SPARC+Agile+DevOps workflow, MCP playbooks, and universal HANDOFF/STATE contracts. Clone â†’ open in VS Code â†’ pick modes â†’ build.

## Quick start
1. **Clone** this repo and open the folder in VS Code.
2. In Roo Code **Settings â†’ Modes**, ensure your `.roomodes` file is active (project-level).
3. Toggle Roo Code UI:
   - âœ… Always approve switching
   - âœ… Always approve subtask creation/completion
4. Set API keys (optional but recommended) for MCP servers (see `docs/mcp/config.sample.md`).
5. Edit `memory-bank/productContext.md` (seed context) and start in **SPARC Orchestrator**.

## Project identity
- Default `projectId`: `sample-app`. Change by renaming `project/sample-app/` and search/replace in the repo.

## Contracts
- HANDOFF instances â†’ `project/<id>/control/handoffs/*.handoff.json`
- Runtime graph â†’ `project/<id>/control/graph.yaml`
- Orchestrator state â†’ `project/<id>/control/state.json`

Run `./scripts/validate.sh` to validate JSON/YAML against schemas (requires Node + `ajv`). See CI for an example.

## Modes & philosophy
- **sparc-orchestrator** delegates only (no browsing/MCP), writes state & progress, and routes per `graph.yaml`.
- Specialists own their artifacts. **MCP** is used by `data-researcher` and `sparc-autonomous-adversary` (and others you may later enable).

Happy shipping ðŸš€
