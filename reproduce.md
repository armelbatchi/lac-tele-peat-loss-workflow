# Reproduce the workflow outputs

This document provides minimal instructions to run `WWL_V6.Rmd` and reproduce the analysis outputs described in the associated Data Descriptor.

## Prerequisites

- R (recommended: R >= 4.3)
- RStudio (optional but convenient)
- Internet access to install missing R packages
- The dataset archive `outputs_all.zip` (see dataset DOI in `README.md`)

## Setup

1. Create a working directory and place `WWL_V6.Rmd` in it.
2. Download and extract `outputs_all.zip` into the same working directory.
3. Preserve the original file names and folder structure from the archive.

## Run the workflow

Open `WWL_V6.Rmd` in RStudio and knit the document, or run from R:

```r
rmarkdown::render("WWL_V6.Rmd")
