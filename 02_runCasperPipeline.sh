#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=pall
#SBATCH --mem-per-cpu=1G


######## Do not run more than 2 array jobs at once as each job
######## spawns a whole bunch of other jobs....!!

export TMPDIR=$SCRATCH
echo $TMPDIR
srrFile="./SRR_modEncode_chromatinChipSeq_modHistone.csv"
WORK_DIR=$PWD
if [ ! -d "${WORK_DIR}/results" ]; then
 mkdir -p ${WORK_DIR}/results
fi
JSON_DIR=${WORK_DIR}/jsonFiles
#FASTQ_DIR=${WORK_DIR}/results/SRR_download
#genomeTsvPath="/data/projects/p025/jenny/genome/ce11/ce11.tsv"

#module load R;
#Rscript ./makeJSON.R $WORK_DIR $JSON_DIR $FASTQ_DIR $srrFile $genomeTsvPath

source $CONDA_ACTIVATE encodeChipSeq

groupNames=( `grep -v -e '^[[:space:]]*$' ${srrFile} |  cut -d";" -f4  | grep -v group | sort -u` )
#groupNames=( `cut -d";" -f4 ${srrFile} | grep -v group | sort -u` )
for grp in "${groupNames[@]}" #"${groupNames[@]:1}" to do all except for first group
do
 #grp=${groupNames[$SLURM_ARRAY_TASK_ID-1]}
 jsonFile=${JSON_DIR}/${grp}.json
 echo "jsonFile is: " $jsonFile
 caper hpc submit chip.wdl -i "${jsonFile}" --singularity  --local-out-dir results/${grp} --str-label ${grp} --leader-job-name $jsonFile  --slurm-partition pall --slurm-account $USER --max-concurrent-tasks 4 --max-concurrent-workflows 4
done

