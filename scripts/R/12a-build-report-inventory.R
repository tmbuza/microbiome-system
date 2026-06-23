###############################################################################
# Microbiome Analysis System
# 12a-build-report-inventory.R
#
# Purpose:
#   Build an inventory of key MAS files for reproducible reporting.
#
# Usage:
#   Rscript scripts/R/12a-build-report-inventory.R
###############################################################################

library(readr)
library(dplyr)
library(tibble)

report_dir <- "data/reports"
reporting_dir <- "data/reporting"

dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(reporting_dir, recursive = TRUE, showWarnings = FALSE)

expected_files <- tibble(
  workflow_stage = c(
    "data_acquisition",
    "quality_control",
    "feature_generation",
    "taxonomic_profiling",
    "diversity_analysis",
    "functional_profiling",
    "differential_analysis",
    "biological_interpretation",
    "biological_interpretation"
  ),
  file_path = c(
    "data/reports/data-acquisition-summary.tsv",
    "data/reports/qc-readiness-report.tsv",
    "data/reports/feature-table-check-report.tsv",
    "data/reports/taxonomic-profile-report.tsv",
    "data/reports/diversity-analysis-report.tsv",
    "data/reports/functional-profile-report.tsv",
    "data/reports/differential-analysis-report.tsv",
    "data/interpretation/interpretation-evidence-index.tsv",
    "data/interpretation/biological-interpretation-notes.md"
  ),
  file_role = c(
    "data acquisition summary",
    "quality-control readiness summary",
    "feature table structural check",
    "taxonomic profile summary",
    "diversity analysis summary",
    "functional profile summary",
    "differential analysis summary",
    "interpretation evidence index",
    "draft biological interpretation notes"
  )
)

inventory <- expected_files %>%
  rowwise() %>%
  mutate(
    status = ifelse(file.exists(file_path), "FOUND", "MISSING"),
    file_size_bytes = ifelse(file.exists(file_path), file.info(file_path)$size, NA_real_),
    last_modified = ifelse(
      file.exists(file_path),
      as.character(file.info(file_path)$mtime),
      NA_character_
    )
  ) %>%
  ungroup()

write_tsv(
  inventory,
  file.path(reporting_dir, "mas-report-file-inventory.tsv")
)

summary <- inventory %>%
  count(status, name = "n_files")

write_tsv(
  summary,
  file.path(report_dir, "reproducible-reporting-summary.tsv")
)

message("Created:")
message("  ", file.path(reporting_dir, "mas-report-file-inventory.tsv"))
message("  ", file.path(report_dir, "reproducible-reporting-summary.tsv"))
