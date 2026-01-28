# CRC Screening Life Expectancy Prediction Model

A prediction model for life expectancy among patients ≥75 years to inform colorectal cancer screening decisions.

> ⚠️ **Data Notice**: This repository contains analysis code only. Patient data contains PHI and is not included in version control. See [SECURITY.md](SECURITY.md) for details.

## Project Overview

This project develops and validates a clinical prediction model using the `tidymodels` framework in R, with `targets` for pipeline orchestration and `renv` for dependency management.

## Quick Start

```r
# 1. Restore package environment
renv::restore()

# 2. View the pipeline
targets::tar_visnetwork()

# 3. Run the pipeline
targets::tar_make()

# 4. Load a target
targets::tar_read(target_name)
```

## Project Structure

```
crcmodel/
├── _targets.R              # Pipeline definition
├── renv.lock               # Package versions
├── SECURITY.md             # Data handling policies
├── R/                      # Functions (sourced by targets)
│   ├── 00_utils.R          # Utility functions
│   ├── 01_data_processing.R
│   ├── 02_feature_engineering.R
│   ├── 03_recipes.R        # Preprocessing recipes
│   ├── 04_model_specs.R    # Model specifications
│   ├── 05_workflows.R      # Workflow definitions
│   ├── 06_tuning.R         # Hyperparameter tuning
│   ├── 07_evaluation.R     # Model evaluation
│   └── 08_reporting.R      # Tables and figures
├── data/                   # Raw data (⛔ GITIGNORED - PHI)
├── data-derived/           # Processed data (⛔ GITIGNORED)
├── output/                 # Final outputs
│   ├── figures/
│   ├── tables/
│   └── models/             # (⛔ GITIGNORED)
├── reports/                # Quarto reports
└── docs/                   # Documentation
```

## Pipeline Workflow

1. **Data Processing**: Load data, define cohort, create outcomes
2. **Feature Engineering**: Create derived variables
3. **Preprocessing**: Apply recipes for imputation, encoding, normalization
4. **Model Training**: Fit candidate models with cross-validation
5. **Hyperparameter Tuning**: Optimize model parameters
6. **Model Selection**: Compare models, select best performer
7. **Final Evaluation**: Internal validation with bootstrap
8. **Reporting**: Generate tables, figures, and model documentation

## Key Dependencies

- **tidymodels**: Modeling framework
- **censored**: Survival analysis extension
- **targets**: Pipeline orchestration
- **renv**: Package management

## Reproducibility

This project uses:
- `renv` for exact package version control
- `targets` for dependency tracking and caching
- Fixed random seeds for reproducible results

To reproduce the analysis:
1. Clone the repository
2. Run `renv::restore()` to install exact package versions
3. Run `targets::tar_make()` to execute the pipeline

## Contact

[Add contact information]

## License

[Add license information]
