#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Plink_convert      ## you can give whatever name you want here to identify your job
#SBATCH -o Plink_converter_EU.log  ## name a file to save log of your job
#SBATCH -e Plink_converter_EU.error        ## save error message if any    
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 20:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10   ## number cpus
#SBATCH --mem=10gb      ## total RAM
##SBATCH --array=1-41%5

############################################
# Your scripts below
############################################

module load plink/2.0.0

cp Europe_haplotype.tped Europe_haplotype.old.tped

cat Europe_haplotype.old.tped | sed 's/N N/0 0/g' > Europe_haplotype.tped

plink2 --tfile Europe_haplotype --allow-extra-chr \
  --make-bed --out Europe_haplotype --chr-set 38
