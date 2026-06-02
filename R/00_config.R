# ============================================================
# 00_config.R
# User settings and folder detection
# ============================================================

options(stringsAsFactors = FALSE)

# Set this manually if auto-detection fails:
# Sys.setenv(LAC_TELE_DATA_DIR = "/path/to/roc_lac_tele_data")

n_validation_per_stratum <- 100
recent_loss_start_year <- 2015
recent_loss_end_year <- 2024
recent_loss_start_code <- 15
recent_loss_end_code <- 24

repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)

candidate_dirs <- unique(c(
  Sys.getenv("LAC_TELE_DATA_DIR", unset = ""),
  repo_root,
  file.path(repo_root, "data"),
  file.path(repo_root, "roc_lac_tele_data"),
  file.path(dirname(repo_root), "roc_lac_tele_data")
))
candidate_dirs <- candidate_dirs[nzchar(candidate_dirs)]

find_data_dir <- function(candidates) {
  for (d in candidates) {
    if (!dir.exists(d)) next
    recursive_hits <- list.files(
      d,
      pattern = "peat_100m_clip_landscape\\.tif$|lossyear_clip_landscape\\.tif$",
      recursive = TRUE,
      full.names = TRUE
    )
    if (length(recursive_hits) > 0) {
      return(normalizePath(d, winslash = "/", mustWork = TRUE))
    }
  }
  stop(
    "Could not find the data directory. Put the input rasters in the repository, ",
    "in data/, in roc_lac_tele_data/, or set Sys.setenv(LAC_TELE_DATA_DIR = '/path/to/data')."
  )
}

data_dir <- find_data_dir(candidate_dirs)
outputs_dir <- file.path(data_dir, "outputs")
reviewer_dir <- file.path(outputs_dir, "reviewer_revision")
fig_dir <- file.path(outputs_dir, "figures_extras")
public_archive_dir <- file.path(data_dir, "public_archive")

for (d in c(outputs_dir, reviewer_dir, fig_dir, public_archive_dir)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

message("Using repo_root: ", repo_root)
message("Using data_dir: ", data_dir)
message("Using outputs_dir: ", outputs_dir)
message("Using reviewer_dir: ", reviewer_dir)
