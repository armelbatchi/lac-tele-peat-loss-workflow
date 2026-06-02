# ============================================================
# 04_manual_validation_summary.R
# Accuracy assessment from manually labelled validation points
# ============================================================

labelled_path <- file.path(reviewer_dir, "validation_points_stratified_labelled.csv")
template_path <- file.path(reviewer_dir, "validation_points_stratified_labeling_template.csv")
allowed_reference_values <- c("reference_loss_on_peat", "reference_not_loss_on_peat")

label_file_ready <- function(path) {
  if (!file.exists(path)) return(FALSE)
  x <- try(utils::read.csv(path, stringsAsFactors = FALSE), silent = TRUE)
  if (inherits(x, "try-error")) return(FALSE)
  if (!("reference_class_binary" %in% names(x))) return(FALSE)
  sum(x$reference_class_binary %in% allowed_reference_values, na.rm = TRUE) > 0
}

if (!file.exists(labelled_path) && label_file_ready(template_path)) {
  file.copy(template_path, labelled_path, overwrite = TRUE)
  message("Detected labels in template and copied to: ", labelled_path)
}

compute_accuracy <- function(labelled, weights) {
  labelled <- labelled[
    !is.na(labelled$reference_class_binary) &
      labelled$reference_class_binary != "" &
      labelled$reference_class_binary %in% allowed_reference_values,
  ]

  if (nrow(labelled) == 0) stop("No valid labelled points found.")

  labelled$predicted_class_binary <- ifelse(
    grepl("^A_", labelled$stratum),
    "predicted_loss_on_peat",
    "predicted_not_loss_on_peat"
  )

  pred_levels <- c("predicted_loss_on_peat", "predicted_not_loss_on_peat")
  ref_levels <- c("reference_loss_on_peat", "reference_not_loss_on_peat")

  unweighted <- table(
    factor(labelled$predicted_class_binary, levels = pred_levels),
    factor(labelled$reference_class_binary, levels = ref_levels)
  )

  unweighted_df <- as.data.frame.matrix(unweighted)
  unweighted_df$predicted_class <- rownames(unweighted_df)
  unweighted_df <- unweighted_df[, c("predicted_class", ref_levels)]

  area_conf <- matrix(
    0,
    nrow = length(pred_levels),
    ncol = length(ref_levels),
    dimnames = list(pred_levels, ref_levels)
  )

  for (h in unique(labelled$stratum)) {
    lh <- labelled[labelled$stratum == h, ]
    wh_area <- weights$map_area_ha[match(h, weights$stratum)]
    if (is.na(wh_area) || nrow(lh) == 0) next

    pred_h <- ifelse(grepl("^A_", h), "predicted_loss_on_peat", "predicted_not_loss_on_peat")
    props <- prop.table(table(factor(lh$reference_class_binary, levels = ref_levels)))

    for (r in ref_levels) {
      area_conf[pred_h, r] <- area_conf[pred_h, r] + wh_area * as.numeric(props[r])
    }
  }

  area_conf_df <- as.data.frame.matrix(area_conf)
  area_conf_df$predicted_class <- rownames(area_conf_df)
  area_conf_df <- area_conf_df[, c("predicted_class", ref_levels)]

  total_area <- sum(area_conf, na.rm = TRUE)
  overall_accuracy <- sum(diag(area_conf), na.rm = TRUE) / total_area
  user_accuracy <- diag(area_conf) / rowSums(area_conf)
  producer_accuracy <- diag(area_conf) / colSums(area_conf)

  accuracy_metrics <- data.frame(
    metric = c(
      "overall_accuracy_area_adjusted",
      paste0("user_accuracy_", names(user_accuracy)),
      paste0("producer_accuracy_", names(producer_accuracy))
    ),
    estimate = c(overall_accuracy, as.numeric(user_accuracy), as.numeric(producer_accuracy)),
    stringsAsFactors = FALSE
  )

  total_map_area <- sum(weights$map_area_ha, na.rm = TRUE)
  var_prop <- 0
  est_prop <- 0

  for (i in seq_len(nrow(weights))) {
    h <- weights$stratum[i]
    Ah <- weights$map_area_ha[i]
    Wh <- Ah / total_map_area
    lh <- labelled[labelled$stratum == h, ]
    nh <- nrow(lh)
    if (nh == 0) next

    ph <- mean(lh$reference_class_binary == "reference_loss_on_peat")
    est_prop <- est_prop + Wh * ph

    if (nh > 1) {
      var_prop <- var_prop + (Wh^2) * ph * (1 - ph) / (nh - 1)
    }
  }

  area_est <- total_map_area * est_prop
  area_se <- total_map_area * sqrt(var_prop)
  area_ci_low <- max(0, area_est - 1.96 * area_se)
  area_ci_high <- area_est + 1.96 * area_se

  area_adjusted <- data.frame(
    estimand = "reference_loss_on_peat_area_ha",
    estimate_ha = area_est,
    se_ha = area_se,
    ci95_low_ha = area_ci_low,
    ci95_high_ha = area_ci_high,
    total_sampled_strata_area_ha = total_map_area,
    stringsAsFactors = FALSE
  )

  list(
    unweighted_df = unweighted_df,
    area_conf_df = area_conf_df,
    accuracy_metrics = accuracy_metrics,
    area_adjusted = area_adjusted,
    n_labelled = nrow(labelled)
  )
}

if (label_file_ready(labelled_path)) {
  labelled <- utils::read.csv(labelled_path, stringsAsFactors = FALSE)

  needed_cols <- c("stratum", "reference_class_binary")
  if (!all(needed_cols %in% names(labelled))) {
    stop("Labelled validation file must contain columns: ", paste(needed_cols, collapse = ", "))
  }

  acc <- compute_accuracy(labelled, stratum_area_weights)

  write_csv_base(acc$unweighted_df, file.path(reviewer_dir, "confusion_matrix_unweighted_binary.csv"))
  write_csv_base(acc$area_conf_df, file.path(reviewer_dir, "confusion_matrix_area_weighted_binary.csv"))
  write_csv_base(acc$accuracy_metrics, file.path(reviewer_dir, "accuracy_metrics_binary_loss_on_peat.csv"))
  write_csv_base(acc$area_adjusted, file.path(reviewer_dir, "area_adjusted_estimates_binary_loss_on_peat.csv"))

  status <- data.frame(
    accuracy_assessment_status = "completed",
    labelled_file = labelled_path,
    n_labelled_points = acc$n_labelled,
    notes = "Accuracy metrics were computed from manually labelled validation points.",
    stringsAsFactors = FALSE
  )
  write_csv_base(status, file.path(reviewer_dir, "accuracy_assessment_status.csv"))

  print(acc$accuracy_metrics)
  print(acc$area_adjusted)

} else {
  status <- data.frame(
    accuracy_assessment_status = "not_run",
    labelled_file = labelled_path,
    n_labelled_points = 0,
    notes = paste(
      "Manual reference labels were not available.",
      "Fill validation_points_stratified_labeling_template.csv and save it as validation_points_stratified_labelled.csv, then rerun."
    ),
    stringsAsFactors = FALSE
  )

  write_csv_base(status, file.path(reviewer_dir, "accuracy_assessment_status.csv"))

  message("Accuracy assessment not run yet.")
  message("Fill: ", template_path)
  message("Save as: ", labelled_path)
}
