#' Setup Docker environment for the project
#'
#' @param project_dir The path to the project directory (assumed to be the current working directory)
#' @param use_latest_versions Logical indicating whether to use the latest versions
#' @param r_version The R version to be used in the Docker image (default is the current R version)
#' @param platform The platform to be used (default is "linux/amd64")
#' @param service_name The name of the service (default is the project directory name)
#' @export
setup_docker_environment <- function(project_dir = getwd(), use_latest_versions = FALSE, r_version = get_r_version(), platform = "linux/amd64", service_name = basename(normalizePath(project_dir))) {
  image_name <- service_name

  # Generate Dockerfile
  generate_dockerfile(project_dir, use_latest_versions = use_latest_versions, r_version = r_version, platform = platform)

  # Generate docker-compose.yml
  generate_docker_compose(project_dir, service_name = service_name, image_name = image_name)
}
