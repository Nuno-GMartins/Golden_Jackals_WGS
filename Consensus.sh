#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Consensus_GL      ## you can give whatever name you want here to identify your job
#SBATCH -o consensus_%a.log	## name a file to save log of your job
#SBATCH -e consensus_%a.error	## save error message if any
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 10:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 15	## number cpus
#SBATCH --mem=8gb	## total RAM
#SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/consensus/logs_erros_RaxML/consensus%A%a.log
#SBATCH --array=1-29%5

############################################
# Your scripts below
############################################

module load angsd/0.940
module load samtools/1.9

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
GL=/projects/mjolnir1/people/jbf527/jackals/consensus
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta

#sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p Simple.filelist | awk '{print $1}')

#na=$(echo $sample | cut -f 1 -d ".")

#angsd -doFasta 2 -minQ 20 -ref $DOG -minmapq 20 -noTrans 1 -doCounts 1 -P 15 -i $sample -out $GL/$na.consensus
#samtools faidx $GL/$na.consensus.fa.gz

#while read p; do
#    na=$(echo $p | cut -f 1 -d ".")
#    angsd -doFasta 2 -minQ 20 -ref $DOG -minmapq 20 -noTrans 1 -doCounts 1 -P 15 -i $p -out $GL/$na.consensus
#done < Simple.filelist

#for m in $WOK/MJ00*.bam
#do
#    n=$(echo $m | cut -f 8 -d "/")
#    na=$(echo $n | cut -f 1 -d ".")
#    angsd -doFasta 2 -minQ 20 -minmapq 20 -setMinDepth 3 -ref $DOG -noTrans 1 -P 4 -doCounts 1 -i $n -out $GL/$na.consensus
#done

#angsd -doFasta 2 -doCounts 1 -i FX001.CanFam31.filtered.bam -minmapq 20 -minQ 20 -setMinDepthInd 3  -out $GL/FX001.consensus

ls $WOK/*.bam > samples_list.txt

sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p samples_list.txt | awk '{print $1}')

na=$(echo $sample | cut -f 8 -d "/" | cut -f 1 -d ".")

if [ -e $GL/$na.Trans.consensus.fa.gz ]; then
    :
else
    echo "File does not exist. Running the command..."
    angsd -doFasta 2 -minQ 20 -minmapq 20 -setMinDepth 3 -ref $DOG \
    -noTrans 1 -remove_bads 1 -uniqueOnly 1 -baq 1 -C 50 -P 15 -doCounts 1 \
    -i $sample -out $GL/$na.Trans.consensus
    samtools faidx $GL/$na.Trans.consensus.fa.gz
fi
