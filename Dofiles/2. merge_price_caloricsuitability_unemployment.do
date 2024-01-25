/****************************
*Merge prices + caloric suitability + unemployment
*Paper: Commodity Price Shocks and Human Trafficking in Brazil
*Author: Ch, Rafael
****************************/
*========================================================================
*Environment
clear all
set more off  
set varabbrev off 
*========================================================================
*Working Directory
cd "/Users/rafaeljafetchduran/Dropbox/HumanTraffickingBrazil/Commodities/CommoditiesTraffickingBrazil/Dofiles"
*========================================================================
*Merge
use "../../Data/sidra_pop_price_caloric_suitability_bycrop.dta", clear
rename year rescue_year
rename mun_id mun_id_res

merge m:m rescue_year mun_id_res using "../../Data/Unemp/uneployment_weverything.dta"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         5,642
        from master                     5,639  (_merge==1) = missing 2021 and few others
        from using                          3  (_merge==2) = missing some of 2021

    Matched                           116,945  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge


save "../../Data/commoditypriceshock_unemployment_v1.dta", replace

