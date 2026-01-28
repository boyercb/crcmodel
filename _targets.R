# _targets.R
# Targets pipeline for CRC screening life expectancy prediction model
# Run with: targets::tar_make()
# Visualize with: targets::tar_visnetwork()

library(targets)
library(tarchetypes)

# Source all functions in R/
tar_source("R")

# Set target options
tar_option_set(

  packages = c(
    # Data manipulation
    "tidyverse",
    "lubridate",
    # Modeling
    "tidymodels",
    "censored",
    "survival",
    # Model types
    "glmnet",
    "xgboost",
    "ranger",
    # Evaluation
    "probably",
    "yardstick",
    # Reporting
    "gtsummary",
    "gt"
  ),
  format = "qs",
  seed = 2026
)

# Pipeline definition
list(
  

)
