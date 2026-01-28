# 06_tuning.R
# Hyperparameter tuning and resampling

#' Create cross-validation folds
#' @param data Training data
#' @param v Number of folds
#' @param repeats Number of repeats
#' @param strata Variable to stratify on
#' @return rsample rset object
create_cv_folds <- function(data, v = 10, repeats = 1, strata = "event") {
  if (repeats > 1) {
    rsample::vfold_cv(
      data,
      v = v,
      repeats = repeats,
      strata = tidyselect::all_of(strata)
    )
  } else {
    rsample::vfold_cv(
      data,
      v = v,
      strata = tidyselect::all_of(strata)
    )
  }
}

#' Create nested cross-validation for honest performance estimates
#' @param data Training data
#' @param outer_v Outer CV folds
#' @param inner_v Inner CV folds
#' @return Nested resampling object
create_nested_cv <- function(data, outer_v = 5, inner_v = 5, strata = "event") {
  rsample::nested_cv(
    data,
    outside = rsample::vfold_cv(v = outer_v, strata = tidyselect::all_of(strata)),
    inside = rsample::vfold_cv(v = inner_v, strata = tidyselect::all_of(strata))
  )
}

#' Create bootstrap resamples for internal validation
#' @param data Training data
#' @param times Number of bootstrap samples
#' @param strata Variable to stratify on
#' @return Bootstrap rset object
create_bootstrap <- function(data, times = 200, strata = "event") {
  rsample::bootstraps(
    data,
    times = times,
    strata = tidyselect::all_of(strata)
  )
}

#' Define tuning grid for elastic net
#' @param levels Number of levels per parameter
#' @return A grid data frame
create_glmnet_grid <- function(levels = 10) {
  dials::grid_regular(
    dials::penalty(range = c(-4, 0)),
    dials::mixture(range = c(0, 1)),
    levels = levels
  )
}

#' Define tuning grid for random forest
#' @param mtry_range Range for mtry as proportion of predictors
#' @param levels Number of levels
#' @return A grid data frame
create_rf_grid <- function(levels = 5) {
  dials::grid_regular(
    dials::mtry(range = c(5, 50)),
    dials::min_n(range = c(10, 50)),
    levels = levels
  )
}

#' Define tuning grid for xgboost
#' @param levels Number of levels
#' @return A grid data frame
create_xgb_grid <- function(levels = 5) {
  dials::grid_latin_hypercube(
    dials::trees(range = c(100, 1000)),
    dials::tree_depth(range = c(3, 8)),
    dials::learn_rate(range = c(-3, -1)),
    dials::min_n(range = c(10, 40)),
    size = levels^2
  )
}

#' Tune a workflow using grid search
#' @param workflow A workflow object
#' @param resamples Resampling object
#' @param grid Tuning grid
#' @param metrics Metric set to optimize
#' @return Tuning results
tune_workflow <- function(workflow, resamples, grid, metrics = NULL) {
  if (is.null(metrics)) {
    # Default metrics for survival
    metrics <- yardstick::metric_set(
      yardstick::concordance_survival,
      yardstick::brier_survival_integrated
    )
  }
  

  tune::tune_grid(
    workflow,
    resamples = resamples,
    grid = grid,
    metrics = metrics,
    control = tune::control_grid(
      verbose = TRUE,
      save_pred = TRUE,
      save_workflow = TRUE
    )
  )
}
