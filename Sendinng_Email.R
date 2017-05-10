
install.packages("mailR")
library(mailR)

sender <- "oanufriyev@gmail.com"
recipients <- c("volytska@gmail.com") # Replace with one or more valid addresses
email <- send.mail(from = sender,
                   to = recipients,
                   subject="KuUKu",
                   body = "testirovanie",
                   html = TRUE,
                   smtp = list(host.name = "smtp.gmail.com",
                               port = 465, 
                               user.name="oanufriyev@gmail.com", 
                               passwd="Theanswer1",
                               ssl = TRUE),                   
                   authenticate = TRUE,
                   attach.files = "./1.xlsx",
                   send = TRUE,
                   debug = TRUE)


getwd()
