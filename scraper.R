# Scraper
library(rvest)
library(tidyverse)
library(RSelenium)
library(beepr)
library(netstat)

main <- function(url, n_pages, filename, sleep_seconds) {
  # Start Selenium, assign to global environment
  rD <<- rsDriver(browser=c("chrome"), chromever = "86.0.4240.22", port = netstat::free_port())
  client <<- rD$client
  
  ## Run first round, check n pages back
  check_n_pages(url, n_pages, filename)
  
  ## Start loop, function run()
  message(paste0(
    "Påbegynder løkke klokken ", format(Sys.time(), "%H:%M:%S"), ". ",
    "Tjekker hvert ", sleep_seconds, ". sekund."
  ))
  
  run(url, filename, sleep_seconds, n_loop = 1)
}

run <- function(url, filename, sleep_seconds, n_loop) {
  tryCatch(
    {
      check_page(url, filename)
      cat(paste0(n_loop, "\t"))
    },
    warning = function(e) {
      cat(paste0("(X)", "\t"))
    }
  )
  
  Sys.sleep(sleep_seconds)
  run(url, filename, sleep_seconds, n_loop+1)
}

check_n_pages <- function(url, n_pages, filename) {
  if (n_pages <= 0) return()
  
  message(paste("Henter første", n_pages, "sider"))
  
  url_list <- paste0(url, "&startRecord=", 0:(n_pages-1)*18)
  map(url_list, check_page, filename)

  message("Færdig med at tjekke første sider.")
}

# Navigates to url. Checks 5 times spaced by 2 seconds. 
# If page not loaded within 10 seconds, returns warning.
# If page loads, call check_new
check_page <- function(url, filename) {
  df <- NULL
  client$navigate(url)
  for (i in 1:5) {
    Sys.sleep(2)
    df <- tryCatch(parsepage(), warning = function(e) NULL)
    if (!is.null(df)) break()
  }
  if (is.null(df)) {warning("err"); return()}
  check_new(df, filename, goto = url)
}

parsepage <- function() {
  adcards <- client$getPageSource()[[1]] %>% 
    read_html() %>% 
    html_nodes(".PropertyList") %>% 
    html_nodes(".RentalCard")
  
  title <- adcards %>% html_nodes(".RentalCard__title") %>% html_text()
  price <- adcards %>% html_nodes(".RentalCard__price") %>% html_text() %>%
    map_dbl(parse_number, locale=locale(grouping_mark=". ", decimal_mark=","))
  loc <- adcards %>% html_nodes(".RentalCard__location") %>% html_text()
  desc <- adcards %>% html_nodes(".RentalCard__description") %>% html_text()
  link <- adcards %>% html_attr('href') %>% map_chr(~paste0("https://www.boligportal.dk", .x))
  
  tibble(title, price, loc, link, desc, date = Sys.time())
}

check_new <- function(df, filename, goto = NULL) {
  ## Load CSV file, seen apartments
  seen_links <- tryCatch(
    read_csv(filename,
      col_types = list(  title = col_character(),
                         price = col_double(),
                         loc = col_character(),
                         desc = col_character(),
                         link = col_character(),
                         date = col_datetime(format = ""))
    )$link,
    error = function(e) NULL)
  
  new <- df %>% 
    filter(!(link %in% seen_links))
  
  if(nrow(new)) {
    beep(5)
    new %>% write_csv(filename, append = !is.null(seen_links))
    
    ## Open URL of new listings in browser
    if (nrow(new) > 3 & !is.null(goto)) {
      browseURL(goto)
    } else {
      map(new$link, browseURL)
    }
    
    print_apartments(new)
  }
}

print_apartments <- function(df) {
  for (i in 1:nrow(df)) {
    ap <- df[i,]
    
    message("")
    message(ap$title)
    message(paste(rep("-", 50), collapse = ""))
    message(paste("Pris:", ap$price))
    message(paste("Sted:", ap$loc))
    message(paste("Link:", ap$link))
    message(paste("Tid: ", ap$date))
    message("")
  }
}