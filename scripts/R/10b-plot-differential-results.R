###############################################################################
# Microbiome Analysis System
# 10b-plot-differential-results.R
#
# Purpose:
#   Plot toy differential analysis results.
#
# Usage:
#   Rscript scripts/R/10b-plot-differential-results.R
###############################################################################

library(readr)
library(dplyr)
library(ggplot2)
library(stringr)

diff_dir <- "data/differential"
figure_dir <- "figures"
table_dir <- "tables"

dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

results_file <- file.path(diff_dir, "example-differential-results.tsv")

if (!file.exists(results_file)) {
  stop(
    "Missing differential results file: ",
    results_file,
    "\nRun: Rscript scripts/R/10a-run-example-differential-analysis.R"
  )
}

results <- read_tsv(results_file, show_col_types = FALSE) %>%
  mutate(
    genus = str_extract(taxonomy, "[^;]+$"),
    genus = str_trim(genus),
    plot_p_value = ifelse(is.na(p_value), 1, p_value),
    neg_log10_p = -log10(plot_p_value)
  )

write_tsv(
  results,
  file.path(table_dir, "example-differential-results-for-plot.tsv")
)

p_volcano <- ggplot(
  results,
  aes(
    x = log2_fold_change,
    y = neg_log10_p,
    label = genus
  )
) +
  geom_point(size = 3) +
  geom_text(vjust = -0.8) +
  labs(
    title = "Example Differential Analysis Results",
    subtitle = "Toy MAS data for workflow testing only",
    x = "Log2 fold change: Group_B vs Group_A",
    y = "-log10(p-value)"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(figure_dir, "example-differential-volcano.png"),
  plot = p_volcano,
  width = 7,
  height = 5,
  dpi = 300
)

top_results <- results %>%
  arrange(desc(abs(log2_fold_change))) %>%
  slice_head(n = 10) %>%
  mutate(
    genus = factor(genus, levels = genus[order(log2_fold_change)])
  )

p_bar <- ggplot(
  top_results,
  aes(
    x = genus,
    y = log2_fold_change
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top Example Log2 Fold Changes",
    subtitle = "Toy MAS data for workflow testing only",
    x = "Feature genus label",
    y = "Log2 fold change"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(figure_dir, "example-differential-log2fc.png"),
  plot = p_bar,
  width = 7,
  height = 5,
  dpi = 300
)

message("Created:")
message("  ", file.path(table_dir, "example-differential-results-for-plot.tsv"))
message("  ", file.path(figure_dir, "example-differential-volcano.png"))
message("  ", file.path(figure_dir, "example-differential-log2fc.png"))
