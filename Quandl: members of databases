# I have the list of needed Quandl databases on the google drive.
# The code reads this file and downloads all the members of these databases, parks them in 1 csv file
# The code skips very big databases: max is 10000 members per database


install.packages("googlesheets") # many other useful pkges are installed as well
install.packages("data.table")

library(data.table)
library(googlesheets)
library(magrittr) # googlesheets pkg uses pipes
gs_ls() # this command delivers the URL, which you should enter into the browser and allow. You will get the key, which you need to paste in R.

Quandl_DB <- gs_title("Quandl_DB") %>% # If you plan to consume data from a sheet or edit it, you must first register it
                gs_read(ws=1,range = cell_rows(4:200) ) %>%
                  as.data.table()  
                  

################################# AT WORK ###################################################################

Path <- "L:\\AGCS\\CFO\\Metadata\\For 2013\\Weight table\\QUANDL" # The directory where all the tick data files are stored
File <- "Quandl_source.csv"
Quandl_DB <- fread(paste0(Path, "\\",File))

##############################################################################################################

setnames(Quandl_DB, make.names(colnames(Quandl_DB))) # this remove spaces from column names
Quandl_DB <- Quandl_DB[Status=="1"& Max.pages<100, # restrcting only to needed sources
                       c(1:4,9)] # keeping only the needed columns
Source <- Quandl_DB[,4] %>% unlist() %>% as.character()
Max_Pages <- Quandl_DB[,5] %>% unlist() %>% as.integer()
Indicators_URL <- paste0(rep(sprintf("https://www.quandl.com/api/v3/datasets.csv?database_code=%s&per_page=100&sort_by=id&page=", # this the url for getting the database elements
                                     Source), # creating 1 url per source
                             Max_Pages), # how many times to repeat each url
                          sequence(Max_Pages)) # concatenate each url with the page number
Instruments <- lapply(Indicators_URL, 
                      function(x) tryCatch( # tryCatch is used for "if error then" ... 
                                          fread(x, stringsAsFactors=FALSE),
                                          error=function(e) NULL)) 
Instruments <- do.call(rbind, Instruments)
write.csv(Instruments,file="Quandl_DB.csv")
