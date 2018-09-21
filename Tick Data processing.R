# To install and load pkges quickly you could use "easypackages", "install.load", "xfun::pkg_attach2()" or "librarian"
install.packages("librarian")
librarian::shelf(readr, feather, data.table,readit,ggplot2,magrittr, 
		     fasttime, lubridate, anytime)


Path <- "\\\\WWG00M.ROOTDOM.NET/DFS/HOME/G107980/ICM/Desktop/1/Programming/R/tick_data"
tickers <- list.files(path = Path) %>% # give a list of all the files in the directory
	     gsub(".txt", "",.)%>%  # I need to get rid of file extensions      
		as.list()                      

datable <- lapply(tickers, function(i) {paste0(Path ,"/",i,".txt") %>% 
				 	fread(dec=',',colClasses=c("numeric")) %>% 
					.[, `:=`(Ticker=i,
						   Date= paste(Date,Time,sep=" ")%>% lubridate::parse_date_time2("dmY HM"),
						   Time=NULL)]}) %>%
		rbindlist()

# anytime::anytime() doesn't recognize 1 digit hour (e.g. 9)
# fasttime::fastPOSIXct() doesn't work as it could be used only for 1 format


# try creating datatable with keys

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


