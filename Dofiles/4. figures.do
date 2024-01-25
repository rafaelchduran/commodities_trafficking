/****************************
*Figures
*Paper: Commodity Price Shocks and Human Trafficking in Brazil
*Author: Ch, Rafael
****************************/
/*Notes
There are three cases:
1. separating muns by CSI measures, irrigation method
2. separating muns by CSI measures, rainfed method
3. separating muns by SIDRA measures
*/
*========================================================================
*Environment
clear all
set more off  
set varabbrev off 
*========================================================================
*Working Directory
cd "/Users/rafaeljafetchduran/Dropbox/HumanTraffickingBrazil/Commodities/CommoditiesTraffickingBrazil/Dofiles"
*=======================================================================
*SET THEME FOR GRAPHS 
set scheme s1color
set scheme plottig 

*=======================================================================
*FIGURES
use "../../Data/commoditypriceshock_unemployment_final.dta", clear

*=========
*A) Wheat
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:
preserve
use "../../Data/commoditypriceshock_unemployment_v1.dta", clear
sum wheat_mean, d
kdensity wheat_mean, normal
sum wheat_rainfed_mean, d
sum wheat_sidra, d
hist wheat_sidra
restore

foreach i in wheat{
gen `i'_mun=0
replace `i'_mun=1 if `i'_mean>0
gen `i'_rainfed_mun=0
replace `i'_rainfed_mun=1 if `i'_rainfed_mean>0
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>0
}

