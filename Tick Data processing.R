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












