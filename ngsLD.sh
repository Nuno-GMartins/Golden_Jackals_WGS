#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J ngsLD_GLWD      ## you can give whatever name you want here to identify your job
#SBATCH -o ngsLD-test.log	## name a file to save log of your job
#SBATCH -e ngsLD-test.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 1-00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 2	## number cpus
#SBATCH --mem=5gb	## total RAM

############################################
# Your scripts below
############################################

module load angsd/0.940
module load ngstools/20220921

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta
GL=/projects/mjolnir1/people/jbf527/jackals/genotype
LINK=/projects/mjolnir1/people/jbf527/jackals/Linkage

angsd -P 2 -bam $WOK/GoldenJackals.filelist -ref $DOG -out $GL/ngsLD-test_GJ_chr8 -r chr8 \
  -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 -minInd 5 \
  -minMapQ 20 -minQ 20 -setMinDepth 2 -doCounts 1 \
  -GL 2 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
  -SNP_pval 1e-3 -doGeno 32 -doPost 1 -postCutoff 0.90

#zcat GJ.bg.gz | awk '{print $1,$2,$3}' | awk -F "_" '{print $1,$2,$3,$4}' > sites_GJ.pos
#sed -i 1d sites_GJ.pos

#sd=$(( $RANDOM ))
#IND=$(wc -l GJ_samples.list | awk '{print $1}')
#SITES=$(wc -l test_EU_GLWD.pos | awk '{print $1}')

IND=154
SITES=4012478

#ngsLD --n_threads 10 --seed $sd --verbose 1 --pos $GL/test_EU_GLWD.pos \
#  --geno Gjs_all_chr1.beagle.gz --n_ind 196 --n_sites 1036000 \
#  --out $LINK/test_EU_GLWD.ld

#ngsLD --n_threads 10 --seed $sd --pos $GL/sites_GJ.pos \
#  --geno $GL/ngsCovar_GJ.geno --n_ind $IND --n_sites $SITES \
#  --out $LINK/GJ_LD.ld

ngsLD --n_threads 10 --seed $sd --pos $GL/sites_GJ.pos \
  --geno $GL/GJ.bg --n_ind $IND --n_sites $SITES \
  --out $LINK/GJ_LD.ld
