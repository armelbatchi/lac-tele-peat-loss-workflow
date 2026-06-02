# ============================================================
# 03_generate_validation_points.R
# Expanded stratified validation points
# ============================================================

set.seed(20260523)

stratum_A <- make_mask(loss_on_peat == 1)
stratum_B <- make_mask((peat_hansen == 4) & (loss_on_peat != 1))
stratum_C <- make_mask((peat_hansen != 4) & (!is.na(peat_hansen)))

stratum_area_weights <- data.frame(
  stratum = c("A_loss_on_peat_2015_2024", "B_peat_no_recent_loss", "C_non_peat_background"),
  available_cells = c(
    available_cells_from_mask(stratum_A),
    available_cells_from_mask(stratum_B),
    available_cells_from_mask(stratum_C)
  ),
  map_area_ha = c(
    area_ha_from_mask(stratum_A, area_hansen),
    area_ha_from_mask(stratum_B, area_hansen),
    area_ha_from_mask(stratum_C, area_hansen)
  ),
  stringsAsFactors = FALSE
)

stratum_area_weights$area_weight <- stratum_area_weights$map_area_ha /
  sum(stratum_area_weights$map_area_ha, na.rm = TRUE)

write_csv_base(stratum_area_weights, file.path(reviewer_dir, "validation_stratum_area_weights.csv"))
print(stratum_area_weights)

points_A <- sample_points_from_mask(stratum_A, n_validation_per_stratum, "A_loss_on_peat_2015_2024", seed = 101)
points_B <- sample_points_from_mask(stratum_B, n_validation_per_stratum, "B_peat_no_recent_loss", seed = 102)
points_C <- sample_points_from_mask(stratum_C, n_validation_per_stratum, "C_non_peat_background", seed = 103)

validation_points <- rbind(points_A, points_B, points_C)
validation_counts <- as.data.frame(table(validation_points$stratum), stringsAsFactors = FALSE)
names(validation_counts) <- c("stratum", "n_points")

template_path <- file.path(reviewer_dir, "validation_points_stratified_labeling_template.csv")
write_csv_base(validation_points, template_path)
write_csv_base(validation_points, file.path(outputs_dir, "validation_points_stratified.csv"))
write_csv_base(validation_counts, file.path(reviewer_dir, "validation_point_counts.csv"))

if (any(validation_counts$n_points < n_validation_per_stratum)) {
  warning("At least one stratum has fewer than requested points. Check validation_point_counts.csv.")
}

print(validation_counts)
