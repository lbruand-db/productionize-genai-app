// ==========================================================================
// Productionizing a GenAI Report App
// 20-min customer-facing deck — eval, logging, cost, OBO, AIM, sizing, cache
// ==========================================================================

#import "dbrx.typ": *

#show: dbrx-presentation.with(
  title: "Productionizing a GenAI Report App",
  author: "Lucas Bruand, Paolo Picello, Paolo Ferri",
  subject: "POC → Production hardening session",
)

// --- Title / Cover ---
#title-slide(
  title: [Productionizing a GenAI Report App],
  subtitle: [From POC to a platform your team owns],
  author: [Lucas Bruand, Paolo Picello, Paolo Ferri — Databricks Solution Architects],
  date: [May 2026],
)

// --- Agenda ---
#content-slide(title: [Agenda])[
  + Context — POC vs. Production
  + Evaluation set
  + Logging user interactions
  + Cost tracking
  + End-user authentication (OBO)
  + End-user access (Entra + AIM)
  + Sizing & pricing
  + Caching
  + Recap & next steps
]

// =========================================================================
// SLIDE 3 — Context: POC → Production gap
// =========================================================================
#box-slide(
  title: [POC → Production gap],
  boxes: (
    (label: [What you already have], body: [
      Reports generated \
      App UI in place \
      LLM-driven AI insights \
      Initial users onboarded
    ]),
    (label: [What production demands], body: [
      Eval discipline \
      Per-user observability \
      Cost visibility \
      Identity & access at scale
    ]),
    (label: [What we add today], body: [
      MLflow eval pipeline \
      Lakebase interaction log \
      System tables + tracing \
      OBO + AIM wiring
    ]),
    (label: [What stays the same], body: [
      Your data \
      Your prompts \
      Your business logic \
      Your team owns it
    ]),
  ),
  box-color: dbrx-teal,
)

// =========================================================================
// SLIDE 4 — Evaluation set
// =========================================================================
#subtitle-content-slide(
  title: [Evaluation set],
  subtitle: [How do we know the next prompt version is better?],
)[
  #set text(size: 18pt)
  #dbrx-table(
    columns: (1.6fr, 1fr, 3fr),
    header: ([Scorer], [Type], [What it measures]),
    [`structure_compliance`], [Deterministic], [Required sections present (0.0–1.0)],
    [`action_item_count`], [Deterministic], [Concrete action items per section],
    [`analysis_relevance`], [LLM-as-judge], [Does the analysis address actual KPIs? (1–5)],
    [`actionability`], [LLM-as-judge], [Are recommendations concrete and feasible? (1–5)],
    [`factual_grounding`], [LLM-as-judge], [Does the analysis stay faithful to data? (1–5)],
  )

  #v(0.4cm)
  #set text(size: 18pt, fill: dbrx-charcoal)
  Versioning: *MLflow Prompt Registry* (Git-like, aliases for `prod` / `staging`) \
  Human-in-the-loop: *Databricks Review App* for labeling — eval CLI runs on every prompt change
]

// =========================================================================
// SLIDE 5 — Logging user interactions (Lakebase)
// =========================================================================
#subtitle-content-slide(
  title: [Logging user interactions],
  subtitle: [Every click and every AI call, queryable in SQL],
)[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 0.5cm,
    [
      #set text(size: 18pt, fill: dbrx-charcoal)
      *What we log* — request id, prompt id + version, user id (from OBO), tokens in / out, latency, route, thumbs feedback

      #v(0.3cm)
      *Hot path* — write to *Lakebase Postgres*: sub-10ms query latency, native ACID, no warehouse spin-up on every request

      #v(0.3cm)
      *Cold path* — *Lakehouse Sync* replicates Postgres → UC managed Delta as SCD Type 2 — full history, no Debezium / Kafka to operate
    ],
    [
      #image("assets/doc-lakebase-cdf.png", width: 100%)
      #set text(size: 11pt, fill: dbrx-blue-gray, style: "italic")
      #v(-0.2cm)
      Source: Databricks docs — Lakehouse Sync (wal2delta)
    ],
  )
]

// =========================================================================
// SLIDE 6 — Cost tracking
// =========================================================================
#two-column-slide(
  title: [Cost tracking],
  left-heading: [Per-user / per-feature attribution],
  right-heading: [Platform cost visibility],
)[
  #set text(size: 18pt, fill: dbrx-charcoal)
  - *MLflow Tracing* captures token counts per call (`llm.token_usage.input_tokens` / `output_tokens`)
  - Tag traces with user id, route, prompt version
  - Aggregate in a UC table for chargeback
  - Surface in a weekly Lakeview dashboard
][
  #set text(size: 16pt, fill: dbrx-charcoal)
  - `system.billing.usage` for DBU by SKU, workspace, custom tags
  - Alert thresholds via Databricks SQL alerts
  #v(0.2cm)
  #image("assets/doc-usage-dashboard.png", width: 95%)
  #set text(size: 10pt, fill: dbrx-blue-gray, style: "italic")
  Source: Databricks docs — Usage dashboard
]

// =========================================================================
// SLIDE 7 — End-user OBO authentication (Public Preview)
// =========================================================================
#content-slide(title: [End-user authentication — OBO])[
  #dbrx-ribbon(label: "PUBLIC PREVIEW", color: dbrx-amber, text-color: dbrx-dark-navy)

  #grid(
    columns: (1.2fr, 1fr),
    column-gutter: 0.5cm,
    [
      #set align(center)
      #dbrx-mermaid("graph LR\nA[User] --> B[Entra SSO]\nB --> C[Databricks App]\nC --> T[x-forwarded-access-token]\nT --> D[Genie]\nT --> E[SQL Warehouse]\nT --> F[UC Volumes]\nclass A dbrxNavy\nclass B,C dbrxTeal\nclass T dbrxAmber\nclass D,E,F dbrxGreen")

      #set align(left)
      #set text(size: 15pt, fill: dbrx-charcoal)
      #v(0.2cm)
      - App SP only for static assets + shared cache
      - Every data call uses *user's* forwarded token — UC row/column security applies naturally
      - App declares scopes at deploy: `sql`, `dashboards.genie`, `files.files`
    ],
    [
      #image("assets/doc-add-scopes.png", width: 100%)
      #set text(size: 10pt, fill: dbrx-blue-gray, style: "italic")
      Source: Databricks docs — Add scopes to a Databricks App
    ],
  )
]

