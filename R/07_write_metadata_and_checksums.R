# ============================================================
# 07_write_metadata_and_checksums.R
# Metadata, QA checks, FAIR statement, data dictionary, checksums
# ============================================================

raster_list <- list(
  peat_100m_clip_landscape = peat_100m,
  lossyear_clip_landscape = lossyear,
  loss_on_peat_swamp_2015_2024_clip_landscape = loss_on_peat
)

if (!is.null(treecover2000)) raster_list$treecover2000_clip_landscape <- treecover2000

metadata <- do.call(rbind, lapply(names(raster_list), function(nm) {
  r <- raster_list[[nm]]
  e <- terra::ext(r)
  rs <- terra::res(r)

  data.frame(
    layer = nm,
    nrow = terra::nrow(r),
    ncol = terra::ncol(r),
    ncell = terra::ncell(r),
    crs = terra::crs(r),
    xmin = e[1], xmax = e[2], ymin = e[3], ymax = e[4],
    xres = rs[1], yres = rs[2],
    min_value = safe_global_min(r),
    max_value = safe_global_max(r),
    na_fraction = non_na_fraction(r),
    stringsAsFactors = FALSE
  )
}))

write_csv_base(metadata, file.path(reviewer_dir, "raster_metadata_expanded.csv"))
write_csv_base(metadata[, c("layer", "ncell", "na_fraction", "min_value", "max_value")],
               file.path(outputs_dir, "qa_raster_summary.csv"))

extent_vec <- function(r) c(xmin = terra::xmin(r), xmax = terra::xmax(r), ymin = terra::ymin(r), ymax = terra::ymax(r))

ref <- loss_on_peat
ref_res <- terra::res(ref)
ref_crs <- terra::crs(ref)
ref_ext_vec <- extent_vec(ref)

spatial_checks <- do.call(rbind, lapply(names(raster_list), function(nm) {
  r <- raster_list[[nm]]
  evec <- extent_vec(r)
  rs <- terra::res(r)

  data.frame(
    layer = nm,
    same_crs_as_loss_grid = identical(terra::crs(r), ref_crs),
    same_resolution_as_loss_grid = isTRUE(all.equal(as.numeric(rs), as.numeric(ref_res), tolerance = 1e-12)),
    same_extent_as_loss_grid = isTRUE(all.equal(as.numeric(evec), as.numeric(ref_ext_vec), tolerance = 1e-12)),
    xres = as.numeric(rs[1]), yres = as.numeric(rs[2]),
    xmin = as.numeric(evec["xmin"]), xmax = as.numeric(evec["xmax"]),
    ymin = as.numeric(evec["ymin"]), ymax = as.numeric(evec["ymax"]),
    stringsAsFactors = FALSE
  )
}))

write_csv_base(spatial_checks, file.path(reviewer_dir, "spatial_consistency_checks.csv"))

data_dictionary <- data.frame(
  file = c(
    "peat_100m_clip_landscape.tif", "lossyear_clip_landscape.tif", "treecover2000_clip_landscape.tif",
    "loss_on_peat_swamp_2015_2024_clip_landscape.tif", "validation_points_stratified_labeling_template.csv",
    "validation_points_stratified_labelled.csv", "confusion_matrix_unweighted_binary.csv",
    "confusion_matrix_area_weighted_binary.csv", "accuracy_metrics_binary_loss_on_peat.csv",
    "area_adjusted_estimates_binary_loss_on_peat.csv", "sensitivity_forest_threshold_10_30_50.csv",
    "resampling_sensitivity_recent_loss_on_peat.csv", "raster_metadata_expanded.csv", "spatial_consistency_checks.csv"
  ),
  description = c(
    "CongoPeat simplified peat/land-cover map clipped to the landscape buffer; class 4 is peat swamp forest.",
    "Hansen Global Forest Change lossyear raster clipped to the landscape buffer; values 1-24 represent 2001-2024.",
    "Hansen treecover2000 raster clipped to the landscape buffer; values represent percent canopy cover in 2000.",
    "Binary screening layer; 1 indicates CongoPeat class 4 overlapping Hansen lossyear 2015-2024.",
    "Expanded stratified validation template for manual interpretation.",
    "User-completed validation file after reference-image interpretation.",
    "Unweighted confusion matrix produced after labelled validation file is available.",
    "Area-weighted confusion matrix produced after labelled validation file is available.",
    "User accuracy, producer accuracy, and overall accuracy produced after labelled validation file is available.",
    "Area-adjusted estimate and 95 percent confidence interval for reference loss-on-peat area.",
    "Sensitivity of recent loss estimates to treecover2000 forest thresholds.",
    "Sensitivity of recent loss-on-peat area to raster-resolution and resampling choices.",
    "Machine-readable raster metadata including CRS, extent, resolution, value range, and missingness.",
    "Checks comparing each raster with the Hansen/loss grid for CRS, resolution, and extent."
  ),
  format = c("GeoTIFF", "GeoTIFF", "GeoTIFF", "GeoTIFF", rep("CSV", 10)),
  stringsAsFactors = FALSE
)

write_csv_base(data_dictionary, file.path(reviewer_dir, "data_dictionary.csv"))

