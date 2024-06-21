#' Generate docker-compose.yml for the project
#'
#' @param project_dir The path to the project directory (assumed to be the current working directory)
#' @param service_name The name of the service (default is "app")
#' @param image_name The name of the Docker image (default is "my_image")
#' @export
generate_docker_compose <- function(project_dir = getwd(), service_name = "app", image_name = "my_image") {
  compose_file <- c(
    "version: '3.8'",
    "services:",
    sprintf("  %s:", service_name),
    "    build: .",
    sprintf("    image: %s", image_name),
    "    volumes:",
    "      - .:/home/rstudio/project",
    "    ports:",
    "      - '8787:8787'",
    "    environment:",
    "      - DISABLE_AUTH=true"
  )

  writeLines(compose_file, file.path(project_dir, "docker-compose.yml"))
}
