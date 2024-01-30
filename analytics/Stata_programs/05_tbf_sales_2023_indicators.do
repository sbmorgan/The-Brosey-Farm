/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\05_tbf_sales_2023_indicators.log", replace name(clean_01)


*************************************************************************************************
***                                                                                           ***
*** Program name: 05_tbf_sales_2023_indicators.do                                             ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Create Analysis Indicators for TBF Market Garden 2023 sales data                 ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) CREATE ANALYSIS INDICATORS                                                          ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: September 26, 2023   	   					 	     			              ***
*** Last date modified: September 29, 2023                                                    ***
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
	set seed 7122023
	
/* Define globals */

	*Root
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics"
    adopath ++ "$root"
    

*=========================================================================================
* I) 
*=========================================================================================
	
	/* Load clean TBF Market Garden 2023 data */
	use "$root\modified_data\tbf_market_garden_sales_2023_clean.dta", clear
	
	/* Sales */
	collapse (sum) sale_value_usd, by(sale_location sale_item)
	rename sale_value_usd sale_value_crop_usd 
	egen sale_value_tot_usd= total(sale_value_crop_usd)
	
	/* Save TBF Market Garden 2023 data with analysis indicators */
	quietly compress
	save "$root\modified_data\tbf_market_garden_sales_2023_clean_indicators.dta", replace
    

log close _all