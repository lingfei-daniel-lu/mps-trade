* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* B. Regressions for product-level annual sample (2000-2019)

*-------------------------------------------------------------------------------

* 1. Baseline

cd "D:\Project E"
use samples\sample_HS6_country,clear

* Baseline
eststo HS6_brw1: reghdfe dlnprice brw, a(group_id) vce(cluster group_id)
eststo HS6_brw2: reghdfe dlnprice brw dlnrgdp, a(group_id) vce(cluster group_id)
eststo HS6_brw3: reghdfe dlnprice brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* USD price
eststo HS6_brw_USD1: reghdfe dlnprice_USD brw, a(group_id) vce(cluster group_id)
eststo HS6_brw_USD2: reghdfe dlnprice_USD brw dlnrgdp, a(group_id) vce(cluster group_id)
eststo HS6_brw_USD3: reghdfe dlnprice_USD brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

*-------------------------------------------------------------------------------

* 2. Different periods

cd "D:\Project E"
use samples\sample_HS6,clear

eststo HS6_brw_0104: reghdfe dlnprice brw if year<=2004, a(HS6) vce(cluster HS6)
eststo HS6_brw_0508: reghdfe dlnprice brw if year>=2005 & year<=2008, a(HS6) vce(cluster HS6)
eststo HS6_brw_0912: reghdfe dlnprice brw if year>=2009 & year<=2012, a(HS6) vce(cluster HS6)
eststo HS6_brw_1316: reghdfe dlnprice brw if year>=2013 & year<=2016, a(HS6) vce(cluster HS6)
eststo HS6_brw_1719: reghdfe dlnprice brw if year>=2017 & year<=2019, a(HS6) vce(cluster HS6)

esttab HS6_brw_0104 HS6_brw_0508 HS6_brw_0912 HS6_brw_1316 HS6_brw_1719 using "D:\Project E\tables\HS6_brw_period.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') mtitle("01-04" "05-08" "09-12" "13-16" "17-19") compress order(brw)

*-------------------------------------------------------------------------------

* 3. Alternative shocks

cd "D:\Project E"
use samples\sample_HS6,clear

* Large scale asset purchase and forward guidance
eststo product_lsap: reghdfe dlnprice lsap fwgd, a(HS6) vce(cluster HS6)

eststo HS6_lsap_0104: reghdfe dlnprice lsap fwgd if year<=2004, a(HS6) vce(cluster HS6)
eststo HS6_lsap_0508: reghdfe dlnprice lsap fwgd if year>=2005 & year<=2008, a(HS6) vce(cluster HS6)
eststo HS6_lsap_0912: reghdfe dlnprice lsap fwgd if year>=2009 & year<=2012, a(HS6) vce(cluster HS6)
eststo HS6_lsap_1316: reghdfe dlnprice lsap fwgd if year>=2013 & year<=2016, a(HS6) vce(cluster HS6)
eststo HS6_lsap_1719: reghdfe dlnprice lsap fwgd if year>=2017 & year<=2019, a(HS6) vce(cluster HS6)

esttab HS6_lsap_0104 HS6_lsap_0508 HS6_lsap_0912 HS6_lsap_1316 HS6_lsap_1719 using "D:\Project E\tables\HS6_lsap_period.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') mtitle("01-04" "05-08" "09-12" "13-16" "17-19") compress