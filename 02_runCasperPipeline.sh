#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=pall
#SBATCH --mem-per-cpu=8G
#SBATCH --array=2


######## Do not run more than 2 array jobs at once as each job
######## spawns a whole bunch of other jobs....!!

srrFile="./SRR_SMCmodEncode_ChIPseq.csv"

source $CONDA_ACTIVATE encodeChipSeq

groupNames=( `cut -d";" -f4 ${srrFile} | grep -v group | sort -u` )
grp=${groupNames[$SLURM_ARRAY_TASK_ID]}
jsonFile=./jsonFiles/${grp}.json
echo "jsonFile is: " $jsonFile
caper run chip.wdl -i ${jsonFile} --singularity --slurm-partition pall --slurm-account pmeister --local-out-dir ${grp} --str-label ${grp}

# reorganise the data in a more human friendly format (adds peaks, signal, align and qc folders)
cd ./${grp}/chip/*/
croo metadata.json

# once all jobs have finished can create overall summary with this command
#qc2tsv ./qc/qc.json > spreadsheet.tsv

