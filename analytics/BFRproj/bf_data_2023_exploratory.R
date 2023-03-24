#load required R packages
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(visdat)
library(lubridate)

#import 2023 bf crop data
bf_2023 <- read_csv("Brosey Farming - data_2023.csv")
str(bf_2023)

#validate data
vis_miss(bf_2023)

#modify data
##Make crop & sow_type factors, not character strings

#build analysis indicators
bf_2023 <- bf_2023 %>% mutate(sow_no_seed_tot= sow_no_cell* sow_no_seed_per)
bf_2023 <- bf_2023 %>% mutate(sow_no_germ_pct= (sow_no_germ_per/sow_no_seed_per)*100)

#exploratory analysis
bf_2023 %>% count(crop, sow_date)

bf_2023 %>% count(crop, sow_date, wt= sow_no_seed_tot)

bf_2023 %>% group_by(crop, sow_date) %>% summarize(sow_no_germ_pct, sow_no_seed_tot)

ggplot(bf_2023, aes(x=reorder(crop, sow_no_seed_tot), y=sow_no_seed_tot, fill=sow_date)) + geom_col(color="blue") + labs(x = "Crop", y = "Number of seeds sown/cell")

ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=sow_date)) + geom_col(color="blue") + labs(x = "Crop", y = "Days to germination")

ggplot(bf_2023, aes(factor(crop), sow_no_germ_pct, fill=sow_date)) + geom_col(color="blue") + labs(x = "Crop", y = "Germination %")
