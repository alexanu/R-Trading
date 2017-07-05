# Quandl

library(data.table)
install.packages("googlesheets") # many other useful pkges are installed as well
install.packages("data.table")



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
