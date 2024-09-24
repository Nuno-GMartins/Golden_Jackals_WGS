#!/bin/Rscript
############################################
# Your scripts below
############################################

library(admixtools)
library(devtools)
library(admixr)
library(Rcpp)
library(igraph)

setwd("/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_GoldenJackals")

prefix = "GoldenJackals_haplo_filtered_fox_Pop"
my_f2_dir = "results_GJ"

mypops = c('Fox','Europe','Israel','Caucasus','Middle_east','India','Latvia','Croatia')
#f2_blocks = f2_from_precomp(my_f2_dir)

# Find the index of 'Fox' in mypops
fox_index <- which(mypops == 'Fox')

# Create a matrix of combinations
combinations <- combn(mypops, 5)

# Rotate the matrix so that each combination starts with 'Fox'
rotated_combinations <- t(combinations)

rrs <- qpf4ratio(prefix,rotated_combinations, boot = FALSE, verbose = TRUE)

sapply("qpf4ratio_results", file.create)
write.table(rrs, file = "qpf4ratio_results", sep = "\t", row.names=FALSE)
