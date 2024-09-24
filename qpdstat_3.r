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

#mypops = c('Europe','Israel','Caucasus','Middle_east','India','Latvia','Fox')

#extract_f2(prefix, my_f2_dir,verbose=TRUE,maxmiss = 0.5, n_cores=10, auto_only = FALSE, pops = mypops)

#f2_blocks = f2_from_precomp(my_f2_dir)

pop1 = 'Fox'
list <- read.table("listB")
#mypops <- list$V1
#mypops = c('Europe','Israel','Caucasus','Middle_east','India','Baltics','Croatia','Latvia')

#mypops<-list[1:53]
#gp2<-mypops[54:106]
mypops<-list[107:112]

#rss <- qpdstat(prefix, pop1, gp1, mypops, mypops)

#rrs <- qp3pop(prefix, pop1, 'MJ254', mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)

#write.table(rss, "D-stats_results_All", sep = "\t", row.names=FALSE)

#for (x in gp1) {
#    rrs <- qpdstat(prefix, pop1, 'MJ318', x, mypops)
#    sapply(paste0("Dstats_results_MJ318_", x), file.create)
#    write.table(rrs, file = paste0("Dstats_results_MJ318_", x), sep = "\t", row.names=FALSE)
#}

for (i in 1:length(mypops)) {
  for (j in 1:length(mypops)) {
    if (i != j) {
      sapply(paste0("Dstats_results_",mypops[i], mypops[j]), file.create)
    }
    for (k in 1:length(mypops)) {
      if (i != j && i != k && j != k) {
        #cat("command(", mypops[i], ",", mypops[j], ",", mypops[k], ")\n")
	rrs <- qpdstat(prefix, pop1, mypops[i], mypops[j], mypops[k])
    	#sapply(paste0("Dstats_results_",mypops[i], mypops[j]), file.create)
    	write.table(rrs, file = paste0("Dstats_results_",mypops[i], mypops[j]), sep = "\t", row.names=FALSE, append = TRUE)
      }
    }
  }
}
