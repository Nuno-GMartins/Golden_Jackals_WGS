#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J ngsCovar_GJ      ## you can give whatever name you want here to identify your job
#SBATCH -o ngsCovar_GJ.log	## name a file to save log of your job
#SBATCH -e ngsCovar_GJ.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 1-10	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=15gb	## total RAM
#SBATCH --array=1-41%5

############################################
# Your scripts below
############################################

module load angsd/0.940
module load ngstools/20220921

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta
GEN=/projects/mjolnir1/people/jbf527/jackals/genotype

chr=$(sed -n "$SLURM_ARRAY_TASK_ID"p $WOK/chrs.txt | awk '{print $1}')

angsd -P 10 -bam $WOK/GoldenJackals.filelist -ref $DOG -out $GEN/ngsCovar_GJ_$chr -r $chr \
  -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
  -minMapQ 20 -minQ 20 -setMinDepth 2 -doCounts 1 \
  -GL 2 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
  -SNP_pval 1e-3 -doGeno 5 -doPost 1 -postCutoff 0.95

# -minInd 10 # Filter to include only sites with more than 10 individuals with data in it

#ngsCovar -probfile pop.geno -outfile pop.covar -nind 40 -nsites 100000 -block_size 20000 -call 0 -minmaf 0.05

IND=wc -l GJ_samples.list | awk '{print $1}'
SITES= zcat ngsCovar_GJ.mafs.gz | wc -l | awk '{print $1}'

ngsCovar -probfile ngsCovar_GJ.geno -outfile GJ.covar -nind $IND -nsites $SITES -block_size 20000 -call 0 -minmaf 0.05
