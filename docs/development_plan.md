# Development Plan: CRC Life Expectancy Prediction Model

**Created**: 2026-01-27  
**Status**: Active

---

## Overview

This document outlines the phased development approach for the life expectancy prediction model. Each phase has specific objectives, tasks, deliverables, and completion criteria.

**Estimated timeline**: [To be determined based on team availability]

---

## Phase 1: Data Exploration & Cohort Definition

### Objectives
- Understand the data structure and quality
- Apply inclusion/exclusion criteria to define the analytic cohort
- Create Table 1 (baseline characteristics)
- Assess outcome distribution and follow-up time

### Tasks

#### 1.1 Data Inventory
- [ ] Load and inspect raw data structure
- [ ] Map variables to codebook definitions
- [ ] Identify key variable categories (demographics, diagnoses, labs, medications, outcomes)
- [ ] Document variable types (continuous, categorical, dates)

#### 1.2 Cohort Definition
> **Note**: Inclusion/exclusion criteria were applied during data extraction. This section focuses on verification and documentation.

- [ ] Verify cohort criteria were applied correctly:
  - Age ≥75 at index
  - ≥2 IM/FM visits within 2 years prior to index
  - Ohio resident
  - Index visit between 2009-2019
  - Excluded: Active non-skin cancer treatment
  - Excluded: Hospice/palliative care at index
- [ ] Document final sample size (N = 151,479)
- [ ] Create CONSORT-style flow diagram documenting extraction criteria

#### 1.3 Outcome Assessment
- [ ] Calculate death rate overall and by calendar year
- [ ] Assess follow-up time distribution (median, IQR, range)
- [ ] Check for administrative censoring patterns
- [ ] Verify Ohio Death Index linkage completeness
- [ ] Create Kaplan-Meier curve for overall survival

#### 1.4 Baseline Characteristics
- [ ] Generate Table 1 with demographics, comorbidities, labs, medications
- [ ] Stratify by outcome (died vs alive at end of follow-up) for descriptive purposes
- [ ] Identify potential data quality issues

### Deliverables
- [ ] Cohort flow diagram with counts
- [ ] Table 1 (baseline characteristics)
- [ ] Summary of outcome/follow-up distribution
- [ ] Data quality report (issues identified, decisions made)

### Completion Criteria
- Analytic cohort defined and documented
- Sample size and event count confirmed adequate for planned analyses
- Major data quality issues identified and addressed

---

## Phase 2: Missing Data Assessment & Covariate Decisions

### Objectives
- Quantify and characterize missing data
- Decide on missing data handling strategy per variable
- Finalize predictor variable set and encoding decisions

### Tasks

#### 2.1 Missingness Assessment
- [ ] Calculate percent missing for each candidate predictor
- [ ] Create missingness heatmap/summary table
- [ ] Assess missingness patterns (MCAR, MAR, MNAR)
- [ ] Compare characteristics of patients with vs without missing values
- [ ] Identify variables with >50% missing (may need to exclude)

#### 2.2 Missing Data Strategy Decisions
For each variable, determine:
- [ ] Is missingness expected at deployment? → Use missingness indicator
- [ ] Is missingness random/predictable? → Use multiple imputation
- [ ] Document rationale for each decision

#### 2.3 Covariate Encoding Decisions
- [ ] List all continuous variables; decide on functional form:
  - Linear
  - Splines (specify knots)
  - Categorical (specify cutpoints with clinical rationale)
- [ ] List all categorical variables; decide on consolidation:
  - Rare levels to combine
  - Reference categories
- [ ] Create derived variables as needed:
  - Comorbidity counts/indices
  - Lab value recency indicators
  - Medication class indicators

#### 2.4 Finalize Candidate Predictor List
- [ ] Review literature for mortality predictors in elderly
- [ ] Map available variables to Lee model predictors
- [ ] Document included/excluded variables with rationale
- [ ] Estimate final number of candidate predictors (for EPV calculation)

### Deliverables
- [ ] Missingness summary table
- [ ] Variable encoding specification document
- [ ] Final candidate predictor list with rationale

### Completion Criteria
- Missing data strategy documented for all variables
- Variable encoding decisions finalized
- Predictor list locked (pre-specification complete)

---

## Phase 3: Feature Engineering & Preprocessing Pipeline

### Objectives
- Implement feature engineering functions
- Build tidymodels recipe(s) for preprocessing
- Validate preprocessing on sample data

### Tasks

#### 3.1 Implement Feature Engineering
- [ ] Create derived features in `R/02_feature_engineering.R`:
  - Comorbidity burden scores
  - Lab recency features
  - Medication indicators
  - Age groups (if using categorical)
- [ ] Unit test feature engineering functions

#### 3.2 Build Preprocessing Recipes
- [ ] Implement base recipe in `R/03_recipes.R`:
  - Imputation steps (per Phase 2 decisions)
  - Missingness indicators (where appropriate)
  - Factor level collapsing
  - Dummy encoding
  - Normalization (for regularized models)
  - Near-zero variance filtering
  - Correlation filtering
