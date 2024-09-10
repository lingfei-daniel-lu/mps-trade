cd "D:\Project E\BACI"
forv i=1996/2022{
import delimited csv\BACI_HS96_Y`i'_V202401b.csv, stringcols(2 3 4) numericcols(6),clear
save dta\BACI_HS96_Y`i'_V202401b,replace
}

import delimited csv\country_codes_V202401b.csv, stringcols(1) clear
save dta\country_codes_V202401b,replace

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

use BACI_96_22_imp_HS6,clear
bys j t: egen share_jt=pc(v),prop
sort j k t
by j k: gen dlnp= ln(p)-ln(p[_n-1]) if t==t[_n-1]+1
by j k: gen share_bar_jt=0.5*(share_jt+share_jt[_n-1]) if t==t[_n-1]+1
replace share_bar_jt=share_jt if share_bar_jt==.
winsor2 dlnp, trim replace
*hist dlnp, xlabel(-3(1)3)
bys j t: egen dlnp_jt=sum(dlnp*share_bar_jt), missing
collapse (sum) v, by(j t dlnp_jt)
save BACI_96_22_imp_cty,replace

use BACI_96_22_imp_cty,clear
rename (j t v) (country_code year value)
merge n:1 country_code using dta\country_codes_V202401b,nogen keep(matched) keepus(country_iso3)
drop country_code
rename country_iso3 countrycode
merge n:1 year using "D:\Project E\MPS\brw\brw_94_22",nogen keep(matched)
save BACI_96_22_imp_brw,replace

use BACI_96_22_imp_brw,clear
egen country_id=group(countrycode)
xtset country_id year
areg dlnp_jt brw l.dlnp_jt, a(country_id) vce(cluster country_id)
areg dlnp_jt brw l.dlnp_jt if year>=2000 & year<=2006, a(country_id) vce(cluster country_id)
