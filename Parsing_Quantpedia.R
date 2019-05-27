install.packages("remotes")
remotes::install_github("DesiQuintans/librarian")
librarian::shelf(readr, feather, data.table,readit,ggplot2,magrittr, 
                 fasttime, lubridate, anytime, stringr,
                 googledrive, tidyverse/googlesheets4,dfCompare, dplyr, rapportools,
                 rvest, ropensci/RSelenium)

# ------------------

# reading the list of strategies from gdrive
x <- drive_get("Quantpedia")$id %>% read_sheet() %>% as.data.table()
names(x) <- make.names(names(x)) # put "." instead of spaces to the names
x$Sharpe.Ratio[rapportools::is.empty(x$Sharpe.Ratio)] <-0 
# there was a problem with uploading a data.table to GDrive, which have empty cells
x[,':='(Sharpe.Ratio=as.numeric(Sharpe.Ratio),
        Number.Of.Instruments=as.character(Number.Of.Instruments))]


# login in
UserName <- "xxxxx"
Password <- "xxxxx"
login_page <- 'https://quantpedia.com/Account/LogOn'
pgsession<-html_session(login_page)
pgform<-html_form(pgsession)[[3]]  #in this case the submit is the 3rd form
filled_form<-set_values(pgform, UserName = UserName, Password = Password)
submit_form(pgsession, filled_form)


main <- "https://quantpedia.com/screener/Details/"
#needed <- x[Premium=="Yes"]$ID[11:30] # selecting only free strategies for testing
needed <- x$ID
parsing_quantpedia <- function(str_num){
  raw_data <- paste0(main,str_num) %>% jump_to(pgsession, .) %>% read_html() 
  x <-  raw_data  %>% html_nodes("p") %>% # main textt is in in "p"
        html_text() %>% as.data.table()
  h2 <- raw_data %>% html_nodes("h2") %>% # chapter headers are in "h2"
        html_text() %>% as.data.table()
  data <- rbindlist(list(list(c("skip","Introduction")),h2[c(1,3:6),])) # adding 2 new headers
  data <-data[,':='(text=x$.,ID=str_num)] %>% tryCatch(., error=function(e) NULL)  
}

lapply(needed,parsing_quantpedia) %>% 
  rbindlist() %>% 
  setnames(1, 'Section')%>%
  dcast(., ID ~ Section, value.var="text") %>% # transpose
  .[,':='(skip=NULL, "Other Papers" = NULL)]-> REPOS 

x <- merge(x,REPOS, all=TRUE, by="ID") # adding parsed data to initial table

write.csv(x, "strategies.csv") 

View(x)

############ reading only links #######################################################

page <- "https://quantpedia.com/screener/Details/7"
links <- page %>% read_html() %>% html_nodes("a") %>% html_attr("href") %>% 
         as.data.table() %>%
         .[grep("http", .)] # leaving only rows, which contain http

#######  pasring all papers used for strategies #######################################

parsing_quantpedia_papers <- function(str_num){
    raw_data <- paste0(main,str_num) %>% read_html() %>% html_nodes("p") %>% .[7] 
    xml_find_all(pg, ".//br") %>% xml_add_sibling("p", "\n")
    xml_find_all(pg, ".//br") %>% xml_remove()
    dt <- html_text(pg) %>% 
          str_split("\n\n") %>% # split as string
          as.data.table() %>%
          .[, c("Paper", "URL","skip","Abstract"):=tstrsplit(V1, "\n", fixed = TRUE)] %>% # spliting a string into columns with a separator
          .[,':='(ID=str_num, V1 = NULL, skip = NULL)] # keeping only need columns
}

all_papers <- lapply(needed,parsing_quantpedia_papers) %>% rbindlist()
View(all_papers)
all_papers[,.N, by="URL"] # .N stands for just number of lines


View(dt)

