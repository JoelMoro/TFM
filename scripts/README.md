# CODE USED EXPLANATION


## Running TRUST4 for BD rhapsody

**Example Call**

````{sh}
./run-trust4 -f hg38_bcrtcr.fa --ref human_IMGT+C.fa -1 home/joel/data2/00_fastq/a1/fastq3/*_R1_*.fastq.gz -2 home/joel/data2/00_fastq/a1/fastq3/*_R2_*.fastq.gz  --barcode home/joel/data2/00_fastq/a1/fastq3/*_R1_*.fastq.gz  --readFormat bc:0:52,r1:60:-1 --od home/joel/data/outs/trust4/a1 -o a1
````

It require only to understand the read format. After many tries, in this project the only way to identify propperly the barcode is to go directly to the fastQ files retrieved by BD and checkk for positions in readFormat:
bc:0:52,r1:60:-1

## TRANSLATION TRUST4 FOR USAGE IN SINGLE-CELL
