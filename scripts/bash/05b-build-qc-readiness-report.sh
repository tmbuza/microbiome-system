#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 05b-build-qc-readiness-report.sh
#
# Purpose:
#   Build a simple QC readiness report from FASTQ QC outputs.
#
# Usage:
#   bash scripts/bash/05b-build-qc-readiness-report.sh
###############################################################################

set -e

QC_DIR="data/qc"
REPORT_DIR="data/reports"

SUMMARY_FILE="${QC_DIR}/fastq-qc-summary.tsv"
STATUS_FILE="${QC_DIR}/fastq-qc-status.tsv"
READINESS_REPORT="${REPORT_DIR}/qc-readiness-report.tsv"

mkdir -p "${REPORT_DIR}"

if [ ! -s "${SUMMARY_FILE}" ]; then
  echo "Missing FASTQ QC summary: ${SUMMARY_FILE}"
  echo "Run: bash scripts/bash/05a-check-fastq-files.sh"
  exit 1
fi

if [ ! -s "${STATUS_FILE}" ]; then
  echo "Missing FASTQ QC status: ${STATUS_FILE}"
  echo "Run: bash scripts/bash/05a-check-fastq-files.sh"
  exit 1
fi

total_files=$(tail -n +2 "${SUMMARY_FILE}" | wc -l | tr -d ' ')
failed_structure=$(awk -F '\t' 'NR > 1 && $9 != "OK" {count++} END {print count+0}' "${SUMMARY_FILE}")
failed_gzip=$(awk -F '\t' 'NR > 1 && $8 == "FAIL" {count++} END {print count+0}' "${SUMMARY_FILE}")
total_reads=$(awk -F '\t' 'NR > 1 {sum += $4} END {print sum+0}' "${SUMMARY_FILE}")
min_reads=$(awk -F '\t' 'NR == 2 {min=$4} NR > 2 && $4 < min {min=$4} END {if (min=="") print 0; else print min}' "${SUMMARY_FILE}")
max_reads=$(awk -F '\t' 'NR == 2 {max=$4} NR > 2 && $4 > max {max=$4} END {if (max=="") print 0; else print max}' "${SUMMARY_FILE}")

decision="READY_FOR_NEXT_STEP"
notes="FASTQ files passed lightweight file-level checks"

if [ "${total_files}" -eq 0 ]; then
  decision="NOT_READY"
  notes="No FASTQ files were found"
elif [ "${failed_structure}" -gt 0 ] || [ "${failed_gzip}" -gt 0 ]; then
  decision="REVIEW_REQUIRED"
  notes="One or more FASTQ files failed gzip or structure checks"
fi

printf "metric\tvalue\n" > "${READINESS_REPORT}"
printf "total_fastq_files\t%s\n" "${total_files}" >> "${READINESS_REPORT}"
printf "total_reads\t%s\n" "${total_reads}" >> "${READINESS_REPORT}"
printf "minimum_reads_per_file\t%s\n" "${min_reads}" >> "${READINESS_REPORT}"
printf "maximum_reads_per_file\t%s\n" "${max_reads}" >> "${READINESS_REPORT}"
printf "failed_gzip_checks\t%s\n" "${failed_gzip}" >> "${READINESS_REPORT}"
printf "failed_fastq_structure_checks\t%s\n" "${failed_structure}" >> "${READINESS_REPORT}"
printf "qc_decision\t%s\n" "${decision}" >> "${READINESS_REPORT}"
printf "notes\t%s\n" "${notes}" >> "${READINESS_REPORT}"

echo "QC readiness report written to: ${READINESS_REPORT}"
echo
cat "${READINESS_REPORT}"
