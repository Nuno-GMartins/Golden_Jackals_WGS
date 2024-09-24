#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J ngsadmix_GJ_angsd      ## you can give whatever name you want here to identify your job
#SBATCH -o ngsadmix_Gja_%A_%a.log	## name a file to save log of your job
#SBATCH -e ngsadmix_Gja_%A_%a.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 20:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 30	## number cpus
#SBATCH --mem=115gb	## total RAM
#SBATCH --array=1-200%10

############################################
# Your scripts below
############################################

module load ngsadmix/1.0.0

BEG="$1" #Name of the beagle file
K="$2" #Number of Ks to test

na=$(echo $BEG | cut -f 1 -d "." | cut -f 2 -d "_")

GEN=/projects/mjolnir1/people/jbf527/jackals/genotype/GL_$na
mkdir $GEN/Admix_$na
RES=$GEN/Admix_$na

touch $RES/"likelihood_"$na"_"$K".txt" # Create a file to save the likelihood of each K

### Command to run NGSAdmix
for i in "$SLURM_ARRAY_TASK_ID"; do
  sd=$(( $RANDOM ))
  NGSadmix -likes $GEN/"$1" \
  -K "$K" \
  -seed $sd \
  -o $RES/admix_GJ_"$K"_"$i" \
  -P 30
  echo "replicate_K-> "$K"_"$i"" >> $RES/likelihood_"$na"_"$K".txt # Save the ID of the run, namely the replicate
  echo "seed_"$sd"" >> $RES/likelihood_"$na"_"$K".txt
  grep -r seed=* $RES/admix_GJ_"$K"_"$i".log >> $RES/likelihood_"$na"_"$K".txt # Save the seed of the run
  grep -r like=* $RES/admix_GJ_"$K"_"$i".log >> $RES/likelihood_"$na"_"$K".txt # Save the likelihood of the run
done
