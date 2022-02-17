#!/bin/bash
#SBATCH --job-name=smallRNA_Collapse
#SBATCH --output=logs/Collapse_%j.out
#SBATCH --error=logs/Collapse_%j.err
#SBATCH --partition=duo-pro
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task 1
#SBATCH --mem 1gb
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
inDir=$(pwd)/N4/${sampleName}_${sampleShortName}/
inFqGz=${inDir}/${sampleName}.fq.gz

#out
step="collapse"
outDir=$(pwd)/${step}/${sampleName}_${sampleShortName}/
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


ml DigitalBarcodeReadgroups/0.1.10-GCC-10.2.0-Perl-5.32.0 mirdeep2/0.1.3-GCC-10.2.0-Perl-5.32.0  

zcat ${inDir}/${sampleName}.fq.gz |fastq2fasta.pl - | collapse_reads_md.pl - ${sampleShortName} > ${outDir}/${sampleShortName}.collapseMd.fa

touch $doneFile

echo "## "$(date)" ##  $0 Done "
