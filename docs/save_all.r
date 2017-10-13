#!/usr/bin/env Rscript
require("mldr")
require("mldr.datasets")
setwd("~/Documentos/research/publications/2017/multilabel-neucom/completas")

go <- function(mld, name) {
  file <- paste0("../full_datasets/", name, ".rds")
  saveRDS(mld, file = file, compress = "xz")
}

main_arff <- function(mldname = commandArgs(trailingOnly = T), path = "./") {
  go(mldr::read.arff(paste0(path, mldname)), mldname)
}

main <- function(mldname = commandArgs(trailingOnly = T)) {
  if (length(mldname) == 1) {
    dataset <- get(mldname)
    
    if (class(dataset) != "mldr") {
      # mldname <- check_n_load.mldr(mldname)
      mldname <- tryCatch(
        load(paste0("../additional-data/", mldname, ".rda")),
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

# datasets <- read.csv("https://github.com/fcharte/mldr.datasets/raw/master/inst/extdata/mldrs.csv", header = T, stringsAsFactors = F)$Name
# datasets <- setdiff(datasets, .w("eurlexdc_test eurlexdc_tra eurlexev_test eurlexev_tra eurlexsm_test eurlexsm_tra"))
# datasets <- setdiff(datasets, 
#                     .w("bibtex bookmarks corel16k001 corel16k002 corel16k003 corel16k004 corel16k005 corel16k006 corel16k007 corel16k008 corel16k009 corel16k010 corel5k delicious enron"))
# datasets <- c(datasets, "stackex_coffee")
# datasets <- .w("tmc2007_500")

datasets <- .w("eurlexdc eurlexev eurlexsm")

for (x in datasets) {
  cat("Incoming:", x, "\n")
  main_arff(x, path = "../eurlex/")
}
