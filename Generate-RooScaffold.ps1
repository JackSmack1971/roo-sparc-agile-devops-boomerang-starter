param(
  [string]$ProjectName = "roo-sparc-agile-devops-boomerang-starter",
  [string]$ProjectId   = "sample-app"
)

$ErrorActionPreference = "Stop"

function Ensure-Dir {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Write-TextFile {
  param(
    [string]$Path,
    [string]$Content
  )
  $dir = Split-Path -Parent $Path
  if ($dir) { Ensure-Dir $dir }
  # UTF8 without BOM (PowerShell 7+) defaults to BOM-less; on 5.1 this is BOM. Either is fine for Roo.
  $Content | Set-Content -LiteralPath $Path -Encoding UTF8
}

$root = Join-Path (Get-Location) $ProjectName

# --- create dirs ---
$dirs = @(
  "$root/.roo/rules",
  "$root/.roo/rules-sparc-orchestrator",
  "$root/.roo/rules-data-researcher",
  "$root/.roo/rules-sparc-autonomous-adversary",
  "$root/docs/contracts",
  "$root/docs/mcp",
  "$root/memory-bank",
  "$root/project/$ProjectId/control/handoffs",
  "$root/.github/workflows",
  "$root/scripts"
)
$dirs | ForEach-Object { Ensure-Dir $_ }

# --- files ---

# README (root)
Write-TextFile -Path "$root/README.md" -Content @'
# Roo SPARC–Agile–DevOps Boomerang Starter

This repo is a **turnkey Roo Code project scaffold**: Boomerang Tasks, a SPARC+Agile+DevOps workflow, MCP playbooks, and universal HANDOFF/STATE contracts. Clone → open in VS Code → pick modes → build.

## Quick start
1. **Clone** this repo and open the folder in VS Code.
2. In Roo Code **Settings → Modes**, ensure your `.roomodes` file is active (project-level).
3. Toggle Roo Code UI:
   - ✅ Always approve switching
   - ✅ Always approve subtask creation/completion
4. Set API keys (optional but recommended) for MCP servers (see `docs/mcp/config.sample.md`).
5. Edit `memory-bank/productContext.md` (seed context) and start in **SPARC Orchestrator**.

## Project identity
- Default `projectId`: `sample-app`. Change by renaming `project/sample-app/` and search/replace in the repo.

## Contracts
- HANDOFF instances → `project/<id>/control/handoffs/*.handoff.json`
- Runtime graph → `project/<id>/control/graph.yaml`
- Orchestrator state → `project/<id>/control/state.json`

Run `./scripts/validate.sh` to validate JSON/YAML against schemas (requires Node + `ajv`). See CI for an example.

## Modes & philosophy
- **sparc-orchestrator** delegates only (no browsing/MCP), writes state & progress, and routes per `graph.yaml`.
- Specialists own their artifacts. **MCP** is used by `data-researcher` and `sparc-autonomous-adversary` (and others you may later enable).

Happy shipping 🚀
'@

# .roomodes (project modes, tuple-less for maximum compatibility)
Write-TextFile -Path "$root/.roomodes" -Content @'
customModes:
  # === Lead (single delegator) ===
  - slug: sparc-orchestrator
    name: SPARC Orchestrator
    whenToUse: Coordinate multi-phase work only; always delegate to specialists.
    roleDefinition: |
      Single delegator. Break work into SPARC phases; route to specialists; enforce quality gates.
      Never implement code or run commands; only delegate, integrate, and update run-state.
    customInstructions: |
      - Delegation-only: use Boomerang tasks (new_task/switch_mode/attempt_completion).
      - Require HANDOFF/V1 for every transfer; reject ambiguous work.
      - Update project/<id>/control/state.json and memory-bank/progress.md; do not produce deliverables yourself.
    groups:
      - read
      - edit

  # === Agile glue ===
  - slug: sparc-project-manager
    name: Project Manager
    whenToUse: Sprint planning, backlog to sprint slicing, stakeholder reporting.
    roleDefinition: |
      Maintain backlog.yaml and sprint.yaml; open Boomerang chains per story; track burn-down.
    customInstructions: |
      - Encode DoR/DoD in HANDOFF acceptance_criteria; update memory-bank/progress.md.
    groups:
      - read
      - edit
      - browser

  # === Discovery / Research ===
  - slug: sparc-specification-writer
    name: Specification Writer
    whenToUse: Turn vague ideas into clear, testable specs and acceptance criteria.
    roleDefinition: |
      Produce specification.md, acceptance-criteria.md, user-scenarios.md; no app code edits.
    customInstructions: |
      - Encode testable AC; include edge cases; handoff with inputs/artifacts listed.
    groups:
      - read
      - edit

  - slug: data-researcher
    name: Enhanced Data Researcher
    whenToUse: Decision-grade external research/evidence is required.
    roleDefinition: |
      Collect high-value sources, synthesize claims, and attach evidence for decision support.
    customInstructions: |
      - Use MCP per playbook; output claims + evidence; include confidence and timestamp.
    groups:
      - read
      - edit
      - browser
      - mcp

  - slug: rapid-fact-checker
    name: Enhanced Fact Checker
    whenToUse: Before decisions that depend on external claims or stats.
    roleDefinition: |
      Cross-source verify claims; record verdicts & confidence; gate progress when needed.
    customInstructions: |
      - Enforce ≥95% confidence on autonomy-critical claims; otherwise mark residual risk.
    groups:
      - read
      - edit
      - browser

  # === Architecture ===
  - slug: sparc-architect
    name: SPARC Architect
    whenToUse: System design, architecture reviews, scalability planning.
    roleDefinition: |
      Produce architecture.md; define components, interfaces, data flows, and observability.
    customInstructions: |
      - Enforce ≤500 lines/module rule in guidance; provide interface tables & risks.
    groups:
      - read
      - edit
      - browser

  - slug: sparc-security-architect
    name: Security Architect
    whenToUse: Identity, data, external exposure, or compliance changes.
    roleDefinition: |
      Create threat-model.md and security-architecture.md; map controls and compliance.
    customInstructions: |
      - No secrets; define logging/audit and IR/DR; list trust boundaries and controls.
    groups:
      - read
      - edit
      - browser

  # === Build & Quality ===
  - slug: sparc-pseudocode-designer
    name: Pseudocode Designer
    whenToUse: Before implementation; translate specs into functions & flows.
    roleDefinition: |
      Produce pseudocode.md, function-specs, and complexity notes; no app code edits.
    customInstructions: |
      - Keep logical functions <50 lines; enumerate error handling; include test hooks.
    groups:
      - read
      - edit

  - slug: sparc-tdd-engineer
    name: TDD Engineer
    whenToUse: Before/with implementation; enforce coverage and fast feedback.
    roleDefinition: |
      Write unit/integration/e2e tests; coordinate with implementer until green.
    customInstructions: |
      - Maintain >90% coverage by default; design for reliability; mark failing/green status.
    groups:
      - read
      - edit

  - slug: sparc-code-implementer
    name: Code Implementer
    whenToUse: Only after pseudocode and architecture exist; implement or refactor per specs.
    roleDefinition: |
      Implement code with ≤500 lines/file, single-responsibility, strong error handling.
    customInstructions: |
      - Follow interfaces; no secrets; keep tests passing; reference functions implemented.
    groups:
      - read
      - edit

  - slug: sparc-qa-analyst
    name: QA Analyst
    whenToUse: Acceptance testing, quality plans, and phase gates.
    roleDefinition: |
      Create QA plans, run acceptance tests, publish QA reports; no app code edits.
    customInstructions: |
      - Trace requirements → tests; record acceptance outcomes with evidence.
    groups:
      - read
      - edit

  - slug: sparc-integrator
    name: Integrator
    whenToUse: Final system validation and delivery readiness checks.
    roleDefinition: |
      Validate contracts/data-flows, E2E scenarios, security controls, and performance under load.
    customInstructions: |
      - Require all edges to pass before delivery sign-off; include integration-report.md.
    groups:
      - read
      - edit

  # === Ops ===
  - slug: sparc-platform-engineer
    name: SPARC Platform Engineer
    whenToUse: Infra design, pipeline setup, platform runbooks.
    roleDefinition: |
      Design IaC modules, pipelines, and platform runbooks with security best practices.
    customInstructions: |
      - Plan DR/backups; validate pipelines with rollback; list environments touched.
    groups:
      - read
      - edit
      - browser

  - slug: sparc-sre-engineer
    name: SPARC SRE Engineer
    whenToUse: Reliability design, production readiness, and ops procedures.
    roleDefinition: |
      Define SLI/SLO frameworks, monitoring/alerting, incident playbooks, and error budgets.
    customInstructions: |
      - Provide dashboards/alerts; include SLO targets and error budgets; attach runbooks.
    groups:
      - read
      - edit
      - browser

  # === Assurance & Adversarial ===
  - slug: security-reviewer
    name: Security Reviewer
    whenToUse: Code/infra security reviews and compliance validation.
    roleDefinition: |
      Run SAST/dependency/config scans (read-only code access); publish audit reports & fixes.
    customInstructions: |
      - Never modify app code; document reproducible steps and SARIF artifacts.
    groups:
      - read
      - edit
      - browser
      - command

  - slug: sparc-autonomous-adversary
    name: SPARC Autonomous Adversary
    whenToUse: Comprehensive risk review before production or major changes.
    roleDefinition: |
      Enumerate edge cases/failures, validate controls/monitoring/IR, and assess autonomy-specific risks.
    customInstructions: |
      - Front-load top risks; require ≥95% mitigations for go/no-go; attach risk register deltas.
    groups:
      - read
      - edit
      - browser
      - mcp

  # === UX ===
  - slug: sparc-ux-architect
    name: SPARC UX Architect
    whenToUse: UX strategy/wireframes/journeys and accessibility reviews.
    roleDefinition: |
      Produce UX strategy, journeys, wireframes; ensure WCAG-compliant guidance.
    customInstructions: |
      - Include personas/flows and a11y checks in every deliverable; attach artifacts list.
    groups:
      - read
      - edit
      - browser
'@

# Global rules
Write-TextFile -Path "$root/.roo/rules/global-governance.md" -Content @'
# Global Governance (all modes)

- EVERY transfer between modes MUST create a HANDOFF/V1 JSON in `project/<id>/control/handoffs/`.
- Prefer Boomerang subtasks over doing cross-domain work in one mode.
- Cite sources, record timestamps, and log MCP usage to `project/<id>/control/mcp-usage.log.jsonl`.
- Do not hardcode secrets; redact tokens in logs and artifacts.
- Keep files ≤500 lines where practical; prefer small, testable modules.
- If acceptance criteria are unclear, request clarification or bounce to orchestrator.

## DoR/DoD shorthands (encode in acceptance_criteria)
- DoR: `spec.ready`, `risks.known`, `interfaces.defined`
- DoD: `tests.green`, `security.ok`, `docs.updated`, `pipelines.pass`, `slo.targets.present`
'@

Write-TextFile -Path "$root/.roo/rules/memory-bank-policy.md" -Content @'
# Memory Bank Policy (all modes)

- Use `memory-bank/productContext.md` for business context; keep it current.
- Record architectural decisions in `memory-bank/decisionLog.md` (1 entry per decision).
- Capture reusable patterns in `memory-bank/systemPatterns.md`.
- Update `memory-bank/progress.md` at the end of every phase handoff.

## Pruning
- When a section or entire file is obsolete or contradicted by newer decisions, **replace** the section and add a one-line deprecation note in `decisionLog.md`.
- Do not accumulate stale alternatives; preserve a single, current source of truth.
'@

# Orchestrator rules
Write-TextFile -Path "$root/.roo/rules-sparc-orchestrator/readme.md" -Content @'
The Orchestrator delegates only, updates state & progress, and never produces deliverables itself.
'@

Write-TextFile -Path "$root/.roo/rules-sparc-orchestrator/delegation-only.md" -Content @'
# Delegation-Only Policy (Orchestrator)

You coordinate; you don't implement. Use:
- `new_task`, `switch_mode`, `attempt_completion`, file read/list
- (with legacy schema) you still have `edit`, but only use it for:
  - `project/<id>/control/state.json`
  - `memory-bank/progress.md`
  - `reports/orchestration/*` and `plans/*` (summaries)

Forbidden:
- `browser`, MCP servers, and writing deliverables (specs, code, tests, docs).
- Research or coding yourself—always delegate.
'@

Write-TextFile -Path "$root/.roo/rules-sparc-orchestrator/boomerang-templates.md" -Content @'
# Boomerang Subtask Templates

## Specification
{
  "tool": "new_task",
  "args": {
    "mode": "sparc-specification-writer",
    "objective": "Produce specification.md + acceptance-criteria.md for <feature>",
    "acceptance_criteria": ["spec.ready","interfaces.defined","Handoff: HANDOFF/V1 with artifacts"],
    "handoff_contract": "HANDOFF/V1"
  }
}

## Architecture
{
  "tool": "new_task",
  "args": {
    "mode": "sparc-architect",
    "objective": "Create architecture.md with components, interfaces, data flow, observability",
    "inputs": ["specification.md","acceptance-criteria.md"],
    "acceptance_criteria": ["interfaces.defined","risks.known","Handoff: HANDOFF/V1"]
  }
}

## TDD-first
{
  "tool": "new_task",
  "args": {
    "mode": "sparc-tdd-engineer",
    "objective": "Write failing tests for <feature> based on pseudocode.md",
    "inputs": ["pseudocode.md","acceptance-criteria.md"],
    "acceptance_criteria": ["tests.fail.initially",">=90% coverage","Handoff: HANDOFF/V1"]
  }
}
'@

# MCP playbooks for MCP-enabled modes
Write-TextFile -Path "$root/.roo/rules-data-researcher/mcp.md" -Content @'
# MCP Playbook — Enhanced Data Researcher

When to use:
- API/library exactness → Ref (URL known) or Context7 (versioned library context)
- Open web / time-sensitive → Exa (enumerate links), then Perplexity (synthesize)
- No external data needed → skip MCP; cite local artifacts

Outputs (always):
- Claims → `project/<id>/sections/<section>/claims-<topic>.json`
- Evidence → `project/<id>/evidence/research/(ref|context7|exa|perplexity)/<topic>/*`
- Include URLs, access timestamp (UTC), confidence, rationale

## Templates

### Ref (ref-tools)
{ "tool": "ref_search_documentation", "args": { "query": "NextAuth v5 session events", "top_k": 5 },
  "expected_artifact": "project/<id>/evidence/research/ref/nextauth/session-events.md" }

{ "tool": "ref_read_url", "args": { "url": "https://next-auth.js.org/configuration/events" },
  "expected_artifact": "project/<id>/evidence/research/ref/nextauth/events.md" }

### Context7 (Upstash)
{ "tool": "context7_inject", "args": { "library": "nestjs", "version": "10.x",
  "topics": ["cache interceptor","testing module","request-scoped providers"] },
  "expected_artifact": "project/<id>/evidence/research/context7/nestjs@10.x.md" }

### Exa Search
{ "tool": "web_search_exa", "args": { "query": "PostgreSQL partitioning performance 2025",
  "freshness": "180d", "site_filters": ["postgresql.org","aws.amazon.com","neon.tech"] },
  "expected_artifact": "project/<id>/evidence/research/exa/pg-partitioning/results.json" }

### Perplexity Ask
{ "tool": "perplexity_ask", "args": { "messages": [
  { "role": "system", "content": "Cite sources with URLs; avoid speculation." },
  { "role": "user", "content": "Summarize current (≤180d) recommendations for PG range partitioning using sources: <urls from Exa>." }
]}, "expected_artifact": "project/<id>/evidence/research/perplexity/pg-partitioning.md" }

## Logging
Append each MCP call (tool, args redacted, artifact path, timestamp) to:
`project/<id>/control/mcp-usage.log.jsonl`
'@

Write-TextFile -Path "$root/.roo/rules-sparc-autonomous-adversary/mcp.md" -Content @'
# MCP Playbook — SPARC Autonomous Adversary

Use:
- Exa to enumerate real incidents and failure classes; Perplexity to synthesize mitigations
- Playwright to reproduce risky flows (evidence: screenshots/HAR)
- Ref/Context7 for exact security-relevant library details

Artifacts:
- `project/<id>/adversarial/<scenario-id>/*`
- `project/<id>/risk-assessment/<date>-<topic>.md`
- Playwright: steps.json + *.png under `project/<id>/adversarial/playwright/<scenario>/`

### Exa example
{ "tool": "web_search_exa", "args": {
  "query": "S3 presigned URL security bypass upload malware 2024..2025",
  "freshness": "365d", "site_filters": ["aws.amazon.com","portswigger.net","owasp.org"] },
  "expected_artifact": "project/<id>/evidence/research/exa/s3-presigned-bypass/results.json" }

### Perplexity example
{ "tool": "perplexity_ask", "args": { "messages": [
  { "role": "system", "content": "Cite sources; list exploit preconditions and mitigations." },
  { "role": "user", "content": "Synthesize common bypasses for S3 uploads (≤365d). Prefer: <urls from Exa>." }
]}, "expected_artifact": "project/<id>/evidence/research/perplexity/s3-presigned-bypass.md" }

### Ref example
{ "tool": "ref_read_url", "args": { "url": "https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-streaming.html" },
  "expected_artifact": "project/<id>/evidence/research/ref/aws/s3-sigv4-streaming.md" }
'@

# docs
Write-TextFile -Path "$root/docs/README.md" -Content @'
# Docs

- Contracts: JSON Schemas for orchestration and planning
- MCP config: how to provide API keys for optional servers (Ref, Context7, Exa, Perplexity)
'@

# contracts (schemas)
Write-TextFile -Path "$root/docs/contracts/handoff_v1.schema.json" -Content @'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "HANDOFF/V1",
  "type": "object",
  "required": ["schema","handoff_id","parent_id","from","to","objective","inputs","acceptance_criteria","artifacts","dependencies","ttl","next"],
  "properties": {
    "schema": { "const": "HANDOFF/V1" },
    "handoff_id": { "type": "string" },
    "parent_id": { "type": ["string","null"] },
    "from": {
      "type": "object",
      "required": ["mode","timestamp"],
      "properties": {
        "mode": { "type": "string" },
        "agent": { "type": ["string","null"] },
        "timestamp": { "type": "string", "format": "date-time" }
      }
    },
    "to": {
      "type": "object",
      "required": ["mode"],
      "properties": {
        "mode": { "type": "string" },
        "agent": { "type": ["string","null"] },
        "timestamp": { "type": ["string","null"], "format": "date-time" }
      }
    },
    "objective": { "type": "string" },
    "inputs": { "type": "array", "items": { "type": "string" } },
    "acceptance_criteria": { "type": "array", "items": { "type": "string" } },
    "artifacts": { "type": "array", "items": { "type": "string" } },
    "dependencies": { "type": "array", "items": { "type": "string" } },
    "ttl": { "type": "string" },
    "next": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["target_mode","intent"],
        "properties": {
          "target_mode": { "type": "string" },
          "intent": { "type": "string" }
        }
      }
    },
    "notes": { "type": "string" },
    "risk_flags": { "type": "array", "items": { "type": "string" } },
    "status": { "type": "string", "enum": ["open","accepted","rejected","completed"] },
    "checksums": { "type": "object", "additionalProperties": { "type": "string" } },
    "links": { "type": "array", "items": { "type": "string", "format": "uri" } }
  },
  "additionalProperties": false
}
'@

