# 00_utils.R
# Utility functions used across the pipeline

#' Set random seed for reproducibility
#' @param seed Integer seed value
set_seed <- function(seed = 2026) {
  set.seed(seed)
}

#' Check if required packages are installed
#' @param packages Character vector of package names
check_packages <- function(packages) {
  missing <- packages[!packages %in% installed.packages()[, "Package"]]
  if (length(missing) > 0) {
    stop(
      "Missing packages: ", paste(missing, collapse = ", "),
      "\nInstall with: install.packages(c('", paste(missing, collapse = "', '"), "'))"
    )
  }
  invisible(TRUE)
}

#' Create a timestamp string for versioning outputs
#' @return Character string with current timestamp
timestamp_string <- function() {
  format(Sys.time(), "%Y%m%d_%H%M%S")
}

#' Safely save an object with backup
#' @param object Object to save
#' @param path File path
#' @param backup Whether to backup existing file
save_with_backup <- function(object, path, backup = TRUE) {
  if (backup && file.exists(path)) {
    backup_path <- paste0(
      tools::file_path_sans_ext(path),
      "_backup_", timestamp_string(),
      ".", tools::file_ext(path)
    )
    file.copy(path, backup_path)
    message("Backed up existing file to: ", backup_path)
  }
  saveRDS(object, path)
  message("Saved to: ", path)
  invisible(path)
}

#' Format p-values for reporting
#' @param p Numeric p-value
#' @param digits Number of significant digits
#' @return Formatted string
format_pvalue <- function(p, digits = 3) {
  dplyr::case_when(
    p < 0.001 ~ "<0.001",
    p < 0.01 ~ sprintf("%.3f", p),
    TRUE ~ sprintf(paste0("%.", digits, "f"), p)
  )
}

#' Format confidence intervals
#' @param estimate Point estimate
#' @param lower Lower bound
#' @param upper Upper bound
#' @param digits Number of decimal places
#' @return Formatted string
format_ci <- function(estimate, lower, upper, digits = 2) {
  sprintf(
    paste0("%.", digits, "f (%.", digits, "f, %.", digits, "f)"),
    estimate, lower, upper
  )
}

#' Log a message with timestamp
#' @param ... Message components
log_message <- function(...) {
  message("[", Sys.time(), "] ", ...)
}
