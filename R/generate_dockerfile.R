#' Generate Dockerfile for the project
#'
#' @param project_dir The path to the project directory (assumed to be the current working directory)
#' @param additional_cmds Additional Dockerfile commands to be added (optional)
#' @param use_latest_versions Logical indicating whether to use the latest versions
#' @param r_version The R version to be used in the Docker image (default is the current R version)
#' @param platform The platform to be used (default is "linux/amd64")
#' @export
generate_dockerfile <- function(project_dir = getwd(), additional_cmds = NULL, use_latest_versions = FALSE, r_version = get_r_version(), platform = "linux/amd64") {
  packages <- detect_packages(project_dir, include_versions = TRUE, use_latest_versions = use_latest_versions)

  if (!dir.exists(project_dir)) {
    dir.create(project_dir, recursive = TRUE)
  }

  package_install_commands <- if (use_latest_versions) {
    paste0("    remotes::install_version('", names(packages), "', dependencies = TRUE);", collapse = " \\\n")
  } else {
    paste0(
      sprintf("    remotes::install_version('%s', version = '%s', dependencies = TRUE);", names(packages), packages),
      collapse = " \\\n"
    )
  }

  dockerfile <- c(
    "# syntax=docker/dockerfile:1.2",
    sprintf("FROM --platform=%s rocker/tidyverse:%s", platform, r_version),
    sprintf("RUN Rscript -e \"install.packages('remotes'); \\\n%s\"",
            package_install_commands)
  )

  if (!is.null(additional_cmds)) {
    dockerfile <- c(dockerfile, additional_cmds)
  }

  writeLines(dockerfile, file.path(project_dir, "Dockerfile"))
}
