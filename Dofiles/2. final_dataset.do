/****************************
*Final dataset
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
*Load dataset
use "../../Data/commoditypriceshock_unemployment_v1.dta", clear
*========================================================================
/*Install packages
ssc install center
*/
*========================================================================
*Variable generation
global commodities wheat oats soybean  coffee cotton

*A) Human trafficking:
gen casepc=(case/population)*100000
gen logcase2=log(case+1)
gen logcase=log(casepc+1)
gen asinhcase=asinh(casepc)
gen logcharcoal_tons=log(charcoal_tons+1)
gen asinhcharcoal_tons=asinh(charcoal_tons)

*B) Average price: 
egen avgprice=rowmean($commodities)
gen logavgprice=log(avgprice+1)

*B) Price shock and production interactions:
*Standardize
global commodities_csi wheat_mean oats_mean soybean_mean  coffee_mean cotton_mean
global commodities_csi_rainfed wheat_rainfed_mean oats_rainfed_mean soybean_rainfed_mean  coffee_rainfed_mean cotton_rainfed_mean
center $commodities_csi $commodities_csi_rainfed treecover_2000_mean csi_mean, standardize inplace

foreach i in $commodities{
gen `i'_log`i'=	`i'_mean*log`i'	
gen `i'_log`i'_rain= `i'_rainfed_mean*log`i'	
}

*For other commodities:
gen tree_loglumber= treecover_2000_mean*loglumber	
gen csi_logavgprice= csi_mean*logavgprice	

*For SIDRA commodities: 
rename logroughrice logrice
rename cacao_sidra cocoa_sidra
rename sugarcane_sidra sugar_sidra

global sidra *_sidra
center $sidra, standardize inplace
**interactions 
global sidra2 rubber rice wheat cocoa sugar coffee corn cotton oats soybean
foreach i in $sidra2{
gen `i'_log`i'_sidra=	`i'_sidra*log`i'	
}

**for cattle and wood
gen wood_loglumber= wood_sidra*loglumber	
gen cattle_heads_loglivecattle= cattle_heads_sidra*loglivecattle	
gen cattle_heads_logfeedercattle= cattle_heads_sidra*logfeedercattle	

*C) Region time trend:
egen state_year=group(state rescue_year)
tab state_year, gen(state_year_)

*D) Controls:
gen logpop=log(population+1)
gen logdp=log(gdp_real+1)

*========================================================================
*Check for duplicates:
quietly bysort mun_id_res rescue_year:  gen dup = cond(_N==1,0,_n)
drop if dup>1 // municipality with same mun_id 
drop dup
*========================================================================
*Save dataset
save "../../Data/commoditypriceshock_unemployment_final.dta", replace
