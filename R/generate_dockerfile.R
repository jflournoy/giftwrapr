#' Generate Dockerfile for the project
#'
#' @param project_dir The path to the project directory (assumed to be the current working directory)
#' @param additional_cmds Additional Dockerfile commands to be added (optional)
#' @param use_latest_versions Logical indicating whether to use the latest versions
#' @export
generate_dockerfile <- function(project_dir = getwd(), additional_cmds = NULL, use_latest_versions = FALSE) {
  r_version <- get_r_version()
  packages <- detect_packages(project_dir, include_versions = TRUE, use_latest_versions = use_latest_versions)

  dockerfile <- c(
    sprintf("FROM rocker/tidyverse:%s", r_version),
    "RUN R -e \"install.packages(c("
  )

  if (use_latest_versions) {
    package_lines <- paste0("'", names(packages), "'", collapse = ", ")
  } else {
    package_lines <- paste0(
      sprintf("'%s' = '%s'", names(packages), packages),
      collapse = ", "
    )
  }

  dockerfile <- c(
    dockerfile,
    package_lines,
    "))\"",
    "COPY . /project"
  )

  if (!is.null(additional_cmds)) {
    dockerfile <- c(dockerfile, additional_cmds)
  }

  writeLines(dockerfile, file.path(project_dir, "Dockerfile"))
}
