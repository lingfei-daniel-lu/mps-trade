* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* C. Regressions for universal customs annual data (2000-2015)

*-------------------------------------------------------------------------------

* 1. Baseline (transaction level)

cd "D:\Project E"
use samples\sample_customs_exp,clear

* Price
eststo customs_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo customs_brw_lag: reghdfe dlnprice_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Quantity
eststo customs_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo customs_brw_quant_lag: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

*-------------------------------------------------------------------------------

* 2. Different periods (transaction level)

cd "D:\Project E"
use samples\sample_customs_exp,clear

eststo customs_brw_0105: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)
eststo customs_brw_0609: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year>=2006 & year<=2009, a(group_id) vce(cluster group_id year)
eststo customs_brw_1013: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year>=2010 & year<=2013, a(group_id) vce(cluster group_id year)

esttab customs_brw_0105 customs_brw_0609 customs_brw_1013 using "D:\Project E\tables\customs_brw_period.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') mtitle("01-05" "06-09" "10-13") compress order(brw)

*-------------------------------------------------------------------------------

* 3. Baseline (firm level)

cd "D:\Project E"
use samples\sample_customs_exp_firm,clear

eststo customs_firm_1: reghdfe dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo customs_firm_2: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo customs_firm_3: reghdfe dlnprice brw l.dlnprice, a(firm_id) vce(cluster firm_id)
eststo customs_firm_4: reghdfe dlnprice brw l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)

*-------------------------------------------------------------------------------

* 4. Different periods (firm level)

cd "D:\Project E"
use samples\sample_customs_exp_firm,clear

eststo customs_firm_0105: reghdfe dlnprice brw if year<=2005, a(firm_id) vce(cluster firm_id)
eststo customs_firm_0609: reghdfe dlnprice brw if year>=2006 & year<=2009, a(firm_id) vce(cluster firm_id)
eststo customs_firm_1013: reghdfe dlnprice brw if year>=2010 & year<=2013, a(firm_id) vce(cluster firm_id)

esttab customs_firm_0105 customs_firm_0609 customs_firm_1013 using "D:\Project E\tables\customs_firm_period.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') mtitle("01-05" "06-09" "10-13") compress order(brw)