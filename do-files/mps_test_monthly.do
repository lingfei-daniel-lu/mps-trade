* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* E. Regressions for monthly data (2000-2006)

*-------------------------------------------------------------------------------

* 1. Baseline

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo monthly_brw: reghdfe dlnprice brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_YoY: reghdfe dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_index: reghdfe price_index l.price_index brw, a(firm_id year) vce(cluster firm_id)

*-------------------------------------------------------------------------------

* 2. Lag and forward

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo monthly_brw_l1: reghdfe dlnprice l.dlnprice brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_f1l1: reghdfe f.dlnprice l.dlnprice brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_f2l1: reghdfe f2.dlnprice l.dlnprice brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_f3l1: reghdfe f3.dlnprice l.dlnprice brw, a(firm_id year) vce(cluster firm_id)

eststo monthly_brw_YoY_l1: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_YoY_f1l1: reghdfe f.dlnprice_YoY l.dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_YoY_f2l1: reghdfe f2.dlnprice_YoY l.dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo monthly_brw_YoY_f3l1: reghdfe f3.dlnprice_YoY l.dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)