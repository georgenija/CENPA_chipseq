#!/bin/bash

### Pipeline for adapter trimming

#------------------
echo "Starting  adapter trimming"


# Loop through all *_1.fastq files for forward strand (paired end)
for fwd_a in *_1.fastq
do
    # Get the reverse file names by replacing _1_ with _2_
    rev_a="${fwd_a/_1/_2}"
    
    # Check if the reverse file exists
    if [[ -e "$rev_a" ]]; then
        # Extract the base name for output files by removing the file extension
        base_name_adap="${fwd_a%%_1*}"
        
        # Construct output file names
        adap_fwd="${cutadapt_op_dir}/${base_name_adap}_1"
        adap_rev="${cutadapt_op_dir}/${base_name_adap}_2"
        
        # Print variables for checking
        echo "Adapter forward output: $adap_fwd"
        echo "Adapter reverse output: $adap_rev"
        
        #echo "trim_galore --paired "$fwd_a" "$rev_a" -o "$cutadapt_op_dir/""
         
        # Run the sickle command
        trim_galore --paired "$fwd_a" "$rev_a" -o "$cutadapt_op_dir"
     
     else       
        echo "Warning: Reverse file for $fwd_a not found. Skipping."
    fi
done

echo "Adaptor trimming completed."