Write-TextFile -Path "$root/docs/contracts/state_v1.schema.json" -Content @'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "SPARC Orchestration State",
  "type": "object",
  "required": ["schema", "project_id", "updated_at", "nodes"],
  "properties": {
    "schema": { "const": "STATE/V1" },
    "version": { "type": "string", "default": "1.0.0" },
    "project_id": { "type": "string", "minLength": 1 },
    "updated_at": { "type": "string", "format": "date-time" },
    "current": { "type": ["string", "null"] },
    "nodes": {
      "type": "object",
      "patternProperties": {
        "^[a-z0-9_-]+$": {
          "type": "object",
          "required": ["mode", "status"],
          "properties": {
            "mode": { "type": "string" },
            "status": { "type": "string", "enum": ["pending","ready","running","blocked","done","failed","skipped"] },
            "handoff_id": { "type": ["string","null"] },
            "artifacts": { "type": "array", "items": { "type": "string" }, "default": [] },
            "depends_on": { "type": "array", "items": { "type": "string" }, "default": [] },
            "attempts": { "type": "integer", "minimum": 0, "default": 0 },
            "started_at": { "type": "string", "format": "date-time" },
            "finished_at": { "type": "string", "format": "date-time" },
            "notes": { "type": "string" }
          },
          "additionalProperties": false
        }
      },
      "additionalProperties": false
    },
    "active": { "type": "array", "items": { "type": "string" } },
    "completed": { "type": "array", "items": { "type": "string" } },
    "failed": { "type": "array", "items": { "type": "string" } }
  },
  "additionalProperties": false
}
'@

