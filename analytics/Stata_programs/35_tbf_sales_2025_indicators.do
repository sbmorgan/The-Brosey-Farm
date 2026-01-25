/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close _all
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\35_tbf_sales_2025_indicators.log", replace name(indicators_35)


*************************************************************************************************
***                                                                                           ***
*** Program name: 35_tbf_sales_2024_indicators.do                                             ***
*** Project: TBF Market Garden 2024                                 				          ***
*** Purpose: Create Analysis Indicators for TBF Market Garden 2024 sales data                 ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) CREATE SALES ANALYSIS INDICATORS                                                    ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: January 25, 2026     	   					 	     			              ***
*** Last date modified: January 25, 2026                                                      ***
***                                                                                           ***
*** Notes:                                                                                    ***
***                                                                                           ***
***                                                                                           ***
*************************************************************************************************

clear all
version 19.5
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
* I) CREATE SALES ANALYSIS INDICATORS 
*=========================================================================================
	
	/* Load clean TBF Market Garden 2025 sales data */
	use "$root\modified_data\tbf_market_garden_sales_2025_clean.dta", clear
/*	
	/* Sales */
	collapse (sum) sale_value_usd, by(sale_location sale_item)
	rename sale_value_usd c_sale_value_crop_usd 
	egen c_sale_value_tot_usd= total(c_sale_value_crop_usd)
	label variable c_sale_value_crop_usd "sale value (dollars)- crop"
	label variable c_sale_value_tot_usd "sale value (dollars)- total"
	tablist sale_location sale_item c_sale_value_crop_usd c_sale_value_tot_usd, sort(v) ab(32)
	
	/* Add TBF 2025 Crop Codes */
	tempfile pre_crop_codes crop_codes
	save `pre_crop_codes', replace
	
	import excel "$root\modified_data\tbf_crop_codes_2025.xlsx", firstrow clear
	tablist crop crop_code, sort(v) ab(32)
	save `crop_codes', replace
	
	use `pre_crop_codes', replace
	rename sale_item crop
	drop if inlist(crop,".s",".m","tomato sauce","tomato jalapeno salsa", "black raspberry jam") // celosia
	merge 1:1 crop using `crop_codes', keep(1 3) 
	replace crop_code= .m if _merge==1 // Celosia was not recorded in the 2025 crop data.
	tablist _merge sale_location crop c_sale_value_crop_usd c_sale_value_tot_usd crop_code, sort(v) ab(32)
	drop _merge
	
	/* Save TBF Market Garden 2025 data with analysis indicators */
	order crop crop_code sale_location c_sale_value_crop_usd c_sale_value_tot_usd
	isid crop
*/		
	quietly compress
	save "$root\modified_data\tbf_market_garden_sales_2025_clean_indicators.dta", replace
    

log close _all