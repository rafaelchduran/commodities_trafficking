/****************************
*Master: Run all do files
*Paper: Zona de Distension
*Author: Ch, Perez, Vargas and Weintraub
****************************/
*========================================================================
*Environment
clear all
set more off  
set varabbrev off 
*========================================================================
*Working Directory
cd "/Users/rafaeljafetchduran/Dropbox/Zona_distension_final/ZonaDistension/Dofiles"
*========================================================================
*Run do files:
*A. For Light:
do "1. merge_light_files.do"
do "2. variable_generation_light.do"
do "2. for_demanding_light_specification.do"
do "3. light.do"

*B. For Coca:
do "1. merge_coca_files.do"
do "2. variable_generation_coca.do"
do "2. for_demanding_coca_specification.do"
do "3. coca.do"
do "4. coca_miscelaneous.do"

*All: 
do "4. no_sorting"


*Missing:
do "1. merge_alldatasets.do" // cannot run because the population variable has 20 thousand more observations


