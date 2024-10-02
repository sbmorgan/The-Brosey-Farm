/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\06_tbf_data_2023_analysis.log", replace name(clean_01)


*************************************************************************************************
***                                                                                           ***
*** Program name: 04_tbf_data_2023_merge.do                                                   ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Merge TBF Market Garden 2023 crop and sales data                                 ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) MERGE SALES DATA TO CROP DATA                                                       ***
***    II) ANALYSIS (TBD)                                                                     ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: September 20, 2023   	   					 	     			              ***
*** Last date modified: January 30, 2023                                                      ***
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
* I) MERGE SALES DATA TO CROP DATA
*=========================================================================================
	
	/* Load cleaned sales data */
	use "$root\modified_data\tbf_market_garden_data_2023_clean_indicators.dta", clear
	merge m:1 crop_code using "$root\modified_data\tbf_market_garden_sales_2023_clean_indicators.dta", assert(1 3)
	tablist _merge crop crop_code, sort(v) ab(32) nolabel
	foreach var of varlist *sale_* {
		capture confirm string variable `var'
		if _rc==0 replace `var'= ".s" if _merge==1
		else replace `var'= .s if _merge==1
	}
	drop _merge
	
	/* Save TBF 2023 Crop and Sales Analysis File */
	isid crop sow_date
	quietly compress
	save "$root\modified_data\tbf_market_garden_crop_sales_analysis.dta", replace
   
*=========================================================================================
* II) ANALYSIS (TBD)
*=========================================================================================  


log close _all