#!/usr/bin/env Rscript
# borrar luego:
setwd("~/Documentos/research/publications/2017/multilabel-neucom")

# trampa
datasets <- read.csv("http://fcharte.com/mldr.datasets/availableMlds.csv", stringsAsFactors = F)[, -1]

BASEURL <- "https://cometa.ml/public/full"

# files <- dir("public/full", pattern = "*.rds", full.names = T)
# names(files) <- sub(".rds", "", basename(files), fixed = T)


add_dataset <- function(df, name, desc) {
  mld <- readRDS(paste0("public/full/", name, ".rds"))
  df[dim(df)[1] + 1, ] <- list(
    name,
    desc,
    mld$measures$num.instances,
    mld$measures$num.attributes,
    mld$measures$num.labels,
    paste0(BASEURL, "/", name, ".rds")
  )
  df[order(df$Name),]
}

datasets$URL <- paste0(BASEURL, "/", datasets$Name, ".rds")
datasets <- add_dataset(datasets, "stackex_coffee", "Dataset from Stack Exchange's coffee forum")

write.csv(datasets, file = "datasets_rds.csv", row.names = F)
