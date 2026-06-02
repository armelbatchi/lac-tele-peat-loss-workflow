# ============================================================
# 01_prepare_spatial_layers.R
# Load and prepare clipped raster layers
# ============================================================

peat_path <- find_file(data_dir, "peat_100m_clip_landscape.tif")
lossyear_path <- find_file(data_dir, "lossyear_clip_landscape.tif")
treecover_path <- find_file(data_dir, "treecover2000_clip_landscape.tif")
loss_on_peat_path <- find_file(data_dir, "loss_on_peat_swamp_2015_2024_clip_landscape.tif")

if (is.na(peat_path)) stop("Missing peat_100m_clip_landscape.tif")
if (is.na(lossyear_path)) stop("Missing lossyear_clip_landscape.tif")

peat_100m <- terra::rast(peat_path)
lossyear <- terra::rast(lossyear_path)

if (!is.na(treecover_path) && file.exists(treecover_path)) {
  treecover2000 <- terra::rast(treecover_path)
} else {
  treecover2000 <- NULL
  warning("treecover2000_clip_landscape.tif not found. Forest-threshold sensitivity will be limited.")
}

if (!is.na(loss_on_peat_path) && file.exists(loss_on_peat_path)) {
  loss_on_peat <- terra::rast(loss_on_peat_path)
} else {
  message("loss_on_peat raster not found. Creating it from peat and lossyear.")
  peat_hansen_tmp <- terra::resample(peat_100m, lossyear, method = "near")
  loss_on_peat <- terra::ifel(
    peat_hansen_tmp == 4 & lossyear >= recent_loss_start_code & lossyear <= recent_loss_end_code,
    1,
    0
  )
  names(loss_on_peat) <- "loss_on_peat_2015_2024"
  loss_on_peat_path <- file.path(data_dir, "loss_on_peat_swamp_2015_2024_clip_landscape.tif")
  terra::writeRaster(loss_on_peat, loss_on_peat_path, overwrite = TRUE)
}

peat_hansen <- terra::resample(peat_100m, loss_on_peat, method = "near")
recent_loss <- terra::ifel(
  lossyear >= recent_loss_start_code & lossyear <= recent_loss_end_code,
  1,
  0
)

area_loss <- terra::cellSize(lossyear, unit = "ha")
area_hansen <- terra::cellSize(loss_on_peat, unit = "ha")
area_peat100 <- terra::cellSize(peat_100m, unit = "ha")

message("Loaded input rasters.")
print(peat_100m)
print(lossyear)
print(loss_on_peat)
