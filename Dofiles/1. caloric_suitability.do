/****************************
*Caloric suitability database
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
*Import commodity price dataset:
insheet using "../../Data/brazil_muns_caloric_suitability_bycrop.csv", clear

keep cd_mun nm_mun sigla_uf area_km2 wheatmmean-muns_treecover_mean_2000_treecov
drop muns_treecover_mean_2000_cd_mun
rename wheatmmean wheat_mean
rename wheatmrain wheat_rainfed_mean
rename oatmmean oats_mean
rename oatmrainme oats_rainfed_mean
rename soybeanmme soybean_mean
rename soybeanmra soybean_rainfed_mean
rename coffeemmea coffee_mean
rename coffeemrai coffee_rainfed_mean
rename sugarbeetm sugarbeet_mean
rename sugarbee_1 sugarbeet_rainfed_mean
rename sugarcanem sugarcane_mean
rename sugarcan_1 sugarcane_rainfed_mean
rename cottonmmea cotton_mean
rename cottonmrai cotton_rainfed_mean
rename csipreavgm csi_mean
rename  muns_treecover_mean_2000_treecov treecover_2000_mean
rename cd_mun mun_id
rename nm_mun mun_name
rename sigla_uf state_abbv

*Expand dataset:
gen year=2000
expand 22, gen(expandob) 
order year mun_id 
sort mun_id mun_name year expandob

ds year mun_id mun_name expandob, not 
bysort mun_id: gen n=_n-1
order year n

bysort mun_id: replace year = year+n 
drop expandob 
drop n

*Save dataset:
save "../../Data/caloric_suitability_bycrop.dta", replace

 
 