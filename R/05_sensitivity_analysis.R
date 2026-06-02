# ============================================================
# 05_sensitivity_analysis.R
# Forest threshold, resampling, peat probability and independent comparison
# ============================================================

# Forest threshold sensitivity
if (!is.null(treecover2000)) {
  treecover_hansen <- terra::resample(treecover2000, lossyear, method = "near")
  thresholds <- c(10, 30, 50)

  sens <- data.frame(
    treecover2000_threshold = thresholds,
    baseline_forest_area_ha = NA_real_,
    recent_loss_area_ha = NA_real_,
    recent_loss_fraction = NA_real_,
    stringsAsFactors = FALSE
  )

  for (i in seq_along(thresholds)) {
    th <- thresholds[i]
    baseline <- make_mask(treecover_hansen >= th)
    recent_on_baseline <- make_mask((!is.na(baseline)) & (recent_loss == 1))
    base_area <- area_ha_from_mask(baseline, area_loss)
    recent_area <- area_ha_from_mask(recent_on_baseline, area_loss)

    sens$baseline_forest_area_ha[i] <- base_area
    sens$recent_loss_area_ha[i] <- recent_area
    sens$recent_loss_fraction[i] <- recent_area / base_area
  }

  write_csv_base(sens, file.path(outputs_dir, "sensitivity_forest_threshold_10_30_50.csv"))

} else {
  sens <- data.frame(
    status = "not_run",
    reason = "treecover2000_clip_landscape.tif was not available.",
    stringsAsFactors = FALSE
  )
  write_csv_base(sens, file.path(outputs_dir, "sensitivity_forest_threshold_10_30_50.csv"))
}

# Resampling sensitivity
default_ha <- area_ha_from_mask(make_mask((peat_hansen == 4) & (recent_loss == 1)), area_loss)
recent_loss_frac_100m <- terra::resample(recent_loss, peat_100m, method = "average")
recent_loss_near_100m <- terra::resample(recent_loss, peat_100m, method = "near")

any_recent_100m <- make_mask((peat_100m == 4) & (recent_loss_frac_100m > 0))
majority_recent_100m <- make_mask((peat_100m == 4) & (recent_loss_frac_100m >= 0.5))
near_recent_100m <- make_mask((peat_100m == 4) & (recent_loss_near_100m == 1))

resamp <- data.frame(
  method = c(
    "default_peat_to_hansen_nearest_30m",
    "peat_grid_100m_any_recent_loss_fraction_gt_0",
    "peat_grid_100m_majority_recent_loss_fraction_ge_0_5",
    "peat_grid_100m_nearest_recent_loss"
  ),
  recent_loss_on_peat_ha = c(
    default_ha,
    area_ha_from_mask(any_recent_100m, area_peat100),
    area_ha_from_mask(majority_recent_100m, area_peat100),
    area_ha_from_mask(near_recent_100m, area_peat100)
  ),
  stringsAsFactors = FALSE
)

resamp$difference_from_default_ha <- resamp$recent_loss_on_peat_ha - default_ha
resamp$ratio_to_default <- resamp$recent_loss_on_peat_ha / default_ha
write_csv_base(resamp, file.path(reviewer_dir, "resampling_sensitivity_recent_loss_on_peat.csv"))
print(resamp)

# Optional peat probability sensitivity
peat_prob_path <- Sys.getenv("PEAT_PROBABILITY_TIF", unset = "")

if (nzchar(peat_prob_path) && file.exists(peat_prob_path)) {
  peat_prob <- terra::rast(peat_prob_path)
  peat_prob_hansen <- terra::resample(peat_prob, loss_on_peat, method = "near")
  thresholds_prob <- c(0.50, 0.65, 0.80)

  prob_sens <- data.frame(
    peat_probability_threshold = thresholds_prob,
    recent_loss_on_peat_ha = NA_real_,
    stringsAsFactors = FALSE
  )

  for (i in seq_along(thresholds_prob)) {
    th <- thresholds_prob[i]
    prob_sens$recent_loss_on_peat_ha[i] <- area_ha_from_mask(
      make_mask((peat_prob_hansen >= th) & (recent_loss == 1)),
      area_loss
    )
  }

  prob_sens$status <- "completed"
  prob_sens$source <- peat_prob_path

} else {
  prob_sens <- data.frame(
    status = "not_run",
    source = peat_prob_path,
    reason = "PEAT_PROBABILITY_TIF was not set or the file was not found. The simplified class-4 peat map remains the default screening mask.",
    stringsAsFactors = FALSE
  )
}

write_csv_base(prob_sens, file.path(reviewer_dir, "peat_probability_threshold_sensitivity.csv"))

# Optional independent disturbance comparison
ind_path <- Sys.getenv("INDEPENDENT_LOSS_TIF", unset = "")

if (nzchar(ind_path) && file.exists(ind_path)) {
  ind <- terra::rast(ind_path)
  ind_hansen <- terra::resample(ind, loss_on_peat, method = "near")

  ind_bin <- make_mask(ind_hansen == 1)
  default_bin <- make_mask(loss_on_peat == 1)

  intersection_ha <- area_ha_from_mask(make_mask((!is.na(default_bin)) & (!is.na(ind_bin))), area_loss)
  default_area_ha <- area_ha_from_mask(default_bin, area_loss)
  independent_area_ha <- area_ha_from_mask(ind_bin, area_loss)
  union_ha <- area_ha_from_mask(make_mask((!is.na(default_bin)) | (!is.na(ind_bin))), area_loss)

  ind_comp <- data.frame(
    status = "completed",
    source = ind_path,
    default_loss_on_peat_ha = default_area_ha,
    independent_disturbance_ha = independent_area_ha,
    overlap_intersection_ha = intersection_ha,
    overlap_union_ha = union_ha,
    jaccard_overlap = intersection_ha / union_ha,
    percent_default_overlapping_independent = intersection_ha / default_area_ha,
    stringsAsFactors = FALSE
  )

} else {
  ind_comp <- data.frame(
    status = "not_run",
    source = ind_path,
    reason = "INDEPENDENT_LOSS_TIF was not set or the file was not found. This optional section can be used for GLAD/JRC/ESA/Sentinel-derived comparisons when a harmonized raster is available.",
    stringsAsFactors = FALSE
  )
}

write_csv_base(ind_comp, file.path(reviewer_dir, "independent_disturbance_comparison.csv"))
