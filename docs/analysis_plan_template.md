# Analysis Plan: Life Expectancy Prediction Model for CRC Screening (Template)

**Version**: 1.0 (Draft)  
**Date**: 2026-01-27  
**Status**: Pre-specification

---

## 1. Study Objectives

### Primary Objective
Develop and internally validate a prediction model for life expectancy (or mortality risk) among patients aged ≥75 years to inform colorectal cancer screening decisions.

### Secondary Objectives
- Compare performance of different modeling approaches (Cox regression, regularized Cox, random survival forest)
- Identify key predictors of mortality in this population
- Create risk stratification to support shared decision-making

---

## 2. Study Design

**Design**: Retrospective cohort study  
**Setting**: [Describe healthcare setting]  
**Time Period**: [Define index date range and follow-up period]

---

## 3. Study Population

### Inclusion Criteria
- [ ] Age ≥75 years at index date
- [ ] [Define index encounter type]
- [ ] [Minimum data completeness requirements]

### Exclusion Criteria
- [ ] [Prior CRC diagnosis?]
- [ ] [Hospice/palliative care at index?]
- [ ] [Insufficient follow-up time?]

---

## 4. Outcome Definition

### Primary Outcome
**All-cause mortality**
- Source: [ODI death date, EHR vital status]
- Censoring: Last contact date for patients without death date
- Time scale: Days from index date

### Time Horizons of Interest
- 1-year mortality
- 3-year mortality
- 5-year mortality
- 10-year mortality (if sufficient follow-up)

---

## 5. Candidate Predictors

### Demographics
- Age (continuous)
- Sex
- Race/ethnicity
- Marital status

### Comorbidities
- [ ] Cardiovascular conditions (CHF, CAD, arrhythmias)
- [ ] Pulmonary conditions (COPD, asthma)
- [ ] Metabolic conditions (diabetes, CKD)
- [ ] Neurological conditions (dementia, Parkinson's)
- [ ] Malignancies (non-CRC cancers)
- [ ] Functional status indicators

### Laboratory Values
- [ ] Complete metabolic panel (creatinine, BUN, electrolytes)
- [ ] Liver function tests
- [ ] CBC (hemoglobin, WBC, RDW)
- [ ] Lipid panel
- [ ] Albumin
- [ ] eGFR

### Medications
- [ ] Number of medications
- [ ] Specific high-risk medications

### Healthcare Utilization
- [ ] Hospitalizations in prior year
- [ ] ICU admissions
- [ ] Emergency visits

### Social/Contextual
- [ ] Area deprivation index
- [ ] Insurance status

---

## 6. Sample Size Considerations

**Events per variable (EPV)**: Target minimum 10-20 events per candidate predictor for Cox regression.

With ~151,000 patients and [estimate mortality rate], expect ~[X] deaths.

If considering ~50 final predictors: need minimum 500-1000 deaths for stable estimation.

---

## 7. Missing Data Strategy

### Assessment
1. Quantify missingness by variable
2. Assess patterns (MCAR, MAR, MNAR)
3. Compare characteristics of complete vs incomplete cases

### Handling
- **Primary analysis**: Multiple imputation by chained equations (mice)
- **Sensitivity analysis**: Complete case analysis
- **Predictors**: Include missingness indicators if missingness is informative

---

## 8. Model Development

### Preprocessing
1. Imputation of missing values (fit on training data only)
2. Collapse rare factor levels (<1%)
3. Create dummy variables for categorical predictors
4. Normalize continuous predictors (for regularized models)
5. Remove near-zero variance predictors
6. Remove highly correlated predictors (r > 0.9)

### Candidate Models
1. **Cox proportional hazards** - baseline interpretable model
2. **Regularized Cox (elastic net)** - variable selection + shrinkage
3. **Random survival forest** - non-linear relationships, interactions

### Variable Selection
- For regularized models: Data-driven via LASSO/elastic net penalty
- Clinical input: Ensure key clinical variables are retained

### Hyperparameter Tuning
- Method: 10-fold cross-validation, stratified by outcome
- Metric: Concordance index (primary), integrated Brier score (secondary)
- Grid: [Define grids for each model type]

---

## 9. Model Evaluation

### Discrimination
- Concordance index (C-statistic) with 95% CI
- Time-dependent AUC at 1, 3, 5 years

### Calibration
- Calibration plots (predicted vs observed) at key time points
- Calibration slope and intercept
- Hosmer-Lemeshow test or similar

### Overall Performance
- Integrated Brier score
- R² (explained variation)

### Clinical Utility
- Decision curve analysis
- Net benefit at relevant threshold probabilities

---

## 10. Internal Validation

### Primary Method
Bootstrap validation (200+ replicates) with optimism correction

### Secondary Method
Nested cross-validation (outer: 5-fold for honest estimation, inner: 5-fold for tuning)

### Metrics to Report
- Apparent performance
- Optimism-corrected performance
- 95% confidence intervals

---

## 11. Sensitivity Analyses

1. **Complete case analysis** - assess impact of imputation
2. **Excluding patients with <1 year follow-up** - reduce immortal time bias
3. **Stratified by age group** (75-79, 80-84, 85+) - assess model consistency
4. **Alternative time horizons** - 5-year vs 10-year mortality

---

## 12. Reporting

### Standards
- Follow TRIPOD guidelines for transparent reporting
- Report all pre-specified analyses
- Document any deviations from protocol

### Key Outputs
1. Table 1: Baseline characteristics
2. Table 2: Model coefficients/variable importance
3. Table 3: Model performance comparison
4. Figure 1: Calibration plots
5. Figure 2: Kaplan-Meier by risk group
6. Supplementary: Full TRIPOD checklist

---

## 13. Timeline

| Phase | Tasks | Target Date |
|-------|-------|-------------|
| 1 | Data exploration, cohort definition | |
| 2 | Feature engineering, preprocessing | |
| 3 | Model development, tuning | |
| 4 | Internal validation | |
| 5 | Reporting, manuscript | |

---

## 14. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-27 | Initial draft |
