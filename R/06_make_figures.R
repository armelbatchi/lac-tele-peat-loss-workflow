# ============================================================
# 06_make_figures.R
# Publication and supplementary figures
# ============================================================

# S1. Forest-threshold sensitivity
sens_path <- file.path(outputs_dir, "sensitivity_forest_threshold_10_30_50.csv")
if (file.exists(sens_path)) {
  sens_plot <- utils::read.csv(sens_path, stringsAsFactors = FALSE)

  if (all(c("treecover2000_threshold", "baseline_forest_area_ha", "recent_loss_fraction") %in% names(sens_plot))) {
    png(file.path(fig_dir, "S1_sensitivity_thresholds.png"), width = 1600, height = 1000, res = 170)
    oldpar <- par(mfrow = c(2, 1), mar = c(4, 5, 3, 1))

    plot(
      sens_plot$treecover2000_threshold,
      sens_plot$baseline_forest_area_ha,
      type = "o",
      pch = 19,
      xlab = "Treecover2000 threshold (%)",
      ylab = "Baseline forest area (ha)",
      main = "Sensitivity to forest definition"
    )

    plot(
      sens_plot$treecover2000_threshold,
      100 * sens_plot$recent_loss_fraction,
      type = "o",
      pch = 19,
      xlab = "Treecover2000 threshold (%)",
      ylab = "Recent loss fraction (%)",
      main = "Percent forest lost during 2015 to 2024"
    )

    par(oldpar)
    dev.off()
  }
}

# S2. Annual loss time series
annual_path <- file.path(outputs_dir, "annual_loss_timeseries_2001_2024.csv")
if (file.exists(annual_path)) {
  annual_plot <- utils::read.csv(annual_path, stringsAsFactors = FALSE)

  png(file.path(fig_dir, "S2_annual_loss_timeseries.png"), width = 1800, height = 1000, res = 170)
  plot(
    annual_plot$year,
    annual_plot$loss_any_ha,
    type = "o",
    pch = 19,
    xlab = "Year",
    ylab = "Annual mapped loss (ha)",
    main = "Annual loss time series, 2001 to 2024"
  )
  lines(annual_plot$year, annual_plot$loss_on_peat_ha, type = "o", pch = 19)
  abline(v = recent_loss_start_year, lty = 2)
  legend("topleft", legend = c("Any mapped loss", "Loss on peat swamp forest"), lty = 1, pch = 19, bty = "n")
  dev.off()
}

# S6. Stratified validation points map
if (exists("validation_points") && exists("validation_counts")) {
  png(file.path(reviewer_dir, "S6_validation_points_map_A100.png"), width = 1800, height = 1400, res = 170)

  ext_h <- terra::ext(loss_on_peat)
  plot(
    NA,
    xlim = c(ext_h[1], ext_h[2]),
    ylim = c(ext_h[3], ext_h[4]),
    xlab = "Longitude",
    ylab = "Latitude",
    main = "Stratified validation points",
    sub = "Points sampled across strata for reproducible manual interpretation"
  )
  grid()

  cols <- c(
    A_loss_on_peat_2015_2024 = "#0072B2",
    B_peat_no_recent_loss = "#D55E00",
    C_non_peat_background = "#009E73"
  )

  for (st in names(cols)) {
    p <- validation_points[validation_points$stratum == st, ]
    points(p$lon, p$lat, pch = 19, cex = 0.65, col = cols[st])
  }

  legend(
    "bottomleft",
    legend = paste0(
      c("A: loss on peat 2015 to 2024", "B: peat no recent loss", "C: non peat background"),
      " (n=",
      as.integer(validation_counts$n_points[match(names(cols), validation_counts$stratum)]),
      ")"
    ),
    col = cols,
    pch = 19,
    bty = "n",
    cex = 0.85
  )

  dev.off()
}
