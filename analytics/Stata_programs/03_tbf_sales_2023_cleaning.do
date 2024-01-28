/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\03_tbf_sales_2023_cleaning.log", replace name(clean_01)


*************************************************************************************************
***                                                                                           ***
*** Program name: 03_tbf_sales_2023_cleaning.do                                               ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Clean TBF Market Garden 2023 sales data                                          ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) LOAD RAW DATA                                                                       ***
***    II) MANAGE VARIABLES                                                                   ***
***    III) CLEAN DATA                                                                        ***
***    IV) DESCRIPTIVE STATISTICS                                                             ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: August 8, 2023   	   					 	     			                  ***
*** Last date modified: January 27, 2023                                                      ***
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
* I) LOAD RAW DATA 
*=========================================================================================

	/* Load raw data */
	import excel "$root\raw_data\Brosey Farming.xlsx", sheet("sales_2023") firstrow clear
	keep sale_date-sale_value_usd
	ds 
	
	/* Save raw TBF Market Garden 2023 data */
	save "$root\raw_data\tbf_market_garden_sales_2023_raw.dta", replace
	
   
*=========================================================================================
* II) MANAGE VARIABLES
*=========================================================================================  

	/* Add variable labels */
	label variable sale_date "sale date"
	label variable sale_location "sale location" 
	label variable sale_item "sale item" 
	label variable sale_amnt "sale amount" 
	label variable sale_unit "sale amount unit" 
	label variable sale_value_usd "sale value (dollars)"
	
	/* Manage variable type */
	describe _all
	
	/* Manage sales date variable */
	foreach var of varlist *date* {
		display as input "Variable: `var'"
		tabulate `var', missing
		capture confirm string var `var'
		if _rc!=0 tostring `var', replace
		generate `var'_year= substr(`var',1,4)
		generate `var'_month= substr(`var',6,2)
		generate `var'_day= substr(`var',9,2)
		foreach var2 of varlist `var'_year `var'_month `var'_day {
			confirm string var `var2'
			destring `var2', replace
		}
		generate `var'_stata= mdy(`var'_month, `var'_day, `var'_year)
		drop `var'_year `var'_month `var'_day
		local varlab : variable label `var'
		label variable `var'_stata "`varlab'- stata"		
		format `var'_stata %td
		order `var'_stata, after(`var')
	}
	
	/* Convert categorical strings into categorical numerics */
	local cat_str_list sale_location sale_item sale_unit
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

    
*=========================================================================================
* III) CLEAN DATA
*=========================================================================================     

	/* Clean missing values */
	foreach var of varlist sale_location_stall_no sale_item sale_item_code sale_amnt sale_unit sale_unit_code {
		display as input "Variable: `var'"
		capture confirm numeric variable `var'
		if _rc==0 {
			assert `var'==. if sale_location== "The Brosey Farm: farm stand"
			replace `var'=.s if sale_location== "The Brosey Farm: farm stand"
		} 		
		else {
			assert `var'=="" if sale_location== "The Brosey Farm: farm stand"
			replace `var'=".s" if sale_location== "The Brosey Farm: farm stand"			
		}
	}
	
	tablist sale_location sale_location_stall_no sale_location_stall_spec, sort(variable) ab(32)
	replace sale_location_stall_no= .m if sale_location_stall_no==.
	replace sale_location_stall_spec= ".m" if sale_location_stall_spec==""
	
	foreach var of varlist _all {
		tabulate `var', missing
		capture confirm numeric variable `var'
		if _rc==0 assert `var' !=.
		else assert `var' !=""
	}	
		
	/* Save clean TBF Market Garden 2023 data */
	quietly compress
	save "$root\modified_data\tbf_market_garden_sales_2023_clean.dta", replace
	export excel "$root\modified_data\tbf_market_garden_sales_2023_clean.xlsx", firstrow(variables) replace
	
 
*=========================================================================================
* IV) DESCRIPTIVE STATISTICS
*=========================================================================================     
	
	describe _all


log close _all