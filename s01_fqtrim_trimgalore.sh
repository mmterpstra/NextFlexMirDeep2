#!/bin/bash
#SBATCH --job-name=smallRNA_TrimGalore_%j
#SBATCH --output=logs/Trimgalore_%j.out
#SBATCH --error=logs/TrimGalore_%j.err
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
lane=$3
outDir=$(pwd)/trimGalore/$sampleName/
#doneFile=$(ls "${outDir}/"$(basename "${fqFile}")".*.done")

step="trimGalore"
outDir=$(pwd)/${step}/${sampleName}_${sampleShortName}_${lane}/
mkdir -p $outDir
outBase=${outDir}/$(basename ${fqFile} .fq.gz)
doneBase=${outBase}_$(basename ${fqFile})
doneFile=$doneBase.$SLURM_JOB_ID.done

if ls -d ${outDir}/ &> /dev/null && ls  $doneBase.*.done &> /dev/null ; then
    	echo "echo "## "$(date)" ##  $0 Finished job exiting."
        exit 0
else
	echo "echo "## "$(date)" ##  $0 Unfinished job restarting." 
	if ls ${outBase}* &> /dev/null ; then
		rm -rv ${outBase}*
	fi
        if ls ${doneBase}.*.done &> /dev/null; then
                rm -rv ${doneBase}.*.done
        fi
fi

mkdir -p $outDir;


ml FastQC/0.11.5-Java-1.7.0_80 TrimGalore/0.3.7-foss-2015b
trim_galore --adapter TGGAATTCTCGGGTGCCAAGG --length 15 --output_dir  ${outDir}/ --fastqc_args "--noextract"  ${fqFile}

touch $doneFile

echo "## "$(date)" ##  $0 Done "
