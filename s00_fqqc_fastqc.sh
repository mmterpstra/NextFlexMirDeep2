#!/bin/bash
#SBATCH --job-name=smallRNA_Fastqc_%j
#SBATCH --output=logs/Fastqc_%j.out
#SBATCH --error=logs/Fastqc_%j.err
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

outDir=$(pwd)/fastqc/${sampleName}_${lane}/

echo "## "$(date)" ##  $0 Started "
if [ ! -e ${outDir}/ ] || [ ! -e ${outDir}/$(basename ${fqFile}).$SLURM_JOB_ID.done ]; then 
	echo "echo "## "$(date)" ##  $0 Unfinished job restarting." 
	if [ -e ${outDir}/ ] ; then
		rm -rv ${outDir}/ 
	fi
        if [ -e ${outDir}/$(basename ${fqFile}).$SLURM_JOB_ID.done ] ; then
                rm -rv ${outDir}/$(basename ${fqFile}).$SLURM_JOB_ID.done
        fi
else
	echo "echo "## "$(date)" ##  $0 Finished job exiting."
	exit 0
fi

mkdir -p $outDir;

ml FastQC/0.11.9-Java-11
fastqc --noextract ${fqFile} --outdir ${outDir}/

touch ${outDir}/$(basename ${fqFile}).$SLURM_JOB_ID.done

echo "## "$(date)" ##  $0 Done "
