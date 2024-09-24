#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J merge_GL      ## you can give whatever name you want here to identify your job
#SBATCH -o merge_GJs.log  ## name a file to save log of your job
#SBATCH -e merge_GJs_144.error        ## save error message if any
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 05:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS
##SBATCH -p hologenomics
#SBATCH -c 2   ## number cpus
#SBATCH --mem=2gb      ## total RAM
##SBATCH --array=1-41%5

############################################
# Your scripts below
############################################

WOR='pwd'

DAT=GJ_ExpandedGoldenJackals
BG="$DAT".bg
MAF="$DAT".mafs

zcat $WOR/"$DAT"_chr1.beagle.gz > $WOR/$BG
for i in {2..38}; do zcat $WOR/"$DAT"_chr"$i".beagle.gz | tail -n +2 >> $WOR/$BG; done
#zcat $WOR/"$DAT"_chrX.beagle.gz | tail -n +2 >> $WOR/$BG
#zcat $WOR/"$DAT"_chrY.beagle.gz | tail -n +2 >> $WOR/$BG
zcat $WOR/"$DAT"_chrMT.beagle.gz | tail -n +2 >> $WOR/$BG
gzip $WOR/$BG

zcat $WOR/"$DAT"_chr1.mafs.gz > $WOR/$MAF
for i in {2..38}; do zcat $WOR/"$DAT"_chr"$i".mafs.gz | tail -n +2 >> $WOR/$MAF; done
#zcat $WOR/"$DAT"_chrX.mafs.gz | tail -n +2 >> $WOR/$MAF
#zcat $WOR/"$DAT"_chrY.mafs.gz | tail -n +2 >> $WOR/$MAF
zcat $WOR/"$DAT"_chrMT.mafs.gz | tail -n +2 >> $WOR/$MAF
gzip $WOR/$MAF

#haploToPlink Europe_haplotype.haplo.gz Europe_haplotype
