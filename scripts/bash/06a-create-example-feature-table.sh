#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 06a-create-example-feature-table.sh
#
# Purpose:
#   Create a small example microbiome feature table and metadata files.
#
# Important:
#   This script creates toy feature counts for workflow testing.
#   These are not real microbiome features and should not be used for
#   biological interpretation.
#
# Usage:
#   bash scripts/bash/06a-create-example-feature-table.sh
###############################################################################

set -e

FEATURE_DIR="data/features"
METADATA_DIR="data/metadata"
REPORT_DIR="data/reports"

mkdir -p "${FEATURE_DIR}"
mkdir -p "${METADATA_DIR}"
mkdir -p "${REPORT_DIR}"

FEATURE_TABLE="${FEATURE_DIR}/feature-table.tsv"
FEATURE_METADATA="${FEATURE_DIR}/feature-metadata.tsv"
SAMPLE_METADATA="${METADATA_DIR}/sample-metadata.tsv"

echo "Creating MAS example feature table..."

cat > "${FEATURE_TABLE}" <<'EOF'
feature_id	SRR17868090	SRR17868091	SRR17868092
ASV_001	120	85	40
ASV_002	15	30	75
ASV_003	0	12	20
ASV_004	45	42	43
ASV_005	5	0	8
EOF

cat > "${FEATURE_METADATA}" <<'EOF'
feature_id	sequence	taxonomy	confidence
ASV_001	ACGTACGTACGT	Bacteria; Firmicutes; Bacilli; Lactobacillales; Lactobacillaceae; Lactobacillus	0.98
ASV_002	TGCATGCATGCA	Bacteria; Bacteroidota; Bacteroidia; Bacteroidales; Bacteroidaceae; Bacteroides	0.97
ASV_003	GGTTCCAAGGTT	Bacteria; Actinobacteriota; Actinobacteria; Bifidobacteriales; Bifidobacteriaceae; Bifidobacterium	0.96
ASV_004	CCGGAATTCCGG	Bacteria; Proteobacteria; Gammaproteobacteria; Enterobacterales; Enterobacteriaceae; Escherichia-Shigella	0.94
ASV_005	TTGGAACCTTGG	Bacteria; Verrucomicrobiota; Verrucomicrobiae; Verrucomicrobiales; Akkermansiaceae; Akkermansia	0.95
EOF

cat > "${SAMPLE_METADATA}" <<'EOF'
sample_id	group	sample_type	description
SRR17868090	healthy	stool	toy example sample 1
SRR17868091	healthy	stool	toy example sample 2
SRR17868092	healthy	stool	toy example sample 3
EOF

echo "Example feature table created."
echo
echo "Created:"
echo "  ${FEATURE_TABLE}"
echo "  ${FEATURE_METADATA}"
echo "  ${SAMPLE_METADATA}"
echo
echo "Next:"
echo "  bash scripts/bash/06b-check-feature-table.sh"
