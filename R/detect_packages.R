#' Detect R packages in the project with optional versions
#'
#' @param project_dir The path to the project directory
#' @param include_versions Logical indicating whether to include package versions
#' @param use_latest_versions Logical indicating whether to use the latest versions
#' @return A named vector of package names and their versions (if requested)
#' @export
detect_packages <- function(project_dir, include_versions = FALSE, use_latest_versions = FALSE) {
  if (!dir.exists(project_dir)) {
    stop("Project directory does not exist.")
  }

  r_files <- list.files(project_dir, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
  if (length(r_files) == 0) {
    warning("No R files found in the project directory.")
    return(character(0))
  }

  scripts <- lapply(r_files, readLines, warn = FALSE)
  all_lines <- unlist(scripts)

  packages <- unique(unlist(stringr::str_extract_all(all_lines, "(?<=library\\()\\w+|(?<=require\\()\\w+")))

  if (include_versions) {
    if (use_latest_versions) {
      warning("Using the latest versions of packages.")
      return(packages)
    } else {
      versions <- get_package_versions(packages)
      return(versions)
    }
  } else {
    return(packages)
  }
}
