#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J ngsDist_GLWD      ## you can give whatever name you want here to identify your job
#SBATCH -o ngsDist.log	## name a file to save log of your job
#SBATCH -e ngsDist.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 1-00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=50gb	## total RAM

############################################
# Your scripts below
############################################

module load angsd/0.940

GL=/projects/mjolnir1/people/jbf527/jackals/genotype
TREE=/projects/mjolnir1/people/jbf527/jackals/tree

sd=$(( $RANDOM ))
#N_IND= wc -l test_EU_GLWD.labels | awk '{print $1}'
#N_SITES= wc -l test_EU_GLWD.pos | awk '{print $1}'

N_IND=88
N_SITES=4012478

/projects/mjolnir1/apps/ngsDist/ngsDist \
  --n_threads 10 --seed $sd --verbose 1 \
  --geno $GL/Europe_chr1-6_DW.bg.gz --probs \
  --n_ind $N_IND --n_sites $N_SITES \
  --labels $GL/test_EU_GLWD.labels --pos $GL/test_EU_GLWD.pos \
  --n_boot_rep 5 --boot_block_size 10 --call_geno \
  --out $TREE/test_EU_GLWD_2B-10CG.dist
