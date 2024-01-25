/****************************
*Merge prices with caloric suitability
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
*Load data
use "../../Data/caloric_suitability_bycrop.dta", clear



*===============
*merge prices
merge m:m year using "../../Data/commodities_prices_byyear.dta"
drop _merge
sort mun_id year

/*
rename corn corn_price
rename wheat wheat_price 
rename oats oats_price 
rename roughrice roughrice_price
rename soybean soybean_price
rename soybeanmeal soybeanmeal_price 
rename soybeanoil soybeanoil_price
rename canola canola_price
rename cocoa cocoa_price
rename coffee coffee_price
rename sugar  sugar_price
rename orangejuice orangejuice_price
rename cotton cotton_price
rename wool wool_price
rename lumber lumber_price
rename rubber rubber_price
rename  ethanol  ethanol_price 
rename livecattle livecattle_price 
rename feedercattle  feedercattle_price 
rename leanhogs leanhogs_price
*/
global commodities corn wheat oats roughrice soybean soybeanmeal soybeanoil canola cocoa coffee sugar orangejuice cotton wool lumber rubber ethanol livecattle feedercattle leanhogs

*Generate logs:
foreach i in $commodities{
gen log`i'=log(`i')	
lab variable `i' "International price"
lab variable log`i' "log(International price)"
}

*Save
save "../../Data/price_caloric_suitability_bycrop.dta", replace

*===============
*merge population
merge m:m year using "../../../Data_raw/Population/Stata/pop_2000_2021.dta"
// missing 2007 (count), and 2010 (census) see https://www.ibge.gov.br/en/statistics/social/population.html 
drop _merge
sort mun_id year

*Edit mun_id 
tostring mun_id, replace
gen str mun_id2 = substr(mun_id,1,6)
drop mun_id
rename mun_id2 mun_id
order year mun_id
destring mun_id, replace
br

save "../../Data/pop_price_caloric_suitability_bycrop.dta", replace

*===============
*merge SIDRA crops
merge m:m mun_id using "../../Data/commodities_sidra.dta"
drop if _merge==2
drop _merge
sort mun_id year

save "../../Data/sidra_pop_price_caloric_suitability_bycrop.dta", replace



