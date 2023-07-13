/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close _all
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\BFRproj\05_tbf_data_2023_cleaning.log", replace name(full)


*************************************************************************************************
***                                                                                           ***
*** Program name: 05_tbf_data_2023_cleaning.do                                                ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Clean TBF Market Garden 2023 data                                                ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) LOAD RAW DATA                                                                       ***
***    II) MANAGE VARIABLES                                                                   ***
***    III) CLEAN DATA                                                                        ***
***    IV) DESCRIPTIVE STATISTICS                                                             ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: July 12, 2023   	   					 	     			                  ***
*** Last date modified: July 12, 2023                                                         ***
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
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\BFRproj"
    adopath ++ "$root"
    

*=========================================================================================
* I) LOAD RAW DATA 
*=========================================================================================

	/* Load raw data */
	import excel "$root\Brosey Farming.xlsx", sheet("data_2023") firstrow clear
	keep crop-notes
	ds 
	describe
	
	/* Save raw TBF Market Garden 2023 data */
	save "$root\tbf_market_garden_data_2023_raw.dta", replace
	
   
*=========================================================================================
* II) MANAGE VARIABLES
*=========================================================================================  

	/* Convert categorical strings into categorical numerics */
	local cat_str_list crop
	tab1 `cat_str_list', missing
	foreach var of varlist `cat_str_list' {
		encode (`var'), generate(`var'_code)
		tablist `var'_code `var', sort(variable) 
		tablist `var'_code `var', sort(variable) nolabel ab(32)
		order `var'_code, after(`var')
		*pause
	}
    
    
*=========================================================================================
* III) CLEAN DATA
*=========================================================================================     

	/* Clean missing values */
	
	

	/* Save clean TBF Market Garden 2023 data */
	save "$root\tbf_market_garden_data_2023_clean.dta", replace
	
 
*=========================================================================================
* IV) DESCRIPTIVE STATISTICS
*=========================================================================================     


log close _all