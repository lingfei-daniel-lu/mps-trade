cd "E:\Data\Peter Schott\US HS-level imports and exports"

use imp_detl_yearly_89n,clear
forv i=90/122{
append using imp_detl_yearly_`i'n
}
tostring commodity,replace
gen HS6=substr(commodity,1,6)
collapse (sum) quantity=con_qy1_yr value=con_val_yr, by(cty_code year HS6)
merge n:1 cty_code using US_cty_namecode,nogen keep(matched)
drop if value==0 | value==.
gen HS2=substr(HS6,1,2)
gen price_cp=value/quantity
cd "D:\Project E"
save US_import\cty_HS6_imp_all_89_22,replace

cd "D:\Project E"
use US_import\cty_HS6_imp_all_89_22,clear
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge n:1 year using BLS_US\GDP_US_annual,nogen keep(matched)
merge n:1 cty_code using ER\country_code_index,nogen keep(matched)
merge n:1 countrycode year using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
sort cty_code HS6 year
by cty_code HS6: gen dlnprice=ln(price_cp)-ln(price_cp[_n-1]) if year==year[_n-1]+1
egen group_id=group(cty_code HS6)
xtset group_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\cty_HS6_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\cty_HS6_imp_all_sample,clear
eststo US_pc_9519_1: reghdfe dlnprice brw dlnGDP dlnRER, a(group_id) vce(cluster HS2)
eststo US_pc_9519_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnRER, a(group_id) vce(cluster HS2)
eststo US_pc_0006_1: reghdfe dlnprice brw dlnGDP dlnRER if year>=2000 & year<=2006, a(group_id) vce(cluster HS2)
eststo US_pc_0006_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnRER if year>=2000 & year<=2006, a(group_id) vce(cluster HS2)

esttab US_pc_* using tables\tables_Sep2024\US_import_all_pc.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("95-19" "95-19" "00-06" "00-06")

cd "D:\Project E"
use US_import\cty_HS6_imp_all_89_22,clear
collapse (sum) quantity value, by(year HS6 HS2)
gen price_p=value/quantity
save US_import\HS6_imp_all_89_22,replace

cd "D:\Project E"
use US_import\HS6_imp_all_89_22,clear
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge n:1 year using BLS_US\GDP_US_annual,nogen keep(matched)
merge n:1 year using ER\dollar_index_year_fed,nogen keep(matched)
sort HS6 year
by HS6: gen dlnprice=ln(price_p)-ln(price_p[_n-1]) if year==year[_n-1]+1
egen product_id=group(HS6)
xtset product_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\HS6_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\HS6_imp_all_sample,clear
eststo US_p_9519_1: reghdfe dlnprice brw dlndollar, a(product_id) vce(cluster HS2)
eststo US_p_9519_2: reghdfe dlnprice brw l.dlnprice dlndollar, a(product_id) vce(cluster HS2)
eststo US_p_0006_1: reghdfe dlnprice brw dlndollar if year>=2000 & year<=2006, a(product_id) vce(cluster HS2)
eststo US_p_0006_2: reghdfe dlnprice brw l.dlnprice dlndollar if year>=2000 & year<=2006, a(product_id) vce(cluster HS2)

esttab US_p_* using tables\tables_Sep2024\US_import_all_p.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("95-19" "95-19" "00-06" "00-06")

cd "D:\Project E"
use US_import\cty_HS6_imp_all_89_22,clear
sort cty_code HS6 year
by cty_code HS6: gen dlnprice=ln(price_cp)-ln(price_cp[_n-1]) if year==year[_n-1]+1
collapse (sum) value (mean) dlnprice=dlnprice [iweight=value], by(cty_code year)
save US_import\cty_imp_all_89_22,replace

cd "D:\Project E"
use US_import\cty_imp_all_89_22,clear
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge n:1 year using BLS_US\GDP_US_annual,nogen keep(matched)
merge n:1 cty_code using ER\country_code_index,nogen keep(matched)
merge n:1 countrycode year using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
egen cty_id=group(cty_code)
xtset cty_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\cty_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\cty_imp_all_sample,clear
eststo US_c_9519_1: reghdfe dlnprice brw dlnGDP dlnRER, a(cty_id)
eststo US_c_9519_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnRER, a(cty_id)
eststo US_c_0006_1: reghdfe dlnprice brw dlnGDP dlnRER if year>=2000 & year<=2006, a(cty_id)
eststo US_c_0006_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnRER if year>=2000 & year<=2006, a(cty_id)

esttab US_c_* using tables\tables_Sep2024\US_import_all_c.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("95-19" "95-19" "00-06" "00-06")