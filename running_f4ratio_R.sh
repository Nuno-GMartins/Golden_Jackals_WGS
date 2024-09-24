#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J f4ratio      ## you can give whatever name you want here to identify your job
#SBATCH -o f4ratio.log	## name a file to save log of your job
#SBATCH -e f4ratio.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 1-15	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 1	## number cpus
#SBATCH --mem=200gb	## total RAM
##SBATCH --array=1-3%3

############################################
# Your scripts below
############################################

SSH=/projects/mjolnir1/people/jbf527/jackals/scripts_jackals

module load gcc/11.2.0
module load R/4.1.3

NR="$SLURM_ARRAY_TASK_ID"

Rscript $SSH/qpf4ratio.r

#Rscript $SSH/qp3pop_$NR.r
