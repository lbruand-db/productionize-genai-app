# SPEC — Productionizing a GenAI Report App

## Meeting Context

- **Audience:** Customer tech team (engineers, architects, data platform owners)
- **Duration:** 20 minutes + Q&A
- **Goal:** Align on the production-readiness path for an existing POC report app — what we add, why we add it, and what the customer's team owns.
- **Outcome:** Customer leaves with a clear checklist of production concerns and Databricks-native solutions for each.
- **Tone:** Technical, concrete, pragmatic. Show concepts and patterns, not finished code.

## Reference Material

Patterns drawn from a prior production engagement (a 374-report weekly retail analytics app: FastAPI + React Databricks App, Unity Catalog Volumes, Genie Space proxy, MLflow eval pipeline, two-tier cache). The deck is **generic** — no customer names, no business-specific KPIs.

## Time Budget (20 min)

| # | Slide / Section | Min | Cumulative |
|---|---|---|---|
| 1 | Title + Agenda | 1 | 1 |
| 2 | Context: POC → Production gap | 1.5 | 2.5 |
| 3 | Evaluation set | 2.5 | 5 |
| 4 | Logging user interactions (Lakebase) | 2.5 | 7.5 |
| 5 | Cost tracking | 2.5 | 10 |
| 6 | End-user authentication (OBO) | 2.5 | 12.5 |
| 7 | End-user access (Entra + Databricks AIM) | 2 | 14.5 |
| 8 | Sizing / pricing | 2 | 16.5 |
| 9 | Caching | 2 | 18.5 |
| 10 | Recap + next steps | 1.5 | 20 |

7 topics × ~2.5 min average. Each topic slide follows the same shape: **Problem → Databricks pattern → What the customer owns**.

## Slide-by-slide

### Slide 1 — Title

- Title: *Productionizing a GenAI Report App*
- Subtitle: *From POC to a platform your team owns*
- Author / date / commit id (via `compile.sh`)
- Use `title-slide`

### Slide 2 — Agenda

- Use `content-slide` with a numbered list, time per item
- Items match the 7 topic slides + recap

### Slide 3 — Context: POC → Production gap

- Use `box-slide` with 4 boxes — what's in the POC vs. what's missing
- POC has: reports, app UI, AI insights
- Missing: evaluation discipline, observability, cost visibility, end-user identity, caching, sizing budget, access workflow
- One-liner framing: *"The hard part isn't building it once — it's running it reliably for many users, every week."*

### Slide 4 — Evaluation set

- Use `subtitle-content-slide`
- Subtitle: *"How do we know the next prompt version is better?"*
- Content: small `dbrx-table` of scorers
  - 2 deterministic (structure, action item count)
  - 3 LLM-as-judge (relevance, actionability, factual grounding)
- Mention: MLflow Prompt Registry for versioning, MLflow Experiments for scoring runs, Review App for human labeling, eval CLI runs on every prompt change
- Speaker note: deterministic scorers gate fast; judge scorers catch quality drift

### Slide 5 — Logging user interactions (Lakebase)

- Use `subtitle-content-slide`
- Subtitle: *"Every click and every AI call, queryable in SQL"*
- Content split:
  - **What** — request/response, prompt id, user id (from OBO), tokens in/out, latency, thumbs feedback
  - **Where** — Lakebase Postgres (low-latency writes from the app) → **Lakehouse Sync** to UC managed Delta (SCD Type 2) for analytics
  - **Why Lakebase** — sub-10ms query latency, native Postgres ACID, no warehouse hop on the hot path
- Speaker note: contrast with writing straight to Delta (works but high write latency, no per-request isolation). Lakehouse Sync is the Databricks-native path — no Debezium / Kafka pipeline to operate.

### Slide 6 — Cost tracking

- Use `two-column-slide`
- Left: *Per-user / per-feature attribution*
  - MLflow traces capture token counts per call
  - Tag traces with user id, route, prompt version
  - Aggregate in a UC table for chargeback
- Right: *Platform cost visibility*
  - `system.billing.usage` for DBU consumption
  - Per-warehouse, per-app, per-job rollup
  - Alert thresholds via Databricks SQL alerts
- Speaker note: tokens cost is on FMAPI line item; surface it weekly so it doesn't surprise the business

### Slide 7 — End-user OBO authentication

- Use `content-slide` with a `dbrx-mermaid` flow + `dbrx-ribbon(label: "PUBLIC PREVIEW")`
- Mermaid: `User → Entra SSO → Databricks App → x-forwarded-access-token → Genie / SQL / Volumes`
- Key points:
  - App runs as a service principal **only** for static assets and shared cache
  - Every data query uses the user's forwarded token (Genie space, SQL warehouse, UC Volumes / Files)
  - App declares **scopes** (`sql`, `dashboards.genie`, `files.files`) at deploy time
  - Row-level / column-level security in UC applies *naturally* — no app-level ACL code
- Speaker note: this is the difference between "the app can see everything" and "the app can only see what the user can see". OBO is currently Public Preview — flag the maturity, GA path is on the roadmap.

### Slide 8 — End-user access (Entra + Databricks AIM)

- Use `two-column-slide`
- Left: *Already in place*
  - Entra ID (Microsoft) for SSO
  - **Databricks AIM** (Automatic Identity Management) — syncs Entra users, groups, **nested groups**, service principals into Databricks. No SCIM app, no admin role required.
