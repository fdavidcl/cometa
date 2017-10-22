#!/usr/bin/env Rscript

library(mldr)
library(mldr.datasets)
library(jsonlite)

path <- commandArgs(trailingOnly = T)
mldname <- sub(".rds", "", basename(path), fixed = T)
dataset <- readRDS(path)

if (class(dataset) == "mldr") {
    sum <- dataset$measures
    sum$name <- mldname
    sum$internal.name <- dataset$name
    sum$attributes <- data.frame(name = names(dataset$attributes), type = dataset$attributes, row.names = NULL)
    
    sink(paste0("site/_data/datasets/", mldname, ".json"))
    cat(toJSON(sum, pretty=T, auto_unbox = T))
    sink()
} else {
    cat("Please specify a valid mld name\n")
}
