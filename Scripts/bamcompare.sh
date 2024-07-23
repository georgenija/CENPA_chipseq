#!/bin/bash

### Pipeline for Normalization - Bamcompare

echo "Starting bamCompare..."
echo "CSV Path: $csv_path"
echo "Alignment Directory: $align_op_dir"
echo "Normalization Directory: $normalisation_dir"

declare -A bam_files
while IFS=, read -r sample fastq_1 fastq_2 antibody control cell_line
do
    # Extract the basename for the BAM file from the FastQ file
    fastq_base_1="${fastq_1%_1.fastq.gz}"
    bam_files["$sample"]="${align_op_dir}/${fastq_base_1}_1_sorted.bam"
done < <(tail -n +2 "$csv_path")

# Now loop through again to process bamCompare
while IFS=, read -r sample fastq_1 fastq_2 antibody control cell_line
do
    if [[ -z "$control" || "$control" == "$sample" || ! ${bam_files["$control"]} ]]; then
        echo "Skipping control or sample without defined input for bamCompare: $sample"
        continue
    fi

    chip_bam="${bam_files["$sample"]}"
    ip_bam="${bam_files["$control"]}"

    # Check if files exist before proceeding
    if [[ -f "$chip_bam" && -f "$ip_bam" ]]; then
        output_file="${sample}_${cell_line}.bw"
        
        echo "bamCompare -b1 "$chip_bam" -b2 "$ip_bam" --operation ratio --binSize 50 -o "$normalisation_dir/$output_file""
        bamCompare -b1 "$chip_bam" -b2 "$ip_bam" --operation ratio --binSize 50 -o "$normalisation_dir/$output_file"
        echo "Normalized file created: $normalisation_dir/$output_file"
    else
        echo "Missing BAM files for sample $sample:"
        echo "  ChIP BAM: $chip_bam"
        echo "  Input BAM: $ip_bam"
    fi
done < <(tail -n +2 "$csv_path")

echo "Bigwig file created wrt input. bamCompare process completed"
