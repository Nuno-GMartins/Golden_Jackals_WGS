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
#SBATCH --array=101-1000%20

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

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $GL/random_GJ_1k.sites | awk '{print $1}')
#sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p remade.sites | awk '{print $1}')

#while read p; do
#    na=$(echo $p | cut -f 1 -d ".")
#    angsd -doFasta 2 -minQ 20 -ref $DOG -minmapq 20 -setMinDepthInd 3 -doCounts 1 -P 10 -i $WOK/$p -out $GL/$na.consensus
#done < $WOK/Gj_shortEU.filelist

# print the information of chromosomes sizes
#awk -v OFS='\t' {'print $1,$2'} Canis_l_familiaris_CanFam3.1_withMT.fasta.fai > dog_genomeFile.txt

## Now we generate n number of sites with l length
#bedtools random -l 5000 -n 1000 -g $GL/dog_genomeFile.txt > $GL/random_GJ_1k.bed
#awk {'print $1,$2,$3'} $GL/random_GJ_1k.bed > $GL/random_GJ_1k.sites

#awk -v OFS=':' {'print $1,$2,$3'} $GL/random_GJ_1k.bed > $GL/random_GJ_1k.sites & sed -i 's/:/-/2' random_GJ_1k.sites

#echo -n "" > tree_GJ_1k.list
#echo -n "" > GJ_1k.fa

#while read o; do
#  na=$(echo $o | cut -f 1 -d ".")
#  echo $na >> $GL/tree_GJ.list
#done < $WOK/ExpandedGoldenJackals.filelist

#while read p; do
#  for d in $p.consensus.MAX10.fa.gz
#  do
#    samtools faidx $d -r random_GJ_1k.sites -o "$p"_GJ-1k_random.fa
#  done
#done < tree_GJ.list

#for i in *_GJ-1k_random.fa
#do
#  na=$(echo $i | cut -f 1 -d "_")
#  for m in {1..1000}; do
#    q=$((1+$m))
#    HE=$(sed -n "$m"p random_GJ_1k.sites)
#    HEE=$(sed -n "$q"p random_GJ_1k.sites)
#    cat $i | sed -n '/'$HE'/,/'$HEE'/p' | head -n -1 > "$na"_"$HE"_GJ.fa
#  done
#done

#for i in *_GJ-1k_random.fa
#do
#    cat $i | sed '1!{/^>.*/d;}' >> GJ_1k.fa
#done

#for m in {1..1000}; do
#  HE=$(sed -n "$m"p random_GJ_1k.sites)
#  for i in *_"$HE"_GJ.fa
#  do
#    cat $i | sed '1!{/^>.*/d;}' >> "$HE"_GJ_1k.fa
#  done
#  while read p; do
#    sed -i '0,/'$HE'/s//'$p'/' "$HE"_GJ_1k.fa
#  done < tree_GJ.list
#done

#HE=$(sed '1q' random_GJ_1k.sites)

#while read p; do
#   sed -i '0,/'$HE'/s//'$p'/' GJ_1k.fa
#done < tree_GJ.list

#raxml-ng --msa GJ_concatenated.fa --model GTR+G --all --force --bs-trees 1000 --threads 30 --outgroup FX001

#raxml-ng --msa $RAX/"$sample"_GJ_1k.fa --model GTR+G --all --bs-trees 100 --threads auto{20} --outgroup FX001

raxml-ng --msa $RAX/"$sample"_short_GJ_1k.fa --model GTR+G --all --bs-trees 100 --threads auto{20} --outgroup FX001
