install.packages("rvest")
library(rvest)

#Checking the chapters of Zorro
zorro_content <-"http://www.zorro-trader.com/manual/ht_contents.htm"
zorro_pages <- read_html(zorro_content) %>% html_nodes("a") %>% html_attr("href")

# Reading sample of Zorro pages
zorro_root<-"http://www.zorro-trader.com/manual/"
test<-zorro_pages[sample(1:length(zorro_pages),4,replace=T)] # taking a sample of pages
paste0(zorro_root,test) %>% 
  lapply(read_html) %>% 
  lapply(html_nodes, "li") %>%
  lapply(html_text) #Converting to text






read_html("http://www.zorro-trader.com/manual/en/testing.htm") %>% html_nodes("p") %>% html_text
