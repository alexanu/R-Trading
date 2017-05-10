search()
install.packages("TTR")
install.packages("PerformanceAnalytics")
install.packages("stocks")
library(TTR)
library(quantmod)
library(PerformanceAnalytics)
library(stocks)
periodReturn
Delt
getSymbols("SPY", from=Sys.Date()-10)
SPY
ret <-cbind(Ad(SPY),
            ROC(Ad(SPY)), # Package: TTR
            periodReturn(Ad(SPY), period = "daily"), # Package: quantmod
            Delt(Ad(SPY)), # Package: quantmod
            as.xts(balances(Ad(SPY)))
)
class(ret)
pchanges(Ad(SPY))

http://chart.finance.yahoo.com/table.csv?_
s=FB_
&a=11_
&b=12_
&c=2016_
&d=0_
&e=12_
&f=2017_
&g=d_
&ignore=.csv

str1 <- "http://ichart.finance.yahoo.com/table.csv?s="
str3 <- paste("&a=", a, "&b=", b, "&c=", c, "&d=", d, "&e=", e, "&f=", f, "&g=d&ignore=.csv", sep="")

# Main loop for all assets
for (i in seq(1,length(tickers),1))
{
  str2 <- tickers[i]
  strx <- paste(str1,str2,str3,sep="")
