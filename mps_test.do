* This do-file is to run regressions for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* 1. Regressions for firm-level sample

****************************************

* 1.1 Regressions of price change on brw
cd "D:\Project E"
use sample_matched_exp,clear

* construct interaction terms
local varlist "FPC_US ExtFin_US Tang_US Invent_US TrCredit_US FPC_cic2 ExtFin_cic2 Tang_cic2 Invent_cic2 Arec Arec_cic2"
foreach var of local varlist {
	gen brw_`var' = `var'*brw
}

* Baseline
eststo firm_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw: reghdfe dlnprice_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag: reghdfe dlnprice_tr dlnRER brw_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed: reghdfe dlnprice_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_brw0 firm_brw firm_brw_lag firm_brw_fixed, star(* .10 ** .05 *** .01) label compress r2

binscatter dlnprice_tr brw, xtitle(US monetary policy shock) ytitle(China's export price change) savegraph(US_shock.jpg) replace

* USD price
eststo firm_brw_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag_USD: reghdfe dlnprice_USD_tr dlnRER brw_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* Credit constraint from US measures
eststo firm_brw_FPC_US: reghdfe dlnprice_tr brw_FPC_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_ExtFin_US: reghdfe dlnprice_tr brw_ExtFin_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Tang_US: reghdfe dlnprice_tr brw_Tang_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Invent_US: reghdfe dlnprice_tr brw_Invent_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_TrCredit_US: reghdfe dlnprice_tr brw_TrCredit_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_FPC_US firm_brw_ExtFin_US firm_brw_Tang_US firm_brw_Invent_US firm_brw_TrCredit_US, star(* .10 ** .05 *** .01) label compress se r2 order(brw brw_*)

* Credit constraint from CN measures
eststo firm_brw_FPC_cic2: reghdfe dlnprice_tr brw_FPC_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_ExtFin_cic2: reghdfe dlnprice_tr brw_ExtFin_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Tang_cic2: reghdfe dlnprice_tr brw_Tang_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Invent_cic2: reghdfe dlnprice_tr brw_Invent_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Arec_cic2: reghdfe dlnprice_tr brw_Arec_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_FPC_cic2 firm_brw_ExtFin_cic2 firm_brw_Tang_cic2 firm_brw_Invent_cic2 firm_brw_Arec firm_brw_Arec_cic2, star(* .10 ** .05 *** .01) label compress se r2 order(brw brw_*)

* Real sales income
gen brw_rSI=brw*lnrSI
eststo firm_brw_rSI: reghdfe dlnprice_tr dlnRER brw brw_lnrSI dlnrgdp, a(group_id) vce(cluster group_id year)

* US vs ROW
eststo firm_brw_US: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_ROW: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim!="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_EU: reghdfe dlnprice_tr brw dlnRER dlnrgdp if EU==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_OECD: reghdfe dlnprice_tr brw dlnRER dlnrgdp if OECD==1, a(group_id) vce(cluster group_id year)

esttab firm_brw_US firm_brw_ROW firm_brw_EU firm_brw_OECD, star(* .10 ** .05 *** .01) label compress r2

* Quantity
eststo firm_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_lag: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_fixed: reghdfe dlnquant_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* EU shock
eststo firm_eus0: reghdfe dlnprice_tr target_ea path_ea dlnrgdp, absorb(group_id) vce(cluster group_id year)
eststo firm_eus: reghdfe dlnprice_tr target_ea path_ea dlnRER dlnrgdp, absorb(group_id) vce(cluster group_id year)
eststo firm_eus_lag: reghdfe dlnprice_tr target_ea_lag path_ea_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_fixed: reghdfe dlnprice_tr dlnRER target_ea path_ea dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_eus0 firm_eus firm_eus_lag firm_eus_fixed, star(* .10 ** .05 *** .01) label compress r2

binscatter dlnprice_tr target_ea, xtitle(EU monetary policy shock) ytitle(China's export price change) savegraph(EU_shock.jpg) replace

* US and EU exposure
gen brw_exposure_US=brw*exposure_US
eststo firm_brw_expoUS: reghdfe dlnprice_tr brw brw_exposure_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen brw_exposure_EU=brw*exposure_EU
eststo firm_brw_expoEU: reghdfe dlnprice_tr brw brw_exposure_EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen eus_exposure_EU=target_ea*exposure_EU
eststo firm_eus_expoEU: reghdfe dlnprice_tr target_ea path_ea eus_exposure_EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)



****************************************

* 1.2 Regression of price change on lsap and fwgd

* Baseline
eststo firm_lsap: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Zero lower bound
gen lsap_prezlb=lsap*prezlb
gen lsap_zlb=lsap*zlb
gen lsap_postzlb=lsap*postzlb
gen fwgd_prezlb=fwgd*prezlb
gen fwgd_zlb=fwgd*zlb
gen fwgd_postzlb=fwgd*postzlb

eststo firm_lsap_zlb: reghdfe dlnprice_tr lsap_prezlb lsap_zlb lsap_postzlb fwgd_prezlb fwgd_zlb fwgd_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_lsap_zlb1: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp if zlb==1, a(group_id) vce(cluster group_id year)

****************************************

* 1.3 Regression of quantity change on lsap and brw

eststo firm_brw_q: reghdfe dlnquant_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)

********************************************************************************

* 2. Regressions for product-level sample

****************************************

* 2.1 Regression of price change on brw
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

****************************************

* 2.2 Regression of price change on lsap and fwgd

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

eststo product_fwgd_zlb0: reghdfe dlnprice_tr fwgd dlnRER dlnrgdp if zlb==0, a(group_id) vce(cluster group_id year)