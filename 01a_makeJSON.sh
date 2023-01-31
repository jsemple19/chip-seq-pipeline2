#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="encode_chipseq"
#SBATCH --partition=pall
#SBATCH --time=0-01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --output=slurm-%x-%A-%a.out
#SBATCH --error=slurm-%x-%A-%a.out


WORK_DIR=$PWD
srrFile=${WORK_DIR}/SRR_modEncode_chromatinChipSeq_modHistone.csv


# make json files for next step
echo "Making json files for pipeline..."
JSON_DIR=${WORK_DIR}/jsonFiles
FASTQ_DIR=${WORK_DIR}/SRR_download
genomeTsvPath="/data/projects/p025/jenny/genome/ce11/ce11.tsv"
module load R;
Rscript ./makeJSON.R $WORK_DIR $JSON_DIR $FASTQ_DIR $srrFile $genomeTsvPath