- [ ] Implement tree-specific recipe (no normalization)
- [ ] Implement spline recipe (for flexible continuous relationships)

#### 3.3 Set Up Targets Pipeline
- [ ] Populate `_targets.R` with Phase 1-3 targets:
  - `tar_target(raw_data, ...)`
  - `tar_target(cohort, ...)`
  - `tar_target(analysis_data, ...)`
  - `tar_target(recipe_base, ...)`
- [ ] Verify pipeline runs end-to-end
- [ ] Check intermediate outputs

#### 3.4 Create Train/Test Split
- [ ] Decide on splitting strategy:
  - Simple random split (e.g., 80/20)
  - Temporal split (train on earlier years, test on later)
  - Or: use all data for development, rely on bootstrap for validation
- [ ] Implement split, stratified by outcome
- [ ] Document hold-out set (if using) — DO NOT PEEK

### Deliverables
- [ ] Working `_targets.R` pipeline through preprocessing
- [ ] Documented recipe specifications
- [ ] Train/test split (if applicable)

### Completion Criteria
- Pipeline runs without errors
- Preprocessed data passes sanity checks
- Recipe produces expected transformations

---

## Phase 4: Model Development & Variable Selection

### Objectives
- Implement candidate model specifications
- Perform variable selection (LASSO with stability selection)
- Tune hyperparameters via cross-validation
- Select best-performing model(s)

### Tasks

#### 4.1 Set Up Resampling
- [ ] Create cross-validation folds (10-fold, stratified by event)
- [ ] Consider: repeated CV or bootstrap for variance estimation
- [ ] For nested CV: set up outer/inner fold structure

#### 4.2 Variable Selection
- [ ] Implement LASSO Cox with BIC-optimized lambda
- [ ] Implement stability selection:
  - Run LASSO on B=100 subsamples of size n/2
  - Calculate selection frequency for each variable
  - Select variables with frequency > threshold (e.g., 0.6)
- [ ] Document selected variables

#### 4.3 Fit Candidate Models
- [ ] Cox proportional hazards (baseline, with selected variables)
- [ ] Regularized Cox (elastic net) with tuning
- [ ] Parametric AFT - Gompertz (using `flexsurv`)
- [ ] Random survival forest (using `ranger` or `aorsf`)
- [ ] [Optional] XGBoost survival

#### 4.4 Hyperparameter Tuning
- [ ] Define tuning grids for each model
- [ ] Run tuning via cross-validation
- [ ] Select best hyperparameters per model
- [ ] Document tuning results

#### 4.5 Model Comparison
- [ ] Compare models on CV performance:
  - Concordance index
  - Integrated Brier score
  - Time-dependent AUC at 5, 10, 15 years
- [ ] Create comparison table and visualization
- [ ] Select final model(s) for validation

### Deliverables
- [ ] Variable selection results (stability plot, final variable list)
- [ ] Tuning results for each model
- [ ] Model comparison table
- [ ] Selected final model specification

### Completion Criteria
- At least 2-3 candidate models tuned and compared
- Final model(s) selected based on pre-specified criteria
- All tuning done within CV (no peeking at test set)

---

## Phase 5: Internal Validation

### Objectives
- Estimate optimism-corrected performance
- Assess calibration
- Evaluate performance in subgroups

### Tasks

#### 5.1 Bootstrap Validation
- [ ] Implement full bootstrap validation (B=200+):
  - For each bootstrap sample:
    - Perform variable selection
    - Fit model
    - Evaluate on bootstrap sample (apparent)
    - Evaluate on original data (test)
  - Calculate optimism = apparent - test
  - Optimism-corrected = original apparent - mean(optimism)
- [ ] Calculate 95% CIs via percentile method

#### 5.2 Discrimination Assessment
- [ ] C-statistic with 95% CI
- [ ] Time-dependent AUC at 5, 10, 15 years
- [ ] ROC curves at key time points

#### 5.3 Calibration Assessment
- [ ] Calibration plots at 5, 10, 15 years
- [ ] Calibration slope and intercept
- [ ] Calibration-in-the-large
- [ ] Brier score and integrated Brier score

#### 5.4 Subgroup Performance
- [ ] Stratify performance by:
  - Age group (75-79, 80-84, 85+)
  - Sex
  - Race/ethnicity
  - Calendar year of index
  - ADI quintile
- [ ] Assess calibration within subgroups

#### 5.5 Clinical Utility
- [ ] Decision curve analysis
- [ ] Net benefit at relevant threshold probabilities
- [ ] Identify useful risk thresholds for clinical decision-making

### Deliverables
- [ ] Optimism-corrected performance estimates with CIs
- [ ] Calibration plots
- [ ] Subgroup performance table
- [ ] Decision curve analysis figure

### Completion Criteria
- All pre-specified performance metrics calculated
- Calibration assessed and acceptable (or recalibration performed)
- Subgroup analyses complete

