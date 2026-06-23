#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 07a-build-taxonomic-profile.sh
#
# Purpose:
#   Build a simple genus-level taxonomic profile from the example feature table.
#
# Inputs:
#   data/features/feature-table.tsv
#   data/features/feature-metadata.tsv
#
# Outputs:
#   data/taxonomy/feature-taxonomy-long.tsv
#   data/taxonomy/genus-counts-long.tsv
#   data/taxonomy/genus-relative-abundance.tsv
#
# Usage:
#   bash scripts/bash/07a-build-taxonomic-profile.sh
###############################################################################

set -e

FEATURE_DIR="data/features"
TAXONOMY_DIR="data/taxonomy"
REPORT_DIR="data/reports"

FEATURE_TABLE="${FEATURE_DIR}/feature-table.tsv"
FEATURE_METADATA="${FEATURE_DIR}/feature-metadata.tsv"

LONG_FEATURE_TAXONOMY="${TAXONOMY_DIR}/feature-taxonomy-long.tsv"
GENUS_COUNTS="${TAXONOMY_DIR}/genus-counts-long.tsv"
GENUS_REL_ABUND="${TAXONOMY_DIR}/genus-relative-abundance.tsv"
REPORT_FILE="${REPORT_DIR}/taxonomic-profile-report.tsv"

mkdir -p "${TAXONOMY_DIR}"
mkdir -p "${REPORT_DIR}"

if [ ! -s "${FEATURE_TABLE}" ]; then
  echo "Missing feature table: ${FEATURE_TABLE}"
  echo "Run: bash scripts/bash/06a-create-example-feature-table.sh"
  exit 1
fi

if [ ! -s "${FEATURE_METADATA}" ]; then
  echo "Missing feature metadata: ${FEATURE_METADATA}"
  echo "Run: bash scripts/bash/06a-create-example-feature-table.sh"
  exit 1
fi

echo "Building genus-level taxonomic profile..."

awk -F '\t' '
NR == FNR {
  if (FNR > 1) {
    taxonomy=$3;
    n=split(taxonomy, parts, ";");
    genus=parts[n];
    gsub(/^ +| +$/, "", genus);
    if (genus == "" || genus == "NA") genus="Unclassified";
    tax[$1]=taxonomy;
    genus_map[$1]=genus;
  }
  next;
}
FNR == 1 {
  for (i=2; i<=NF; i++) {
    sample[i]=$i;
  }
  print "feature_id\tsample_id\tcount\ttaxonomy\tgenus";
  next;
}
{
  feature=$1;
  for (i=2; i<=NF; i++) {
    print feature "\t" sample[i] "\t" $i "\t" tax[feature] "\t" genus_map[feature];
  }
}
' "${FEATURE_METADATA}" "${FEATURE_TABLE}" > "${LONG_FEATURE_TAXONOMY}"

awk -F '\t' '
BEGIN {OFS="\t"}
NR == 1 {next}
{
  key=$2 "\t" $5;
  counts[key]+=$3;
}
END {
  print "sample_id", "genus", "count";
  for (key in counts) {
    print key, counts[key];
  }
}
' "${LONG_FEATURE_TAXONOMY}" | sort -k1,1 -k2,2 > "${GENUS_COUNTS}"

awk -F '\t' '
BEGIN {OFS="\t"}
NR == 1 {next}
{
  total[$1]+=$3;
  count[$1 "\t" $2]+=$3;
}
END {
  print "sample_id", "genus", "count", "relative_abundance";
  for (key in count) {
    split(key, parts, "\t");
    sample=parts[1];
    genus=parts[2];
    rel=0;
    if (total[sample] > 0) rel=count[key]/total[sample];
    print sample, genus, count[key], rel;
  }
}
' "${GENUS_COUNTS}" | sort -k1,1 -k2,2 > "${GENUS_REL_ABUND}"

feature_count=$(tail -n +2 "${FEATURE_TABLE}" | wc -l | tr -d ' ')
sample_count=$(head -n 1 "${FEATURE_TABLE}" | awk -F '\t' '{print NF-1}')
genus_count=$(tail -n +2 "${GENUS_COUNTS}" | awk -F '\t' '{print $2}' | sort -u | wc -l | tr -d ' ')

printf "metric\tvalue\n" > "${REPORT_FILE}"
printf "feature_count\t%s\n" "${feature_count}" >> "${REPORT_FILE}"
printf "sample_count\t%s\n" "${sample_count}" >> "${REPORT_FILE}"
printf "genus_count\t%s\n" "${genus_count}" >> "${REPORT_FILE}"
printf "taxonomic_rank\tgenus\n" >> "${REPORT_FILE}"
printf "profile_status\tREADY_FOR_PLOTTING\n" >> "${REPORT_FILE}"

echo "Created:"
echo "  ${LONG_FEATURE_TAXONOMY}"
echo "  ${GENUS_COUNTS}"
echo "  ${GENUS_REL_ABUND}"
echo "  ${REPORT_FILE}"