- Right: *What that gives the app*
  - Entra groups directly grant UC + Apps permissions (account-level assets)
  - Group memberships refresh on browser login (5 min) / token auth (40 min)
  - JIT user provisioning on first login — no pre-provisioning needed
- Speaker note: the customer's identity story is essentially **already production-grade**. Slide is a confirmation, not new work. AIM is the recommended path over SCIM (which is still supported as a fallback).

### Slide 9 — Sizing / pricing

- Use `content-slide` with a `dbrx-table` of SKUs
  - **Databricks Apps compute** — Medium (2 vCPU / 6 GB / 0.5 DBU/h) default, Large (4 vCPU / 12 GB / 1 DBU/h) for high-concurrency
  - **Foundation Model API** — pay-per-token (DBU-per-1M-tokens) for variable load; Provisioned Throughput for guaranteed capacity
  - **SQL warehouse** — Serverless, on-demand for app queries
  - **Lakebase** — Capacity Units for logging hot path
  - **Storage** — UC Volumes for reports + cache (negligible)
- Show a *concrete weekly envelope* example: e.g., "N users × M reports × K tokens = $X / week"
- Reference Quicksizer / Lakemeter offer to refine

### Slide 10 — Caching

- Use `content-slide` with a `dbrx-mermaid`
- Mermaid: `Request → L1 in-memory (LRU) → L2 UC Volume → Foundation Model API`
- Bullets:
  - L1: per-worker in-memory LRU, no network hop, no cost
  - L2: UC Volume — persistent across restarts, shared across workers
  - Cache key: report id + prompt version (invalidates automatically on prompt bump)
- Speaker note: Control AI cost; caching is non-optional at this scale

### Slide 11 — Recap & next steps

- Use `takeaway-slide` or numbered `content-slide`
- 3 takeaways:
  1. Production = eval + observability + identity + cost + cache — all native to Databricks
  2. Customer team keeps owning identity, data access, prompt curation
  3. Databricks owns the platform plumbing (Apps, FMAPI, UC, MLflow, Lakebase)
- Next step: agree on a sizing exercise + a 2-week production hardening sprint

### Slide 12 — Q&A / Thank you

- Use `freeform-slide` with author contact info
- End with `blank-dark-slide`

## Visual conventions

- One secondary color per slide (teal OR amber, not both)
- All titles `dbrx-dark-navy`, body `dbrx-charcoal`
- Mermaid diagrams use `dbrxNavy` for the user/entry, `dbrxTeal` for Databricks-managed, `dbrxAmber` for customer-owned
- Tables: `dbrx-table` with 14–16pt body text

## What to keep out

- No customer name, no industry-specific KPIs from the reference engagement
- No code blocks longer than 3 lines (this is a speaking deck, not a tutorial)
- No "ROADMAP" pills. Exception: OBO is Public Preview today — flag explicitly on slide 7, don't hide it.
- No deep dives into MLflow internals; mention by name, move on

## Build

```bash
./compile.sh productionize-deck.typ   # → productionize-deck.pdf
```

Deck file will live at repo root as `productionize-deck.typ` (import `dbrx.typ`).

## Verified against Databricks docs (2026-05-26)

| Claim | Status | Source |
|---|---|---|
| MLflow Prompt Registry, aliases, LLM-as-judge scorers | ✅ GA | `docs.databricks.com/aws/en/mlflow3/genai/prompt-version-mgmt/prompt-registry/` |
| MLflow traces capture token usage (`llm.token_usage.*`) | ✅ GA | `mlflow.org/docs/latest/genai/tracing/token-usage-cost/` |
| `system.billing.usage` with SKU + custom_tags | ✅ GA | `docs.databricks.com/aws/en/admin/system-tables/billing` |
| Lakebase Postgres, sub-10ms latency | ✅ GA | `databricks.com/blog/reverse-etl-lakebase-activate-your-lakehouse-data-operational-analytics` |
| Lakehouse Sync (Postgres → UC Delta as SCD2) | ✅ GA | `docs.databricks.com/aws/en/oltp/projects/lakehouse-sync` |
| OBO via `x-forwarded-access-token` header | ⚠️ Public Preview, opt-in, scopes required | `docs.databricks.com/aws/en/dev-tools/databricks-apps/auth` |
| Databricks AIM (Automatic Identity Management) | ✅ GA, default for accounts created after 2025-08-01 | `learn.microsoft.com/en-us/azure/databricks/admin/users-groups/automatic-identity-management/` |
| Databricks Apps sizes: Medium (0.5 DBU/h), Large (1 DBU/h) | ✅ GA — note: no "Small" tier exists | `docs.databricks.com/aws/en/dev-tools/databricks-apps/compute-size` |
| FMAPI pay-per-token + Provisioned Throughput | ✅ GA | `databricks.com/product/pricing/foundation-model-serving` |

## Open questions for the user

- Should the recap propose a concrete *next-meeting* date (e.g., the sizing review), or leave it as "to be scheduled"?
 leave it as to be secheduled
- Is FMAPI the assumed model gateway, or does the customer want options (Azure OpenAI via External Models, BYO endpoint)?
 no other options
- Is Lakebase already provisioned in their workspace, or is this a new ask to budget for?
 I don't know leave this out
