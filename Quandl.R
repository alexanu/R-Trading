# Quandl

install.packages("Quandl")
library(Quandl)
library(data.table)


library(googlesheets)

search()
library()

install.packages("devtools")
devtools::install_github("jennybc/googlesheets")
require(googlesheets)

version

# If you would like to make more than 50 calls a day, 
# however, you will need to create a free Quandl account and set your API key
QUANDL_API_KEY="U8tm97CPG1YbezAfqmvD"
Quandl.api_key(QUANDL_API_KEY) 

head(Quandl("FRED/GDP", type="raw"))
head(Quandl("FRED/GDP", type="ts"))
head(Quandl("FRED/GDP", type="xts"))
head(Quandl("FRED/GDP", type="zoo"))


tail(Quandl(c("FRED/GDP.1", "WIKI/AAPL.4")))
tail(Quandl(c("FRED/GDP", 
              "WIKI/AAPL")))
tail(Quandl("WIKI/AAPL",type="zoo"))
Quandl.datatable("ZACKS/FC", ticker="AAPL")[1:6]
tail(Quandl.datatable("ZACKS/P", ticker="AAPL"))


data <- fread("https://www.quandl.com/api/v3/datasets.csv?database_code=FSE&per_page=100&sort_by=id&page=1&api_key=U8tm97CPG1YbezAfqmvD")
data <- fread("https://www.quandl.com/api/v3/datasets.csv?database_code=FSE&per_page=100&sort_by=id&page=2&api_key=U8tm97CPG1YbezAfqmvD")
pages <- c("1","2")
Source <- c("WIKI", "LME", "CME", "ZILL", "FRED", "LBMA", "TSE", "NSE", "ODA", "YALE", "CBOE", "FSE", "MULTPL", "URC", "ML", "LJUBSE", "RBNZ")
QUANDL_API_KEY="U8tm97CPG1YbezAfqmvD"


Instruments <- lapply(sprintf("https://www.quandl.com/api/v3/datasets.csv?database_code=%s&per_page=100&sort_by=id&page=1",Source),
             FUN=fread,
             stringsAsFactors=FALSE)
Instruments <- do.call(rbind, Instruments)
write.csv(Instruments,file="Example.csv")

getwd()
expand.grid("https://www.quandl.com/api/v3/datasets.csv?database_code=",Source,"&per_page=100&sort_by=id&page=",pages)




install.packages("readr")
library(readr)
WIKI <- read_file_raw("https://www.quandl.com/api/v3/databases/WIKI/codes")
head(WIKI)



tf <- tempfile()
td <- tempdir()
download.file("https://www.quandl.com/api/v3/databases/OSE/codes",tf, mode="wb")
dd <- fread(unzip(tf), header=F)
head(dd)






myData <- Quandl.datatable("WIKI/PRICES")
tail(myData)
Short_interest <-read.table("https://www.quandl.com/api/v3/databases/SI/codes", fileEncoding="UTF-16LE")
head(Short_interest)
