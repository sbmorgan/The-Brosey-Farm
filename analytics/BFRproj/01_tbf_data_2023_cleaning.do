/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\BFRproj\01_tbf_data_2023_cleaning.log", replace name(clean_01)


*************************************************************************************************
***                                                                                           ***
*** Program name: 01_tbf_data_2023_cleaning.do                                                ***
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
*** Last date modified: July 26, 2023                                                         ***
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
	drop if missing(crop)
	ds 
	
	/* Save raw TBF Market Garden 2023 data */
	save "$root\tbf_market_garden_data_2023_raw.dta", replace
	
   
*=========================================================================================
* II) MANAGE VARIABLES
*=========================================================================================  

	/* Manage variable type */
	tostring *type*, replace // All "type" variables are intended to be character strings. Empty "type" variables are read in as byte numeric. Convert those to character strings.
	
	/* Manage date variables */
	foreach var of varlist *date* {
		
	}
	
	/* Convert categorical strings into categorical numerics */
	local cat_str_list crop sow_med *type*
	tab1 `cat_str_list', missing
	foreach var of varlist `cat_str_list' {
		if `var'=="." continue
		encode (`var'), generate(`var'_code)
		tablist `var' `var'_code, sort(variable) ab(32)
		tablist `var' `var'_code, sort(variable) nolabel ab(32)
		local varlab : variable label `var'
		label variable `var'_code "`varlab'- code"
		order `var'_code, after(`var')
		*pause
	}
	
	/* Add variable labels */
	include "$root\02_tbf_data_2023_labels.do" // This program creates the variable labels.
	
    
*=========================================================================================
* III) CLEAN DATA
*=========================================================================================     

	/* Clean missing values */
	
		*-> Seedlings variables: *sow* transp*
		foreach var of varlist sow_cell sow_heatmat-transp_no_end_2 { // These variables should be missing if the crop was direct seeded in the garden versus indoor seeding.
			assert missing(`var') if inlist(sow_med_code, 1, 2)
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if inlist(sow_med_code, 1, 2)
			else replace `var'= ".s" if inlist(sow_med_code, 1, 2)
		}

	/* Save clean TBF Market Garden 2023 data */
	save "$root\tbf_market_garden_data_2023_clean.dta", replace
	
 
*=========================================================================================
* IV) DESCRIPTIVE STATISTICS
*=========================================================================================     
	
	describe


log close _all