###############################################################################
# Microbiome Analysis System
# 13b-create-portfolio-summary.R
#
# Purpose:
#   Create a learner-facing portfolio summary from the MAS skills matrix.
#
# Usage:
#   Rscript scripts/R/13b-create-portfolio-summary.R
###############################################################################

library(readr)
library(dplyr)
library(glue)

workforce_dir <- "data/workforce"
report_dir <- "data/reports"

dir.create(workforce_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

skills_file <- file.path(workforce_dir, "mas-skills-matrix.tsv")
portfolio_file <- file.path(workforce_dir, "mas-portfolio-summary.md")
status_file <- file.path(report_dir, "portfolio-summary-status.tsv")

if (!file.exists(skills_file)) {
  stop(
    "Missing skills matrix: ",
    skills_file,
    "\nRun: Rscript scripts/R/13a-build-skills-matrix.R"
  )
}

skills <- read_tsv(skills_file, show_col_types = FALSE)

skill_lines <- paste0(
  "- **", skills$mas_stage, "**: ",
  skills$practical_skill,
  " — Evidence: ",
  skills$evidence_output,
  collapse = "\n"
)

portfolio <- glue(
"# MAS Portfolio Summary

## Overview

This portfolio summary documents practical skills demonstrated through the Microbiome Analysis System workflow.

The workflow shows how microbiome analysis can move from organized inputs to quality control, feature generation, profiling, interpretation, and reproducible reporting.

## Skills Demonstrated

{skill_lines}

## Portfolio Evidence

A learner can include the following evidence:

- project directory structure
- scripts used in each stage
- generated report tables
- taxonomic profile plot
- diversity analysis plot
- functional profile plot
- differential analysis plot
- biological interpretation notes
- final analysis summary report

## Reflection Questions

1. What biological question does the workflow address?
2. Which metadata variables are required for interpretation?
3. Which quality-control checks were performed?
4. What does the feature table represent?
5. What does the taxonomic profile show?
6. What do diversity metrics summarize?
7. What is the difference between functional potential and functional activity?
8. Why should differential results be interpreted cautiously?
9. What limitations should be reported?
10. How can the workflow be rerun or improved?

## Important Note

If this portfolio was built using the MAS toy example, it demonstrates workflow readiness only.

It should not be presented as a real biological analysis.

## Next Step

Replace the toy example with a real, well-documented dataset and repeat the workflow with proper study design, quality control, and interpretation.
"
)

writeLines(portfolio, portfolio_file)

status <- tibble::tibble(
  metric = c(
    "skills_documented",
    "portfolio_file",
    "status"
  ),
  value = c(
    nrow(skills),
    portfolio_file,
    "PORTFOLIO_SUMMARY_CREATED"
  )
)

write_tsv(status, status_file)

message("Created:")
message("  ", portfolio_file)
message("  ", status_file)
