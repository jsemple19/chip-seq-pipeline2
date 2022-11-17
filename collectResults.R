#!/usr/bin/env Rscript
library(rjson)

args <- commandArgs(trailingOnly=TRUE)

SRRfile<-"./SRR_Ahringer.csv"
workDir=getwd()
SRRfile<-args[1]
workDir<-args[2]
jsonDir<-args[3]


df<-read.delim(SRRfile,sep=";",skip=1,header=F,stringsAsFactors=F)

groups<-unique(df$V4)

dir.create("bigwig_fc", showWarnings=F)
dir.create("bigwig_pval", showWarnings=F)
dir.create("peaks", showWarnings=F)
dir.create("qc", showWarnings=F)

for (grp in groups) {
  grpInfo<-fromJSON(file=paste0(jsonDir,"/",grp,".json"))
  batchName<-list.files(paste0(workDir,"/results/",grp,"/chip"))

  # rep1 bigwig fc
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep1/",grp,"_rep1_IP.srt.nodup_x_",grp,"_rep1_input.srt.nodup.fc.signal.bigwig"),
           to=paste0(workDir,"/bigwig_fc/",grp,"_rep1_IP_x_input.srt.nodup.fc.signal.bigwig"))
 
  # rep1 bigwig pval
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep1/",grp,"_rep1_IP.srt.nodup_x_",grp,"_rep1_input.srt.nodup.pval.signal.bigwig"),
           to=paste0(workDir,"/bigwig_pval/",grp,"_rep1_IP_x_input.srt.nodup.pval.signal.bigwig"))

  # rep2 bigwig fc
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep2/",grp,"_rep2_IP.srt.nodup_x_",grp,"_rep2_input.srt.nodup.fc.signal.bigwig"),
           to=paste0(workDir,"/bigwig_fc/",grp,"_rep2_IP_x_input.srt.nodup.fc.signal.bigwig"))
    # rep2 bigwig pval
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/rep2/",grp,"_rep2_IP.srt.nodup_x_",grp,"_rep2_input.srt.nodup.pval.signal.bigwig"),
           to=paste0(workDir,"/bigwig_pval/",grp,"_rep2_IP_x_input.srt.nodup.pval.signal.bigwig"))
  
  # pooled bigwig fc
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/pooled-rep/rep.pooled_x_ctl.pooled.fc.signal.bigwig"),
          to=paste0(workDir,"/bigwig_fc/",grp,"_rep.pooled_x_ctl.pooled.fc.signal.bigwig"))
  # pooled bigwig pval
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/signal/pooled-rep/rep.pooled_x_ctl.pooled.pval.signal.bigwig"),
           to=paste0(workDir,"/bigwig_pval/",grp,"_rep.pooled_x_ctl.pooled.pval.signal.bigwig"))
  
  if(grpInfo$chip.pipeline_type == "histone"){
  # peak rep1
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/rep1/",grp,"_rep1_IP.srt.nodup_x_",grp,"_rep1_input.srt.nodup.pval0.01.500K.bfilt.narrowPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_rep1_IP_x_input.srt.nodup.pval0.01.500K.bfilt.narrowPeak.gz"))
  # peak rep2
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/rep2/",grp,"_rep2_IP.srt.nodup_x_",grp,"_rep2_input.srt.nodup.pval0.01.500K.bfilt.narrowPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_rep2_IP_x_input.srt.nodup.pval0.01.500K.bfilt.narrowPeak.gz"))
  
  ## reproducible peaks - conservative
  #file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/overlap_reproducibility/overlap.conservative_peak.narrowPeak.gz"),
  #         to=paste0(workDir,"/peaks/",grp,"_overlap.conservative_peak.narrowPeak.gz"))
  # reproducible peaks - optimal
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/overlap_reproducibility/overlap.optimal_peak.narrowPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_overlap.optimal_peak.narrowPeak.gz"))
  } else {
    # peak rep1
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/rep1/",grp,"_rep1_IP.srt.nodup_x_",grp,"_rep1_input.srt.nodup.300K.bfilt.regionPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_rep1_IP_x_input.srt.nodup.300K.bfilt.regionPeak.gz"))
  # peak rep2
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/rep2/",grp,"_rep2_IP.srt.nodup_x_",grp,"_rep2_input.srt.nodup.300K.bfilt.regionPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_rep2_IP_x_input.srt.nodup.300K.bfilt.regionPeak.gz"))
  # reproducible peaks - optimal
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/overlap_reproducibility/overlap.optimal_peak.regionPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_overlap.optimal_peak.regionPeak.gz"))
  # idr reproducible peaks - optimal
  file.copy(from=paste0(workDir,"/results/",grp,"/chip/",batchName,"/peak/idr_reproducibility/idr.optimal_peak.regionPeak.gz"),
           to=paste0(workDir,"/peaks/",grp,"_idr.optimal_peak.regionPeak.gz"))
  }
  # qc folder
  dir.create(paste0(workDir,"/qc/",grp))
  system(paste0("cp -r ",workDir,"/results/",grp,"/chip/",batchName,"/qc/*  ", workDir,"/qc/",grp,"/"))
  system(paste0("cp -r ",workDir,"/results/",grp,"/chip/",batchName,"/croo*  ", workDir,"/qc/",grp,"/"))
}
