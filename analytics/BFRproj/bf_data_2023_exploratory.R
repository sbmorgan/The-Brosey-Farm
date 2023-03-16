#load required R packages
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(visdat)

#import 2023 crop data
bf_2023 <- read_csv("Brosey Farming - data_2023.csv")
str(bf_2023)

#validate data
vis_miss(bf_2023)