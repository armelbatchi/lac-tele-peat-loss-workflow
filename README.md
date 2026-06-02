# Lac Télé peat-swamp forest loss workflow, Republic of the Congo, 2001-2024

This repository contains the reproducible R workflow used to generate geospatial raster/vector products, tabular summaries, validation outputs, sensitivity analyses, metadata, and publication figures for peat swamp forest and forest-cover loss screening in the Lac Télé-Likouala-aux-Herbes landscape, Republic of the Congo, 2001-2024.

The code repository is intentionally kept lightweight. Large GeoTIFF, GeoPackage, CSV, PNG, and metadata outputs are archived separately in the Zenodo dataset record.

## Repository contents

```text
lac-tele-peat-loss-workflow/
├── 00_run_all.R
├── R/
│   ├── 00_config.R
│   ├── 00_helpers.R
│   ├── 01_prepare_spatial_layers.R
│   ├── 02_calculate_loss_area.R
│   ├── 03_generate_validation_points.R
│   ├── 04_manual_validation_summary.R
│   ├── 05_sensitivity_analysis.R
│   ├── 06_make_figures.R
│   ├── 07_write_metadata_and_checksums.R
│   └── 08_build_public_archive.R
├── manuscript_support/
│   └── reviewer_revision_workflow.Rmd
├── README.md
├── README_dataset.txt
├── reproduce.md
├── CITATION.cff
├── .zenodo.json
├── LICENSE
└── .gitignore
```

## Data archive

The processed dataset files are archived separately on Zenodo.

- Dataset DOI, all versions or concept DOI: `10.5281/zenodo.18770920`
- Dataset DOI, exact version used in the revised manuscript: replace this after publishing the new dataset version
- Code/software DOI, all versions or concept DOI: `10.5281/zenodo.18773510`
- Code/software DOI, exact version used in the revised manuscript: replace this after Zenodo archives the new GitHub release

## Required input files

Place these input files either in the working directory, in `data/`, or in `roc_lac_tele_data/`:

```text
peat_100m_clip_landscape.tif
lossyear_clip_landscape.tif
treecover2000_clip_landscape.tif
loss_on_peat_swamp_2015_2024_clip_landscape.tif
```

If `loss_on_peat_swamp_2015_2024_clip_landscape.tif` is missing, the workflow creates it from the peat class-4 mask and Hansen lossyear values 15-24.

## Quick start

In R:

```r
source("00_run_all.R")
```

Optional environment variables:

```r
Sys.setenv(LAC_TELE_DATA_DIR = "/path/to/roc_lac_tele_data")
Sys.setenv(PEAT_PROBABILITY_TIF = "/path/to/peat_probability.tif")
Sys.setenv(INDEPENDENT_LOSS_TIF = "/path/to/independent_loss_raster.tif")
```

## Manual validation

The workflow writes a validation template:

```text
outputs/reviewer_revision/validation_points_stratified_labeling_template.csv
```

Fill `reference_class_binary` with only these values:

```text
reference_loss_on_peat
reference_not_loss_on_peat
```

Save the completed file as:

```text
outputs/reviewer_revision/validation_points_stratified_labelled.csv
```

Then rerun:

```r
source("00_run_all.R")
```

The workflow then writes confusion matrices, accuracy metrics, and area-adjusted estimates.

## Main outputs

```text
outputs/annual_loss_timeseries_2001_2024.csv
outputs/annual_loss_timeseries_2001_2024_LONG.csv
outputs/sensitivity_forest_threshold_10_30_50.csv
outputs/validation_points_stratified.csv
outputs/figures_extras/S1_sensitivity_thresholds.png
outputs/figures_extras/S2_annual_loss_timeseries.png
outputs/reviewer_revision/S6_validation_points_map_A100.png
outputs/reviewer_revision/validation_points_stratified_labelled.csv
outputs/reviewer_revision/confusion_matrix_unweighted_binary.csv
outputs/reviewer_revision/confusion_matrix_area_weighted_binary.csv
outputs/reviewer_revision/accuracy_metrics_binary_loss_on_peat.csv
outputs/reviewer_revision/area_adjusted_estimates_binary_loss_on_peat.csv
outputs/reviewer_revision/resampling_sensitivity_recent_loss_on_peat.csv
outputs/reviewer_revision/raster_metadata_expanded.csv
outputs/reviewer_revision/spatial_consistency_checks.csv
outputs/reviewer_revision/file_manifest_with_checksums.csv
outputs/reviewer_revision/FAIR_statement.txt
outputs_all.zip
```

## Interpretation note

The raster layer `loss_on_peat_swamp_2015_2024_clip_landscape.tif` is a screening product. It identifies overlap between CongoPeat class-4 peat swamp forest and Hansen Global Forest Change lossyear values 15-24. It should not be interpreted as a definitive deforestation area unless the validation-adjusted estimates are used.

## License

Code is released under the MIT License. Upstream data remain governed by their original licenses and terms.
