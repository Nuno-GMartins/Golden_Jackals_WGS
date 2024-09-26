#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Rohan_GJ      ## you can give whatever name you want here to identify your job
#SBATCH -o Rohan_All_%a.log	## name a file to save log of your job
#SBATCH -e Rohan_All_%a.error	## save error message if any
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 25:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS
##SBATCH -p hologenomics
#SBATCH -c 8   ## number cpus
#SBATCH --mem=6gb      ## total RAM
#SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/heterozygosity/logs_erros_SFS-Rohan/Rohan_%A_%a.log
#SBATCH --array=1-137%15 # The array number changes with the size of the fileslist

############################################
# Your scripts below
############################################

HET=/projects/mjolnir1/people/jbf527/jackals/heterozygosity/rohan
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta
ROH=/projects/mjolnir1/people/jbf527/bin/rohan/bin
WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams

file='$1' #Input the filelist with the bam files that you want to use for this analysis

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $WOK/$file | awk '{print $1}')
na=$(echo $sample | cut -d "/" -f 8 | cut -d "." -f 1)

if [ -e $HET/"$na".hEst.gz ]; then
    :
else
    $ROH/rohan -t 8 --rohmu 1e-5 --auto $WOK/names.txt --out $HET/$na \
      $DOG $WOK/$sample
fi
