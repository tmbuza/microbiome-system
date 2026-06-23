###############################################################################
# Microbiome Analysis System
# 08a-calculate-diversity-metrics.R
#
# Purpose:
#   Calculate simple alpha and beta diversity metrics from the example
#   feature table.
#
# Usage:
#   Rscript scripts/R/08a-calculate-diversity-metrics.R
###############################################################################

library(readr)
library(dplyr)
library(tidyr)
library(tibble)

feature_dir <- "data/features"
metadata_dir <- "data/metadata"
diversity_dir <- "data/diversity"
report_dir <- "data/reports"

dir.create(diversity_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

feature_table_file <- file.path(feature_dir, "feature-table.tsv")
sample_metadata_file <- file.path(metadata_dir, "sample-metadata.tsv")

if (!file.exists(feature_table_file)) {
  stop(
    "Missing feature table: ",
    feature_table_file,
    "\nRun: bash scripts/bash/06a-create-example-feature-table.sh"
  )
}

if (!file.exists(sample_metadata_file)) {
  stop(
    "Missing sample metadata: ",
    sample_metadata_file,
    "\nRun: bash scripts/bash/06a-create-example-feature-table.sh"
  )
}

feature_table <- read_tsv(feature_table_file, show_col_types = FALSE)
sample_metadata <- read_tsv(sample_metadata_file, show_col_types = FALSE)

feature_matrix <- feature_table %>%
  column_to_rownames("feature_id") %>%
  as.matrix()

sample_matrix <- t(feature_matrix)

shannon_index <- function(x) {
  total <- sum(x)
  if (total == 0) {
    return(0)
  }
  p <- x[x > 0] / total
  -sum(p * log(p))
}

alpha_diversity <- tibble(
  sample_id = rownames(sample_matrix),
  total_reads = rowSums(sample_matrix),
  observed_features = rowSums(sample_matrix > 0),
  shannon_diversity = apply(sample_matrix, 1, shannon_index)
) %>%
  left_join(sample_metadata, by = "sample_id")

write_tsv(
  alpha_diversity,
  file.path(diversity_dir, "alpha-diversity.tsv")
)

bray_curtis <- function(x, y) {
  numerator <- sum(abs(x - y))
  denominator <- sum(x + y)
  if (denominator == 0) {
    return(0)
  }
  numerator / denominator
}

sample_ids <- rownames(sample_matrix)
bray_matrix <- matrix(
  0,
  nrow = length(sample_ids),
  ncol = length(sample_ids),
  dimnames = list(sample_ids, sample_ids)
)

for (i in seq_along(sample_ids)) {
  for (j in seq_along(sample_ids)) {
    bray_matrix[i, j] <- bray_curtis(sample_matrix[i, ], sample_matrix[j, ])
  }
}

bray_table <- as.data.frame(bray_matrix) %>%
  rownames_to_column("sample_id")

write_tsv(
  bray_table,
  file.path(diversity_dir, "bray-curtis-distance-matrix.tsv")
)

pcoa <- cmdscale(as.dist(bray_matrix), k = 2, eig = TRUE)

ordination <- tibble(
  sample_id = rownames(pcoa$points),
  axis1 = pcoa$points[, 1],
  axis2 = pcoa$points[, 2]
) %>%
  left_join(sample_metadata, by = "sample_id")

write_tsv(
  ordination,
  file.path(diversity_dir, "bray-curtis-pcoa.tsv")
)

report <- tibble(
  metric = c(
    "sample_count",
    "feature_count",
    "alpha_metrics",
    "beta_metric",
    "ordination_method",
    "diversity_status"
  ),
  value = c(
    nrow(sample_matrix),
    ncol(sample_matrix),
    "observed_features; shannon_diversity",
    "Bray-Curtis",
    "PCoA using cmdscale",
    "READY_FOR_PLOTTING"
  )
)

write_tsv(
  report,
  file.path(report_dir, "diversity-analysis-report.tsv")
)

message("Created:")
message("  ", file.path(diversity_dir, "alpha-diversity.tsv"))
message("  ", file.path(diversity_dir, "bray-curtis-distance-matrix.tsv"))
message("  ", file.path(diversity_dir, "bray-curtis-pcoa.tsv"))
message("  ", file.path(report_dir, "diversity-analysis-report.tsv"))
