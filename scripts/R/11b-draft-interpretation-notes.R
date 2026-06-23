###############################################################################
# Microbiome Analysis System
# 11b-draft-interpretation-notes.R
#
# Purpose:
#   Create a draft biological interpretation notes file from MAS outputs.
#
# Usage:
#   Rscript scripts/R/11b-draft-interpretation-notes.R
###############################################################################

library(readr)
library(dplyr)
library(glue)

interpretation_dir <- "data/interpretation"
report_dir <- "data/reports"

dir.create(interpretation_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

evidence_file <- file.path(interpretation_dir, "interpretation-evidence-index.tsv")
notes_file <- file.path(interpretation_dir, "biological-interpretation-notes.md")
report_file <- file.path(report_dir, "biological-interpretation-report.tsv")

if (!file.exists(evidence_file)) {
  stop(
    "Missing interpretation evidence index: ",
    evidence_file,
    "\nRun: Rscript scripts/R/11a-build-interpretation-evidence.R"
  )
}

evidence <- read_tsv(evidence_file, show_col_types = FALSE)

found_outputs <- evidence %>%
  filter(status == "FOUND") %>%
  pull(evidence_area)

missing_outputs <- evidence %>%
  filter(status == "MISSING") %>%
  pull(evidence_area)

found_text <- if (length(found_outputs) > 0) {
  paste0("- ", found_outputs, collapse = "\n")
} else {
  "- No evidence outputs were found"
}

missing_text <- if (length(missing_outputs) > 0) {
  paste0("- ", missing_outputs, collapse = "\n")
} else {
  "- No expected evidence outputs are missing"
}

notes <- glue(
"# Biological Interpretation Notes

## Interpretation Status

This file is a draft interpretation support document generated from MAS workflow outputs.

It should be edited by the analyst before reporting.

## Evidence Outputs Found

{found_text}

## Evidence Outputs Missing

{missing_text}

## Draft Interpretation Framework

### 1. Biological Question

State the biological question that the microbiome analysis is intended to answer.

### 2. Study Design Context

Summarize the sample type, comparison groups, sequencing strategy, and relevant metadata.

### 3. Quality-Control Context

Summarize whether data acquisition and quality-control checks support downstream interpretation.

### 4. Taxonomic Patterns

Describe major taxonomic patterns, dominant taxa, or community composition observations.

### 5. Diversity Patterns

Describe alpha diversity and beta diversity patterns. Avoid overinterpreting ordination plots.

### 6. Functional Patterns

Describe functional profile patterns if functional outputs are available. Distinguish functional potential from functional activity.

### 7. Differential Results

Summarize differential results as candidate observations. Include effect sizes, adjusted p-values where appropriate, and limitations.

### 8. Integrated Interpretation

Connect taxonomic, diversity, functional, and differential evidence into cautious biological statements.

### 9. Limitations

Document limitations including sample size, metadata completeness, sequencing strategy, toy data, batch effects, or method assumptions.

### 10. Reporting Statement

Write a concise report-ready statement supported by the evidence.

## Important Note

For the MAS toy example data, no biological conclusions should be made. The purpose is workflow testing only.
"
)

writeLines(notes, notes_file)

report <- tibble::tibble(
  metric = c(
    "evidence_outputs_found",
    "evidence_outputs_missing",
    "notes_file",
    "interpretation_status"
  ),
  value = c(
    length(found_outputs),
    length(missing_outputs),
    notes_file,
    "DRAFT_NOTES_CREATED"
  )
)

write_tsv(report, report_file)

message("Created:")
message("  ", notes_file)
message("  ", report_file)
