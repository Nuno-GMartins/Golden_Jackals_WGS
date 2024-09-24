#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J gone_Gjs      ## you can give whatever name you want here to identify your job
#SBATCH -o gone_%A.log	## name a file to save log of your job
#SBATCH -e gone_%A.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 1-00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 25	## number cpus
#SBATCH --mem=4gb	## total RAM

############################################
# Your scripts below
############################################

pop="$1" # Name of the plink file

na=$(echo $pop | cut -f -1 -d "_")

PLK=/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_$na

module load plink/1.9.0
module load gone/20230501

## Create the .map and .ped files using the plink files
plink --bfile $PLK/$pop --allow-extra-chr --chr-set 38 --recode --out $pop
## randomly select n number of snps to run gone - limit 10M - and using the newly generated .map file
shuf -n 1400000 "$na"_haplo_filtered_pruned-filtercount.map > "$na"_fileset.subset.map
#shuf -n 1900000 "$na"_haplo_filtered_pruned.map > "$na"_fileset.subset.map
#shuf -n 8000000 "$na"_haplo_filtered.map > "$na"_fileset.subset.map
## use the subset of n snps to create a plink subset from the original plink
plink --bfile $PLK/$pop --allow-extra-chr --chr-set 38 --extract "$na"_fileset.subset.map --make-bed --out file_"$na"
## create a new .map & .ped files using the subseted plink
plink --bfile file_"$na" --allow-extra-chr --chr-set 38 --recode --out file_"$na"

## the .ped file needs to be edited before using gone:
## change ID1 ID1 0 0 0 1 > ID1 ID1 0 0 0 -9
sed -i 's/\(MJ[0-9]\+\) \(MJ[0-9]\+\) 0 0 0 1/\1 \2 0 0 0 -9/g' file_"$na".ped
## number out the individuals ID1 ID1 0 0 0 -9 > 1 ID1 ID1 0 0 0 -9
awk 'BEGIN { prev_id = ""; line_num = 1 } {
    if ($1 != prev_id) {
        prev_id = $1;
        print line_num, $0;
        line_num++;
    } else {
        print line_num - 1, $2, $3, $4, $5, $6, $7, $8;
    }
}' file_"$na".ped > file_"$na"_rename.ped
## edit out the repetition 1 ID1 ID1 0 0 0 -9 > 1 ID1 0 0 0 -9
awk '{ sub($2 FS, ""); print }' file_"$na"_rename.ped > file_"$na"_right.ped

## Finally run gone
script_GONE.sh file_"$na"
