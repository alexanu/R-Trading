install.packages("XML")
install.packages("stringr")
install.packages("RCurl")
install.packages("httr")

library(RCurl)
library(stringr)
library(XML)
library(httr)
library(curl)

install.packages("curl")

url <- "http://www.boerse-frankfurt.de/etp/etp-finder?freetext=&etptype=&issuer=&benchmark=&listingdate="

parsed_doc <- GET(url)
	
parsed_doc <- getURL(url)

parsed_doc <- readHTMLTable(url)
#print(parsed_doc) #here head functions doesn't work as it is string doc
parsed_doc <- htmlParse(url)



ETFS <- as.data.frame(readHTMLTable(parsed_doc))["etfs.Symbol"]
etf.list <- as.character(ETFS[,1])



ETF <- xpathSApply(parsed_doc, "//tr", xmlSize)

ETF2 <- xpathSApply(parsed_doc, "//tr", xmlGetAttr, "id")

ETF2 <- str_replace_all(ETF2, "etf_", "")
#print(ETF2)