Write-TextFile -Path "$root/docs/contracts/backlog_v1.schema.json" -Content @'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Backlog",
  "type": "object",
  "required": ["epics"],
  "properties": {
    "epics": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id","name","stories"],
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "stories": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["id","title"],
              "properties": {
                "id": { "type": "string" },
                "title": { "type": "string" },
                "priority": { "type": "string", "enum": ["Low","Medium","High","Critical"] },
                "acceptance": { "type": "array", "items": { "type": "string" } }
              }
            }
          }
        }
      }
    }
  },
  "additionalProperties": false
}
'@

Write-TextFile -Path "$root/docs/contracts/sprint_v1.schema.json" -Content @'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Sprint",
  "type": "object",
  "required": ["sprint","dates","stories","policy"],
  "properties": {
    "sprint": { "type": "integer", "minimum": 1 },
    "dates": {
      "type": "object",
      "required": ["start","end"],
      "properties": {
        "start": { "type": "string" },
        "end": { "type": "string" }
      }
    },
    "stories": { "type": "array", "items": { "type": "string" } },
    "policy": {
      "type": "object",
      "required": ["dor","dod"],
      "properties": {
        "dor": { "type": "array", "items": { "type": "string" } },
        "dod": { "type": "array", "items": { "type": "string" } }
      }
    }
  },
  "additionalProperties": false
}
'@

