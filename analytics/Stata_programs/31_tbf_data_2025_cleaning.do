/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close _all
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\31_tbf_data_2025_cleaning.log", replace name(cleaning_31)


*************************************************************************************************
***                                                                                           ***
*** Program name: 31_tbf_data_2025_cleaning.do                                                ***
*** Project: TBF Market Garden 2025                                 				          ***
*** Purpose: Clean TBF Market Garden 2025 data                                                ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) LOAD RAW DATA                                                                       ***
***    II) MANAGE VARIABLES                                                                   ***
***    III) CLEAN DATA                                                                        ***
***    IV) DESCRIPTIVE STATISTICS                                                             ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: May 23, 2025     	   					 	     			                  ***
*** Last date modified: January 9, 2026                                                       ***
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
	set seed 7122025
	
/* Define globals */

	*Root
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics"
    adopath ++ "$root"
    

*=========================================================================================
* I) LOAD RAW DATA 
*=========================================================================================

	/* Load raw data */
	import excel "$root\raw_data\Brosey Farming.xlsx", sheet("data_2025") firstrow clear
	keep crop-notes
	drop if missing(crop)
	ds 
	
	/* Save raw TBF Market Garden 2025 data */
	save "$root\raw_data\tbf_market_garden_data_2025_raw.dta", replace
	export excel "$root\raw_data\tbf_market_garden_data_2025_raw.xlsx", firstrow(variables) replace

  
