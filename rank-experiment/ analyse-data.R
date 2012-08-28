library("DBI")
library("RSQLite")
library("fields")
library("RColorBrewer")
library("graphics")
library(png)
library(Cairo)
library(R.utils)



analyse_db = function(dbname) {
  setwd("/home/pmavrodiev/Programs/rank-experiment")
  spg_db = dbname
  SQLite()
  drv = dbDriver("SQLite")
  con = dbConnect(drv,dbname=paste(spg_db,".db",sep=""))
  #dbListTables(con)
  spg_db_query=paste("SELECT * FROM export_",spg_db,"_0",sep="")
  query=dbSendQuery(con,spg_db_query)
  results=fetch(query,-1)
  #basic set-up
  nagents = nrow(results)
  estimate_cols = c(8,seq(10,46,by=4))
  rounds=seq(0,10)
  remove_agent = 1 #remove me from the data
  data = matrix(NA,nagents,length(rounds))
 
  #fill 'data' by column
  for (i in 1:length(rounds)) {
    for (j in 1:nagents) {
      data[j,i] = as.double(strsplit(results[j,estimate_cols[i]],"/")[[1]][2])
  }  
  }
  collective_error_mean = rep(NA,length(rounds)) #calculated as (<x>-T)^2
  collective_error_median = rep(NA,length(rounds)) #calculated as (median-T)^2
  diversity = rep(0,length(rounds))
  
  #plot the row distance to the truth of all agents
  setwd("/home/pmavrodiev/Programs/rank-experiment/plots")
  CairoPDF(file=paste(dbname,".pdf",sep=""),width=15,height=15) 
  dummy=1
  for (i in 1:nagents) {
    if (i != remove_agent) {
      estimates_i = data[i,]
      if (dummy == 1) {
        plot(rounds,estimates_i,type="o",col=i,ylim=c(-330,330),xlab="Round",ylab="Dist. to Truth",main="Distance to the Truth for all Agents",lwd=3,cex.lab=2,cex.axis=2,cex.main=2)  
        dummy = dummy+1
      }
      else
        lines(rounds,estimates_i,type="o",col=i,lwd=3)
    }
  }
  
  #plot the abs distance to the truth of all agents
  dummy=1
  for (i in 1:nagents) {
    if (i != remove_agent) {
      abs_estimates_i = abs(data[i,])
      if (dummy == 1) {
        plot(rounds,log(abs_estimates_i),type="o",col=i,ylim=c(-6.5,6),xlab="Round",ylab="Log Dist. to Truth",main="Absolute Distance to the Truth for all Agents",lwd=3,cex.lab=2,cex.axis=2,cex.main=2)  
        dummy = dummy+1
      }
      else
        lines(rounds,log(abs_estimates_i),type="o",col=i,lwd=3)
    }
  }
  #plot the collective errors calculated with the mean and median
  for (col in 1:length(rounds)) {  
    Mean = c()
    Median = c()
    v = c()
    for (row in 1:nagents) {
      if (row != remove_agent) {
        internalEstimate = data[row,col]
        Mean=c(Mean,internalEstimate)
        Median=c(Median,internalEstimate)
        v = c(v,internalEstimate)
      }
    }
    collective_error_mean[col] = mean(Mean,na.rm=TRUE)^2
    collective_error_median[col] = median(Mean,na.rm=TRUE)^2
    diversity[col] = var(v,na.rm=TRUE)
  }  
  plot(rounds,collective_error_mean,type="b",lty=3,pch="x",lwd=3,xlab="Round",ylab="CE",main="Collective Error (mean-T)^2",cex.lab=2,cex.axis=2,cex.main=2)  
  plot(rounds,collective_error_median,type="b",lty=3,pch=20,lwd=3,xlab="Round",ylab="CE",main="Collective Error (median-T)^2",cex.lab=2,cex.axis=2,cex.main=2)
  plot(rounds,diversity,type="b",lty=3,pch=23,lwd=3,xlab="Round",ylab="Diversity",main="Diversity",cex.lab=2,cex.axis=2,cex.main=2)
  dev.off()   
  
  dbClearResult(query)
  dbDisconnect(con)
}


## 2012_28_08_11_47 - Server crashed after the first stage (my fault). Canceled the rest.
analyse_db("2012_28_08_11_47")