# MCP config doc
Write-TextFile -Path "$root/docs/mcp/config.sample.md" -Content @'
# MCP Config (sample)

Set these environment variables before using MCP-enabled modes:

- `REF_API_KEY`        # Ref (ref-tools)
- `CONTEXT7_API_KEY`   # Context7 (Upstash)
- `EXA_API_KEY`        # Exa MCP
- `SONAR_API_KEY`      # Perplexity (Sonar)

Playwright MCP:
- Ensure Node 18+ and a runnable browser environment
- Maintain an allowlist in `project/<id>/control/playwright-origins.json`
'@

# memory-bank files
Write-TextFile -Path "$root/memory-bank/productContext.md" -Content @'
# Product Context (seed)
## Vision
Describe what success looks like and the high-level product narrative.

## Goals / Success Criteria
- Quantitative goals (e.g., activation rate, revenue)
- Qualitative goals (e.g., user delight, support load)

## Stakeholders & Personas
- Primary persona(s) and their needs

## Scope Boundaries / Out of Scope

## Constraints (time, budget, tech)

## Non-functional Targets (performance, availability, security, cost)
'@

Write-TextFile -Path "$root/memory-bank/decisionLog.md" -Content @'
# Decision Log
- 2025-08-24: Project initialized. Default tech choices TBD.
'@

