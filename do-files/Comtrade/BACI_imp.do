cd "D:\Project E\BACI"
forv i=1996/2022{
import delimited csv\BACI_HS96_Y`i'_V202401b.csv, stringcols(2 3 4) numericcols(6),clear
save dta\BACI_HS96_Y`i'_V202401b,replace
}

import delimited csv\country_codes_V202401b.csv, stringcols(1) clear
save BACI\dta\country_codes_V202401b,replace

import delimited csv\product_codes_HS96_V202401b.csv, varnames(1) clear
save dta\product_codes_V202401b,replace

use dta\BACI_HS96_Y1996_V202401b
forv i=1997/2022{
append using dta\BACI_HS96_Y`i'_V202401b
}
drop if q==. | q==0
collapse (sum) v q, by(j k t)
gen p=v/q
save BACI_96_22_imp_HS6,replace

cd "D:\Project E"
use BACI\BACI_96_22_imp_HS6,clear
sort j k t
by j k: gen dlnp= ln(p)-ln(p[_n-1]) if t==t[_n-1]+1
winsor2 dlnp, trim replace
save BACI\BACI_96_22_imp_HS6_price,replace

cd "D:\Project E"
use BACI\BACI_96_22_imp_HS6_price,clear
bys j t: egen share_jt=pc(v),prop
sort j k t
by j k: gen share_bar_jt=0.5*(share_jt+share_jt[_n-1]) if t==t[_n-1]+1
replace share_bar_jt=share_jt if share_bar_jt==.
*hist dlnp, xlabel(-3(1)3)
bys j t: egen dlnp_jt=sum(dlnp*share_bar_jt), missing
collapse (sum) v, by(j t dlnp_jt)
save BACI\BACI_96_22_imp_cty,replace

cd "D:\Project E"
use BACI\BACI_96_22_imp_cty,clear
rename (j t v) (country_code year value)
merge n:1 country_code using BACI\dta\country_codes_V202401b,nogen keep(matched) keepus(country_iso3)
drop country_code
rename country_iso3 countrycode
merge n:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge n:1 year countrycode using ER\RER_89_19,nogen keep(matched) keepus(dlnrgdp)
save BACI\sample_BACI_imp_cty,replace

cd "D:\Project E"
use BACI\sample_BACI_imp_cty,clear
egen country_id=group(countrycode)
xtset country_id year
areg dlnp_jt brw, a(country_id) vce(cluster country_id)
areg dlnp_jt brw l.dlnp_jt dlnrgdp if year>=2000 & year<=2006, a(country_id) vce(cluster country_id)

cd "D:\Project E"
use BACI\BACI_96_22_imp_HS6_price,clear
rename (j k t v) (country_code HS6 year value)
merge n:1 country_code using BACI\dta\country_codes_V202401b,nogen keep(matched) keepus(country_iso3)
drop country_code
rename country_iso3 countrycode
merge n:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge n:1 year countrycode using ER\RER_89_19,nogen keep(matched) keepus(dlnrgdp)
merge n:1 countrycode using country_X\country_GDP_2006,nogen keep(matched master) keepus(gdp_pc)
gen lngdp_pc=ln(gdp_pc)
save BACI\sample_BACI_imp_HS6,replace

cd "D:\Project E"
use BACI\sample_BACI_imp_HS6,clear
egen group_id=group(countrycode HS6)
xtset group_id year
areg dlnp brw, a(group_id) vce(cluster countrycode)
areg dlnp brw l.dlnp dlnrgdp if year>=2000 & year<=2006, a(group_id) vce(cluster countrycode)

cd "D:\Project E"
use BACI\sample_BACI_imp_HS6,clear
gen HS2=substr(HS6,1,2)
keep if countrycode=="ARG" | countrycode=="BGD" |countrycode=="BRA" |countrycode=="CAN" |countrycode=="CHN" |countrycode=="COL" |countrycode=="DEU" |countrycode=="EGY" |countrycode=="FRA" |countrycode=="GBR" |countrycode=="IDN" |countrycode=="IND" |countrycode=="IRL" |countrycode=="ISR" |countrycode=="ITA" |countrycode=="JPN" |countrycode=="KOR" |countrycode=="MEX" |countrycode=="MYS" |countrycode=="NGA" |countrycode=="PAK" |countrycode=="PHL" |countrycode=="ROU" |countrycode=="RUS" |countrycode=="SAU" |countrycode=="THA" |countrycode=="TUR" |countrycode=="USA" |countrycode=="VNM" |countrycode=="ZAF"

local country "ARG BGD BRA CAN CHN COL DEU EGY FRA GBR IDN IND IRL ISR ITA JPN KOR MEX MYS NGA PAK PHL ROU RUS SAU THA TUR USA VNM ZAF"
foreach i of local country{
eststo imp_`i': areg dlnp brw if countrycode=="`i'", a(HS6) vce(cluster HS2)
}
estfe imp_*, labels(HS6 "Product FE")
esttab imp_* using tables\tables_Sep2024\otherimp.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

preserve
statsby _b _se n=(e(N)), by(countrycode lngdp_pc) clear: areg dlnp brw, a(HS6) vce(cluster HS2)
save BACI\BACI_imp_HS6_coef_raw,replace
restore

preserve
statsby _b _se n=(e(N)), by(countrycode lngdp_pc) clear: areg dlnp brw l.dlnp dlnrgdp, a(HS6) vce(cluster HS2)
save BACI\BACI_imp_HS6_coef_control,replace
restore

cd "D:\Project E"
use BACI\BACI_imp_HS6_coef_raw,clear

scatter _b_brw lngdp_pc, mlabel(countrycode) xtitle(Log GDP per capita) ytitle(Coefficients of price response) yline(0) yscale(r(0 0.6))
graph export figures\Other-imp_ctr_30_raw.png, as(png) replace

twoway (hist _b_brw, width(0.2) start(-0.2) frequency legend(off)) (scatteri 0 0 20 0, recast(line) lcolor(blue) lpattern(dash)) (scatteri 0 0.209 20 0.209, recast(line) lcolor(red) lpattern(solid) text(20 0.21 "US, 0.209", color(red) place(e)size(5)))
graph export figures\Other-imp_ctr_30_raw_hist.png, as(png) replace

cd "D:\Project E"
use BACI\BACI_imp_HS6_coef_control,clear

replace _b_brw=0.5 if _b_brw>0.5

twoway (hist _b_brw, width(0.2) start(-0.2) frequency legend(off)) (scatteri 0 0 20 0, recast(line) lcolor(blue) lpattern(dash)) (scatteri 0 0.268 20 0.268, recast(line) lcolor(red) lpattern(solid) text(20 0.27 "US, 0.268", color(red) place(e)  size(5)))
graph export figures\Other-imp_ctr_30_control_hist.png, as(png) replace
