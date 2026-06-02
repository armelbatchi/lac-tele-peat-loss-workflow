Geospatial raster, vector, tabular, validation, and metadata outputs for peat swamp forest and forest-cover loss screening in the Lac Télé-Likouala-aux-Herbes landscape, Republic of the Congo, 2001-2024

This Zenodo dataset record contains the processed outputs associated with the revised Data in Brief submission.

Recommended dataset structure after extracting outputs_all.zip:

lac_tele_dib_public_revision/
├── rasters/
│   ├── peat_100m_clip_landscape.tif
│   ├── lossyear_clip_landscape.tif
│   ├── treecover2000_clip_landscape.tif
│   └── loss_on_peat_swamp_2015_2024_clip_landscape.tif
├── tables/
│   ├── annual_loss_timeseries_2001_2024.csv
│   ├── annual_loss_timeseries_2001_2024_LONG.csv
│   ├── sensitivity_forest_threshold_10_30_50.csv
│   ├── summary_metrics_corrected.csv
│   ├── peat_class_frequency.csv
│   └── lossyear_value_frequency.csv
├── validation/
│   ├── validation_points_stratified.csv
│   ├── validation_points_stratified_labeling_template.csv
│   ├── validation_points_stratified_labelled.csv
│   ├── validation_point_counts.csv
│   ├── validation_stratum_area_weights.csv
│   ├── confusion_matrix_unweighted_binary.csv
│   ├── confusion_matrix_area_weighted_binary.csv
│   ├── accuracy_metrics_binary_loss_on_peat.csv
│   ├── area_adjusted_estimates_binary_loss_on_peat.csv
│   └── accuracy_assessment_status.csv
├── figures/
│   ├── S1_sensitivity_thresholds.png
│   ├── S2_annual_loss_timeseries.png
│   └── S6_validation_points_map_A100.png
└── metadata/
    ├── FAIR_statement.txt
    ├── data_dictionary.csv
    ├── workflow_steps.csv
    ├── raster_metadata_expanded.csv
    ├── spatial_consistency_checks.csv
    ├── resampling_sensitivity_recent_loss_on_peat.csv
    ├── peat_probability_threshold_sensitivity.csv
    ├── independent_disturbance_comparison.csv
    ├── file_manifest_with_checksums.csv
    └── sessionInfo_reviewer_revision.txt

Important notes:
1. WDPA boundary geometry is not redistributed. Users wishing to reproduce the full original clipping workflow should obtain the Lac Télé Community Reserve boundary independently from Protected Planet under the applicable WDPA terms.
2. The layer loss_on_peat_swamp_2015_2024_clip_landscape.tif is a screening layer, not a definitive deforestation product.
3. Area-adjusted estimates should be used when making quantitative statements after manual validation has been completed.
4. File checksums are provided in metadata/file_manifest_with_checksums.csv.
5. The corresponding code workflow is archived separately as a Zenodo software record and developed on GitHub.
