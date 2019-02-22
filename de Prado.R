


Path <- "\\\\WWG00M.ROOTDOM.NET/DFS/HOME/G107980/ICM/Desktop/1/Programming/R/tick_data/IVE_tickbidask.txt"
x<-fread(Path)
head(x)
summary(x)

x <- fread(Path,colClasses=c("numeric")) %>% 
					.[, `:=`(Date= paste(V1,V2,sep=" ")%>% lubridate::parse_date_time2("m/d/Y HMS"),
						   V1=NULL,
						   V2=NULL)]

y <- fread("http://api.kibot.com/?action=history&symbol=IVE&interval=tickbidask&bp=1&user=guest")
