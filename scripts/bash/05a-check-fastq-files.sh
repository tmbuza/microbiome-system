#!/bin/bash

###############################################################################
# Microbiome Analysis System
# 05a-check-fastq-files.sh
#
# Purpose:
#   Perform lightweight FASTQ quality-control checks before feature generation.
#
# Checks:
#   - FASTQ files exist
#   - gzip integrity for compressed files
#   - FASTQ line count is divisible by 4
#   - read count
#   - minimum, maximum, and average read length
#
# Usage:
#   bash scripts/bash/05a-check-fastq-files.sh
###############################################################################

set -e

RAW_DIRS="data/raw/ena data/raw/ncbi"
QC_DIR="data/qc"
REPORT_DIR="data/reports"

mkdir -p "${QC_DIR}"
mkdir -p "${REPORT_DIR}"

SUMMARY_FILE="${QC_DIR}/fastq-qc-summary.tsv"
STATUS_FILE="${QC_DIR}/fastq-qc-status.tsv"

printf "file\tdirectory\tlines\treads\tmin_read_length\tmax_read_length\tmean_read_length\tgzip_status\tfastq_structure_status\n" > "${SUMMARY_FILE}"
printf "check\tstatus\tnotes\n" > "${STATUS_FILE}"

echo "Microbiome Analysis System: FASTQ QC Check"
echo

fastq_count=0
failed_count=0

for dir in ${RAW_DIRS}; do
  if [ ! -d "${dir}" ]; then
    echo "Directory not found: ${dir}"
    continue
  fi

  for file in "${dir}"/*.fastq.gz "${dir}"/*.fq.gz "${dir}"/*.fastq "${dir}"/*.fq; do
    [ -e "${file}" ] || continue

    fastq_count=$((fastq_count + 1))
    filename=$(basename "${file}")

    gzip_status="NOT_COMPRESSED"
    fastq_structure_status="UNKNOWN"

    if echo "${file}" | grep -Eq "\.(fastq|fq)\.gz$"; then
      if gzip -t "${file}" 2>/dev/null; then
        gzip_status="OK"
      else
        gzip_status="FAIL"
        failed_count=$((failed_count + 1))
      fi
      line_count=$(gzip -cd "${file}" | wc -l | tr -d ' ')
      read_stats=$(gzip -cd "${file}" | awk 'NR % 4 == 2 {
        len=length($0);
        count++;
        total+=len;
        if (min=="" || len < min) min=len;
        if (len > max) max=len;
      }
      END {
        if (count > 0) {
          printf "%d\t%d\t%.2f", min, max, total/count;
        } else {
          printf "0\t0\t0";
        }
      }')
    else
      line_count=$(wc -l < "${file}" | tr -d ' ')
      read_stats=$(awk 'NR % 4 == 2 {
        len=length($0);
        count++;
        total+=len;
        if (min=="" || len < min) min=len;
        if (len > max) max=len;
      }
      END {
        if (count > 0) {
          printf "%d\t%d\t%.2f", min, max, total/count;
        } else {
          printf "0\t0\t0";
        }
      }' "${file}")
    fi

    reads=$((line_count / 4))

    if [ $((line_count % 4)) -eq 0 ] && [ "${line_count}" -gt 0 ]; then
      fastq_structure_status="OK"
    else
      fastq_structure_status="FAIL"
      failed_count=$((failed_count + 1))
    fi

    min_len=$(echo "${read_stats}" | awk -F '\t' '{print $1}')
    max_len=$(echo "${read_stats}" | awk -F '\t' '{print $2}')
    mean_len=$(echo "${read_stats}" | awk -F '\t' '{print $3}')

    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
      "${filename}" "${dir}" "${line_count}" "${reads}" \
      "${min_len}" "${max_len}" "${mean_len}" \
      "${gzip_status}" "${fastq_structure_status}" >> "${SUMMARY_FILE}"

    echo "Checked: ${file}"
  done
done

if [ "${fastq_count}" -eq 0 ]; then
  printf "FASTQ presence\tFAIL\tNo FASTQ files found in expected raw data directories\n" >> "${STATUS_FILE}"
  echo
  echo "No FASTQ files found."
  exit 1
else
  printf "FASTQ presence\tOK\t%s FASTQ files found\n" "${fastq_count}" >> "${STATUS_FILE}"
fi

if [ "${failed_count}" -eq 0 ]; then
  printf "FASTQ file checks\tOK\tNo failed gzip or structure checks\n" >> "${STATUS_FILE}"
else
  printf "FASTQ file checks\tWARN\t%s failed checks detected\n" "${failed_count}" >> "${STATUS_FILE}"
fi

echo
echo "FASTQ files checked: ${fastq_count}"
echo "Failed checks: ${failed_count}"
echo
echo "Summary written to: ${SUMMARY_FILE}"
echo "Status written to:  ${STATUS_FILE}"
