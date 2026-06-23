###############################################################################
# Microbiome Analysis System
# 10a-run-example-differential-analysis.R
#
# Purpose:
#   Run a lightweight example differential analysis on the toy feature table.
#
# Important:
#   This is a workflow demonstration only. It is not a recommended statistical
#   method for real microbiome differential abundance analysis.
#
# Usage:
#   Rscript scripts/R/10a-run-example-differential-analysis.R
###############################################################################

library(readr)
library(dplyr)
library(tidyr)
library(tibble)

feature_dir <- "data/features"
metadata_dir <- "data/metadata"
diff_dir <- "data/differential"
report_dir <- "data/reports"

dir.create(diff_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

feature_table_file <- file.path(feature_dir, "feature-table.tsv")
feature_metadata_file <- file.path(feature_dir, "feature-metadata.tsv")
sample_metadata_file <- file.path(metadata_dir, "sample-metadata.tsv")

if (!file.exists(feature_table_file)) {
  stop(
    "Missing feature table: ",
    feature_table_file,
    "\nRun: bash scripts/bash/06a-create-example-feature-table.sh"
  )
}

if (!file.exists(feature_metadata_file)) {
  stop(
    "Missing feature metadata: ",
    feature_metadata_file,
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
feature_metadata <- read_tsv(feature_metadata_file, show_col_types = FALSE)
sample_metadata <- read_tsv(sample_metadata_file, show_col_types = FALSE)

comparison_metadata <- sample_metadata %>%
  mutate(
    comparison_group = case_when(
      sample_id %in% c("SRR17868090", "SRR17868091") ~ "Group_A",
      sample_id %in% c("SRR17868092") ~ "Group_B",
      TRUE ~ "Unassigned"
    )
  )

write_tsv(
  comparison_metadata,
  file.path(metadata_dir, "sample-metadata-with-comparison.tsv")
)

feature_long <- feature_table %>%
  pivot_longer(
    cols = -feature_id,
    names_to = "sample_id",
    values_to = "count"
  ) %>%
  left_join(comparison_metadata, by = "sample_id") %>%
  left_join(feature_metadata, by = "feature_id")

pseudocount <- 1

group_summary <- feature_long %>%
  group_by(feature_id, comparison_group) %>%
  summarise(
    mean_count = mean(count),
    median_count = median(count),
    total_count = sum(count),
    sample_count = n(),
    .groups = "drop"
  )

wide_summary <- group_summary %>%
  select(feature_id, comparison_group, mean_count) %>%
  pivot_wider(
    names_from = comparison_group,
    values_from = mean_count
  )

results <- wide_summary %>%
  mutate(
    Group_A = ifelse(is.na(Group_A), 0, Group_A),
    Group_B = ifelse(is.na(Group_B), 0, Group_B),
    log2_fold_change = log2((Group_B + pseudocount) / (Group_A + pseudocount))
  ) %>%
  left_join(feature_metadata, by = "feature_id")

toy_p_values <- feature_long %>%
  group_by(feature_id) %>%
  summarise(
    p_value = {
      values_a <- count[comparison_group == "Group_A"]
      values_b <- count[comparison_group == "Group_B"]
      if (length(values_a) >= 2 && length(values_b) >= 2) {
        t.test(values_b, values_a)$p.value
      } else {
        NA_real_
      }
    },
    .groups = "drop"
  ) %>%
  mutate(
    adjusted_p_value = p.adjust(p_value, method = "BH")
  )

results <- results %>%
  left_join(toy_p_values, by = "feature_id") %>%
  mutate(
    direction = case_when(
      log2_fold_change > 0 ~ "Higher_in_Group_B",
      log2_fold_change < 0 ~ "Higher_in_Group_A",
      TRUE ~ "No_change"
    ),
    interpretation_status = "toy_result_do_not_interpret_biologically"
  ) %>%
  select(
    feature_id,
    taxonomy,
    Group_A,
    Group_B,
    log2_fold_change,
    p_value,
    adjusted_p_value,
    direction,
    confidence,
    interpretation_status
  )

write_tsv(
  results,
  file.path(diff_dir, "example-differential-results.tsv")
)

report <- tibble(
  metric = c(
    "comparison",
    "feature_count",
    "method",
    "pseudocount",
    "status",
    "interpretation_warning"
  ),
  value = c(
    "Group_B vs Group_A",
    nrow(results),
    "toy mean-count log2 fold change",
    pseudocount,
    "READY_FOR_PLOTTING",
    "Toy data; not suitable for biological interpretation"
  )
)

write_tsv(
  report,
  file.path(report_dir, "differential-analysis-report.tsv")
)

message("Created:")
message("  ", file.path(metadata_dir, "sample-metadata-with-comparison.tsv"))
message("  ", file.path(diff_dir, "example-differential-results.tsv"))
message("  ", file.path(report_dir, "differential-analysis-report.tsv"))
