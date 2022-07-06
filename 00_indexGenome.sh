#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=1-12:00:00
#SBATCH --cpus-per-task=2
#SBATCH --partition=pall
#SBATCH --mem-per-cpu=8G

#source $CONDA_ACTIVATE encodeChipSeq
source $CONDA_ACTIVATE encd-chip

GENOME_DIR=/data/projects/p025/jenny/genome/ce11

if [ ! -e "${GENOME_DIR}/ce11-blacklist.v2.bed" ]; then
   wget  https://github.com/Boyle-Lab/Blacklist/raw/master/lists/ce11-blacklist.v2.bed.gz
   gunzip ce11-blacklist.v2.bed.gz
   cut -f1-3 ce11-blacklist.v2.bed > $GENOME_DIR/ce11-blacklist.v2.bed
   rm ce11-blacklist.v2.bed
fi

bash ./scripts/build_genome_data.sh ce11 $GENOME_DIR

