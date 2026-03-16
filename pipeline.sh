#!/bin/bash
# WGS Variant Calling Pipeline
# Sample: NA12878 (SRR1518158)
# Author: Your Name

set -e  # Stop if any command fails

echo "Starting NGS pipeline..."

# ============================================================
# STEP 1 - Quality Control
# ============================================================
echo "Running FastQC..."
mkdir -p qc_results
fastqc raw_data/SRR1518158_1.fastq.gz raw_data/SRR1518158_2.fastq.gz \
  -o qc_results/

# ============================================================
# STEP 2 - Trimming
# ============================================================
echo "Trimming reads..."
mkdir -p trimmed_reads
trimmomatic PE \
  raw_data/SRR1518158_1.fastq.gz raw_data/SRR1518158_2.fastq.gz \
  trimmed_reads/trimmed_R1.fastq.gz trimmed_reads/unpaired_R1.fastq.gz \
  trimmed_reads/trimmed_R2.fastq.gz trimmed_reads/unpaired_R2.fastq.gz \
  ILLUMINACLIP:$CONDA_PREFIX/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
  LEADING:3 TRAILING:3 MINLEN:36

# ============================================================
# STEP 3 - Alignment
# ============================================================
echo "Aligning reads to reference..."
mkdir -p alignment
bwa mem \
  reference/hg19.fa \
  trimmed_reads/trimmed_R1.fastq.gz \
  trimmed_reads/trimmed_R2.fastq.gz \
  -R "@RG\tID:SRR1518158\tSM:NA12878\tPL:ILLUMINA\tLB:lib1" \
  > alignment/aligned.sam

# ============================================================
# STEP 4 - BAM Processing
# ============================================================
echo "Processing BAM file..."
samtools view -bS alignment/aligned.sam | \
  samtools sort -o alignment/aligned_sorted.bam
samtools index alignment/aligned_sorted.bam

# Mark duplicates
gatk MarkDuplicates \
  -I alignment/aligned_sorted.bam \
  -O alignment/deduped.bam \
  -M alignment/duplicate_metrics.txt

samtools index alignment/deduped.bam

# Remove intermediate SAM
rm alignment/aligned.sam

# ============================================================
# STEP 5 - Variant Calling
# ============================================================
echo "Calling variants..."
mkdir -p variants
gatk HaplotypeCaller \
  -R reference/hg19.fa \
  -I alignment/deduped.bam \
  -O variants/raw_variants.vcf \
  --sample-name NA12878

# ============================================================
# STEP 6 - Variant Filtering
# ============================================================
echo "Filtering variants..."
gatk VariantFiltration \
  -R reference/hg19.fa \
  -V variants/raw_variants.vcf \
  -O variants/filtered_variants.vcf \
  --filter-expression "QD < 2.0" --filter-name "QD2" \
  --filter-expression "DP < 10" --filter-name "LowDepth" \
  --filter-expression "GQ < 20" --filter-name "LowGQ" \
  --filter-expression "MQ < 40.0" --filter-name "MQ40"

# Extract PASS variants
grep "^#" variants/filtered_variants.vcf > variants/pass_only.vcf
grep -v "^#" variants/filtered_variants.vcf | awk '$7=="PASS"' >> variants/pass_only.vcf

echo "Pipeline complete!"
echo "Total variants called: $(grep -v '^#' variants/raw_variants.vcf | wc -l)"
echo "High quality variants: $(grep -v '^#' variants/pass_only.vcf | wc -l)"
