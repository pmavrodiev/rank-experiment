library("DBI")
library("RSQLite")
library("fields")
library("RColorBrewer")
library("graphics")
library(png)
library(Cairo)
library(R.utils)
library("psych")
library("plotrix") 
library("circular")
library("animation")

#######
#######
analyse_db = function(dbname) {
  setwd("/home/pmavrodiev/Programs/rank-experiment/data/")
  spg_db = dbname
  SQLite()
  drv = dbDriver("SQLite")
  con = dbConnect(drv,dbname=paste(spg_db,".db",sep=""))
  #dbListTables(con)
  tname = paste(spg_db,"_0",sep="") # table name
  spg_db_query=paste("SELECT * FROM export_",spg_db,"_0",sep="")
  query=dbSendQuery(con,spg_db_query)
  results=fetch(query,-1)
  #basic set-up
  nagents = nrow(results)
  estimate_cols = c(8,seq(10,46,by=4))
  rank_cols = c(7,seq(11,47,by=4))
  rounds=seq(0,10)
  remove_agent = 1 #remove me from the data
  data = matrix(NA,nagents,length(rounds))
  ranks = matrix(NA,nagents,length(rounds))
  
  #fill 'data' by column
  for (i in 1:length(rounds)) {
    for (j in 1:nagents) {
      data[j,i] = as.double(strsplit(results[j,estimate_cols[i]],"/")[[1]][2])
      ranks[j,i] = as.double(results[j,rank_cols[i]])
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
  {
  plot(rounds,collective_error_mean,type="b",lty=3,pch="x",lwd=3,xlab="Round",ylab="CE",main="Collective Error (mean-T)^2",cex.lab=2,cex.axis=2,cex.main=2)  
  plot(rounds,collective_error_median,type="b",lty=3,pch=20,lwd=3,xlab="Round",ylab="CE",main="Collective Error (median-T)^2",cex.lab=2,cex.axis=2,cex.main=2)
  plot(rounds,diversity,type="b",lty=3,pch=23,lwd=3,xlab="Round",ylab="Diversity",main="Diversity",cex.lab=2,cex.axis=2,cex.main=2)
  dev.off()     
  dbClearResult(query)
  dbDisconnect(con)
  }
  
  
  #generate a movie with the estimates moving on a circle over time
  ani.options("nmax"=50,"interval"=1,"outdir"=getwd())
  createMovie = function() {
    controlCircular=list(units="degrees",rotation="counter",zero=0,type="angles",
                         template="none",modulo="asis")    
    par(mar=c(0,0,0,0))
    for (tidx in 1:length(rounds)) {   
      estimates_tidx = as.circular(data[,tidx],control.circular=controlCircular)    
      plot.circular(estimates_tidx,shrink=0.9)
      mean_angle = mean.circular(estimates_tidx,na.rm=TRUE)
      median_angle = medianCircular(estimates_tidx,na.rm=TRUE)
      arrows.circular(mean_angle,length=0.2,code=2,angle=30,lwd=2)
      arrows.circular(median_angle,length=0.2,code=2,angle=30,col="blue",lwd=2)
      #who has the lowest and highest ranks?
      lowest_rank_idx = which(ranks[,tidx] == min(ranks[,tidx],na.rm=TRUE))
      highest_rank_idx = which(ranks[,tidx] == max(ranks[,tidx],na.rm=TRUE))
      first = estimates_tidx[lowest_rank_idx]
      last = estimates_tidx[highest_rank_idx]
      points.circular(first,col="green")
      points.circular(last,col="red")
      #plot rank 1 from the previous round in yellow
      if (tidx > 1) {
        estimates_tidx_minus_1 = as.circular(data[,tidx-1],control.circular=controlCircular)
        previous_lowest_rank_idx = which(ranks[,tidx-1] == min(ranks[,tidx-1],na.rm=TRUE))
        previous_winner = estimates_tidx_minus_1[previous_lowest_rank_idx]
        points.circular(previous_winner,col="yellow")
      }
      #plot the global amplitude and phase
      estimates_tidx_converted=conversion.circular(estimates_tidx,units="radians",
                                                   type="angles",template="none",
                                                   modulo="asis",zero=0,rotation="counter")
      complex_amplitude=mean(complex(real=cos(estimates_tidx_converted),
                                     imaginary=sin(estimates_tidx_converted)),na.rm=TRUE)
      arrows.circular(mean_angle,Mod(complex_amplitude),x0=0,y0=0,angle=20,
                      col="pink",lwd=4)   
    }
  }
  #movie name is the name of the current table from the database, representing
  #one stage.
  saveVideo(createMovie(),video.name=paste(tname,".mp4",sep=""),img.name="RPlot",
            clean=TRUE)  
}

#######
#######


## 2012_28_08_11_47 - Server crashed after the first stage (my fault). 
##                    Canceled the other stages.
analyse_db("2012_28_08_11_47")
## 2012_28_08_12_00 - The first two stages only were done. Offsets were constant
##                    between stages, so we had to stop.
analyse_db("2012_28_08_12_00")


p_20 = function(alpha) {
  return (1-(1-alpha/180)^20)
}

Exp_Time_Alpha = function(alpha) {
  return (1/p_20(alpha)-1)
}

Total_Exp_Time = function(alpha_start,alpha_end) {
  nsuccesses = 0
  tmp=alpha_start
  while (tmp > alpha_end) {tmp = tmp/2;nsuccesses=nsuccesses+1}
  expected_total_time = 0
  for (i in 1:nsuccesses) {
    expected_total_time = expected_total_time + Exp_Time_Alpha(alpha_start)
    alpha_start = alpha_start / 2
  } 
  return (paste(nsuccesses,":",expected_total_time,sep=""))
}

Total_Exp_Time(20,0.5)
Total_Exp_Time(180,2)

x=rnorm(100,20,1.5)
hist(x)
plot(seq(1,20),success_prob(seq(1,20),25/180),type="l")




