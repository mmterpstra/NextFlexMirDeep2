#!/bin/bash
#SBATCH --job-name=smallRNA_CollapseNextFlex
#SBATCH --output=logs/Collapse_nextflex_%j.out
#SBATCH --error=logs/Collapse_nextflex_%j.err

#SBATCH --time=10:00:00
#SBATCH --cpus-per-task 1
#SBATCH --mem 12gb
#SBATCH --nodes 1
#SBATCH --open-mode=append
#SBATCH --export=NONE
#SBATCH --get-user-env=L

set -e;
set -x;
set -o pipefail;

#in
fqFile=$1
sampleName=$2
sampleShortName=$3
inDir=$(pwd)/N4/${sampleName}__${sampleShortName}/
inFqGz=${inDir}/${sampleName}.fq.gz

#out
step="nfbccollapse"
outDir=$(pwd)/${step}/${sampleName}__${sampleShortName}/
outBase=${outDir}/${sampleShortName}.collapseMd.fa
doneBase=${outBase}_$(basename ${fqFile})
doneFile=$doneBase.$SLURM_JOB_ID.done

if ls -d ${outDir}/ 1> /dev/null 2>&1 && ls  $doneBase.*.done 1> /dev/null 2>&1 ; then
    	echo "echo "## "$(date)" ##  $0 Finished job exiting."
        exit 0
else
	echo "echo "## "$(date)" ##  $0 Unfinished job restarting." 
	if ls ${outBase}* 1> /dev/null 2>&1 ; then
		rm -rv ${outBase}*
	fi
        if ls ${doneBase}.*.done 1> /dev/null 2>&1 ; then
                rm -rv ${doneBase}.*.done
        fi
fi

echo "## "$(date)" ##  $0 Started "

mkdir -p $outDir;

ml purge
ml DigitalBarcodeReadgroups/0.1.10-GCC-10.2.0-Perl-5.32.0 mirdeep2/0.1.3-GCC-10.2.0-Perl-5.32.0
zcat ${inDir}/${sampleName}__${sampleShortName}.fq.gz |fastq2fasta.pl - | collapse_reads_md.pl - ${sampleShortName} > ${outDir}/${sampleShortName}.collapseMd.fa
#the PCR duplicate problem more pcr dups = more sampleing dispersion vs saturation of a loci. This can be approched greedely by allowing more than 1 read for each barcode to pass, creating more observations and extending the ranges of observed barcodes. beermat (or beer coaster) math says possibleadapters/amountofreadobservations=4^[6-8]/10000 =~ 0.4-6,5 and because the pcr cycles are not taken into account this will likely be higher and more spread for each barcode, but with less saturation. So likely the count of max 2 should be safe. 
#!!!!!!Important the `cut -f8-9,15` might go worng due to dual indexing issues....
zcat ${inDir}/${sampleName}__${sampleShortName}.fq.gz | \
	perl -wne 'if ($. % 4 > 0){chomp ; $_ .= "\t"; if($. % 4 == 1){s![\:\+\ ]!\t!g;}}; print $_;'| \
	cut -f8-9,15 | \
	sort --buffer-size=6G -n | \
	uniq -c | \
	perl -wlane 'if($F[0] < 2){print ">'$sampleShortName'_$._x$F[0]\n$F[3]";}else{print ">'$sampleShortName'_$._x2\n$F[3]";}' | \
	collapse_reads_md.pl - ${sampleShortName} >  ${outBase}
#note this is the regular method, but be sure to check the output:
#zcat ${inDir}/${sampleName}.fq.gz | \
#        perl -wne 'if ($. % 4 > 0){chomp ; $_ .= "\t"; if($. % 4 == 1){s![\:\+\ ]!\t!g;}}; print $_;'| \
#        cut -f14 | \
#        sort --buffer-size=6G -n | \
#        uniq -c | \
#        perl -wlane 'print ">'$sampleShortName'_$._x$F[0]\n$F[3]"' > ${outBase}



touch $doneFile

echo "## "$(date)" ##  $0 Done "
