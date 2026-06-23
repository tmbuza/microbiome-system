#!/bin/bash

###############################################################################
# Microbiome Analysis System Scaffold
# Complex Data Insights
###############################################################################

set -e

echo "Creating Microbiome Analysis System scaffold..."

mkdir -p scripts/bash
mkdir -p scripts/R
mkdir -p data/raw
mkdir -p data/metadata
mkdir -p data/processed
mkdir -p data/results
mkdir -p data/reports
mkdir -p figures
mkdir -p tables
mkdir -p library

touch index.qmd
touch 00-preface.qmd
touch 01-system-overview.qmd
touch 02-study-design-and-metadata.qmd
touch 03-sample-collection-and-sequencing.qmd
touch 04-data-acquisition.qmd
touch 05-quality-control.qmd
touch 06-feature-generation.qmd
touch 07-taxonomic-profiling.qmd
touch 08-diversity-analysis.qmd
touch 09-functional-profiling.qmd
touch 10-differential-analysis.qmd
touch 11-biological-interpretation.qmd
touch 12-reproducible-reporting.qmd
touch 13-workforce-readiness.qmd
touch 999-appendix.qmd
touch 999-references.qmd
touch library/references.bib

cat > _quarto.yml <<'EOF'
project:
  type: book
  output-dir: docs

bibliography: library/references.bib
date: last-modified
date-format: "MMM YYYY"

book:
  title: "Microbiome Analysis System"
  subtitle: "From Microbial Communities to Defensible Biological Insights"
  author: "Teresia Mrema Buza | Complex Data Insights"

  chapters:
    - index.qmd
    - 00-preface.qmd
    - 01-system-overview.qmd
    - 02-study-design-and-metadata.qmd
    - 03-sample-collection-and-sequencing.qmd
    - 04-data-acquisition.qmd
    - 05-quality-control.qmd
    - 06-feature-generation.qmd
    - 07-taxonomic-profiling.qmd
    - 08-diversity-analysis.qmd
    - 09-functional-profiling.qmd
    - 10-differential-analysis.qmd
    - 11-biological-interpretation.qmd
    - 12-reproducible-reporting.qmd
    - 13-workforce-readiness.qmd

  appendices:
    - 999-appendix.qmd
    - 999-references.qmd

format:
  html:
    theme: cosmo
    toc: true
    number-sections: true
    code-fold: true
    code-summary: "Show code"
    code-tools: true
    smooth-scroll: true

execute:
  freeze: auto
EOF

cat > .gitignore <<'EOF'
# Quarto build/cache
.quarto/
_freeze/
docs/

# R / RStudio
.Rhistory
.RData
.Rproj.user/

# macOS
.DS_Store

# Data files
data/raw/
data/processed/
data/results/
data/reports/

# Temporary files
*.log
*.tmp
EOF

echo "MAS scaffold created successfully."