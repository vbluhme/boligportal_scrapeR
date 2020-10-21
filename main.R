source("scraper.R")

## Config
# URL for search results. Encodes location, max rent, etc.
url <- "https://www.boligportal.dk/find?placeIds=49%2C14%2C24%2C365%2C106%2C19%2C44%2C817&housingTypes=3&minRooms=2&maxRent=13000&minRentalPeriod=3"

# File for storing table of seen properties
filename <- "set.csv"

# Number of pages to check on init. Set to 0 to begin loop immediately.
n_pages <- 0

# Sleep between refresh
sleep_seconds <- 10

main(url, n_pages, filename, sleep_seconds)