cd "D:\Project E\US_import\US_country_code"

import excel using "Annex_A.xlsx", sheet("Sheet1") clear
gen cty_code = ustrregexs(0) if ustrregexm(A, "[0-9]+")
gen cty_name=subinstr(A,".","",.)
replace cty_name=subinstr(cty_name," ","",.)
replace cty_name = substr(cty_name,1,strlen(cty_name)-4)
drop A
save US_country_code_A,replace

import excel using "Annex_B.xlsx", sheet("Sheet1") clear
gen alpha2code = substr(A,-2,.)
gen cty_name=subinstr(A,".","",.)
replace cty_name=subinstr(cty_name," ","",.)
replace cty_name = substr(cty_name,1,strlen(cty_name)-2)
drop A
save US_country_code_B,replace

use US_country_code_B,clear
merge 1:n cty_name using US_country_code_A,nogen keep(matched)
drop if alpha2code=="SB"
duplicates drop
format cty_name %40s
sort alpha2code
save US_country_code_ISO2,replace

import delimited countries_codes_and_coordinates.csv, varnames(1) clear
foreach x of varlist alpha2code alpha3code numericcode latitudeaverage longitudeaverage{
replace `x'= subinstr(`x'," ","",.)
replace `x'= subinstr(`x',char(34),"",.)
}
sort alpha2code country
duplicates drop alpha2code,force
merge 1:1 alpha2code using US_country_code_ISO2,nogen keep(matched)
save US_country_code_ISO3,replace