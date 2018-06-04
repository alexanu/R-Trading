getwd()

search()
library()

install.packages("curl")

#Load packages
library(RCurl) # the following functions from the package are used:...
library(plyr) # the following functions from the package are used:...
library(stringr) # the following functions from the package are used:...
library(quantmod) # the following functions from the package are used:...
library(data.table)
library(lubridate)
library(ggplot2)
library(PerformanceAnalytics)
library(curl)

id <- "0BxvMvfwI5rgZZ3YxdmlDaFZEVDA" # google file ID
ETFDB <- read.csv2(sprintf("https://docs.google.com/uc?id=%s&export=download", id),row.names = NULL)
row.names(oanda.currencies)
getFX("USD/EUR") # A convenience wrapper to getSymbols(x,src='oanda')



install.packages("psych")
library(psych) # has a function which combines head and tail


ret=30
Start_Date = Sys.Date()-(ret*2) #format should be “2015-01-19”
Stocks <- lapply(ETFs_Final$Symbol, 
                 function(sym) ROC( # calculating the return
                   Ad(na.omit(getSymbols(sym, from=Start_Date, auto.assign=FALSE))),
                   n=ret)) 




FX_CHANGE <- lapply(paste0(row.names(oanda.currencies),"/EUR")[1:4], 
                    function(x) tryCatch( # tryCatch is used for "if error then" ... 
                                        ROC(getFX(x,from=Start_Date, auto.assign=FALSE)),
                                        error=function(e) NULL))

FX_CHANGE <- do.call(merge.xts,FX_CHANGE) # transforming list
FX_CHANGE
...

FX_CHANGE <-FX_CHANGE[Sys.Date()-1,] # leaving only the returns for the last date
colnames(Stocks) <- gsub("[.].*$","",colnames(Stocks)) # removing everything after dot in the name
Stocks<-t(Stocks) # transposing matrix
Stocks<- cbind(Stocks, rownames(Stocks)) # adding another column ...
colnames(Stocks)<- c(paste("Ret_",ret, sep=""),"Symbol") #...and renaming both columns
ETFs_Final <<- merge(ETFs_Final, Stocks, by = "Symbol") # adding the returns to the main database of ETFs (the sign "<<-" does this)
remove(Stocks) # cleaning the Stocks variable
ETFs_Final # displaying the database with new data

#================================================================================#

install.packages("fxregime")
library(fxregime)

data("FXRatesCHF")
headTail(FXRatesCHF)

#================================================================================#
install.packages("lucr") # 
library(lucr)

key <- "2267e9ca092c411584b066dd16ba1f75"

conversion_rates(currency = "USD", key)



#================================================================================#
install.packages("TFX") # source of rates - TrueFX.com
library(TFX)

username <-"Kalmar"
password <-"Theanswer1"

QueryTrueFX(
		ConnectTrueFX(username=username, 
				  password=password,
				  format="csv"), 
		parse=FALSE)


#================================================================================#





















































