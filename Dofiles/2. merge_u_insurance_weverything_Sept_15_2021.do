*New Dataset

clear all
*=============================
*Set working directory
cd "C:\Users\rafaelch"

*===========================================================================================
*Load population dataset
use "HumanTrafficking\Data_raw\PopulationIBGE\pop_2000_2020.dta", clear
quietly bysort state_num mun_id year:  gen dup = cond(_N==1,0,_n)
*generate population of 2015 that is an average between 2014 and 2016.
replace year=2015 if year==2014 & dup==2 
replace population=. if year==2015
replace population=(population[_n+1]+population[_n-1])/2 if year==2015
drop dup
preserve 
collapse population state_num (firstnm) state municipality, by(mun_id)
drop population
gen year=2007
order state state_num mun_id municipality year
tempfile year2007
save `year2007'
restore
append using `year2007'
preserve 
collapse population state_num (firstnm) state municipality, by(mun_id)
drop population
gen year=2010
order state state_num mun_id municipality year
tempfile year2010
save `year2010'
restore
append using `year2010'
sort mun_id year
replace population=(population[_n+1]+population[_n-1])/2 if year==2007
replace population=(population[_n+1]+population[_n-1])/2 if year==2010
rename mun_id mun_id_res
rename year rescue_year
*tempfile population
*save `population'
*N=5,571 approx * 20 years = 111,270  approx

*===========================================================================================
*Merge unemployment dataset

preserve
import delimited using "HumanTrafficking\Data_waste\unemployment_insurance_copy2.csv", clear 

tostring cd_municipio_ibge_res, replace
gen mun_id_res_str=substr(cd_municipio_ibge_res,1,6)
destring mun_id_res_str, gen(mun_id_res)

tostring cd_municipio_ibge_nat, replace
gen mun_id_birth_str=substr(cd_municipio_ibge_nat,1,6)
destring mun_id_birth_str, force gen(mun_id_birth)

gen same_mun=0
replace same_mun=1 if mun_id_birth==mun_id_res
tab same_mun
/*
   same_mun |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     15,648       42.84       42.84
          1 |     20,876       57.16      100.00
------------+-----------------------------------
      Total |     36,524      100.00


*/

*transform dates:
*1) rescue date
generate rescue_date=date(dt_resgate_requerente,"DMY") 
format rescue_date %tdnn/dd/CCYY
gen rescue_day=day(rescue_date)
gen rescue_month=month(rescue_date)
gen rescue_year=year(rescue_date)


*2) trafficking date 
generate trafficking_began_date=date(dt_admissao_requerente,"DMY") 
format trafficking_began_date %tdnn/dd/CCYY
gen trafficking_began_day=day(rescue_date)
gen trafficking_began_month=month(rescue_date)
gen trafficking_began_year=year(rescue_date)

*3) birth date 
generate birth_date=date(dt_nascimento,"DMY") 
format birth_date %tdnn/dd/CCYY
gen birth_day=day(birth_date)
gen birth_month=month(birth_date)
gen birth_year=year(birth_date)

*4) dummy of change from place of birth and residence:
gen change_birth_place=0
replace change_birth_place=1 if mun_id_birth!=mun_id_res

*collapse to the municipal-year level
gen case=1
encode ds_genero, gen(female)
replace female=0 if female==2
encode ds_estado_civil, gen(married)
replace married=. if married==1
replace married=0 if married==3
replace married=1 if married==4
replace married=1 if married==2
encode ds_raca_requerente, gen(race)
tab race, gen(race_)
gen age=2020-birth_year
gen years_trafficked=rescue_year-trafficking_began_year
encode ds_grau_instrucao, gen(schooling)
tab schooling, gen(schooling_)

collapse (sum) case (mean)female married race_* age schooling_* change_birth_place (firstnm) ds_regiao_residencia ds_mesorregiao_residencia ds_microrregiao_residencia, by(mun_id_res rescue_year)

tempfile unemployment_insurance
save `unemployment_insurance'
*N=5,858 observaitons (mun-year)
restore

*Main dataset
merge 1:1 mun_id_res rescue_year using `unemployment_insurance'
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                       110,983
        from master                   110,983  (_merge==1)
        from using                          0  (_merge==2)

    matched                             5,858  (_merge==3)
    -----------------------------------------


*/
rename _merge merge_unemployment_insurance
replace case=0 if case==.

*===========================================================================================
*Merge permanent and temporal crops

*A. MERGE PERMANENT CROPS
merge m:1 mun_id_res using "HumanTrafficking\Data_waste\permanent_crops_clean2.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,731
        from master                     1,703  (_merge==1)
        from using                         28  (_merge==2)

    matched                           115,138  (_merge==3)
    -----------------------------------------


*/
drop if _merge==2
gen no_human_trafficking=0
replace no_human_trafficking=1 if _merge==2 & mun_id_res>100
replace no_human_trafficking=. if _merge==2 & mun_id_res<100

gen no_permanentcrop_data=0
replace no_permanentcrop_data=1 if _merge==1

rename _merge _merge_wpermanentcrops


*B. MERGE TEMPORAL CROPS
merge m:1 mun_id_res using "HumanTrafficking\Data_waste\temporal_crops_clean2.dta"
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                           347
        from master                       318  (_merge==1)
        from using                         29  (_merge==2)

    matched                           116,523  (_merge==3)
    -----------------------------------------

*/
drop if _merge==2
gen no_temporalcrop_data=0
replace no_temporalcrop_data=1 if _merge==1

rename _merge _merge_wtemporalcrops

*===========================================================================================
*Merge cattle
preserve
use "HumanTrafficking\Data_waste\cattle.dta", clear
drop total
drop name
tostring id, replace
gen mun_id_res_str=substr(id,1,6)
destring mun_id_res_str, gen(mun_id_res)

tempfile cattle
save `cattle'
*1100015
restore 