---

## Phase 6: Comparator Model Evaluation

### Objectives
- Implement and evaluate Lee model
- Implement and evaluate Cho model
- Compare against developed model

### Tasks

#### 6.1 Lee Model
- [ ] Obtain Lee model coefficients from publication
- [ ] Map CCHS variables to Lee model predictors
- [ ] Calculate Lee model predictions for CCHS cohort
- [ ] Evaluate performance (discrimination, calibration)
- [ ] [Optional] Refit Lee model variables to CCHS data

#### 6.2 Cho Model
- [ ] Implement Cho model risk groupings
- [ ] Calculate Cho model predictions
- [ ] Evaluate performance

#### 6.3 Head-to-Head Comparison
- [ ] Compare all models on same validation data:
  - C-statistic comparison (with CIs, DeLong test)
  - Calibration comparison
  - Net reclassification improvement (NRI)
  - Integrated discrimination improvement (IDI)
- [ ] Create comparison visualization

### Deliverables
- [ ] Comparator model implementations
- [ ] Head-to-head comparison table
- [ ] Comparison figures

### Completion Criteria
- At least Lee model implemented and compared
- Statistical comparison of discrimination complete

---

## Phase 7: External Validation (MetroHealth)

### Objectives
- Validate final model in external population
- Assess transportability

### Tasks

#### 7.1 Data Acquisition
- [ ] Obtain MetroHealth data extract
- [ ] Map variables to CCHS definitions
- [ ] Apply same cohort criteria

#### 7.2 External Validation
- [ ] Apply final CCHS model to MetroHealth data
- [ ] Evaluate discrimination and calibration
- [ ] Compare patient characteristics (case-mix)
- [ ] Assess need for recalibration

#### 7.3 Transportability Analysis
- [ ] Quantify population differences
- [ ] Explain any performance gaps
- [ ] [Optional] Develop recalibration strategy

### Deliverables
- [ ] External validation results
- [ ] Comparison of CCHS vs MetroHealth populations
- [ ] Transportability assessment

### Completion Criteria
- External validation complete
- Performance documented and interpreted

---

## Phase 8: Reporting & Manuscript

### Objectives
- Document all analyses per TRIPOD guidelines
- Prepare manuscript and supplementary materials
- Finalize model for potential deployment

### Tasks

#### 8.1 TRIPOD Compliance
- [ ] Complete TRIPOD checklist
- [ ] Ensure all items addressed in manuscript

#### 8.2 Manuscript Preparation
- [ ] Methods section (detailed, reproducible)
- [ ] Results section with all tables/figures
- [ ] Discussion of strengths, limitations, clinical implications
- [ ] Supplementary materials

#### 8.3 Tables and Figures
- [ ] Table 1: Baseline characteristics
- [ ] Table 2: Missingness summary
- [ ] Table 3: Model coefficients / variable importance
- [ ] Table 4: Performance comparison (CCHS internal)
- [ ] Table 5: External validation results
- [ ] Figure 1: Cohort flow diagram
- [ ] Figure 2: Calibration plots
- [ ] Figure 3: Time-dependent AUC
- [ ] Figure 4: Decision curve analysis
- [ ] Figure 5: Kaplan-Meier by risk groups

#### 8.4 Model Artifact
- [ ] Save final model object for deployment
- [ ] Document required inputs and preprocessing
- [ ] Create prediction function for new patients
- [ ] [Optional] Risk calculator prototype

### Deliverables
- [ ] Complete manuscript draft
- [ ] All tables and figures
- [ ] TRIPOD checklist
- [ ] Final model artifact

### Completion Criteria
- Manuscript ready for co-author review
- All analyses documented and reproducible

---

## Dependencies & Critical Path

```
Phase 1 ─────► Phase 2 ─────► Phase 3 ─────► Phase 4 ─────► Phase 5 ─────► Phase 8
   │              │                             │              │              ▲
   │              │                             │              └──► Phase 6 ──┤
   │              │                             │                             │
   │              │                             └─────────────► Phase 7 ──────┘
   │              │
   │              └─── (Lock predictor list before Phase 4)
   │
   └─── (Cohort definition needed for all subsequent phases)
```

**Critical path**: Phases 1 → 2 → 3 → 4 → 5 → 8

**Parallel work possible**:
- Phase 6 (comparator models) can begin once Phase 4 variable list is finalized
- Phase 7 (external validation) can begin data acquisition early, but validation requires Phase 5

---

## Progress Tracking

| Phase | Status | Start Date | End Date | Notes |
|-------|--------|------------|----------|-------|
| 1. Data Exploration | Not started | | | |
| 2. Missing Data | Not started | | | |
| 3. Preprocessing | Not started | | | |
| 4. Model Development | Not started | | | |
| 5. Internal Validation | Not started | | | |
| 6. Comparator Models | Not started | | | |
| 7. External Validation | Not started | | | |
| 8. Reporting | Not started | | | |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-27 | Initial development plan |
