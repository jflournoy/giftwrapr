#' Get the current R version
#'
#' @return A string representing the current R version
#' @export
get_r_version <- function() {
  return(as.character(getRversion()))
}

#' Get the versions of installed packages
#'
#' @param packages A character vector of package names
#' @return A named vector of package versions
#' @export
get_package_versions <- function(packages) {
  installed <- installed.packages()
  versions <- installed[packages, "Version"]
  names(versions) <- packages
  return(versions)
}

