# 05_workflows.R
# Combine recipes and model specs into workflows

#' Create a workflow from recipe and model spec
#' @param recipe A recipe object
#' @param model_spec A parsnip model specification
#' @return A workflow object
create_workflow <- function(recipe, model_spec) {
  workflows::workflow() |>
    workflows::add_recipe(recipe) |>
    workflows::add_model(model_spec)
}

#' Create a workflow set for comparing multiple models
#' @param recipes Named list of recipes
#' @param model_specs Named list of model specifications
#' @return A workflow set
create_workflow_set <- function(recipes, model_specs) {
  workflowsets::workflow_set(
    preproc = recipes,
    models = model_specs,
    cross = TRUE
  )
}

#' Create standard workflow set for survival models
#' @param data Training data for recipe creation
#' @return A workflow set with multiple model types
create_survival_workflow_set <- function(data) {
  # Define recipes
  recipes <- list(
    base = create_base_recipe(data),
    tree = create_tree_recipe(data)
  )
  
  # Define model specifications
  model_specs <- list(
    cox = spec_cox_ph(),
    cox_glmnet = spec_cox_glmnet(),
    rsf = spec_rsf()
  )
  
  # Create workflow set
  # Note: Match appropriate recipes to models
  workflowsets::workflow_set(
    preproc = list(
      base = recipes$base,
      base = recipes$base,
      tree = recipes$tree
    ),
    models = list(
      cox = model_specs$cox,
      cox_glmnet = model_specs$cox_glmnet,
      rsf = model_specs$rsf
    ),
    cross = FALSE
  )
}
