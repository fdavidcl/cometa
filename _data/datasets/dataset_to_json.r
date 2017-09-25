#!/usr/bin/env Rscript

library(mldr)
library(mldr.datasets)
library(jsonlite)

mldname <- commandArgs(trailingOnly = T)

if (length(mldname) == 1) {
  dataset <- get(mldname)
  
  if (class(dataset) != "mldr") {
    mldname <- check_n_load.mldr(mldname)
    
    if (!is.null(mldname))
      dataset <- get(mldname)
  }
  
  if (class(dataset) == "mldr") {
    sum <- dataset$measures
    sum$name <- mldname
    sum$internal.name <- dataset$name
    sum$attributes <- data.frame(name = names(dataset$attributes), type = dataset$attributes, row.names = NULL)
    
    sink(paste0(mldname, ".json"))
    cat(toJSON(sum, pretty=T, auto_unbox = T))
    sink()
  } else {
    cat("Please specify a valid mld name\n")
  }
} else {
  cat("Usage: dataset_to_json.r mld_name\n")
}