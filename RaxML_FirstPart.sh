#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J RaxML      ## you can give whatever name you want here to identify your job
#SBATCH -o RaxML_FirstPart-short.log        ## name a file to save log of your job
#SBATCH -e RaxML_FirstPart-short.error      ## save error message if any
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 03:30:00 ## give an estimation of how long is your job going to run, format HH:MM:SS
##SBATCH -p hologenomics
#SBATCH -c 10    ## number cpus
#SBATCH --mem=2gb      ## total RAM
##SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/consensus/final%A.log
##SBATCH --array=1-4%4

############################################
# Your scripts below
############################################

module load angsd/0.940
module load samtools/1.9
module load bedtools/2.30.0
module load raxml-ng/1.1.0

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
GL=/projects/mjolnir1/people/jbf527/jackals/consensus
CON=/projects/mjolnir1/people/jbf527/jackals/consensus/Consensus
RAX=/projects/mjolnir1/people/jbf527/jackals/consensus/1000_rando_GJ
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta

# print the information of chromosomes sizes
awk -v OFS='\t' {'print $1,$2'} Canis_l_familiaris_CanFam3.1_withMT.fasta.fai > dog_genomeFile.txt

## Now we generate n number of sites with l length
bedtools random -l 5000 -n 1000 -g $GL/dog_genomeFile.txt > $GL/random_GJ_1k.bed
awk {'print $1,$2,$3'} $GL/random_GJ_1k.bed > $GL/random_GJ_1k.sites

awk -v OFS=':' {'print $1,$2,$3'} $GL/random_GJ_1k.bed > $GL/random_GJ_1k.sites & sed -i 's/:/-/2' random_GJ_1k.sites

echo -n "" > $GL/tree_GJ_1k.list # Create an empty file for the samples names
echo -n "" > $GL/GJ_1k.fa # Create an empty file where we will concantenate all sequences

# List the samples names and store them
while read o; do
  na=$(echo $o | cut -f 1 -d ".")
  echo $na >> $GL/tree_GJ_1k.list
done < $WOK/PhylogenyShort.filelist
# ExpandedGoldenJackalsPhylogenyShort.filelist
# ExpandedGoldenJackalsPhylogeny.filelist
# Simple.filelist
# A .filelist, is a list of the bam files to be use for this analysis

# Collect the sequences of each random selected region for each sample and store it into a sample specific file, with the 1000 regions
while read p; do
  for d in $CON/$p.consensus.fa.gz
  do
    samtools faidx $d -r random_GJ_1k.sites -o $RAX/"$p"_GJ-1k_random.fa
  done
done < $GL/tree_GJ_1k.list

# Extract each 1k regions from each sample and collects them into one file - information of a single region to all individuals
while read p; do
 for i in $RAX/"$p"_GJ-1k_random.fa
 do
   for m in {1..1000}; do
     q=$((1+$m))
     HE=$(sed -n "$m"p $GL/random_GJ_1k.sites)
     HEE=$(sed -n "$q"p $GL/random_GJ_1k.sites)
     cat $i | sed -n '/'$HE'/,/'$HEE'/p' | head -n -1 > $RAX/"$p"_"$HE"_GJ.fa
   done
 done
done < $GL/tree_GJ_1k.list

# This loop goes through all the previously generated single region to all individuals file and adds the individual names
for m in {1..1000}; do
  HE=$(sed -n "$m"p $GL/random_GJ_1k.sites)
  while read p; do
    cat $RAX/"$p"_"$HE"_GJ.fa | sed '1!{/^>.*/d;}' >> $RAX/"$HE"_short_GJ_1k.fa
    sed -i '0,/'$HE'/s//'$p'/' $RAX/"$HE"_short_GJ_1k.fa
  done < $GL/tree_GJ_1k.list
done
