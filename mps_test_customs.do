* This do-file is to run regressions for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* C. Regressions for customs long data (2000-2015)

*-------------------------------------------------------------------------------

* 1. Regressions of price change on monetary policy shocks

cd "D:\Project E"
use sample_customs_exp,clear

* 1.1 Baseline

* Price
eststo customs_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo customs_brw_lag: reghdfe dlnprice_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Quantity
eststo customs_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo customs_brw_quant_lag: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)


*-------------------------------------------------------------------------------

* 1.2 Different periods

cd "D:\Project E"
use sample_customs_exp,clear

* Fixed exchange rate regime

eststo customs_brw_0105: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)
eststo customs_brw_0609: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year>=2006 & year<=2009, a(group_id) vce(cluster group_id year)
eststo customs_brw_1013: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year>=2010 & year<=2013, a(group_id) vce(cluster group_id year)

esttab customs_brw_0105 customs_brw_0609 customs_brw_1013 using "D:\Project E\tables\customs_brw_period.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') mtitle("01-05" "06-09" "10-13") compress order(brw)