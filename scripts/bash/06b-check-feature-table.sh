#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 06b-check-feature-table.sh
#
# Purpose:
#   Check a microbiome feature table before downstream profiling and statistics.
#
# Checks:
#   - feature table exists
#   - sample metadata exists
#   - feature metadata exists
#   - feature table has at least one feature and one sample
#   - count values are numeric
#   - feature table sample columns match sample metadata sample_id values
#
# Usage:
#   bash scripts/bash/06b-check-feature-table.sh
###############################################################################

set -e

FEATURE_DIR="data/features"
METADATA_DIR="data/metadata"
REPORT_DIR="data/reports"

FEATURE_TABLE="${FEATURE_DIR}/feature-table.tsv"
FEATURE_METADATA="${FEATURE_DIR}/feature-metadata.tsv"
SAMPLE_METADATA="${METADATA_DIR}/sample-metadata.tsv"
REPORT_FILE="${REPORT_DIR}/feature-table-check-report.tsv"

mkdir -p "${REPORT_DIR}"

printf "check\tstatus\tnotes\n" > "${REPORT_FILE}"

echo "Microbiome Analysis System: Feature Table Check"
echo

check_file() {
  label="$1"
  file="$2"

  if [ -s "${file}" ]; then
    echo "FOUND: ${label} -> ${file}"
    printf "%s\tOK\t%s\n" "${label}" "${file}" >> "${REPORT_FILE}"
  else
    echo "MISSING: ${label} -> ${file}"
    printf "%s\tFAIL\t%s\n" "${label}" "${file}" >> "${REPORT_FILE}"
    exit 1
  fi
}

check_file "feature_table" "${FEATURE_TABLE}"
check_file "feature_metadata" "${FEATURE_METADATA}"
check_file "sample_metadata" "${SAMPLE_METADATA}"

feature_count=$(tail -n +2 "${FEATURE_TABLE}" | wc -l | tr -d ' ')
sample_count=$(head -n 1 "${FEATURE_TABLE}" | awk -F '\t' '{print NF-1}')

if [ "${feature_count}" -gt 0 ] && [ "${sample_count}" -gt 0 ]; then
  printf "feature_table_dimensions\tOK\t%s features and %s samples\n" "${feature_count}" "${sample_count}" >> "${REPORT_FILE}"
else
  printf "feature_table_dimensions\tFAIL\t%s features and %s samples\n" "${feature_count}" "${sample_count}" >> "${REPORT_FILE}"
fi

non_numeric=$(awk -F '\t' '
NR > 1 {
  for (i = 2; i <= NF; i++) {
    if ($i !~ /^[0-9]+([.][0-9]+)?$/) {
      count++;
    }
  }
}
END {print count+0}
' "${FEATURE_TABLE}")

if [ "${non_numeric}" -eq 0 ]; then
  printf "numeric_values\tOK\tAll feature abundance values are numeric\n" >> "${REPORT_FILE}"
else
  printf "numeric_values\tFAIL\t%s non-numeric abundance values detected\n" "${non_numeric}" >> "${REPORT_FILE}"
fi

tmp_feature_samples=$(mktemp)
tmp_metadata_samples=$(mktemp)

head -n 1 "${FEATURE_TABLE}" | tr '\t' '\n' | tail -n +2 | sort > "${tmp_feature_samples}"
tail -n +2 "${SAMPLE_METADATA}" | awk -F '\t' '{print $1}' | sort > "${tmp_metadata_samples}"

missing_in_metadata=$(comm -23 "${tmp_feature_samples}" "${tmp_metadata_samples}" | wc -l | tr -d ' ')
missing_in_feature_table=$(comm -13 "${tmp_feature_samples}" "${tmp_metadata_samples}" | wc -l | tr -d ' ')

if [ "${missing_in_metadata}" -eq 0 ] && [ "${missing_in_feature_table}" -eq 0 ]; then
  printf "sample_id_linkage\tOK\tFeature table samples match sample metadata\n" >> "${REPORT_FILE}"
else
  printf "sample_id_linkage\tFAIL\t%s feature-table samples missing in metadata; %s metadata samples missing in feature table\n" \
    "${missing_in_metadata}" "${missing_in_feature_table}" >> "${REPORT_FILE}"
fi

rm -f "${tmp_feature_samples}" "${tmp_metadata_samples}"

echo
echo "Feature table check report written to: ${REPORT_FILE}"
echo
cat "${REPORT_FILE}"
