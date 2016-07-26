# An assembly tutorial with MEGAHIT

C. Titus Brown

July 2016.

Click here:

[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org:/repo/mblmicdiv/ecoli-assembly-binder)

to start a binder.

-----

Open a terminal, and get command line access.

Now, download some data:

```
curl -O -L https://s3.amazonaws.com/public.ged.msu.edu/ecoli_ref-5m.fastq.gz
```

This is an E. coli single-colony data set originally from
[Chitsaz et al., 2011](https://www.ncbi.nlm.nih.gov/pubmed/21926975).

Let's take a look at this data -- it's just interleaved, paired-end data

```
gunzip -c ecoli_ref-5m.fastq.gz | head   
```

(see the /1 and /2 at the ends of each sequence).  Coming from a
sequencing facility, you would normally have two files, one containing
the /1 sequences and the other containing the /2 sequences; you can
use e.g. the [khmer software's](https://khmer.readthedocs.io/) script
`interleave-reads.py` to combine them.

We're going to do two things to this data.  We're going to assemble it,
and, while we're assembling it, we're going to evaluate the quality of
the reads.

## Assembling

In one terminal, run
[the MEGAHIT assembler](https://github.com/voutcn/megahit).

```
megahit --12 ecoli_ref-5m.fastq.gz -o ecoli
```

This will take about 10 minutes to run.  While it runs, also run the
FastQC report (next).

## Evaluating the quality of your reads with FastQC

In another terminal, run FASTQC:

```
fastqc ecoli_ref-5m.fastq.gz
```

This will produce a file `ecoli_ref-5m_fastqc.zip` file that you can
download from the console.  Open the zip file on your local computer,
and find the file `ecoli_ref-5m_fastqc.html`. Double click on that.

This is a
[FastQC report](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
that gives you a basic report on the quality of your sequencing.

## Looking at your assembly: mapping

In the meantime, your assembly should have finished!  You should see
something like

```
--- [Tue Jul 26 17:33:02 2016] ALL DONE. Time elapsed: 931.238694 seconds ---
```

There will be a file `ecoli/final.contigs.fa` - copy it out and compress it,

```
cp ecoli/final.contigs.fa ecoli-assembly.fa
```

If you look at this assembly with 'head', you'll see it's a bunch of
FASTA sequences.  How do you look at it comprehensively?

Try running [quast](http://quast.sourceforge.net/quast):

```
quast.py ecoli-assembly.fa -o ecoli_report
```

This will produce a set of output files that will be in ecoli_report; let's
grab that:

```
zip -r ecoli_report.zip ecoli_report
```

and then download ecoli_report.zip via the console and unpack it.
You want to look at report.txt or report.html.  This will give you basic
assembly stats.

## Mapping reads

Let's subsample the reads to get the first 250,000:

```
gunzip -c ecoli_ref-5m.fastq.gz | head -1000000 | 
     split-paired-reads.py -1 head.1 -2 head.2 
```

Use BWA to align the reads:

```
bwa index ecoli-assembly.fa 
bwa aln ecoli-assembly.fa head.1 > head.1.sai 
bwa aln ecoli-assembly.fa head.2 > head.2.sai 
bwa sampe ecoli-assembly.fa head.1.sai head.2.sai head.1 head.2 > head.sam
```

Convert the alignments into a BAM format:

```
samtools faidx ecoli-asssembly.fa
samtools import ecoli-assembly.fai head.sam head.bam
samtools sort head.bam head.sorted
samtools index head.sorted.bam
```

and now you can ask questions.  For example, 
this command gives you how many reads didn't align to the reference:

```
samtools view -c -f 4 head.sorted.bam
```

and this tells you how many did:

```
samtools view -c -F 4 head.sorted.bam
```

and from this you can calculate a mapping percentage.  (> 98%, basically.)
Higher mapping percentages are good; the higher the mapping, the more
inclusive your assembly is.

## Running BLAST against your assembly


You can also search your assembly for desired genes.  First, we need to
make a BLAST database:

```
makeblastdb -dbtype nucl -in ecoli-assembly.fa
```

and now let's grab an E. coli gene:

```
curl -O http://www.uniprot.org/uniprot/P0ACJ8.fasta 
```

and BLAST it against the assembly:

```
tblastn -query P0ACJ8.fasta -db ecoli-assembly.fa
```

Do we see the expected match?

## Annotating your assembly with Prokka

To annotate the genomic sequence and produce a file that is almost
suited for upload to NCBI, you can use
[Prokka](https://github.com/tseemann/prokka).

Run it like so:

```
prokka --outdir anno --prefix prokka ecoli-assembly.fa
```

You can look at `anno/prokka.txt` to see stats on the output:

```
head anno/prokka.txt
```

-- it should have found around 4,239 genes.

To visualize this locally, zip up the Prokka GFF output file:

```
zip -r anno.zip anno/prokka.gff
```

and download `anno.zip` to your desktop -- now you can open it using
[artemis](http://www.sanger.ac.uk/science/tools/artemis).
