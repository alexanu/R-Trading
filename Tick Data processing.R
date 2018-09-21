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


# ---------------------------------------------------------------------------------------------------------------------


tables() # shows list of created datables
setkey(datable_key,Volume)

datable <- NULL
summary(datable)
lapply(small_data,class)
head(datable)
head(datable_key)

system.time(
datable[,.N, by=Ticker] # .N stands for just number of lines
datable[,length(Volume), by=Ticker]
datable[,sum(Volume), by="Ticker,Close"]
datable[,head(.SD,10), by=Ticker] # returns the first 3 rows for every ticker
datable[,lapply(.SD,mean), by=Ticker] # .SD allows to run the mean by every column
datable[(Close-Open)/Open>0.05 & Volume>10000]
datable[,.(sum(Volume),.N), by=.(lubridate::wday(Date),hour(Date))] # volume of trades by day and hour
)


x <- datable[High-Close==0,.(Avg_Vol=mean(Volume),No_of_Trades=length(Volume)), by=Ticker]
x <- datable[,wday:=paste(wday,hour,sep=" ")]

x
Vol_over <-  dcast(datable[,.(Vol=round(sum(Volume)/1e6, 1)),  # to show in millions
				  keyby=.(wday(Date,label=TRUE), # we need "keyby" no just "by", because we need sorted data
				  hour(Date),
				  Ticker)],
			wday+hour~Ticker, # vertical axes ~ horizontal axis
			value.var = "Vol") # values

Vol_over
Vol_over[,wday:=paste(wday,hour,sep=" ")][,':='(hour=NULL)] # 1st part merges days and hours; 2nd part deletes the not-needed hour column



system.time(datable[,sum(Volume), by="Ticker,Close"])
system.time(datable_key[,sum(Volume), by="Ticker,Close"])


system.time(datable[order(Volume)]) # much faster than base::order()
system.time(datable_key[order(Volume)]) # much faster than base::order()


# ---------------------------------------------------------------------------------------------------------------------


ggplot(datatb[Date>"2011-11-01" & Date<"2012-11-01"],
	 aes(x=Date,
	     y=Close,
	     colour=Ticker))+
	geom_line()+
	geom_smooth()+
	facet_wrap(~Ticker,scales = "free_y")


ggplot(datatb[(Close-Open)/Open >0.025], # Daily change more than 2.5%
	 aes(Date))+
	geom_histogram()+ # or "geom_freqpoly" could be also used
	facet_wrap(~Ticker, ncol=1) # putting 4 charts 1 under another




ggplot(datatb[,.(mean(Volume),.N),by=.(Ticker,wday(Date,label=TRUE))],
	 aes(x=wday,
	     y=V1,
	     colour=Ticker))+
	geom_point(aes(size=N))+
	scale_size_area() +
	xlab(NULL)+
	ylab("Avg Volume")
ggsave("plot.png", width = 5, height = 5)


DAY <- datatb[Date>"2011-11-01" & Date<"2011-11-02" & Ticker=="LL"]
DAY[,D:=Close>Open]
ggplot(DAY, 
		   aes(Date, 
			 Close, 
			 ymin = Low, 
			 ymax = High,
			 colour=D))+ 
	  geom_pointrange()




ggplot(datatb[Ticker=="LL",.(mean(Volume),mean(Close)),by=.(year(Date),month(Date,label=TRUE))],
	 aes(x=paste(year,month,sep=" "),
	     y=V1,
	     colour = V2))+
	geom_line(aes(group=1), size = 2)+
	geom_point(size = 5)

datatb[,.(sum(Volume),mean(Close)),by=.(Ticker,year(Date),month(Date,label=TRUE))]


ggplot(datatb[,.(sum(Volume),mean(Close)),by=.(Ticker,year(Date),month(Date,label=TRUE))],
	 aes(x=paste(year,month,sep=" "),
	     y=V2,
	     colour = Ticker))+
	geom_point(aes(size = V1))+
	scale_size_area("Monthly volume", breaks = c(1000000, 2000000, 3000000,4000000))




ggplot(datatb[,.(sum(Volume),mean(Close)),by=.(Ticker,floor_date(Date,"week"))],
	 aes(x=V1,y=V2))+
	 geom_point(aes(colour = Ticker)) +
  	 geom_point(data=datatb[,.(sum(Volume),mean(Close)),by=.(floor_date(Date,"week"))],
			colour="grey70")+
	 facet_wrap(~Ticker, ncol=1)




ggplot(datatb,
	 aes(Date))+
	 geom_histogram(aes(fill = Ticker), 
			   position = "fill",
			   na.rm = TRUE)
			   


install.packages("hexbin")
library(hexbin)
ggplot(datatb[,.(sum(Volume),(mean(Close)-mean(Open))/mean(Open)),by=.(Ticker,year(Date),month(Date,label=TRUE))],
	 aes(V2,V1))+
	 geom_hex()
	 
	 


datatb[Ticker=="LL" & floor_date(Date,"day")==ymd("2007-11-12",tz="GMT")]



datatb[,RR:=rank(-1*Volume),by=.(Ticker,floor_date(Date,"month"))] # adds the rank to the trades in every month
ggplot(datatb[Ticker=="LL"],
	 aes(x=Date,
	     y=Close))+
	geom_line()+
	geom_point(data=datatb[Ticker=="LL"& RR=="1"], 
		     aes(x=Date,
	     		   y=Close,
			   size=Volume))




ggplot(datatb[Date>"2011-11-01" & Date<"2012-11-02",.((mean(Close)-mean(Open))/mean(Open)),by=.(Ticker,floor_date(Date,"month"))],
	 aes(V1,
	     reorder(paste(Ticker,floor_date,sep=" "),V1)))+
	 geom_point()











