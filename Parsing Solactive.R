install.packages("rvest")
library(rvest)

Solactive_URL <-"https://www.solactive.com/indices/"
Solactive_indices <- read_html(Solactive_URL) %>% 
                     html_nodes("td.name.sorting_1") %>% 
                     html_attr("href")

Solactive_indices <- read_html(Solactive_URL) %>% 
  html_nodes("tr.td.name sorting_1") %>% 
  html_text()

#DataTables_Table_0 > tbody > tr:nth-child(3) > td.name.sorting_1 > a

Solactive_indices<-NULL
Solactive_indices


install.packages("XML")
library(XML)
readHTMLTable(Solactive_URL)



//*[@id="DataTables_Table_0"]/tbody/tr[3]/td[1]/a
# Reading sample of Zorro pages
zorro_root<-"http://www.zorro-trader.com/manual/"
test<-zorro_pages[sample(1:length(zorro_pages),4,replace=T)] # taking a sample of pages
paste0(zorro_root,test) %>% 
  lapply(read_html) %>% 
  lapply(html_nodes, "li") %>%
  lapply(html_text) #Converting to text


