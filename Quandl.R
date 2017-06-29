# Quandl

library(data.table)
install.packages("googlesheets") # many other useful pkges are installed as well
install.packages("data.table")



library(googlesheets)
library(magrittr) # googlesheets pkg uses pipes
gs_ls() # this command delivers the URL, which you should enter into the browser and allow. You will get the key, which you need to paste in R.

Quandl_DB <- gs_title("Quandl_DB") %>% # If you plan to consume data from a sheet or edit it, you must first register it
                gs_read(ws=1,range = cell_rows(4:200) ) %>%
                  as.data.table()  
setnames(Quandl_DB, make.names(colnames(Quandl_DB))) # this remove spaces from column names
Quandl_DB <- Quandl_DB[Status=="1"& Max.pages<70, # restrcting only to needed sources
                       c(1:4,9)] # keeping only the needed columns





install.packages("Quandl")
library(Quandl)

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
