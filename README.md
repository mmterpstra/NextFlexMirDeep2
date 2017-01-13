# convert flowexport

For easy use in bash as sourceable object some conversion is needed. 

```
#libreoffice -calc 161208_NB501043_0090_AH55LGBGX2.csv #for adding read files and whateversuits your fancy
cp ../../raw/161208_NB501043_0090_AH55LGBGX2/161208_NB501043_0090_AH55LGBGX2.csv ./
perl -i -wpe 's/,,/,undef,/g;s/,,/,undef,/g;' 161208_NB501043_0090_AH55LGBGX2.csv
perl -i -wpe 's/[\@\(\) \-]/_/g;s/,/\t/g' 161208_NB501043_0090_AH55LGBGX2.csv
perl -wane 'use Data::Dumper; if($. == 1){our $obj ; %{$obj} = ();@{ $obj -> {'array'} } = @F;warn Dumper $obj}else{for my $idx (0..(scalar(@{$obj->{'array'}})-1)){$obj->{'array'}->[$idx] =~ s/\//_/g;$F[$idx] =~ s/[^\w\/\.\-]/_/g;my $topr=$obj->{'array'}->[$idx]."=".$F[$idx].";"; print $topr; }print "\n"}' 161208_NB501043_0090_AH55LGBGX2.csv > 161208_NB501043_0090_AH55LGBGX2.source.table.sh; tail -n 10 *.source.table.sh

```
# general setup

```
#
mkdir logs
```


# run fastqc

fastqc for quality control

```
(for i in $(cat 161208_NB501043_0090_AH55LGBGX2.source.table.sh);do . <(echo $i);sbatch s00_fqqc_fastqc.sh $read1fqgz $Sample $lane; done)

```

# run trim galore

adapter trimming tool for illumina adapter removal

```
 (for i in $(cat 161208_NB501043_0090_AH55LGBGX2.source.table.sh);do echo $i ; . <(echo $i);sbatch s01_fqtrim_trimgalore.sh $read1fqgz $Sample $lane; done)

```

# Trim n4 adapters

Remove the random 4 nt sequence at the end and the start of the read and integrate it into the readname. also fumble up a shortname based on a name index.

```
(for i in $(cat 161208_NB501043_0090_AH55LGBGX2.source.table.sh);do . <(echo $i);if [ $lane -eq 1 ] ; then echo sbatch s02_trimN4.sh $read1fqgz  $Sample "S"$(echo $Sample| perl -wpe 's/(^\d+).*/$1/;$_ = sprintf("%02d",$_);' ) | tee >(bash); fi; done)
```

# Collapse NextFlex? Collapse

```
(for i in $(cat 161208_NB501043_0090_AH55LGBGX2.source.table.sh);do . <(echo $i);if [ $lane -eq 1 ] ; then echo sbatch s03.3_CollapseNextFlex.sh $read1fqgz  $Sample "S"$(echo $Sample| perl -wpe 's/(^\d+).*/$1/;$_ = sprintf("%02d",$_);' ) | tee >(bash); fi; done)

```

# Run quantification

```
cat nfbccollapse/*/*.fa > nf.sample.all.reads.fa
cat collapse/*/*.fa > default.sample.all.reads.fa
cp /groups/umcg-griac/tmp04/projects/umcg-mterpstra/VandenBerge_MicroRNAseq/mirbase21 ./ -r
paste  <(ls collapse/*/*.fa) <(ls collapse/*/*.fa | perl -wpe 's!.*\/(S\d\d).*.fa!$1!g;')> default.sample.config
paste  <(ls nfbccollapse/*/*.fa) <(ls nfbccollapse/*/*.fa | perl -wpe 's!.*\/(S\d\d).*.fa!$1!g;')> nf.sample.config
 
sbatch s04_Quantifier.sh r2 10JAN2017 1 2 3 4
sbatch s04_Quantifier_customfa.sh r1 12JAN2017 1 2 3 4

```

#get Readcounts of fastq file from fastqc data

```
for i in $(ls  fastqc/10_1610_Ong_SmallRNAseq_Batch2_1/161208_NB501043_0090_AH55LGBGX2_L1_TAGCTT_fastqc.html ); do echo -ne $i"\t"; perl -wpe 's!</tr>!</tr>\n!g;s!\</{0,1}t[dr]\>\</{0,1}t[dr]\>!\t!g' $i | grep 'Total'; done
```


