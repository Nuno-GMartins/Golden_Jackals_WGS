#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J ngsF_GLpops      ## you can give whatever name you want here to identify your job
#SBATCH -o ngsF.log	## name a file to save log of your job
#SBATCH -e ngsF.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 2-10	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 10	## number cpus
#SBATCH --mem=20gb	## total RAM

############################################
# Your scripts below
############################################

module load angsd/0.940
module load ngstools/20220921

DOG=/projects/mjolnir1/people/jbf527/ref/CanFam3_withMT/Canis_l_familiaris_CanFam3.1_withMT.fasta
WOK=/projects/mjolnir1/people/jbf527/jackals/inbreeding

for POP in BUL LTV CRO EST+CAU SLV;
do
  echo $POP
  angsd -P 10 -bam Gj_EU_$POP.filelist -ref $DOG -out $WOK/$POP -r chr1 \
    -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
    -trim 0 -C 50 -baq 1 \
    -minMapQ 20 -minQ 20 -setMinDepth 2 -doCounts 1 \
    -GL 2 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
    -doGlf 3 -SNP_pval 1e-3 &> /dev/null
done

for POP in BUL LTV CRO EST+CAU SLV;
do
  NSAMS=wc -l Gj_EU_$POP.filelist | awk '{print $1}'
  NSITES=`$WOK/${POP}.mafs.gz | tail -n+2 | wc -l`
  echo $POP $NSAMS $NSITES
  zcat $WOK/$POP.glf.gz | ngsF --n_ind $NSAMS --n_sites $NSITES --glf - --out $WOK/$POP.approx_indF --approx_EM --init_values u --n_threads 10 &> /dev/null
  zcat $WOK/$POP.glf.gz | ngsF --n_ind $NSAMS --n_sites $NSITES --glf - --out $WOK/$POP.indF --init_values $WOK/$POP.approx_indF.pars --n_threads 10 &> /dev/null
  cat $WOK/$POP.indF
done
