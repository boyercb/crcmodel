# 08_reporting.R
# Functions for tables, figures, and manuscript reporting

#' Create Table 1 (baseline characteristics)
#' @param data Analytic dataset
#' @param by Optional stratification variable
#' @return A gtsummary table
create_table1 <- function(data, by = NULL) {
  # Select variables for Table 1
  # TODO: Customize variable selection
  
  tbl <- data |>
    gtsummary::tbl_summary(
      by = {{ by }},
      statistic = list(
        gtsummary::all_continuous() ~ "{mean} ({sd})",
        gtsummary::all_categorical() ~ "{n} ({p}%)"
      ),
      missing = "ifany"
    )
  
  if (!is.null(by)) {
    tbl <- tbl |>
      gtsummary::add_p() |>
      gtsummary::add_overall()
  }
  
  tbl
}

#' Create model coefficients table
#' @param model Fitted model
#' @return A gtsummary table
create_coefficients_table <- function(model) {
  gtsummary::tbl_regression(
    model,
    exponentiate = TRUE,
    label = list()
  ) |>
    gtsummary::add_global_p()
}

#' Create model comparison table
#' @param models Named list of fitted models
#' @param metrics_df Data frame with performance metrics
#' @return A gt table
create_comparison_table <- function(models, metrics_df) {
  metrics_df |>
    gt::gt() |>
    gt::fmt_number(
      columns = where(is.numeric),
      decimals = 3
    ) |>
    gt::tab_header(
      title = "Model Comparison",
      subtitle = "Performance metrics from internal validation"
    )
}

#' Create Kaplan-Meier plot by risk groups
#' @param data Data with predicted risk groups
#' @param risk_var Name of risk group variable
#' @return A ggplot object
plot_km_by_risk <- function(data, risk_var = "risk_group") {
}

#' Save model for deployment
#' @param workflow Fitted workflow
#' @param path Output path
#' @return Path to saved model
save_model <- function(workflow, path = "output/models/final_model.rds") {
  # Bundle for portability
  bundled <- bundle::bundle(workflow)
  saveRDS(bundled, path)
  path
}

#' Generate TRIPOD checklist items
#' @return A tibble with TRIPOD items and status
create_tripod_checklist <- function() {
  tibble::tribble(
    ~item, ~section, ~description, ~status, ~location,
    "1", "Title", "Identify the study as developing/validating a prediction model", NA, NA,
    "2", "Abstract", "Provide summary of objectives, methods, results", NA, NA,
    "3a", "Background", "Explain medical context and rationale", NA, NA,
    "3b", "Background", "Specify objectives including whether developing/validating", NA, NA,
    "4a", "Methods - Source", "Describe study design and setting", NA, NA,
    "4b", "Methods - Source", "Specify key study dates", NA, NA,
    "5a", "Methods - Participants", "Specify eligibility criteria", NA, NA,
    "5b", "Methods - Participants", "Give details of treatments received", NA, NA,
    "6a", "Methods - Outcome", "Clearly define outcome", NA, NA,
    "6b", "Methods - Outcome", "Report actions to blind outcome assessment", NA, NA,
    "7a", "Methods - Predictors", "Define all predictors", NA, NA,
    "7b", "Methods - Predictors", "Report actions to blind predictor assessment", NA, NA,
    "8", "Methods - Sample size", "Explain how sample size was determined", NA, NA,
    "9", "Methods - Missing data", "Describe how missing data were handled", NA, NA,
    "10a", "Methods - Analysis", "Describe how predictors were handled", NA, NA,
    "10b", "Methods - Analysis", "Specify type of model and selection method", NA, NA,
    "10d", "Methods - Analysis", "Specify measures to assess model performance", NA, NA
  )
}
