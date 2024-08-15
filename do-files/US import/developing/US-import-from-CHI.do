cd "E:\Data\Peter Schott\US HS-level imports and exports"

forv i=89/122{
use imp_detl_yearly_`i'n,clear
keep if cty_code==3370
collapse (sum) con_qy1_yr con_val_yr, by(commodity year)
save "D:\Project E\US_import\imp_Chile\imp_Chile_yearly_`i'n",replace
}

cd "D:\Project E\US_import\imp_Chile"
use imp_Chile_yearly_89n,clear
forv i=90/122{
append using imp_Chile_yearly_`i'n
}
tostring commodity,replace
gen HS8=substr(commodity,1,8)
collapse (sum) quantity=con_qy1_yr value=con_val_yr, by(year HS8)
drop if value==0 | value==.
save HS8_imp_Chile_89_22,replace

use HS8_imp_Chile_89_22,clear
gen HS6=substr(HS8,1,6)
collapse (sum) quantity=quantity value=value, by(year HS6)
gen HS2=substr(HS6,1,2)
gen price=value/quantity
save HS6_imp_Chile_89_22,replace

cd "D:\Project E\US_import\imp_Chile"
use HS6_imp_Chile_89_22,clear
merge m:1 year using "D:\Project E\MPS\brw\brw_94_22",nogen keep(matched)
sort HS6 year
by HS6: gen dlnprice=ln(price)-ln(price[_n-1]) if year==year[_n-1]+1
egen product_id=group(HS6)
xtset product_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\US_import\HS6_imp_Chile_sample",replace

cd "D:\Project E"
use samples\US_import\HS6_imp_Chile_sample,clear
eststo USCHI_0019_1: reghdfe dlnprice brw, a(product_id) vce(cluster product_id)
eststo USCHI_0019_2: reghdfe dlnprice brw l.dlnprice, a(product_id) vce(cluster product_id)
eststo USCHI_0006_1: reghdfe dlnprice brw if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)
eststo USCHI_0006_2: reghdfe dlnprice brw l.dlnprice if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)

estfe USCHI_*, labels(product_id "Product FE")
esttab USCHI_* using tables\tables_Aug2024\US-imp-CHI.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("00-19" "00-19" "00-06" "00-06")