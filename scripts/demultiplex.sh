#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Help message
function usage() {
    echo "Usage: $0 --barcodes <path> --bam <path> --outdir <path> --n <int> --vcf <path> --fasta <path> [--cell_tag <tag>]"
    echo "  --barcodes  Path to barcodes.tsv file"
    echo "  --bam       Path to BAM file"
    echo "  --outdir    Output directory for scSplit results"
    echo "  --n         Number of clusters for scSplit"
    echo "  --vcf       Path to VCF file"
    echo "  --fasta     Path to FASTA file for FreeBayes"
    echo "  --cell_tag  (Optional) Cell tag"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --barcodes) BARCODES="$2"; shift ;;
        --bam) BAM="$2"; shift ;;
        --outdir) OUTDIR="$2"; shift ;;
        --n) N="$2"; shift ;;
        --vcf) VCF="$2"; shift ;;
        --fasta) FASTA="$2"; shift ;;
        --cell_tag) CELL_TAG="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check mandatory arguments
if [[ -z "$BARCODES" || -z "$BAM" || -z "$OUTDIR" || -z "$N" || -z "$VCF" || -z "$FASTA" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

# Ensure output directory exists
mkdir -p "$OUTDIR"

# Define output files
FILTERED_BAM="$OUTDIR/filtered_bam.bam"
FILTERED_BAM_DEDUP="$OUTDIR/filtered_bam_dedup.bam"
FILTERED_BAM_DEDUP_SORTED="$OUTDIR/filtered_bam_dedup_sorted.bam"
FREEBAYES_VCF="$OUTDIR/freebayes_var.vcf"
FREEBAYES_QUAL30="$OUTDIR/freebayes_var_qual30.recode.vcf"
REF_FILTERED="$OUTDIR/ref_filtered.csv"
ALT_FILTERED="$OUTDIR/alt_filtered.csv"
RESULT_CSV="$OUTDIR/scSplit_result.csv"
SUMMARY_TSV="$OUTDIR/scSplit_summary.tsv"

# Step 1: Filter BAM file
singularity exec Demuxafy.sif samtools view -b -S -q 10 -F 3844 "$BAM" > "$FILTERED_BAM"

# Step 2: Remove duplicates
singularity exec Demuxafy.sif samtools rmdup "$FILTERED_BAM" "$FILTERED_BAM_DEDUP"

# Step 3: Sort BAM file
singularity exec Demuxafy.sif samtools sort -o "$FILTERED_BAM_DEDUP_SORTED" "$FILTERED_BAM_DEDUP"

# Step 4: Index BAM file
singularity exec Demuxafy.sif samtools index "$FILTERED_BAM_DEDUP_SORTED"

# Step 5: Run FreeBayes
singularity exec Demuxafy.sif freebayes -f "$FASTA" -iXu -C 2 -q 1 "$FILTERED_BAM_DEDUP_SORTED" > "$FREEBAYES_VCF"

# Step 6: Filter VCF with VCFtools
singularity exec Demuxafy.sif vcftools --gzvcf "$FREEBAYES_VCF" --minQ 30 --recode --recode-INFO-all --out "$OUTDIR/freebayes_var_qual30"

# Step 7: scSplit count
SCSPLIT_COUNT_CMD="singularity exec Demuxafy.sif scSplit count -c $VCF -v $FREEBAYES_QUAL30 -i $FILTERED_BAM_DEDUP_SORTED -b $BARCODES"
if [[ -n "$CELL_TAG" ]]; then
    SCSPLIT_COUNT_CMD+=" -t $CELL_TAG"
fi
SCSPLIT_COUNT_CMD+=" -r $REF_FILTERED -a $ALT_FILTERED -o $OUTDIR"
eval "$SCSPLIT_COUNT_CMD"

# Step 8: scSplit run
singularity exec Demuxafy.sif scSplit run -r "$REF_FILTERED" -a "$ALT_FILTERED" -n "$N" -o "$OUTDIR"

# Step 9: scSplit genotype
singularity exec Demuxafy.sif scSplit genotype -r "$REF_FILTERED" -a "$ALT_FILTERED" -p "$OUTDIR/scSplit_P_s_c.csv" -o "$OUTDIR"

# Step 10: scSplit summary
singularity exec Demuxafy.sif bash scSplit_summary.sh "$RESULT_CSV" > "$SUMMARY_TSV"

echo "Pipeline completed successfully. Results are in $OUTDIR."
