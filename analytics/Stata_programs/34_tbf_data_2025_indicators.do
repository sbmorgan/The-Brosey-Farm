/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close _all
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\34_tbf_data_2025_indicators.log", replace name(indicators_34)


*************************************************************************************************
***                                                                                           ***
*** Program name: 34_tbf_data_2025_indicators.do                                              ***
*** Project: TBF Market Garden 2025                                 				          ***
*** Purpose: Create Analysis Indicators for TBF Market Garden 2025 data                       ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) CREATE CROP ANALYSIS INDICATORS                                                     ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: January 25, 2026   	   					 	     			                  ***
*** Last date modified: January 25, 2026                                                      ***
***                                                                                           ***
*** Notes:                                                                                    ***
***                                                                                           ***
***                                                                                           ***
*************************************************************************************************


*=========================================================================================
* 0) SET UP CODE
*=========================================================================================	

/* Set do-file preferences */
	clear all
	version 19.5
	set more off
	set varabbrev off
	pause off

/* Set seed */
	set seed 7142025
	
/* Define globals */

	*Root
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics"
    adopath ++ "$root"
	
	
*=========================================================================================
* I) CREATE CROP ANALYSIS INDICATORS
*=========================================================================================
	
	/* Load clean TBF Market Garden 2025 crop data */
	use "$root\modified_data\tbf_market_garden_data_2025_clean.dta", clear
	 
	/* Planting */ // (!) This section is only in this 2025 crop inidicator code. Needs to be added to 2023 & 2024.
	
	*-> Number of seeds planted
	generate c_plant_num_seed=.c
	label variable c_plant_num_seed "number of seeds planted"	
	replace c_plant_num_seed= sow_no_cellrowhill * sow_no_seed_per if sow_no_seed_per!=96 // sow_no_seed_per==96 indicates broadcast seeding of unknown number of units
	replace c_plant_num_seed= .b if sow_no_seed_per==96
	tablist crop sow_med sow_cell sow_no_cellrowhill sow_no_seed_per c_plant_num_seed, sort(v) ab(32)
	tablist sow_med crop sow_cell sow_no_cellrowhill sow_no_seed_per c_plant_num_seed, sort(v) ab(32)	
