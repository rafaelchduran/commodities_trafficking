/****************************
*Population
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
cd "/Users/rafaeljafetchduran/Dropbox/HumanTraffickingBrazil/Data_raw/Population/Data/"
/*
Brazil population: https://www.ibge.gov.br/estatisticas/sociais/populacao/9103-estimativas-de-populacao.html?=&t=downloads

*/

foreach i in 2000 2001 2002 2003 2004 2005 2006 {
global year `i'
import excel "pop_$year.xls",  clear
rename A state
rename B state_num
rename C mun_code
rename D municipality
rename E population
capture drop F
tostring state_num, replace
tostring mun_code, replace
gen length=strlen(mun_code)
gen mun_id=state_num+"000"+mun_code if length==1
replace mun_id=state_num+"00"+mun_code if length==2
replace mun_id=state_num+"0"+mun_code if length==3
replace mun_id=state_num+mun_code if length==4
foreach i in state_num mun_code mun_id{
destring `i', replace
}
drop mun_code length
gen year=$year
order state state_num mun_id municipality year population
save "../Stata/pop_$year.dta", replace
}

foreach i in 2008{
global year `i'
import excel "pop_$year.xls",  clear
rename A state
rename B state_num
rename C mun_code
rename D municipality
rename E population
capture drop F
tostring state_num, replace
*tostring mun_code, replace
gen length=strlen(mun_code)
gen mun_code2=substr(mun_code,1,4) if length>4
gen mun_id=state_num+mun_code2
foreach i in state_num mun_code mun_id{
destring `i', replace
}
drop mun_code length mun_code2
gen year=$year
order state state_num mun_id municipality year population
save "../Stata/pop_$year.dta", replace
}

foreach i in 2009 {
global year `i'
import excel "pop_$year.xls",  clear
rename A state
rename B state_num
rename C mun_code
rename D municipality
rename E population
sort municipality
capture drop F G H
tostring state_num, replace
tostring mun_code, replace
gen length=strlen(mun_code)
gen mun_id=state_num+"0000"+mun_code if length==1
replace mun_id=state_num+"000"+mun_code if length==2
replace mun_id=state_num+"00"+mun_code if length==3
gen mun_code2=substr(mun_code,1,4) if length>4
replace mun_id=state_num+"0"+mun_code if length==4
replace mun_id=state_num+mun_code2 if length==5
drop mun_code2
gen mun_id2=substr(mun_id,1,6)
drop mun_id
rename mun_id2 mun_id
foreach i in state_num mun_code mun_id population{
destring `i', replace force
}
drop mun_code length
gen year=$year
order state state_num mun_id municipality year population
drop if mun_id==.
capture drop F 
capture drop G 
capture drop H
capture drop I
capture drop J
capture drop K
capture drop L
capture drop M
capture drop N
save "../Stata/pop_$year.dta", replace
}


foreach i in 2009 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021{
global year `i'
import excel "pop_$year.xls",  clear
rename A state
rename B state_num
rename C mun_code
rename D municipality
rename E population
capture drop F G H
tostring state_num, replace
tostring mun_code, replace
gen length=strlen(mun_code)
gen mun_id=state_num+"000"+mun_code if length==1
replace mun_id=state_num+"00"+mun_code if length==2
replace mun_id=state_num+"0"+mun_code if length==3
gen mun_code2=substr(mun_code,1,4) if length>4
replace mun_id=state_num+mun_code if length==4
replace mun_id=state_num+mun_code2 if length==5
drop mun_code2
foreach i in state_num mun_code mun_id population{
destring `i', replace force
}
drop mun_code length
gen year=$year
order state state_num mun_id municipality year population
drop if mun_id==.
capture drop F 
capture drop G 
capture drop H
capture drop I
capture drop J
capture drop K
capture drop L
capture drop M
capture drop N
save "../Stata/pop_$year.dta", replace
}

foreach i in 2021{
global year `i'
import excel "pop_$year.xlsx",  clear
rename A state
rename B state_num
rename C mun_code
rename D municipality
rename E population
capture drop F G H
tostring state_num, replace
tostring mun_code, replace
gen length=strlen(mun_code)
gen mun_id=state_num+"000"+mun_code if length==1
replace mun_id=state_num+"00"+mun_code if length==2
replace mun_id=state_num+"0"+mun_code if length==3
gen mun_code2=substr(mun_code,1,4) if length>4
replace mun_id=state_num+mun_code if length==4
replace mun_id=state_num+mun_code2 if length==5
drop mun_code2
foreach i in state_num mun_code mun_id population{
destring `i', replace force
}
drop mun_code length
gen year=$year
order state state_num mun_id municipality year population
drop if mun_id==.
capture drop F 
capture drop G 
capture drop H
capture drop I
capture drop J
capture drop K
capture drop L
capture drop M
capture drop N
save "../Stata/pop_$year.dta", replace
}

use "../Stata/pop_2000.dta", clear
append using "../Stata/pop_2001.dta"
append using "../Stata/pop_2002.dta"
append using "../Stata/pop_2003.dta"
append using "../Stata/pop_2004.dta"
append using "../Stata/pop_2005.dta"
append using "../Stata/pop_2006.dta"
append using "../Stata/pop_2008.dta"
append using "../Stata/pop_2009.dta"
append using "../Stata/pop_2011.dta"
append using "../Stata/pop_2012.dta"
append using "../Stata/pop_2013.dta"
append using "../Stata/pop_2014.dta"
append using "../Stata/pop_2015.dta"
append using "../Stata/pop_2016.dta"
append using "../Stata/pop_2017.dta"
append using "../Stata/pop_2018.dta"
append using "../Stata/pop_2019.dta"
append using "../Stata/pop_2020.dta"
append using "../Stata/pop_2021.dta"

sort mun_id year
keep mun_id year population
save "../Stata/pop_2000_2021.dta", replace
