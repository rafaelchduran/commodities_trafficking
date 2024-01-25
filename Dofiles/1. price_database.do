/****************************
*Price database
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
  import excel using "../../Data/CommodityPrices/Bloomberg/AG_clossingprice.xlsx", ///
         sheet("Sheet2") firstrow clear
drop in 1 // drop first row
drop C F I L O R U X AA AD AG AJ AM AP AS AV AY BB BE
rename C1COMDTY corn_date 
rename W1COMDTY wheat_date 
rename O1COMDTY oats_date
rename RRI roughrice_date
rename S1 soybean_date
rename SM1 soybeanmeal_date
rename BO1 soybeanoil_date
rename RS1 canola_date
rename CC1 cocoa_date
rename KC1 coffee_date
rename SB1 sugar_date
rename JO1 orangejuice_date
rename CT1 cotton_date
rename OL1 wool_date
rename LB1 lumber_date
rename OR1 rubber_date
rename DL1 ethanol_date
rename LC1 livecattle_date
rename FC1 feedercattle_date
rename LH1 leanhogs_date
rename *, lower
rename cotton2 cotton
rename sugar11 sugar
rename coffeec coffee
rename rubbersingapore rubber

global commodities corn wheat oats roughrice soybean soybeanmeal soybeanoil canola cocoa coffee sugar orangejuice cotton wool lumber rubber ethanol livecattle feedercattle leanhogs

foreach i in $commodities{
preserve
keep `i' `i'_date
rename `i'_date year_date
format %td year_date
gen year=year(year_date)
gen month=month(year_date)
gen day=day(year_date)
save "../../Data/`i'.dta", replace	
restore
}

use "../../Data/soybeanmeal.dta", clear

*Construct base price dataset: from Jan 1, 2000 to Dec. 31, 2021
clear
local start = date("2000/01/01", "YMD")
local end = date("2021/12/31", "YMD")

set obs `=`end'-`start'+1'

egen year_date = seq(), from(`start') to(`end')
format %td year_date

gen year=year(year_date)
gen month=month(year_date)
gen day=day(year_date)


*merge data:
global commodities corn wheat oats roughrice soybean soybeanmeal soybeanoil canola cocoa coffee sugar orangejuice cotton wool lumber rubber ethanol livecattle feedercattle leanhogs

foreach i in $commodities{
merge m:m year_date using "../../Data/`i'.dta"
drop if _merge==2
drop _merge
}

*Save dataset:
save "../../Data/commodities_prices_byday.dta", replace

**Dataset by month:
preserve
collapse (mean) corn-leanhogs, by(year month)
save "../../Data/commodities_prices_bymonth.dta", replace
restore
**Dataset by year:
collapse (mean) corn-leanhogs, by(year)
save "../../Data/commodities_prices_byyear.dta", replace

