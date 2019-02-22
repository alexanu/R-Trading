
#--------------------------------------------------------------------------------------------------

# Get a tidy data frame of information about all of your Github stars (repos you've starred)
# Initial source: https://gist.github.com/mkearney/be9e7a7f69adb0768b720cc64d9b35f6


library(magrittr)
library(data.table)
library(rvest)

## function to convert GH count format to numeric
	detruncnum <- function(x) {
		if (length(x) == 0) return(x)
		k <- grepl("k$", x)
		x <- sub("k$", "", x) %>% as.numeric()
		x[k] <- x[k] * 1000
		x
		}

username<-"alexanu"


## get the number of starred repos
	stars_url <- sprintf("https://github.com/%s?tab=stars", username)
	s <- xml2::read_html(stars_url)
	num_stars <- rvest::html_nodes(s, "span.Counter") %>%
				rvest::html_text(trim = TRUE) %>%
				detruncnum() %>%
				.[2]

		## initialize output vector
			n_pages <- ceiling(num_stars / 30) # divide by 30 to get estimated number of pages
			stars_data <- init_list(n_pages)
			tfse::print_start("Looping through ", n_pages, " pages (about ", num_stars, " stars) of repos...")

		## for loop through the pages, breaking on error
			for (i in seq_along(stars_data)) {
				stars_data[[i]] <- tryCatch(
								parse_stars_page(stars_url), # fetch page and convert to tbl_df
								error = function(e) NULL)
				if (is.null(stars_data[[i]])) break # break on error
				tfse::print_complete("Page ", i, "/", n_pages, " complete!")
				stars_url <- next_link(stars_data[[i]]) # update stars_url (pagination)
				if (length(stars_url) == 0) break # if there's not a next_link then break
				}

		## return stars data (as data frame if possible)
			tryCatch(
				do_call_rbind(stars_data),
				error = function(e) stars_data
				)
		}













#-------------------------------------------------------------------------------------
# function to convert html page into stars data frame
parse_stars_page <- function(url) {
	s <- xml2::read_html(url)   # read as xml
	strs <- rvest::html_nodes(s, ".col-12.d-block.width-full.py-4.border-bottom")  ## each strs node

	repo <- rvest::html_node(strs, "h3 a") %>%
			rvest::html_attr("href") %>%
			sub("^/", "", .)

	gh_url <- paste0("https://github.com/", repo)
	user <- sub("/.*", "", repo)
	repo <- tfse::regmatches_first(repo, "(?<=/).*") # simplify to name of repo

	description <- rvest::html_node(strs, "div.py-1 p") %>%   # description of repo
    			   rvest::html_text(trim = TRUE)

	lang <- rvest::html_node(strs, "span.mr-3") %>% # repo language
    		  rvest::html_text(trim = TRUE)

	# for repos that don't have langs
		wout_lang_stars <- strs %>%
					rvest::html_node(".f6.text-gray.mt-2 a:nth-child(1)") %>%
					rvest::html_text(trim = TRUE) %>%
					gsub("\\,", "", .) %>%
					(function(.) suppressWarnings(as.integer(.)))

		wout_lang_forks <- strs %>%
					rvest::html_node(".f6.text-gray.mt-2 a:nth-child(2)") %>%
					rvest::html_text(trim = TRUE) %>%
					gsub("\\,", "", .) %>%
					(function(.) suppressWarnings(as.integer(.)))

	# for repos that do have langs
		with_lang_stars <- strs %>%
					rvest::html_node(".f6.text-gray.mt-2 a:nth-child(3)") %>%
					rvest::html_text(trim = TRUE) %>%
					gsub("\\,", "", .) %>%
					(function(.) suppressWarnings(as.integer(.)))
		with_lang_forks <- strs %>%
					rvest::html_node(".f6.text-gray.mt-2 a:nth-child(4)") %>%
					rvest::html_text(trim = TRUE) %>%
					gsub("\\,", "", .) %>%
					(function(.) suppressWarnings(as.integer(.)))

	## star count and fork count
	star_count <- ifelse(!is.na(lang), with_lang_stars, wout_lang_stars)
	fork_count <- ifelse(!is.na(lang), with_lang_forks, wout_lang_forks)
	fork_count[is.na(fork_count)] <- 0L

	## store as data set
	d <- tfse::data_set(
				user = user,
				repo = repo,
				lang = lang,
				description = description,
				stars = star_count,
				forks = fork_count,
				url = gh_url)

	## parse next link
	next_link <- s %>%
			as.character() %>%
			tfse::regmatches_('(?<=href=")https://github\\.com/\\S+\\?after[^"]+(?=")') %>%
			unlist() %>%
			grep("direction=", ., invert = TRUE, value = TRUE)

	attr(d, "next_link") <- next_link # store as attribute

	d
}


#----------------------------------------------------------------------------------------------------------------

## function to return next_link attribute
next_link <- function(x) attr(x, "next_link")

## function to initialize list vector
init_list <- function(n = 0) vector("list", n)

## function to convert GH count format to numeric
detruncnum <- function(x) {
  if (length(x) == 0) return(x)
  k <- grepl("k$", x)
  x <- sub("k$", "", x) %>% as.numeric()
  x[k] <- x[k] * 1000
  x
}

## function to bind rows
do_call_rbind <- function(x) {
  do.call("rbind", x[lengths(x) > 0], quote = TRUE)
}

#----------------------------------------------------------------------------------------------------------------

## big function to get all stars data
get_stars_data <- function(username) {

		## get the number of starred repos
			stars_url <- sprintf("https://github.com/%s?tab=stars", username)
			s <- xml2::read_html(stars_url)
			num_stars <- rvest::html_nodes(s, "span.Counter") %>%
					rvest::html_text(trim = TRUE) %>%
					detruncnum() %>%
					.[2]

		## initialize output vector
			n_pages <- ceiling(num_stars / 30) # divide by 30 to get estimated number of pages
			stars_data <- init_list(n_pages)
			tfse::print_start("Looping through ", n_pages, " pages (about ", num_stars, " stars) of repos...")

		## for loop through the pages, breaking on error
			for (i in seq_along(stars_data)) {
				stars_data[[i]] <- tryCatch(
								parse_stars_page(stars_url), # fetch page and convert to tbl_df
								error = function(e) NULL)
				if (is.null(stars_data[[i]])) break # break on error
				tfse::print_complete("Page ", i, "/", n_pages, " complete!")
				stars_url <- next_link(stars_data[[i]]) # update stars_url (pagination)
				if (length(stars_url) == 0) break # if there's not a next_link then break
				}

		## return stars data (as data frame if possible)
			tryCatch(
				do_call_rbind(stars_data),
				error = function(e) stars_data
				)
		}



##----------------------------------------------------------------------------##
##                          ENTER YOUR USERNAME HERE                          ##
##----------------------------------------------------------------------------##

## replace my Github username with yours to get your starred repo data
stars_data <- get_stars_data("mkearney")

## number of starred repos by user
stars_data %>%
  tbltools::tabsort(user) %>%
  print(n = 20)

## number of starred repos by lang
stars_data %>%
  tbltools::tabsort(lang) %>%
  print(n = 20)

## number of starred repos by user and lang
stars_data %>%
  tbltools::tabsort(lang, user)

## most common repo names
stars_data %>%
  tbltools::tabsort(repo)

## average number of stars and forks by user
stars_data %>%
  dplyr::group_by(user) %>%
  dplyr::summarise(stars = mean(stars), forks = mean(forks), n = dplyr::n()) %>%
  tbltools::arrange_rows(stars, forks) %>%
  dplyr::filter(n > 2) %>%
print(n = 20)
