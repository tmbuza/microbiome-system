###############################################################################
# Microbiome Analysis System
# 09b-plot-functional-profile.R
#
# Purpose:
#   Plot a simple pathway-level functional profile.
#
# Usage:
#   Rscript scripts/R/09b-plot-functional-profile.R
###############################################################################

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

function_dir <- "data/function"
figure_dir <- "figures"
table_dir <- "tables"

dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

pathway_file <- file.path(function_dir, "pathway-abundance.tsv")
metadata_file <- file.path(function_dir, "pathway-metadata.tsv")

if (!file.exists(pathway_file)) {
  stop(
    "Missing pathway abundance file: ",
    pathway_file,
    "\nRun: bash scripts/bash/09a-create-example-functional-profile.sh"
  )
}

if (!file.exists(metadata_file)) {
  stop(
    "Missing pathway metadata file: ",
    metadata_file,
    "\nRun: bash scripts/bash/09a-create-example-functional-profile.sh"
  )
}

pathways <- read_tsv(pathway_file, show_col_types = FALSE)
pathway_metadata <- read_tsv(metadata_file, show_col_types = FALSE)

pathway_long <- pathways %>%
  pivot_longer(
    cols = -pathway_id,
    names_to = "sample_id",
    values_to = "abundance"
  ) %>%
  left_join(pathway_metadata, by = "pathway_id") %>%
  group_by(sample_id) %>%
  mutate(
    relative_abundance = abundance / sum(abundance),
    relative_abundance_percent = relative_abundance * 100
  ) %>%
  ungroup()

write_tsv(
  pathway_long,
  file.path(table_dir, "pathway-relative-abundance-for-plot.tsv")
)

p <- ggplot(
  pathway_long,
  aes(
    x = sample_id,
    y = relative_abundance_percent,
    fill = pathway_name
  )
) +
  geom_col() +
  labs(
    title = "Example Functional Profile",
    subtitle = "Toy MAS pathway abundance data for workflow testing",
    x = "Sample",
    y = "Relative abundance (%)",
    fill = "Pathway"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(
  filename = file.path(figure_dir, "pathway-relative-abundance-profile.png"),
  plot = p,
  width = 8,
  height = 5,
  dpi = 300
)

message("Created:")
message("  ", file.path(table_dir, "pathway-relative-abundance-for-plot.tsv"))
message("  ", file.path(figure_dir, "pathway-relative-abundance-profile.png"))
