#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J evalAdmix_GJ      ## you can give whatever name you want here to identify your job
#SBATCH -o evalAdmix_%A.log	## name a file to save log of your job
#SBATCH -e evalAdmix_%A.error	## save error message if any
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 12:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=125gb	## total RAM

############################################
# Your scripts below
############################################

module load evalAdmix/0.961

GEN=/projects/mjolnir1/people/jbf527/jackals/genotype/GL_GoldenJackals/Admix_GoldenJackals
BEA=`pwd`

BG="$1" #Name of the beagle file
FOPT=$GEN/"$2".fopt.gz #Name of the better likelihood run without the termination
QOPT=$GEN/"$2".qopt #Name of the better likelihood run without the termination 

name=$(echo "$2" | cut -f 3 -d "_") #Create a better name for the final file

#evalAdmix -misTol 0.05 -minMaf 0.05 -beagle $BEA/GJ.bg.gz -fname admix_GJ_10_2.fopt.gz -qname admix_GJ_10_2.qopt -o evaladmixOut.GJ_10_2-2.corres -P 20

evalAdmix -beagle $BEA/$BG -misTol 0.05 -minMaf 0.05 -fname $FOPT -qname $QOPT -o evaladmixOut.$name.corres -P 10 -nIts 10
