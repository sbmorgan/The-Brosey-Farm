##load required R packages##
  pacman::p_load(tidyverse, readr, stringr, visdat, skimr, DT, esquisse, datamods, lubridate, googlesheets4)

##import 2023 bf crop data##
  #bf_2023 <- read_csv("Brosey Farming - data_2023.csv")
  bf_2023 <- read_sheet("https://docs.google.com/spreadsheets/d/1lXsVEpM5iNZrNqlap8JHbxeIxeXF_C3s--FMrx_Inc8/edit#gid=707201855", sheet = "data_2023")
  str(bf_2023)
  
  #Revise column types
  bf_2023$crop <- as.factor(bf_2023$crop)
  bf_2023$sow_type <- as.factor(bf_2023$sow_type)
  bf_2023$transp_date_1 <- as.character(bf_2023$transp_date_1)  
  str(bf_2023)
  
##validate data##
  vis_miss(bf_2023)

##build analysis indicators##
  bf_2023 <- bf_2023 %>% 
    mutate(sow_no_seed_tot= sow_no_cellrow* sow_no_seed_per, 
           sow_no_germ_pct= (sow_no_germ_per/sow_no_seed_per)*100,
           sow_to_transp_days= difftime(transp_date_1, sow_date, units = "days"),
           transp_harden_days= difftime(transp_harden_date_end, transp_harden_date_srt, units = "days"))

##analysis##

  #exploratory
  skim(bf_2023)
  bf_2023 %>% count(crop, sow_date)
  bf_2023 %>% count(crop, sow_date, wt= sow_no_seed_tot)

  #sowing
  ggplot(bf_2023, aes(x=reorder(crop, sow_no_seed_tot), y=sow_no_seed_tot, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Number of seeds sown") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + labs(fill = "Sow Date")
  ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Days to germination") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + labs(fill = "Sow Date")
  ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Days to germination") + theme(axis.text.x=element_text(angle=60), strip.background=element_blank(), strip.text.y= element_blank()) + facet_wrap(vars(sow_date), scales = "free_x") + labs(fill = "Sow Date")
  ggplot(bf_2023, aes(x=reorder(crop, sow_to_germ_days), y=sow_to_germ_days, fill=factor(sow_date))) + geom_point(shape= 15, size=5, color="blue") + labs(x = "Crop", y = "Days to germination") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + scale_fill_discrete(name = "Sow Date")
  ggplot(bf_2023, aes(x=reorder(crop, sow_no_germ_pct), y=sow_no_germ_pct, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Germination %") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x")
  
  bf_crop_summary = bf_2023 %>% group_by(crop, sow_date) %>% summarize(sow_no_germ_pct, sow_no_seed_tot)
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

  #transplanting
  ggplot(bf_2023, aes(x=reorder(crop, sow_to_transp_days), y=sow_to_transp_days, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Sow to transplate- days") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + scale_fill_discrete(name = "Sow Date")
  ggplot(bf_2023, aes(x=reorder(crop, transp_harden_days), y=transp_harden_days, fill=factor(sow_date))) + geom_col(color="blue") + labs(x = "Crop", y = "Transplant hardening off- days") + theme(axis.text.x=element_text(angle=60)) + facet_wrap(vars(sow_date), scales = "free_x") + scale_fill_discrete(name = "Sow Date")
