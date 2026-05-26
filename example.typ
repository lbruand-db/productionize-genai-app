// ==========================================================================
// Example Databricks Presentation
// ==========================================================================

#import "dbrx.typ": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#show: dbrx-presentation.with(
  title: "Quarterly Business Review",
  author: "Jane Smith",
  subject: "Data Platform Engineering",
)

// --- Title / Cover Slide ---
#title-slide(
  title: [Quarterly Business Review],
  subtitle: [Data Platform Engineering],
  author: [Jane Smith],
  date: [February 2026],
)

// --- Section Divider (Red) ---
#section-slide(title: [Agenda])

// --- Basic Content Slide ---
#content-slide(title: [Key Highlights])[
  - Revenue grew 35% year-over-year
  - Expanded to 3 new regions in EMEA
  - Launched Databricks Unity Catalog for all customers
  - Net Promoter Score increased to 72
]

// --- Title + Subtitle + Content ---
#subtitle-content-slide(
  title: [Platform Performance],
  subtitle: [Metrics from Q4 2025],
)[
  - Average query latency reduced by 42%
  - Cluster utilization improved to 89%
  - Zero unplanned downtime incidents
  - 99.99% SLA compliance achieved
]

// --- Section Divider (Dark Navy) ---
#section-slide-dark(title: [Deep Dive: Architecture], variant: 1)

// --- Two Column Slide ---
#two-column-slide(
  title: [Before vs. After Migration],
  left-heading: [Legacy Stack],
  right-heading: [Databricks Lakehouse],
)[
  - Siloed data warehouses
  - Manual ETL pipelines
  - 48-hour refresh cycles
  - Limited ML capabilities
][
  - Unified data platform
  - Automated Delta Live Tables
  - Near real-time streaming
  - Integrated MLflow
]

// --- Three Column Slide ---
#three-column-slide(
  title: [Team Structure],
  headings: ([Engineering], [Data Science], [Operations]),
)[
  - Platform team (12)
  - Backend services (8)
  - Frontend (5)
][
  - ML engineers (6)
  - Analytics (4)
  - Research (3)
][
  - SRE team (4)
  - DevOps (3)
  - Support (2)
]

// --- Box Layout (3 boxes) ---
#box-slide(
  title: [Strategic Pillars],
  boxes: (
    (label: [Performance], body: [
      - Sub-second queries
      - Auto-scaling clusters
      - Photon engine
    ]),
    (label: [Governance], body: [
      - Unity Catalog
      - Row-level security
      - Data lineage
    ]),
    (label: [Collaboration], body: [
      - Shared notebooks
      - Git integration
      - Real-time co-editing
    ]),
  ),
)

// --- Box Layout (2 boxes) ---
#box-slide(
  title: [Cost Comparison],
  boxes: (
    (label: [Current State], body: [
      Monthly spend: \$1.2M \
      Storage: 450 TB \
      Compute: 2,400 DBUs/day
    ]),
    (label: [Projected (Q2)], body: [
      Monthly spend: \$890K \
      Storage: 500 TB \
      Compute: 1,800 DBUs/day
    ]),
  ),
  box-color: dbrx-dark-teal,
)

// --- Quote Slide (Red) ---
#quote-slide(
  quote: [The Databricks Lakehouse Platform has transformed how we think about data infrastructure.],
  attribution: [-- Sarah Chen, VP of Engineering],
  bg: "red",
)

// --- Quote Slide (Dark Navy) ---
#quote-slide(
  quote: [Moving to Unity Catalog gave us the governance framework we needed to scale securely.],
  attribution: [-- Marcus Johnson, Chief Data Officer],
  bg: "dark",
)

// --- Quote Slide (Teal) ---
#quote-slide(
  quote: [Our data scientists can now go from experiment to production in hours, not weeks.],
  attribution: [-- Dr. Aisha Patel, Head of ML],
  bg: "teal",
)

// --- Headline / Tagline Slide ---
#headline-slide(
  text-content: [Databricks simplifies and accelerates your data and AI goals.],
)

