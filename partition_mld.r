#!/usr/bin/env Rscript

require(mldr)
require(mldr.datasets)

STRATEGIES <-
  list(rand = mldr.datasets::random.kfolds,
       stra = mldr.datasets::stratified.kfolds)
FORMATS <-
  list(
    arff = c("MULAN", "MEKA"),
    svm = "LibSVM",
    dat = "KEEL"
  )
SEED <- 23456123
ALT_SEED <- 31638452

# validation functions:
# (mld : "mldr", f : (mld, k, seed) -> mldr.folds) -> list() : named list with a mldr for each file to be written
VALIDATION = list (
  hout = function(mld, f) {
    folds <- f(mld, k = 10, seed = SEED)
    list(
      tra = Reduce(`+`, lapply(folds[1:6], function(x) x$train)),
      tst = Reduce(`+`, lapply(folds[7:10], function(x) x$train))
    )
  },
  
  "2x5" = function(mld, f) {
    folds <- c(f(mld, k = 5, seed = SEED),
               f(mld, k = 5, seed = ALT_SEED))
    
    # Name each fold and flatten the list of lists
    Reduce(c, lapply(1:length(folds), function(i) {
      l = list(folds[[i]]$train, folds[[i]]$test)
      names(l) <- c(paste0(i, "-tra"), paste0(i, "-tst"))
      l
    }))
  },
  
  "1x10" = function(mld, f) {
    folds <- f(mld, k = 10, seed = SEED)
    
    # Name each fold and flatten the list of lists
    Reduce(c, lapply(1:length(folds), function(i) {
      l = list(folds[[i]]$train, folds[[i]]$test)
      names(l) <- c(paste0(i, "-tra"), paste0(i, "-tst"))
      l
    }))
  }
)

partition <- function(mld, name) {
  for (s in 1:length(STRATEGIES)) {
    for (v in 1:length(VALIDATION)) {
      fold_list <- VALIDATION[[v]](mld, STRATEGIES[[s]])
      
      for (g in names(fold_list)) {
        basename <- paste(name, names(STRATEGIES)[s], names(VALIDATION)[v], g, sep = "-")
        
        for (f in FORMATS) {
          mldr.datasets::write.mldr(fold_list[[g]], format = f, basename = basename)
        }
        
        # RDS format
        saveRDS(fold_list[[g]], file = paste0(basename, ".rds"))
        cat("Exported", basename, "\n")
      }
    }
  }
}

main <- function() {
  mldname <- commandArgs(trailingOnly = T)
  
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
      partition(dataset, mldname)
    } else {
      cat("Please specify a valid mld name\n")
    }
  } else {
    cat("Usage: partition_mld.r mld_name\n")
  }
}

main()