#!/bin/bash
#SBATCH --mail-user=jennifer.semple@unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=1-34%10
#SBATCH --job-name="encode_chipseq"
#SBATCH --partition=pall
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --output=slurm-%x-%A-%a.out
#SBATCH --error=slurm-%x-%A-%a.out

### NOTE: the number of array jobs should be the same as the number of lines (datasets) in the srrFile

module add UHTS/Analysis/sratoolkit/2.10.7;

working_path=$PWD
srrFile=${working_path}/SRR_modEncode_chromatinChipSeq_modHistone.csv

taskID=$SLURM_ARRAY_TASK_ID
echo $taskID is SRRfile line number
nThreads=$SLURM_CPUS_PER_TASK
echo $nThreads threads used per task
slurmOutFile=${working_path}/slurm-${SLURM_JOB_NAME}-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}.out
echo $slurmOutFile is slurm output file

SRR_exp=(`grep -v "input;ip;name;group" $srrFile | sed -n ${taskID}p | cut -f3 -d";"`)
echo "Experiment name $SRR_exp"

SRR_IP=(`grep -v "input;ip;name;group" $srrFile | sed -n ${taskID}p | cut -f2 -d";"`)
SRR_input=(`grep -v "input;ip;name;group" $srrFile | sed -n ${taskID}p | cut -f1 -d";"`)
echo ${SRR_IP[@]} IP
echo ${SRR_input[@]} input

echo "-------------------------------"
#create folder for SRR download if it does not exists and delete content if it does
[ ! -d $working_path/SRR_download/${SRR_exp}_task${taskID} ] && mkdir -p $working_path/SRR_download/${SRR_exp}_task${taskID}
rm -rf $working_path/SRR_download/${SRR_exp}_task${taskID}/*
[ ! -d $working_path/SRR_download/${SRR_exp}_task${taskID}/IP ] && mkdir -p $working_path/SRR_download/${SRR_exp}_task${taskID}/IP
[ ! -d $working_path/SRR_download/${SRR_exp}_task${taskID}/input ] && mkdir -p $working_path/SRR_download/${SRR_exp}_task${taskID}/input
[ ! -d $working_path/qc/SRR_download/${SRR_exp}_task${taskID} ] && mkdir -p $working_path/qc/SRR_download/${SRR_exp}_task${taskID}

echo "Downloading IP: ${SRR_IP[@]}"
for i in "${SRR_IP[@]}"
do
   echo $i
   prefetch -o $working_path/SRR_download/${SRR_exp}_task${taskID}/$i $i
   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   if [ $? -ne 0  ]
   then
     echo "trying fasterq on its own"
     fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP -t $TMPDIR -e $nThreads $i
   else
     echo "running fasterq with prefetch"
     fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP -t $TMPDIR  -e $nThreads $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   fi

   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/IP/${i}.fastq
   if [ $? -ne 0 ]
   then
     echo "dowload failed. trying fastq-dump"
     fastq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/IP $i
     spots=$(tac $slurmOutFile | grep -m 1 "Read .* spots")
     echo $spots
   else
     spots=$(tac $slurmOutFile | grep -m 1 "spots read")
     echo $spots
   fi
   echo "compressing fastq with gzip."
   gzip $working_path/SRR_download/${SRR_exp}_task${taskID}/IP/${i}.fastq
   echo "${SRR_exp};IP;${i};${spots}" >> $working_path/qc/SRR_download/${SRR_exp}_task${taskID}/spotCounts.csv
  
   #clean up
   rm $working_path/SRR_download/${SRR_exp}_task${taskID}/${i}*
done


echo ""
echo "Downloading input: ${SRR_input[@]}"
for i in "${SRR_input[@]}"
do
   prefetch -o $working_path/SRR_download/${SRR_exp}_task${taskID}/$i $i
   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   if [ $? -ne 0  ]
   then
     echo "trying fasterq on its own"
     fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/input -t $TMPDIR -e $nThreads $i
   else
     echo "running fasterq with prefetch"
     fasterq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/input -t $TMPDIR -e $nThreads $working_path/SRR_download/${SRR_exp}_task${taskID}/$i
   fi
   vdb-validate $working_path/SRR_download/${SRR_exp}_task${taskID}/input/${i}.fastq
   
   if [ $? -ne 0 ]
   then
     echo "download failed. trying fastq-dump"
     fastq-dump -O $working_path/SRR_download/${SRR_exp}_task${taskID}/input $i
     spots=$(tac $slurmOutFile | grep -m 1 "Read .* spots")
     echo $spots
   else
     spots=$(tac $slurmOutFile | grep -m 1 "spots read")
     echo $spots
   fi
   echo "compressing fastq with gzip."
   gzip $working_path/SRR_download/${SRR_exp}_task${taskID}/input/${i}.fastq
   echo "${SRR_exp};input;${i};${spots}" >> $working_path/qc/SRR_download/${SRR_exp}_task${taskID}/spotCounts.csv
   
   #clean up
   rm $working_path/SRR_download/${SRR_exp}_task${taskID}/${i}*
done

echo "SRR download is over"

# combine multiple input/IP files into a single input/IP file
input=$(find $working_path/SRR_download/${SRR_exp}_task${taskID}/input/ -type f -name "*.fastq.gz")
IP=$(find $working_path/SRR_download/${SRR_exp}_task${taskID}/IP/ -type f -name "*.fastq.gz")
echo "Input files: $input" 
echo "IP files: $IP"
cat $input > $working_path/SRR_download/${SRR_exp}_input.fq.gz
cat $IP > $working_path/SRR_download/${SRR_exp}_IP.fq.gz

#cleanup
rm -rf $working_path/SRR_download/${SRR_exp}_task${taskID}

module rm UHTS/Analysis/sratoolkit/2.10.7;


# make json files for next step
#echo "Making json files for pipeline..."
#JSON_DIR=${working_path}/jsonFiles
#FASTQ_DIR=${working_path}/results/SRR_download
#genomeTsvPath="/data/projects/p025/jenny/genome/ce11/ce11.tsv"
#module load R;
#Rscript ./makeJSON.R $WORK_DIR $JSON_DIR $FASTQ_DIR $srrFile $genomeTsvPath