// --- Image Slide ---
#image-slide(
  title: [Architecture Overview],
  img: rect(
    width: 80%,
    height: 80%,
    fill: dbrx-light-gray,
    stroke: 0.5pt + dbrx-teal,
    radius: 4pt,
  )[
    #set align(center + horizon)
    #text(fill: dbrx-teal, size: 20pt)[_Insert architecture diagram here_]
  ],
  caption: [Figure 1: Lakehouse reference architecture],
)

// --- Content Slide with Table ---
#content-slide(title: [Performance Metrics])[
  #set text(size: 14pt)
  #dbrx-table(
    columns: (1fr, 1fr, 1fr, 1fr),
    header: ([Metric], [Q3 2025], [Q4 2025], [Change]),
    [Query Latency (p50)], [1.2s], [0.7s], [#text(fill: dbrx-green)[-42%]],
    [Cluster Utilization], [71%], [89%], [#text(fill: dbrx-green)[+18pp]],
    [Pipeline Failures], [12/mo], [3/mo], [#text(fill: dbrx-green)[-75%]],
    [Data Freshness], [48h], [15min], [#text(fill: dbrx-green)[-99.5%]],
  )
]

// --- Code Snippet Slide ---
#content-slide(title: [Reading Delta Tables with PySpark])[
  #set text(size: 16pt)
  #block(
    fill: dbrx-light-gray,
    inset: 1em,
    radius: 4pt,
    width: 100%,
  )[
    ```python
    from pyspark.sql import SparkSession
    from pyspark.sql.functions import col, avg, count

    spark = SparkSession.builder.appName("analytics").getOrCreate()

    # Read from Unity Catalog
    df = spark.read.table("main.default.transactions")

    # Aggregate metrics by region
    summary = (
        df.filter(col("status") == "completed")
          .groupBy("region")
          .agg(
              count("*").alias("total_orders"),
              avg("amount").alias("avg_amount"),
          )
          .orderBy(col("total_orders").desc())
    )

    summary.write.format("delta").saveAsTable("main.default.regional_summary")
    ```
  ]
]

// --- Mermaid Diagram Slide ---
#content-slide(title: [Data Pipeline Architecture])[
  #set align(center)
  #dbrx-mermaid("graph LR\nA[Raw Data] --> B[Bronze Layer]\nB --> G{Quality Checks}\nG --> C[Silver Layer]\nG --> H[Quarantine]\nC --> D[Gold Layer]\nD --> E[Dashboard]\nD --> F[ML Models]\nclass A dbrxGray\nclass B dbrxNavy\nclass G dbrxAmber\nclass C dbrxTeal\nclass H dbrxRed\nclass D dbrxDarkTeal\nclass E,F dbrxGreen")
]

// --- Histogram with Gaussian Fit Slide ---
#content-slide(title: [Query Latency Distribution])[
  #set align(center)
  #{
    // Parameters
    let mean = 2.5
    let std = 1.2
    let n-bins = 20
    let x-min = -1.5
    let x-max = 6.5
    let bin-width = (x-max - x-min) / n-bins

    // Simple LCG pseudo-random number generator (deterministic)
    let seed = 42
    let m = 2147483647
    let a = 1103515245
    let c = 12345
    let state = seed

    // Generate ~200 samples from approx Gaussian using Box-Muller-like CLT
    let samples = ()
    for i in range(200) {
      // Sum of 12 uniform [0,1) minus 6 ≈ N(0,1)
      let sum = 0.0
      for j in range(12) {
        state = calc.rem(a * state + c, m)
        if state < 0 { state = state + m }
        sum += state / m
      }
      let z = sum - 6.0
      let x = mean + std * z
      samples.push(x)
    }

    // Bin the samples
    let counts = range(n-bins).map(_ => 0)
    for s in samples {
      let bin = int(calc.floor((s - x-min) / bin-width))
      if bin >= 0 and bin < n-bins {
        counts.at(bin) = counts.at(bin) + 1
      }
    }

    // Normalize to density (count / (n * bin-width))
    let n-samples = samples.len()
    let hist-data = range(n-bins).map(i => {
      let x = x-min + (i + 0.5) * bin-width
      let density = counts.at(i) / (n-samples * bin-width)
      (x, density)
    })

    // Gaussian PDF
    let gauss(x) = {
      let z = (x - mean) / std
      (1.0 / (std * calc.sqrt(2.0 * calc.pi))) * calc.exp(-0.5 * z * z)
    }

    canvas(length: 1cm, {
      draw.set-style(axes: (stroke: 0.5pt + dbrx-charcoal, tick: (stroke: 0.5pt)))

      plot.plot(
        size: (16, 8),
        x-label: [Latency (seconds)],
        y-label: [Density],
        x-tick-step: 1,
        y-tick-step: 0.1,
        y-min: 0,
        y-max: 0.4,
        legend: "inner-north-east",
        {
          plot.add-bar(
            hist-data,
            bar-width: bin-width * 0.9,
            style: (stroke: dbrx-teal, fill: dbrx-teal.transparentize(60%)),
            labels: ([Observed],),
          )
          plot.add(
            gauss,
            domain: (x-min, x-max),
            samples: 100,
            style: (stroke: 2pt + dbrx-red),
            label: [Gaussian fit],
          )
        },
      )
    })
  }
]

