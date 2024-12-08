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
merge n:1 countrycode year using ER\RER_89_19,nogen keep(matched) keepus(NER RER dlnRER dlnNER dlnrgdp inflation)
merge n:1 year using ER\US_NER_89_19,nogen keep(matched)
gen dlnNER_toUS=dlnNER-dlnNER_US
sort cty_code HS6 year
by cty_code HS6: gen dlnprice=ln(price_cp)-ln(price_cp[_n-1]) if year==year[_n-1]+1
egen group_id=group(cty_code HS6)
xtset group_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\cty_HS6_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\cty_HS6_imp_all_sample,clear
gen exp_CN=1 if countrycode=="CHN"
replace exp_CN=0 if exp_CN==.
eststo US_pc_9519_1: reghdfe dlnprice brw, a(group_id) vce(cluster group_id)
eststo US_pc_9519_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnNER_toUS, a(group_id) vce(cluster group_id)
eststo US_pc_9519_3: reghdfe dlnprice brw c.brw#c.exp_CN l.dlnprice dlnGDP dlnNER_toUS, a(group_id) vce(cluster group_id)
eststo US_pc_0006_1: reghdfe dlnprice brw if year>=2000 & year<=2006, a(group_id) vce(cluster group_id)
eststo US_pc_0006_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnNER_toUS if year>=2000 & year<=2006, a(group_id) vce(cluster group_id)
eststo US_pc_0006_3: reghdfe dlnprice brw c.brw#c.exp_CN l.dlnprice dlnGDP dlnNER_toUS if year>=2000 & year<=2006, a(group_id) vce(cluster group_id)

esttab US_pc_* using tables\tables_Oct2024\US_import_all_pc.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("95-19" "95-19" "95-19" "00-06" "00-06" "00-06")

cd "D:\Project E"
use US_import\cty_HS6_imp_all_89_22,clear
collapse (sum) quantity value, by(year HS6 HS2)
gen price_p=value/quantity
save US_import\HS6_imp_all_89_22,replace

cd "D:\Project E"
use US_import\HS6_imp_all_89_22,clear
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge m:1 year using MPS\FFR\FFR_annual,nogen keep(matched)
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
eststo US_p_9519_1: reghdfe dlnprice brw, a(product_id) vce(cluster HS6)
eststo US_p_9519_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlndollar, a(product_id) vce(cluster HS6)
eststo US_p_0006_1: reghdfe dlnprice brw dlnGDP dlndollar if year>=2000 & year<=2006, a(product_id) ce(cluster HS6)
eststo US_p_0006_2: reghdfe dlnprice brw dlnGDP l.dlnprice dlndollar if year>=2000 & year<=2006, a(product_id) ce(cluster HS6)

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
merge n:1 countrycode year using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnNER dlnrgdp inflation)
egen cty_id=group(cty_code)
xtset cty_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\cty_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\cty_imp_all_sample,clear
eststo US_c_9519_1: reghdfe dlnprice brw, a(cty_id) vce(cluster cty_id)
eststo US_c_9519_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnNER, a(cty_id) vce(cluster cty_id)
eststo US_c_0006_1: reghdfe dlnprice brw if year>=2000 & year<=2006, a(cty_id) vce(cluster cty_id)
eststo US_c_0006_2: reghdfe dlnprice brw l.dlnprice dlnGDP dlnNER if year>=2000 & year<=2006, a(cty_id) vce(cluster cty_id)

esttab US_c_* using tables\tables_Sep2024\US_import_all_c.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("95-19" "95-19" "00-06" "00-06")

*-------------------------------------------------------------------------------
* Motivation Figures

cd "D:\Project E"
use samples\US_import\HS6_imp_all_sample,clear

binscatter dlnprice brw, xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\US_HS6_imp_brw_raw.png") replace nq(30) text(0.1 0.1 "{&beta}=0.132", place(e) size(6))

binscatter dlnprice brw, control(dlnGDP dlndollar l.dlnprice) xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\US_HS6_imp_brw_control.png") replace nq(30) text(0.1 0.1 "{&beta}=0.098", place(e) size(6))

import excel MPS\FFR\RIFSPFFNA.xls, sheet("FRED Graph") cellrange(A11:B80) firstrow clear
gen year=year(observation_date)
rename RIFSPFFNA FFR
keep year FFR
save MPS\FFR\FFR_annual,replace

cd "D:\Project E"
use samples\US_import\HS6_imp_all_sample,clear

binscatter dlnprice FFR, xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\US_HS6_imp_ffr_raw.png") replace nq(30)

binscatter dlnprice FFR, control(dlnGDP dlndollar l.dlnprice) xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\US_HS6_imp_ffr_control.png") replace nq(30)