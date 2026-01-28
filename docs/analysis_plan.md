# Analysis Plan: Life Expectancy Prediction Model for CRC Screening

**Version**: 1.0  
**Date**: 2026-01-27  
**Status**: Pre-specification

---

## 1. Study Objectives

### Primary Objective
Develop and validate a prediction model for **predicted life expectancy** among Cleveland Clinic Health System patients aged ≥75 years to inform colorectal cancer screening decisions.

### Secondary Objectives
- Estimate 5-year, 10-year, and 15-year conditional survival probabilities to assess model performance on time scales relevant to CRC screening decisions
- Compare performance against existing models (Lee model, Cho model)
- Create risk stratification to support shared decision-making
- Assess generalizability via external validation at MetroHealth System

---

## 2. Study Design

**Design**: Retrospective cohort study  
**Setting**: Cleveland Clinic Health System (CCHS)  
**Data Source**: CCHS patients aged ≥75 years who resided in Ohio with ≥2 Internal Medicine or Family Medicine visits between January 1, 2007 and September 1, 2022 within two years

---

## 3. Target Population

The target population consists of CCHS patients aged ≥75 years with an Internal Medicine or Family Medicine visit who are:
- Eligible for colorectal cancer screening (meaning not up to date with screening per guidelines)
- Not currently receiving treatment for any non-skin cancer

---

## 4. Study Population

### Inclusion Criteria
- Age ≥75 years at index date
- ≥2 Internal Medicine or Family Medicine visits within two years prior to index
- Ohio resident
- First eligible primary care visit between 2009 and 2019

### Exclusion Criteria
- Currently receiving treatment for non-skin cancer
- Not on hospice/palliative care at index

### Index Date (Time Zero)
First eligible primary care visit in the CCHS system conducted after age 75.

---

## 5. Outcome Definition

### Primary Outcome
**All-cause mortality**

### Data Sources
- Administrative records in CCHS EHR
- Ohio State Death Index (captures deaths outside health system, should be complete for Ohio residents)

### Estimand
Conditional life expectancy (i.e. time to all-cause death) based on patient characteristics at the time of primary care visit.

### Time Horizons of Interest
- **Primary**: Life expectancy (continuous)
- **Secondary**: 5-year, 10-year, 15-year conditional survival probabilities

### Follow-up
- **Start of follow-up**: Date of first eligible primary care visit after age 75
- **End of follow-up**: December 31, 2019 (to avoid COVID-19 mortality impact)
- **Time scale**: Days from index date
- **Censoring**: Last contact date for patients without death date
- **Note**: Consider sensitivity analysis including COVID period

---

## 6. Candidate Predictors

### Covariate Assessment Window
- Baseline covariates populated from data up to 1 year prior to index visit
- For diagnoses: May extend lookback further (chronic conditions)

### Demographics
- Age (continuous)
- Sex
- Race/ethnicity
- Marital status
- Smoking status

### Socioeconomic Position
- Area Deprivation Index (ADI)
- Insurance status/type

### Comorbidities
All diagnoses independently associated with mortality in published literature, including:
- Heart failure
- [Other conditions to be specified based on literature review]

### Medications
- Number of medications
- Specific that indicate disease presence/severity:
  - Furosemide (heart failure severity indicator)
  - Beta-blockers

**Rationale**: Previous study demonstrated medications add to discrimination in mortality models.

### Laboratory Values
- Complete metabolic panel (creatinine, BUN, electrolytes)
- Liver function tests
- CBC (hemoglobin, WBC, RDW)
- Lipid panel
- Albumin
- eGFR

**Note**: These labs have not been included in prior LE models.

### Healthcare Utilization
- Hospitalizations in prior year
- ICU admissions
- Emergency visits

### Blinding
Pre-processing and assessment of candidate predictors will be performed while blind to study outcomes to minimize bias.

---

## 7. Sample Size Considerations

Because our study population is comprised of patients aged 75 and older, we anticipate an event rate of greater than 50% over the follow-up period. 

**Events per variable (EPV)**: Target minimum 10-20 events per candidate predictor.

Dataset: ~151,000 patients with ~402 variables

[Calculate expected number of deaths and final EPV after variable selection]

---

## 8. Missing Data Strategy

### Two-pronged approach based on clinical deployment considerations:

#### Approach 1: Multiple Imputation
**When to use**: Missingness is NOT anticipated in clinical deployment setting
- Use multiple imputation by chained equations
- Appropriate methods for combining estimates across imputation datasets
- Proper uncertainty quantification

#### Approach 2: Missingness Indicator Method
**When to use**: Missingness IS anticipated in clinical deployment
- Include additional predictor variable: "1" if predictor is missing, "0" otherwise
- Captures how predictions vary depending on information availability

### Data Cleaning Tasks
1. Create Table 1 with sample size and baseline characteristics
2. Create Table summarizing missingness across all covariates
3. Determine imputation strategy based on deployment feasibility
4. Mark covariates as continuous vs categorical
5. For continuous variables: decide modeling approach (consider restricted cubic splines with variable knots based on bivariate outcome ~ covariate)
6. For categorical variables: decide if consolidation needed

---

## 9. Model Development

### Goals
Create a model that is both **locally accurate** and **highly generalizable**, balanced through rigorous modeling techniques and external validation.

### Variable Selection
Following Lee et al. approach:
1. **LASSO Cox proportional hazards** regression with BIC-optimized lambda
2. **Stability selection principle**: Apply algorithm to random subsamples (n/2) multiple times
3. Assign high scores to variables consistently selected across randomizations
4. This repeated double randomization ensures selected variables are consistent over range of model parameters

