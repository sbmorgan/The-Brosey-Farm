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
***    I) CREATE ANALYSIS INDICATORS                                                          ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: September 26, 2023   	   					 	     			              ***
*** Last date modified: January 29, 2024                                                      ***
***                                                                                           ***
*** Notes:                                                                                    ***
***                                                                                           ***
***                                                                                           ***
*************************************************************************************************


*=========================================================================================
* 0) SET UP CODE
*=========================================================================================	

/* Set do-file preferences */
	clear all
	version 18.0
	set more off
	set varabbrev off
	pause off

/* Set seed */
	set seed 7122023
	
/* Define globals */

	*Root
	global root "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics"
    adopath ++ "$root"
	
	
*=========================================================================================
* I) CREATE ANALYSIS INDICATORS
*=========================================================================================
	
	/* Load clean TBF Market Garden 2023 data */
	use "$root\modified_data\tbf_market_garden_data_2023_clean.dta", clear
	
	/* Harvest */
	
	*-> Number of plants harvested
	generate c_harvest_no_plant=.c
	label variable c_harvest_no_plant "number of plants harvested"
	replace c_harvest_no_plant=transp_no_end_1 if sow_type=="indoor seed" & transp_no_end_2==.s
	replace c_harvest_no_plant=transp_no_end_2 if sow_type=="indoor seed" & transp_no_end_2!=.s // Use final transplant number if multiple transplantings (e.g., from seed tray to small container (1), then to garden plot (2))
	replace c_harvest_no_plant= (sow_no_thin_per * sow_no_cellrowhill) if sow_type=="outdoor seed" & crop_code!=8 // "& crop_code!=8" to exclude a calculation for the garlic that has not germinated yet. Planted in FA23 for harvest SU24.
	replace c_harvest_no_plant=transp_no_end_1 if sow_type=="external transplant" // These are starts purchased outside the farm.
	tablist sow_date sow_type crop transp_no_end_1 transp_no_end_2 sow_no_thin_per sow_no_cellrowhill c_harvest_no_plant, sort(v) ab(32)
	table crop, statistic(total c_harvest_no_plant)
	
	*-> Total harvest- weight
	tablist crop crop_code harvest_unit_1, sort(v) ab(32) nolabel
	generate flag_crop_wt= inlist(crop_code,1,2,5,6,8,9) | inlist(crop_code,10,16,17,18,19,20) 
	tablist crop crop_code flag_crop_wt harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_wt "flags crops not harvested by weight"
	
	generate c_harvest_total_wtoz= 0
	replace c_harvest_total_wtoz= .c if flag_crop_wt==0 
	label variable c_harvest_total_wtoz "total harvest- weight, ounces"
	
	generate c_harvest_total_wtoz_prev=0
	replace c_harvest_total_wtoz_prev= .c if flag_crop_wt==0 
	label variable c_harvest_total_wtoz_prev "total harvest- weight, ounces (previous sum in loop iteration)"
	
	forval x=1/30 {
		capture confirm string variable harvest_unit_`x'
		if _rc==0 {
			replace c_harvest_total_wtoz= c_harvest_total_wtoz + harvest_amnt_`x' if harvest_unit_`x'=="ounce" & flag_crop_wt==1
			replace c_harvest_total_wtoz= c_harvest_total_wtoz + (harvest_amnt_`x' * 16) if harvest_unit_`x'=="pound" & flag_crop_wt==1
			tablist flag_crop_wt crop c_harvest_total_wtoz harvest_amnt_`x' harvest_unit_`x' c_harvest_total_wtoz_prev, sort(v) ab(32)
			*pause
			replace c_harvest_total_wtoz_prev= c_harvest_total_wtoz if flag_crop_wt==1
		}
		else assert harvest_unit_`x'==.s // No harvest collected.
	} 
	assert c_harvest_total_wtoz==.c if flag_crop_wt==0 
	table crop if flag_crop_wt==1, statistic(total c_harvest_total_wtoz)
	drop c_harvest_total_wtoz_prev
	
	clonevar c_harvest_total_wtlb= c_harvest_total_wtoz
	label variable c_harvest_total_wtlb "total harvest- weight, pounds"
	replace c_harvest_total_wtlb= c_harvest_total_wtlb/16 if flag_crop_wt==1
	tablist flag_crop_wt crop sow_date c_harvest_total_wtlb c_harvest_total_wtoz, sort(v) ab(32)
	tablist flag_crop_wt crop sow_date sow_date_stata c_harvest_total_wtlb c_harvest_total_wtoz if crop_code==21, sort(v) ab(32) // The ornamental corn was harvested all together and not separated by sow date.
	replace c_harvest_total_wtoz=.c if crop_code==21 & sow_date=="2023-06-10"
	replace c_harvest_total_wtlb=.c if crop_code==21 & sow_date=="2023-06-10"
	tablist flag_crop_wt crop sow_date c_harvest_total_wtlb c_harvest_total_wtoz, sort(v) ab(32)
	assert c_harvest_total_wtlb==.c if flag_crop_wt==0 
	table crop if flag_crop_wt==1, statistic(total c_harvest_total_wtlb)	

	*-> Total harvest- unit
	tablist crop crop_code harvest_unit_1 harvest_amnt_1, sort(v) ab(32) nolabel
	generate flag_crop_unit= inlist(crop_code,17,20)
	tablist crop crop_code flag_crop_unit harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_unit "flags crops harvested by unit"
	
	generate c_harvest_total_unit= 0
	replace c_harvest_total_unit= .c if flag_crop_unit==0
	label variable c_harvest_total_unit "total harvest- units"
	
	generate c_harvest_total_unit_prev=0
	replace c_harvest_total_unit_prev= .c if flag_crop_unit==0
	label variable c_harvest_total_unit_prev "total harvest- units (previous sum in loop iteration)"
	
	forval x=1/30 {
		capture confirm string variable harvest_unit_`x'
		if _rc==0 {
			replace c_harvest_total_unit= c_harvest_total_unit + harvest_amnt_`x' if inlist(harvest_unit_`x',"unit","small","medium","large") & flag_crop_unit==1
			tablist flag_crop_unit crop c_harvest_total_unit harvest_amnt_`x' c_harvest_total_unit_prev, sort(v) ab(32)
			*pause
			replace c_harvest_total_unit_prev= c_harvest_total_unit if flag_crop_unit==1
		} 
		else assert harvest_unit_`x'==.s // No harvest collected.
	}
	assert c_harvest_total_unit==.c if flag_crop_unit==0
	table crop if flag_crop_unit==1, statistic(total c_harvest_total_unit)
	drop c_harvest_total_unit_prev

	*-> Total harvest- unit size: small, medium, larg
	tablist crop crop_code harvest_unit_1 harvest_amnt_1, sort(v) ab(32) nolabel
	generate flag_crop_unit_size= inlist(crop_code,17)
	tablist crop crop_code flag_crop_unit_size harvest_unit_1, sort(v) ab(32) nolabel
	label variable flag_crop_unit_size "flags crops harvested by unit size"
	
	local size_list1 sml med lrg
	local size_list2 small medium large
	forval x =1/3 {
		
		local sz1 : word `x' of `size_list1'
		local sz2 : word `x' of `size_list2'

		display as input "size1; `sz1' , size2: `sz2'"
		
		generate c_harvest_total_unit_`sz1'= 0
		replace c_harvest_total_unit_`sz1'= .c if flag_crop_unit_size==0
		label variable c_harvest_total_unit_`sz1' "total harvest- units `sz2'"
		
		generate c_harvest_total_unit_prev_`sz1'= 0
		replace c_harvest_total_unit_prev_`sz1'= .c if flag_crop_unit_size==0
		label variable c_harvest_total_unit_prev_`sz1' "total harvest- units `sz2' (previous sum in loop iteration)"
	
		forval x=1/30 {
			capture confirm string variable harvest_unit_`x'
			if _rc==0 {
				replace c_harvest_total_unit_`sz1'=  c_harvest_total_unit_`sz1' + harvest_amnt_`x' if harvest_unit_`x' == "`sz2'" & flag_crop_unit_size==1
				tablist flag_crop_unit_size crop c_harvest_total_unit_`sz1' harvest_unit_`x' harvest_amnt_`x' c_harvest_total_unit_prev_`sz1', sort(v) ab(32)
				pause
				replace c_harvest_total_unit_prev_`sz1'= c_harvest_total_unit_`sz1' if flag_crop_unit_size==1
			} 
			else assert harvest_unit_`x'==.s // No harvest collected.
		}
		assert c_harvest_total_unit_`sz1'==.c if flag_crop_unit_size==0
		table crop if flag_crop_unit_size==1, statistic(total c_harvest_total_unit_`sz1')
		drop c_harvest_total_unit_prev_`sz1'
	}
	
	/* Save TBF Market Garden 2023 data with analysis indicators */
	drop flag_*
	quietly compress
	save "$root\modified_data\tbf_market_garden_data_2023_clean_indicators.dta", replace
	
	/* Descriptive statistics */
	des c_*
	summarize c_*, detail
	
   
log close _all