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

#sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $GL/random_GJ_1k.sites | awk '{print $1}')
#sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p remade.sites | awk '{print $1}')

#while read p; do
#    na=$(echo $p | cut -f 1 -d ".")
#    angsd -doFasta 2 -minQ 20 -ref $DOG -minmapq 20 -setMinDepth 3 -doCounts 1 -P 10 -i $WOK/$p -out $GL/$na.consensus
#    samtools faidx $GL/$na.consensus
#done < $WOK/Gj_shortEU.filelist

#while read p; do
#    na=$(echo $p | cut -f 1 -d ".")
#    angsd -doFasta 2 -minQ 20 -ref $DOG -minmapq 20 -remove_bads 1 -uniqueOnly 1 -baq 1 -C 50 -setMinDepth 3 -doCounts 1 -P 15 -i $WOK/$p -out $GL/$na.extra.consensus
#    samtools faidx $GL/$na.extra.consensus
#done < $WOK/ExpandedGoldenJackalsPhylogeny.filelist

# print the information of chromosomes sizes
#awk -v OFS='\t' {'print $1,$2'} Canis_l_familiaris_CanFam3.1_withMT.fasta.fai > dog_genomeFile.txt

## Now we generate n number of sites with l length
#bedtools random -l 5000 -n 1000 -g $GL/dog_genomeFile.txt > $GL/random_GJ_1k.bed
#awk {'print $1,$2,$3'} $GL/random_GJ_1k.bed > $GL/random_GJ_1k.sites

#awk -v OFS=':' {'print $1,$2,$3'} $GL/random_GJ_1k.bed > $GL/random_GJ_1k.sites & sed -i 's/:/-/2' random_GJ_1k.sites

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
# Collect the sequences of each random selected region for each sample and store it into a sample specific file, with the 1000 regions
#while read p; do
#  for d in $CON/$p.consensus.fa.gz
#  do
#    samtools faidx $d -r random_GJ_1k.sites -o $RAX/"$p"_GJ-1k_random.fa
#  done
#done < $GL/tree_GJ_1k.list

# Extract each 1k regions from each sample and collects them into one file - information of a single region to all individuals
#while read p; do
# for i in $RAX/"$p"_GJ-1k_random.fa
# do
#   for m in {1..1000}; do
#     q=$((1+$m))
#     HE=$(sed -n "$m"p $GL/random_GJ_1k.sites)
#     HEE=$(sed -n "$q"p $GL/random_GJ_1k.sites)
#     cat $i | sed -n '/'$HE'/,/'$HEE'/p' | head -n -1 > $RAX/"$p"_"$HE"_GJ.fa
#   done
# done
#done < $GL/tree_GJ_1k.list

# This loop goes through all the previously generated single region to all individuals file and adds the individual names
for m in {1..1000}; do
  HE=$(sed -n "$m"p $GL/random_GJ_1k.sites)
  while read p; do
    cat $RAX/"$p"_"$HE"_GJ.fa | sed '1!{/^>.*/d;}' >> $RAX/"$HE"_short_GJ_1k.fa
    sed -i '0,/'$HE'/s//'$p'/' $RAX/"$HE"_short_GJ_1k.fa
  done < $GL/tree_GJ_1k.list
done

# Concatenate all the samples and regions into a single file
#for i in $RAX/*_GJ-1k_random.fa
#do
#    cat $i | sed '1!{/^>.*/d;}' >> $GL/GJ_1k.fa
#done
#HE=$(sed '1q' random_GJ_1k.sites)
## Change the name
#while read p; do
#   cat "$p"_GJ-1k_random.fa | sed '1!{/^>.*/d;}' >> $GL/GJ_1k.fa
#   sed -i '0,/'$HE'/s//'$p'/' GJ_1k.fa
#done < tree_GJ_1k.list

#raxml-ng --msa GJ_concatenated.fa --model GTR+G --all --force --bs-trees 1000 --threads 30 --outgroup FX001

#raxml-ng --msa MT_concatenated.fa --model GTR+G --all --force --bs-trees 100 --threads 5 --outgroup FX001

#raxml-ng --msa "$sample"_GJ_1k.fa --model GTR+G --all --force --bs-trees 100 --threads 5 --outgroup FX001
