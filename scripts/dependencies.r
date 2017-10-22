#!/usr/bin/env Rscript

check_install <- function(pkg) {
  not_installed <- !(pkg %in% installed.packages())
  if (any(not_installed))
    install.packages(pkg[not_installed], repos = "https://cran.r-project.org")
  else
    cat("All dependencies are installed!\n")
}

check_install(commandArgs(trailingOnly = T))