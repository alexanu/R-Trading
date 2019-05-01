install.packages("remotes")
remotes::install_github("DesiQuintans/librarian")
librarian::shelf(readr, feather, data.table,readit,ggplot2,magrittr, 
                 fasttime, lubridate, anytime,
                 rvest, googledrive, tidyverse/googlesheets4,dfCompare, dplyr)

# ------------------

x <- drive_get("Quantpedia")$id %>% read_sheet() %>% as.data.table()

main <- "https://quantpedia.com/screener/Details/"
needed <- x[Premium=="No"]$ID
parsing_quantpedia <- function(str_num){
  raw_data <- paste0(main,str_num) %>% read_html() 
  x <-  raw_data  %>% html_nodes("p") %>% html_text() %>% as.data.table()
  x$.<-substr(x$.,0,15)
  h2 <- raw_data %>% html_nodes("h2") %>% html_text() %>% as.data.table()
  data <- rbindlist(list(list(c("skip","Introduction")),h2[c(1,3:6),]))
  data <-data[,':='(text=x$.,strategy=str_num)]  
}
lapply(needed,parsing_quantpedia) %>% rbindlist() %>% .[.!="skip"] %>% setnames(1, 'Section')-> REPOS 
View(REPOS)
fwrite(x,"1.csv")
