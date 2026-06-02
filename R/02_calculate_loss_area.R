# ============================================================
# 02_calculate_loss_area.R
# Annual and summary area calculations
# ============================================================

years <- 2001:2024
loss_codes <- 1:24

annual <- data.frame(
  year = years,
  lossyear_code = loss_codes,
  loss_on_peat_ha = NA_real_,
  loss_any_ha = NA_real_,
  stringsAsFactors = FALSE
)

for (i in seq_along(loss_codes)) {
  code <- loss_codes[i]
  annual$loss_any_ha[i] <- area_ha_from_mask(make_mask(lossyear == code), area_loss)
  annual$loss_on_peat_ha[i] <- area_ha_from_mask(make_mask((peat_hansen == 4) & (lossyear == code)), area_loss)
}

write_csv_base(annual, file.path(outputs_dir, "annual_loss_timeseries_2001_2024.csv"))

annual_long <- rbind(
  data.frame(year = annual$year, metric = "loss_any_ha", value_ha = annual$loss_any_ha),
  data.frame(year = annual$year, metric = "loss_on_peat_ha", value_ha = annual$loss_on_peat_ha)
)
write_csv_base(annual_long, file.path(outputs_dir, "annual_loss_timeseries_2001_2024_LONG.csv"))

summary_metrics <- data.frame(
  metric = c(
    "peat_swamp_forest_area_ha_class4_resampled_to_hansen_grid",
    "recent_loss_on_peat_2015_2024_ha_default",
    "any_loss_2001_2024_ha",
    "recent_any_loss_2015_2024_ha"
  ),
  value = c(
    area_ha_from_mask(make_mask(peat_hansen == 4), area_loss),
    area_ha_from_mask(make_mask(loss_on_peat == 1), area_loss),
    area_ha_from_mask(make_mask((lossyear >= 1) & (lossyear <= 24)), area_loss),
    area_ha_from_mask(make_mask((lossyear >= recent_loss_start_code) & (lossyear <= recent_loss_end_code)), area_loss)
  ),
  unit = "ha",
  notes = c(
    "CongoPeat simplified class 4 after nearest-neighbour resampling to Hansen grid.",
    "Mapped screening estimate; use validation-adjusted estimates for quantitative claims.",
    "All Hansen lossyear cells coded 1 to 24.",
    "Hansen lossyear cells coded 15 to 24."
  ),
  stringsAsFactors = FALSE
)

write_csv_base(summary_metrics, file.path(data_dir, "summary_metrics_corrected.csv"))
write_csv_base(summary_metrics, file.path(outputs_dir, "summary_metrics_corrected.csv"))
print(summary_metrics)

peat_freq <- as.data.frame(terra::freq(peat_100m))
if ("value" %in% names(peat_freq)) peat_freq <- peat_freq[!is.na(peat_freq$value), , drop = FALSE]
write_csv_base(peat_freq, file.path(outputs_dir, "peat_class_frequency.csv"))

loss_freq <- as.data.frame(terra::freq(lossyear))
if ("value" %in% names(loss_freq)) loss_freq <- loss_freq[!is.na(loss_freq$value), , drop = FALSE]
write_csv_base(loss_freq, file.path(outputs_dir, "lossyear_value_frequency.csv"))
