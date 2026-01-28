**Target population:** The target population consists of Cleveland Clinic Health System patients aged ≥75 years with an Internal Medicine or Family Medicine visit who are eligible for colorectal cancer screening and not currently receiving treatment for any non-skin cancer. 

**Data source:** Cleveland Clinic Health System patients aged ≥75 years who resided in Ohio and who had ≥2 Internal Medicine or Family Medicine visits between January 1, 2007 and September 1, 2022 within two years.

**Estimand:** Our prediction model estimates the conditional life expectancy based on patient characteristics at the time of their primary care visit. As secondary targets, we will also estimate 5-year, 10-year, and 15-year conditional survival probabilities to assess performance of the model on time scales relevant to informing clinical decision-making around the appropriateness of colorectal cancer screening.

**Outcome:** The primary outcome variable is death due to any cause. This will be assessed via administrative record in the CCHS EHR, as well as through linkage with the Ohio State Death Index, which captures patients who died outside of our health system. 

**Timing:** Time zero in the primary model is the first eligible primary care visit in the CCHS system conducted after age 75\. The prediction horizon for life expectancy estimation is roughly  

**Predictors:** Variables will include age, race, sex, smoking status, and socioeconomic position as estimated from the Area Deprivation Index; as well as all specific diagnoses, medications, and lab values that are independently associated with mortality, based on published literature. For diagnoses, this will include conditions such as heart failure, and specific medications, such as furosemide or a beta-blocker, that indicate the severity of heart failure. In a previous study we demonstrated that medications add to discrimination in a mortality model of pneumonia. We will include lab values, such as red cell distribution width (RDW) and white blood cell count (WBC),which are independently associated with mortality in older patients, and have not been included in prior models. To minimize bias, pre-processing and assessment of candidate predictors will be performed while blind to study outcomes. 

**Missing data:** Missingness in predictor variables will be handled in one of two ways depending on what is known about the cause of missingness and whether missingness is anticipated in the clinical setting in which the model will be deployed. If missingness is not anticipated for a particular variable we will use multiple imputation to impute predictor values and use appropriate methods for combining estimates across imputation datasets and quantifying uncertainty. On the other hand, if missingness in a particular variable is anticipated, we will use the missingness indicator method (i.e. include an additional predictor variable that is “1” if the predictor is missing and zero otherwise) to capture how predictions vary depending on whether information is or is not available.

**Index model development:** The goal is to create a model which is both locally accurate and highly generalizable. We will balance these goals by use of rigorous modeling techniques, including careful variable selection and external validation. First, following similar lines as the approach of Lee et al., we will perform variable selection of the pool of candidate predictors from the EHR using a Lasso Cox proportional hazards regression with a BIC-optimized lambda. We will consider the stability selection principle to ensure selected variables are consistent over a range of model parameters. Thus, we will apply the algorithm several times to random subsamples of the data of size n/2 (n=number of samples) and find the tuning variables that appear consistently. This repeated double randomization is used to assign high scores to consistently selected variables across randomizations. Second, we will use the selected variables for model fitting. Here, we consider multiple approaches including Cox regression and parametric accelerated failure times (e.g., Gompertz distribution).

**Comparator model(s):**

* *Cho model:* This model estimates life expectancy from Medicare claims by comparing survival models with US life tables. The model estimates individual life expectancy by grouping patients into three groups: no comorbidity, low/medium, and high comorbidity. A major limitation of this model is a lack of information on disease severity, which results in a lack of individualization of life expectancy estimates. Due to their lack of precision, use of life tables may be problematic and may have lower acceptability with physicians.  We recently used a model by Cho et al., to evaluate use of colonoscopy in patients with limited life expectancy.14   
* *Lee model*: Lee and colleagues developed a life expectancy model using EHR data from the Veterans Health Administration.13 This model was specifically developed to aid in cancer screening decisions, and includes demographics, diseases, medications, laboratory results, utilization, and vital signs recorded within one year of the index visit. The final model used approximately 100 predictors out of 913 candidate predictors, and the AUC life expectancy prediction was 0.816 \[0.815, 0.817\]. Because this model was developed in a VA population, only 3% of the sample was female. Generalizability of this model to non-VA health systems has not been evaluated but may be limited given the unique patient sample. 

