library("DBI")
library("RSQLite")
library("fields")
library("RColorBrewer")
library("graphics")

setwd("/home/pmavrodiev/Programs/rank-experiment")
spg_db = "2012_27_08_15_32.db"
SQLite()
drv = dbDriver("SQLite")
con = dbConnect(drv,dbname=spg_db)
dbListTables(con)


spg_db_query=paste("SELECT * FROM export_2012_27_08_15_32_0",sep="")

query=dbSendQuery(con,spg_db_query)
results=fetch(query,-1)
cols = c(8,seq(10,46,by=4))
x=seq(0,10)
data = matrix(0,6,11)
collective_error = rep(0,11)
collective_error_median = rep(0,11)
diversity = rep(0,11)
Mean = c()
Median = c()

for (i in 1:11) {
  
  v = c()
  for (j in 1:6) {
    internalEstimate = abs(as.double(strsplit(results[j,cols[i]],"/")[[1]][2]))
    data[j,i] = internalEstimate
    Mean=c(Mean,internalEstimate)
    Median=c(Median,internalEstimate)
    v = c(v,internalEstimate)
  }
  collective_error[i] = mean(Mean)^2
  collective_error_median[i] = median(Mean)^2
  diversity[i] = var(v)
}


plot(x,log(data[1,]),type="o",ylim=c(0,10),col=1)
lines(x,log(data[2,]),type="o",col=2)
lines(x,log(data[3,]),type="o",col=3)
lines(x,log(data[4,]),type="o",col=4)
lines(x,log(data[5,]),type="o",col=5)
lines(x,log(data[6,]),type="o",col=6)
lines(x,log(collective_error),type="b",lty=3,pch="x",lwd=3)
lines(x,log(collective_error_median),type="b",lty=3,pch=20,lwd=3)
lines(x,log(diversity),type="b",lty=3,pch=23,lwd=3)


dbClearResult(query)
dbDisconnect(con)