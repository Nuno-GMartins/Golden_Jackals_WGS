#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Plink_maker      ## you can give whatever name you want here to identify your job
#SBATCH -o Plink_maker.log  ## name a file to save log of your job
#SBATCH -e Plink_maker_GJ.error        ## save error message if any    
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 10:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 6   ## number cpus
#SBATCH --mem=85gb      ## total RAM
##SBATCH --array=1-41%5

############################################
# Your scripts below
############################################

module load angsd/0.940
module load plink/2.0.0

file="$1" #name of the filelist with the samples names to which we generated the haplotypes
beg="$2" #name of one of the haplo files - Ex: GJ_ExpandedGoldenJackals_chr1.haplo.gz

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams

#na=$(echo $WOK/$file | cut -f 1 -d "." | cut -f 8 -d "/")
DAT=$(echo $beg | cut -f 1 -d "." | cut -f 1 -d "_")
na=$(echo $DAT | cut -f 2 -d "_")
BG="$na".haplo

HPC=/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_$na

#zcat $HPC/"$DAT"_chr1.haplo.gz > $HPC/$BG
#for i in {2..38}; do zcat $HPC/"$DAT"_chr"$i".haplo.gz | tail -n +2 >> $HPC/$BG; done
#zcat $HPC/"$DAT"_chrX.haplo.gz | tail -n +2 >> $HPC/$BG
#zcat $HPC/"$DAT"_chrY.haplo.gz | tail -n +2 >> $HPC/$BG
#zcat $HPC/"$DAT"_chrMT.haplo.gz | tail -n +2 >> $HPC/$BG

#cat $HPC/$BG | awk 'NR!=1 {delete a;for(i=4;i<=NF;i++){if($i!="N"){a[$i]++}};if(length(a)<=2){print $0};next} NR==1 {print $0}' OFS='\t' | gzip -c > $HPC/$BG.gz
#cat $HPC/$BG | awk 'NR!=1 {delete a;for(i=4;i<=NF;i++){if($i!="N"){a[$i]++}};if(length(a)<=2){print $0};next} NR==1 {print $0}' OFS='\t' | gzip -c > $HPC/$BG.gz

haploToPlink $HPC/$BG.gz $HPC/Canids_"$na"_haplo

cp $HPC/Canids_"$na"_haplo.tped $HPC/Canids_"$na"_haplo.old.tped

cat $HPC/Canids_"$na"_haplo.old.tped | sed 's/N N/0 0/g' > $HPC/Canids_"$na"_haplo.tped

plink2 --tfile $HPC/Canids_"$na"_haplo --allow-extra-chr --make-bed --out $HPC/Canids_"$na"_haplo --chr-set 38

# we want to edit the FAM file so that it has a meaningful name
# We will change ind0 (ANGSD default name) for each name of the samples we used:
awk '{print $1}' $HPC/Canids_"$na"_haplo.fam > $HPC/listA #list the names of the fam file (ind0-n)

#while read p; do
#  echo $p | cut -f 1 -d "." | cut -f 8 -d "/"
#done < $WOK/$file > $HPC/listB

# This command lits the names of each sample used to generate the initial haplotype file
cp $HPC/Canids_"$na"_haplo.fam $HPC/Canids_"$na"_haplo.old.fam

awk '
    FILENAME == ARGV[1] { listA[$1] = FNR; next }
    FILENAME == ARGV[2] { listB[FNR] = $1; next }
    {
        for (i = 1; i <= NF; i++) {
            if ($i in listA) {
                $i = listB[listA[$i]]
            }
        }
        print
    }
' $HPC/listA $HPC/listB $HPC/Canids_"$na"_haplo.old.fam > $HPC/Canids_"$na"_haplo.fam

sed -i 's/-9$/1/' $HPC/Canids_"$na"_haplo.fam

## We need to filter a bit the file
## The most important filter is to remove transitions
# Filter the sites of the variant file that have transitions
awk '{print $2,$5,$6}' $HPC/Canids_"$na"_haplo.bim > $HPC/variant_ID.txt
awk -F' ' -v OFS=, '$2=="A" && $3=="G"{print $1}' $HPC/variant_ID.txt > $HPC/ID
awk -F' ' -v OFS=, '$2=="G" && $3=="A"{print $1}' $HPC/variant_ID.txt >> $HPC/ID
awk -F' ' -v OFS=, '$2=="C" && $3=="T"{print $1}' $HPC/variant_ID.txt >> $HPC/ID
awk -F' ' -v OFS=, '$2=="T" && $3=="C"{print $1}' $HPC/variant_ID.txt >> $HPC/ID

# And now we run the plink command to generate a new filtered plink file
plink2 --bfile $HPC/Canids_"$na"_haplo --allow-extra-chr --chr-set 38 --exclude ID --make-bed --out $HPC/Canids_"$na"_haplo_filtered

