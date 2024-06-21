library(testthat)
library(giftwrapr)

# Test get_r_version
test_that("get_r_version works correctly", {
  r_version <- get_r_version()
  expect_true(grepl("^\\d+\\.\\d+\\.\\d+$", r_version))
})

# Test get_package_versions
test_that("get_package_versions works correctly", {
  packages <- c("ggplot2", "dplyr")
  versions <- get_package_versions(packages)
  expect_true(all(names(versions) %in% packages))
  expect_true(all(grepl("^\\d+\\.\\d+\\.\\d+$", versions)))
})

# Test detect_packages with versions
test_that("detect_packages includes versions correctly", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  temp_file <- file.path(temp_dir, "test_script.R")
  writeLines(c("library(ggplot2)", "require(dplyr)"), temp_file)

  packages <- detect_packages(temp_dir, include_versions = TRUE)
  expect_true("ggplot2" %in% names(packages))
  expect_true("dplyr" %in% names(packages))
  expect_true(all(grepl("^\\d+\\.\\d+\\.\\d+$", packages)))

  unlink(temp_dir, recursive = TRUE)
})

# Test generate_dockerfile with versions
test_that("generate_dockerfile includes versions correctly", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  temp_file <- file.path(temp_dir, "test_script.R")
  writeLines(c("library(ggplot2)", "require(dplyr)"), temp_file)

  # Change working directory to the temporary project directory
  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd), add = TRUE)

  generate_dockerfile(temp_dir, use_latest_versions = FALSE, r_version = get_r_version(), platform = "linux/amd64")

  dockerfile_path <- file.path(temp_dir, "Dockerfile")
  dockerfile_content <- readLines(dockerfile_path)

  # Print Dockerfile content
  cat("\nGenerated Dockerfile:\n")
  cat(dockerfile_content, sep = "\n")

  expect_true(any(grepl("ggplot2", dockerfile_content)))
  expect_true(any(grepl("dplyr", dockerfile_content)))
  expect_equal(dockerfile_content[1], "# syntax=docker/dockerfile:1.2")
  expect_equal(dockerfile_content[2], sprintf("FROM --platform=linux/amd64 rocker/tidyverse:%s", get_r_version()))
  expect_equal(dockerfile_content[3], "RUN Rscript -e \"install.packages('remotes'); \\")
  expect_true(any(grepl("remotes::install_version\\('ggplot2', version = '3.5.0', dependencies = TRUE\\);", dockerfile_content)))
  expect_true(any(grepl("remotes::install_version\\('dplyr', version = '1.1.4', dependencies = TRUE\\);", dockerfile_content)))

  unlink(temp_dir, recursive = TRUE)
})

# Test generate_docker_compose
test_that("generate_docker_compose creates correct docker-compose.yml", {
  temp_dir <- tempfile()
  dir.create(temp_dir)

  generate_docker_compose(temp_dir, service_name = "app", image_name = "my_image")

  compose_path <- file.path(temp_dir, "docker-compose.yml")
  compose_content <- readLines(compose_path)

  # Print docker-compose.yml content
  cat("\nGenerated docker-compose.yml:\n")
  cat(compose_content, sep = "\n")

  expected_compose_content <- c(
    "version: '3.8'",
    "services:",
    "  app:",
    "    build: .",
    "    image: my_image",
    "    volumes:",
    "      - .:/home/rstudio/project",
    "    ports:",
    "      - '8787:8787'",
    "    environment:",
    "      - DISABLE_AUTH=true"
  )

  expect_equal(compose_content, expected_compose_content)

  unlink(temp_dir, recursive = TRUE)
})

# Test setup_docker_environment
test_that("setup_docker_environment creates correct Dockerfile and docker-compose.yml", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  temp_file <- file.path(temp_dir, "test_script.R")
  writeLines(c("library(ggplot2)", "require(dplyr)"), temp_file)

  # Change working directory to the temporary project directory
  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd), add = TRUE)

  setup_docker_environment(temp_dir, use_latest_versions = FALSE, r_version = get_r_version(), platform = "linux/amd64")

  # Verify Dockerfile content
  dockerfile_path <- file.path(temp_dir, "Dockerfile")
  dockerfile_content <- readLines(dockerfile_path)

  # Print Dockerfile content
  cat("\nGenerated Dockerfile:\n")
  cat(dockerfile_content, sep = "\n")

  expect_equal(dockerfile_content[1], "# syntax=docker/dockerfile:1.2")
  expect_equal(dockerfile_content[2], sprintf("FROM --platform=linux/amd64 rocker/tidyverse:%s", get_r_version()))
  expect_equal(dockerfile_content[3], "RUN Rscript -e \"install.packages('remotes'); \\")
  expect_true(any(grepl("remotes::install_version\\('ggplot2', version = '3.5.0', dependencies = TRUE\\);", dockerfile_content)))
  expect_true(any(grepl("remotes::install_version\\('dplyr', version = '1.1.4', dependencies = TRUE\\);", dockerfile_content)))

  # Verify docker-compose.yml content
  compose_path <- file.path(temp_dir, "docker-compose.yml")
  compose_content <- readLines(compose_path)

  # Print docker-compose.yml content
  cat("\nGenerated docker-compose.yml:\n")
  cat(compose_content, sep = "\n")

  project_name <- basename(temp_dir)
  expected_compose_content <- c(
    "version: '3.8'",
    "services:",
    sprintf("  %s:", project_name),
    "    build: .",
    sprintf("    image: %s", project_name),
    "    volumes:",
    "      - .:/home/rstudio/project",
    "    ports:",
    "      - '8787:8787'",
    "    environment:",
    "      - DISABLE_AUTH=true"
  )

  expect_equal(compose_content, expected_compose_content)

  unlink(temp_dir, recursive = TRUE)
})
