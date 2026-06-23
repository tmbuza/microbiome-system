###############################################################################
# Microbiome Analysis System
# 07b-plot-taxonomic-profile.R
#
# Purpose:
#   Plot a simple genus-level relative abundance profile.
#
# Usage:
#   Rscript scripts/R/07b-plot-taxonomic-profile.R
###############################################################################

library(readr)
library(dplyr)
library(ggplot2)
library(stringr)

taxonomy_dir <- "data/taxonomy"
figure_dir <- "figures"
table_dir <- "tables"

dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

rel_abund_file <- file.path(taxonomy_dir, "genus-relative-abundance.tsv")

if (!file.exists(rel_abund_file)) {
  stop(
    "Missing genus relative abundance file: ",
    rel_abund_file,
    "\nRun: bash scripts/bash/07a-build-taxonomic-profile.sh"
  )
}

taxa <- read_tsv(rel_abund_file, show_col_types = FALSE)

taxa_plot <- taxa %>%
  mutate(
    relative_abundance_percent = relative_abundance * 100,
    genus = str_replace_all(genus, "_", " ")
  )

write_tsv(
  taxa_plot,
  file.path(table_dir, "genus-relative-abundance-for-plot.tsv")
)

p <- ggplot(
  taxa_plot,
  aes(
    x = sample_id,
    y = relative_abundance_percent,
    fill = genus
  )
) +
  geom_col() +
  labs(
    title = "Example Genus-Level Taxonomic Profile",
    subtitle = "Toy MAS example data for workflow testing",
    x = "Sample",
    y = "Relative abundance (%)",
    fill = "Genus"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(
  filename = file.path(figure_dir, "genus-relative-abundance-profile.png"),
  plot = p,
  width = 8,
  height = 5,
  dpi = 300
)

message("Created:")
message("  ", file.path(table_dir, "genus-relative-abundance-for-plot.tsv"))
message("  ", file.path(figure_dir, "genus-relative-abundance-profile.png"))
