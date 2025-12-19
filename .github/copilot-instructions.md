## Bilicurve-Shiny: Copilot Instructions

Purpose: Help AI coding agents be immediately productive in this R Shiny app that plots neonatal bilirubin thresholds for term (>35w) and preterm (<35w) infants.

### Big Picture
- Two parallel apps: Dutch [app.R](../../app.R) and English [app_EN.R](../../app_EN.R); they share logic but use different UI labels, input IDs, and GET parameter names.
- Term (>35w): X-axis is age in days from birth; thresholds are read from TSVs in [data/](../../data). Risk selection (`bili_risk`) chooses which TSV to load and which curve to highlight based on GA at birth.
- Preterm (<35w): X-axis is postmenstrual age (weeks). Threshold “bands” are hard-coded rectangles drawn in the plotting layers.
- Advanced mode supports bulk input via HTTP GET parameters and annotating phototherapy intervals; manual inputs are disabled when `advanced` is on.

### Key Files
- App (NL): [app.R](../../app.R) — IDs/params like `prematuur`, `geboorte_GET`, `PML_geboorte_GET`, `PML_GET`, `PT_aantalLampen_GET`.
- App (EN): [app_EN.R](../../app_EN.R) — IDs/params like `premature`, `birth_GET`, `GA_birth_GET`, `GA_GET`, `PT_numLamps_GET`.
- Curves: [data/all_norisk.tsv](../../data/all_norisk.tsv), [data/all_risk.tsv](../../data/all_risk.tsv) — canonical term thresholds consumed at runtime.
- Sources: [data/*_norisk.txt](../../data), [data/*_risk.txt](../../data) plus [create_df.R](../../create_df.R) to generate the TSVs.
- Static assets: [www/](../../www) — images used by the UI.
- Container: [Dockerfile](../../Dockerfile) — runs on `rocker/shiny:4.3.0` and installs required CRAN packages for deployment.

### Run and Develop
- Local (R): open the project and run either app file.
  - Term/Preterm (Dutch):
    - In R console: `shiny::runApp('app.R', host='0.0.0.0', port=3838)`
  - Term/Preterm (English):
    - In R console: `shiny::runApp('app_EN.R', host='0.0.0.0', port=3838)`
- Required packages (dev): `tidyverse`, `shinyTime`, `shinythemes`, `DT`, `Cairo`, `shinyscreenshot`, `ggrepel`, and `readxl` (for Excel import).
  - Note: The Dockerfile does not install `readxl`. Add it there if Excel upload is needed in containers: `install.packages('readxl')`.
- Docker (prebuilt): see README.
  - `docker run -dp 0.0.0.0:3838:3838 rmvpaeme/bilicurve:0.4`
- Docker (build locally):
  - `docker build -t bilicurve:local .`
  - `docker run -dp 0.0.0.0:3838:3838 bilicurve:local`

### Data and Thresholds
- Term curves come from TSVs in [data/](../../data); selection is governed by `bili_risk` (= no/yes) and `PML_geboorte`/`GA at birth` to decide which week label to highlight (e.g., “36 weeks”).
- To update term thresholds: regenerate the TSVs using [create_df.R](../../create_df.R) from the `*_norisk.txt` / `*_risk.txt` sources and commit the TSVs.
- Preterm thresholds are hard-coded annotated rectangles in `renderPlot()` in each app; edit those `annotate(geom = 'rect', ...)` calls to change cutoffs.
- The plot annotates labels at the most recent entered time using `approx()` interpolation across the highlighted curve and the TcB confirmation line.

### Advanced Mode and GET Parameters
- Toggle advanced: `advanced=ja` (NL) or `advanced=yes` (EN). Manual inputs are disabled when advanced is on.
- Common arrays are comma-separated; missing phototherapy stop may be `NA`. Examples are in [README.md](../../README.md).
- Dutch (term): `geboorte_GET`, `afname_GET`, `PML_geboorte_GET`, `bili_GET`.
- Dutch (preterm): `PML_GET` and `bili_GET`.
- Dutch (phototherapy): `PT_start_GET`, `PT_stop_GET`, `PT_aantalLampen_GET`.
- English (term): `birth_GET`, `sampling_GET`, `GA_birth_GET`, `bili_GET`.
- English (preterm): `GA_GET` and `bili_GET`.
- English (phototherapy): `PT_start_GET`, `PT_stop_GET`, `PT_numLamps_GET`.
- Gestational-age strings like `23+1/7` are parsed by `calc()` which does `eval(parse(text=x))`.

### UI/Workflow Patterns
- Tab visibility is controlled by `observeEvent()` on `prematuur/premature` and `advanced`.
- Table export/import: DT Buttons exports Excel; uploads are read with `readxl::read_excel()` and merged back into the reactive table (do not edit the exported Excel schema).
- `Cairo` is enabled via `options(shiny.usecairo=TRUE)`; `shinyscreenshot` is wired with a screenshot button beside the plot.

### Contributing Conventions
- Keep NL and EN apps feature-parity. When adding or renaming inputs/GET params, update both `parseQueryString(...)` blocks, UI labels, and plot layers in [app.R](../../app.R) and [app_EN.R](../../app_EN.R).
- For term curve changes, prefer regenerating TSVs over ad hoc code edits. For preterm, modify the annotated rectangles in code.
- Static assets live under [www/](../../www). New images should be added there and referenced by filename.
