# Centeromeric_chipseq_analysis
### Analysis pipeline for mapping ChIP-Seq to the new T2T assembly

The following are the instructions for running the ChIP-seq analysis pipeline for centromeric protein peak calling

----------------------------------------------------------------------------------------------------------------
## 1. Directory set up
Have 3 folders

a) Files 
- having all the raw fastq files in a folder called fastq in the Files directory
- genome files for alignment in folder called t2t - Downloaded from https://genome.ucsc.edu/cgi-bin/hgGateway File - GCA_009914755.4.chrNames.fa.gz fasta sequence with chrN sequence names
- genome file should be indexed using
> bam index GCA_009914755.4.chrNames.fa.gz

b) Results 
- will store all the results. The directory set up for this is already present in the code

c) Scripts
- containing all the scripts. Copy this README and all the scripts in this folder for easy access and troubleshooting
- add the sample/input file for calling ChIP input pairs - more in point 2

----------------------------------------------------------------------------------------------------------------
## 2. CSV sample file containing the chip and input fastqfile and its details in the format
* Store this in Scripts

your input file should look like this (example) and should be named Inputfile.csv (or change it according to point 4)

sample,fastq_1,fastq_2,antibody,control,cell_line
CENPA_async,SRR6936860_1.fastq.gz,SRR6936860_2.fastq.gz,CENP-A,CENPA_async_IP,HeLa
CENPA_G1,SRR6936864_1.fastq.gz,SRR6936864_2.fastq.gz,CENP-A,CENPA_G1_IP,HeLa
CENPA_async_IP,SRR6800098_1.fastq.gz,SRR6800098_2.fastq.gz,,,HeLa
CENPA_G1_IP,SRR7703390_1.fastq.gz,SRR7703390_2.fastq.gz,,,HeLa

Make sure it has a header as mentioned. Also, give sample names according to the experiment conducted

----------------------------------------------------------------------------------------------------------------
## 3. Creating environments to run the pipeline
This action needs to be performed only *once* in a system.

- Two environments called centromere and macs2 (the names can be replaced) will be created 
     
1. Manual Method
you can create these environments using
##### Creating and setting up the 'centromere' environment
> conda create -n centromere python=3.12.3 -y
##### Activating the environment
> conda activate centromere
##### Installing required packages
> conda install bioconda::fastqc sickle-trim bwa bioconda::samtools bioconda::bedops bioconda::bioconda::bedtools -y
#
> pip install cutadapt deeptools

and
##### Creating and setting up the 'macs2' environment with a different python version
> conda create -n macs2 python=2.7 -y
##### Activating the environment
> conda activate macs2

###### Install packages for 'macs2'
> conda install bioconda::macs2 -y 

     
OR 
     
2. Automate it by
       
Making environment.sh in the scripts folder executable
    chmod +x ~/path/to/folder/Scripts/environment.sh
       
Run the script environment.sh present in the scripts folder
    ~/path/to/folder/Scripts/environment.sh

----------------------------------------------------------------------------------------------------------------
## 4. To run the pipeline

A) Open the script file and change the 1st part of the script which mentions directories ie

******
#### TO BE CHANGED

###### your directory for keeping all files, results and scripts - change according to your home directory structure
- files=" ~/path/to/folder/Files/fastq"
- home_dir=" ~/path/to/folder/Results" 
- scripts=" ~/path/to/folder/Scripts"
- t2t_index=" ~/path/to/folder/Files/t2t_files/UCSC/indexfiles/GCA_009914755.4.chrNames.fa" #make sure your fa file is indexed

###### Path to CSV file containing your ChIP and Input information
csv_path="${scripts}/Inputfile.csv" #Should have a header

******

B) The below information is to perform the Mapping and peak calling of CENP-A bound regions

Run the script containing the pipeline after making it an executable

chmod +x ~/path/to/folder/Scripts/CENPA_chip.sh

~/path/to/folder/Scripts/CENPA_chip.sh

#### NOTE: Change the directories as required in the home file. Make sure You create a directory structure as mentioned in point 1 as the script will take care of the rest of the Directories in the results

----------------------------------------------------------------------------------------------------------------
       
         