// --- PDF Embed Slide ---
#pdf-slide(
  title: [Referenced Paper],
  pdf-path: "assets/2509.21459.pdf",
  page: 0,
  caption: [Page 1 of arXiv:2509.21459],
  content-height: 13.5cm,
  pdf-dy: -1.5cm,
)

// --- Section Divider (Dark, variant 2) ---
#section-slide-dark(title: [Next Steps & Roadmap], variant: 2)

// --- Content Slide with Ribbon ---
#content-slide(title: [Upcoming Feature: Serverless Compute])[
  #dbrx-ribbon(label: "ROADMAP")
  - Automatic cluster provisioning and scaling
  - Pay only for compute you use — no idle costs
  - Sub-second startup times for interactive workloads
  - Available in preview Q2 2026
]

// --- Four Box Slide ---
#box-slide(
  title: [Q1 2026 Roadmap],
  boxes: (
    (label: [January], body: [
      Unity Catalog rollout Phase 2
    ]),
    (label: [February], body: [
      Streaming pipeline migration
    ]),
    (label: [March], body: [
      ML model serving launch
    ]),
    (label: [April], body: [
      Cost optimization sprint
    ]),
  ),
)

// --- Card Slide (3 cards with icons and pill labels) ---
#card-slide(
  title: [Why Migrate to the Lakehouse],
  cards: (
    (
      icon: "assets/dbrx-icon-speed.svg",
      heading: [Performance],
      body: [Sub-second query latency with Photon engine. Auto-scaling clusters eliminate over-provisioning.],
      label: [Up to 12x faster than legacy],
    ),
    (
      icon: "assets/dbrx-icon-ai.svg",
      heading: [Unified AI],
      body: [Train, track, and serve ML models alongside your data. Built-in MLflow and Feature Store.],
      label: [One platform for data + AI],
    ),
    (
      icon: "assets/dbrx-icon-data_warehouse.svg",
      heading: [Governance],
      body: [Unity Catalog provides fine-grained access control, lineage, and auditing across all assets.],
      label: [Enterprise-grade security],
    ),
  ),
)

// --- Card Slide (2 cards, custom colors) ---
#card-slide(
  title: [Deployment Options],
  cards: (
    (
      icon: "assets/dbrx-icon-data_warehouse.svg",
      heading: [Multi-Cloud],
      body: [Run on AWS, Azure, or GCP with a consistent experience. No vendor lock-in.],
    ),
    (
      icon: "assets/dbrx-icon-predict.svg",
      heading: [Serverless],
      body: [Zero infrastructure management. Pay only for what you use with instant startup.],
    ),
  ),
  card-color: rgb("#eef6f9"),
  card-border: rgb("#c0dae3"),
  accent-color: dbrx-dark-teal,
)

