#!/usr/bin/env Rscript
library(rjson)

args <- commandArgs(trailingOnly=TRUE)

SRRfile<-"./SRR_modEncode_chromatinChipSeq_modHistone.csv"
workDir=getwd()
jsonDir="./jsonFiles"
SRRfile<-args[1]
workDir<-args[2]
jsonDir<-args[3]


df<-read.delim(SRRfile,sep=";",skip=1,header=F,stringsAsFactors=F)

groups<-unique(df$V4)

dir.create("bigwig_fc", showWarnings=F)
dir.create("bigwig_pval", showWarnings=F)
dir.create("peaks", showWarnings=F)
dir.create("qc", showWarnings=F)

grp=groups[1]
for (grp in groups) {
  grpInfo<-fromJSON(file=paste0(jsonDir,"/",grp,".json"))
  batchName<-list.files(paste0(workDir,"/results/",grp,"/chip"))
  isPooled<-grep("_ctl\\.pooled",list.files(paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep1/"),pattern="fc\\.signal\\.bigwig"))
  tmp<-df[df$V4==grp,]
  for(i in 1:nrow(tmp)){
    if(isPooled){
      suffix="_ctl.pooled"
      suffix1=suffix
    } else {
      suffix=paste0("_",tmp$V3[i],"_rep",i,"_input.srt.nodup")
      suffix1="_input.srt.nodup"
    }

    # rep bigwig fc
    file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep",i,"/",tmp$V3[i],"_IP.srt.nodup_x",suffix,".fc.signal.bigwig"),
           to=paste0(workDir,"/bigwig_fc/",grp,"_rep",i,"_IP_x",suffix1,".fc.signal.bigwig"))
    # rep bigwig pval
    file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep",i,"/",tmp$V3[i],"_IP.srt.nodup_x",suffix,".pval.signal.bigwig"),
           to=paste0(workDir,"/bigwig_pval/",grp,"_rep",i,"_IP_x",suffix1,".pval.signal.bigwig"))
    # peak rep
    file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/rep",i,"/",tmp$V3[i],"_IP.srt.nodup_x",suffix,".pval0.01.500K.bfilt.narrowPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_rep",i,"_IP_x",suffix1,".pval0.01.500K.bfilt.narrowPeak.gz"))  
  }

  # pooled bigwig fc
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/pooled-rep/rep.pooled_x_ctl.pooled.fc.signal.bigwig"),
          to=paste0(workDir,"/bigwig_fc/",grp,"_rep.pooled_x_ctl.pooled.fc.signal.bigwig"))
  # pooled bigwig pval
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/pooled-rep/rep.pooled_x_ctl.pooled.pval.signal.bigwig"),
           to=paste0(workDir,"/bigwig_pval/",grp,"_rep.pooled_x_ctl.pooled.pval.signal.bigwig"))
  
  # reproducible peaks - optimal
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/overlap_reproducibility/overlap.optimal_peak.narrowPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_overlap.optimal_peak.narrowPeak.gz"))
  
  # qc folder
  dir.create(paste0(workDir,"/qc/",grp))
  system(paste0("cp -r ",workDir,"/results/",grp,"/chip/",batchName,"/qc/*  ", workDir,"/qc/",grp,"/"))
  system(paste0("cp -r ",workDir,"/results/",grp,"/chip/",batchName,"/croo*  ", workDir,"/qc/",grp,"/"))

  #TODO: idr overlap peaks for TF?
}