workflow_steps <- data.frame(
  step = 1:10,
  action = c(
    "Detect data directory and create reviewer output folders.",
    "Load clipped CongoPeat, Hansen lossyear, and optional treecover rasters.",
    "Create or load recent loss-on-peat screening raster.",
    "Resample peat class layer to Hansen grid for overlay.",
    "Create expanded stratified validation sample with A, B, and C strata.",
    "Write manual validation template and validation map.",
    "If labelled validation file exists, compute accuracy and area-adjusted estimates.",
    "Generate annual loss summaries and forest-threshold sensitivity.",
    "Generate resampling sensitivity and optional independent/probability checks.",
    "Write QA metadata, FAIR statement, manifest, checksums, and session info."
  ),
  stringsAsFactors = FALSE
)

write_csv_base(workflow_steps, file.path(reviewer_dir, "workflow_steps.csv"))

fair_lines <- c(
  "FAIR support statement",
  "Findable: The data and code are deposited in Zenodo with persistent DOI identifiers. File names are descriptive and listed in the manifest.",
  "Accessible: Processed outputs are downloadable without restriction. WDPA geometry is not redistributed in the public archive; users should obtain WDPA inputs under the original Protected Planet terms.",
  "Interoperable: Raster outputs are GeoTIFF files and tabular outputs are CSV files. CRS, resolution, extent, and variable definitions are provided in machine-readable metadata.",
  "Reusable: The R workflow, data dictionary, file manifest, QA tables, validation template, and processing steps document provenance and intended use.",
  "Caution: Derived map areas should be interpreted as screening estimates unless validation-adjusted estimates are used."
)
write_text(fair_lines, file.path(reviewer_dir, "FAIR_statement.txt"))

repo_tree_lines <- c(
  "lac_tele_dib_public_revision/",
  "├── rasters/",
  "│   ├── peat_100m_clip_landscape.tif",
  "│   ├── lossyear_clip_landscape.tif",
  "│   ├── treecover2000_clip_landscape.tif",
  "│   └── loss_on_peat_swamp_2015_2024_clip_landscape.tif",
  "├── tables/",
  "│   ├── annual_loss_timeseries_2001_2024.csv",
  "│   ├── annual_loss_timeseries_2001_2024_LONG.csv",
  "│   ├── sensitivity_forest_threshold_10_30_50.csv",
  "│   └── summary_metrics_corrected.csv",
  "├── validation/",
  "│   ├── validation_points_stratified.csv",
  "│   ├── validation_points_stratified_labeling_template.csv",
  "│   ├── validation_points_stratified_labelled.csv",
  "│   ├── validation_point_counts.csv",
  "│   ├── validation_stratum_area_weights.csv",
  "│   ├── confusion_matrix_unweighted_binary.csv",
  "│   ├── confusion_matrix_area_weighted_binary.csv",
  "│   ├── accuracy_metrics_binary_loss_on_peat.csv",
  "│   └── area_adjusted_estimates_binary_loss_on_peat.csv",
  "├── figures/",
  "│   ├── S1_sensitivity_thresholds.png",
  "│   ├── S2_annual_loss_timeseries.png",
  "│   └── S6_validation_points_map_A100.png",
  "└── metadata/",
  "    ├── FAIR_statement.txt",
  "    ├── data_dictionary.csv",
  "    ├── workflow_steps.csv",
  "    ├── raster_metadata_expanded.csv",
  "    ├── spatial_consistency_checks.csv",
  "    ├── resampling_sensitivity_recent_loss_on_peat.csv",
  "    ├── peat_probability_threshold_sensitivity.csv",
  "    ├── independent_disturbance_comparison.csv",
  "    ├── file_manifest_with_checksums.csv",
  "    └── sessionInfo_reviewer_revision.txt"
)
write_text(repo_tree_lines, file.path(reviewer_dir, "repository_tree_clean_public_archive.txt"))

public_files <- unique(c(
  list.files(outputs_dir, recursive = TRUE, full.names = TRUE),
  file.path(data_dir, "summary_metrics_corrected.csv"),
  file.path(data_dir, "peat_100m_clip_landscape.tif"),
  file.path(data_dir, "lossyear_clip_landscape.tif"),
  file.path(data_dir, "treecover2000_clip_landscape.tif"),
  file.path(data_dir, "loss_on_peat_swamp_2015_2024_clip_landscape.tif")
))
public_files <- public_files[file.exists(public_files)]
public_files <- public_files[!grepl("Grant_submission|Paper For Submission|Other_papers|~\\$|\\.docx$|\\.pdf$", public_files)]
md5 <- tools::md5sum(public_files)
manifest <- data.frame(
  file = public_files,
  relative_path = sub(paste0("^", gsub("([\\\\.])", "\\\\\\1", data_dir), "/?"), "", public_files),
  size_bytes = file.info(public_files)$size,
  md5 = as.character(md5),
  stringsAsFactors = FALSE
)
write_csv_base(manifest, file.path(reviewer_dir, "file_manifest_with_checksums.csv"))

sink(file.path(reviewer_dir, "sessionInfo_reviewer_revision.txt"))
print(sessionInfo())
sink()
