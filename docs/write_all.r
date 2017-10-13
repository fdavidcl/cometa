#!/usr/bin/env Rscript
require("mldr")
require("mldr.datasets")

sparseness <- function(mld) {
  sum(mld$dataset == 0) / prod(dim(mld$dataset))
}

should_sparse <- function(mld) {
  sparseness(mld) > 0.5
}

go <- function(dataset, name) {
  mldr.datasets::write.mldr(
    dataset[1:2],
    basename = paste0("../multilabel-repo/", name),
    sparse = should_sparse(dataset)
  )
}

main <- function(mldname = commandArgs(trailingOnly = T)) {
  if (length(mldname) == 1) {
    dataset <- get(mldname)
    
    if (class(dataset) != "mldr") {
      # mldname <- check_n_load.mldr(mldname)
      mldname <- tryCatch(
        load(paste0("../mldr.datasets/additional-data/", mldname, ".rda")),
        error = function(e) {
          mldname <- tryCatch(
            load(paste0("../mldr.datasets/data/", mldname, ".rda")),
            error = { cat("Couldn't find dataset :(") }
          ) 
          
          if (!is.null(mldname))
            dataset <- get(mldname)
        }
      ) 
      
      if (!is.null(mldname))
        dataset <- get(mldname)
    }
    
    if (class(dataset) == "mldr") {
      go(dataset, mldname)
    } else {
      cat("Please specify a valid mld name\n")
    }
  } else {
    cat("Usage: partition_mld.r mld_name\n")
  }
}

.w <- function(x) strsplit(x, " ")[[1]]

datasets <- read.csv("https://gitlab.com/fdavidcl/mldr.datasets/raw/master/inst/extdata/mldrs.csv", header = T, stringsAsFactors = F)$Name
#datasets <- setdiff(datasets, .w("eurlexdc_test eurlexdc_tra eurlexev_test eurlexev_tra eurlexsm_test eurlexsm_tra imdb nuswide_BoW nuswide_VLAD tmc2007 tmc2007_500"))
#datasets <- .w("yahoo_arts yahoo_education yahoo_recreation yahoo_social yahoo_business yahoo_entertainment yahoo_reference yahoo_society yahoo_computers yahoo_health yahoo_science yeast")
#datasets <- .w("tmc2007")

for (x in datasets) {
  cat("Incoming:", x, "\n")
  main(x)
}