// =========================================================================
// SLIDE 8 — End-user access (Entra + Databricks AIM)
// =========================================================================
#two-column-slide(
  title: [End-user access — Entra + Databricks AIM],
  left-heading: [Already in place],
  right-heading: [What that gives the app],
)[
  #set text(size: 18pt, fill: dbrx-charcoal)
  - *Entra ID* for SSO
  - *Databricks AIM* — Automatic Identity Management
  - Syncs users, groups, *nested groups*, service principals from Entra
  - No SCIM app, no Cloud Application Administrator role required
  - Default for accounts created after Aug 2025

  #v(0.3cm)
  #image("assets/doc-enable-aim.png", width: 80%)
][
  #set text(size: 18pt, fill: dbrx-charcoal)
  - Entra groups directly grant UC + Apps permissions (account-level assets)
  - Group memberships refresh: 5 min (browser login) / 40 min (token auth)
  - JIT user provisioning — no pre-provisioning of new joiners
  - Audit log entries tagged `endpoint: "autoUserCreation"`
]

// =========================================================================
// SLIDE 9 — Sizing & pricing
// =========================================================================
#content-slide(title: [Sizing & pricing])[
  #set text(size: 16pt)
  #dbrx-table(
    columns: (1.6fr, 2.5fr, 2fr),
    header: ([SKU], [Configuration], [Cost driver]),
    [Databricks Apps — Medium], [2 vCPU / 6 GB], [0.5 DBU/h (default)],
    [Databricks Apps — Large], [4 vCPU / 12 GB], [1 DBU/h (high concurrency)],
    [Foundation Model API], [Pay-per-token (default) or Provisioned Throughput], [DBU per 1M tokens],
    [SQL Warehouse (serverless)], [On-demand for app + analytics queries], [DBU/h while running],
    [Lakebase], [Capacity Units, autoscaling], [CU/h],
    [UC Volumes], [Reports + AI response cache], [Storage GB/month (negligible)],
  )

  #v(0.4cm)
  #set text(size: 18pt, fill: dbrx-charcoal)
  *Weekly envelope* = N users × M reports/user × K tokens/report × DBU/1M × \$ /DBU \
  Refine with *Quicksizer* + *Lakemeter* in a dedicated session
]

// =========================================================================
// SLIDE 10 — Caching
// =========================================================================
#content-slide(title: [Caching — control AI cost])[
  #set align(center)
  #dbrx-mermaid("graph LR\nA[Request] --> B[L1 in-memory LRU]\nB --> C[L2 UC Volume]\nC --> D[Foundation Model API]\nD --> E[Response]\nclass A dbrxNavy\nclass B,C dbrxTeal\nclass D dbrxAmber\nclass E dbrxGreen")

  #set align(left)
  #set text(size: 18pt, fill: dbrx-charcoal)
  #v(0.3cm)
  - *L1* — per-worker LRU, no network hop, no cost
  - *L2* — UC Volume, persistent across restarts, shared across workers
  - *Cache key* — report id + prompt version → invalidates automatically when prompt bumps
  - Without this, every dashboard view re-pays the FMAPI cost. With it, hit rate climbs to ~95% after warmup.
]

// =========================================================================
// SLIDE 11 — Recap & next steps
// =========================================================================
#takeaway-slide(
  title: [Recap],
  items: (
    (
      heading: [Production is the sum of five disciplines],
      body: [Eval + observability + identity + cost + cache — every one is Databricks-native],
      color: dbrx-dark-navy,
    ),
    (
      heading: [You keep what matters],
      body: [Identity (Entra + AIM), data access (UC + OBO), prompt curation — all owned by your team],
      color: dbrx-teal,
    ),
    (
      heading: [We own the plumbing],
      body: [Databricks Apps, FMAPI, MLflow, Lakebase, UC, SQL warehouses — managed services, one platform],
      color: dbrx-dark-teal,
    ),
  ),
)

#content-slide(title: [Next steps])[
  - [ ] Confirm OBO scopes and enable on the existing app
  - [ ] Provision (or confirm) the Lakebase instance for the interaction log
  - [ ] Schedule a *sizing review* — Quicksizer + Lakemeter — date TBD
  - [ ] Agree on a 2-week production hardening sprint
  - [ ] Single point of contact on your side for the sprint
]

// =========================================================================
// Closing
// =========================================================================
#quote-slide(
  quote: [The hard part isn't building it once — it's running it reliably for many users, every week.],
  bg: "teal",
)

#freeform-slide()[
  #place(top + left, dx: margin-x, dy: margin-top,
    block(width: 31.3cm)[
      #text(size: 40pt, fill: dbrx-dark-navy)[Thank You]
      #v(1cm)
      #text(size: 24pt, fill: dbrx-teal)[Questions?]
      #v(2cm)
      #text(size: 18pt, fill: dbrx-charcoal)[
        Lucas Bruand — Specialist Solution Architect \
        Paolo Picello — Solution Architect \
        Paolo Ferri — Solution Architect \
        lucas.bruand\@databricks.com
      ]
    ]
  )
]

#blank-dark-slide()
