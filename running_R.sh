#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J qp3pop_4      ## you can give whatever name you want here to identify your job
#SBATCH -o admixtool4.log	## name a file to save log of your job
#SBATCH -e admixtool4.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 10:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=80gb	## total RAM

############################################
# Your scripts below
############################################

SSH=/projects/mjolnir1/people/jbf527/jackals/scripts_jackals

module load gcc/11.2.0
module load R/4.1.3

Rscript $SSH/admirx.r