Write-TextFile -Path "$root/memory-bank/systemPatterns.md" -Content @'
# System Patterns
- Testing: TDD pyramid; fast unit tests; contract tests for APIs.
- Security: centralized authN/Z; secretless local dev; input validation everywhere.
- Observability: logs, metrics, traces by default; SLOs per service.
'@

Write-TextFile -Path "$root/memory-bank/progress.md" -Content @'
# Progress
- 2025-08-24: Project initialized. Orchestrator ready. Graph loaded.
'@

# control plane files (use $ProjectId dynamically for paths where necessary)
Write-TextFile -Path "$root/project/$ProjectId/control/graph.yaml" -Content @"
version: 1
project_id: $ProjectId
handoff_contract: HANDOFF/V1
orchestrator: sparc-orchestrator

nodes:
  spec:           { mode: sparc-specification-writer,  desc: "Write specification.md + acceptance-criteria.md" }
  research:       { mode: data-researcher,             desc: "Collect decision-grade sources & claims" }
  factcheck:      { mode: rapid-fact-checker,          desc: "Verify claims (≥95% for autonomy-critical)" }
  arch:           { mode: sparc-architect,             desc: "Architecture.md, components & interfaces" }
  sec-arch:       { mode: sparc-security-architect,    desc: "Threat-model.md, security-architecture.md" }
  pseudo:         { mode: sparc-pseudocode-designer,   desc: "pseudocode.md, function specs" }
  tdd:            { mode: sparc-tdd-engineer,          desc: "Failing tests → coverage targets" }
  impl:           { mode: sparc-code-implementer,      desc: "Code implementation per pseudo + tests" }
  qa:             { mode: sparc-qa-analyst,            desc: "QA plan, acceptance-test-results.md" }
  adversary:      { mode: sparc-autonomous-adversary,  desc: "Adversarial/risk assessment + evidence" }
  reviewer:       { mode: security-reviewer,           desc: "Security audit reports + SARIF" }
  integrate:      { mode: sparc-integrator,            desc: "Integration-report.md, delivery checks" }
  platform:       { mode: sparc-platform-engineer,     desc: "IaC/CI/CD/observability configs" }
  sre:            { mode: sparc-sre-engineer,          desc: "SLI/SLOs, alerts, runbooks" }
  ux:             { mode: sparc-ux-architect,          desc: "UX strategy, journeys, wireframes" }