### Candidate Models

| Model | Description |
|-------|-------------|
| **LASSO Cox PH** | Cox proportional hazards with LASSO penalty, baseline risk via Kaplan-Meier |
| **Parametric AFT (Gompertz)** | Accelerated failure time model with Gompertz distribution ([reference](https://www.jstatsoft.org/article/view/v070i08)) |
| **Survival Random Forest** | Generalized random forests for survival |

### Preprocessing (within model pipeline)
1. Handle missing values (per strategy above)
2. Collapse rare factor levels
3. Normalize continuous predictors (for regularized models)
4. Create splines for continuous variables where appropriate

### Hyperparameter Tuning
- Bootstrap resampling or k-fold cross-validation
- Include ALL model building steps in resampling loop:
  - Variable selection
  - Imputation
  - Penalization/tuning parameter selection
  - Estimation

---

## 10. Comparator Models

### Cho Model
- Estimates life expectancy from Medicare claims
- Compares survival models with US life tables
- Groups patients into: no comorbidity, low/medium, high comorbidity
- **Limitations**: 
  - Lacks disease severity information
  - Limited individualization of LE estimates
  - Life tables may have lower physician acceptability

### Lee Model
- Developed using VA EHR data specifically for cancer screening decisions
- Includes demographics, diseases, medications, labs, utilization, vital signs (within 1 year of index)
- ~100 predictors from 913 candidates
- AUC: 0.816 [0.815, 0.817]
- **Limitations**:
  - Only 3% female in development cohort
  - Generalizability to non-VA systems not evaluated

### Comparator Analysis Options
- Lee model with original coefficients
- Lee model re-fitted to CCHS data
- Hybrid approach

---

## 11. Model Evaluation

### Internal Validation
**Method**: Bootstrap resampling with optimism correction
- Include all model-building steps in bootstrap loop
- Consider stratified bootstrap by year for internal-external validation

### Discrimination Metrics
- C-statistic (concordance index)
- Time-dependent ROC/AUC at 5, 10, 15 years
- 95% confidence intervals

### Calibration Metrics
- Calibration slope
- Calibration plots (predicted vs observed)
- Brier score
- Integrated Brier score

### Subgroup Analyses
Assess performance within:
- Race/ethnicity groups
- Age groups
- Sex
- Calendar year
- Socioeconomic status (ADI)

### Clinical Utility
- Decision curve analysis
- Net benefit at relevant threshold probabilities

---

## 12. External Validation

### Setting
**MetroHealth System**
- 732-bed county-owned hospital
- Northeast Ohio's main safety-net provider

### Rationale
Although generalizability is not essential (primary use case is internal CCHS decisions), external validation will assess if model is a more widely useful tool.

---

## 13. Sensitivity Analyses

1. **COVID-19 period**: Model including vs excluding data after December 31, 2019
2. **Alternative follow-up periods**
3. **Complete case analysis** (assess imputation impact)
4. **Different lookback windows** for covariate assessment

---

## 14. Implementation Considerations

### EHR Deployment
- Model must be deployable with data available at point of care
- SureScript medication data may not be pullable at deployment
- Focus on physician-entered prescriptions in EHR

### Future Extensions
- Consider capturing intermediates (incident disease, medication initiation)

---

## 15. Reporting

### Standards
- Follow TRIPOD guidelines for transparent reporting
- Report all pre-specified analyses
- Document any protocol deviations

### Key Outputs
1. **Table 1**: Baseline characteristics
2. **Table 2**: Missingness summary
3. **Table 3**: Model coefficients/variable importance
4. **Table 4**: Model performance comparison (discrimination + calibration)
5. **Figure 1**: Calibration plots
6. **Figure 2**: Time-dependent AUC curves
7. **Figure 3**: Kaplan-Meier by predicted risk groups
8. **Supplementary**: Subgroup analyses, TRIPOD checklist

---

## 16. Timeline

| Phase | Tasks | Target Date |
|-------|-------|-------------|
| 1 | Data exploration, cohort definition, Table 1 | |
| 2 | Missingness assessment, covariate decisions | |
| 3 | Feature engineering, preprocessing pipeline | |
| 4 | Variable selection, model development | |
| 5 | Internal validation (bootstrap) | |
| 6 | Comparator model evaluation | |
| 7 | External validation (MetroHealth) | |
| 8 | Reporting, manuscript | |

---

## 17. References

1. Lee SJ, et al. (Lee model reference)
2. Cho H, et al. (Cho model reference)
3. [flexsurv package for Gompertz](https://www.jstatsoft.org/article/view/v070i08)
4. [Calibration methods](https://pmc.ncbi.nlm.nih.gov/articles/PMC5578404/)
5. [Validation framework](https://www.sciencedirect.com/science/article/pii/S0895435601003419)
6. [Survival prediction methods](https://link.springer.com/chapter/10.1007/978-3-030-16399-0_5)

---

## 18. Open Questions

- [ ] Lookback window for diagnoses: how far back? Can we determine if diagnosis is "resolved"?
- [ ] COVID period handling: Include with sensitivity analysis, or exclude entirely?
- [ ] Contact Jarrod re: COVID period handling in similar work
- [ ] Finalize list of candidate predictors from literature
- [ ] Confirm MetroHealth data access and timeline

---

## 19. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-27 | Initial version incorporating prior planning notes |
