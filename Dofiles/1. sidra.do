/****************************
*SIDRA data: Commodities and cattle 
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
*Cattle heads
  insheet using "../../Data/AgricultureProduction/production_livestock/quant_cattle.csv", ///
      clear
keep cd_municipality nu_year value
rename cd_municipality mun_id_res
rename nu_year  rescue_year
rename value cattle_heads
lab variable cattle_heads "Cattle heads"
destring cattle_heads, replace force

sort mun_id_res rescue_year

drop if rescue_year>2000 | rescue_year<1990
collapse (mean)cattle_heads, by(mun_id_res)
lab variable cattle_heads "Cattle heads, average 90s"

*Edit mun_id 
tostring mun_id_res, replace
gen str mun_id_res2 = substr(mun_id_res,1,6)
drop mun_id_res
rename mun_id_res2 mun_id_res
destring mun_id_res, replace
br

order mun_id_res cattle_heads
sort mun_id_res cattle_heads

**Save dataset:
save "../../Data/cattle_heads.dta", replace

*========================================================================
*Round wood 
  insheet using "../../Data/AgricultureProduction/production extraction/quantidade produzida na extraa_a_o vegetal_madeira em tora.csv", ///
      clear
keep cd_municipality nu_year value
rename cd_municipality mun_id_res
rename nu_year  rescue_year
rename value wood
lab variable wood "Wood, cubic meters"
destring wood, replace force

sort mun_id_res rescue_year

drop if rescue_year>2000 | rescue_year<1990
collapse (mean)wood, by(mun_id_res)
lab variable wood "Wood, cubic meters, average 90s"

*Edit mun_id 
tostring mun_id_res, replace
gen str mun_id_res2 = substr(mun_id_res,1,6)
drop mun_id_res
rename mun_id_res2 mun_id_res
destring mun_id_res, replace
br

order mun_id_res wood
sort mun_id_res wood

**Save dataset:
save "../../Data/wood.dta", replace

*========================================================================
*Other crops
foreach i in rubber rice wheat cacao canesugar coffee corn cotton oats rye sorghum soybean tobacco{ 
  insheet using "../../Data/AgricultureProduction/production_crops/quant_`i'.csv", clear
keep cd_municipality nu_year value
rename cd_municipality mun_id_res
rename nu_year  rescue_year
rename value `i'
lab variable `i' "`i', tons"
destring `i', replace force

sort mun_id_res rescue_year

drop if rescue_year>2000 | rescue_year<1990
collapse (mean)`i', by(mun_id_res)
lab variable `i' "`i', tons, average 90s"

*Edit mun_id 
tostring mun_id_res, replace
gen str mun_id_res2 = substr(mun_id_res,1,6)
drop mun_id_res
rename mun_id_res2 mun_id_res
destring mun_id_res, replace
br

order mun_id_res `i'
sort mun_id_res `i'

**Save dataset:
save "../../Data/`i'.dta", replace
}

*Merge all datasets 
use "../../Data/rubber.dta", clear
merge 1:1 mun_id_res using "../../Data/rice.dta", nogen
merge 1:1 mun_id_res using "../../Data/wheat.dta", nogen
merge 1:1 mun_id_res using "../../Data/cacao.dta", nogen
merge 1:1 mun_id_res using "../../Data/canesugar.dta", nogen
merge 1:1 mun_id_res using "../../Data/coffee.dta", nogen
merge 1:1 mun_id_res using "../../Data/corn.dta", nogen
merge 1:1 mun_id_res using "../../Data/cotton.dta", nogen
merge 1:1 mun_id_res using "../../Data/oats.dta", nogen
merge 1:1 mun_id_res using "../../Data/rye.dta", nogen
merge 1:1 mun_id_res using "../../Data/sorghum.dta", nogen
merge 1:1 mun_id_res using "../../Data/soybean.dta", nogen
merge 1:1 mun_id_res using "../../Data/tobacco.dta", nogen
merge 1:1 mun_id_res using "../../Data/wood.dta", nogen
merge 1:1 mun_id_res using "../../Data/cattle_heads.dta", nogen

rename rubber rubber_sidra
rename wheat wheat_sidra
rename cacao cacao_sidra
rename rice rice_sidra
rename canesugar sugarcane_sidra
rename coffee coffee_sidra
rename corn corn_sidra
rename cotton cotton_sidra
rename oats oats_sidra
rename rye rye_sidra
rename sorghum sorghum_sidra
rename soybean soybean_sidra
rename tobacco tobacco_sidra
rename wood wood_sidra
rename cattle_heads cattle_heads_sidra
rename mun_id_res mun_id 

*Save
save "../../Data/commodities_sidra.dta", replace