*1. CSI measures, irrigation method
preserve
foreach i in wheat{
	
collapse (sum) case (mean)`i', by(`i'_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_mun==1, yaxis(1)  ytitle("Price US$/bu")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu")) ///
title("Mean trafficking cases in" "`i' and non-`i' municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean violence in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_cases_prices_bycsi.png", as(png) replace
}

restore
 
*2. CSI measures, rainfed method (expect no difference)
preserve
foreach i in wheat{
	
collapse (sum) case (mean)`i', by(`i'_rainfed_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_rainfed_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_rainfed_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_rainfed_mun==1, yaxis(1)  ytitle("Price US$/bu")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu")) ///
title("Mean trafficking cases in" "`i' and non-`i' rain-fed municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_rainfed_cases_prices_bycsi.png", as(png) replace
}

restore

*3. SIDRA measures

preserve
foreach i in wheat{
	
collapse (sum) case (mean)`i', by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/bu")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu")) ///
title("Mean trafficking cases in" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities producing" " `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore

*=========
*B) Cattle heads
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:
preserve
use "../../Data/commoditypriceshock_unemployment_v1.dta", clear
sum cattle_heads_sidra, d
kdensity cattle_heads_sidra, normal
hist cattle_heads_sidra
restore

foreach i in cattle_heads{
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>0
}


*SIDRA measures for livecattle

preserve
drop cattle_heads
rename livecattle cattle_heads
foreach i in cattle_heads{
	
collapse (sum) case (mean)`i' feedercattle, by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/lb.")) ///
			 (line feedercattle rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/lb.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "live `i' price US$/lb.") ///
			 lab(4 "feeder `i' price US$/lb.")) ///
title("Mean trafficking cases in live" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities" " producing `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore

*=========
*C) Corn
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:
foreach i in corn{
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>0
}


*3. SIDRA measures

preserve
foreach i in corn{
	
collapse (sum) case (mean)`i', by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/bu")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu")) ///
title("Mean trafficking cases in" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities producing" " `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore

*=========
*D) Cocoa
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:
foreach i in cocoa{
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>0
}


*3. SIDRA measures

preserve
foreach i in cocoa{
	
collapse (sum) case (mean)`i', by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/MT")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/MT")) ///
title("Mean trafficking cases in" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities producing" " `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore

*=========
*E) Lumber
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:
preserve
use "../../Data/commoditypriceshock_unemployment_v1.dta", clear
sum treecover_2000_mean, d
kdensity treecover_2000_mean, normal
restore



*1. Tree coverage
preserve

foreach i in lumber{
	rename treecover_2000_mean tree_mean
foreach j in tree{
gen `j'_mun=0
replace `j'_mun=1 if `j'_mean>0


	
collapse (sum) case (mean)`i', by(`j'_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `j'_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `j'_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `j'_mun==1, yaxis(1)  ytitle("Price US$/1000 board feet")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`j' municipalities") lab(2 "`j' municipalities") lab(3 "`i' price US$/1000 board feet")) ///
title("Mean trafficking cases in" "`j' and non-`j' municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities with wide tree" "coverage from GFW.")
graph export "../Figures/`i'_cases_prices_treecoverage.png", as(png) replace
}
}

restore
 

*2. SIDRA wood measures
preserve

foreach i in lumber{
foreach j in wood{
gen `j'_sidra_mun=0
replace `j'_sidra_mun=1 if `j'_sidra>0

collapse (sum) case (mean)`i', by(`j'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `j'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `j'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `j'_sidra_mun==1, yaxis(1)  ytitle("Price US$/1000 board feet")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`j' municipalities") lab(2 "`j' municipalities") lab(3 "`i' price US$/1000 board feet")) ///
title("Mean trafficking cases in" "`j' and non-`j'  municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities with" " `j' coverage using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_`j'.png", as(png) replace
}
}

restore


*=========
*F) Cotton
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:

foreach i in cotton{
gen `i'_mun=0
replace `i'_mun=1 if `i'_mean>0
gen `i'_rainfed_mun=0
replace `i'_rainfed_mun=1 if `i'_rainfed_mean>0
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>-0.10
}

*1. CSI measures, irrigation method
preserve
foreach i in cotton{
	
collapse (sum) case (mean)`i', by(`i'_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_mun==1, yaxis(1)  ytitle("Price US$/lb.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/lb.")) ///
title("Mean trafficking cases in" "`i' and non-`i' municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean violence in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_cases_prices_bycsi.png", as(png) replace
}

restore
 
*2. CSI measures, rainfed method
preserve
foreach i in cotton{
	
collapse (sum) case (mean)`i', by(`i'_rainfed_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_rainfed_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_rainfed_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_rainfed_mun==1, yaxis(1)  ytitle("Price US$/lb.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/lb.")) ///
title("Mean trafficking cases in" "`i' and non-`i' rain-fed municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_rainfed_cases_prices_bycsi.png", as(png) replace
}

restore

*3. SIDRA measures

preserve
foreach i in cotton{
	
collapse (sum) case (mean)`i', by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/lb.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/lb.")) ///
title("Mean trafficking cases in" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities producing" " `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore


*=========
*G) Soybean
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:

foreach i in soybean{
gen `i'_mun=0
replace `i'_mun=1 if `i'_mean>0
gen `i'_rainfed_mun=0
replace `i'_rainfed_mun=1 if `i'_rainfed_mean>0
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>-0.19
}

*1. CSI measures, irrigation method
preserve
foreach i in soybean{
	
collapse (sum) case (mean)`i', by(`i'_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_mun==1, yaxis(1)  ytitle("Price US$/bu.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu.")) ///
title("Mean trafficking cases in" "`i' and non-`i' municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean violence in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_cases_prices_bycsi.png", as(png) replace
}

restore
 
*2. CSI measures, rainfed method
preserve
foreach i in soybean{
	
collapse (sum) case (mean)`i', by(`i'_rainfed_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_rainfed_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_rainfed_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_rainfed_mun==1, yaxis(1)  ytitle("Price US$/bu.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu.")) ///
title("Mean trafficking cases in" "`i' and non-`i' rain-fed municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_rainfed_cases_prices_bycsi.png", as(png) replace
}

restore

*3. SIDRA measures

preserve
foreach i in soybean{
	
collapse (sum) case (mean)`i', by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/bu.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu.")) ///
title("Mean trafficking cases in" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities producing" " `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore


*=========
*H) Oats
*=========
*Get trafficking case for wheat and non-wheat producing municipalities:

foreach i in oats{
gen `i'_mun=0
replace `i'_mun=1 if `i'_mean>0
gen `i'_rainfed_mun=0
replace `i'_rainfed_mun=1 if `i'_rainfed_mean>0
gen `i'_sidra_mun=0
replace `i'_sidra_mun=1 if `i'_sidra>-0.13
}

*1. CSI measures, irrigation method
preserve
foreach i in oats{
	
collapse (sum) case (mean)`i', by(`i'_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_mun==1, yaxis(1)  ytitle("Price US$/bu.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu.")) ///
title("Mean trafficking cases in" "`i' and non-`i' municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean violence in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_cases_prices_bycsi.png", as(png) replace
}

restore
 
*2. CSI measures, rainfed method
preserve
foreach i in oats{
	
collapse (sum) case (mean)`i', by(`i'_rainfed_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_rainfed_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_rainfed_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_rainfed_mun==1, yaxis(1)  ytitle("Price US$/bu.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu.")) ///
title("Mean trafficking cases in" "`i' and non-`i' rain-fed municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities suitable" "for `i' from Galor and Ozark (2016).")
graph export "../Figures/`i'_rainfed_cases_prices_bycsi.png", as(png) replace
}

restore

*3. SIDRA measures

preserve
foreach i in oats{
	
collapse (sum) case (mean)`i', by(`i'_sidra_mun rescue_year)
label variable case "Human trafficking cases"
graph twoway (line case rescue_year if `i'_sidra_mun==0, yaxis(2) ytitle("Human trafficking cases")) ///
			 (line case rescue_year if `i'_sidra_mun==1, yaxis(2) ytitle("Human trafficking cases")) ///
             (line `i' rescue_year if `i'_sidra_mun==1, yaxis(1)  ytitle("Price US$/bu.")) ///
			 , legend(position(11) cols(1) ring(0) lab(1 "no-`i' municipalities") lab(2 "`i' municipalities") lab(3 "`i' price US$/bu.")) ///
title("Mean trafficking cases in" "`i' and non-`i' SIDRA municipalities," "and the price of `i'") xtitle("year") ///
note("Note: This figure shows the (log) int. price of `i', as well as mean trafficking in municipalities producing" " `i' using SIDRA estimates from the 90s.")
graph export "../Figures/`i'_cases_prices_bysidra.png", as(png) replace
}

restore













