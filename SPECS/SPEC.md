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
| 7 | End-user access (Entra + AIM) | 2 | 14.5 |
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
- One-liner framing: *"The hard part isn't building it once — it's running it for many users on Monday morning."*

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
  - **Where** — Lakebase Postgres (low-latency writes from the app) → CDC to UC for analytics
  - **Why Lakebase** — sub-10ms writes, transactional consistency, no warehouse hop on the hot path
- Speaker note: contrast with writing straight to Delta (works but high write latency, no per-request isolation)

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

- Use `content-slide` with a `dbrx-mermaid` flow
- Mermaid: `User → Entra SSO → Databricks App → X-Forwarded-Access-Token → Genie / SQL / Volumes`
- Key points:
  - App runs as a service principal **only** for static assets and shared cache
  - Every data query uses the user's forwarded token (Genie space, SQL warehouse, UC Volumes)
  - Row-level / column-level security in UC applies *naturally* — no app-level ACL code
- Speaker note: this is the difference between "the app can see everything" and "the app can only see what the user can see"

### Slide 8 — End-user access (Entra + AIM)

- Use `two-column-slide`
- Left: *Already in place at customer*
  - Entra (Azure AD) for SSO
  - AIM (customer's identity provisioning) for group sync
- Right: *What we wire into the app*
  - Databricks Apps consume the SCIM-provisioned identity
  - UC permissions managed via Entra groups → Databricks groups
  - No new IdP, no new directory — reuse existing identity flow
- Speaker note: customer keeps owning identity; Databricks consumes it

### Slide 9 — Sizing / pricing

- Use `content-slide` with a `dbrx-table` of SKUs
  - Databricks Apps compute (small / medium)
  - Foundation Model API tokens (per prompt × users × frequency)
  - SQL warehouse (serverless, on-demand for app queries)
  - Lakebase (compute units for logging hot path)
  - Storage (UC Volumes for reports + cache)
- Show a *concrete weekly envelope* example: e.g., "N users × M reports × K tokens = $X / week"
- Reference Quicksizer / Lakemeter offer to refine

### Slide 10 — Caching

- Use `content-slide` with a `dbrx-mermaid`
- Mermaid: `Request → L1 in-memory (LRU) → L2 UC Volume → Foundation Model API`
- Bullets:
  - L1: per-worker in-memory LRU, no network hop, no cost
  - L2: UC Volume — persistent across restarts, shared across workers
  - Cache key: report id + prompt version (invalidates automatically on prompt bump)
- Speaker note: AI cost on a 300+ report deck collapses by ~95% after the first generation; caching is non-optional at this scale

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
- No "ROADMAP" pills — every pattern shown is GA today
- No deep dives into MLflow internals; mention by name, move on

## Build

```bash
./compile.sh productionize-deck.typ   # → productionize-deck.pdf
```

Deck file will live at repo root as `productionize-deck.typ` (import `dbrx.typ`).

## Open questions for the user

- Should the recap propose a concrete *next-meeting* date (e.g., the sizing review), or leave it as "to be scheduled"?
- Is FMAPI the assumed model gateway, or does the customer want options (Azure OpenAI via External Models, BYO endpoint)?
- Is Lakebase already provisioned in their workspace, or is this a new ask to budget for?
