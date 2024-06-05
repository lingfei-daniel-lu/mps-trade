cd "E:\Data\Peter Schott\US HS-level imports and exports"

forv i=89/122{
use imp_detl_yearly_`i'n,clear
keep if cty_code==5700
collapse (sum) con_qy1_yr con_val_yr, by(commodity year)
save imp_China\imp_China_yearly_`i'n,replace
}

cd "E:\Data\Peter Schott\US HS-level imports and exports\imp_China"
use imp_China_yearly_89n,clear
forv i=90/122{
append using imp_China_yearly_`i'n
}
tostring commodity,replace
gen HS8=substr(commodity,1,8)
collapse (sum) quantity=con_qy1_yr value=con_val_yr, by(year HS8)
drop if value==0 | value==.
save HS8_imp_China_89_22,replace

use HS8_imp_China_89_22,clear
gen HS6=substr(HS8,1,6)
collapse (sum) quantity=quantity value=value, by(year HS6)
gen HS2=substr(HS6,1,2)
gen price=value/quantity
save HS6_imp_China_89_22,replace
**# Bookmark #1

cd "E:\Data\Peter Schott\US HS-level imports and exports\imp_China"
use HS6_imp_China_89_22,clear
merge m:1 year using "D:\Project E\MPS\brw\brw_94_22",nogen keep(matched)
merge n:1 year using "D:\Project E\ER\US_NER_99_19",nogen keep(matched)
sort HS6 year
by HS6: gen dlnprice=ln(price)-ln(price[_n-1]) if year==year[_n-1]+1
egen product_id=group(HS6)
xtset product_id year
winsor2 dlnprice,trim replace
save "D:\Project E\samples\HS6_US-import",replace

cd "D:\Project E"
use samples\HS6_US-import,clear
eststo USCN_0019_1: reghdfe dlnprice brw dlnNER_US, a(product_id) vce(cluster product_id)
eststo USCN_0019_2: reghdfe dlnprice brw l.dlnprice dlnNER_US, a(product_id) vce(cluster product_id)
eststo USCN_0006_1: reghdfe dlnprice brw dlnNER_US if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)
eststo USCN_0006_2: reghdfe dlnprice brw l.dlnprice dlnNER_US if year>=2000 & year<=2006, a(product_id) vce(cluster product_id)
eststo USCN_0713_1: reghdfe dlnprice brw dlnNER_US if year>=2007 & year<=2013, a(product_id) vce(cluster product_id)
eststo USCN_0713_2: reghdfe dlnprice brw l.dlnprice dlnNER_US if year>=2007 & year<=2013, a(product_id) vce(cluster product_id)
eststo USCN_1419_1: reghdfe dlnprice brw dlnNER_US if year>=2014 & year<=2019, a(product_id) vce(cluster product_id)
eststo USCN_1419_2: reghdfe dlnprice brw l.dlnprice dlnNER_US if year>=2014 & year<=2019, a(product_id) vce(cluster product_id)

estfe USCN_*, labels(product_id "Product FE")
esttab USCN_* using tables\tables_May2024\US-imp-CN.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("00-19" "00-19" "00-06" "00-06" "07-13" "07-13" "14-19" "14-19")