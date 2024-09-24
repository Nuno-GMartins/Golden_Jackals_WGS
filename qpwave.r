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

prefix = "GoldenJackals_haplo_filtered.fox"
my_f2_dir = "results_GJ"

f2_blocks = f2_from_precomp(my_f2_dir)

mypops = c('Europe','Israel','Caucasus','Middle_east','India','Thailand')

left = c('Europe', 'Caucasus')
right = c('Israel', 'India', 'Thailand')
target = 'Middle_east'

rrs <- qpwave_pairs(f2_blocks, left = c(target, left), right = right)
sapply("qpwave_results_Middle_east", file.create)
write.table(rrs, file = "qpwave_results_Middle_east", sep = "\t", row.names=FALSE)

left = c('Europe')
right = c('Israel', 'Middle_east', 'India', 'Thailand')
target = 'Caucasus'

rrs <- qpwave_pairs(f2_blocks, left = c(target, left), right = right)
sapply(paste0("qpwave_results_", x), file.create)
write.table(rrs, file = paste0("f3_results_", x), sep = "\t", row.names=FALSE)

for (x in mypops) {
    rrs <- qp3pop(prefix, pop1, x, mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE,apply_corr=FALSE)
    sapply(paste0("f3_results_", x), file.create)
    write.table(rrs, file = paste0("f3_results_", x), sep = "\t", row.names=FALSE)
}
