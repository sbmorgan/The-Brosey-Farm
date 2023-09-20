/******************************************************************************
* Copyright (C) The Brosey Farm, LLC. 
* This code cannot be copied, distributed or used without the express written permission
* of The Brosey Farm 
*******************************************************************************/

capture log close clean_01
log using "C:\Users\sethb\Documents\The Brosey Farm\GitHub repositories\The-Brosey-Farm\analytics\Stata_programs\04_tbf_data_2023_merge.log", replace name(clean_01)


*************************************************************************************************
***                                                                                           ***
*** Program name: 04_tbf_data_2023_merge.do                                                   ***
*** Project: TBF Market Garden 2023                                 				          ***
*** Purpose: Merge TBF Market Garden 2023 data and sales                                      ***    
***																	 				          ***
*** Contents:                                                       				          ***
***    0) SET UP CODE                              				                              ***
***    I)                                                                        ***
***    II)                                                                    ***
***    III)                                                                         ***
***    IV)                                                              ***
***                                                                                           ***
*** Authors: Seth B. Morgan                                 				                  ***
*** Start date: September 20, 2023   	   					 	     			              ***
*** Last date modified: September 20, 2023                                                    ***
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
	
	/* Load raw data */
	*use "$root\clean_data\tbf_market_garden_data_2023_clean.dta", clear
	

	*merge  "$root\clean_data\tbf_market_garden_sales_2023_clean.dta", replace
	
   
*=========================================================================================
* II) 
*=========================================================================================  

	/* Save raw TBF Market Garden 2023 data */
	*save "$root\raw_data\tbf_market_garden_data&sales_2023_clean.dta", replace
    



log close _all