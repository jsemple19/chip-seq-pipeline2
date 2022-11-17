#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --job-name="ChIP_seq_modENCODE"
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=pall
#SBATCH --mem-per-cpu=4G


######## Do not run more than 2 array jobs at once as each job
######## spawns a whole bunch of other jobs....!!


export TMPDIR=$SCRATCH
echo $TMPDIR
srrFile="./SRR_SMCmodEncode_ChIPseq.csv"
WORK_DIR=${PWD}
JSON_DIR=${WORK_DIR}/jsonFiles

source $CONDA_ACTIVATE encodeChipSeq
module load R;

groupNames=( `grep -v -e '^[[:space:]]*$' ${srrFile} |  cut -d";" -f4  | grep -v group | sort -u` )
#grp=${groupNames[$SLURM_ARRAY_TASK_ID-1]}
#jsonFile=${WORK_DIR}/jsonFiles_Ahringer/${grp}.json
#echo "jsonFile is: " $jsonFile


Rscript collectResults.R $srrFile $WORK_DIR $JSON_DIR

# reorganise the data in a more human friendly format (adds peaks, signal, align and qc folders)
#cd ${WORK_DIR}/qc/${grp}/
for grp in ${groupNames[@]}
do 
  latestRun=`ls -t ${WORK_DIR}/results/${grp}/chip/ | head -1`
  echo ${WORK_DIR}/results/${grp}/chip/${latestRun}
  croo --out-dir ${WORK_DIR}/qc/${grp}    ${WORK_DIR}/results/${grp}/chip/${latestRun}/metadata.json
done

# once all jobs have finished can create overall summary with this command
qc2tsv ${WORK_DIR}/results/*/chip/*/qc/qc.json  > spreadsheet.tsv
