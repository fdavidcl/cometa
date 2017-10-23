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
    sum$bibtex <- dataset$bibtex

    my_dir <- "public/json/"
    if (!dir.exists(my_dir))
        dir.create(my_dir)
    
    sink(paste0(my_dir, mldname, ".json"))
    cat(toJSON(sum, pretty=T, auto_unbox = T))
    sink()
} else {
    cat("Please specify a valid mld path\n")
}
