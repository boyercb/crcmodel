# 01_data_processing.R
# Functions for loading and cleaning raw data

#' Load the life expectancy dataset
#' @param path Path to the RDS file
#' @return A tibble with the raw data
load_raw_data <- function(path = "data/le_data_set.rds") {

  readRDS(path) |>
    tibble::as_tibble()
}

#' Define the analytic cohort
#' Apply inclusion/exclusion criteria
#' @param data Raw data tibble
#' @return Filtered tibble meeting cohort criteria
define_cohort <- function(data) {

  # TODO: Define inclusion/exclusion criteria

  # Example structure:
  # data |>

  #   filter(age >= 75) |>

  #   filter(!is.na(contact_date)) |>
  #   filter(contact_date >= as.Date("2015-01-01"))
  

  data
}

#' Create outcome variables for survival analysis
#' @param data Cohort data
#' @return Data with survival outcome variables
create_outcomes <- function(data) {
  data |>
    dplyr::mutate(
      # Event indicator: 1 = death, 0 = censored
      event = dplyr::if_else(!is.na(death_date), 1L, 0L),
      
      # Follow-up time in days
      # TODO: Define appropriate end of follow-up for censored patients
      followup_end = dplyr::coalesce(death_date, last_contact_date),
      
      time_days = as.numeric(
        difftime(followup_end, contact_date, units = "days")
      ),
      
      # Convert to years for interpretability
      time_years = time_days / 365.25
    ) |>
    # Remove invalid follow-up times
    dplyr::filter(time_days > 0)
}

#' Select candidate predictor variables
#' @param data Data with outcomes
#' @return Data with only relevant columns for modeling
select_predictors <- function(data) {
}
