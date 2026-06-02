# Reproduction instructions

## 1. Install R packages

```r
install.packages("terra", repos = "https://cloud.r-project.org")
```

## 2. Prepare the data directory

Create one folder containing the input rasters:

```text
roc_lac_tele_data/
├── peat_100m_clip_landscape.tif
├── lossyear_clip_landscape.tif
├── treecover2000_clip_landscape.tif
└── loss_on_peat_swamp_2015_2024_clip_landscape.tif
```

The fourth raster can be recreated by the workflow if it is missing.

## 3. Run all scripts

From the repository root:

```r
Sys.setenv(LAC_TELE_DATA_DIR = "/path/to/roc_lac_tele_data")
source("00_run_all.R")
```

## 4. Manual validation

Open:

```text
outputs/reviewer_revision/validation_points_stratified_labeling_template.csv
```

Complete the column `reference_class_binary` using only:

```text
reference_loss_on_peat
reference_not_loss_on_peat
```

Use the following interpretation sources where available:

```text
Google Earth web imagery
Sentinel-2
Planet/NICFI
very high-resolution imagery
field verification
```

Save as:

```text
outputs/reviewer_revision/validation_points_stratified_labelled.csv
```

Rerun:

```r
source("00_run_all.R")
```

## 5. Rebuild Zenodo dataset archive

The final script creates:

```text
outputs_all.zip
```

Upload this ZIP to the Zenodo dataset record, not to GitHub.