edges:
  - { from: spec,       to: research }
  - { from: research,   to: factcheck }
  - { from: factcheck,  to: arch }
  - { from: arch,       to: sec-arch }
  - { from: sec-arch,   to: pseudo }
  - { from: pseudo,     to: tdd }
  - { from: tdd,        to: impl }
  - { from: impl,       to: qa }
  - { from: qa,         to: adversary }
  - { from: adversary,  to: reviewer }
  - { from: reviewer,   to: integrate }
  - { from: integrate,  to: platform }
  - { from: platform,   to: sre }
"@

Write-TextFile -Path "$root/project/$ProjectId/control/state.json" -Content @'
{
  "schema": "STATE/V1",
  "version": "1.0.0",
  "project_id": "sample-app",
  "updated_at": "2025-08-24T15:42:00Z",
  "current": "spec",
  "nodes": {
    "spec":     { "mode": "sparc-specification-writer", "status": "ready" },
    "research": { "mode": "data-researcher",            "status": "pending" },
    "factcheck":{ "mode": "rapid-fact-checker",         "status": "pending" }
  },
  "active": [],
  "completed": [],
  "failed": []
}
'@

Write-TextFile -Path "$root/project/$ProjectId/control/backlog.yaml" -Content @'
epics:
  - id: E-100
    name: Onboarding
    stories:
      - id: US-101
        title: As a user, I can sign up with email
        priority: High
        acceptance: ["email verification", "rate-limited", "audit log"]
