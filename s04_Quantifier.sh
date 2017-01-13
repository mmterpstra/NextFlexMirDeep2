#!/bin/bash
#SBATCH --job-name=Quantifier
#SBATCH --output=logs/Quantifier_%j.out
#SBATCH --error=logs/Quantifier_%j.err
#SBATCH --partition=duo-pro
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
step="quantfier"
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

mkdir -p $outDir;

mkdir -p $outDir/high_conf_nf
cd $outDir/high_conf_nf
perl -wne 'my $header = $_; defined(my $seq = <>) or die "Input error incomplete fasta"; chomp $seq;print $header.$seq."\n" if(length($seq) >= 17);' ${mainDir}/nf.sample.all.reads.fa > $(pwd)/high_conf_nf.sample.all.reads.fa 
quantifier.pl  -c ${mainDir}/nf.sample.config -p ${mainDir}/mirbase21/high_conf_hairpin.fa -m ${mainDir}/mirbase21/high_conf_mature.fa -r $(pwd)/high_conf_nf.sample.all.reads.fa -y nf.highconf -P -t hsa -W

mkdir -p $outDir/high_conf_default
cd $outDir/high_conf_default
perl -wne 'my $header = $_; defined(my $seq = <>) or die "Input error incomplete fasta"; chomp $seq;print $header.$seq."\n" if(length($seq) >= 17);' ${mainDir}/default.sample.all.reads.fa > $(pwd)/high_conf_default.sample.all.reads.fa
quantifier.pl  -c ${mainDir}/default.sample.config -p ${mainDir}/mirbase21/high_conf_hairpin.fa -m ${mainDir}/mirbase21/high_conf_mature.fa -r $(pwd)/high_conf_default.sample.all.reads.fa -y default.highconf -P -t hsa -W

mkdir -p $outDir/nf
cd $outDir/nf
perl -wne 'my $header = $_; defined(my $seq = <>) or die "Input error incomplete fasta"; chomp $seq;print $header.$seq."\n" if(length($seq) >= 17);' ${mainDir}/nf.sample.all.reads.fa > $(pwd)/nf.sample.all.reads.fa
quantifier.pl  -c ${mainDir}/nf.sample.config -p ${mainDir}/mirbase21/hairpin.fa -m ${mainDir}/mirbase21/mature.fa -r $(pwd)/nf.sample.all.reads.fa -P -t hsa -W -y nf

mkdir -p $outDir/default
cd $outDir/default
perl -wne 'my $header = $_; defined(my $seq = <>) or die "Input error incomplete fasta"; chomp $seq;print $header.$seq."\n" if(length($seq) >= 17);' ${mainDir}/default.sample.all.reads.fa > $(pwd)/default.sample.all.reads.fa
quantifier.pl  -c ${mainDir}/default.sample.config -p ${mainDir}/mirbase21/hairpin.fa -m ${mainDir}/mirbase21/mature.fa -r $(pwd)/default.sample.all.reads.fa -P -t hsa -W -y default

#.sample.all.reads.fa
#ml DigitalBarcodeReadgroups/0.1.6-foss-2015b-Perl-5.20.2-bare mirdeep2/0.0.8-foss-2015b-Perl-5.20.2


touch $doneFile

echo "## "$(date)" ##  $0 Done "
