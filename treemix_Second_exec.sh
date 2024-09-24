#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J treemix      ## you can give whatever name you want here to identify your job
#SBATCH -o treemix_%A-%a.log	## name a file to save log of your job
#SBATCH -e treemix_%A-%a.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 01:30:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=6gb	## total RAM
##SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/heterozygosity/angsd%A%a.log
#SBATCH --array=1-30%5

############################################
# Your scripts below
############################################

module load treemix/1.13
module load phylip/3.696
module load parallel/20221122

WOK=/projects/mjolnir1/people/jbf527/jackals/Treemix
HAP=/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_ExpandedGoldenJackals

#GENO=$HAP/ExpandedGoldenJackals_haplo_filtered_fox.geno
#IND_POP=$HAP/ExpandedGoldenJackals_haplo_filtered_fox.ind
# Column1(Sample+id) Col2(Sex, Normally U), Col3(Pop)
OUT='ExpandedGJ_fox.freq'

Mig="$1"

#ls $WOK/*.bam | cut -d "/" -f 8 > Canids.filelist
rep=${SLURM_ARRAY_TASK_ID}

###awk '{print $1,$2,$3}' OFS='\t' $IND_POP | awk -F "" 'NR==FNR {split($0,a,"\t"); pop[NR]=a[3];!l[a[3]]++;next}{for(j in l){f[j":0"]=0;f[j":1"]=0};for(i=1;i<=NF;i++){switch($i){case "0":f[pop[i]":0"]++;break; case "2": f[pop[i]":1"]++;break;}};if(FNR==1){for(k in l){printf k"\t"};print "";} ;for(k in l){printf f[k":0"]","f[k":1"]"\t"};print "";delete f}' OFS='\t' - $GENO > $WOK/$OUT

###grep -v "0,0" $WOK/$OUT | gzip -c > $WOK/ExpandedGJ_fox_noMiss.freq.gz

###treemix -i ExpandedGJ_fox_noMiss.freq.gz -m 1 -o test_Pops_m1 -root Fox -global -bootstrap -k 500 -noss -n_warn 12 > treemix_pops_1_log

#treemix -i GJ_fox_v2_noMiss.freq.gz -k 500 -root Fox -bootstrap 100 -o treemix_GJ_$mig -m $mig -n_warn 10

#treemix -i $WOK/ExpandedGJ_fox_noMiss.freq.gz -k 500 -root Fox -bootstrap 100 -global -o $WOK/Expanded_m1_$mig -m 1 -n_warn 20

#-noss

#for i in {0..5}
# do
#   treemix -i $FILE.treemix.frq.gz -m $i -o $FILE.$i -root Fox -global -bootstrap -k 500 -noss > treemix_${i}_log
#done

#treemix -i $WOK/ExpandedGJ_fox_noMiss.freq.gz -m $Mig -o $WOK/Pops.m"$Mig"_${rep} \
#  -bootstrap -k 500 \
#  -n_warn 12 -root Fox >> $WOK/treemix_Wbase"$Mig"_log

treemix -i $WOK/ExpandedGJ_pruned_noMiss.freq.gz -m $Mig -o $WOK/Pops.m"$Mig"_${rep}_withBase \
  -g $WOK/Pops.m0_6.vertices.gz $WOK/Pops.m0_6.edges.gz -bootstrap -k 500 \
  -n_warn 12 -root Fox >> $WOK/treemix_Wbase"$Mig"_log

#treemix -i $WOK/ExpandedGJ_pruned_noMiss.freq.gz -m $Mig -o $WOK/Pops.m"$Mig"_${rep} \
#  -bootstrap -k 500 -n_warn 12 -root Fox >> $WOK/treemix_base"$Mig"_log