## Create .par file so we can convert the plink format to .snp .geno .ind format
echo "genotypename: Canids_${na}_haplo_filtered.bed
snpname: Canids_${na}_haplo_filtered.bim
indivname: Canids_${na}_haplo_filtered.fam
outputformat: EIGENSTRAT
genotypeoutname: ${na}_haplo_filtered.eigenstratgeno
snpoutname: ${na}_haplo_filtered.snp
indivoutname: ${na}_haplo_filtered.ind
familynames: YES
pordercheck: NO" > $HPC/$na.par

/projects/mjolnir1/apps/conda/eigensoft-7.2.1/bin/convertf -p $HPC/$na.par

cp $HPC/"$na"_haplo_filtered.eigenstratgeno $HPC/"$na"_haplo_filtered_old.eigenstratgeno

mv $HPC/"$na"_haplo_filtered.eigenstratgeno $HPC/"$na"_haplo_filtered.geno

### Now we will add the fox into the dataset so it can be use as an outgroup for different analysis
## Xin script to adding samples into the plink files

echo 'fox	fox	/projects/mjolnir1/people/jbf527/ref/fox/FX001.consensus.fa.gz' > $HPC/meta.txt
echo 'dog_india         dog     /projects/mjolnir1/people/jbf527/jackals/consensus/MD001.consensus.fa.gz' >> $HPC/meta.txt
echo 'dog_sweden	dog     /projects/mjolnir1/people/jbf527/jackals/consensus/MD012.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'wolf_israel     wolf    /projects/mjolnir1/people/jbf527/jackals/consensus/MW171.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'wolf_mongolia     wolf	/projects/mjolnir1/people/jbf527/jackals/consensus/MW610.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'africa_wolf_egypt     AfricawolfE    /projects/mjolnir1/people/jbf527/jackals/consensus/MJ121.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'africa_wolf_marocco     AfricawolfW    /projects/mjolnir1/people/jbf527/jackals/consensus/MJ122.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'ethiopia_wolf     Ethiopiawolf    /projects/mjolnir1/people/jbf527/jackals/consensus/MJ129.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'dhole     Dhole    /projects/mjolnir1/people/jbf527/jackals/consensus/Consensus/MJ338.Trans.consensus.fa.gz' >> $HPC/meta.txt
echo 'jackal Side-stripedJackal /projects/mjolnir1/people/jbf527/Africa/consensus/Consensus/MJ352.consensus.fa.gz' >> $HPC/meta.txt
echo 'MJ320     Thailand    /projects/mjolnir1/people/jbf527/jackals/consensus/MJ320.Trans.consensus.fa.gz' >> $HPC/meta.txt

/projects/mjolnir1/people/jbf527/ref/add_sample_to_eig.sh "$na"_haplo_filtered outgps meta.txt _ $HPC

module unload plink/2.0.0

module load plink/1.9.0
plink --bfile Canids_"$na"_haplo_filtered --indep-pairwise 50 5 0.5 --out "$na" --allow-extra-chr --chr-set 38
plink --bfile Canids_"$na"_haplo_filtered --allow-extra-chr --chr-set 38 --maf 0.05 --make-bed --out "$na"_haplo_filtered_filtercount

module unload plink/1.9.0

module load plink/2.0.0
plink2 --bfile Canids_"$na"_haplo_filtered --allow-extra-chr --chr-set 38 --exclude "$na".prune.out --make-bed --out "$na"_haplo_filtered_pruned

module unload plink/2.0.0

module load plink/1.9.0
plink --bfile "$na"_haplo_filtered_pruned --allow-extra-chr --chr-set 38 --maf 0.05 --make-bed --out "$na"_haplo_filtered_pruned-filtercount

## Create .par file so we can convert the plink format to .snp .geno .ind format
echo "genotypename: ${na}_haplo_filtered_pruned-filtercount.bed
snpname: ${na}_haplo_filtered_pruned-filtercount.bim
indivname: ${na}_haplo_filtered_pruned-filtercount.fam
outputformat: EIGENSTRAT
genotypeoutname: ${na}_haplo_filtered_pruned-filtercount.eigenstratgeno
snpoutname: ${na}_haplo_filtered_pruned-filtercount.snp
indivoutname: ${na}_haplo_filtered_pruned-filtercount.ind
familynames: YES
pordercheck: NO" > $HPC/"$na"_pruned-filtercount.par

/projects/mjolnir1/apps/conda/eigensoft-7.2.1/bin/convertf -p $HPC/"$na"_pruned-filtercount.par

cp $HPC/"$na"_haplo_filtered_pruned-filtercount.eigenstratgeno $HPC/"$na"_haplo_filtered_pruned-filtercount_old.eigenstratgeno

mv $HPC/"$na"_haplo_filtered_pruned-filtercount.eigenstratgeno $HPC/"$na"_haplo_filtered_pruned-filtercount.geno

/projects/mjolnir1/people/jbf527/ref/add_sample_to_eig.sh "$na"_haplo_filtered_pruned-filtercount outgps meta.txt _ $HPC