*=========================================================================================
* II) MANAGE VARIABLES
*=========================================================================================  

	/* Add variable labels */
	include "$root\Stata_programs\32_tbf_data_2025_labels.do" // This program creates the variable labels.
	
	/* Manage variable type */
	tostring *type*, replace // All "type" variables are intended to be character strings. Empty "type" variables are read in as byte numeric. Convert those to character strings.

	/* Manage date variables */
	foreach var of varlist *date* {
		display as input "Variable: `var'"
		capture confirm string var `var'
		if _rc!=0 tostring `var', replace
		
		tabulate `var', missing
		replace `var'="" if `var'=="."
		tabulate `var', missing
		*pause
		
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
		replace `var'="" if `var'=="."
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
	export excel "$root\modified_data\tbf_crop_codes_2025.xlsx", firstrow(variables) nolabel replace
	
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
		foreach var of varlist crop sow_type sow_med {
			assert !missing(`var')
		}
 		
		*-> Non-seeded transplants (externally sourced transplants)
		count if sow_type=="external transplant"
		if `r(N)' != 0 {
			foreach var of varlist sow_date-transp_harden_date_end_stata { // These variables are for crops sown on the farm and thus should be missing if the crop was sourced externally (purchase, gift, etc.).
				tablist sow_type `var', sort(v) ab(32) nolabel
				assert missing(`var') if sow_type=="external transplant"
				capture confirm numeric variable `var'
				if _rc==0 replace `var'= .s if sow_type=="external transplant"
				else replace `var'= ".s" if sow_type=="external transplant"
				tablist sow_type `var', sort(v) ab(32) nolabel
			}			
		}

		*-> Seedlings variables: *sow* transp*
		foreach var of varlist sow_cell sow_heatmat-transp_no_end_3 { // These variables are for crops sown indoors and thus should be missing if the crop was directly seeded in the garden.
			display as input _n "Variable: `var'"
			tablist sow_med sow_med_code `var', sort(v) ab(32) nolabel
			assert missing(`var') if inlist(sow_med, "raised bed- ground", "rasied bed- frame")
			capture confirm numeric variable `var'
			if _rc==0 replace `var'= .s if inlist(sow_med, "raised bed- ground", "rasied bed- frame")
			else replace `var'= ".s" if inlist(sow_med, "raised bed- ground", "rasied bed- frame")
			tablist sow_med sow_med_code `var', sort(v) ab(32) nolabel
		}

		tablist crop crop_code, sort(v) nolabel
		tablist crop crop_code sow_date if crop_code==18, sort(v) ab(32) nolabel
		assert sow_to_germ50_days==. if crop=="garlic- german white hardneck" & sow_date=="2025-11-19" // Garlic doesn't bulb/produce leaves above ground until the following season.
		replace sow_to_germ50_days=.s if crop=="garlic- german white hardneck" & sow_date=="2025-11-19"
		foreach var of varlist sow_no_germ_per sow_no_thin_per {	
			assert `var'==. if crop=="garlic- german white hardneck" & sow_date=="2025-11-19"
			replace `var'=.s if crop=="garlic- german white hardneck" & sow_date=="2025-11-19" // For the 2025-planted garlic that has not germinated yet. Planted in FA25 for harvest SU26.
		}
		tablist sow_heatmat sow_heatmat_temp, sort(v) ab(32) // Heat temperature of heat mat should be missing if heat mat not used. 
		assert sow_heatmat_temp==. if sow_heatmat=="no"
		replace sow_heatmat_temp=.s if sow_heatmat=="no"
		tablist sow_heatmat sow_heatmat_temp, sort(v) ab(32)
		
		forval x= 2/7 {
			egen misscount_`x'= rowmiss(sow_fert_date_`x'-sow_fert_dose_`x')
			foreach var of varlist sow_fert_date_`x'-sow_fert_dose_`x' {
				capture confirm numeric variable `var'
				if _rc==0 replace `var'=.s if misscount_`x'==7
				else replace `var'=".s" if misscount_`x'==7
			}
			drop misscount_`x'
		}
		
		egen misscount= rowmiss(transp_date_2-transp_no_end_2)
		foreach var of varlist transp_date_2-transp_no_end_2 {
			capture confirm numeric variable `var'
			if _rc==0 replace `var'=.s if misscount==5
			else replace `var'=".s" if misscount==5
		}
		drop misscount
		
		forval x= 1/4 {
			egen misscount_`x'= rowmiss(fert_type_npk_`x'-fert_unit_`x')
			foreach var of varlist fert_type_npk_`x'-fert_unit_`x' {
				capture confirm numeric variable `var'
				if _rc==0 replace `var'=.s if misscount_`x'==8
				else replace `var'=".s" if misscount_`x'==8
			}
			drop misscount_`x'
		}
		
		forval x= 1/3 {
			egen misscount_`x'= rowmiss(path_type_`x'-path_ipm_date_`x'_3_stata)
			foreach var of varlist path_type_`x'-path_ipm_date_`x'_3_stata {
				capture confirm numeric variable `var'
				if _rc==0 replace `var'=.s if misscount_`x'==16
				else replace `var'=".s" if misscount_`x'==16
			}
			order misscount_`x', after(path_ipm_date_`x'_3_stata)
			drop misscount_`x'
		}
	
		forval x= 1/3 {
			forval y= 1/3 {
				egen misscount_`x'_`y'= rowmiss(path_ipm_type_`x'_`y'-path_ipm_date_`x'_`y'_stata)
				foreach var of varlist path_ipm_type_`x'_`y'-path_ipm_date_`x'_`y'_stata {
					capture confirm numeric variable `var'
					if _rc==0 replace `var'=.s if misscount_`x'_`y'==4
					else replace `var'=".s" if misscount_`x'_`y'==4
				}
				order misscount_`x'_`y', after(path_ipm_date_`x'_`y'_stata)
				drop misscount_`x'_`y'
			}
		}
	
		forval x= 1/30 {
			egen misscount_`x'= rowmiss(harvest_date_`x'-harvest_unit_`x')
			foreach var of varlist harvest_date_`x'-harvest_unit_`x' {
				capture confirm numeric variable `var'
				if _rc==0 replace `var'=.s if misscount_`x'==4
				else replace `var'=".s" if misscount_`x'==4
			}
			order misscount_`x', after(harvest_unit_`x')
			drop misscount_`x'
		}
				
		*-> Notes
		replace notes=".s" if missing(notes)

		*-> Check all missing values have been cleaned
		foreach var of varlist _all {
			display as input "Variable: `var'"
			capture confirm numeric variable `var'
			if _rc==0 {
				replace `var'= .m if `var'==.
				count if `var'==.m
				if r(N)>0 {
					tablist crop sow_type sow_date sow_med `var' if `var'==.m, sort(v) ab(32)
					*pause
				}
			}
			else {
				replace `var'=".m" if `var'==""
				count if `var'==".m"
				if r(N)>0 {
					tablist crop sow_type sow_date sow_med `var' if `var'==".m", sort(v) ab(32)
					*pause
				}
			}
		}

	/* Save clean TBF Market Garden 2025 data */
	***isid crop sow_date
	quietly compress
	save "$root\modified_data\tbf_market_garden_data_2025_clean.dta", replace
	export excel "$root\modified_data\tbf_market_garden_data_2025_clean.xlsx", firstrow(variables) replace
	
 
*=========================================================================================
* IV) DESCRIPTIVE STATISTICS
*=========================================================================================     
	
	describe _all


log close _all
