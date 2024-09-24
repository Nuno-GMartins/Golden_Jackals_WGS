#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J plx_B10      ## you can give whatever name you want here to identify your job
#SBATCH -o plx_B10.log	## name a file to save log of your job
#SBATCH -e paleomix_Block10.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 2-15	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 20	## number cpus
#SBATCH --mem=120gb	## total RAM

############################################
# Your scripts below
############################################

module load paleomix/1.3.6

JAK=/projects/mjolnir1/people/jbf527/jackals/Block10

paleomix bam_pipeline run --max-threads=20 --bwa-max-threads=20 --jre-option=-Xmx120g \
	--temp-root $JAK --jar-root /projects/mjolnir1/apps/conda/paleomix-1.3.6/share/picard-2.27.2-0 \
	$JAK/JackalBlock10.yaml