// --- Summary Slide (dark, icon-badge rows) ---
#summary-slide(
  title: [Key Takeaways],
  items: (
    (
      icon: "assets/dbrx-icon-speed.svg",
      heading: [42% faster queries],
      body: [Photon engine and optimized Delta Lake delivered sub-second latency across all workloads.],
      accent: rgb("#ff9080"),
      bg: rgb("#5c1a10"),
    ),
    (
      icon: "assets/dbrx-icon-ai.svg",
      heading: [Unified data + AI platform],
      body: [ML engineers and analysts work on the same platform — no data movement, no silos.],
      accent: dbrx-teal-light,
      bg: rgb("#122d3a"),
    ),
    (
      icon: "assets/dbrx-icon-data_warehouse.svg",
      heading: [Enterprise governance from day one],
      body: [Unity Catalog rolled out to all teams with row-level security and full lineage tracking.],
      accent: rgb("#8bb8c7"),
      bg: rgb("#1b4150"),
    ),
    (
      icon: "assets/dbrx-icon-predict.svg",
      heading: [26% cost reduction projected],
      body: [Auto-scaling and serverless compute will cut monthly spend from \$1.2M to \$890K by Q2.],
      accent: rgb("#66d9a8"),
      bg: rgb("#0a3d28"),
    ),
  ),
)

// --- Takeaway Slide (numbered color-banded rows) ---
#takeaway-slide(
  title: [5 Key Takeaways],
  items: (
    (heading: [Lakehouse eliminates data silos], body: [Unified platform for data engineering, analytics, and ML — no more copying data between systems.], color: dbrx-red),
    (heading: [Photon delivers 12x performance], body: [Native C++ engine optimized for Delta Lake. Sub-second queries on petabyte-scale datasets.], color: dbrx-dark-navy),
    (heading: [Unity Catalog provides end-to-end governance], body: [Fine-grained access control, data lineage, and auditing across all data assets and AI models.], color: dbrx-dark-teal),
    (heading: [Serverless reduces costs by 26%], body: [Auto-scaling compute with instant startup. Pay only for what you use — no idle cluster costs.], color: dbrx-teal),
    (heading: [The platform moat is the integration], body: [Standalone tools solve one problem. Databricks solves storage + compute + governance + AI together.], color: dbrx-charcoal),
  ),
)

// --- Icon Row Cards (building blocks for custom slides) ---
#content-slide(title: [Platform Capabilities])[
  #set text(size: 16pt)
  #dbrx-icon-row(
    icon: "assets/dbrx-icon-speed.svg",
    heading: [Photon Engine],
    body: [Native C++ query engine delivers up to 12x performance on Delta Lake workloads.],
  )
  #v(0.3cm)
  #dbrx-icon-row(
    icon: "assets/dbrx-icon-ai.svg",
    heading: [Mosaic AI],
    body: [Build, deploy, and govern AI models — from fine-tuning to production serving.],
    color: dbrx-dark-navy,
    heading-color: white,
    text-color: white.transparentize(15%),
  )
  #v(0.3cm)
  #dbrx-icon-row(
    icon: "assets/dbrx-icon-data_warehouse.svg",
    heading: [Unity Catalog],
    body: [Unified governance for all data and AI assets across clouds.],
    color: dbrx-dark-teal,
    heading-color: white,
    text-color: white.transparentize(15%),
  )
]

// --- Board / Kanban Slide ---
#board-slide(
  title: [Feature Maturity],
  columns: (
    (heading: [GA], color: dbrx-green, items: (
      [Delta Live Tables],
      [Unity Catalog],
      [Photon Engine],
      [MLflow Integration],
    )),
    (heading: [Public Preview], color: dbrx-amber, items: (
      [AI Gateway v2],
      [Lakebase],
      [Serverless Compute],
      [Agent Framework],
      [Genie Spaces],
    )),
    (heading: [Private Preview], color: dbrx-teal, items: (
      [Multi-modal pipelines],
      [Federated queries],
      [Real-time ML serving],
    )),
  ),
)

// --- Ribbon with custom text size ---
#content-slide(title: [Upcoming Feature: Serverless Compute v2])[
  #dbrx-ribbon(label: "INTERNAL - DO NOT SHARE", text-size: 11pt)
  - Next-generation serverless with zero cold starts
  - Automatic workload isolation between teams
  - Cost attribution per notebook, per user, per team
  - GA expected Q3 2026
]

