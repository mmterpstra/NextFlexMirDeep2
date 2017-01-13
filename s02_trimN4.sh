#!/bin/bash
#SBATCH --job-name=trimN4_Digitalbcrgs
#SBATCH --output=logs/Digitalbcrgs_%j.out
#SBATCH --error=logs/Digitalbcrgs_%j.err
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

fqFile=$1
sampleName=$2
sampleShortName=$3
outDirLast=trimGalore/${sampleName}/
outDir=$(pwd)/N4/${sampleName}_${sampleShortName}/

doneBase=${outBase}_$(basename ${fqFile})
doneFile=$doneBase.$SLURM_JOB_ID.done

echo "## "$(date)" ##  $0 Started "
if [ ! -e ${outDir}/ ] || [ ! -e $doneFile ]; then
        echo "echo "## "$(date)" ##  $0 Unfinished job restarting."
        if [ -e ${outDir}/ ] ; then
                rm -rv ${outDir}/
        fi
	if [ -e $doneFile ] ; then
                rm -rv $doneFile
        fi

else
    	echo "echo "## "$(date)" ##  $0 Finished job exiting."
        exit 0
fi


mkdir -p $outDir;


ml DigitalBarcodeReadgroups/0.1.6-foss-2015b-Perl-5.20.2-bare mirdeep2/0.0.8-foss-2015b-Perl-5.20.2
perl $EBROOTDIGITALBARCODEREADGROUPS/src/NextFlexSmallRNARemove4N.pl $outDirLast/$(basename ${fqFile} .fq.gz)'_trimmed.fastq.gz'  ${outDir}/${sampleName}.fq.gz

#touch $doneFile
echo $SLURM_JOB_ID > $doneFile

echo "## "$(date)" ##  $0 Done "
