**************************************
*CHARCOAL PRODUCTION AND RESCUED CASES (Unemployment insurance)
**************************************
/**NOTES/TODOS
0. Try to replicate my dofile "5. regression_charcoal_priceshocks.do"
1. run this do file. 
2. Generate main regression tables
 
*/
clear all
set varabbrev off
*===========================================================================================
cd "C:\Users\rafaelch"

*===========================================================================================
*Load data
use "HumanTrafficking\Data_waste\uneployment_weverything.dta", clear

/*transform outcome variables: human trafficking
1. rescued
2. labor_tips_settlement
3. case_settlement

Control variables:
1. popnumeric

Treatments
1. Pig iron:
2. Gold:
3. Hog:
4. Cattle:
a. lc1
b. quant_cattle_heads
5. Charcoal: 
b. quant_charcoal_vegetation_tons
6. Lumber/timber: (David searches for International price)
b.

7. forestformation_diff (check if its deforestation)

*/

*Transformation of outcomes:
foreach var in rescued labor_tips_settlement case_settlement[
gen `var'pc=(`var'/popnumeric)*100000
gen log`var'2=log(`var'+1)
gen log`var'pc=log(`var'pc+1)
gen asinh`var'pc=asinh(`var'pc)
}

/*transform treatment variable: human trafficking
1. rescued
2. 
*/

*Transformation of treatments:
rename quant_charcoal_vegetation_tons charcoal_tons
rename quant_cattle_heads cattle_heads

foreach var in quant_cattle_heads charcoal_tons forestformation_diff{
gen log`var'=log(`var'+1)
gen asinh`var'=asinh(`var')
}


*Transformation of controls:
foreach var in popnumeric gdp{
gen log`var'=log(`var'+1)
gen asinh`var'=asinh(`var')
}


*===========================================================================================
*Set panel data
xtset muncode7 year

*===========================================================================================
**Transformations of the price variables:
*generate price shock variables

rename lc1 price_cattle
rename hl1 price_hogs
rename charcoallc13r price_charcoal


foreach var in price_cattle price_hogs price_timber price_charcoal{
gen log`var'=ln(`var')
}

*Create interactions:
gen charcoal_2004=charcoal_tons/1000 if year==2004
bysort muncode7: replace charcoal_2004 = charcoal_2004[_n-1] if charcoal_2004==.
gen charcoalprod_charcoalprice= charcoal_2004*logprice_charcoal


*===========================================================================================
**region time trend
egen state_year=group(state year)
tab state_year, gen(state_year_)

encode state, gen(state_num)

*****TILL HERE WE GENERATED RELEVANT VARIABLES.
*===========================================================================================
*Set globals
global controls logpopnumeric loggdp

*===========================================================================================
*****REGRESSION TABLES: 

***TABLE 1. Regression without controls ****** 

est clear
*A) LOGS REGRESSION WITHOUT PER CAPITA
foreach outcome in   logrescued loglabor_tips_settlement logcase_settlement{

eststo: xi: reghdfe `outcome' charcoalprod_charcoalprice i.year, a(muncode7 ) vce(cluster state) 
	estadd local controls NO
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend NO
	preserve
	keep if e(sample)==1
	sum `outcome'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: xi: reghdfe `outcome' charcoalprod_charcoalprice i.year, a(muncode7 state_year) vce(cluster state) 
	estadd local controls NO
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `outcome'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep(charcoalprod_charcoalprice) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "trafficking.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls countryFE yearfe continenttimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Municipal FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep(charcoalprod_charcoalprice) ///
coeflabel(charcoalprod_charcoalprice "Charcoal tons(2004)*log(price)" )


*===========================================================================================
***TABLE 2. Regression with controls ****** 

est clear
*A) LOGS REGRESSION WITHOUT PER CAPITA
foreach outcome in   logrescued loglabor_tips_settlement logcase_settlement{

eststo: xi: reghdfe `outcome' charcoalprod_charcoalprice i.year $controls, a(muncode7 ) vce(cluster state) 
	estadd local controls NO
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend NO
	preserve
	keep if e(sample)==1
	sum `outcome'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
eststo: xi: reghdfe `outcome' charcoalprod_charcoalprice i.year $controls, a(muncode7 state_year) vce(cluster state) 
	estadd local controls NO
	estadd local countryFE YES
	estadd local yearfe YES
	estadd local continenttimetrend YES
	preserve
	keep if e(sample)==1
	sum `outcome'
	global mean_outcome: di %5.4f  r(mean)
	estadd local mean_outcome $mean_outcome
	restore
}
	
*Table
esttab est*, keep(charcoalprod_charcoalprice) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "trafficking.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls countryFE yearfe continenttimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Municipal FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep(charcoalprod_charcoalprice) ///
coeflabel(charcoalprod_charcoalprice "Charcoal tons(2004)*log(price)" )

