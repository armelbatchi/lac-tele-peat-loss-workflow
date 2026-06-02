# ============================================================
# Lac Tele peat-swamp forest loss workflow
# Main runner
# ============================================================

source("R/00_config.R")
source("R/00_helpers.R")
source("R/01_prepare_spatial_layers.R")
source("R/02_calculate_loss_area.R")
source("R/03_generate_validation_points.R")
source("R/04_manual_validation_summary.R")
source("R/05_sensitivity_analysis.R")
source("R/06_make_figures.R")
source("R/07_write_metadata_and_checksums.R")
source("R/08_build_public_archive.R")

cat("\nWorkflow completed.\n")
cat("Main output folder: ", outputs_dir, "\n", sep = "")
cat("Reviewer output folder: ", reviewer_dir, "\n", sep = "")
cat("Zenodo dataset ZIP, if created: ", file.path(data_dir, "outputs_all.zip"), "\n", sep = "")
