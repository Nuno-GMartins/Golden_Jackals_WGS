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

prefix = "GoldenJackals_haplo_filtered_fox_Indv"
my_f2_dir = "results_GJ"

#mypops = c('Europe','Israel','Caucasus','Middle_east','India','Thailand','Baltics')

#extract_f2(prefix, my_f2_dir,verbose=TRUE,maxmiss = 0.5, n_cores=1, auto_only = FALSE, pops = mypops)

#f2_blocks = f2_from_precomp(my_f2_dir)

pop1 = 'Fox'
list <- read.table("listB_fox")
mypops <- list$V1

#gp1<-mypops[1:53]
#gp2<-mypops[54:106]
gp3<-mypops[107:112]

#gp1<-mypops[31:40]
#gp1<-mypops[41:50]
#gp1<-mypops[51:60]
#gp1<-mypops[61:70]
#gp1<-mypops[71:80]
#gp1<-mypops[81:90]
#gp1<-mypops[91:100]
#gp1<-mypops[101:110]
#gp1<-mypops[111:120]
#gp1<-mypops[121:130]
#gp1<-mypops[131:140]
#gp1<-mypops[141:150]
#gp1<-mypops[151:154]

#qp3pop(prefix, pop1, 'MJ001', mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)

#rrs <- qp3pop(prefix, pop1, 'MJ324', mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)

#rrs <- qp3pop(prefix, pop1, 'MJ131', mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)

#rrs <- qp3pop(prefix, pop1, 'MJ160', mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)

#rrs <- qp3pop(prefix, pop1, 'MJ254', mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)

#write.table(rrs, "f3_results_MJ254", sep = "\t", row.names=FALSE)

#for (x in gp1) {
#    rrs <- qp3pop(prefix, pop1, x, mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE)
#    sapply(paste0("f3_results_", x), file.create)
#    write.table(rrs, file = paste0("f3_results_", x), sep = "\t", row.names=FALSE)
#}

#for (x in mypops) {
#    rrs <- qp3pop(prefix, pop1, x, mypops, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE,apply_corr=FALSE)
#    sapply(paste0("f3_results_", x), file.create)
#    write.table(rrs, file = paste0("f3_results_", x), sep = "\t", row.names=FALSE)
#}

#for (x in list) {
#    rrs <- qp3pop(prefix, pop1, x, gp1, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE,apply_corr=FALSE)
#    file_path <- paste0("f3_results_1_", x)
#    file.create(file_path)
#    write.table(rrs, file = file_path, sep = "\t", row.names = FALSE)
#}

#for (x in list) {
#    rrs <- qp3pop(prefix, pop1, x, gp2, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE,apply_corr=FALSE)
#    file_path <- paste0("f3_results_1_", x)
#    file.create(file_path)
#    write.table(rrs, file = file_path, sep = "\t", row.names = FALSE)
#}

for (x in list) {
    rrs <- qp3pop(prefix, pop1, x, gp3, sure=TRUE, verbose=TRUE,outgroupmode=TRUE,auto_only=FALSE,allsnps=TRUE,apply_corr=FALSE)
    file_path <- paste0("f3_results_3")
    file.create(file_path)
    write.table(rrs, file = file_path, sep = "\t", row.names = FALSE)
}
