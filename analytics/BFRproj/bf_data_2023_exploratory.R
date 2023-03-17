#load required R packages
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(visdat)

#import 2023 bf crop data
bf_2023 <- read_csv("Brosey Farming - data_2023.csv")
str(bf_2023)

#validate data
vis_miss(bf_2023)

#modify data
##Make crop & sow_type factors, not character strings

#build analysis indicators
bf_2023 <- bf_2023 %>% mutate(sow_no_seed_tot= sow_no_cell* sow_no_seed_per)

#exploratory analysis
bf_2023 %>% count(crop, sow_date)

bf_2023 %>% count(crop, sow_date, wt= sow_no_seed_tot)

ggplot(bf_2023, aes(x= crop, y= sow_no_seed_tot, fill=sow_date)) + geom_col()