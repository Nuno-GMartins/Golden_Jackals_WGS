#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J SMC++      ## you can give whatever name you want here to identify your job
#SBATCH -o SMC++_%A.log	## name a file to save log of your job
#SBATCH -e SMC++_%A.error	## save error message if any	
##SBATCH --mail-user=example@example.dk	## your email account to receive notification of job status
##SBATCH --mail-type=ALL	## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 20:00:00	## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 8	## number cpus
#SBATCH --mem=10gb	## total RAM
##SBATCH --output=/projects/mjolnir1/people/jbf527/jackals/heterozygosity/angsd%A%a.log
##SBATCH --array=1-38%7

############################################
# Your scripts below
############################################

module load smcpp/1.15.5

HAP=/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_GoldenJackals
VC=GoldenJackals_vcf_pruned.vcf.gz

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ203_MJ203 MJ186_MJ186 -c 15000 $VC chr"$i".Europe.gz "$i" \
  Europe:MJ001_MJ001,MJ134_MJ134,MJ135_MJ135,MJ136_MJ136,MJ137_MJ137,MJ138_MJ138,MJ139_MJ139,MJ141_MJ141,MJ142_MJ142,MJ143_MJ143,MJ144_MJ144,MJ154_MJ154,MJ155_MJ155,MJ156_MJ156,MJ175_MJ175,MJ176_MJ176,MJ177_MJ177,MJ178_MJ178,MJ181_MJ181,MJ182_MJ182,MJ183_MJ183,MJ184_MJ184,MJ185_MJ185,MJ186_MJ186,MJ188_MJ188,MJ189_MJ189,MJ190_MJ190,MJ191_MJ191,MJ200_MJ200,MJ202_MJ202,MJ203_MJ203,MJ208_MJ208,MJ209_MJ209,MJ210_MJ210,MJ211_MJ211,MJ260_MJ260,MJ261_MJ261,MJ262_MJ262,MJ263_MJ263,MJ282_MJ282,MJ284_MJ284,MJ290_MJ290,MJ293_MJ293,MJ297_MJ297,MJ305_MJ305,MJ310_MJ310,MJ311_MJ311,MJ349_MJ349
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ195_MJ195 MJ196_MJ196 -c 15000 $VC chr"$i".Croatia.gz "$i" \
  Croatia:MJ195_MJ195,MJ196_MJ196,MJ197_MJ197,MJ198_MJ198,MJ199_MJ199
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ163_MJ163 MJ166_MJ166 -c 15000 $VC chr"$i".Latvia.gz "$i" \
  Latvia:MJ163_MJ163,MJ165_MJ165,MJ166_MJ166,MJ167_MJ167,MJ168_MJ168,MJ169_MJ169
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ125_MJ125 MJ323_MJ323 -c 15000 $VC chr"$i".MiddleEast.gz "$i" \
  MiddleEast:MJ125_MJ125,MJ250_MJ250,MJ264_MJ264,MJ267_MJ267,MJ322_MJ322,MJ323_MJ323
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ160_MJ160 MJ312_MJ312 -c 15000 $VC chr"$i".Baltics.gz "$i" \
  Baltics:MJ158_MJ158,MJ159_MJ159,MJ160_MJ160,MJ161_MJ161,MJ162_MJ162,MJ312_MJ312,MJ313_MJ313
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ127_MJ127 MJ133_MJ133 -c 15000 $VC chr"$i".India.gz "$i" \
  India:MJ127_MJ127,MJ133_MJ133,MJ252_MJ252,MJ324_MJ324
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ079_MJ079 MJ268_MJ268 -c 15000 $VC chr"$i".Israel.gz "$i" \
  Israel:MJ003_MJ003,MJ005_MJ005,MJ006_MJ006,MJ007_MJ007,MJ008_MJ008,MJ011_MJ011,MJ061_MJ061,MJ062_MJ062,MJ063_MJ063,MJ064_MJ064,MJ065_MJ065,MJ066_MJ066,MJ067_MJ067,MJ068_MJ068,MJ079_MJ079,MJ080_MJ080,MJ081_MJ081,MJ082_MJ082,MJ131_MJ131,MJ268_MJ268
done

for i in {1..38}
do
  smc++ vcf2smc -v --cores 10 -d MJ118_MJ118 MJ255_MJ255 -c 15000 $VC chr"$i".Caucasus.gz "$i" \
  Caucasus:MJ118_MJ118,MJ119_MJ119,MJ170_MJ170,MJ172_MJ172,MJ173_MJ173,MJ254_MJ254,MJ255_MJ255,MJ315_MJ315,MJ316_MJ316
done

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.Europe.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf Europe_plot.pdf
mv plot.csv Europe_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.Croatia.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf Croatia_plot.pdf
mv plot.csv Croatia_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.Latvia.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf Latvia_plot.pdf
mv plot.csv Latvia_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.MiddleEast.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf MiddleEast_plot.pdf
mv plot.csv MiddleEast_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.Baltics.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf Baltics_plot.pdf
mv plot.csv Baltics_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.India.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf India_plot.pdf
mv plot.csv India_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.Israel.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf Israel_plot.pdf
mv plot.csv Israel_plot.csv

smc++ estimate -v 0.45e-8 --spline cubic --timepoints 1e2 1e5 --cores 8 chr*.Caucasus.gz
smc++ plot -v -g 4 -c plot.pdf model.final.json
mv plot.pdf Caucasus_plot.pdf
mv plot.csv Caucasus_plot.csv
