#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J merge_hplo      ## you can give whatever name you want here to identify your job
#SBATCH -o merge_hplo.log  ## name a file to save log of your job
#SBATCH -e merge_hplo.error        ## save error message if any    
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 03:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 3   ## number cpus
#SBATCH --mem=14gb      ## total RAM
##SBATCH --array=1-41%5

############################################
# Your scripts below
############################################

module load angsd/0.940

DAT=GoldenJackals
BG="$DAT".haplo
MAF="$DAT".mafs
na=$(echo $DAT | cut -f 2 -d "_")

zcat "$DAT"_chr1.haplo.gz > $BG
for i in {2..38}; do zcat "$DAT"_chr"$i".haplo.gz | tail -n +2 >> $BG; done
#zcat "$DAT"_chrX.haplo.gz | tail -n +2 >> $BG
#zcat "$DAT"_chrY.haplo.gz | tail -n +2 >> $BG
zcat "$DAT"_chrMT.haplo.gz | tail -n +2 >> $BG
