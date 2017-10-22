#!/usr/bin/env Rscript

require(mldr)
require(mldr.datasets)

STRATEGIES <-
  list(rand = mldr.datasets::random.kfolds,
       stra = mldr.datasets::stratified.kfolds,
       iter = mldr.datasets::iterative.stratification.kfolds)
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
    folds <- f(mld, k = 10, seed = SEED, get.indices = T)
    list(
      tra = Reduce(c, lapply(folds[1:6], function(x) x$test)),
      tst = Reduce(c, lapply(folds[7:10], function(x) x$test))
    )
  },

  "2x5" = function(mld, f) {
    folds <- c(f(mld, k = 5, seed = SEED, get.indices = T),
               f(mld, k = 5, seed = ALT_SEED, get.indices = T))

    # Name each fold and flatten the list of lists
    Reduce(c, lapply(1:length(folds), function(i) {
      l = list(folds[[i]]$train, folds[[i]]$test)
      names(l) <- c(paste0(i, "-tra"), paste0(i, "-tst"))
      l
    }))
  },

  "1x10" = function(mld, f) {
    folds <- f(mld, k = 10, seed = SEED, get.indices = T)

    # Name each fold and flatten the list of lists
    Reduce(c, lapply(1:length(folds), function(i) {
      l = list(folds[[i]]$train, folds[[i]]$test)
      names(l) <- c(paste0(i, "-tra"), paste0(i, "-tst"))
      l
    }))
  }
)

sparseness <- function(mld) {
  sum(mld$dataset == 0) / prod(dim(mld$dataset))
}

should_sparse <- function(mld) {
  sparseness(mld) > 0.5
}

partition <- function(mld, name) {
  sparse = should_sparse(mld)

  for (s in 1:length(STRATEGIES)) {
    for (v in 1:length(VALIDATION)) {
      fold_list <- VALIDATION[[v]](mld, STRATEGIES[[s]])

      for (g in names(fold_list)) {
        basename <- paste(name, names(STRATEGIES)[s], names(VALIDATION)[v], g, sep = "-")

        fold_object <- mldr::mldr_from_dataframe(mld$dataset[fold_list[[g]],], labelIndices = mld$labels$index, attributes = mld$attributes, name = mld$name)

        for (f in FORMATS) {
          mldr.datasets::write.mldr(fold_object, format = f, basename = basename, sparse = sparse)
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
