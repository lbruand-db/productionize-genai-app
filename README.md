# Databricks Corporate Presentation Template for Typst

A Typst template that faithfully reproduces the Databricks corporate slide deck, extracted from the official PowerPoint template. Uses the Barlow font, Databricks brand colors, logos, and halftone background patterns.

## Quick Start

```typ
#import "dbrx.typ": *

#show: dbrx-presentation.with(
  title: "My Presentation",
  author: "Your Name",
  subject: "Team Name",
)

#title-slide(
  title: [My Presentation],
  subtitle: [Team Name],
  author: [Your Name],
  date: [February 2026],
)

#content-slide(title: [Key Points])[
  - First point
  - Second point
  - Third point
]
```

Compile with:

```bash
./compile.sh my-presentation.typ
```

This uses the bundled Barlow fonts and embeds the current git commit ID in the PDF metadata.

## Project Structure

```
typst-dbrx-template/
  dbrx.typ              # Template library (import this)
  example.typ           # Full example presentation
  compile.sh            # Build script (fonts + git commit ID)
  fonts/
    Barlow-Regular.ttf   # Barlow font (5 weights)
    Barlow-Medium.ttf
    Barlow-SemiBold.ttf
    Barlow-Bold.ttf
    Barlow-Light.ttf
  assets/
    logo-light.png       # White logo (for dark/red backgrounds)
    logo-dark.png        # Dark logo (for white backgrounds)
    db-icon-red.svg      # Red Databricks icon (for QR codes)
    bg-red.png           # Red halftone background
    bg-dark.png          # Dark navy halftone background
    bg-teal.png          # Teal halftone background
    bg-headline-red.png  # Headline slide background (red)
    bg-headline-dark-*.jpg  # Headline slide backgrounds (dark, 3 variants)
```

## Slide Functions

### `title-slide` -- Cover Slide

Red background with halftone pattern. Used as the opening slide.

```typ
#title-slide(
  title: [Quarterly Business Review],
  subtitle: [Data Platform Engineering],
  author: [Jane Smith],
  date: [February 2026],
)
```

### `section-slide` -- Section Divider (Red)

Red background divider to separate major sections.

```typ
#section-slide(title: [Agenda])
```

### `section-slide-dark` -- Section Divider (Dark Navy)

Dark navy background with photography. Three `variant` options (1, 2, 3) with different photos.

```typ
#section-slide-dark(title: [Deep Dive: Architecture], variant: 1)
```

### `content-slide` -- Basic Content

White background with title and body content area. Body text is 28pt with bullet support.

```typ
#content-slide(title: [Key Highlights])[
  - Revenue grew 35% year-over-year
  - Expanded to 3 new regions
]
```

### `subtitle-content-slide` -- Title + Subtitle + Content

White background with title, teal subtitle, and body content.

```typ
#subtitle-content-slide(
  title: [Platform Performance],
  subtitle: [Metrics from Q4 2025],
)[
  - Average query latency reduced by 42%
  - Cluster utilization improved to 89%
]
```

### `two-column-slide` -- Two Columns

White background with optional teal column headings. Takes two content bodies.

```typ
#two-column-slide(
  title: [Comparison],
  left-heading: [Before],
  right-heading: [After],
)[
  - Legacy systems
  - Manual processes
][
  - Modern platform
  - Automated pipelines
]
```

### `three-column-slide` -- Three Columns

White background with optional headings. Takes three content bodies.

```typ
#three-column-slide(
  title: [Team Structure],
  headings: ([Engineering], [Data Science], [Operations]),
)[
  - Platform team (12)
][
  - ML engineers (6)
][
  - SRE team (4)
]
```

### `box-slide` -- Colored Category Boxes (2-4)

White background with teal category boxes. Supports 2 to 4 boxes. Optional `box-color` parameter.

```typ
#box-slide(
  title: [Strategic Pillars],
  boxes: (
    (label: [Performance], body: [
      - Sub-second queries
      - Auto-scaling clusters
    ]),
    (label: [Governance], body: [
      - Unity Catalog
      - Row-level security
    ]),
  ),
  box-color: dbrx-dark-teal,  // optional, defaults to dbrx-teal
)
```

### `quote-slide` -- Quote with Attribution

Three background variants: `"red"`, `"dark"`, `"teal"`.

```typ
#quote-slide(
  quote: [The platform has transformed our data infrastructure.],
  attribution: [-- Sarah Chen, VP of Engineering],
  bg: "red",
)
```

### `headline-slide` -- Tagline / Headline

Red/dark background for impactful single statements.

```typ
#headline-slide(
  text-content: [Databricks simplifies and accelerates your data and AI goals.],
)
```

### `image-slide` -- Title + Image + Caption

White background with a centered image area and optional caption.

```typ
#image-slide(
  title: [Architecture Overview],
  img: image("diagram.png", width: 80%),
  caption: [Figure 1: Lakehouse reference architecture],
)
```

