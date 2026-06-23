#!/bin/bash

###############################################################################
# Microbiome Analysis System
# end-to-end-case-study.sh
#
# Purpose:
#   Run the complete MAS toy end-to-end case study from data acquisition through
#   workforce readiness outputs.
#
# Important:
#   This workflow uses toy example data created by MAS scripts.
#   It is intended for workflow testing only and should not be used for
#   biological interpretation.
#
# Usage:
#   bash scripts/bash/end-to-end-case-study.sh
###############################################################################

set -e

echo "========================================"
echo "Microbiome Analysis System"
echo "End-to-End Toy Case Study"
echo "========================================"
echo

echo "Step 04: Data acquisition"
bash scripts/bash/04a-create-example-acquisition-data.sh
bash scripts/bash/04b-check-data-acquisition.sh
echo

echo "Step 05: Quality control"
bash scripts/bash/05a-check-fastq-files.sh
bash scripts/bash/05b-build-qc-readiness-report.sh
echo

echo "Step 06: Feature generation"
bash scripts/bash/06a-create-example-feature-table.sh
bash scripts/bash/06b-check-feature-table.sh
echo

echo "Step 07: Taxonomic profiling"
bash scripts/bash/07a-build-taxonomic-profile.sh
Rscript scripts/R/07b-plot-taxonomic-profile.R
echo

echo "Step 08: Diversity analysis"
Rscript scripts/R/08a-calculate-diversity-metrics.R
Rscript scripts/R/08b-plot-diversity-results.R
echo

echo "Step 09: Functional profiling"
bash scripts/bash/09a-create-example-functional-profile.sh
Rscript scripts/R/09b-plot-functional-profile.R
echo

echo "Step 10: Differential analysis"
Rscript scripts/R/10a-run-example-differential-analysis.R
Rscript scripts/R/10b-plot-differential-results.R
echo

echo "Step 11: Biological interpretation"
Rscript scripts/R/11a-build-interpretation-evidence.R
Rscript scripts/R/11b-draft-interpretation-notes.R
echo

echo "Step 12: Reproducible reporting"
Rscript scripts/R/12a-build-report-inventory.R
Rscript scripts/R/12b-create-analysis-summary-report.R
echo

echo "Step 13: Workforce readiness"
Rscript scripts/R/13a-build-skills-matrix.R
Rscript scripts/R/13b-create-portfolio-summary.R
echo

echo "========================================"
echo "MAS end-to-end toy case study complete"
echo "========================================"
echo
echo "Key reports:"
echo "  data/reports/data-acquisition-summary.tsv"
echo "  data/reports/qc-readiness-report.tsv"
echo "  data/reports/feature-table-check-report.tsv"
echo "  data/reports/taxonomic-profile-report.tsv"
echo "  data/reports/diversity-analysis-report.tsv"
echo "  data/reports/functional-profile-report.tsv"
echo "  data/reports/differential-analysis-report.tsv"
echo "  data/reports/biological-interpretation-report.tsv"
echo "  data/reports/reproducible-reporting-summary.tsv"
echo "  data/reports/workforce-readiness-summary.tsv"
echo
echo "Important:"
echo "  These outputs are generated from toy data for workflow testing only."
echo "  Do not interpret them biologically."
