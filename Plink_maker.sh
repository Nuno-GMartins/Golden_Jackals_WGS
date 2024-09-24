#!/bin/bash
### NOTE: lines start only with '#SBATCH' are the option setting of slurm, all other lines are comments, eg. '##SBATCH', '# SBATCH' ###

#SBATCH -J Plink_maker      ## you can give whatever name you want here to identify your job
#SBATCH -o Plink_maker.log  ## name a file to save log of your job
#SBATCH -e Plink_maker_%A.error        ## save error message if any    
##SBATCH --mail-user=example@example.dk ## your email account to receive notification of job status
##SBATCH --mail-type=ALL        ## ALL mean you will receive everything about your job, such like start running, fail, or finish
#SBATCH -t 15:00:00 ## give an estimation of how long is your job going to run, format HH:MM:SS 
##SBATCH -p hologenomics
#SBATCH -c 12   ## number cpus
#SBATCH --mem=100gb      ## total RAM
##SBATCH --array=1-41%5

############################################
# Your scripts below
############################################

module load angsd/0.940
module load plink/2.0.0

file="$1" # Filelist file

na=$(echo $file | cut -f 1 -d "." | cut -f 2 -d "_")

WOK=/projects/mjolnir1/people/jbf527/jackals/filtered_bams
HPC=/projects/mjolnir1/people/jbf527/jackals/haplotype/Pop_$na

#zcat GJ-all_chr1.haplo.gz > $LOC
#for i in {2..38}; do zcat GJ-all_chr$i.haplo.gz | tail -n +2 >> $LOC; done
#zcat GJ-all_chrX.haplo.gz | tail -n +2 >> $LOC
#zcat GJ-all_chrY.haplo.gz | tail -n +2 >> $LOC
#zcat GJ-all_chrMT.haplo.gz | tail -n +2 >> $LOC
#gzip $LOC

#haploToPlink Europe_haplotype.haplo.gz Europe_haplotype

#zcat GJ_Miss0.haplo.gz | awk 'NR!=1 {delete a;for(i=4;i<=NF;i++){if($i!="N"){a[$i]++}};if(length(a)<=2){print $0};next} NR==1 {print $0}' OFS='\t' | gzip -c > GJ.haplo.al2.gz

#haploToPlink GJ.haplo.al2.gz $HPC/GJackal_haplo

#cp $HPC/GJackal_haplo.tped $HPC/GJackal_haplo.old.tped

#cat $HPC/GJackal_haplo.old.tped | sed 's/N N/0 0/g' > $HPC/GJackal_haplo.tped

#plink2 --tfile $HPC/GJackal_"$na"_haplo --allow-extra-chr --make-bed --out $HPC/"$na"_haplo --chr-set 38
#wait
#haploToPlink GJ-HC_EUR_chrTEST_hap.haplo.al2.gz GJ-HC_EUR_TEST_chr1_haplotype

# we want to edit the FAM file so that it has a meaningful name
# We will change ind0 (ANGSD default name) for each name of the samples we used:
awk '{print $1}' "$na"_haplo.fam > listA #list the names of the fam file (ind0-n)

while read p; do
    echo $p | cut -f 1 -d "."
done < $WOK/$file > listB

# This command lits the names of each sample used to generate the initial haplotype file
cp "$na"_haplo.fam "$na"_haplo.old.fam

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
' listA listB "$na"_haplo.old.fam > "$na"_haplo.fam

sed -i 's/-9$/1/' "$na"_haplo.fam

## We need to filter a bit the file
## The most important filter is to remove transitions
# Filter the sites of the variant file that have transitions
awk '{print $2,$5,$6}' "$na"_haplo.bim > variant_ID.txt
awk -F' ' -v OFS=, '$2=="A" && $3=="G"{print $1}' variant_ID.txt >> ID
awk -F' ' -v OFS=, '$2=="G" && $3=="A"{print $1}' variant_ID.txt >> ID
awk -F' ' -v OFS=, '$2=="C" && $3=="T"{print $1}' variant_ID.txt >> ID
awk -F' ' -v OFS=, '$2=="T" && $3=="C"{print $1}' variant_ID.txt >> ID

# And now we run the plink command to generate a new filtered plink file
plink2 --bfile "$na"_haplo --allow-extra-chr --chr-set 38 --exclude ID --make-bed --out "$na"_haplo_filtered
wait
## Create .par file so we can convert the plink format to .snp .geno .ind format
echo "genotypename: ${na}_haplo_filtered.bed
snpname: ${na}_haplo_filtered.bim
indivname: ${na}_haplo_filtered.fam
outputformat: EIGENSTRAT
genotypeoutname: ${na}_haplo_filtered.eigenstratgeno
snpoutname: ${na}_haplo_filtered.snp
indivoutname: ${na}_haplo_filtered.ind
familynames: YES
pordercheck: NO" > $na.par

/projects/mjolnir1/apps/conda/eigensoft-7.2.1/bin/convertf -p $na.par

cp "$na"_haplo_filtered.eigenstratgeno "$na"_haplo_filtered.geno

### Now we will add the fox into the dataset so it can be use as an outgroup for different analysis
## Xin script to adding samples into the plink files

echo 'fox	fox	/projects/mjolnir1/people/jbf527/ref/fox/FX001.consensus.fa.gz' > meta.txt

/projects/mjolnir1/people/jbf527/ref/add_sample_to_eig.sh "$na"_haplo_filtered fox meta.txt _

