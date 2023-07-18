# This script makes the Brosey Farm Crop Reports

pacman::p_load(tidyverse,
               readr,
               visdat,
               stringr,
               janitor,
               DT,
               skimr,
               wesanderson)

# List of crop names
crop_list = c("basil", "eggplant", "kale", "lettuce", "pepper- anaheim","pepper- jalapeno", "pepper- sweet", "sage",              "tomato- amish", "tomato- roma")

# Add to report title (update each month)
reptime = "July 2023"
reptitle = reptime

# Source other scripts here

#TODO Still need to tie this into a filter by crop for main RMD

# Make crop reports (1 = Yes, 0 = No)

# mkcroprep = 0
# 
# this_crop = 'all'
# 
# rmarkdown::render(
#   input = "BF_ProgReport_2023.Rmd",
#   output_dir = "output/",
#   output_file = paste0("Seasonal Report ", reptitle, ".html")
# )

mkcroprep = 1

for (jj in crop_list) {
  
  this_crop = crop_list[jj]
  print(this_crop)
  reptitle = paste(reptime, this_crop, sep = " ")
  
  rmarkdown::render(
    input = "BF_ProgReport_2023.Rmd",
    output_dir = "output/",
    output_file = paste0("Seasonal Report ", reptitle, ".html")
  )
  
  rm(list = setdiff(ls(), c("reptime", "jj", "crop_list")))
}



