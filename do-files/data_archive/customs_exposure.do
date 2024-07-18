cd "D:\Project E"
use customs_matched\customs_matched_exp,clear
collapse (sum) value_year, by (FRDM year coun_aim countrycode)
merge n:1 coun_aim using country_X\country_tag, nogen keep(master matched) keepus(peg_USD OECD EU EME)
merge n:1 coun_aim using country_X\country_advanced, nogen keep(master matched) keepus(AD)
merge n:1 FRDM year using "D:\Project C\sample_matched\customs_matched_twoway",nogen keep(master matched) keepus(export_sum)
gen value_year_US=value_year if coun_aim=="美国"
replace value_year_US=0 if value_year_US==.
local group "EU OECD EME peg_USD AD"
foreach var of local group{
	gen value_year_`var'=value_year if `var'==1
	replace value_year_`var'=0 if value_year_`var'==.
}
* Firm-level export exposure
bys FRDM year: egen export_sum_US=total(value_year_US) 
gen exposure_US=export_sum_US/export_sum
local group "EU OECD EME peg_USD AD"
foreach var of local group{
	bys FRDM year: egen export_sum_`var'=total(value_year_`var') 
	gen exposure_`var'=export_sum_`var'/export_sum
}
/* Firm-product-level export exposure
bys FRDM HS6 year: egen export_sum_US_HS6=total(value_year_US) 
gen exposure_US_HS6=export_sum_US_HS6/export_sum
bys FRDM HS6 year: egen export_sum_EU_HS6=total(value_year_EU) 
gen exposure_EU_HS6=export_sum_EU_HS6/export_sum 
*/
collapse (mean) exposure_*, by (FRDM year)
*by FRDM: egen exposure_US_mean=mean(exposure_US)
*by FRDM: egen exposure_EU_mean=mean(exposure_EU)
save customs_matched\customs_matched_exposure,replace
