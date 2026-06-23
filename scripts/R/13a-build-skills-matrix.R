###############################################################################
# Microbiome Analysis System
# 13a-build-skills-matrix.R
#
# Purpose:
#   Build a skills matrix linking MAS workflow stages to practical competencies.
#
# Usage:
#   Rscript scripts/R/13a-build-skills-matrix.R
###############################################################################

library(readr)
library(tibble)

workforce_dir <- "data/workforce"
report_dir <- "data/reports"

dir.create(workforce_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

skills_matrix <- tibble(
  mas_stage = c(
    "study_design_and_metadata",
    "data_acquisition",
    "quality_control",
    "feature_generation",
    "taxonomic_profiling",
    "diversity_analysis",
    "functional_profiling",
    "differential_analysis",
    "biological_interpretation",
    "reproducible_reporting"
  ),
  practical_skill = c(
    "Define biological questions and metadata requirements",
    "Organize acquired sequencing data and metadata",
    "Check FASTQ file presence, structure, and readiness",
    "Create and validate feature tables",
    "Summarize taxa and relative abundance profiles",
    "Calculate and interpret alpha and beta diversity outputs",
    "Summarize functional potential carefully",
    "Compare features across groups with caution",
    "Translate outputs into evidence-based interpretation",
    "Assemble workflow outputs into a transparent report"
  ),
  evidence_output = c(
    "metadata plan or sample metadata table",
    "data acquisition summary",
    "QC readiness report",
    "feature table check report",
    "taxonomic profile table and plot",
    "alpha diversity table and beta diversity plot",
    "functional profile table and plot",
    "differential results table and plot",
    "biological interpretation notes",
    "analysis summary report"
  ),
  readiness_level = c(
    "foundation",
    "foundation",
    "foundation",
    "intermediate",
    "intermediate",
    "intermediate",
    "intermediate",
    "intermediate",
    "advanced_foundation",
    "advanced_foundation"
  )
)

write_tsv(
  skills_matrix,
  file.path(workforce_dir, "mas-skills-matrix.tsv")
)

summary <- tibble(
  metric = c(
    "skill_rows",
    "readiness_levels",
    "status"
  ),
  value = c(
    nrow(skills_matrix),
    paste(unique(skills_matrix$readiness_level), collapse = "; "),
    "SKILLS_MATRIX_CREATED"
  )
)

write_tsv(
  summary,
  file.path(report_dir, "workforce-readiness-summary.tsv")
)

message("Created:")
message("  ", file.path(workforce_dir, "mas-skills-matrix.tsv"))
message("  ", file.path(report_dir, "workforce-readiness-summary.tsv"))
