#!/bin/bash
#SBATCH --job-name=Quantifier
#SBATCH --output=logs/Quantifier_%j.out
#SBATCH --error=logs/Quantifier_%j.err

#SBATCH --time=4-23:00:00
#SBATCH --cpus-per-task 1
#SBATCH --mem 7gb
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
inFa=$0/
mainDir=$(pwd)

#out
step="quantfier_customfa"
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

ml DigitalBarcodeReadgroups/0.1.6-foss-2015b-Perl-5.20.2-bare mirdeep2/0.0.8-foss-2015b-Perl-5.20.2
#pseudo: quantifier.pl -P -p hsa_viral_novel_hairpin.fa -c mirdeep.config -m hsa_viral_novel_mature.fa -r processed.all.collapse_md.fa -y quantifier_run_00 -W >quantifier.out 2> quantifier.err
#quantifier.pl -c /groups/umcg-oncogenetics/tmp04/projects/NextFlexForOng/nf.sample.config -m /groups/umcg-oncogenetics/tmp04/projects/NextFlexForOng/custom.fa -p /groups/umcg-oncogenetics/tmp04/projects/NextFlexForOng/custom.fa -r /groups/umcg-oncogenetics/tmp04/projects/NextFlexForOng/quantfier/12JAN2017_1/nf/nf.sample.all.reads.fa -y nf_custom -W -e 300 -f 300
mkdir -p $outDir;

mkdir -p $outDir/nf
cd $outDir/nf
perl -wne 'my $header = $_; defined(my $seq = <>) or die "Input error incomplete fasta"; chomp $seq;print $header.$seq."\n" if(length($seq) >= 17);' ${mainDir}/nf.sample.all.reads.fa > $(pwd)/nf.sample.all.reads.fa
quantifier.pl -g 0 -c ${mainDir}/nf.sample.config -p ${mainDir}/custom.fa -m ${mainDir}/custom.fa -r $(pwd)/nf.sample.all.reads.fa -P -W -y nf_custom -W -e 300 -f 300

mkdir -p $outDir/default
cd $outDir/default
perl -wne 'my $header = $_; defined(my $seq = <>) or die "Input error incomplete fasta"; chomp $seq;print $header.$seq."\n" if(length($seq) >= 17);' ${mainDir}/default.sample.all.reads.fa > $(pwd)/default.sample.all.reads.fa
quantifier.pl -g 0 -c ${mainDir}/default.sample.config -p ${mainDir}/custom.fa -m ${mainDir}/custom.fa -r $(pwd)/default.sample.all.reads.fa -P -W -y default_custom

#ml DigitalBarcodeReadgroups/0.1.6-foss-2015b-Perl-5.20.2-bare mirdeep2/0.0.8-foss-2015b-Perl-5.20.2


touch $doneFile

echo "## "$(date)" ##  $0 Done "
