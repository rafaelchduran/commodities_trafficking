/****************************
*Main regressions
*Paper: Commodity Price Shocks and Human Trafficking in Brazil
*Author: Ch, Rafael
****************************/
/*Notes
*/
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
use "../../Data/commoditypriceshock_unemployment_final.dta", clear
*========================================================================
*Set panel data
xtset mun_id_res rescue_year
*========================================================================
*Set globals
global interactions wheat_logwheat wheat_logwheat_rain oats_logoats oats_logoats_rain soybean_logsoybean soybean_logsoybean_rain coffee_logcoffee coffee_logcoffee_rain cotton_logcotton cotton_logcotton_rain tree_loglumber

global interactions2 csi_logavgprice

global sidra_interactions wheat_logwheat_sidra oats_logoats_sidra soybean_logsoybean_sidra coffee_logcoffee_sidra cotton_logcotton_sidra wood_loglumber rubber_logrubber_sidra rice_logrice_sidra  cocoa_logcocoa_sidra sugar_logsugar_sidra  corn_logcorn_sidra     cattle_heads_loglivecattle cattle_heads_logfeedercattle

global sidra_interactions2 wheat_logwheat_sidra oats_logoats_sidra soybean_logsoybean_sidra coffee_logcoffee_sidra cotton_logcotton_sidra wood_loglumber

global controls logpop 
*========================================================================
/*Install packages
ssc install reghdfe
ssc install ftools
*/
*========================================================================
*Same sample:
quietly xi: reghdfe logcase $sidra_interactions i.rescue_year, a(mun_id_res) vce(cluster state) 
keep if e(sample)==1
quietly xi: reghdfe logcase $interactions i.rescue_year, a(mun_id_res) vce(cluster state) 
keep if e(sample)==1
*========================================================================
*Table 1: all commodities, CSI 
est clear
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' $interactions i.rescue_year, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' $interactions i.rescue_year state_year_*, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' $interactions i.rescue_year $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' $interactions i.rescue_year state_year_* $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep($interactions) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "../Tables/all_commodities.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls munFE yearfe regiontimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Mun FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep($interactions) ///
coeflabel(wheat_logwheat "Wheat suitability (irrigated)*log(price)" ///
wheat_logwheat_rain "Wheat suitability (rainfed)*log(price)" ///
oats_logoats "Oats suitability (irrigated)*log(price)" ///
oats_logoats_rain "Oats suitability (rainfed)*log(price)" ///
soybean_logsoybean "Soybean suitability (irrigated)*log(price)" ///
soybean_logsoybean_rain "Soybean suitability (rainfed)*log(price)" ///
coffee_logcoffee "Coffee suitability (irrigated)*log(price)" ///
coffee_logcoffee_rain "Coffee suitability (rainfed)*log(price)" ///
cotton_logcotton "Cotton suitability (irrigated)*log(price)" ///
cotton_logcotton_rain "Cotton suitability (rainfed)*log(price)" ///
tree_loglumber "Tree Coverage (in 2000))*log(price)" )

           

*========================================================================
*Table 2: avg. CSI
est clear
foreach commodity in $interactions2{
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' `commodity' i.rescue_year, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' `commodity' i.rescue_year state_year_*, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' `commodity' i.rescue_year $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' `commodity' i.rescue_year state_year_* $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
}
	
*Table
esttab est*, keep($interactions2) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "../Tables/csi_average_commodities.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls munFE yearfe regiontimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Mun FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep($interactions2) ///
coeflabel(csi_logavgprice "Avg. Caloric Suitability Index*log(avg. commodity prices)")

*========================================================================
*Table 3: all commodities, sidra_interactions
est clear
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' $sidra_interactions i.rescue_year, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' $sidra_interactions i.rescue_year state_year_*, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' $sidra_interactions i.rescue_year $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' $sidra_interactions i.rescue_year state_year_* $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep($sidra_interactions) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "../Tables/all_commodities_sidra.csv", compress replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls munFE yearfe regiontimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Mun FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep($sidra_interactions)  ///
coeflabel(wheat_logwheat_sidra "Wheat prod. (90s)*log(price)" ///
oats_logoats_sidra "Oats prod. (90s)*log(price)" ///
soybean_logsoybean_sidra "Soybean prod. (90s)*log(price)" ///
coffee_logcoffee_sidra "Coffee prod. (90s)*log(price)" ///
cotton_logcotton_sidra "Cotton prod. (90s)*log(price)" ///
wood_loglumber "Wood prod. (90s)*log(price)" ///
rubber_logrubber_sidra "Rubber prod. (90s)*log(price)" ///
rice_logrice_sidra "Rice prod. (90s)*log(price)" ///
cocoa_logcocoa_sidra "Cocoa prod. (90s)*log(price)" ///
sugar_logsugar_sidra "Sugarcane prod. (90s)*log(price)" ///
corn_logcorn_sidra "Corn prod. (90s)*log(price)" ///
cattle_heads_loglivecattle "Cattle heads (90s)*log(live cattle price)" ///
cattle_heads_logfeedercattle "Cattle heads (90s)*log(feeder cattle price)" )


*========================================================================
/*Table 4: all commodities, sidra_interactions2 (comparable sample to that of CSI)
est clear
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' $sidra_interactions2 i.rescue_year, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' $sidra_interactions2 i.rescue_year state_year_*, a(mun_id_res) vce(cluster state) 
	estadd local controls NO
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' $sidra_interactions2 i.rescue_year $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend NO 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' $sidra_interactions2 i.rescue_year state_year_* $controls, a(mun_id_res) vce(cluster state) 
	estadd local controls YES
	estadd local munFE YES
	estadd local yearfe YES
	estadd local regiontimetrend YES 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep($sidra_interactions2) t star(* 0.10 ** 0.05 *** 0.01)

                  
esttab using "../Tables/all_commodities_sidra.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls munFE yearfe regiontimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Mun FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep($sidra_interactions2) ///
coeflabel(wheat_logwheat_sidra "Wheat prod. (90s)*log(price)" ///
oats_logoats_sidra "Oats prod. (90s)*log(price)" ///
soybean_logsoybean_sidra "Soybean prod. (90s)*log(price)" ///
coffee_logcoffee_sidra "Coffee prod. (90s)*log(price)" ///
cotton_logcotton_sidra "Cotton prod. (90s)*log(price)" ///
wood_loglumber "Wood prod. (90s)*log(price)" ///
rubber_logrubber_sidra "Rubber prod. (90s)*log(price)" ///
rice_logrice_sidra "Rice prod. (90s)*log(price)" ///
cocoa_logcocoa_sidra "Cocoa prod. (90s)*log(price)" ///
sugar_logsugar_sidra "Sugarcane prod. (90s)*log(price)" ///
corn_logcorn_sidra "Corn prod. (90s)*log(price)" ///
cattle_heads_loglivecattle "Cattle heads (90s)*log(live cattle price)" ///
cattle_heads_logfeedercattle "Cattle heads (90s)*log(feeder cattle price)" )