'@

Write-TextFile -Path "$root/project/$ProjectId/control/sprint.yaml" -Content @'
sprint: 1
dates: { start: 2025-08-25, end: 2025-09-05 }
stories: ["US-101"]
policy:
  dor: ["spec.ready","risks.known"]
  dod: ["tests.green","security.ok","docs.updated","pipelines.pass","slo.targets.present"]
'@

Write-TextFile -Path "$root/project/$ProjectId/control/playwright-origins.json" -Content @'
{ "allow": ["https://example.com", "https://stripe.com"], "block": ["*://*/*login*"] }
'@

Write-TextFile -Path "$root/project/$ProjectId/control/mcp-usage.log.jsonl" -Content @'
# One JSON per line; example:
{"ts":"2025-08-24T16:00:00Z","tool":"web_search_exa","topic":"stripe-webhooks","artifact":"project/sample-app/evidence/research/exa/stripe-webhooks/results.json"}
'@

# keep handoffs dir in git
Write-TextFile -Path "$root/project/$ProjectId/control/handoffs/.gitkeep" -Content ""

# CI workflow, script, gitignore
Write-TextFile -Path "$root/.github/workflows/ci.yml" -Content @'
name: Validate Contracts
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm i -g ajv-cli yaml-js
      - name: Validate state.json
        run: ajv validate -s docs/contracts/state_v1.schema.json -d project/sample-app/control/state.json
      - name: Validate backlog.yaml
        run: |
          node -e "console.log(JSON.stringify(require('yaml-js').load(require('fs').readFileSync('project/sample-app/control/backlog.yaml','utf8'))))" > /tmp/backlog.json
          ajv validate -s docs/contracts/backlog_v1.schema.json -d /tmp/backlog.json
      - name: Validate sprint.yaml
        run: |
          node -e "console.log(JSON.stringify(require('yaml-js').load(require('fs').readFileSync('project/sample-app/control/sprint.yaml','utf8'))))" > /tmp/sprint.json
          ajv validate -s docs/contracts/sprint_v1.schema.json -d /tmp/sprint.json
