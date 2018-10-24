#!/usr/bin/env Rscript

BASEURL <- "https://cometa.ujaen.es/public/full"

add_dataset <- function(df, file) {
  name <- sub(".rds", "", basename(file))
  cat("Reading", name, "...\n")
  
  mld <- readRDS(file)
  df[dim(df)[1] + 1, ] <- list(
    name,
    mld$measures$num.instances,
    mld$measures$num.attributes,
    mld$measures$num.labels,
    paste0(BASEURL, "/", name, ".rds")
  )
  df[order(df$Name),]
}


files <- dir("public/full", pattern = "*.rds", full.names = T)

datasets <- data.frame(Name = character(0), Instances = numeric(0), Attributes = numeric(0), Labels = numeric(0), URL = character(0), stringsAsFactors = F)

for (f in files)
  datasets <- add_dataset(datasets, f)

write.csv(datasets, file = "site/datasets_rds.csv", row.names = F)
