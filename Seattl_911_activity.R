#-----------------------------------by Nader Laal Dehghani----------------------------------------#
library(data.table)
Data <- fread(file="Call_Data.csv", header=TRUE, sep=",")

CAD <- Data$`CAD Event Number`
clear <- Data$`Event Clearance Description`
call <- Data$`Call Type`
priority <- Data$Priority
initial_type <- Data$`Initial Call Type`
final_type <- Data$`Final Call Type`
time_org <- Data$`Original Time Queued`
time_arr <- Data$`Arrived Time`
sector <- Data$Sector
precinct <- Data$Precinct
beat <- Data$Beat

#-----------------------------------------------------------------------------------------------------#
time1 <- strptime(time_org,format='%m/%d/%Y %I:%M:%S %p')
Month <- as.numeric(format(time1,"%m"))
Year  <- as.numeric(format(time1,"%Y"))
HOUR  <- as.numeric(format(time1,"%H"))
time2 <- strptime(time_arr,format='%b %e %Y %I:%M:%S:000%p')
time_res <- as.numeric(time2-time1) #call response time

idx0 <- time_res>0 & time_res<10000 #valid response time
idx1 <- call!="ONVIEW" #ignoring onview police interaction for response time analysis
idx2 <- clear!="DUPLICATED OR CANCELLED BY RADIO" & clear!="RESPONDING UNIT(S) CANCELLED BY RADIO"
idx3 <- priority>0
idx4 <- sector!="NULL"

index <- idx0 & idx1 & idx2
t_hour_mean <- tapply(time_res[index],HOUR[index],mean)
t_hour_count <- tapply(time_res[index],HOUR[index],length)
barplot(t_hour_mean,xlab = "Hour of the day", ylim = c(0,3000), ylab = "Average police response time in second",col="darkblue")
barplot(t_hour_count,xlab = "Hour of the day", ylim=c(0,120000), ylab = "Number of police calls",col="red")

H <- c(0:23)
H_pr <- matrix(0,nrow=9, ncol=length(H), byrow=TRUE)
counter <-0
for (i in H) {
  counter <- counter +1
  temp <- tapply(time_res[index&idx3&HOUR==i],priority[index&idx3&HOUR==i],length)
  H_pr[as.numeric(names(temp/sum(temp)))+(counter-1)*9] <-temp/sum(temp)
}

colnames(H_pr) <-c(0:23)
par(fig=c(0,0.95,0,1))
barplot(H_pr,xlab = "Hour of the day", ylab = "Proportion of Service Call Priority Codes",col=rainbow(9))
par(fig=c(0,1,0,1))
legend(28,1,legend=c(1:9),fill = rainbow(9))
