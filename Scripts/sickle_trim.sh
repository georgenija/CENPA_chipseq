#!/bin/bash

### Pipeline for sickle trimming

#------------------
echo "Starting the sickle trimming..."

# Read sample sheet skipping the header
tail -n +2 "$csv_path" | while IFS=, read -r sample fastq_1 fastq_2 antibody control cell_line
do
    # Check if both files exist
    if [[ -e "$fastq_1" && -e "$fastq_2" ]]; then
        # Extract the base name for output files by removing the file extension from the first FASTQ
        base_name="${fastq_1%%_1.*}"
        echo "$fastq_1 $fastq_2"

        # Construct output file names
        trimmed_fwd="${sickle_dir_up}/${base_name}_1.fastq"
        trimmed_rev="${sickle_dir_up}/${base_name}_2.fastq"
        trimmed_singles="${sickle_dir_p}/${base_name}_singles.fastq"

        # Print variables for checking
        echo "Trimming: $sample"
        echo "Trimmed forward output: $trimmed_fwd"
        echo "Trimmed reverse output: $trimmed_rev"
        echo "Trimmed singles output: $trimmed_singles"

        # Run the sickle command
        sickle pe -f "$fastq_1" -r "$fastq_2" -t sanger -o "$trimmed_fwd" -p "$trimmed_rev" -s "$trimmed_singles"
    else
        echo "Warning: One or both FASTQ files for $sample not found. Skipping."
    fi
done

echo "Sickle trimming completed."

