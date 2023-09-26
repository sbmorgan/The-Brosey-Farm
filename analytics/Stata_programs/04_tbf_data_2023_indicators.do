/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\04_tbf_data_2023_indicators.log", replace name(clean_01)


*************************************************************************************************
***                                                                                           ***
*** Program name: 04_tbf_data_2023_indicators.do                                              ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Create Analysis Indicators for TBF Market Garden 2023 data                       ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I) LOAD DATA                                                                           ***
***    II) CREATE ANALYSIS INDICATORS                                                         ***
***    III)                                                                                   ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: September 26, 2023   	   					 	     			              ***
*** Last date modified: September 26, 2023                                                    ***
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
* I) LOAD DATA
*=========================================================================================
	
	/* Load clean TBF Market Garden 2023 data */
	use "$root\clean_data\tbf_market_garden_data_2023_clean.dta", clear
	
	
*=========================================================================================
* II) CREATE ANALYSIS INDICATORS
*=========================================================================================
	
	/* Harvest */
	
	*-> Total harvest- weight
	tablist crop crop_code harvest_unit_1, sort(v) ab(32) nolabel
	generate flag_crop_nowt= inlist(crop_code,1,2,5,6,8,9) | inlist(crop_code,16,17,18,19,20) 
	tablist crop crop_code flag_crop_nowt harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_nowt "flags crops not harvested by weight"
	
	generate c_harvest_total_wtoz= 0
	replace c_harvest_total_wtoz= .c if flag_crop_nowt==1 
	label variable c_harvest_total_wtoz "total harvest- weight, ounces"
	
	forval x=1/25 {
		capture confirm string variable harvest_unit_`x'
		if _rc==0 {
			replace c_harvest_total_wtoz= c_harvest_total_wtoz + harvest_amnt_`x' if harvest_unit_`x'=="ounce" & flag_crop_nowt==0
			replace c_harvest_total_wtoz= c_harvest_total_wtoz + (harvest_amnt_`x' * 16) if harvest_unit_`x'=="pound" & flag_crop_nowt==0
		}
		else assert harvest_unit_`x'==.s // No harvest collected.
	} 
	assert c_harvest_total_wtoz==.c if flag_crop_nowt==1 
	table crop if flag_crop_nowt==0, statistic(total c_harvest_total_wtoz)
	
	clonevar c_harvest_total_wtlb= c_harvest_total_wtoz
	label variable c_harvest_total_wtlb "total harvest- weight, pounds"
	replace c_harvest_total_wtlb= c_harvest_total_wtlb/16 if flag_crop_nowt==0
	assert c_harvest_total_wtlb==.c if flag_crop_nowt==1 
	table crop if flag_crop_nowt==0, statistic(total c_harvest_total_wtlb)	

	*-> Total harvest- unit
	tablist crop crop_code harvest_unit_1, sort(v) ab(32) nolabel
	generate flag_crop_nout= !inlist(crop_code,16,19,20)
	tablist crop crop_code flag_crop_nout harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_nout "flags crops not harvested by unit"
	
	generate c_harvest_total_unit= 0
	replace c_harvest_total_unit= .c if flag_crop_nout==1 
	label variable c_harvest_total_unit "total harvest- units"
	
	forval x=1/25 {
		capture confirm string variable harvest_unit_`x'
		if _rc==0 {
			replace c_harvest_total_unit= c_harvest_total_unit + harvest_amnt_`x' if inlist(harvest_unit_`x',"unit","small","medium","large") & flag_crop_nout==0
		} 
		else assert harvest_unit_`x'==.s // No harvest collected.
	}
	assert c_harvest_total_unit==.c if flag_crop_nout==1 
	table crop if flag_crop_nout==0, statistic(total c_harvest_total_unit)

	/* Save TBF Market Garden 2023 data with analysis indicators */
	drop flag_*
	quietly compress
	save "$root\clean_data\tbf_market_garden_data_2023_clean_indicators.dta", replace
	
   
*=========================================================================================
* III) 
*=========================================================================================  

	/* */
	des c_*
	summarize c_*, detail
    

log close _all