# CODE USED EXPLANATION

## MULTIPLEXING

The idea of how to run this step was obtained from https://demultiplexing-doublet-detecting-docs.readthedocs.io/en/latest/.

Before running the application two things are needed:

- 1. You will need to have the bam file from the alignment of the scRNAseq data that you are willing to demultiplex. It is mandatory to also have the vcf file for the SNPs reference and also the fasta file for the reference genome. In our case,  we used the one provided by demuxafy in the case of vcf and used ENSEMBL FTP server to extract the fasta file.
- 2. It is also needed to extract the barcodes from the data. We recommend extracting the barcodees of cells filtered previously from the QC step of the scRNASeq. This will optimize the time taken in execution and also will retrieve results from cells that have a decent signal. To do so, in our case, we used simple Seurat + Tidyverse approach:

````{r}
gfege
````

Therefore, to an example of execution of the code:

````{sh}
chmod +x scsplit_pipeline.sh #Make sure the script can be executed
./scsplit_pipeline.sh --barcodes /path/to/barcodes.tsv --bam /path/to/bam.bam --outdir /path/to/output --n 12 --vcf /path/to/vcf --fasta /path/to/fasta

````
## Running TRUST4 for BD rhapsody

**Example Call**

````{sh}
./run-trust4 -f hg38_bcrtcr.fa --ref human_IMGT+C.fa -1 home/joel/data2/00_fastq/a1/fastq3/*_R1_*.fastq.gz -2 home/joel/data2/00_fastq/a1/fastq3/*_R2_*.fastq.gz  --barcode home/joel/data2/00_fastq/a1/fastq3/*_R1_*.fastq.gz  --readFormat bc:0:52,r1:60:-1 --od home/joel/data/outs/trust4/a1 -o a1
````

It require only to understand the read format. After many tries, in this project the only way to identify propperly the barcode is to go directly to the fastQ files retrieved by BD and checkk for positions in readFormat:
bc:0:52,r1:60:-1

## TRANSLATION TRUST4 FOR USAGE IN SINGLE-CELL
