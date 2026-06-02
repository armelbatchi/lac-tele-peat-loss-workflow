# ============================================================
# 00_helpers.R
# Helper functions
# ============================================================

if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra", repos = "https://cloud.r-project.org")
}
library(terra)

find_file <- function(root, filename) {
  direct <- file.path(root, filename)
  if (file.exists(direct)) return(normalizePath(direct, winslash = "/", mustWork = TRUE))

  hits <- list.files(root, pattern = paste0("^", gsub("\\.", "\\\\.", filename), "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) > 0) return(normalizePath(hits[1], winslash = "/", mustWork = TRUE))

  NA_character_
}

safe_global_sum <- function(r) {
  x <- try(terra::global(r, "sum", na.rm = TRUE)[1, 1], silent = TRUE)
  if (inherits(x, "try-error") || is.na(x)) return(NA_real_)
  as.numeric(x)
}

safe_global_min <- function(r) {
  x <- try(terra::global(r, "min", na.rm = TRUE)[1, 1], silent = TRUE)
  if (inherits(x, "try-error") || is.na(x)) return(NA_real_)
  as.numeric(x)
}

safe_global_max <- function(r) {
  x <- try(terra::global(r, "max", na.rm = TRUE)[1, 1], silent = TRUE)
  if (inherits(x, "try-error") || is.na(x)) return(NA_real_)
  as.numeric(x)
}

non_na_fraction <- function(r) {
  n_total <- terra::ncell(r)
  n_missing <- safe_global_sum(is.na(r))
  if (is.na(n_missing)) return(NA_real_)
  n_missing / n_total
}

make_mask <- function(condition_r) {
  terra::ifel(condition_r, 1, NA)
}

area_ha_from_mask <- function(mask_r, area_r = NULL) {
  if (is.null(area_r)) area_r <- terra::cellSize(mask_r, unit = "ha")
  m <- mask_r * area_r
  safe_global_sum(m)
}

available_cells_from_mask <- function(mask_r) {
  m <- terra::ifel(is.na(mask_r), 0, 1)
  safe_global_sum(m)
}

sample_points_from_mask <- function(mask_r, n_target, stratum_label, seed = 1) {
  set.seed(seed)

  vals <- terra::values(mask_r, mat = FALSE)
  candidate_cells <- which(!is.na(vals))
  n_available <- length(candidate_cells)

  message(stratum_label, ": available cells = ", n_available)

  if (is.na(n_available) || n_available == 0) {
    stop("No available cells for stratum: ", stratum_label)
  }

  n_use <- min(as.integer(n_target), as.integer(n_available))

  if (n_use < n_target) {
    warning("Only ", n_use, " cells available for ", stratum_label, "; requested ", n_target)
  }

  sampled_cells <- sample(candidate_cells, size = n_use, replace = FALSE)
  xy <- terra::xyFromCell(mask_r, sampled_cells)

  out <- data.frame(
    point_id = sprintf("%s_%03d", stratum_label, seq_len(n_use)),
    stratum = stratum_label,
    predicted_class_binary = ifelse(
      grepl("^A_", stratum_label),
      "predicted_loss_on_peat",
      "predicted_not_loss_on_peat"
    ),
    cell = as.integer(sampled_cells),
    lon = as.numeric(xy[, 1]),
    lat = as.numeric(xy[, 2]),
    reference_class_binary = NA_character_,
    reference_source = NA_character_,
    interpreter_notes = NA_character_,
    stringsAsFactors = FALSE
  )

  rm(vals, candidate_cells, sampled_cells, xy)
  invisible(gc())
  out
}

write_csv_base <- function(x, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(x, path, row.names = FALSE, na = "")
  message("Wrote: ", path)
}

write_text <- function(lines, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, con = path, useBytes = TRUE)
  message("Wrote: ", path)
}

copy_if_exists <- function(from, to) {
  if (file.exists(from)) {
    dir.create(dirname(to), recursive = TRUE, showWarnings = FALSE)
    file.copy(from, to, overwrite = TRUE)
    return(TRUE)
  }
  FALSE
}
