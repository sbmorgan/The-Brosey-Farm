/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\01_tbf_data_2023_cleaning.log", replace name(clean_01)


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
*** Last date modified: August 31, 2023                                                       ***
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
	import excel "$root\raw_data\Brosey Farming.xlsx", sheet("data_2023") firstrow clear
	keep crop-notes
	drop if missing(crop)
	ds 
	
	/* Save raw TBF Market Garden 2023 data */
	save "$root\raw_data\tbf_market_garden_data_2023_raw.dta", replace
	
   
*=========================================================================================
* II) MANAGE VARIABLES
*=========================================================================================  

	/* Add variable labels */
	include "$root\Stata_programs\02_tbf_data_2023_labels.do" // This program creates the variable labels.
	
	/* Manage variable type */
	tostring *type*, replace // All "type" variables are intended to be character strings. Empty "type" variables are read in as byte numeric. Convert those to character strings.
	
	/* Manage date variables */
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
	
	/* Convert yes/no variables from character strings to numerics with "yes" (1) /"no" (0) value lables */
	local cat_yn_list sow_heatmat
	foreach var of varlist `cat_yn_list' {
		if `var'=="." continue
		*encode (`var'), generate(`var'_code)
		*replace `var'_code= 0 if `var'_code== 1
		*replace `var'_code= 1 if `var'_code== 2
		tabulate `var', generate(`var'_code)
		drop `var'_code1
		rename `var'_code2 `var'_code
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
		
		*-> Crop
		assert !missing(crop)
		assert !missing(sow_type)
		
		*-> Non-seeded transplants (externally sourced transplants)
		foreach var of varlist sow_date-transp_harden_date_end {
			tablist sow_type `var', sort(var) ab(32) nolabel
			assert missing(`var') if sow_type=="external transplant"
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if sow_type=="external transplant"
			else replace `var'= ".s" if sow_type=="external transplant"
			tablist sow_type `var', sort(var) ab(32) nolabel
		}
		
		*-> Seedlings variables: *sow* transp*
		foreach var of varlist sow_cell sow_heatmat-transp_no_end_2 { // These variables should be missing if the crop was direct seeded in the garden versus indoor seeding.
			tablist sow_med_code `var', sort(var) ab(32) nolabel
			assert missing(`var') if inlist(sow_med_code, 1, 2)
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if inlist(sow_med_code, 1, 2)
			else replace `var'= ".s" if inlist(sow_med_code, 1, 2)
			tablist sow_med_code `var', sort(var) ab(32) nolabel
		}

		tablist sow_heatmat sow_heatmat_temp, sort(var) ab(32)
		assert sow_heatmat_temp==. if sow_heatmat=="no"
		replace sow_heatmat_temp=.s if sow_heatmat=="no"
		tablist sow_heatmat sow_heatmat_temp, sort(var) ab(32)
		
		*-> Fertilizing, pathogen, and harvesting variables: *fert_* path_* harvest_*
		foreach var of varlist *fert_* path_* harvest_* {
			display as input "Variable: `var'"
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if missing(`var')
			else replace `var'= ".s" if missing(`var') | `var'=="."
			tablist sow_type `var', sort(var) ab(32) nolabel
		}
		
		*-> Notes
		replace notes=".s" if missing(notes)
		
		*-> Check all missing values have been cleaned
		foreach var of varlist _all {
			display as input "Variable: `var'"
			tabulate `var', missing
			capture confirm numeric variable `var'
			if _rc==0 assert `var' !=.
			else assert `var' !=""
		}
		
	/* Save clean TBF Market Garden 2023 data */
	save "$root\clean_data\tbf_market_garden_data_2023_clean.dta", replace
	
 
*=========================================================================================
* IV) DESCRIPTIVE STATISTICS
*=========================================================================================     
	
	describe _all


log close _all