### `freeform-slide` -- Manual Layout

Provides a branded slide (logo + background) with full manual control over content. Set `dark: true` for dark navy background.

```typ
#freeform-slide()[
  #place(top + left, dx: margin-x, dy: margin-top,
    block(width: 31.3cm)[
      #text(size: 40pt, fill: dbrx-dark-navy)[Thank You]
    ]
  )
]
```

### `blank-dark-slide` / `blank-white-slide` -- Branded Blanks

Empty slides with just background and logo.

```typ
#blank-dark-slide()
#blank-white-slide()
```

## Utility: `dbrx-table`

A branded table with alternating row colors and a teal header.

```typ
#dbrx-table(
  columns: (1fr, 1fr, 1fr),
  header: ([Metric], [Value], [Change]),
  [Latency], [0.7s], [#text(fill: dbrx-green)[-42%]],
  [Uptime],  [99.99%], [#text(fill: dbrx-green)[+0.05%]],
)
```

## Utility: `dbrx-qr-code`

A branded QR code with the Databricks logo overlaid in the center. Uses high error correction so the code remains scannable.

```typ
#dbrx-qr-code("https://docs.databricks.com")
#dbrx-qr-code("https://example.com", width: 4cm, color: dbrx-teal, logo-width: 0.8cm)
```

| Parameter | Default | Description |
|---|---|---|
| `url` | (required) | URL to encode |
| `width` | `5cm` | QR code size |
| `color` | `dbrx-dark-navy` | QR code color |
| `logo-width` | `1cm` | Databricks logo size |

## Plotting with CeTZ

The example presentation includes a histogram with Gaussian fit using [cetz-plot](https://typst.app/universe/package/cetz-plot/). Import and use within a `content-slide`:

```typ
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#content-slide(title: [Distribution])[
  #set align(center)
  #{
    let data = ((0, 0.05), (1, 0.18), (2, 0.33), (3, 0.38), (4, 0.14), (5, 0.08))

    canvas(length: 1cm, {
      plot.plot(size: (16, 8), x-label: [Value], y-label: [Density], {
        plot.add-bar(data, bar-width: 0.9,
          style: (stroke: dbrx-teal, fill: dbrx-teal.transparentize(60%)))
        plot.add(x => /* gaussian pdf */ .., domain: (-1, 7), samples: 100,
          style: (stroke: 2pt + dbrx-red))
      })
    })
  }
]
```

See `example.typ` for a full working histogram with pseudo-random data generation and Gaussian overlay.

## PDF Metadata

`dbrx-presentation` accepts optional metadata that populates PDF document fields:

```typ
#show: dbrx-presentation.with(
  title: "Quarterly Business Review",
  author: "Jane Smith",
  subject: "Data Platform Engineering",
)
```

The git commit ID is automatically embedded via `compile.sh`. You can also pass it manually:

```typ
#show: dbrx-presentation.with(
  title: "My Deck",
  commit-id: "abc123",
)
```

Or at compile time: `typst compile --input commit_id=$(git rev-parse HEAD) ...`

## Brand Colors

All colors are exported and can be used directly in your content:

| Variable | Hex | Usage |
|---|---|---|
| `dbrx-dark-navy` | `#1b3038` | Dark backgrounds, titles on white |
| `dbrx-red` | `#ff3620` | Brand red, accent bars, red backgrounds |
| `dbrx-white` | `#ffffff` | White backgrounds, text on dark |
| `dbrx-light-gray` | `#f2f2f2` | Light background fills |
| `dbrx-teal` | `#618793` | Sub-headings, box fills, labels |
| `dbrx-teal-light` | `#6ca6bb` | Teal background variant |
| `dbrx-dark-teal` | `#1b5161` | Subtitles, deep accent |
| `dbrx-charcoal` | `#3a3838` | Body text on white |
| `dbrx-blue-gray` | `#a0acbe` | Secondary accent |
| `dbrx-crimson` | `#98102a` | Accent (use sparingly) |
| `dbrx-green` | `#00b379` | Positive/success accent |
| `dbrx-amber` | `#ffab00` | Warning/highlight accent |

## Layout Constants

These are exported for use in `freeform-slide` or custom layouts:

| Variable | Value | Description |
|---|---|---|
| `slide-width` | 33.867cm | Slide width (16:9) |
| `slide-height` | 19.05cm | Slide height |
| `margin-x` | 1.28cm | Left content margin |
| `margin-top` | 1.014cm | Top content margin |

## Brand Guidelines

Per the official Databricks template:

- **Font**: Barlow is the only font that should be used
- **No bold text**: Visual hierarchy is achieved through font size and color
- **Color pairing**: Pair one secondary color with primary colors; avoid multiple secondary colors per slide
- **Four background contexts**: Dark navy, Databricks red, white, and teal