'@

Write-TextFile -Path "$root/scripts/validate.sh" -Content @'
#!/usr/bin/env bash
set -euo pipefail
if ! command -v ajv >/dev/null 2>&1; then
  echo "Installing ajv-cli and yaml-js locally..."
  npm i -g ajv-cli yaml-js
fi
ajv validate -s docs/contracts/state_v1.schema.json -d project/sample-app/control/state.json
node -e "console.log(JSON.stringify(require('yaml-js').load(require('fs').readFileSync('project/sample-app/control/backlog.yaml','utf8'))))" > /tmp/backlog.json
ajv validate -s docs/contracts/backlog_v1.schema.json -d /tmp/backlog.json
node -e "console.log(JSON.stringify(require('yaml-js').load(require('fs').readFileSync('project/sample-app/control/sprint.yaml','utf8'))))" > /tmp/sprint.json
ajv validate -s docs/contracts/sprint_v1.schema.json -d /tmp/sprint.json
echo "All good ✅"
'@

Write-TextFile -Path "$root/.gitignore" -Content @'
# node / tooling
node_modules/
*.log
# local bits
.env
.DS_Store
project/*/control/handoffs/*.handoff.json
project/*/control/mcp-usage.log.jsonl
'@

# --- zip it with Compress-Archive ---
$zipPath = Join-Path (Split-Path $root -Parent) ("$ProjectName.zip")
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path (Join-Path $root '*') -DestinationPath $zipPath -Force

Write-Host ""
Write-Host "Created project at: $root" -ForegroundColor Green
Write-Host "ZIP archive at:     $zipPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1) Open '$ProjectName' in VS Code."
Write-Host "  2) In Roo Code, ensure .roomodes is active; enable auto-approve switches/subtasks."
Write-Host "  3) (Optional) Set MCP API keys from docs/mcp/config.sample.md."
Write-Host "  4) Start in 'SPARC Orchestrator' and run Boomerang flows." -ForegroundColor Cyan
