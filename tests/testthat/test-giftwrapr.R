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

  generate_dockerfile(temp_dir, use_latest_versions = FALSE)

  dockerfile_path <- file.path(temp_dir, "Dockerfile")
  dockerfile_content <- readLines(dockerfile_path)

  # Print Dockerfile content
  cat("\nGenerated Dockerfile:\n")
  cat(dockerfile_content, sep = "\n")

  expect_true(any(grepl("ggplot2", dockerfile_content)))
  expect_true(any(grepl("dplyr", dockerfile_content)))
  expect_true(any(grepl(sprintf("^FROM rocker/tidyverse:%s", get_r_version()), dockerfile_content)))
  expect_true(any(grepl("COPY . /project", dockerfile_content)))

  unlink(temp_dir, recursive = TRUE)
})
