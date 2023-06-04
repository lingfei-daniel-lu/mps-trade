* This do-file is to run product-level regressions for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* B. Regressions for product-level sample

*-------------------------------------------------------------------------------

* 1. Regression of price change on brw
cd "D:\Project E"
use sample_HS6,clear

* Baseline
eststo product_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_brw: reghdfe dlnprice_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_brw_lag: reghdfe dlnprice_tr dlnRER brw_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_brw_fixed: reghdfe dlnprice_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* USD price
eststo product_brw_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_brw_USD_fixed: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* Zero lower bound
gen brw_prezlb=brw*prezlb
gen brw_zlb=brw*zlb
gen brw_postzlb=brw*postzlb
eststo product_brw_zlb0: reghdfe dlnprice_tr brw dlnRER dlnrgdp if zlb==0, a(group_id) vce(cluster group_id year)
eststo product_brw_zlb: reghdfe dlnprice_tr brw_prezlb brw_zlb brw_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* US exposure
gen brw_exposure_US=brw*exposure_US
eststo product_brw_expo_US: reghdfe dlnprice_tr brw brw_exposure_US dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_brw_nozlb_expo_US: reghdfe dlnprice_tr brw brw_exposure_US dlnRER dlnrgdp if zlb==0, a(group_id) vce(cluster group_id year)

* Large scale asset purchase and forward guidance
eststo product_lsap: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

gen lsap_prezlb=lsap*prezlb
gen lsap_zlb=lsap*zlb
gen lsap_postzlb=lsap*postzlb
gen fwgd_prezlb=fwgd*prezlb
gen fwgd_zlb=fwgd*zlb
gen fwgd_postzlb=fwgd*postzlb

eststo product_lsap_zlb: reghdfe dlnprice_tr lsap_prezlb lsap_zlb lsap_postzlb fwgd_prezlb fwgd_zlb fwgd_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

eststo product_lsap_zlb1: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp if zlb==1, a(group_id) vce(cluster group_id year)
eststo product_lsap_zlb0: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp if zlb==0, a(group_id) vce(cluster group_id year)
eststo product_lsap_prezlb: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp if zlb==0, a(group_id) vce(cluster group_id year)