#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J pcangsd-GJ      ## you can give whatever name you want here to identify your job
#SBATCH -o pcangsd_%A.log	## name a file to save log of your job
#SBATCH -e pcangsd_%A.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 12:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 25	## number cpus
#SBATCH --mem=85gb	## total RAM

############################################
# Your scripts below
############################################

pop="$1" # Name of the beagle file

na=$(echo $pop | cut -f -2 -d ".")

module load pcangsd/1.3

GEN=/projects/mjolnir1/people/jbf527/jackals/genotype/GL_GoldenJackals

pcangsd \
 --beagle $GEN/$pop \
 --maf 0.05 \
 --threads 25 \
 --iter 300 -e 5 \
 --maf_iter 200 \
 --pcadapt --selection \
 -o $GEN/$pop-TEST3_pca

# Additional options
# --admix \
# --tree \


