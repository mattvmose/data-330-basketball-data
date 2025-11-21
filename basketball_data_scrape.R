# basketball_data_scrape.R

library(dplyr)
library(readr)

#Downloading data
url <- "https://kenpom.com/cbbga26.txt"
raw_data <- read.fwf(url,
                     widths = c(10, 25, 3, 23, 4),
                     col.names=c("Date", "Away_Team", "Away_Score", "Home_Team", "Home_Score"),
                     stringsAsFactors=FALSE)

#Clean data and only keep relevant columns
games <- raw_data |>
  select(Date, Away_Score, Home_Score) |>
  mutate(
    Away_Score = as.numeric(Away_Score),
    Home_Score = as.numeric(Home_Score)
  )
games$Date <- as.Date(raw_data$Date, format="%m/%d/%Y")

#Summarise by game date
summary <- games |>
  group_by(Date) |>
  summarise(
    Total_Away = sum(Away_Score, na.rm=TRUE),
    Total_Home = sum(Home_Score, na.rm=TRUE),
    Games = n(),
    Avg_Points = (as.double(Total_Away)+as.double(Total_Home))/as.double(Games),
    .groups="drop"
  )

# Append to CSV
output_file <- "basketball_data/kenpom_summary.csv"
if(!dir.exists("basketball_data")) {
  dir.create("basketball_data")
}
if(file.exists(output_file)) {
  existing <- read_csv(output_file)
  combined <- bind_rows(existing, summary) |> distinct(Date, .keep_all = TRUE)
} else {
  combined <- summary
}

write_csv(combined, output_file)