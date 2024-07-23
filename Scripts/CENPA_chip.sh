#!/bin/bash
#set -x 

echo "Starting the pipeline..."

# Pipeline for Mapping of CENP-A–bound reads

#--------------------------------------------------------------------------------------------------------------
# TO BE CHANGED

#your directory for keeping all files, results and scripts - change according to your home directory structure
files="~/path/to/folder/Files/fastq"
home_dir="~/path/to/folder/Results/" 
scripts="~/path/to/folder/Scripts/"
t2t_index="~/path/to/folder/Files/t2t_files/UCSC/indexfiles/GCA_009914755.4.chrNames.fa" #make sure your fa file is indexed

# Path to CSV file containg your ChIP and Input information
csv_path="${scripts}/Inputfile.csv" #Should have a header


#--------------------------------------------------------------------------------------------------------------

# Directory setup
declare -A dirs=(
    [fastqc]="${home_dir}/fastqc"
    [sickle_dir_up]="${home_dir}/sickle_trimmed/unpaired"
    [sickle_dir_p]="${home_dir}/sickle_trimmed/paired"
    [cutadapt_op_dir]="${home_dir}/cutadapt_trimmed"
    [fastqc_post_adapter_trim]="${home_dir}/cutadapt_trimmed/fastqc"
    [align_op_dir]="${home_dir}/bwa_aligned"
    [tmp_dir]="${home_dir}/bwa_aligned/tmp"
    [normalisation_dir]="${home_dir}/bam_compare_wIP"
    [peakcalls_dir]="${home_dir}/peakcalls"
)

# Make the directories if not already present
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
done

#--------------------------------------------------------------------------------------------------------------

# THE PIPELINE



#------------------------------------------------
# 1. Run Fastqc on all files in the files folder
# Change to the directory containing the fastq files
cd "${files}" || { echo "Error: Could not change directory to $files"; exit 1; }

echo "Running fastqc on all files in the folder '${files}'"
conda run -n centromere --no-capture-output bash -c "fastqc -o '${dirs[fastqc]}' *.fastq.gz" || { echo "Error: FASTQC script failed"; exit 1; }

#------------------------------------------------
# 2. Run Sickle - for trimming
## first we make the script executable
echo "Running sickle trimming on all files in the folder '${files}'"
chmod +x "${scripts}/sickle_trim.sh"

#Run the sickle trim command
conda run -n centromere --no-capture-output bash -c "csv_path='${csv_path}' sickle_dir_up='${dirs[sickle_dir_up]}' sickle_dir_p='${dirs[sickle_dir_p]}' source '${scripts}/sickle_trim.sh'" || { echo "Error: Sickle trimming script failed"; exit 1; }


#------------------------------------------------
# 3. Trim adapters using cutadapt

# Change to the directory containing the trimmed files
echo "Running cutadapt to trim adapters"

cd "${dirs[sickle_dir_up]}" || { echo "Error: Could not change directory to ${dirs[sickle_dir_up]} for adapter trimming."; exit 1; }

## Run the adapter trimming script
chmod +x "${scripts}/adapter_trimming.sh"
conda run -n centromere --no-capture-output bash -c "export cutadapt_op_dir='${dirs[cutadapt_op_dir]}'; source '${scripts}/adapter_trimming.sh'" || { echo "Error: Adapter trimming script failed"; exit 1; }


#------------------------------------------------
# 4. FastQC post adapter trimming
echo "Performing Fastqc post adapter trimming"
cd "${dirs[cutadapt_op_dir]}" || { echo "Error: Could not change directory to ${dirs[cutadapt_op_dir]} for fastqc and alignment post adapter trimming."; exit 1; }

conda run -n centromere --no-capture-output bash -c "fastqc -o "${dirs[fastqc_post_adapter_trim]}" *.fq" || { echo "Error: FASTQC script post adapter trimming failed"; exit 1; }


#------------------------------------------------
# 5. Aligning the reads to T2T-CHM13v2.0 - From UCSC - check if t -50 parellel processing is available in your environment
echo "Running BWA Mem with index $t2t_index"
chmod +x "${scripts}/bwa_mem.sh"

conda run -n centromere --no-capture-output bash -c "export t2t_index='${t2t_index}'; export align_op_dir='${dirs[align_op_dir]}'; export tmp_dir='${dirs[tmp_dir]}'; source '${scripts}/bwa_mem.sh'" || { echo "Error: BWA Alignment script failed"; exit 1; }


#------------------------------------------------
# 6. Alignments were normalized with deepTools - with ip controls - bamCompare

cd "${dirs[align_op_dir]}" || { echo "Error: Could not change directory to ${dirs[align_op_dir]} for bamCompare and peak calling with input files."; exit 1; }
chmod +x "${scripts}/bamcompare.sh"
echo "Normalising with deeptools"

conda run -n centromere --no-capture-output bash -c "export normalisation_dir='${dirs[normalisation_dir]}'; export align_op_dir='${dirs[align_op_dir]}'; export csv_path='$csv_path'; source '${scripts}/bamcompare.sh'" || { echo "Error: bamCompare script failed"; exit 1; }

#------------------------------------------------
# 7. MACS2 peakcalling
# Activate the environment containg the required pacakges for CenPA ChIP  peak calling using MAC2
#MACS2 requesries python 2.7. Therefore is loaded into a different environment
echo "Running Macs2 peakcalling"
chmod +x "${scripts}/peakcalling.sh"
conda run -n macs2 --no-capture-output bash -c "export peakcalls_dir='${dirs[peakcalls_dir]}'; export align_op_dir='${dirs[align_op_dir]}'; export csv_path='$csv_path'; source '${scripts}/peakcalling.sh'" || { echo "Error: MACS2 peak calling script failed"; exit 1; }


# 8. Go back to the previous enviroment which contains bedtools and deeptools
echo "CENPA ChIP-seq Pipeline is now complete. PLease use IGV genome browser, BedTools and deeptools for futher visualisation and analysis."


#--------------------------------------------------------------------------------------------------------------





