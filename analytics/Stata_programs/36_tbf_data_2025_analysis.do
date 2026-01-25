/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close _all
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\26_tbf_data_2025_analysis.log", replace name(analysis_36)


*************************************************************************************************
***                                                                                           ***
*** Program name: 36_tbf_data_2025_analyis.do                                                 ***
*** Project: TBF Market Garden 2025                                 				          ***
*** Purpose: Analyze TBF Market Garden 2025 crop and sales data                               ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) MERGE SALES DATA TO CROP DATA                                                       ***
***    II) ANALYSIS (TBD)                                                                     ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: January 25, 2026      	   					 	     			              ***
*** Last date modified: January 25, 2026                                                      ***
***                                                                                           ***
*** Notes:                                                                                    ***
***                                                                                           ***
***                                                                                           ***
*************************************************************************************************

clear all
version 18.0
set more off
set varabbrev off
pause off


*=========================================================================================
* 0) SET UP CODE
*=========================================================================================	

/* Set seed */
	set seed 7142025
	
/* Define globals */

	*Root
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics"
    adopath ++ "$root"
    

*=========================================================================================
* I) MERGE SALES DATA TO CROP DATA
*=========================================================================================
	
	/* Load and merge cleaned crop and sales data with indicators */

/*	use "$root\modified_data\tbf_market_garden_sales_2025_clean_indicators.dta", clear
	tablist crop_code crop, sort(v)
	drop if crop_code==.m
	isid crop
	isid crop_code
	tempfile sales_2024_clean_indicators
	save `sales_2024_clean_indicators'
*/	
	use "$root\modified_data\tbf_market_garden_data_2025_clean_indicators.dta", clear
/*
	merge m:1 crop_code using "`sales_2025_clean_indicators'", assert(1 3)
	tablist _merge crop crop_code, sort(v) ab(32) nolabel
	foreach var of varlist *sale_* {
		capture confirm string variable `var'
		if _rc==0 replace `var'= ".s" if _merge==1
		else replace `var'= .s if _merge==1
	}
	drop _merge
	
	/* Save TBF 2025 Crop and Sales Analysis File */
	isid crop sow_date
	quietly compress
	save "$root\modified_data\tbf_market_garden_crop_sales_analysis.dta", replace
	
   
*=========================================================================================
* II) ANALYSIS (TBD)
*=========================================================================================  

	/* Harvest */
	foreach var of varlist c_harvest_no_plant c_harvest_total_wtoz c_harvest_total_wtlb c_harvest_total_unit {
		display as input _n(2) "Harvest: `var'"
		table crop , stat(sum `var')
	}
		
	/* Sales */
	foreach var of varlist c_sale_value_crop_usd {
		display as input _n(2) "Harvest: `var'"
		table sale_location , stat(sum `var')
	}
	summarize c_sale_value_tot_usd, detail
*/

	/* Planting */
	foreach var of varlist c_plant_num_seed {
		display as input _n(2) "Planting: `var'"
		table crop , stat(sum `var')
	}
		
		

log close _all