###############################################################################
# Microbiome Analysis System
# 11a-build-interpretation-evidence.R
#
# Purpose:
#   Build an evidence index from MAS analysis outputs.
#
# Usage:
#   Rscript scripts/R/11a-build-interpretation-evidence.R
###############################################################################

library(readr)
library(dplyr)
library(tibble)

interpretation_dir <- "data/interpretation"
report_dir <- "data/reports"

dir.create(interpretation_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

expected_outputs <- tibble(
  evidence_area = c(
    "data_acquisition",
    "quality_control",
    "feature_generation",
    "taxonomic_profiling",
    "diversity_analysis",
    "functional_profiling",
    "differential_analysis"
  ),
  expected_file = c(
    "data/reports/data-acquisition-summary.tsv",
    "data/reports/qc-readiness-report.tsv",
    "data/reports/feature-table-check-report.tsv",
    "data/reports/taxonomic-profile-report.tsv",
    "data/reports/diversity-analysis-report.tsv",
    "data/reports/functional-profile-report.tsv",
    "data/reports/differential-analysis-report.tsv"
  ),
  interpretation_role = c(
    "documents whether data were acquired and organized",
    "documents whether FASTQ inputs passed lightweight QC checks",
    "documents whether the feature table is structurally usable",
    "summarizes taxonomic profile readiness",
    "summarizes alpha and beta diversity outputs",
    "summarizes functional profile readiness",
    "summarizes differential comparison outputs"
  )
)

evidence_index <- expected_outputs %>%
  rowwise() %>%
  mutate(
    status = ifelse(file.exists(expected_file), "FOUND", "MISSING"),
    file_size_bytes = ifelse(file.exists(expected_file), file.info(expected_file)$size, NA_real_)
  ) %>%
  ungroup()

write_tsv(
  evidence_index,
  file.path(interpretation_dir, "interpretation-evidence-index.tsv")
)

summary_report <- evidence_index %>%
  count(status, name = "n_outputs")

write_tsv(
  summary_report,
  file.path(report_dir, "interpretation-evidence-summary.tsv")
)

message("Created:")
message("  ", file.path(interpretation_dir, "interpretation-evidence-index.tsv"))
message("  ", file.path(report_dir, "interpretation-evidence-summary.tsv"))
