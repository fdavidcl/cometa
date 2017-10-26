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
    sum$labels <- dataset$labels$index - 1 # label indices starting from 0
    sum$bibtex <- dataset$bibtex

    my_dir <- "public/json/"
    if (!dir.exists(my_dir))
        dir.create(my_dir)
    
    sink(paste0(my_dir, mldname, ".json"))
    cat(toJSON(sum, pretty=T, auto_unbox = T))
    sink()

    # Concurrence plot
    selected <- order(dataset$labels$SCUMBLE, decreasing = T)
    tryPlot <- function(filename, max_) {
      selection <- dataset$labels$index[selected[1:min(max_, length(selected))]]
      png(filename, width = 1024, height = 1024, pointsize = 15)
      tryCatch({
        plot(
          dataset,
          labelIndices = selection,
          title = "",
          color.function = colorspace::rainbow_hcl
        )
      },
      error = function(...) {})
      dev.off()
    }
    
    my_plot_dir <- "public/img/"
    if (!dir.exists(my_plot_dir))
        dir.create(my_plot_dir)
    filename <- paste0(my_plot_dir, mldname, ".png")
    
    amount <- 10
    tryPlot(filename, amount)
    while (!file.exists(filename) && amount < 100) {
      amount <- amount + 10
      cat("Trying to plot with", amount, "labels...\n")
      tryPlot(filename, amount)
    }
} else {
    cat("Please specify a valid mld path\n")
}
