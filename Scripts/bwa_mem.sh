#!/bin/bash

### Pipeline for sickle bwa alignment to t2t (v2)

#------------------
echo "Starting the BWA alignment..."

# Process each pair of trimmed fastq files
for fwd_align in *1_val_1.fq; do
    # Get the reverse file names by replacing _1_val_1.fq with _2_val_2.fq
    rev_align="${fwd_align/1_val_1.fq/2_val_2.fq}"
    echo "Checking files: $fwd_align and $rev_align"

    
    if [[ -e "$rev_align" ]]; then
        # Extract the base name for output files
        base_name_align="${fwd_align%%_val_1.fq}"
        
        # Construct output file paths
        bam_file="${align_op_dir}/${base_name_align}_sorted.bam"
        # sam_file="${align_op_dir}/${base_name_align}_aligned.sam"  # Unused
          
        echo "Output BAM File: $bam_file"
        # echo "Output SAM File: $sam_file"  
        
        # Run BWA, convert to BAM, filter, and sort directly (CHeck if parallel processing is possible)
        bwa mem -k 50 -c 1000000 -t 50 "$t2t_index" "$fwd_align" "$rev_align" | \
        samtools view -b -F 2308 -q 20 | \
        samtools sort -m 2G -T "${tmp_dir}/${base_name_align}" -o "$bam_file"
        
        # Check if the  pipeline succeeded
        if [ $? -eq 0 ]; then
            samtools index "$bam_file"
            echo "Processed and indexed: $bam_file"
        else
            echo "Error processing $bam_file"
            continue
        fi
    else
        echo "Warning: Reverse file for $fwd_align not found. Skipping."
    fi
done

echo "Alignment to T2T-CHM13v2.0 complete"