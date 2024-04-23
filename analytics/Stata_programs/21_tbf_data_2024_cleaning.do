/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_21
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\21_tbf_data_2024_cleaning.log", replace name(clean_21)


*************************************************************************************************
***                                                                                           ***
*** Program name: 01_tbf_data_2024_cleaning.do                                                ***
*** Project: TBF Market Garden 2024                                 				          ***
*** Purpose: Clean TBF Market Garden 2024 data                                                ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) LOAD RAW DATA                                                                       ***
***    II) MANAGE VARIABLES                                                                   ***
***    III) CLEAN DATA                                                                        ***
***    IV) DESCRIPTIVE STATISTICS                                                             ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: February 29, 2024 	   					 	     			                  ***
*** Last date modified: April 23, 2024                                                         ***
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
	set seed 7122024
	
/* Define globals */

	*Root
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics"
    adopath ++ "$root"
    

*=========================================================================================
* I) LOAD RAW DATA 
*=========================================================================================

	/* Load raw data */
	import excel "$root\raw_data\Brosey Farming.xlsx", sheet("data_2024") firstrow clear
	keep crop-notes
	drop if missing(crop)
	ds 
	
	/* Save raw TBF Market Garden 2024 data */
	save "$root\raw_data\tbf_market_garden_data_2024_raw.dta", replace
	export excel "$root\raw_data\tbf_market_garden_data_2024_raw.xlsx", firstrow(variables) replace
	
/*   
*=========================================================================================
* II) MANAGE VARIABLES
*=========================================================================================  

	/* Add variable labels */
	include "$root\Stata_programs\02_tbf_data_2024_labels.do" // This program creates the variable labels.
	
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
		tablist `var' `var'_code, sort(v) ab(32)
		tablist `var' `var'_code, sort(v) nolabel ab(32)
		local varlab : variable label `var'
		label variable `var'_code "`varlab'- code"
		order `var'_code, after(`var')
		*pause
	}
	
	/* Export codes for reference in other programs/scripts */
	tempfile pre_code_export
	save `pre_code_export'
	
	tablist crop crop_code, sort(v) nolabel
	keep crop crop_code
	duplicates drop
	tablist crop crop_code, sort(v) nolabel
	sort crop_code
	export excel "$root\modified_data\tbf_crop_codes_2024.xlsx", firstrow(variables) nolabel replace
	
	use `pre_code_export', replace
	
	/* Convert yes/no variables from character strings to numerics with "yes" (1) /"no" (0) value lables */
	local cat_yn_list sow_heatmat
	foreach var of varlist `cat_yn_list' {
		tabulate `var', generate(`var'_code)
		drop `var'_code1
		rename `var'_code2 `var'_code
		tablist `var' `var'_code, sort(v) ab(32)
		tablist `var' `var'_code, sort(v) nolabel ab(32)
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
		foreach var of varlist sow_date-transp_harden_date_end_stata {
			tablist sow_type `var', sort(v) ab(32) nolabel
			assert missing(`var') if sow_type=="external transplant"
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if sow_type=="external transplant"
			else replace `var'= ".s" if sow_type=="external transplant"
			tablist sow_type `var', sort(v) ab(32) nolabel
		}
		
		*-> Seedlings variables: *sow* transp*
		foreach var of varlist sow_cell sow_heatmat-transp_no_end_2 { // These variables should be missing if the crop was direct seeded in the garden versus indoor seeding.
			tablist sow_med_code `var', sort(v) ab(32) nolabel
			assert missing(`var') if inlist(sow_med_code, 1, 2)
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if inlist(sow_med_code, 1, 2)
			else replace `var'= ".s" if inlist(sow_med_code, 1, 2)
			tablist sow_med_code `var', sort(v) ab(32) nolabel
		}

		tablist sow_heatmat sow_heatmat_temp, sort(v) ab(32)
		assert sow_heatmat_temp==. if sow_heatmat=="no"
		replace sow_heatmat_temp=.s if sow_heatmat=="no"
		tablist sow_heatmat sow_heatmat_temp, sort(v) ab(32)
		
**# Bookmark #1
		tablist crop crop_code, sort(v) nolabel
		foreach var of varlist sow_no_germ_per sow_to_germ25_days sow_no_thin_per {	
			replace `var'=.s if `var'==. & crop_code==9 // For the garlic that has not germinated yet. Planted in FA23 for harvest SU24.
		}
		
		tablist crop sow_date if sow_no_thin_per==., sort(v) ab(32) // These are true missing data. Should have been filled out but were not.
		replace sow_no_thin_per=.m if sow_no_thin_per==.
		
		/*
		foreach var of varlist transp_* {
			capture tablist crop sow_date if missing(`var'), sort(v) ab(32)
			if _rc==0 {
				capture confirm numeric variable `var'
				*if _rc==0 replace  `var'=.f if `var'==. & inlist(crop,"lettuce- gourmet blend","kale- lacinato") & sow_date=="2024-08-13" // These are plants that have not yet been transplanted.
				*else replace `var'=".f" if `var'=="" & inlist(crop,"lettuce- gourmet blend","kale- lacinato") & sow_date=="2024-08-13" // These are plants that have not yet been transplanted.
				// All plants have now been transplanted but saving this loop for next season;s iteration of this crop data cleaning program
			}
		}
		*/
		
		foreach var of varlist transp*_2* {
			tablist crop sow_date if missing(`var'), sort(v) ab(32)
			capture confirm numeric variable `var'
			if _rc==0 replace  `var'=.s if `var'==.  & transp_date_1_stata!=.m // These are crops that were trnasplanted only once.
			else replace `var'=".f" if `var'=="" & transp_date_1_stata!=.m // These are crops that were trnasplanted only once.
		}
		
		*-> Fertilizing, pathogen, and harvesting variables: *fert_* path_* harvest_*
		foreach var of varlist *fert_* path_* harvest_* {
			display as input "Variable: `var'"
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if missing(`var')
			else replace `var'= ".s" if missing(`var') | `var'=="."
			tablist sow_type `var', sort(v) ab(32) nolabel
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
*/		
	/* Save clean TBF Market Garden 2024 data */
	isid crop sow_date
	quietly compress
	save "$root\modified_data\tbf_market_garden_data_2024_clean.dta", replace
	export excel "$root\modified_data\tbf_market_garden_data_2024_clean.xlsx", firstrow(variables) replace
	
 
*=========================================================================================
* IV) DESCRIPTIVE STATISTICS
*=========================================================================================     
	
	describe _all


log close _all
