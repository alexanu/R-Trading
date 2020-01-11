library(dplyr) # use function "View"
View(Old_Zorro_Content)
View(New_Zorro_Content)
zorro_pages
library()
Test_Z_Links


#========================================================================================================
install.packages(c("rvest","googlesheets","data.table"))


library(rvest)

#Checking the chapters of Zorro
zorro_content <-"http://www.zorro-trader.com/manual/ht_contents.htm"
zorro_pages_links <- read_html(zorro_content) %>% html_nodes("a") %>% html_attr("href")
zorro_pages_names <- read_html(zorro_content) %>% html_nodes("a") %>% html_attr("title")
New_Zorro_Content <- data.table(zorro_pages_names,zorro_pages_links)

gs_ls() # this command delivers the URL, which you should enter into the browser and allow. You will get the key, which you need to paste in R.
Old_Zorro_Content <- gs_title("ZorroContent") %>% # If you plan to consume data from a sheet or edit it, you must first register it
  gs_read(ws=1) %>%
  as.data.table()  


library(dfCompare)
dfCompare(Old_Zorro_Content, New_Zorro_Content,key="zorro_pages_names") # comparing old and new content


#install.packages(c("dfCompare","dataCompareR"))
#library(dataCompareR)
#x <- rCompare(Old_Zorro_Content, New_Zorro_Content) # returns an S3 object
#summary(x)
#rCompare(Old_Zorro_Content, New_Zorro_Content,keys="zorro_pages_names")# used if number of rows is the same. To comare values


#========================================================================================================

library(stringr)

zorro_root<-"http://www.zorro-trader.com/manual/"
Test_Z_Links <- New_Zorro_Content[sample(1:nrow(New_Zorro_Content), 4, replace=T),2] %>% unlist() %>% as.character()


paste0(zorro_root,Test_Z_Links) %>% lapply(read_html) %>% lapply(html_nodes("h2")) %>% lapply(html_text)



h2_text <- function(x) {x %>% read_html() %>% html_nodes("h2") %>% html_text()}
check <- sapply(paste0(zorro_root,Test_Z_Links),h2_text)
check


read_html(paste0(zorro_root,Test_Z_Links))%>% 
  html_nodes("h2") %>% # seems to cover the small header which introduce different z functions
  html_text 





read_html("http://www.zorro-trader.com/manual/en/testing.htm") %>% html_nodes("p") %>% html_text

read_html("http://www.zorro-trader.com/manual/en/profile.htm") %>% html_nodes("p") %>% html_text
View(read_html("http://www.zorro-trader.com/manual/en/profile.htm") %>% html_text)


read_html("http://www.zorro-trader.com/manual/en/profile.htm") %>% 
          html_nodes("h2") %>% # seems to cover the small header which introduce different z functions
          html_text 





read_html("http://www.zorro-trader.com/manual/en/ig.htm") %>% 
          html_nodes("li") %>% # seems to cover the small header which introduce different z functions
          html_text 

read_html("http://www.zorro-trader.com/manual/en/ig.htm") %>% html_text %>% str_split('\n')


read_html("http://www.zorro-trader.com/manual/en/profile.htm") %>% html_name 




str_split


#========================================================================================================

install.packages("mailR")
library(mailR)

sender <- "xxxx@gmail.com"
recipients <- c("xxxxx@gmail.com") # Replace with one or more valid addresses
email <- send.mail(from = sender,
                   to = recipients,
                   subject="KuUKu",
                   body = "testirovanie",
                   html = TRUE,
                   smtp = list(host.name = "smtp.gmail.com",
                               port = 465, 
                               user.name="xxx@gmail.com", 
                               passwd="xxxxxx",
                               ssl = TRUE),                   
                   authenticate = TRUE,
                   attach.files = "./1.xlsx",
                   send = TRUE,
                   debug = TRUE)


getwd()



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








