#' Generate Dockerfile for the project
#'
#' @param project_dir The path to the project directory (assumed to be the current working directory)
#' @param additional_cmds Additional Dockerfile commands to be added (optional)
#' @param use_latest_versions Logical indicating whether to use the latest versions
#' @param r_version The R version to be used in the Docker image (default is "latest")
#' @param platform The platform to be used (default is "linux/amd64")
#' @export
generate_dockerfile <- function(project_dir = getwd(), additional_cmds = NULL, use_latest_versions = FALSE, r_version = "latest", platform = "linux/amd64") {
  packages <- detect_packages(project_dir, include_versions = TRUE, use_latest_versions = use_latest_versions)

  if (!dir.exists(project_dir)) {
    dir.create(project_dir, recursive = TRUE)
  }

  package_lines <- if (use_latest_versions) {
    paste0("'", names(packages), "'", collapse = ", ")
  } else {
    paste0(
      sprintf("'%s' = '%s'", names(packages), packages),
      collapse = ", "
    )
  }

  package_lines_split <- strwrap(package_lines, width = 70, simplify = FALSE)
  package_lines_with_backslashes <- paste(package_lines_split, collapse = " \\\n")

  dockerfile <- c(
    "# syntax=docker/dockerfile:1.2",
    sprintf("FROM --platform=%s rocker/tidyverse:%s", platform, r_version),
    "RUN R -e \"install.packages(c( \\\n",
    package_lines_with_backslashes,
    "))\""
  )

  if (!is.null(additional_cmds)) {
    dockerfile <- c(dockerfile, additional_cmds)
  }

  writeLines(dockerfile, file.path(project_dir, "Dockerfile"))
}
