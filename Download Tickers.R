
# We create a dataframe of the urls:
BORSE <- c("NYSE","NASDAQ","AMEX")
urls <- c("http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download",
          "http://www.nasdaq.com/screening/companies-by-industry.aspx?exchange=NASDAQ&render=download",
          "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download")
BORSE_URL <- data.frame(BORSE, urls, stringsAsFactors=F)

<<<<<<< HEAD
summary(datatb)
=======
#---------------------------------------------------------------------------------------------------------------------------

Y <- read.csv("http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download")
urls[1]
>>>>>>> b3fca39db039cfd058202e73a71732f7e4933601

# Then we go through every of urls and receive a combine list of all tickers on 3 exchanges
install.packages("data.table")

library(stringr)
library(dplyr)
library(data.table)
datalist<-NULL # clear datalist (just in case)
datatb<-NULL
datalist = lapply(BORSE_URL$urls, #creates list
                  FUN=fread, # fread from the package "DATA.TABLE" does it much faster than read.table 
                  header=TRUE)
datalist <- mapply(cbind, datalist , "Borse"=BORSE_URL$BORSE , SIMPLIFY=F) # add new column to every data.table in the list and fills it with the symbol
datatb = rbindlist(datalist, # merging rows of 3 lists in one
		   fill=TRUE) # we need "Fill=True" as there are some columns which appear only in 1 database
datatb[Borse=="NASDAQ",industry:=Industry] # there are 2 industry columns, named differently. We need to merge them.
setnames(datatb, make.names(colnames(datatb))) # this remove spaces from column names

datatb<- datatb[,list(Symbol,Name,Sector,industry, Summary.Quote,Borse)] # keeping only needed columns
datatb[,Summary.Quote:=str_replace(Summary.Quote,"https://www.nasdaq.com/symbol/","")] # xxx


datatb[,.(.N),by=.(Summary.Quote, Symbol)]
max(datatb[,.(.N),by=.(Summary.Quote, Symbol)]$N)

datatb[,.(.N),by=.(Summary.Quote, industry)]
max(datatb[,.(.N),by=.(Summary.Quote)]$N)


#----------------------------------------------------------------------------------------------------------


View(datatb)

# For now I don't reall see the need to download yahoo quotes. It is just an exercise.
# Now we could start the downloading of files with quotes to the hard drive

Test_Tickers <- datatb$Symbol[sample(1:length(datatb$Symbol),10,replace=T)] # we select 10 random tickers from our list
url_date <- "&a=11&b=16&c=2016&d=0&e=16&f=2017&g=d&ignore=.csv" # this is just the continuation of the link with dates
Path_Home <-"C:\\Users\\oleksander.anufriyev\\Documents\\R\\files\\"
Path_Work <-"L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\"
lapply(Test_Tickers, # for all selected tickers we apply the function "download.file"
	function(x) download.file(paste0("http://chart.finance.yahoo.com/table.csv?s=",x,url_date),
				   destfile = paste0(Path_Work,x,".csv"))
	)



#--------------------------------------------------------------------------------------------------------------------------------------
# Link to download the stock details looks like this: "http://download.finance.yahoo.com/d/quotes.csv?s=AAPL&f=sl1d1t1c1ohgv&e=.csv"
# The quantmod function "getQuote" allows to do it as well, but not transparent

# We create a dataframe of the YAHOO commands:
Indicator_Group <- c("General","General","General","General",
		     "Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat","Trading Stat",
		     "Real-time","Real-time","Real-time","Real-time","Real-time","Real-time","Real-time","Real-time",
		     "Share Stat","Share Stat","Share Stat",
		     "Financials: Income","Financials: Income","Financials: Income","Financials: Income","Financials: Income","Financials: Income",
		     "Dividends","Dividends","Dividends","Dividends",
		     "Valuation","Valuation","Valuation","Valuation","Valuation","Valuation","Valuation","Valuation","Valuation","Valuation",
		     "Check","Check","Check","Check","Check","Check","Check","Check")
Indicator_Name <- c("Symbol","Name","Stock Exchange","Currency",
		    "Bid","Ask","Previous Close","Open","Percent Change From 52-week High","Percent Change From 52-week Low","Day’s Range","Trade Date","High Limit","Low Limit","Last Trade (Price Only)","Last Trade (With Time)","Last Trade Date","Last Trade Size","Last Trade Time","Volume","Average Daily Volume","Bid Size","Ask Size","Short Ratio",
		    "Last Trade (Real-time) With Time","Change (Real-time)","Change Percent (Real-time)","Day’s Range (Real-time)","After Hours Change (Real-time)","Bid (Real-time)","Ask (Real-time)","Order Book (Real-time)",
		    "Float Shares","Shares Outstanding","Shares Owned",
		    "Earnings/Share","EPS Estimate Current Year","EPS Estimate Next Year","EPS Estimate Next Quarter","EBITDA","Revenue",
		    "Dividend/Share","Ex-Dividend Date","Dividend Pay Date","Dividend Yield",
		    "P/E Ratio","P/E Ratio (Real-time)","Price/EPS Estimate Current Year","Price/EPS Estimate Next Year","PEG Ratio","Price/Sales","Price/Book","Market Capitalization","Market Cap (Real-time)","Book Value",
		    "Commission","Error Indication (returned for symbol changed / invalid)","Trade Links Additional","More Info","Notes","Price Paid","Trade Links","Ticker Trend")
Indicator_YHOO_Code <- c("s","n","x","c4","b","a","p","o","k5","j6","m","d2","l2","l3","l1","l","d1","k3","t1","v","a2","b6","a5","s7","k1","c6","k2","m2","c8","b3","b2","i5","f6","j2","s1","e","e7","e8","e9","j4","s6","d","q","r1","y","r","r2","r6","r7","r5","p5","p6","j1","j3","b4","c3","e1","f0","i","n4","p1","t6","t7")
Indicator_YHOO <- data.table(Indicator_Group, Indicator_YHOO_Code, Indicator_Name, stringsAsFactors=F)

Indicator_YHOO[,paste(Indicator_YHOO_Code, collapse = ''),by=.(Indicator_Group)] # the "paste" command concatenates all yahoo codes


lapply(Test_Tickers,
	 function(x) download.file(paste0("http://download.finance.yahoo.com/d/quotes.csv?s=", # the url is different from the one we used to get quotes
               	  			   x,
			   	           "&f=",
					   Indicator_YHOO[Indicator_Group=="Real-time",paste(Indicator_YHOO_Code, collapse = '')], # an example to download only one group of indicators
					   "&e=.csv"),
				   destfile = paste0(Path_Work,x,".csv"))
	)