**Model evaluation:** We will use bootstrap resampling techniques to estimate optimism-corrected performance of our candidate and comparator models. Specifically we will calculate measures of discrimination (c-statistic, time-dependent ROC/AUC) and calibration (slope, plot, and Brier score). We will consider both overall performance of the model as well as performance over calendar time and within key age and demographic groups (race/ethnicity, socio-economic status). 

**External validation:** Although generalizability/transportability of our model to other settings is not essential (as our primary use case for the model is internal CCHS decisions about colorectal cancer screening) we will nonetheless estimate the performance of the model in another healthcare setting to understand if it may be a more widely useful tool. Specifically, we will perform and external validation study using data from the MetroHealth System, a 732-bed county-owned hospital, which is the Northeast Ohio region’s main safety-net provider. 

**Analytic Plan**

**Data:**

- All patients ages 75+ with first eligible primary care visit between 2009 and 2019  
- Baseline is first eligible primary care visit, to populate covariate values can go back 1 year or more before?  
  - For diagnoses could go back further… (is there anyway to know if a diagnosis has been “resolved” ? or is the focus more on chronic disease ?)(JK)  
- Stop follow up on December 31, 2019 to ignore the dip in life expectancy due to COVID?   
  - Would it be useful to maybe create two models, one including this data and one not? I could see an argument that COVIDs impact extends to present day and I’d worry not including this data would impact our  ability to accurately predict current outcomes. (JK)

- Ask jarrod what he did with covid period  
- 

**Idea: can we get data on intermediates like incident disease or medication initiation?**

- Can get SureScript information but my understanding is we might not be able to pull that data when the model is deployed. We should have scripts sent in by the physician in the EHR. (JK)

*Data Cleaning Tasks*

1. Create Table 1 with sample size and baseline characteristics   
2. Create Table summarizing missingness across all covariates (no outcomes should be missing i think?)   
   1. Think about whether imputation would be helpful  
      1. An issue with this might be at deployment of the model in the EHR.(JK)  
3. Mark covariates as continuous versus categorical; for each continuous variable, decide how to model it, for each categorical variable, decide whether it needs to be consolidated.  
   1. Could it be based on bivariate outcome \~ covariate using restricted cubic splines with variable number of knots?

*Model Building and Evaluation Tasks*

1. Use bootstrap to calculate optimism corrected performance statistics using the full data?   
   1. Include all model building steps: variable selection, imputation, penalization/tuning parameter selection, estimation.  
   2. Calculate performance metrics in   
   3. Could do stratified bootstrap by year to do internal-external validation  
2.  Models to consider  
   1. Lasso Cox PH with baseline risk estimated using KP  
   2. Parametric Survival model based on Gompertz distribution  
      1. [https://www.jstatsoft.org/article/view/v070i08](https://www.jstatsoft.org/article/view/v070i08)  
   3. Survival Generalized Random Forests  
   4. Jarrod’s model  
   5. Lee model (original coeff, re-fit, and some hybrid?)  
3. Evaluation  
   1. AUC at different LE thresholds (5 years, 10 years, 15 years)  
   2. Calibration  
   3. Subgroups  
      1. Race  
      2. Age  
      3. Sex  
      4. Calendar year  
4. External  
   1. Validate in MetroHealth data

References:  
[https://pmc.ncbi.nlm.nih.gov/articles/PMC5578404/](https://pmc.ncbi.nlm.nih.gov/articles/PMC5578404/)  
[https://www.sciencedirect.com/science/article/pii/S0895435601003419](https://www.sciencedirect.com/science/article/pii/S0895435601003419)  
[https://link.springer.com/chapter/10.1007/978-3-030-16399-0\_5](https://link.springer.com/chapter/10.1007/978-3-030-16399-0_5)  