merge m:1 mun_id_res using `cattle'
/*
     Result                           # of obs.
    -----------------------------------------
    not matched                           472
        from master                       444  (_merge==1)
        from using                         28  (_merge==2)

    matched                           116,397  (_merge==3)
    -----------------------------------------


*/
drop if _merge==2
gen no_cattle_data=0
replace no_cattle_data=1 if _merge==1

rename _merge _merge_wcattle

*===========================================================================================
*Merge charcoal
preserve
import excel "HumanTrafficking\Data_raw\CharcoalIBGE\charcoal_1986_2019.xlsx", sheet("tons") firstrow clear
foreach v of varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ {
   local x : variable label `v'
   rename `v' year_`x'
}
drop AK

*to long format
reshape long year_, i(mun_id) j(year)
rename year_ charcoal_tons
drop if mun_id==""
destring mun_id, replace
destring charcoal_tons, replace
rename mun_id mun_id_res
order mun_id_res municipality year
drop if mun_id_res<100
tempfile charcoal_tons
save `charcoal_tons'
restore


preserve
import excel "HumanTrafficking\Data_raw\CharcoalIBGE\charcoal_1986_2019.xlsx", sheet("value_percentage_of_total")  firstrow clear
foreach v of varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ {
   local x : variable label `v'
   rename `v' year_`x'
}
drop AK

*to long format
reshape long year_, i(mun_id) j(year)
rename year_ charcoal_perc
drop if mun_id==""
destring mun_id, replace
destring charcoal_perc, replace force
rename mun_id mun_id_res
order mun_id_res municipality year
drop if mun_id_res<100
tempfile charcoal_perc
save `charcoal_perc'
restore

preserve 
use `charcoal_tons', clear
merge 1:1 mun_id_res year using `charcoal_perc'
**all get merged
rename year rescue_year
drop _merge 
tostring mun_id_res, replace
gen mun_id_res2=substr(mun_id_res,1,6) 
drop mun_id_res
rename mun_id_res2 mun_id_res
destring mun_id_res, replace
order mun_id_res municipality rescue_year
keep if rescue_year>=2000
tempfile charcoal
save `charcoal'
save "HumanTrafficking\Data_waste\charcoal.dta", replace
restore



*Main dataset
merge m:1 mun_id_res rescue_year using `charcoal'
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         9,895
        from master                     9,788  (_merge==1)
        from using                        107  (_merge==2)

    matched                           107,053  (_merge==3)
    -----------------------------------------


*/

gen no_charcoal_data=0
replace no_charcoal_data=1 if _merge==1

rename _merge _merge_charcoal

*===========================================================================================
*Merge GDP 2002-2017
preserve
insheet using "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\brazil_gdp_deflator_worldbank.csv", clear
rename year rescue_year
save "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\brazil_gdp_deflator_worldbank.dta", replace
restore

preserve
insheet using "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\gdp.csv", clear
foreach i in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012{
destring vl_ano_`i', replace force
}
quietly bysort cd_unidade_territorial:  gen dup = cond(_N==1,0,_n)
drop dup
drop if cd_unidade_territorial<53002
reshape long vl_ano_, i(cd_unidade_territorial) j(year)
drop sg_nivel ds_unidade_territorial v1
rename cd_unidade_territorial mun_id_res  
rename year rescue_year  
rename vl_ano_ gdp
tostring mun_id_res, replace
gen mun_id_res2=substr(mun_id_res,1,6) 
drop mun_id_res
rename mun_id_res2 mun_id_res
destring mun_id_res, replace
order mun_id_res rescue_year

*gdp current to constant prices
merge m:1 rescue_year using "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\brazil_gdp_deflator_worldbank.dta"
drop if _merge==2
drop _merge 

replace brazil_gdp_deflator=(brazil_gdp_deflator/100)+1
*Real GDP = Nominal GDP / Price Index  x 100 
gen gdp_real=(gdp/brazil_gdp_deflator)*100

save "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\gdp.dta", replace
 
tempfile gdp
save `gdp'
restore


*Main dataset
merge m:1 mun_id_res rescue_year using `gdp'
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        27,864
        from master                    27,846  (_merge==1)
        from using                         18  (_merge==2)

    matched                            89,102  (_merge==3)
    -----------------------------------------


*/
drop if _merge==2
drop _merge

*===========================================================================================
*Merge Poverty in 2018
preserve
insheet using "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\poverty.csv", clear
destring nw_mun_perc_poor2018, replace dpcomma force
rename nw_mun_perc_poor2018 poor_percentage_2018
drop v1 
rename cd_mun_ibge mun_id_res
tostring mun_id_res, replace
gen mun_id_res2=substr(mun_id_res,1,6) 
drop mun_id_res
rename mun_id_res2 mun_id_res
destring mun_id_res, replace
order mun_id_res

save "HumanTrafficking\Data_raw\Socioeconomic2020_NETWORK\poverty.dta", replace
tempfile poverty
save `poverty'

restore

*Main dataset
merge m:1 mun_id_res  using `poverty'
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             3
        from master                         3  (_merge==1)
        from using                          0  (_merge==2)

    matched                           116,945  (_merge==3)
    -----------------------------------------

*/
drop _merge


*===========================================================================================
*Save final dataset
save "HumanTrafficking\Data_waste\uneployment_weverything.dta", replace




