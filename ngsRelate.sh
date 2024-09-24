#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J ngsRelate      ## you can give whatever name you want here to identify your job
#SBATCH -o ngsRelateGJ_test_%a.log	## name a file to save log of your job
#SBATCH -e ngsRelateGJ_test_%a.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 1-15	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 15	## number cpus
#SBATCH --mem=100gb	## total RAM
##SBATCH --array=1-41%10

############################################
# Your scripts below
############################################

module load angsd/0.940
module load ngsrelate/2.0

pop=GoldenJackals.filelist

na=$(echo $pop | cut -f 2 -d "_" | cut -f 1 -d ".")

FIL=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
GEN=/projects/mjolnir1/people/jbf527/jackals/genotype/GL_$na
REL=/projects/mjolnir1/people/jbf527/jackals/relate

#chr=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FIL/chrs.txt | awk '{print $1}')

#angsd -b $FIL/$pop -gl 2 -domajorminor 1 -snp_pval 1e-6 -domaf 1 -minmaf 0.05 -doGlf 3 -out $REL/GoldenJackal

#angsd -GL 2 \
#  -bam $FIL/$pop  \
#  -nThreads 10 \
#  -minMapQ 20 -minQ 20 \
#  -doMajorMinor 1 -doMaf 1 \
#  -SNP_pval 1e-6 \
#  -doGlf 3 \
#  -minMaf 0.05 -P 10 \
#  -out $REL/GJ_"$na"_"$chr" \
#  -r $chr:

#DAT=GJ_$na
#BG="$DAT".bg
#MAF="$DAT".mafs
#ind=

#zcat $REL/"$DAT"_chr1.beagle.gz > $REL/$BG
#for i in {2..38}; do zcat $REL/"$DAT"_chr"$i".beagle.gz | tail -n +2 >> $REL/$BG; done
#zcat $REL/"$DAT"_chrX.beagle.gz | tail -n +2 >> $REL/$BG
#zcat $REL/"$DAT"_chrY.beagle.gz | tail -n +2 >> $REL/$BG
#zcat $REL/"$DAT"_chrMT.beagle.gz | tail -n +2 >> $REL/$BG
#gzip $REL/$BG

#zcat $REL/"$DAT"_chr1.mafs.gz > $REL/$MAF
#for i in {2..38}; do zcat $REL/"$DAT"_chr"$i".mafs.gz | tail -n +2 >> $REL/$MAF; done
#zcat $REL/"$DAT"_chrX.mafs.gz | tail -n +2 >> $REL/$MAF
#zcat $REL/"$DAT"_chrY.mafs.gz | tail -n +2 >> $REL/$MAF
#zcat $REL/"$DAT"_chrMT.mafs.gz | tail -n +2 >> $REL/$MAF
#gzip $REL/$MAF

######zcat $GEN/GoldenJackal.mafs.gz | cut -f5 | sed 1d > $REL/freq_GJ

zcat $REL/GJ_GoldenJackals_143.mafs.gz | cut -f5 | sed 1d > $REL/$na.freq

#IND=$(wc -l $FIL/$pop | awk '{print $1}')
IND=158
SIT=$(wc -l $REL/$na.freq | awk '{print $1}')

#ngsRelate -g $GEN/GJ_$na.bg.gz -n $IND -L $SIT -f $REL/$na.freq -O $REL/GJackals

#ngsRelate -g $GEN/GoldenJackal.bg.gz -n $IND -L $SIT -f $REL/$na.freq -O $REL/GJackals

#ngsRelate -G GJ_GoldenJackals_144.bg.gz -n $IND -f GJ.freq -O final_Gjs -p 10
ngsRelate -G GJ_GoldenJackals_143.bg.gz -n $IND -f $na.freq -O final_Gjs -p 15

#ngsRelate -g $REL/GJ_GoldenJackals.glf.gz -f $REL/GoldenJackals.freq -O $REL/GoldenJackals_relate -n $IND -p 10

ngsRelate -G GJ_GoldenJackals_143.bg.gz -n $IND -f $na.freq -O test_INBREED_final_Gjs -p 15 -F 1