/*	
	/* Harvest */
	
	*-> Number of plants harvested
	generate c_harvest_no_plant=.c
	label variable c_harvest_no_plant "number of plants harvested from"
	replace c_harvest_no_plant=transp_no_end_1 if sow_type=="indoor seed" & transp_no_end_2==.s
	replace c_harvest_no_plant=transp_no_end_2 if sow_type=="indoor seed" & transp_no_end_2!=.s // Use final transplant number if multiple transplantings (e.g., from seed tray to small container (1), then to garden plot (2))
	tablist crop crop_code, sort(v) ab(32) nolabel
	tablist crop crop_code sow_type sow_date sow_med sow_no_cellrowhill sow_no_seed_per sow_to_germ50_days sow_no_germ_per sow_no_thin_per if crop_code==18, sort(v) ab(32) nolabel
	replace c_harvest_no_plant= (sow_no_thin_per * sow_no_cellrowhill) if sow_type=="outdoor seed" & !(crop_code==18 & sow_date=="2024-11-16") // "& !(crop_code==18 & sow_date=="2024-11-16")" to exclude a calculation for the 2024 garlic that has not germinated yet. Planted in FA24 for harvest SU25.
	replace c_harvest_no_plant=transp_no_end_1 if sow_type=="external transplant" // These are starts purchased outside the farm.
	replace c_harvest_no_plant= .s if sow_no_thin_per==96 // These are herbs that were broadcast seeded in framed raised beds. 
	tablist sow_type sow_date crop transp_no_srt_1 transp_no_end_1 transp_no_srt_2 transp_no_end_2 sow_no_thin_per sow_no_cellrowhill c_harvest_no_plant, sort(v) ab(32)
	table crop, statistic(total c_harvest_no_plant)
	
	*-> Total harvest- weight
	tablist crop crop_code harvest_unit_1, sort(v) ab(32) nolabel
	generate flag_crop_wt= inlist(harvest_unit_1,"ounce","pound")
	tablist flag_crop_wt crop crop_code harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_wt "flags crops harvested by weight"
	
	generate c_harvest_total_wtoz= 0
	replace c_harvest_total_wtoz= .c if flag_crop_wt==0 
	label variable c_harvest_total_wtoz "total harvest- weight, ounces"
	
	generate c_harvest_total_wtoz_prev=0
	replace c_harvest_total_wtoz_prev= .c if flag_crop_wt==0 
	label variable c_harvest_total_wtoz_prev "total harvest- weight, ounces (previous sum in loop iteration)"
	
	tablist flag_crop_wt crop crop_code harvest_unit_1 c_harvest_total_wtoz, sort(v) ab(32) nolabel
	
	forval x=1/30 {
		capture confirm string variable harvest_unit_`x'
		if _rc==0 {
			replace c_harvest_total_wtoz= c_harvest_total_wtoz + harvest_amnt_`x' if harvest_unit_`x'=="ounce" & flag_crop_wt==1
			replace c_harvest_total_wtoz= c_harvest_total_wtoz + (harvest_amnt_`x' * 16) if harvest_unit_`x'=="pound" & flag_crop_wt==1
			tablist flag_crop_wt crop c_harvest_total_wtoz harvest_amnt_`x' harvest_unit_`x' c_harvest_total_wtoz_prev, sort(v) ab(32)
			*pause
			replace c_harvest_total_wtoz_prev= c_harvest_total_wtoz if flag_crop_wt==1
		}
		else assert harvest_unit_`x'==.s // No harvest collected.
	} 
	assert c_harvest_total_wtoz==.c if flag_crop_wt==0 
	table crop if flag_crop_wt==1, statistic(total c_harvest_total_wtoz)
	drop c_harvest_total_wtoz_prev
	
	clonevar c_harvest_total_wtlb= c_harvest_total_wtoz
	label variable c_harvest_total_wtlb "total harvest- weight, pounds"
	replace c_harvest_total_wtlb= c_harvest_total_wtlb/16 if flag_crop_wt==1
	tablist flag_crop_wt crop sow_date c_harvest_total_wtlb c_harvest_total_wtoz, sort(v) ab(32)
	assert c_harvest_total_wtlb==.c if flag_crop_wt==0 
	table crop if flag_crop_wt==1, statistic(total c_harvest_total_wtlb)	

	*-> Total harvest- unit
	tablist crop crop_code harvest_unit_1 harvest_amnt_1, sort(v) ab(32) nolabel
	generate flag_crop_unit= inlist(harvest_unit_1,"unit")
	tablist flag_crop_unit crop crop_code harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_unit "flags crops harvested by unit"
	
	generate c_harvest_total_unit= 0
	replace c_harvest_total_unit= .c if flag_crop_unit==0
	label variable c_harvest_total_unit "total harvest- units"
	
	generate c_harvest_total_unit_prev=0
	replace c_harvest_total_unit_prev= .c if flag_crop_unit==0
	label variable c_harvest_total_unit_prev "total harvest- units (previous sum in loop iteration)"
	
	tablist flag_crop_unit crop crop_code harvest_unit_1 c_harvest_total_unit, sort(v) ab(32) nolabel
	
	forval x=1/30 {
		capture confirm string variable harvest_unit_`x'
		if _rc==0 {
			replace c_harvest_total_unit= c_harvest_total_unit + harvest_amnt_`x' if inlist(harvest_unit_`x',"unit") & flag_crop_unit==1
			tablist flag_crop_unit crop c_harvest_total_unit harvest_amnt_`x' c_harvest_total_unit_prev, sort(v) ab(32)
			*pause
			replace c_harvest_total_unit_prev= c_harvest_total_unit if flag_crop_unit==1
		} 
		else assert harvest_unit_`x'==.s // No harvest collected.
	}
	assert c_harvest_total_unit==.c if flag_crop_unit==0
	table crop if flag_crop_unit==1, statistic(total c_harvest_no_plant c_harvest_total_unit)
	drop c_harvest_total_unit_prev
	
	tablist flag_* crop crop_code sow_type sow_date c_*, sort(v) ab(32) nolabel 
	
	/* Save TBF Market Garden 2025 data with analysis indicators */
	drop flag_*
*/
	isid crop sow_date
	quietly compress
	save "$root\modified_data\tbf_market_garden_data_2025_clean_indicators.dta", replace
	
	/* Descriptive statistics */
	des c_*
	summarize c_*, detail
	
   
log close _all