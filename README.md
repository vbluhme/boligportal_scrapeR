# boligportal_scrapeR
A simple web scraper for boligportal.dk written in R using Selenium. Written for personal use.

Required packages: `c("tidyverse", "rvest", "RSelenium", "beepr", "netstat")`

Search parameters are encoded in `url`, so set your desired parameters at https://www.boligportal.dk/find and copy the url into `main.R`. To initialise, run `main.R`. When first initialised, scraper checks `n_pages` back. It then checks `url` for new listings recursively, sleeping for `sleep_seconds` seconds between refreshes.

When a new listing is found, the scraper:
- Adds the listing to the `set.csv` file of seen listings. If this file does not exist, it is created.
- Opens the boligportal.dk listing in the standard browser. If there are more than 3 new listings on the page, opens the results page instead.
- Prints basic information about the listing to terminal.
- Plays an annoying notification sound using the `beepr` 📦 package.
