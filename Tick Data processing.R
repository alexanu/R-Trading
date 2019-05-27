For testing the speed of data.table we need to create 3 identical databases:
1) A dataframe
2) A Datatable without key
3) A Datatable with key

################################# Creating a data frame ##################################################


Path <- "L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\tick_data" # The directory where all the tick data files are stored
tickers <- gsub(".txt", "", # I need to get rid of file extensions
                                    list.files(path = Path)) # ...give a list of all the files in the directory
Symbol_Path <- paste0(Path ,"\\",tickers,".txt")
datalist = lapply(Symbol_Path, #creates list: reads all  the txt file from the folder and every dataframe in separate list componentassuming tab separated values with a header    
                  FUN=read.table, # fread from the package "DATA.TABLE" does it much faster than read.table (standard functionality). The comparison of time could be done using function system.time(x), where x is our expression
                  stringsAsFactors=FALSE,
                  header=TRUE,
                  dec=",") # OLHC data has comma as a decimal separator
datalist <- mapply(cbind, datalist , "Ticker"=tickers, SIMPLIFY=F) # add new column to every dataframe in the list and fills it with the symbol
datafr = do.call("rbind", datalist) #merges down all the dataframes

datafr[,"Date"]<-paste(datafr[,"Date"],datafr[,"Time"],sep=" ") # the date and time are in 2 columns: we need to merge them
datafr <- datafr[,-2]
datafr[,"Date"]<-as.POSIXct(strptime(datafr[,"Date"],"%d.%m.%Y %H:%M")) # 
datafr[,"Volume"]<-as.numeric(datafr[,"Volume"]) # # we need this in order to work with Volumes as integer is not enough


################################### Creating a data table w/o key ###########################################



install.packages("data.table")# we need the function "fread" from this package.
library(data.table)
install.packages("fasttime") # we need the function "fastPOSIXct" from this package.
library(fasttime)


Path <- "L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\tick_data" # The directory where all the tick data files are stored
tickers <- gsub(".txt", "", # I need to get rid of file extensions
                                    list.files(path = Path)) # ...give a list of all the files in the directory
Symbol_Path <- paste0(Path ,"\\",tickers,".txt")
datalist = lapply(Symbol_Path, #creates list: reads all  the txt file from the folder and every dataframe in separate list componentassuming tab separated values with a header    
                                                FUN=fread, # fread from the package "DATA.TABLE" does it much faster than read.table (standard functionality). The comparison of time could be done using function system.time(x), where x is our expression
                                                stringsAsFactors=FALSE,
                                                dec=",") # OLHC data has comma as a decimal separator    
datalist <- mapply(cbind, datalist , "Ticker"=tickers, SIMPLIFY=F) # add new column to every dataframe in the list and fills it with the symbol
datatb = rbindlist(datalist) # #merges down all the data tables. The function is from data.table package. Another way is to do like this: "do.call("rbind", datalist)". The alternative way could be slower
datatb[,Date:=paste(datatb[,Date],datatb[,Time],sep=" ")] # the date and time are in 2 columns: we need to merge them
datatb[,Date:=fastPOSIXct(datatb[,Date])]# This is much faster than to do it with "as.POSIXct" function from standart functionality
datatb[,Time:=NULL] # delete not needed column 
datatb[,Volume:=as.numeric(datatb[,Volume])] # we need this in order to work with Volumes as integer is not enough

################################### Creating a data table with key ###########################################

datatbKEY = do.call("rbind", datalist) #merges down all the dataframes

datatbKEY[,Date:=paste(datatbKEY[,Date],datatbKEY[,Time],sep=" ")] # the date and time are in 2 columns: we need to merge them
datatbKEY[,Date:=fastPOSIXct(datatbKEY[,Date])]# This is much faster than to do it with "as.POSIXct" function from standart functionality
datatbKEY[,Time:=NULL] # delete not needed column 
datatbKEY[,Volume:=as.numeric(datatbKEY[,Volume])] # we need this in order to work with Volumes as integer is not enough

##############################################################################################################

Path <- "L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\ETFcsv"
ETF_files <- list.files(path = Path,full.names = TRUE) # ...give a list of all the files in the directory
datalist = lapply(ETF_files, # creates list: reads all  the txt file from the folder and every dataframe in separate list componentassuming tab separated values with a header    
                  FUN=fread) # fread from the package "DATA.TABLE" does it much faster than read.table


ETFDT = do.call(merge, datalist, by=Ticker) #merges down all the dataframes

names(datalist[[1]])
ETFDT
names(ETFDT)
class(ETF_files)

















#################################################################################################################




######################################################################################################


head(datafr)
datatb=data.table(datafr)
head(datatb)
sapply(datatb,class)
sapply(datafr,class)
class(datatb)
datatb[Volume>1000000,]
setkey(datatb,Volume, Open, Close)
setkey(datatb,Date)
setkey(datatb,Ticker)
datatb[>1000000]
dim(datafr)


datafr[(datafr$Close-datafr$Open)/datafr$Open>0.05 & datafr$Volume>10000,]
system.time(ans1 <- datafr[(datafr$Close-datafr$Open)/datafr$Open>0.05 & datafr$Volume>10000,])
system.time(ans1 <- datatb[(Close-Open)/Open>0.05 & Volume>10000]) # the search through data.table is 2-3 times faster than through dataframe

datatb[,Volume:=as.numeric(datatb[,Volume])] # we need this in order to work with Volumes as integer is not enough
datatb[,length(Volume), by=Ticker]
datatb[,sum(Volume), by=Ticker]
datatb[,.N, by=Ticker] # .N stands for just number of lines
datatb[High-Close==0,.(Avg_Vol=mean(Volume),No_of_Trades=length(Volume)), by=Ticker]

datatb[,lapply(.SD,mean), by=Ticker] # .SD allows to run the mean by every column

datatb[,head(.SD,3), by=Ticker] # returns the first 3 rows for every ticker



####### Testing of using the key ###############################
tables() # shows list of created datables
setkey(datatbKEY,Volume)

system.time(datatb[,sum(Volume), by=Ticker])
system.time(datatbKEY[,sum(Volume), by=Ticker])




############Testing the speed of "by=" vs tapply#############################
system.time(datatb[,sum(Volume), by=Ticker]) # by is much faster than tapply ...
system.time(tapply(datatb$Volume,datatb$Ticker,sum)) #...while tapply for DT is a bit faster than for DF
system.time(tapply(datafr$Volume,datafr$Ticker,sum))
system.time(datatb[,sum(Volume), by="Ticker,Close"]) # it is even faster when we use 2 criteriors
system.time(tapply(datatb$Volume,list(datatb$Ticker,datatb$Close),sum))


############Testing the speed of ordering########################
system.time(datatb[order(Volume)]) # Much faster than 2 other ways below:
system.time(datatb[base::order(Volume)])


