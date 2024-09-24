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

prefix = "GoldenJackals_haplo_filtered_fox_Pop.ind"
my_f2_dir = "results_GJ"

mypops = c('Europe','Israel','Caucasus','Middle_east','India','Latvia','Croatia')

f2_blocks = f2_from_precomp(my_f2_dir)



qpadm(f2_blocks, left, right, target)

#rrs <- qpadm_rotate(f2_blocks, leftright = mypops[3:7], target = mypops[1], rightfix = mypops[1:2], full_results = TRUE)

#sapply(paste0("qpwave_results_", x), file.create)
#write.table(rrs, file = paste0("f3_results_", x), sep = "\t", row.names=FALSE)

#for (x in mypops) {
#    rrs <- qp3pop(prefix, pop1, x, mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE,apply_corr=FALSE)
#    sapply(paste0("f3_results_", x), file.create)
#    write.table(rrs, file = paste0("f3_results_", x), sep = "\t", row.names=FALSE)
#}
