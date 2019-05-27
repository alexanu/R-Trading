install.packages("data.table")# we need the function "fread" from this package.
install.packages("fasttime") # we need the function "fastPOSIXct" from this package.
install.packages("lubridate")

library(data.table) # we need the function "fread" from this package.
library(fasttime) # we need the function "fastPOSIXct" from this package
library(lubridate)
library(ggplot2)

Path <- "L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\tick_data" # The directory where all the tick data files are stored
tickers <- gsub(".txt", "", # I need to get rid of file extensions
			list.files(path = Path)) # ...give a list of all the files in the directory

datatb <- rbindlist( # puts every block one under another
			        lapply(paste0(Path ,"\\",tickers,".txt"), # to every return duration applies the formuls from below... 
	   			  	   function(x) cbind( # this function creates several columns...
								   fread(x),
							     	   "Ticker"=tickers)
				  ))

####################################################################################################################################
# We need to transform 2 first columns in data and time
# The fastPOSIXct function is very fast, however it requires the format like this: "%Y-%m-%d"
# Unfortunately the txt file have this format: "%d.%m.%Y"
# I need to find a solution for quick format change.
# One idea was to specify type of columns during the fread. However fread doesn't like this


datatb1 <- rbindlist( # puts every block one under another
			        lapply(paste0(Path ,"\\",tickers,".txt"), # to every return duration applies the formuls from below... 
	   			  	   function(x) cbind( # this function creates several columns...
								   fread(x,
										colClasses = c("Date",
												   "Time",
												   "character", 
												   "character", 
												   "character", 
												   "character", 
												   "numeric", 
												   "character")),
							     	   "Ticker"=tickers)
				  ))

# below are different ways of transforming to the needed-for-fastPOSIXct format already after the fread. 
# all the ways were very long even for 4 tickers (20 secs)

with(datatb , dmy(Date) + hm(Time))
datatb[,Date:=paste(datatb[,Date],datatb[,Time],sep=" ")] # the date and time are in 2 columns: we need to merge them
datatb[,Date:=fastPOSIXct(datatb[,Date],"GMT")]# This is much faster than to do it with "as.POSIXct" function from standart functionality
datatb[,Date:=fastPOSIXct(paste(dmy(datatb[,Date]),datatb[,Time],sep=" "),"GMT")]#
as.Date(datatb[,Date], "%d.%m.%Y")
dmy(datatb[,Date])
paste(as.Date(datatb[,Date], "%d.%m.%Y"),datatb[,Time],sep=" ")
fastPOSIXct(as.Date(paste(datatb[,Date], datatb[,Time],sep=" "),"%d.%m.%Y %H:%M"),"GMT")
paste(datatb[,Date], datatb[,Time],sep=" ")

fastPOSIXct(paste(datatb[,Date], datatb[,Time],sep=" "),
                            format="%d.%m.%Y %H:%M" #format time
                            )

parse_date_time(datatb[,Date],"%d.%m.%Y")


library(chron)
chron(datatb[,Date], format = "d.m.Y")


strptime(datatb[,Date],"%d.%m.%Y")

fastPOSIXct(paste(as.Date(datatb[,Date], "%d.%m.%Y"),datatb[,Time],sep=" "),"GMT")
fastPOSIXct(paste(dmy(datatb[,Date]),datatb[,Time],sep=" "),"GMT")
fastPOSIXct(paste(dmy(datatb[,Date]),datatb[,Time],sep=" "),"GMT")





###############################################################################################################################



datatb[,Date:=paste(format(as.Date(datatb[,Date],format="%d.%m.%Y"),"%Y-%m-%d"),datatb[,Time],sep=" ")] # the date and time are in 2 columns: we need to merge them
datatb[,Date:=fastPOSIXct(datatb[,Date],"GMT")]# This is much faster than to do it with "as.POSIXct" function from standart functionality
						# however it requires the format like this "%Y-%m-%d"
datatb[,':='(Time=NULL, V8=NULL)] # delete not needed column
datatb[,Volume:=as.numeric(datatb[,Volume])] # we need this in order to work with Volumes as integer is not enough


datatb[,.(.N), by=.(weekdays(Date),Ticker)] # number of rows per weekday and ticker
datatb[,.(sum(Volume),.N), by=.(wday(Date),hour(Date))] # volume of trades by day and hour. "wday" is from "lubridate" package


Vol_over <-  dcast(datatb[,.(Vol=round(sum(Volume)/1e6, 1)),  # to show in millions
				  keyby=.(wday(Date,label=TRUE), # we need "keyby" no just "by", because we need sorted data. "wday" is from "lubridate" package
				  hour(Date),
				  Ticker)],
			wday+hour~Ticker, # vertical axes ~ horizontal axis
			value.var = "Vol") # values
Vol_over[,wday:=paste(wday,hour,sep=" ")][,':='(hour=NULL)] # 1st part merges days and hours; 2nd part deletes the not-needed hour column
Vol_over[, 2:5:=lapply(.SD, rank),.SDcols = 2:5] # ranks the periods for every ticker



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
