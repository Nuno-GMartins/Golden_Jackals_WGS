#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J SFS_pop_test      ## you can give whatever name you want here to identify your job
#SBATCH -o SFS_pops.log	## name a file to save log of your job
#SBATCH -e SFS_pops.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 2-15	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=10gb	## total RAM

############################################
# Your scripts below
############################################

module load angsd/0.940

#WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
WOK=/projects/mjolnir1/people/qvw641/FalklanWolf/Final_BAMs_canFam31
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta
GEN=/projects/mjolnir1/people/jbf527/jackals/heterozygosity/angsd
ANC=/projects/mjolnir1/people/jbf527/ref/dhole/GWHAAAC00000000.genome.fasta
FOX=/projects/mjolnir1/people/jbf527/ref/fox/FX001.consensus.fa.gz

for POP in BUL LTV CRO EST+CAU SLV
do
  angsd -P 10 -bam Gj_EU_$POP.filelist -ref $DOG -anc $FOX -out $GEN/SFS_FOX_$POP -r chr1 \
    -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
    -minMapQ 20 -minQ 20 -setMinDepth 2 -doCounts 1 -GL 2 -doSaf 1
done

# -fold 1

for POP in BUL LTV CRO EST+CAU SLV
do
  realSFS $GEN/SFS_FOX_$POP.saf.idx -bootstrap 4 -P 10 > $GEN/$POP.fox.sfs
done

realSFS SFS_BUL.saf.idx SFS_SLV.saf.idx -bootstrap 10 -P 10 > $GEN/BUL-SLV.sfs
realSFS SFS_BUL.saf.idx SFS_EST+CAU.saf.idx -bootstrap 10 -P 10 > $GEN/BUL-EST+CAU.sfs
realSFS SFS_BUL.saf.idx SFS_LTV.saf.idx -bootstrap 10 -P 10 > $GEN/BUL-LTV.sfs
realSFS SFS_BUL.saf.idx SFS_CRO.saf.idx -bootstrap 10 -P 10 > $GEN/BUL-CRO.sfs

#for n in SFS_FOX_*.saf.idx
#do
#  na=$(echo $n | cut -f 3 -d "_" | cut -f 1 -d ".")
#  realSFS $n -P 10 > $na.just1.ml
#done

#for n in SFS_FOX_*.saf.idx
#do
#  na=$(echo $n | cut -f 3 -d "_" | cut -f 1 -d ".")
#  realSFS $n -maxIter 100 -P 10 > $na.sfs
#done

#realSFS $GEN/SFS_FOX_$POP.saf.idx -bootstrap 4 -P 10 > $GEN/$POP.fox.sfs
