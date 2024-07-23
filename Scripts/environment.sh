#!/bin/bash

# Initialize Conda
source /path/to/conda.sh  # Adjust this path to where your conda.sh is located (it is often in ~/miniconda3/etc/profile.d/conda.sh or similar)

# Creating and setting up the 'centromere' environment
conda create -n centromere python=3.12.3 -y || { echo "Failed to create environment 'centromere'"; exit 1; }
conda activate centromere

# Install packages
conda install bioconda::fastqc sickle-trim bwa bioconda::samtools bioconda::bedops bioconda::bioconda::bedtools -y || { echo "Failed to install packages in 'centromere'"; exit 1; }
pip install cutadapt deeptools || { echo "Failed to install Python packages with pip"; exit 1; }

# Creating and setting up the 'macs2' environment with Python 2.7
conda create -n macs2 python=2.7 -y || { echo "Failed to create environment 'macs2'"; exit 1; }
conda activate macs2

# Install packages for 'macs2'
conda install bioconda::macs2 -y || { echo "Failed to install packages in 'macs2'"; exit 1; }



# Verions used
#### 1. Python - v3.12.3 if not otherwise mentioned
#### 2. FastQC: v0.12.1
#### 3. sickle: v1.33
#### 4. samtools: v1.20 (using htslib 1.20)
#### 5. bedops: v2.4.41 (typical)
#### 6. bedtools: v2.31.1
#### 7. cutadapt: v4.9
#### 8. deeptools: v3.5.5

#### 9. macs2: v2.1.0.20150731


