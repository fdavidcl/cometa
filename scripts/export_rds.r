#!/usr/bin/env Rscript

require(mldr.datasets)

FORMATS <- c("mulan", "meka", "libsvm", "keel")

main <- function(args = commandArgs(trailingOnly = T)) {
     path <- args[1]
     mld <- readRDS(path)
     mldr.datasets::write.mldr(mld, format = FORMATS, basename = sub(".rds", "", basename(path)), sparse = mldr.datasets::sparsity(mld) > 0.5)
}

main()