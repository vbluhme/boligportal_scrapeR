source("scraper.R")

## Config
# URL for search results. Encodes location, max rent, etc.
url <- "https://www.boligportal.dk/find?placeIds=49%2C14%2C24%2C365%2C106%2C19%2C44%2C817&housingTypes=3&minRooms=2&maxRent=11000&minRentalPeriod=3"

# File for storing table of seen properties
filename <- "set.csv"

# Number of pages to check on init. Set to 0 to begin loop immediately.
n_pages <- 0

# Sleep between refresh
sleep_seconds <- 10

# If Selenium breaks down (usually due to a lost internet connection),
# wait 60 seconds and launch again from scratch.
f <- function() {
  tryCatch(
    {
      main(url, n_pages, filename, sleep_seconds)
    },
    error = function(e) {
      message("Fejl. Genstarter om 60 sekunder.")
      Sys.sleep(60)
      f()
    }
  )
}

f()