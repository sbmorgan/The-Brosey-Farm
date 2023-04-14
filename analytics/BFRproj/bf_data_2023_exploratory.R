#load required R packages
library(tidyverse)
library(readr)
library(stringr)
library(visdat)
library(skimr)
library(DT)
library(esquisse)
library(datamods)
library(lubridate)

#import 2023 bf crop data
bf_2023 <- read_csv("Brosey Farming - data_2023.csv")
str(bf_2023)

#validate data
vis_miss(bf_2023)

#modify data
#TODO Make crop & sow_type factors, not character strings

#build analysis indicators
bf_2023 <- bf_2023 %>% 
  mutate(sow_no_seed_tot= sow_no_cell* sow_no_seed_per, 
         sow_no_germ_pct= (sow_no_germ_per/sow_no_seed_per)*100)

#exploratory analysis
skim(bf_2023)

bf_2023 %>% count(crop, sow_date)

bf_2023 %>% count(crop, sow_date, wt= sow_no_seed_tot)

bf_crop_summary = bf_2023 %>% group_by(crop, sow_date) %>% summarize(sow_no_germ_pct, sow_no_seed_tot)

ggplot(bf_2023, aes(x=reorder(crop, sow_no_seed_tot), y=sow_no_seed_tot, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Number of seeds sown") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x")

ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Days to germination") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + labs(fill = "Sow Date")
ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Days to germination") + theme(axis.text.x=element_text(angle=60), strip.background=element_blank(), strip.text.y= element_blank()) + facet_wrap(vars(sow_date), scales = "free_x") + labs(fill = "Sow Date")
ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=factor(sow_date))) + geom_point(shape= 15, size=5, color="blue") + labs(x = "Crop", y = "Days to germination") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + scale_fill_discrete(name = "Sow Date")

ggplot(bf_2023, aes(x=reorder(crop, sow_no_germ_pct), y=sow_no_germ_pct, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Germination %") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x")

ggplot(bf_crop_summary, aes(x=factor(sow_date), y=sow_no_seed_tot, fill = crop)) +
  geom_bar(stat = "identity", position = "dodge") + 
  theme_classic() +
  labs(
    title = "Number of seeds sown by crop, 2023",
    x = "Sow Date", y = "Number of seeds sown") +
  scale_fill_brewer(palette="Spectral")

##esquisse:::esquisser()

ggplot(bf_2023) +
  aes(x = crop, y = sow_no_seed_tot, fill = factor(sow_date)) +
  geom_col() +
  labs(
    x = "Crop sown",
    y = "Total seeds sown",
    title = "My first Esquisse plot :)",
    subtitle = "(Engage!)",
    caption = "Precious little life-forms",
    fill = "Crop sow date"
  ) +
  theme_gray() +
  facet_wrap(vars(sow_date), scales = "free_x") +
  theme(axis.text.x=element_text(angle=60))