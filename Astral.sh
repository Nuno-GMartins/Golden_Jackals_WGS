#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Astral      ## you can give whatever name you want here to identify your job
#SBATCH -o astral.log        ## name a file to save log of your job
#SBATCH -e astral.error      ## save error message if any    
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 04:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 15    ## number cpus
#SBATCH --mem=16gb      ## total RAM
##SBATCH --array=1-10%5

############################################
# Your scripts below
############################################

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
GL=/projects/mjolnir1/people/jbf527/jackals/consensus/1000_rando_GJ
TRE=/projects/mjolnir1/people/jbf527/jackals/tree
AST=/projects/mjolnir1/people/jbf527/bin/Astral

while read p; do
    cat $GL/"$p"_GJ_1k.fa.raxml.bestTree >> $TRE/tree_combined_GJ1k.tree
    ls $GL/"$p"_GJ_1k.fa.raxml.support >> $TRE/bs-file_r1k
done < random_GJ_1k.sites

#java -jar $AST/astral.5.7.8.jar -i r10_5k.tre -o all_r10_5k.tree
java -Xmx16G -jar $AST/astral.5.7.8.jar -i $TRE/tree_combined_GJ1k.tree \
  --outgroup FX001 -o $TRE/r1k_combine.tree 2> $TRE/out_r1k.log

#### use the support file instead - because the support files are mucht lighter and will make it run faster

#java -Xmx96G -jar $AST/astral.5.7.8.jar -i $TRE/tree_combined_GJ1k.tree \
#  -b $TRE/bs-file_r1k --outgroup FX001 -o $TRE/r1k_combine.tree 2> $TRE/out_r1k.log