// --- Documentation & QR Code Slide ---
#content-slide(title: [Documentation & Resources])[
  #grid(
    columns: (1fr, auto),
    column-gutter: 2cm,
    align: (left + horizon, center + horizon),
    [
      #text(size: 20pt, weight: "bold", fill: dbrx-dark-navy)[Get Started with Databricks]
      #v(0.8cm)
      #text(size: 16pt)[
        Explore the full documentation at: \
        #link("https://docs.databricks.com")[#text(fill: dbrx-teal)[https://docs.databricks.com]]
      ]
      #v(0.8cm)
      #text(size: 14pt, fill: dbrx-charcoal)[
        - Platform overview & quickstarts
        - API reference & SDK guides
        - Unity Catalog documentation
        - Delta Lake & MLflow tutorials
      ]
    ],
    [
      #dbrx-qr-code("https://docs.databricks.com")
      #v(0.3cm)
      #text(size: 12pt, fill: dbrx-charcoal)[Scan to open docs]
    ],
  )
]

// --- Frosted Glass Overlay (light) ---
#freeform-slide()[
  // Background photo
  #place(top + left,
    image("assets/bg-headline-dark-1.jpg", width: slide-width, height: slide-height, fit: "cover"))
  // Semi-transparent white overlay
  #place(top + left,
    rect(width: slide-width, height: slide-height, fill: white.transparentize(45%)))
  #_logo(variant: "dark")

  #place(top + left, dx: margin-x, dy: margin-top,
    block(width: 22cm,
      text(size: 40pt, fill: dbrx-dark-navy)[Real-Time Data Platform]))

  // Frosted card
  #place(top + left, dx: margin-x, dy: 4.4cm,
    block(
      width: 22cm,
      fill: white.transparentize(40%),
      inset: 1.2em,
      radius: 8pt,
    )[
      #set text(size: 22pt, fill: dbrx-charcoal)
      #set list(marker: text(fill: dbrx-charcoal, sym.bullet), indent: 0.6cm, body-indent: 0.4cm, spacing: 0.6em)
      Ingest, transform, and serve data in a single platform.

      #v(0.3cm)
      - Sub-second streaming with Delta Live Tables
      - Automatic schema evolution and data quality checks
      - Unified batch and streaming on one engine

      #v(0.3cm)
      _From raw event to dashboard in minutes, not days._
    ])
]

// --- Frosted Glass Overlay (dark) ---
#freeform-slide()[
  // Background photo
  #place(top + left,
    image("assets/bg-headline-dark-2.jpg", width: slide-width, height: slide-height, fit: "cover"))
  // Semi-transparent dark overlay
  #place(top + left,
    rect(width: slide-width, height: slide-height, fill: rgb("#1b3038").transparentize(30%)))
  #_logo(variant: "light")

  #place(top + left, dx: margin-x, dy: margin-top,
    block(width: 22cm,
      text(size: 40pt, fill: dbrx-white)[AI-Powered Analytics]))

  // Frosted dark card
  #place(top + left, dx: margin-x, dy: 4.4cm,
    block(
      width: 22cm,
      fill: rgb("#1b3038").transparentize(65%),
      inset: 1.2em,
      radius: 8pt,
    )[
      #set text(size: 20pt, fill: dbrx-white)
      #set list(marker: text(fill: dbrx-white, sym.bullet), indent: 0.6cm, body-indent: 0.4cm, spacing: 0.5em)
      From natural language to insight — no SQL required.

      #v(0.15cm)
      #block(
        fill: white.transparentize(65%),
        inset: 0.8em,
        radius: 4pt,
        width: 100%,
      )[
        #text(size: 16pt, fill: dbrx-white)[_"Show me revenue by region for Q4, broken down by product line, with year-over-year comparison."_]
      ]

      #v(0.15cm)
      - Databricks AI/BI translates intent into optimized queries
      - Genie spaces provide governed, conversational analytics
      - Results refresh automatically as data arrives

      #v(0.15cm)
      _Every analyst becomes a data engineer._
    ])
]

// --- Free-form Slide ---
#freeform-slide()[
  #place(top + left, dx: margin-x, dy: margin-top,
    block(width: 31.3cm)[
      #text(size: 40pt, fill: dbrx-dark-navy)[Thank You]
      #v(1cm)
      #text(size: 24pt, fill: dbrx-teal)[Questions?]
      #v(2cm)
      #text(size: 18pt, fill: dbrx-charcoal)[
        Jane Smith \
        jane.smith\@databricks.com \
        Data Platform Engineering
      ]
    ]
  )
]

// --- Blank Dark Slide (closing) ---
#blank-dark-slide()
