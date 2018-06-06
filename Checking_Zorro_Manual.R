library(dplyr) # use function "View"
View(Old_Zorro_Content)
View(New_Zorro_Content)
zorro_pages

#========================================================================================================
install.packages("rvest")
install.packages("googlesheets") # many other useful pkges are installed as well
install.packages("data.table")

library(rvest)

#Checking the chapters of Zorro
zorro_content <-"http://www.zorro-trader.com/manual/ht_contents.htm"
zorro_pages_links <- read_html(zorro_content) %>% html_nodes("a") %>% html_attr("href")
zorro_pages_names <- read_html(zorro_content) %>% html_nodes("a") %>% html_attr("title")
New_Zorro_Content <- data.table(zorro_pages_names,zorro_pages_links)

                                                                          
                                                                          
# Reading sample of Zorro pages
zorro_root<-"http://www.zorro-trader.com/manual/"
test<-zorro_pages[sample(1:length(zorro_pages),4,replace=T)] # taking a sample of pages
paste0(zorro_root,test) %>% 
  lapply(read_html) %>% 
  lapply(html_nodes, "li") %>%
  lapply(html_text) #Converting to text


#========================================================================================================

library(data.table)
library(googlesheets)
library(magrittr) # googlesheets pkg uses pipes

gs_ls() # this command delivers the URL, which you should enter into the browser and allow. You will get the key, which you need to paste in R.
Old_Zorro_Content <- gs_title("ZorroContent") %>% # If you plan to consume data from a sheet or edit it, you must first register it
                      gs_read(ws=1) %>%
                      as.data.table()  


#### ETF database is on google drive now (status Feb 2016)
id <- "0BxvMvfwI5rgZZ3YxdmlDaFZEVDA" # google file ID
ETFDB <- read.csv2(sprintf("https://docs.google.com/uc?id=%s&export=download", id),row.names = NULL)

#========================================================================================================

install.packages(c("dfCompare","dataCompareR"))
library(dfCompare)
library(dataCompareR)

x <- rCompare(Old_Zorro_Content, New_Zorro_Content) # returns an S3 object
summary(x)
rCompare(Old_Zorro_Content, New_Zorro_Content,keys="zorro_pages_names")# used if number of rows is the same. To comare values
dfCompare(Old_Zorro_Content, New_Zorro_Content,key="zorro_pages_names")






read_html("http://www.zorro-trader.com/manual/en/testing.htm") %>% html_nodes("p") %>% html_text
