/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/


*************************************************************************************************
***                                                                                           ***
*** Program name: 02_tbf_data_2023_labels.do                                                  ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Create variable labels for TBF Market Garden 2023 data                           ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) CREATE VARIABLE LABELS                                                              ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: July 13, 2023   	   					 	     			                  ***
*** Last date modified: October 12, 2023                                                    ***
***                                                                                           ***
*** Notes:                                                                                    ***
***   This program will be used as an include file in 01_tbf_data_2023_cleaning.do            ***
***                                                                                           ***
*************************************************************************************************


capture log close labels_02
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\02_tbf_data_2023_labels.log", replace name(labels_02)


*=========================================================================================
* I) CREATE VARIABLE LABELS    
*=========================================================================================
	
	label variable crop "crop type"
	label variable sow_type "seed sowing type"
	label variable sow_date "seed sowing date"
	label variable sow_med "seed sowing medium"
	label variable sow_cell "seed sowing cell type"
	label variable sow_no_cellrowhill "number of cells/rows/hills sown"
	label variable sow_no_seed_per "number of seeds sown per cell/row/hill" 
	label variable sow_no_germ_per "number of seeds germinated per cell/row/hill" 
	label variable sow_to_germ25_days "number of days to germination (25%)" 
	label variable sow_no_thin_per "number of seedlings per cell/row/hill after thinning" 
	label variable sow_heatmat "heat mat used to germinate seedlings" 
	label variable sow_heatmat_temp "temperature (F) of heat mat used to germinate seedlings" 
	label variable sow_light_hrs "number of hours of lighting" 
	label variable sow_light_type "lighting type"
	
	/* Indoor fertilizing */
	forval x=1/4 {
		label variable sow_fert_date_`x' "date of fertilizer applied to indoor seedlings: round `x'"
		label variable sow_fert_type_npk_`x' "npk of fertilizer applied to indoor seedlings: round `x'"
		label variable sow_fert_type_name_`x' "name of fertilizer applied to indoor seedlings: round `x'"
		label variable sow_fert_dose_`x' "dose of fertilizer applied to indoor seedlings: round `x'"
	}
	
	/* Transplanting */
	label variable transp_harden_date_srt "transplant harden off start date"
	label variable transp_harden_date_end "transplant harden off end date"
	
	forval x=1/2 {
		label variable transp_date_`x' "transplant date: round `x'"
		label variable transp_med_`x' "transplant medium: round `x'"
		label variable transp_no_srt_`x' "starting number of transplants: round `x'"
		label variable transp_no_end_`x' "ending number of transplants: round `x'"
	}
	
	/* Outdoor fertilizing */
	forval x=1/3 {
		label variable fert_type_npk_`x' "npk of fertilizer applied to indoor seedlings: round `x'"
		label variable fert_type_name_`x' "name of fertilizer applied to indoor seedlings: round `x'"
		label variable fert_date_`x' "date of fertilizer applied to crop: round `x'"
		label variable fert_amnt_per_`x' "amount of fertilizer applied per plant: round `x'"
		label variable fert_unit_`x' "unit of fertilizer applied to crop: round `x'"
	}
	
	/* Pest management */
	forval x=1/3 {
		label variable path_type_`x' "pathogen type: pathogen `x'"
		label variable path_date_`x' "pathogen date: pathogen `x'"
		forval y=1/3 {
			label variable path_ipm_type_`x'_`y' "ipm type, type `y': pathogen `x'"
			label variable path_ipm_date_`x'_`y' "ipm date, type `y': pathogen `x'"
		}
	}
	
	/* Harvesting */
	forval x=1/30 {
		label variable harvest_date_`x' "date of harvest: round `x'"
		label variable harvest_amnt_`x' "harvested amount (wet): round `x'"
		label variable harvest_unit_`x' "unit of harvest: round `x'"
	}
	
log close labels_02