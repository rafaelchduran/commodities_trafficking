**************************************
*CHARCOAL PRODUCTION AND RESCUED CASES (Unemployment insurance)
**************************************
/**NOTES/TODOS
1. run controlling for GDP at constant prices. Population is not needed since cases are per capita. 
2. interaction with place of birth change 
 
*/
clear all
set varabbrev off
*===========================================================================================
cd "C:\Users\rafaelch"

*===========================================================================================
*Load data
use "HumanTrafficking\Data_waste\uneployment_weverything.dta", clear

*transform variables
gen casepc=(case/population)*100000
gen logcase2=log(case+1)
gen logcase=log(casepc+1)
gen asinhcase=asinh(casepc)
gen logcharcoal_tons=log(charcoal_tons+1)
gen asinhcharcoal_tons=asinh(charcoal_tons)
*===========================================================================================
*Set panel data
xtset mun_id_res rescue_year

*===========================================================================================
*Set globals
global controls gdp_real

*===========================================================================================
*merge prices
preserve
insheet using "HumanTrafficking\Data_raw\CharcoalPrice\coal-prices.csv", clear
rename year rescue_year
save "HumanTrafficking\Data_raw\CharcoalPrice\coal-prices.dta", replace
restore

merge m:m rescue_year using "HumanTrafficking\Data_raw\CharcoalPrice\coal-prices.dta"
drop if _merge==2
drop _merge

*prices from: https://ourworldindata.org/grapher/coal-prices
*===========================================================================================
*generate price shock variables

gen logprice=ln(us_central_spot)
gen prod_2000=charcoal_tons/1000 if rescue_year==2000
bysort mun_id_res: replace prod_2000=prod_2000[_n-1] if prod_2000==.
gen coalprod_coalprice=prod_2000*logprice

gen logprice2=ln(japan_cook)
gen coalprod_coalprice2=prod_2000*logprice2

gen logprice3=ln(northwest_europe)
gen coalprod_coalprice3=prod_2000*logprice3


**region time trend
egen state_year=group(state rescue_year)
tab state_year, gen(state_year_)

gen logpop=log(population)
*===========================================================================================
*globals
global controls logpop
*===========================================================================================
***TABLE 1. INCIDENTS PER CAPITA ****** 

est clear
*A) event per capita + others via oilrev
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' coalprod_coalprice i.rescue_year, a(mun_id_res ) vce(cluster state) 
	estadd local controls 
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' coalprod_coalprice i.rescue_year, a(mun_id_res state_year) vce(cluster state) 
	estadd local controls 
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' coalprod_coalprice i.rescue_year $controls, a(mun_id_res ) vce(cluster state) 
	estadd local controls YES
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' coalprod_coalprice i.rescue_year $controls, a(mun_id_res state_year) vce(cluster state) 
	estadd local controls YES
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep(coalprod_coalprice ) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "incidents_percapita.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls countryFE yearfe continenttimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Country FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep(coalprod_coalprice) ///
coeflabel(coalprod_coalprice "Prod (2000)*log(price)" )

*===========================================================================================
***TABLE 2. WITH JAPANESE COOKING PRICE: EFFECTS ARE SMALLER***

est clear
*A) event per capita + others via oilrev
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' coalprod_coalprice2 i.rescue_year, a(mun_id_res ) vce(cluster state) 
	estadd local controls 
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' coalprod_coalprice2 i.rescue_year, a(mun_id_res state_year) vce(cluster state) 
	estadd local controls 
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' coalprod_coalprice2 i.rescue_year $controls, a(mun_id_res ) vce(cluster state) 
	estadd local controls YES
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' coalprod_coalprice2 i.rescue_year $controls, a(mun_id_res state_year) vce(cluster state) 
	estadd local controls YES
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep(coalprod_coalprice2 ) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "incidents_percapita_placebo.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls countryFE yearfe continenttimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Country FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep(coalprod_coalprice2) ///
coeflabel(coalprod_coalprice2 "Prod (2000)*log(price Japan)" )

*===========================================================================================
***TABLE 3. WITH NORTHWESTERN EUROPE PRICES: EFFECTS ARE SMALLER***

est clear
*A) event per capita + others via oilrev
foreach i in   logcase{
eststo: quietly xi: reghdfe `i' coalprod_coalprice3 i.rescue_year, a(mun_id_res ) vce(cluster state) 
	estadd local controls 
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' coalprod_coalprice3 i.rescue_year, a(mun_id_res state_year) vce(cluster state) 
	estadd local controls 
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}

foreach i in  case {
eststo: quietly xi: reghdfe `i' coalprod_coalprice3 i.rescue_year $controls, a(mun_id_res ) vce(cluster state) 
	estadd local controls YES
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend 
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: quietly xi: reghdfe `i' coalprod_coalprice3 i.rescue_year $controls, a(mun_id_res state_year) vce(cluster state) 
	estadd local controls YES
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `i'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep(coalprod_coalprice3 ) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "incidents_percapita_placebo2.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls countryFE yearfe continenttimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Country FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep(coalprod_coalprice3) ///
coeflabel(coalprod_coalprice3 "Prod (2000)*log(price Europe)" )



