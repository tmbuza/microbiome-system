#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 09a-create-example-functional-profile.sh
#
# Purpose:
#   Create a small example functional profile for workflow testing.
#
# Important:
#   This script creates toy pathway abundances and mock annotations.
#   These are not real functional profiling results and should not be used for
#   biological interpretation.
#
# Usage:
#   bash scripts/bash/09a-create-example-functional-profile.sh
###############################################################################

set -e

FUNCTION_DIR="data/function"
REPORT_DIR="data/reports"

mkdir -p "${FUNCTION_DIR}"
mkdir -p "${REPORT_DIR}"

FUNCTION_TABLE="${FUNCTION_DIR}/pathway-abundance.tsv"
FUNCTION_METADATA="${FUNCTION_DIR}/pathway-metadata.tsv"
REPORT_FILE="${REPORT_DIR}/functional-profile-report.tsv"

echo "Creating MAS example functional profile..."

cat > "${FUNCTION_TABLE}" <<'EOF'
pathway_id	SRR17868090	SRR17868091	SRR17868092
PWY_001	45	38	22
PWY_002	12	18	35
PWY_003	5	7	20
PWY_004	25	21	19
PWY_005	3	5	12
EOF

cat > "${FUNCTION_METADATA}" <<'EOF'
pathway_id	pathway_name	category	notes
PWY_001	Carbohydrate fermentation	Metabolism	toy pathway
PWY_002	Short-chain fatty acid production	Metabolism	toy pathway
PWY_003	Bile acid transformation	Host-microbe interaction	toy pathway
PWY_004	Amino acid biosynthesis	Metabolism	toy pathway
PWY_005	Oxidative stress response	Stress response	toy pathway
EOF

pathway_count=$(tail -n +2 "${FUNCTION_TABLE}" | wc -l | tr -d ' ')
sample_count=$(head -n 1 "${FUNCTION_TABLE}" | awk -F '\t' '{print NF-1}')

printf "metric\tvalue\n" > "${REPORT_FILE}"
printf "pathway_count\t%s\n" "${pathway_count}" >> "${REPORT_FILE}"
printf "sample_count\t%s\n" "${sample_count}" >> "${REPORT_FILE}"
printf "profile_type\ttoy pathway abundance profile\n" >> "${REPORT_FILE}"
printf "functional_profile_status\tREADY_FOR_PLOTTING\n" >> "${REPORT_FILE}"

echo "Example functional profile created."
echo
echo "Created:"
echo "  ${FUNCTION_TABLE}"
echo "  ${FUNCTION_METADATA}"
echo "  ${REPORT_FILE}"
echo
echo "Next:"
echo "  Rscript scripts/R/09b-plot-functional-profile.R"
