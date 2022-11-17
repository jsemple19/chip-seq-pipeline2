#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=pall
#SBATCH --mem-per-cpu=1G
#SBATCH --array=1#%2


######## Do not run more than 2 array jobs at once as each job
######## spawns a whole bunch of other jobs....!!

export TMPDIR=$SCRATCH
echo $TMPDIR
srrFile="./SRR_SMCmodEncode_ChIPseq.csv"

WORK_DIR=$PWD
if [ ! -d "${WORK_DIR}/results" ]; then
 mkdir -p ${WORK_DIR}/results
fi

source $CONDA_ACTIVATE encodeChipSeq

groupNames=( `grep -v -e '^[[:space:]]*$' ${srrFile} |  cut -d";" -f4  | grep -v group | sort -u` )
groupNames=( `cut -d";" -f4 ${srrFile} | grep -v group | sort -u` )
grp=${groupNames[$SLURM_ARRAY_TASK_ID-1]}
jsonFile=${WORK_DIR}/jsonFiles_TF/${grp}.json
echo "jsonFile is: " $jsonFile
caper hpc submit chip.wdl -i "${jsonFile}" --singularity  --local-out-dir results/${grp} --str-label ${grp} --leader-job-name chipseq  --slurm-partition pall --slurm-account $USER


# reorganise the data in a more human friendly format (adds peaks, signal, align and qc folders)
#cd ${WORK_DIR}/results/${grp}/chip/*/
#croo metadata.json

# once all jobs have finished can create overall summary with this command
#qc2tsv ./results/*/chip/*/qc/qc.json  > spreadsheet.tsv

