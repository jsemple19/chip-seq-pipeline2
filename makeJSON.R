args<-commandArgs(trailingOnly=T)

workDir<-args[1]
jsonDir<-args[2]
fastqPath<-args[3]
srrFile<-args[4]
genomeTsvPath<-args[5]

SRR<-read.delim(srrFile,sep=";",header=T)

#########
# make json files for encode pipeline -----
library(rjson)
if(!dir.exists(jsonDir)){
  dir.create(jsonDir)
}
#fastqPath<-"/data/projects/p025/jenny/modEncode_SMC/tmpRun/fastqFiles"
#genomeTsvPath<-"/data/projects/p025/jenny/genome/ce11/ce11.tsv"
# read in template
template<-fromJSON(file=paste0(workDir,"/example_input_json/template.json"))
for (g in unique(SRR$group)){
  tmp<-SRR[SRR$group==g,]
  numReplicates=nrow(tmp)
  print(paste0(g, " has ",numReplicates, " replicates"))
  tmpjson<-template
  tmpjson$chip.title<-tmp$group[1]
  tmpjson$chip.description<-paste("ModEncode ChIP:",tmp$group[1])
  tmpjson$chip.pipeline_type<-ifelse(grepl("^H[1|2|3|4]",tmp$group[1]),"histone","tf") #
  tmpjson$chip.genome_tsv<-genomeTsvPath
  tmpjson$chip.paired_end<-FALSE
  tmpjson$chip.ctl_paired_end<-FALSE
  tmpjson$chip.always_use_pooled_ctl<-FALSE
  for (r in 1:numReplicates){
  tmpjson[[paste0("chip.fastqs_rep",r,"_R1")]]<-list(paste0(fastqPath,"/",tmp$name[r],"_IP.fq.gz"))
  tmpjson[[paste0("chip.fastqs_rep",r,"_R2")]]<-NULL
  tmpjson[[paste0("chip.ctl_fastqs_rep",r,"_R1")]]<-list(paste0(fastqPath,"/",tmp$name[r],"_input.fq.gz"))
  tmpjson[[paste0("chip.ctl_fastqs_rep",r,"_R2")]]<-NULL
  }
  # write json
  prejson<-toJSON(tmpjson, indent=2)
  write(prejson,paste0(jsonDir,"/",g,".json"))
}


