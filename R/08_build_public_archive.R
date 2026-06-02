# ============================================================
# 08_build_public_archive.R
# Build clean Zenodo dataset archive: outputs_all.zip
# ============================================================

if (dir.exists(public_archive_dir)) unlink(public_archive_dir, recursive = TRUE, force = TRUE)
dir.create(public_archive_dir, recursive = TRUE, showWarnings = FALSE)

archive_root <- file.path(public_archive_dir, "lac_tele_dib_public_revision")
dir.create(archive_root, recursive = TRUE, showWarnings = FALSE)
for (d in c("rasters", "tables", "validation", "figures", "metadata")) {
  dir.create(file.path(archive_root, d), recursive = TRUE, showWarnings = FALSE)
}

# Rasters
copy_if_exists(file.path(data_dir, "peat_100m_clip_landscape.tif"), file.path(archive_root, "rasters", "peat_100m_clip_landscape.tif"))
copy_if_exists(file.path(data_dir, "lossyear_clip_landscape.tif"), file.path(archive_root, "rasters", "lossyear_clip_landscape.tif"))
copy_if_exists(file.path(data_dir, "treecover2000_clip_landscape.tif"), file.path(archive_root, "rasters", "treecover2000_clip_landscape.tif"))
copy_if_exists(file.path(data_dir, "loss_on_peat_swamp_2015_2024_clip_landscape.tif"), file.path(archive_root, "rasters", "loss_on_peat_swamp_2015_2024_clip_landscape.tif"))

# Tables
for (f in c("annual_loss_timeseries_2001_2024.csv", "annual_loss_timeseries_2001_2024_LONG.csv", "sensitivity_forest_threshold_10_30_50.csv", "summary_metrics_corrected.csv", "peat_class_frequency.csv", "lossyear_value_frequency.csv", "qa_raster_summary.csv")) {
  copy_if_exists(file.path(outputs_dir, f), file.path(archive_root, "tables", f))
  copy_if_exists(file.path(data_dir, f), file.path(archive_root, "tables", f))
}

# Validation
copy_if_exists(file.path(outputs_dir, "validation_points_stratified.csv"), file.path(archive_root, "validation", "validation_points_stratified.csv"))
for (f in c("validation_points_stratified_labeling_template.csv", "validation_points_stratified_labelled.csv", "validation_point_counts.csv", "validation_stratum_area_weights.csv", "confusion_matrix_unweighted_binary.csv", "confusion_matrix_area_weighted_binary.csv", "accuracy_metrics_binary_loss_on_peat.csv", "area_adjusted_estimates_binary_loss_on_peat.csv", "accuracy_assessment_status.csv")) {
  copy_if_exists(file.path(reviewer_dir, f), file.path(archive_root, "validation", f))
}

# Figures
for (f in c("S1_sensitivity_thresholds.png", "S2_annual_loss_timeseries.png")) {
  copy_if_exists(file.path(fig_dir, f), file.path(archive_root, "figures", f))
}
copy_if_exists(file.path(reviewer_dir, "S6_validation_points_map_A100.png"), file.path(archive_root, "figures", "S6_validation_points_map_A100.png"))

# Metadata
for (f in c("FAIR_statement.txt", "data_dictionary.csv", "workflow_steps.csv", "raster_metadata_expanded.csv", "spatial_consistency_checks.csv", "resampling_sensitivity_recent_loss_on_peat.csv", "peat_probability_threshold_sensitivity.csv", "independent_disturbance_comparison.csv", "file_manifest_with_checksums.csv", "repository_tree_clean_public_archive.txt", "sessionInfo_reviewer_revision.txt")) {
  copy_if_exists(file.path(reviewer_dir, f), file.path(archive_root, "metadata", f))
}

copy_if_exists(file.path(repo_root, "README_dataset.txt"), file.path(archive_root, "README_dataset.txt"))

zip_path <- file.path(data_dir, "outputs_all.zip")
if (file.exists(zip_path)) unlink(zip_path)
old_wd <- getwd()
setwd(public_archive_dir)
utils::zip(zipfile = zip_path, files = "lac_tele_dib_public_revision")
setwd(old_wd)
message("Wrote Zenodo dataset ZIP: ", zip_path)
