#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Hcaller      ## you can give whatever name you want here to identify your job
#SBATCH -o Hcaller_GJ_noPAK.log	## name a file to save log of your job
#SBATCH -e Hcaller_GJ_%a.error	## save error message if any
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 17:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 15	## number cpus
#SBATCH --mem=10gb	## total RAM
#SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/haplotype/GoldenJackal_GJ_nofilter_%A%a.log
#SBATCH --array=1-41%10

############################################
# Your scripts below
############################################

module load angsd/0.940

filelist="$1" #Filelist file where the bam files are listed

group=$(echo $filelist | cut -f 1 -d "." | cut -f 2 -d "_")
total=$(wc -l $filelist | cut -f 1 -d " ")
indvs=$(echo $(($total-($total*1/10))))

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
HPC=/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_$group
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta

chr=$(sed -n "$SLURM_ARRAY_TASK_ID"p $WOK/chrs.txt | awk '{print $1}')

angsd -dohaplocall 1 \
  -bam $WOK/$filelist \
  -nThreads 15 \
  -doCounts 1 \
  -minMapQ 20 -minQ 20 \
  -setMinDepth 3 \
  -minMinor 1 -minInd $indvs \
  -skipTriallelic 1 \
  -doMajorMinor 2 -C 50 \
  -baq 1 -remove_bads 1 \
  -ref $DOG \
  -out $HPC/"$group"_"$chr"_"$indvs" \
  -r $chr:
