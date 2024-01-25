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

*===========================================================================================
*FOR GIS
preserve
keep state state_num mun_id_res municipality rescue_year  population case casepc logcase logcase2 charcoal_tons logcharcoal_tons asinhcharcoal_tons

reshape wide  population case casepc logcase logcase2 charcoal_tons logcharcoal_tons asinhcharcoal_tons state state_num municipality, i( mun_id_res) j(rescue_year)
export delimited using "HumanTrafficking\GIS\charcoal_trafficking_2002_2020.csv", replace

*create cumulative years
foreach i in case{
egen `i'_2002_2005=rowtotal(`i'2002 `i'2003 `i'2004 `i'2005)
egen `i'_2006_2010=rowtotal(`i'2006 `i'2007 `i'2007 `i'2009 `i'2010)
egen `i'_2011_2015=rowtotal(`i'2011 `i'2012 `i'2013 `i'2014 `i'2015)
egen `i'_2016_2018=rowtotal(`i'2016 `i'2017 `i'2018)
}

foreach i in charcoal_tons population{
egen `i'_2002_2005=rowmean(`i'2002 `i'2003 `i'2004 `i'2005)
egen `i'_2006_2010=rowmean(`i'2006 `i'2007 `i'2007 `i'2009 `i'2010)
egen `i'_2011_2015=rowmean(`i'2011 `i'2012 `i'2013 `i'2014 `i'2015)
egen `i'_2016_2018=rowmean(`i'2016 `i'2017 `i'2018)
}



foreach i in case charcoal_tons{
gen `i'_2002_2005pc=(`i'_2002_2005/population_2002_2005)*100000
gen `i'_2006_2010pc=(`i'_2006_2010/population_2006_2010)*100000
gen `i'_2011_2015pc=(`i'_2011_2015/population_2011_2015)*100000
gen `i'_2016_2018pc=(`i'_2016_2018/population_2016_2018)*100000
}

foreach i in case charcoal_tons{
gen log`i'_2002_2005pc=log(`i'_2002_2005/population_2002_2005)
gen log`i'_2006_2010pc=log(`i'_2006_2010/population_2006_2010)
gen log`i'_2011_2015pc=log(`i'_2011_2015/population_2011_2015)
gen log`i'_2016_2018pc=log(`i'_2016_2018/population_2016_2018)
}


foreach i in case charcoal_tons{
gen log`i'_2002_2005=log(`i'_2002_2005)
gen log`i'_2006_2010=log(`i'_2006_2010)
gen log`i'_2011_2015=log(`i'_2011_2015)
gen log`i'_2016_2018=log(`i'_2016_2018)
}

keep mun_id_res state2002 state_num2002  case_2002_2005- logcharcoal_tons_2016_2018

/*create correlations:
collapse 
foreach i in 2002_2005 2006_2010 2011_2015 2016_2018{
bysort state_num2002: corr case_`i'pc charcoal_tons_`i'
return list
bysort state_num2002: di r(rho)
bysort state_num2002: gen rho_`i' = r(rho)
}

*/
 

export delimited using "HumanTrafficking\GIS\charcoal_trafficking_2002_2020_waggregates.csv", replace
restore
*===========================================================================================
*A.1 EXTENSIVE MARGIN
*standardize variables
preserve
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_perc

*center `variables', inplace standardize

*set panel
xtset mun_id_res rescue_year

*run regression
est clear
foreach treatment in logcharcoal_tons  {
foreach outcome in casepc {
eststo: quietly xi: areg `outcome' F.`treatment' F.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' `treatment' $controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L.`treatment' L.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L2.`treatment'  L2.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L3.`treatment' L3.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
}


esttab est*, keep( F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
 t star(* 0.1 ** 0.05 *** 0.01)


esttab using "HumanTrafficking\Outputs\Tables\charcoal_regression.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 MunFE YearFE, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE")) ///
keep(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
coeflabel(F.`treatment' "lead 1 year - log(Charcoal) (tons)" `treatment' "log(Charcoal) (tons)" L.`treatment' "lag 1 year-log(Charcoal) (tons)" ///
L2.`treatment' "lag 2 years-log(Charcoal) (tons)" L3.`treatment' "lag 3 years-log(Charcoal) (tons)") ///
label collabels(none) nonotes nobooktabs nomtitles f

}
restore
*"If we increase x by one percent, we expect y to increase by (β1/100) units of y." So the effect is really small.

*===========================================================================================
*A.2 EXTENSIVE MARGIN INTERACTION WITH CHANGE OF PLACE OF BIRTH 
preserve
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_perc change_birth_place

center `variables', inplace standardize

*set panel
xtset mun_id_res rescue_year

*global
global interaction change_birth_place

*run regression
est clear
foreach treatment in logcharcoal_tons  {
foreach outcome in logcase {
eststo: quietly xi: areg `outcome' c.F.`treatment'##c.$interaction F.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[F1.`treatment']+_b[cF.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[F1.`treatment']+_b[cF.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly  xi: areg `outcome' c.`treatment'##c.$interaction $controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[`treatment']+_b[c.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[`treatment']+_b[c.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly xi: areg `outcome' cL.`treatment'##c.$interaction L.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[L.`treatment']+_b[cL.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[L.`treatment']+_b[cL.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly xi: areg `outcome' cL2.`treatment'##c.$interaction L2.$control i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[L2.`treatment']+_b[cL2.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[L2.`treatment']+_b[cL2.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly xi: areg `outcome' cL3.`treatment'##c.$interaction L3.$control i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[L3.`treatment']+_b[cL3.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[L3.`treatment']+_b[cL3.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue

esttab using "HumanTrafficking\Outputs\Tables\charcoal_regression_interaction.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 MunFE YearFE tot_int pvalue, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE" "Tot.Int." "p-value(Tot.Int.)")) ///
keep( F.`treatment' cF.`treatment'#c.$interaction /// 
`treatment'  c.`treatment'#c.$interaction ///
L.`treatment' cL.`treatment'#c.$interaction ///
L2.`treatment' cL2.`treatment'#c.$interaction ///
L3.`treatment' cL3.`treatment'#c.$interaction) ///
order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
coeflabel(F.`treatment' "lead 1 year - log(Charcoal) (tons)" `treatment' "log(Charcoal) (tons)" L.`treatment' "lag 1 year-log(Charcoal) (tons)" ///
L2.`treatment' "lag 2 years-log(Charcoal) (tons)" L3.`treatment' "lag 3 years-log(Charcoal) (tons)" ////
*$interaction "Indicator change place birth" ///
cF.`treatment'#c.$interaction "Indicator*lead 1 year-log(Charcoal)" ///
c.`treatment'#c.$interaction "log(Charcoal)  (tons)" ///
cL.`treatment'#c.$interaction "Indicator*lag 1 year-log(Charcoal)" ///
cL2.`treatment'#c.$interaction "Indicator*lag 2 year-log(Charcoal)" ///
cL3.`treatment'#c.$interaction "Indicator*lag 3 year-log(Charcoal)")  ///
label collabels(none) nonotes nobooktabs nomtitles f
}
}


/*esttab est*, keep( F.`treatment' $interaction cF.`treatment'#c.$interaction /// 
`treatment' $interaction c.`treatment'#c.$interaction ///
L.`treatment' $interaction cL.`treatment'#c.$interaction ///
L2.`treatment' $interaction cL2.`treatment'#c.$interaction ///
L3.`treatment' $interaction cL3.`treatment'#c.$interaction)  ///
order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
 t star(* 0.1 ** 0.05 *** 0.01)
 }
 */

*esttab est*, keep( F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') t star(* 0.1 ** 0.05 *** 0.01)

restore

*===========================================================================================
*B.1 INTENSIVE MARGIN STATE LEVEL
preserve
bysort state rescue_year: egen state_charcoal_tons=sum(charcoal_tons)
replace state_charcoal_tons=0 if state_charcoal_tons==.
gen charcoal_state_perc=charcoal_tons/state_charcoal_tons

*standardize variables
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_perc

center `variables', inplace standardize

*set panel
xtset mun_id_res rescue_year

*run regression
est clear
foreach treatment in charcoal_state_perc  {
foreach outcome in logcase {
eststo: quietly xi: areg `outcome' F.`treatment' F.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' `treatment' $controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L.`treatment' L.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L2.`treatment' L2.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L3.`treatment' L3.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
}


esttab est*, keep( F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
 t star(* 0.1 ** 0.05 *** 0.01)


esttab using "HumanTrafficking\Outputs\Tables\charcoal_state_perc_regression.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 MunFE YearFE, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE")) ///
keep(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
coeflabel(F.`treatment' "lead 1 year - log(Charcoal) (tons)" `treatment' "log(Charcoal) (tons)" L.`treatment' "lag 1 year-log(Charcoal) (tons)" ///
L2.`treatment' "lag 2 years-log(Charcoal) (tons)" L3.`treatment' "lag 3 years-log(Charcoal) (tons)") ///
label collabels(none) nonotes nobooktabs nomtitles f

}

restore

*===========================================================================================
*B.2 INTENSIVE MARGIN STATE LEVEL * INTERACTION
preserve
bysort state rescue_year: egen state_charcoal_tons=sum(charcoal_tons)
replace state_charcoal_tons=0 if state_charcoal_tons==.
gen charcoal_state_perc=charcoal_tons/state_charcoal_tons

*standardize variables
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_perc

center `variables', inplace standardize

*set panel
xtset mun_id_res rescue_year

*global
global interaction change_birth_place


*run regression
est clear
foreach treatment in charcoal_state_perc  {
foreach outcome in logcase {
eststo: quietly xi: areg `outcome' c.F.`treatment'##c.$interaction F.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[F1.`treatment']+_b[cF.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[F1.`treatment']+_b[cF.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly  xi: areg `outcome' c.`treatment'##c.$interaction $controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[`treatment']+_b[c.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[`treatment']+_b[c.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly xi: areg `outcome' cL.`treatment'##c.$interaction L.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[L.`treatment']+_b[cL.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[L.`treatment']+_b[cL.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly xi: areg `outcome' cL2.`treatment'##c.$interaction L2.$control i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[L2.`treatment']+_b[cL2.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[L2.`treatment']+_b[cL2.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo: quietly xi: areg `outcome' cL3.`treatment'##c.$interaction L3.$control i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[L3.`treatment']+_b[cL3.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[L3.`treatment']+_b[cL3.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
}


esttab using "HumanTrafficking\Outputs\Tables\charcoal_state_perc_regression_interaction.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 MunFE YearFE tot_int pvalue, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE" "Tot.Int." "p-value(Tot.Int.)")) ///
keep( F.`treatment' cF.`treatment'#c.$interaction /// 
`treatment'  c.`treatment'#c.$interaction ///
L.`treatment' cL.`treatment'#c.$interaction ///
L2.`treatment' cL2.`treatment'#c.$interaction ///
L3.`treatment' cL3.`treatment'#c.$interaction) ///
order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
coeflabel(F.`treatment' "lead 1 year - log(Charcoal) (tons)" `treatment' "log(Charcoal) (tons)" L.`treatment' "lag 1 year-log(Charcoal) (tons)" ///
L2.`treatment' "lag 2 years-log(Charcoal) (tons)" L3.`treatment' "lag 3 years-log(Charcoal) (tons)" ////
*$interaction "Indicator change place birth" ///
cF.`treatment'#c.$interaction "Indicator*lead 1 year-log(Charcoal)" ///
c.`treatment'#c.$interaction "log(Charcoal)  (tons)" ///
cL.`treatment'#c.$interaction "Indicator*lag 1 year-log(Charcoal)" ///
cL2.`treatment'#c.$interaction "Indicator*lag 2 year-log(Charcoal)" ///
cL3.`treatment'#c.$interaction "Indicator*lag 3 year-log(Charcoal)")  ///
label collabels(none) nonotes nobooktabs nomtitles f


}

restore



*===========================================================================================
*C. INTENSIVE MARGIN NATIONAL LEVEL
preserve
bysort rescue_year: egen state_charcoal_tons=sum(charcoal_tons)
replace state_charcoal_tons=0 if state_charcoal_tons==.
gen charcoal_state_perc=charcoal_tons/state_charcoal_tons

*standardize variables
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_perc

center `variables', inplace standardize

*set panel
xtset mun_id_res rescue_year

*run regression
est clear
foreach treatment in charcoal_state_perc  {
foreach outcome in logcase {
eststo: quietly xi: areg `outcome' F.`treatment' F.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' `treatment' $controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L.`treatment' L.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L2.`treatment' L2.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo: quietly xi: areg `outcome' L3.`treatment' L3.$controls i.rescue_year if mun_id_res>100 & rescue_year>=2002, a(mun_id_res) r
	estadd local MunFE YES
	estadd local YearFE YES
}


esttab est*, keep( F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
 t star(* 0.1 ** 0.05 *** 0.01)


esttab using "HumanTrafficking\Outputs\Tables\charcoal_national_perc_regression.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2 MunFE YearFE, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE")) ///
keep(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
order(F.`treatment' `treatment' L.`treatment' L2.`treatment' L3.`treatment') ///
coeflabel(F.`treatment' "lead 1 year - log(Charcoal) (tons)" `treatment' "log(Charcoal) (tons)" L.`treatment' "lag 1 year-log(Charcoal) (tons)" ///
L2.`treatment' "lag 2 years-log(Charcoal) (tons)" L3.`treatment' "lag 3 years-log(Charcoal) (tons)") ///
label collabels(none) nonotes nobooktabs nomtitles f

}
restore

*===========================================================================================
*D.1 INTENSIVE MARGIN WITH OTHER CROPS 
preserve
use "HumanTrafficking\Data_waste\uneployment_weverything.dta", clear

keep if rescue_year>=2016
collapse (mean) Abacate-Mudas_mamao population gdp_real poor_percentage_2018 (sum) charcoal_tons case, by(state_num mun_id_res)
egen total_tons=rowtotal(Abacate-Mudas_mamao charcoal_tons )
gen charcoal_intensive=charcoal_tons/total_tons

*transform variables
gen casepc=(case/population)*100000
gen logcase2=log(case+1)
gen logcase=log(casepc+1)
gen asinhcase=asinh(casepc)
gen logcharcoal_tons=log(charcoal_tons+1)
gen asinhcharcoal_tons=asinh(charcoal_tons)

*standardize variables
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_intensive

center `variables', inplace standardize

*run regression
global interaction poor_percentage_2018
est clear
foreach treatment in charcoal_intensive  {
foreach outcome in logcase {
eststo:  xi: areg `outcome' `treatment' if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo:  xi: areg `outcome' `treatment' $controls poor_percentage_2018 if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo:  xi: areg `outcome' c.`treatment'##c.$interaction $controls  if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[`treatment']+_b[c.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[`treatment']+_b[c.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue

}


esttab est*, keep(  `treatment' c.`treatment'#c.poor_percentage_2018) t star(* 0.1 ** 0.05 *** 0.01)


esttab using "HumanTrafficking\Outputs\Tables\charcoal_intensive_regression.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2  MunFE tot_int pvalue, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE")) ///
keep( `treatment' c.`treatment'#c.poor_percentage_2018) ///
coeflabel( `treatment' "log(Charcoal) (tons)" c.`treatment'#c.poor_percentage_2018 "log(Charcoal)*Perc. Poor" ) ///
label collabels(none) nonotes nobooktabs nomtitles f

}
restore


*===========================================================================================
*D.2 INTENSIVE MARGIN WITH OTHER CROPS * INTERACTION
preserve
use "HumanTrafficking\Data_waste\uneployment_weverything.dta", clear

keep if rescue_year>=2016
collapse (mean) Abacate-Mudas_mamao population gdp_real poor_percentage_2018 change_birth_place (sum) charcoal_tons case, by(state_num mun_id_res)
egen total_tons=rowtotal(Abacate-Mudas_mamao charcoal_tons )
gen charcoal_intensive=charcoal_tons/total_tons
replace change_birth_place=0 if change_birth_place==.
*transform variables
gen casepc=(case/population)*100000
gen logcase2=log(case+1)
gen logcase=log(casepc+1)
gen asinhcase=asinh(casepc)
gen logcharcoal_tons=log(charcoal_tons+1)
gen asinhcharcoal_tons=asinh(charcoal_tons)

*standardize variables
local variables casepc logcase asinhcase charcoal_tons logcharcoal_tons asinhcharcoal_tons charcoal_intensive

center `variables', inplace standardize

*run regression
global interaction poor_percentage_2018
global interaction2 change_birth_place
est clear
foreach treatment in charcoal_intensive  {
foreach outcome in logcase {
eststo:  xi: areg `outcome' `treatment' if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo:  xi: areg `outcome' `treatment' $controls poor_percentage_2018 if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
eststo:  xi: areg `outcome' c.`treatment'##c.$interaction $controls  if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[`treatment']+_b[c.`treatment'#c.$interaction] = 0
	global total_interaction: di %5.4f _b[`treatment']+_b[c.`treatment'#c.$interaction]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue
eststo:  xi: areg `outcome' c.`treatment'##c.$interaction2 $controls  if mun_id_res>100, a(state_num) r
	estadd local MunFE YES
	estadd local YearFE YES
	test  _b[`treatment']+_b[c.`treatment'#c.$interaction2] = 0
	global total_interaction: di %5.4f _b[`treatment']+_b[c.`treatment'#c.$interaction2]
	estadd local tot_int $total_interaction
	global pvalue: di %5.4f r(p)
	estadd local pvalue $pvalue

}


esttab est*, keep(  `treatment' c.`treatment'#c.$interaction  c.`treatment'#c.$interaction2) t star(* 0.1 ** 0.05 *** 0.01)


esttab using "HumanTrafficking\Outputs\Tables\charcoal_intensive_regression.csv", replace b(%9.4f) se(%9.4f) se  star(* 0.10 ** 0.05 *** 0.01) ///
s(N r2  MunFE tot_int pvalue, fmt(0 3) label("Observations" "R2" "Mun FE" "Year FE")) ///
keep( `treatment' c.`treatment'#c.$interaction c.`treatment'#c.$interaction2 ) ///
coeflabel( `treatment' "log(Charcoal) (tons)" c.`treatment'#c.$interaction "log(Charcoal)*Perc. Poor" ///
c.`treatment'#c.$interaction2 "log(Charcoal)*Change Birth Place" ) ///
label collabels(none) nonotes nobooktabs nomtitles f

}
restore



