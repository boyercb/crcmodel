# 03_recipes.R
# Recipe definitions for preprocessing within tidymodels

#' Create the base preprocessing recipe
#' @param data Training data
#' @return A recipe object
create_base_recipe <- function(data) {
  recipes::recipe(x = data) |>
    
    # Update roles
    # TODO: Set outcome and predictor roles
    # recipes::update_role(time_years, new_role = "outcome") |>
    # recipes::update_role(event, new_role = "outcome") |>
    
    # Handle missing values
    # Impute numeric predictors with median
    recipes::step_impute_median(recipes::all_numeric_predictors()) |>
    
    # Impute nominal predictors with mode
    recipes::step_impute_mode(recipes::all_nominal_predictors()) |>
    
    # Handle categorical variables
    # Collapse rare factor levels
    recipes::step_other(
      recipes::all_nominal_predictors(),
      threshold = 0.01,
      other = "other"
    ) |>
    
    # Create dummy variables
    recipes::step_dummy(
      recipes::all_nominal_predictors(),
      one_hot = FALSE
    ) |>
    
    # Handle numeric predictors
    # Remove near-zero variance predictors
    recipes::step_nzv(recipes::all_predictors()) |>
    
    # Normalize numeric predictors (for regularized models)
    recipes::step_normalize(recipes::all_numeric_predictors()) |>
    
    # Remove highly correlated predictors
    recipes::step_corr(
      recipes::all_numeric_predictors(),
      threshold = 0.9
    )
}

#' Create recipe for tree-based models (no normalization needed)
#' @param data Training data
#' @return A recipe object
create_tree_recipe <- function(data) {
  recipes::recipe(x = data) |>
    
    # Imputation
    recipes::step_impute_median(recipes::all_numeric_predictors()) |>
    recipes::step_impute_mode(recipes::all_nominal_predictors()) |>
    
    # Collapse rare levels
    recipes::step_other(
      recipes::all_nominal_predictors(),
      threshold = 0.01
    ) |>
    
    # Dummy encoding (trees can handle factors but xgboost needs numeric)
    recipes::step_dummy(
      recipes::all_nominal_predictors(),
      one_hot = TRUE
    ) |>
    
    # Remove near-zero variance
    recipes::step_nzv(recipes::all_predictors())
}

#' Create recipe with splines for flexible relationships
#' @param data Training data
#' @param continuous_vars Variables to add splines for
#' @return A recipe object
create_spline_recipe <- function(data, continuous_vars = c("age", "bmi_calculated")) {
  create_base_recipe(data) |>
    recipes::step_ns(
      tidyselect::all_of(continuous_vars),
      deg_free = 4
    )
}
