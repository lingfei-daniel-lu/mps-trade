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
merge n:1 year using ER\dollar_index_year_fed,nogen keep(matched)
sort cty_code HS6 year
by cty_code HS6: gen dlnprice=ln(price)-ln(price[_n-1]) if year==year[_n-1]+1
egen group_id=group(cty_code HS6)
xtset group_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\cty_HS6_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\cty_HS6_imp_all_sample,clear
eststo USall_0019_1: reghdfe dlnprice brw dlndollar, a(product_id) vce(cluster product_id)
eststo USall_0019_2: reghdfe dlnprice brw l.dlnprice dlndollar, a(product_id) vce(cluster product_id)
eststo USall_0006_1: reghdfe dlnprice brw dlndollar if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)
eststo USall_0006_2: reghdfe dlnprice brw l.dlnprice dlndollar if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)

esttab USall_* using tables\tables_Aug2024\US_import_all.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("00-19" "00-19" "00-06" "00-06")

cd "D:\Project E"
use US_import\cty_HS6_imp_all_89_22,clear
collapse (sum) quantity value, by(year HS6)
gen price_p=value/quantity
save HS6_imp_all_89_22,replace

cd "D:\Project E"
use US_import\HS6_imp_all_89_22,clear
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge n:1 year using ER\dollar_index_year_fed,nogen keep(matched)
sort HS6 year
by HS6: gen dlnprice=ln(price)-ln(price[_n-1]) if year==year[_n-1]+1
egen product_id=group(HS6)
xtset product_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\HS6_imp_all_sample",replace

cd "D:\Project E"
use samples\US_import\HS6_imp_all_sample,clear
eststo USall_0019_1: reghdfe dlnprice brw dlndollar, a(product_id) vce(cluster product_id)
eststo USall_0019_2: reghdfe dlnprice brw l.dlnprice dlndollar, a(product_id) vce(cluster product_id)
eststo USall_0006_1: reghdfe dlnprice brw dlndollar if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)
eststo USall_0006_2: reghdfe dlnprice brw l.dlnprice dlndollar if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)

esttab USall_* using tables\tables_Aug2024\US_import_all.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mlabel("00-19" "00-19" "00-06" "00-06")