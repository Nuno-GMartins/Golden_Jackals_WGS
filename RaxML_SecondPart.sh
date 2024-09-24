#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J RaxML      ## you can give whatever name you want here to identify your job
#SBATCH -o RaxML_Second_%A%a.log        ## name a file to save log of your job
#SBATCH -e RaxML_Second_%A%a.error      ## save error message if any
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 03:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS
##SBATCH -p hologenomics
#SBATCH -c 20    ## number cpus
#SBATCH --mem=2gb      ## total RAM
#SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/consensus/remade%A%a.log
#SBATCH --array=1-1000%20

############################################
# Your scripts below
############################################

module load angsd/0.940
module load samtools/1.9
module load bedtools/2.30.0
module load raxml-ng/1.1.0

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
GL=/projects/mjolnir1/people/jbf527/jackals/consensus
RAX=/projects/mjolnir1/people/jbf527/jackals/consensus/1000_rando_GJ
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta

# This uses the list of the 1k random regions and runs each one in raxml. This way you can build an array when submitting it to Slurm
sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $GL/random_GJ_1k.sites | awk '{print $1}')
# Run raxml-ng for each region. Each file contains the same 5k region for each sample. And it runs 100 replicates
raxml-ng --msa $RAX/"$sample"_short_GJ_1k.fa --model GTR+G --all --bs-trees 100 --threads auto{20} --outgroup FX001
