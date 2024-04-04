//Datasets for this code are in CARNE as indicated in the working directory


cd "C:\Commodity pricing\Data\working_copies_David\generatingRegressions\data\processed"
use "land_use_major_crops_cases_agshare_gdp_pop_merged_copy", clear

//transform outcomes
foreach var in rescued labor_tips_settlement case_settlement {
    gen `var'pc = (`var'/popnumeric) * 100000
    gen log`var'2 = log(`var'+1)
    gen log`var'pc = log(`var'pc+1)
    gen asinh`var'pc = asinh(`var'pc)
}

//transform of treatments 
foreach var in liveCattlePrice coalAPI2Price thermalCoalPrice mcCloskeyCoalPrice goldPrice PigsPrice ironOrePrice forestformation_diff{
    gen log`var'2 = log(`var'+1)
    gen asinh`var'= asinh(`var')
}


//transform of controls 
foreach var in popnumeric{
    gen log`var'2 = log(`var'+1)
    gen asinh`var'= asinh(`var')
}


************************DO NOT EXECUTE: LUMBER PRICES CONTAIN NEGATIVES; WEIRD CLOSE PRICES***********************************
/*
// Including Lumber

clear
* Change the working directory
cd "C:\Commodity pricing\Data\working_copies_David\generatingRegressions\data\raw"

* Import the CSV file
import delimited Lumber_1058643NNET.csv

* Check the format of the 'date' variable, assuming it is named 'date'
describe date

* Start in the raw data directory and perform your data manipulations
split date, parse("/") gen(date_part)
gen year = real(date_part3)
collapse (mean) close, by(year)
rename close Lumber_1058643NNET
keep if year >= 2004 & year <= 2021


* Sort the current dataset in descending order by year
sort year

* Save the intermediate result in the current directory
save collapsed_data.dta, replace

* Change to the directory where the land use file is located
cd "C:\Commodity pricing\Data\working_copies_David\generatingRegressions\data\processed"

* Load the land use data
use land_use_major_crops_cases_agshare_gdp_pop_merged_copy.dta, clear

* Sort the land use data in descending order by year
sort year

* Merge with the "collapsed_data" file
merge m:1 year using "C:\Commodity pricing\Data\working_copies_David\generatingRegressions\data\raw\collapsed_data.dta"


* given that lumber only has availability from 2006 to 2021, I am imputing 
*with a moving average from the 2006, 2007, and 2008 

/*
  Result                           # of obs.
    -----------------------------------------
    not matched                        11,143
        from master                    11,143  (_merge==1)
        from using                          0  (_merge==2)
    matched                            85,189  (_merge==3)
    -----------------------------------------
*/

* Calculate the average of Lumber_1058643NNET for 2006, 2007, and 2008
egen avg_Lumber = mean(Lumber_1058643NNET) if inrange(year, 2006, 2008)

* Store the average in a scalar
scalar avg_Lumber_value = avg_Lumber[1]

* Replace Lumber_1058643NNET values for the year 2004 and 2005 with the calculated average
replace Lumber_1058643NNET = scalar(avg_Lumber_value) if year == 2004 | year == 2005

* Save the merged file in the processed directory
*save land_use_major_crops_cases_agshare_gdp_pop_merged_copy.dta, replace
*/

*Continue: transformation of treatments
rename quant_cattle_heads cattle_heads

* Encode the string variable 'muncode7' to a numeric variable 'muncode_num'
encode muncode7, gen(muncode_num)

*===========================================================================================
*Set panel data
xtset muncode_num year

*===========================================================================================
*Set globals
global controls gdp

*===========================================================================================

*generate price shock variables

*gen logprice=ln(us_central_spot) ---done throught the transformations

/* there is not charcoal prices
gen prod_2000=charcoal_tons/1000 if rescue_year==2000
bysort mun_id_res: replace prod_2000=prod_2000[_n-1] if prod_2000==.
gen coalprod_coalprice=prod_2000*logprice
*/ 

gen cattleprod_catteleprice=cattle_heads*liveCattlePrice

**region time trend
egen state_year=group(state year)


*===========================================================================================
*globals
global controls logpop
*==========================================================================================
/* This does not work
*Defining logcase
* Define logcase as the list of generated logarithmic and asinh variables
local logcase logrescued2 logrescuedpc asinhrescuedpc loglabor_tips_settlement2 loglabor_tips_settlementpc asinhlabor_tips_settlementpc logcase_settlement2 logcase_settlementpc asinhcase_settlementpc


***TABLE 1. INCIDENTS PER CAPITA ****** 

est clear
*A) event per capita + others via oilrev
foreach i in logcase{
eststo: quietly xi: reghdfe `i' cattleprod_cattelepric i.year, a(muncode_num) vce(cluster state) 
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
eststo: quietly xi: reghdfe `i' coalprod_coalprice i.year, a(muncode_num state year ) vce(cluster state) 
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

*/

* Define logcase as the list of generated logarithmic and asinh variables
local logcase logrescued2 logrescuedpc asinhrescuedpc loglabor_tips_settlement2 loglabor_tips_settlementpc asinhlabor_tips_settlementpc logcase_settlement2 logcase_settlementpc asinhcase_settlementpc

* Clear existing stored estimates
est clear

* Loop over each variable in logcase and run the regressions
foreach i of local logcase {
    eststo: quietly reghdfe `i' cattleprod_cattleprice i.year, a(muncode_num) vce(cluster state)
    estadd local controls
    estadd local countryFE YES
    estadd local yearfe YES
    estadd local continenttimetrend
    preserve
    keep if e(sample)==1
    sum `i'
    global mean_outcome = r(mean)
    estadd local mean_outcome `mean_outcome'
    restore

    eststo: quietly reghdfe `i' cattleprod_cattleprice i.year, a(muncode_num state_year) vce(cluster state)
    estadd local controls
    estadd local countryFE YES
    estadd local yearfe YES
    estadd local continenttimetrend YES
    preserve
    keep if e(sample)==1
    sum `i'
    global mean_outcome = r(mean)
    estadd local mean_outcome `mean_outcome'
    restore
}


*Table
esttab est*, keep(cattleprod_cattleprice) t star(* 0.10 ** 0.05 *** 0.01)

esttab using "incidents_percapita.csv", replace f b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 controls countryFE yearfe continenttimetrend mean_outcome, fmt(0 3) label("Observations" "R2" ///
"Controls" "Country FE" "Year FE"  "State linear time trend" "mean(outcome)")) ///
keep(cattleprod_cattleprice) ///
coeflabel(cattleprod_cattleprice "Prod (2004)*log(price)" )

