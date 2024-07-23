#!/bin/bash

### Pipeline for peak Calling using MACS2


#------------------

echo "Starting macs2 peak calling.."
echo "CSV Path: $csv_path"
echo "Alignment Directory: $align_op_dir"
echo "Peakcalls Directory: $peakcalls_dir"


# genome size (-g) and q-value threshold (-q)
#for t2t according to Life Science alliance paper
genome_size="3.03e9"
q_value="0.00001"


# Read CSV and populate the associative array, skipping the header
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
        echo "Skipping control or sample without defined input for peakcalling: $sample"
        continue
    fi

    chip_bam="${bam_files["$sample"]}"
    ip_bam="${bam_files["$control"]}"

    # Check if files exist before proceeding
    if [[ -f "$chip_bam" && -f "$ip_bam" ]]; then
        output_file="${sample}_${cell_line}.bed"

    echo "macs2 callpeak -t "$chip_bam" -c "$ip_bam" -g "$genome_size" -q "$q_value" --outdir "$peakcalls_dir" --name "$output_file""
    macs2 callpeak -t "$chip_bam" -c "$ip_bam" -g "$genome_size" -q "$q_value" --outdir "$peakcalls_dir" --name "$output_file"

    else
        echo "Missing BAM files for sample $sample:"
        echo "  ChIP BAM: $chip_bam"
        echo "  Input BAM: $ip_bam"
    fi
done < <(tail -n +2 "$csv_path")

echo "Macs2 peak calling for $cell_line wrt Input is complete. Please visualise the rest on IGV"   

