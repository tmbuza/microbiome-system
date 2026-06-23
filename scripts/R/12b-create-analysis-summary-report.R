###############################################################################
# Microbiome Analysis System
# 12b-create-analysis-summary-report.R
#
# Purpose:
#   Create a simple Markdown summary report from MAS workflow outputs.
#
# Usage:
#   Rscript scripts/R/12b-create-analysis-summary-report.R
###############################################################################

library(readr)
library(dplyr)
library(glue)

reporting_dir <- "data/reporting"
report_dir <- "data/reports"

dir.create(reporting_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

inventory_file <- file.path(reporting_dir, "mas-report-file-inventory.tsv")
summary_report <- file.path(reporting_dir, "mas-analysis-summary-report.md")
status_report <- file.path(report_dir, "analysis-summary-report-status.tsv")

if (!file.exists(inventory_file)) {
  stop(
    "Missing report inventory: ",
    inventory_file,
    "\nRun: Rscript scripts/R/12a-build-report-inventory.R"
  )
}

inventory <- read_tsv(inventory_file, show_col_types = FALSE)

found <- inventory %>% filter(status == "FOUND")
missing <- inventory %>% filter(status == "MISSING")

found_text <- if (nrow(found) > 0) {
  paste0(
    "- **", found$workflow_stage, "**: ",
    found$file_role,
    " (`", found$file_path, "`)",
    collapse = "\n"
  )
} else {
  "- No expected report files were found"
}

missing_text <- if (nrow(missing) > 0) {
  paste0(
    "- **", missing$workflow_stage, "**: ",
    missing$file_role,
    " (`", missing$file_path, "`)",
    collapse = "\n"
  )
} else {
  "- No expected report files are missing"
}

report_text <- glue(
"# MAS Analysis Summary Report

## Purpose

This report summarizes key outputs from the Microbiome Analysis System workflow.

It is intended as a lightweight reproducible reporting scaffold. The analyst should review, edit, and expand it before sharing externally.

## Workflow Outputs Found

{found_text}

## Workflow Outputs Missing

{missing_text}

## Interpretation Guidance

The MAS workflow outputs should be interpreted together, not as isolated files.

A report-ready interpretation should connect:

- study question
- sample metadata
- data acquisition status
- quality-control status
- feature generation outputs
- taxonomic profile patterns
- diversity patterns
- functional profile patterns, when available
- differential analysis results, when available
- biological interpretation notes
- limitations

## Required Analyst Review

Before final reporting, review:

1. Whether all expected outputs were generated.
2. Whether toy example data were replaced by real analysis data where appropriate.
3. Whether all figures and tables match the current analysis.
4. Whether interpretation statements are supported by evidence.
5. Whether limitations are clearly stated.

## Important Note

If this report was generated from the MAS toy example, it should not be used for biological interpretation.

The toy data are designed only for workflow testing.

## Next Step

Use this scaffold as input to the final Quarto report or project documentation.
"
)

writeLines(report_text, summary_report)

status <- tibble::tibble(
  metric = c(
    "inventory_files_found",
    "inventory_files_missing",
    "summary_report",
    "report_status"
  ),
  value = c(
    nrow(found),
    nrow(missing),
    summary_report,
    "SUMMARY_REPORT_CREATED"
  )
)

write_tsv(status, status_report)

message("Created:")
message("  ", summary_report)
message("  ", status_report)
