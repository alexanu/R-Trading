
# script shows info about github repos of a user

install.packages("librarian")
librarian::shelf(jsonlite, httr, magrittr, data.table)

username<-"16149724"

# shortcut for looking at more than 100 repos. Just 2 pages. Could be implemented nicer
pages <- c(sprintf("https://api.github.com/user/%s/repos?per_page=100&page=%s", username,1),
           sprintf("https://api.github.com/user/%s/repos?per_page=100&page=%s", username,2))


parsing_git <- function(url){
                  url %>%
                  GET() %>%
                  content() %>%
                  jsonlite::toJSON() %>%
                  jsonlite::fromJSON() %>% # names() will show which field ar e available
                  as.data.table() %>%   
                  .[,c("id","name","size","description","created_at","updated_at","pushed_at","html_url","forks_count")]
  }
lapply(pages,parsing_git) %>% rbindlist() -> REPOS 

# if there is no description for the repo, fwrite cause problems. But we could play with sep2
fwrite(REPOS, file="repos.csv",sep="|", sep2=c("",",","")) # in sep2 1st and 3rd argument are the beginning and end of list



  