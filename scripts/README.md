# CODE USED EXPLANATION

## DEMULTIPLEXING

The idea of how to run this step was obtained from https://demultiplexing-doublet-detecting-docs.readthedocs.io/en/latest/.

Before running the application two things are needed:

- 1. You will need to have the bam file from the alignment of the scRNAseq data that you are willing to demultiplex. It is mandatory to also have the vcf file for the SNPs reference and also the fasta file for the reference genome. In our case,  we used the one provided by demuxafy in the case of vcf and used ENSEMBL FTP server to extract the fasta file.
- 2. It is also needed to extract the barcodes from the data. We recommend extracting the barcodees of cells filtered previously from the QC step of the scRNASeq. This will optimize the time taken in execution and also will retrieve results from cells that have a decent signal. To do so, in our case, we used simple Seurat + Tidyverse approach. We provide a general example for anyone to use. The linquers and CLS are provided as well in the barcode_translation.py code, but since it can change depending on the BD Rhapsody or other techonology modality, we leave it up to the user to accomodate.

````{r}
library(Tidyverse)
library(Seurat)

# Generalized function for barcode translation
index_to_sequence <- function(index, cell_key1, cell_key2, cell_key3, linker1, linker2) {
  zerobased <- as.integer(index) - 1
  
  cl1 <- (as.integer((zerobased) / 384 / 384) %% 384) + 1
  cl2 <- (as.integer((zerobased) / 384) %% 384) + 1
  cl3 <- (zerobased %% 384) + 1
  
  cls1_sequence <- cell_key1[cl1]
  cls2_sequence <- cell_key2[cl2]
  cls3_sequence <- cell_key3[cl3]
  
  return(paste0(cls1_sequence, linker1, cls2_sequence, linker2, cls3_sequence))
}

# Wrapper to process a Seurat object
process_seurat_object <- function(seurat_obj, cell_key1, cell_key2, cell_key3, linker1, linker2, output_dir, file_prefix) {
  # Ensure the output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Extract metadata table with rownames
  tbl <- seurat_obj@meta.data %>%
    rownames_to_column("index") %>%
    select(index, Sample_Name)
  
  # Translate indices to barcodes
  tbl$barcode <- sapply(tbl$index, function(idx) index_to_sequence(idx, cell_key1, cell_key2, cell_key3, linker1, linker2))
  
  # Save the full table
  write.table(tbl, file = file.path(output_dir, paste0(file_prefix, "_table.txt")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
  
  # Save barcodes only
  write.table(tbl$barcode, file = file.path(output_dir, paste0("barcodes_", file_prefix, ".tsv")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)
  
  # Save indices only
  write.table(tbl$index, file = file.path(output_dir, paste0("indices_", file_prefix, ".tsv")), quote = FALSE, sep = "\t", row.names = FALSE, col.names = FALSE)
}

# Example usage with your Seurat object
# Define input variables
A96_cell_key1 <- c("A1", "A2", "A3", "...") # Replace with your actual key
A96_cell_key2 <- c("B1", "B2", "B3", "...") # Replace with your actual key
A96_cell_key3 <- c("C1", "C2", "C3", "...") # Replace with your actual key
v1_linker1 <- "_L1_" # Replace with your actual linker
v1_linker2 <- "_L2_" # Replace with your actual linker
output_directory <- "../data" # Replace with your desired output directory
file_prefix <- "wtA3" # Replace with your desired file prefix

# Run the function for the 3rd object in your Seurat list
process_seurat_object(
  seurat_obj = obj_list[[3]],
  cell_key1 = A96_cell_key1,
  cell_key2 = A96_cell_key2,
  cell_key3 = A96_cell_key3,
  linker1 = v1_linker1,
  linker2 = v1_linker2,
  output_dir = output_directory,
  file_prefix = file_prefix
)

````

Therefore, to an example of execution of the code:

````{sh}
chmod +x scsplit_pipeline.sh #Make sure the script can be executed
./scsplit_pipeline.sh --barcodes /path/to/barcodes.tsv --bam /path/to/bam.bam --outdir /path/to/output --n 12 --vcf /path/to/vcf --fasta /path/to/fasta

````

With the output you will be able to identify to which samples your cells are related to and modify it manually in the metadata of the seurat object. This will enable more cells for the TRUST4 step.
## Running TRUST4 for BD rhapsody

**Example Call**

````{sh}
./run-trust4 -f hg38_bcrtcr.fa --ref human_IMGT+C.fa -1 home/joel/data2/00_fastq/a1/fastq3/*_R1_*.fastq.gz -2 home/joel/data2/00_fastq/a1/fastq3/*_R2_*.fastq.gz  --barcode home/joel/data2/00_fastq/a1/fastq3/*_R1_*.fastq.gz  --readFormat bc:0:52,r1:60:-1 --od home/joel/data/outs/trust4/a1 -o a1
````

It require only to understand the read format. After many tries, in this project the only way to identify propperly the barcode is to go directly to the fastQ files retrieved by BD and checkk for positions in readFormat:
bc:0:52,r1:60:-1

## TRANSLATION TRUST4 FOR USAGE IN SINGLE-CELL

To run this section it is only needed to extract the barcodes from the first column of TRUST4 outputs, as well as adding the keys for BD rhapsody linkers and CLS (as keky1,2 and 3). For more information, pleasew refer to the thesis document.
Example run:

```
./barcode_translate.py --input_file input.txt --output_file output.csv \
--linker1 expected_linker1 --linker2 expected_linker2 \
--key1 ref_key1.txt --key2 ref_key2.txt --key3 ref_key3.txt
```
