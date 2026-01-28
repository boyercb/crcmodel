# 04_model_specs.R
# Model specifications using parsnip

#' Cox proportional hazards model specification
#' @return A parsnip model specification
spec_cox_ph <- function() {
  parsnip::proportional_hazards() |>
    parsnip::set_engine("survival") |>
    parsnip::set_mode("censored regression")
}

#' Regularized Cox model (elastic net)
#' @param penalty Regularization penalty (tune)
#' @param mixture Elastic net mixing (0 = ridge, 1 = lasso)
#' @return A parsnip model specification
spec_cox_glmnet <- function(penalty = tune::tune(), mixture = tune::tune()) {
  parsnip::proportional_hazards(
    penalty = penalty,
    mixture = mixture
  ) |>
    parsnip::set_engine("glmnet") |>
    parsnip::set_mode("censored regression")
}

#' Random survival forest specification
#' @param mtry Number of predictors to sample (tune)
#' @param min_n Minimum node size (tune)
#' @param trees Number of trees
#' @return A parsnip model specification
spec_rsf <- function(mtry = tune::tune(), min_n = tune::tune(), trees = 500) {
  parsnip::rand_forest(
    mtry = mtry,
    min_n = min_n,
    trees = trees
  ) |>
    parsnip::set_engine("ranger") |>
    parsnip::set_mode("censored regression")
}

#' XGBoost survival model specification
#' @return A parsnip model specification
spec_xgb_surv <- function(
    trees = tune::tune(),
    tree_depth = tune::tune(),
    learn_rate = tune::tune(),
    min_n = tune::tune()
) {
  parsnip::boost_tree(
    trees = trees,
    tree_depth = tree_depth,
    learn_rate = learn_rate,
    min_n = min_n
  ) |>
    parsnip::set_engine("xgboost") |>
    parsnip::set_mode("censored regression")
}

#' Logistic regression for binary outcome (e.g., 5-year mortality)
#' @return A parsnip model specification
spec_logistic <- function() {
  parsnip::logistic_reg() |>
    parsnip::set_engine("glm") |>
    parsnip::set_mode("classification")
}

#' Regularized logistic regression
#' @return A parsnip model specification
spec_logistic_glmnet <- function(penalty = tune::tune(), mixture = tune::tune()) {
  parsnip::logistic_reg(
    penalty = penalty,
    mixture = mixture
  ) |>
    parsnip::set_engine("glmnet") |>
    parsnip::set_mode("classification")
}
