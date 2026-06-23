###############################################################################
# Microbiome Analysis System
# 08b-plot-diversity-results.R
#
# Purpose:
#   Plot simple alpha diversity and beta diversity results.
#
# Usage:
#   Rscript scripts/R/08b-plot-diversity-results.R
###############################################################################

library(readr)
library(dplyr)
library(ggplot2)

diversity_dir <- "data/diversity"
figure_dir <- "figures"
table_dir <- "tables"

dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

alpha_file <- file.path(diversity_dir, "alpha-diversity.tsv")
ordination_file <- file.path(diversity_dir, "bray-curtis-pcoa.tsv")

if (!file.exists(alpha_file)) {
  stop(
    "Missing alpha diversity file: ",
    alpha_file,
    "\nRun: Rscript scripts/R/08a-calculate-diversity-metrics.R"
  )
}

if (!file.exists(ordination_file)) {
  stop(
    "Missing ordination file: ",
    ordination_file,
    "\nRun: Rscript scripts/R/08a-calculate-diversity-metrics.R"
  )
}

alpha <- read_tsv(alpha_file, show_col_types = FALSE)
ordination <- read_tsv(ordination_file, show_col_types = FALSE)

write_tsv(
  alpha,
  file.path(table_dir, "alpha-diversity-for-plot.tsv")
)

write_tsv(
  ordination,
  file.path(table_dir, "bray-curtis-pcoa-for-plot.tsv")
)

p_alpha <- ggplot(
  alpha,
  aes(
    x = sample_id,
    y = shannon_diversity
  )
) +
  geom_col() +
  labs(
    title = "Example Shannon Diversity",
    subtitle = "Toy MAS example data for workflow testing",
    x = "Sample",
    y = "Shannon diversity"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(
  filename = file.path(figure_dir, "alpha-shannon-diversity.png"),
  plot = p_alpha,
  width = 7,
  height = 5,
  dpi = 300
)

p_beta <- ggplot(
  ordination,
  aes(
    x = axis1,
    y = axis2,
    label = sample_id
  )
) +
  geom_point(size = 3) +
  geom_text(vjust = -0.8) +
  labs(
    title = "Example Bray-Curtis PCoA",
    subtitle = "Toy MAS example data for workflow testing",
    x = "PCoA axis 1",
    y = "PCoA axis 2"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  filename = file.path(figure_dir, "bray-curtis-pcoa.png"),
  plot = p_beta,
  width = 7,
  height = 5,
  dpi = 300
)

message("Created:")
message("  ", file.path(table_dir, "alpha-diversity-for-plot.tsv"))
message("  ", file.path(table_dir, "bray-curtis-pcoa-for-plot.tsv"))
message("  ", file.path(figure_dir, "alpha-shannon-diversity.png"))
message("  ", file.path(figure_dir, "bray-curtis-pcoa.png"))
