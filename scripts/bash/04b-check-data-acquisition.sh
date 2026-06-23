#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 04-check-data-acquisition.sh
#
# Purpose:
#   Check whether a CDI-DAS-style microbiome data acquisition package is present
#   and summarize files needed before quality control.
#
# Usage:
#   bash scripts/bash/04-check-data-acquisition.sh
#
# Optional:
#   BIOPROJECT=PRJNA802976 bash scripts/bash/04-check-data-acquisition.sh
###############################################################################

set -e

BIOPROJECT="${BIOPROJECT:-PRJNA802976}"

METADATA_DIR="data/metadata"
MANIFEST_DIR="data/manifests"
RAW_ENA_DIR="data/raw/ena"
RAW_NCBI_DIR="data/raw/ncbi"
INVENTORY_DIR="data/inventory"
VALIDATION_DIR="data/validation"
REPORT_DIR="data/reports"

RUNINFO_FILE="${METADATA_DIR}/runinfo-${BIOPROJECT}.csv"
ENA_FILE="${METADATA_DIR}/ena-${BIOPROJECT}.tsv"
SRR_FILE="${METADATA_DIR}/srr-accessions.txt"
MANIFEST_FILE="${MANIFEST_DIR}/download-manifest.tsv"
TEST_MANIFEST_FILE="${MANIFEST_DIR}/test-manifest.tsv"
ENA_INVENTORY_FILE="${INVENTORY_DIR}/fastq-inventory-ena.tsv"
VALIDATION_REPORT="${VALIDATION_DIR}/validation-report.tsv"

mkdir -p "${REPORT_DIR}"

SUMMARY_FILE="${REPORT_DIR}/data-acquisition-summary.tsv"

echo "Microbiome Analysis System: Data Acquisition Check"
echo "BioProject: ${BIOPROJECT}"
echo

printf "item\tstatus\tpath_or_count\n" > "${SUMMARY_FILE}"

check_file() {
  label="$1"
  file="$2"

  if [ -s "${file}" ]; then
    lines=$(wc -l < "${file}" | tr -d ' ')
    echo "FOUND: ${label} (${lines} lines) -> ${file}"
    printf "%s\tFOUND\t%s lines; %s\n" "${label}" "${lines}" "${file}" >> "${SUMMARY_FILE}"
  else
    echo "MISSING: ${label} -> ${file}"
    printf "%s\tMISSING\t%s\n" "${label}" "${file}" >> "${SUMMARY_FILE}"
  fi
}

check_dir_fastq() {
  label="$1"
  dir="$2"

  if [ -d "${dir}" ]; then
    count=$(find "${dir}" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" -o -name "*.fastq" -o -name "*.fq" \) | wc -l | tr -d ' ')
    echo "FASTQ files in ${label}: ${count}"
    printf "%s\tCOUNT\t%s FASTQ files; %s\n" "${label}" "${count}" "${dir}" >> "${SUMMARY_FILE}"
  else
    echo "MISSING DIRECTORY: ${label} -> ${dir}"
    printf "%s\tMISSING\t%s\n" "${label}" "${dir}" >> "${SUMMARY_FILE}"
  fi
}

check_file "NCBI RunInfo metadata" "${RUNINFO_FILE}"
check_file "ENA metadata" "${ENA_FILE}"
check_file "SRR accession list" "${SRR_FILE}"
check_file "Download manifest" "${MANIFEST_FILE}"
check_file "Test manifest" "${TEST_MANIFEST_FILE}"
check_dir_fastq "ENA raw data" "${RAW_ENA_DIR}"
check_dir_fastq "NCBI raw data" "${RAW_NCBI_DIR}"
check_file "ENA FASTQ inventory" "${ENA_INVENTORY_FILE}"
check_file "Validation report" "${VALIDATION_REPORT}"

echo
echo "Summary written to: ${SUMMARY_FILE}"
echo
echo "Next MAS step:"
echo "  Review the summary, confirm metadata and FASTQ files are present,"
echo "  then continue to 05-quality-control.qmd."
