#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

df <- read.table(args[1])

y_l <- as.numeric(args[2])
y_u <- as.numeric(args[3])

jpeg_filename <- paste(args[1],".jpg",sep="")
jpeg(file=jpeg_filename)
plot(df[,1],df[,2],type = "l",ylim = c(y_l,y_u),main=args[4],xlab="time (ps)",ylab="Energy (ev/atom)")
#plot(df[,1],df[,2],type = "l",ylim = c(y_l,y_u))
lines(df[,1],df[,4])
lines(df[,1],df[,3])
