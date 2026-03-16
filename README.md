# ngs-variant-calling-pipeline
cat > ~/ngs_project/README.md << 'EOF'
# WGS Variant Calling Pipeline — NA12878 Exome Analysis

A reproducible end-to-end NGS pipeline for variant calling and clinical interpretation, built using industry-standard bioinformatics tools.

## Overview

This pipeline processes raw Illumina paired-end whole exome sequencing data from the NA12878 reference sample (SRR1518158) through quality control, alignment, variant calling, filtering, and biological annotation.

## Sample Information

- **Sample:** NA12878 (Coriell GM12878)
- **Accession:** SRR1518158 (ENA)
- **Organism:** Homo sapiens
- **Strategy:** Whole Exome Sequencing (WXS)
- **Instrument:** Illumina HiSeq 2000
- **Reference Genome:** hg19/GRCh37

## Pipeline Steps

1. Quality Control — FastQC
2. Adapter Trimming — Trimmomatic
3. Alignment — BWA-MEM
4. BAM Processing — Samtools
5. Duplicate Marking — GATK MarkDuplicates
6. Variant Calling — GATK HaplotypeCaller
7. Variant Filtering — GATK VariantFiltration
8. Variant Annotation — Ensembl VEP

## Key Results

| Step | Metric | Value |
|------|--------|-------|
| Raw reads | Total | 2,318,426 |
| Trimming | Reads surviving | 92% |
| Alignment | Mapping rate | 99.96% |
| Duplicates | Duplication rate | 2.17% |
| Variant calling | Raw variants | 33,946 |
| Filtering | High quality variants | 5,317 |
| Annotation | Genes overlapped | 3,897 |
| Annotation | High priority variants | 124 |

## Biological Findings

- 124 high priority variants (stop gained + frameshift) identified
- 13 variants in BRCA2 exon 11 — associated with hereditary breast and ovarian cancer syndrome (ClinVar)
- Missense variants in NOS1AP (PolyPhen 0.998) — associated with cardiac arrhythmia
- Missense variants in F5 — associated with Factor V Leiden thrombophilia

**Note:** This analysis used low coverage data (~3-4x). Several high priority calls including the BRCA2 frameshift are likely false positives due to insufficient depth. Clinical reporting requires minimum 30x coverage and Base Quality Score Recalibration (BQSR).

## Requirements

Reproduce the exact environment using:
```bash
conda env create -f environment.yml
conda activate ngs_pipeline
```

## Usage
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/ngs-variant-calling-pipeline.git
cd ngs-variant-calling-pipeline

# Set up environment
conda env create -f environment.yml
conda activate ngs_pipeline

# Download reference genome and data (see Data section below)
# Then run the full pipeline
bash pipeline.sh
```

## Data

Raw sequencing data is not included in this repository due to file size.
Download using SRA Toolkit or ENA:
```bash
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR151/008/SRR1518158/SRR1518158_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR151/008/SRR1518158/SRR1518158_2.fastq.gz
```

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| FastQC | 0.12.1 | Quality control |
| Trimmomatic | 0.40 | Adapter trimming |
| BWA | latest | Read alignment |
| Samtools | 1.23 | BAM processing |
| GATK | 4.6.2.0 | Variant calling and filtering |
| Ensembl VEP | web | Variant annotation |

## Author

Your Name — Biotechnology Undergraduate
EOF
