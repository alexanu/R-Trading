install.packages(c("httr", "jsonlite", "lubridate"))
library(httr) # allows for easy crafting of API calls
library(jsonlite) # API usually answers in JSON format. The package translates JSON’s nested data structures into  R objects
library(lubridate)

options(stringsAsFactors = FALSE) # turns off the R feature of turning strigsinto factors

url  <- "http://api.epdb.eu"
path <- "eurlex/directory_code"
raw.result <- GET(url = url, path = path) # Executing an API call
names(raw.result) # explore what we’ve got back
# The result we got back from the API is a list of length 10. 
# Of these, two parts are important:
# 1) status_code that tells us, if the call worked network-wise.
# 2) content the API’s answer in raw binary code, not text. 

raw.result$status_code # examine the status code
# we see that we’ve got 200, which means, all worked out fine. 
# This status code only tells us, that the server recieved our request,
# not if it was valid for the API or found any data.

head(raw.result$content) 
# That’s useless, unless you speak Unicode. =>
# => Let’s translate that into text.
this.raw.content <- rawToChar(raw.result$content)
substr(this.raw.content, 1, 100) # look at the first 100 characters
# So the result is a single character string that contains a JSON file.
this.content <- fromJSON(this.raw.content) # parse JSON into R objects.
class(this.content) # the result is a list of lists
this.content[[1]]

this.content.df <- do.call(what = "rbind", # combine them all together into a single data frame
                           args = lapply(this.content, as.data.frame)) # turns each of the 462 list elements into mini single-row data frames