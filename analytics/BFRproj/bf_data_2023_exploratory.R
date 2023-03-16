library(readr)
library(dplyr)

#Import 2023 crop data
bf_2023 <- read_csv("Brosey Farming - data_2023.csv")
str(bf_2023)
bf_2023

#as.Date(bf_2023$sow_date)