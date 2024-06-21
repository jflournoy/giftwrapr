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

# Test setup_docker_environment
test_that("setup_docker_environment creates correct Dockerfile and docker-compose.yml", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  temp_file <- file.path(temp_dir, "test_script.R")
  writeLines(c("library(ggplot2)", "require(dplyr)"), temp_file)

  # Change working directory to the temporary project directory
  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd), add = TRUE)

  setup_docker_environment(temp_dir, use_latest_versions = FALSE, r_version = "latest", platform = "linux/amd64")

  # Verify Dockerfile content
  dockerfile_path <- file.path(temp_dir, "Dockerfile")
  dockerfile_content <- readLines(dockerfile_path)

  # Print Dockerfile content
  cat("\nGenerated Dockerfile:\n")
  cat(dockerfile_content, sep = "\n")

  expect_true(any(grepl("ggplot2", dockerfile_content)))
  expect_true(any(grepl("dplyr", dockerfile_content)))
  expect_true(any(grepl("^FROM --platform=linux/amd64 rocker/tidyverse:", dockerfile_content)))
  expect_true(any(grepl("RUN R -e \"install.packages\\(c\\(", dockerfile_content)))
  expect_true(any(grepl("\\\\", dockerfile_content)))

  # Verify docker-compose.yml content
  compose_path <- file.path(temp_dir, "docker-compose.yml")
  compose_content <- readLines(compose_path)

  # Print docker-compose.yml content
  cat("\nGenerated docker-compose.yml:\n")
  cat(compose_content, sep = "\n")

  project_name <- basename(temp_dir)
  expect_true(any(grepl("version: '3.8'", compose_content)))
  expect_true(any(grepl("services:", compose_content)))
  expect_true(any(grepl(sprintf("  %s:", project_name), compose_content)))
  expect_true(any(grepl("build: .", compose_content)))
  expect_true(any(grepl(sprintf("image: %s", project_name), compose_content)))
  expect_true(any(grepl("volumes:", compose_content)))
  expect_true(any(grepl("ports:", compose_content)))
  expect_true(any(grepl("environment:", compose_content)))

  unlink(temp_dir, recursive = TRUE)
})
