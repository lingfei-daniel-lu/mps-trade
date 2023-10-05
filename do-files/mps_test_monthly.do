* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* E. Regressions for month data (2000-2006)

set processor 8
*-------------------------------------------------------------------------------

* 1. Baseline

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_firm_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_3: reghdfe dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo month_brw_firm_4: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)

estfe month_brw_firm_*, labels(firm_id "Firm FE" year "Year FE")
esttab month_brw_firm_* using "tables\brw_month_baseline", replace nomtitles booktabs b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)')

*-------------------------------------------------------------------------------

* 2. Lag values of brw

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

gen brw_lag3=l.brw+l2.brw+l3.brw
gen brw_lag6=l.brw+l2.brw+l3.brw+l4.brw+l5.brw+l6.brw
gen brw_lag12=l.brw+l2.brw+l3.brw+l4.brw+l5.brw+l6.brw+l7.brw+l8.brw+l9.brw+l10.brw+l11.brw+l12.brw

eststo month_brw_lag_1: reghdfe dlnprice_YoY l.brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_lag_2: reghdfe dlnprice_YoY brw_lag3, a(firm_id) vce(cluster firm_id)
eststo month_brw_lag_3: reghdfe dlnprice_YoY brw_lag6, a(firm_id) vce(cluster firm_id)
eststo month_brw_lag_4: reghdfe dlnprice_YoY brw_lag12, a(firm_id) vce(cluster firm_id)

estfe month_brw_lag_*, labels(firm_id "Firm FE")
esttab month_brw_lag_* using "tables\brw_month_lag", replace nomtitles booktabs b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)')

*-------------------------------------------------------------------------------

* 3. Firm-product price index

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear

eststo month_brw_HS6_1: reghdfe dlnprice_hit_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_2: reghdfe dlnprice_hit_YoY l.dlnprice_hit_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_3: reghdfe dlnprice_hit_YoY brw, a(group_id year) vce(cluster group_id)
eststo month_brw_HS6_4: reghdfe dlnprice_hit_YoY l.dlnprice_hit_YoY brw, a(group_id year) vce(cluster group_id)
eststo month_brw_HS6_5: reghdfe dlnprice_hit_YoY brw, a(FRDM HS6) vce(cluster FRDM HS6)
eststo month_brw_HS6_6: reghdfe dlnprice_hit_YoY l.dlnprice_hit_YoY brw, a(FRDM HS6) vce(cluster FRDM HS6)

estfe month_brw_HS6_*, labels(group_id "Firm-product FE" FRDM "Firm FE" HS6 "Product FE" year "Year FE" )
esttab month_brw_HS6_* using "tables\brw_month_HS6", replace nomtitles booktabs b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)')

*-------------------------------------------------------------------------------

* 4. Alternative monetary policy shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_NS_1: reghdfe dlnprice_YoY NS_shock, a(firm_id) vce(cluster firm_id)
eststo month_brw_NS_2: reghdfe dlnprice_YoY NS_shock l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

eststo month_brw_FFR_1: reghdfe dlnprice_YoY ffr_shock, a(firm_id) vce(cluster firm_id)
eststo month_brw_FFR_2: reghdfe dlnprice_YoY ffr_shock l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe month_brw_NS_* month_brw_FFR_*, labels(firm_id "Firm FE")
esttab month_brw_NS_* month_brw_FFR_* using "tables\brw_month_altshock", replace nomtitles booktabs b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') order(NS_shock ffr_shock)


*-------------------------------------------------------------------------------

* 5. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
gen brw_lag12=l.brw+l2.brw+l3.brw+l4.brw+l5.brw+l6.brw+l7.brw+l8.brw+l9.brw+l10.brw+l11.brw+l12.brw
eststo month_Markup_brw_1: reghdfe S12.Markup brw, a(firm_id) vce(cluster firm_id)
eststo month_Markup_brw_2: reghdfe S12.Markup brw_lag12, a(firm_id) vce(cluster firm_id)
eststo month_brw_Markup_1: reghdfe dlnprice_YoY brw S12.Markup, a(firm_id) vce(cluster firm_id)
eststo month_brw_Markup_2: reghdfe dlnprice_YoY brw_lag12 S12.Markup, a(firm_id) vce(cluster firm_id)

estfe month_Markup_brw_* month_brw_Markup_*, labels(firm_id "Firm FE")
esttab month_Markup_brw_* month_brw_Markup_* using "tables\brw_month_markup", replace booktabs b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)')