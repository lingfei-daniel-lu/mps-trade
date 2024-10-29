* This do-file is to run regressions for the second draft of Li, Lu, and Yao (2023) by Dec 31, 2023.

********************************************************************************

set processor 8

*===============================================================================

* Section I. Introduction and II. Data and Measurements

*-------------------------------------------------------------------------------

* F4. US monetary policy shock

cd "D:\Project E\MPS\brw"
use brw_month,replace
drop if brw==0
keep if year<=2021
twoway scatter brw ym, ytitle(US monetary policy shock) xtitle(time) tline(2000m1 2006m12) title("Monetary policy shock series by BRW(2021)") saving(BRW.png, replace)

*-------------------------------------------------------------------------------

* A1. Summary Statistics

cd "D:\Project E"
use customs_matched\customs_matched_exp_firm,clear

merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched)

replace SI=SI/1000

eststo sum_stats: estpost sum HS6_count value SI PERSENG exp_int, detail

esttab sum_stats using "tables\tables_Oct2024\sum_stats.tex", replace cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) p25(fmt(2)) p75(fmt(2))") label booktab nonumber nomtitles


*-------------------------------------------------------------------------------

* A2. Correlations of alternative monetary policy shock measures

cd "D:\Project E"
use MPS\monthly\Shock_rescale\data\US_shock_scaled,clear
corr brw ns BS target path mp cbi

*-------------------------------------------------------------------------------

* 1. Baseline (spillback)

cd "D:\Project E"
use samples\sample_monthly_exp_firm_US,clear

eststo ToUS_month_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo ToUS_month_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm_US,clear

eststo ToUS_annual_1: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id year) 
eststo ToUS_annual_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

esttab ToUS_* using tables\tables_Oct2024\baseline_spillback.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

* 2. Baseline (spillover)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo baseline_month_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo baseline_month_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo baseline_annual_1: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo baseline_annual_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

cd "D:\Project E"
use samples\sample_monthly_exp_firm_nonUS,clear

eststo NonUS_month_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo NonUS_month_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm_nonUS,clear

eststo NonUS_annual_1: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo NonUS_annual_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

esttab NonUS_* baseline_* using tables\tables_Oct2024\baseline_spillover.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* F5. Monthly US MPS and China's Export Prices

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

binscatter dlnprice_YoY brw, xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\brw_monthly.png") replace discrete

cd "D:\Project E"
use samples\sample_monthly_exp_firm_US,clear

binscatter dlnprice_YoY brw, xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\brw_monthly_US.png") replace discrete text(0.06 0.05 "{&beta}=0.212", color(red) place(e) size(6))

cd "D:\Project E"
use samples\sample_monthly_exp_firm_nonUS,clear

binscatter dlnprice_YoY brw, xtitle("Monetary policy shocks") ytitle("{&Delta} log price") savegraph("D:\Project E\figures\brw_monthly_nonUS.png") replace discrete text(0.07 0.05 "{&beta}=0.277", color(red) place(e) size(6))

*-------------------------------------------------------------------------------

* B1. Dynamic regression (forward prices)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo forward_`i': reghdfe f`i'.dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY f`i'.dlnNER_US, a(firm_id) vce(cluster firm_id time)
}

estfe forward_*, labels(firm_id "Firm FE")
esttab forward_* using tables\tables_Oct2024\dynamic.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

gen b=0
gen u=0
gen d=0

forv h = 0/12 {
reghdfe f`h'.dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY f`h'.dlnNER_US, a(firm_id) vce(cluster firm_id time)
replace b = _b[brw]                    if _n == `h'+1
replace u = _b[brw] + 1.645* _se[brw]  if _n == `h'+1
replace d = _b[brw] - 1.645* _se[brw]  if _n == `h'+1
}

*Plot

gen h=_n-1
gen Zero=0
twoway (rarea u d h if h<=12, fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
  (line b h if h<=12, lcolor(blue) lpattern(solid) lwidth(thick)) /// 
  (line Zero h if h<=12, lcolor(black)), legend(off) ///
  title("Dynamic responses in 12 months", color(black)) ///
  ytitle("Price response", size(medsmall)) xtitle("Time horizon", size(medsmall)) xlabel(0 (1) 12) ///
  graphregion(color(white)) plotregion(color(white))

* B2. Dynamic regression (lagged shocks)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo lag_1: reghdfe dlnprice_YoY brw l.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_2: reghdfe dlnprice_YoY brw l.brw l2.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_3: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_4: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_5: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_6: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_7: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l7.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_8: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l7.brw l8.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_9: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l7.brw l8.brw l9.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_10: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l7.brw l8.brw l9.brw l10.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_11: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l7.brw l8.brw l9.brw l10.brw l11.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo lag_12: reghdfe dlnprice_YoY brw l.brw l2.brw l3.brw l4.brw l5.brw l6.brw l7.brw l8.brw l9.brw l10.brw l11.brw l12.brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)

estfe lag*, labels(firm_id "Firm FE")
esttab lag_* using tables\tables_Oct2024\dynamic_lag.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

gen b=0
gen u=0
gen d=0

forv h = 0/12 {
replace b = _b[l`h'.brw]                    	 if _n == `h'+1
replace u = _b[l`h'.brw] + 1.645* _se[l`h'.brw]  if _n == `h'+1
replace d = _b[l`h'.brw] - 1.645* _se[l`h'.brw]  if _n == `h'+1
}


* Dynamic regression with different time gap

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo gap1_`i': reghdfe s`i'.l.f`i'.price_index brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
}
estfe gap1_*, labels(firm_id "Firm FE")
esttab gap1_* using tables\tables_Oct2024\gap1.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

forv i=1/12{
eststo gap2_`i': reghdfe s`i'.price_index brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
}
estfe gap2_*, labels(firm_id "Firm FE")
esttab gap2_* using tables\tables_Oct2024\gap2.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps
  
*-------------------------------------------------------------------------------

* B3. Firm-level value and Firm-product level quantity

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo value_1: reghdfe dlnvalue_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo value_2: reghdfe dlnvalue_YoY brw l12.lnrSI l.dlnvalue_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
eststo value_3: reghdfe dlnvalue brw dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo value_4: reghdfe dlnvalue brw l.lnrSI l.dlnvalue dlnNER_US, a(firm_id) vce(cluster firm_id year)

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear
eststo quant_1: reghdfe dlnquant_h_YoY brw, a(group_id) vce(cluster group_id time)
eststo quant_2: reghdfe dlnquant_h_YoY brw l12.lnrSI l.dlnquant_h_YoY, a(group_id) vce(cluster group_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm_HS6,clear
eststo quant_3: reghdfe dlnquant_h_YoY brw, a(group_id) vce(cluster group_id year)
eststo quant_4: reghdfe dlnquant_h_YoY brw l.lnrSI l.dlnquant_h_YoY, a(group_id) vce(cluster group_id year)

estfe value_* quant_*, labels(firm_id "Firm FE" group_id "Firm-Product FE")
esttab value_* quant_* using tables\tables_Oct2024\value_quant.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 3. Alternative monetary policy shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge m:1 year month using MPS\monthly\Shock_rescale\data\US_shock_scaled,nogen keep(matched master) keepus(*_s)
xtset firm_id time

eststo monthmps_1: reghdfe dlnprice_YoY ns_s dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_2: reghdfe dlnprice_YoY ns_s l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_3: reghdfe dlnprice_YoY BS_s dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_4: reghdfe dlnprice_YoY BS_s l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_5: reghdfe dlnprice_YoY target_s path_s dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_6: reghdfe dlnprice_YoY target_s path_s l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_7: reghdfe dlnprice_YoY mp_s cbi_s dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo monthmps_8: reghdfe dlnprice_YoY mp_s cbi_s l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe monthmps_*, labels(firm_id "Firm FE")
esttab monthmps_* using tables\tables_Oct2024\scaledmps.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("NS" "NS" "BS" "BS"  "Acosta" "Acosta" "JK" "JK") order(ns* BS* target* path* mp* cbi*)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
merge m:1 year using MPS\monthly\Shock_rescale\data\US_shock_scaled_annual,nogen keep(matched master) keepus(*_s)
xtset firm_id year

eststo annualmps_1: reghdfe dlnprice ns_s dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_2: reghdfe dlnprice ns_s l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_3: reghdfe dlnprice BS_s dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_4: reghdfe dlnprice BS_s l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_5: reghdfe dlnprice target_s path_s dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_6: reghdfe dlnprice target_s path_s l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_7: reghdfe dlnprice mp_s cbi_s dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo annualmps_8: reghdfe dlnprice mp_s cbi_s l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

estfe annualmps_*, labels(firm_id "Firm FE")
esttab annualmps_* using tables\tables_Oct2024\scaledmps_annual.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("NS" "NS" "BS" "BS"  "Acosta" "Acosta" "JK" "JK") order(ns* BS* target* path* mp* cbi*)

*-------------------------------------------------------------------------------

* 4. Monetary tightness in China

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge m:1 year month using control\china\China_m2g_monthly,nogen keep(matched master)
xtset firm_id time

eststo tight_monthly_1: reghdfe dlnprice_YoY brw c.brw#c.tight_YoY tight_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo tight_monthly_2: reghdfe dlnprice_YoY brw c.brw#c.tight_YoY tight_YoY l.dlnprice_YoY l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)

eststo tight_monthly_3: reghdfe dlnprice_YoY brw c.brw#c.tight_MoM tight_MoM dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo tight_monthly_4: reghdfe dlnprice_YoY brw c.brw#c.tight_MoM tight_MoM l.dlnprice_YoY l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
merge m:1 year using control\china\China_m2g_annual,nogen keep(matched master)
xtset firm_id year

eststo tight_annual_1: reghdfe dlnprice brw c.brw#c.tight_annual tight_annual dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo tight_annual_2: reghdfe dlnprice brw c.brw#c.tight_annual tight_annual l.dlnprice l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id year)

estfe tight_annual_* tight_monthly_*, labels(firm_id "Firm FE")
esttab tight_annual_* tight_monthly_* using tables\tables_Oct2024\tightness.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw* tight*)

*-------------------------------------------------------------------------------

* B4. Exact announcement date effect

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge n:1 year month using MPS\brw\weight\brw_weight_m,nogen keep(matched)
xtset firm_id time

eststo weightm_1: reghdfe dlnprice_YoY brw_weight_m dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo weightm_2: reghdfe dlnprice_YoY brw_weight_m l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo weightm_3: reghdfe dlnprice_YoY brw_weight_m l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
merge n:1 year using MPS\brw\weight\brw_weight_y,nogen keep(matched)
xtset firm_id year

eststo weighty_1: reghdfe dlnprice brw_weight_y dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo weighty_2: reghdfe dlnprice brw_weight_y l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo weighty_3: reghdfe dlnprice brw_weight_y l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

estfe weightm_* weighty_*, labels(firm_id "Firm FE")
esttab  weightm_* weighty_* using tables\tables_Oct2024\dateweight.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B5. Alternative aggregation

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
xtset group_id time 

eststo altagg_1: reghdfe dlnprice_h_YoY brw dlnNER_US, a(group_id) vce(cluster group_id time)
eststo altagg_2: reghdfe dlnprice_h_YoY brw l12.lnrSI dlnNER_US, a(group_id) vce(cluster group_id time)
eststo altagg_3: reghdfe dlnprice_h_YoY brw l12.lnrSI l.dlnprice_h_YoY dlnNER_US, a(group_id) vce(cluster group_id time)

cd "D:\Project E"
use samples\sample_monthly_exp,clear
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
rename group_id group_id_ipc
sort group_id_ipc time

eststo altagg_4: reghdfe dlnprice_YoY brw dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)
eststo altagg_5: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)
eststo altagg_6: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)

estfe altagg_*, labels(group_id "Firm-Product FE" group_id_ipc "Firm-Product-Country FE")
esttab altagg_* using tables\tables_Oct2024\altagg.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw L.*)

cd "D:\Project E"
use samples\sample_matched_exp_firm_HS6,clear
merge n:1 year using ER\US_NER_99_19,nogen keep(matched)
xtset group_id year

eststo annualagg_1: reghdfe dlnprice_h brw dlnNER_US, a(group_id) vce(cluster group_id year)
eststo annualagg_2: reghdfe dlnprice_h brw l.lnrSI dlnNER_US, a(group_id) vce(cluster group_id year)
eststo annualagg_3: reghdfe dlnprice_h brw l.lnrSI l.dlnprice_h dlnNER_US, a(group_id) vce(cluster group_id year)

cd "D:\Project E"
use samples\sample_matched_exp,clear
merge n:1 coun_aim year using ER\RER_99_19,nogen keep(matched)
merge n:1 year using ER\US_NER_99_19,nogen keep(matched)
rename group_id group_id_ipc
sort group_id_ipc year

eststo annualagg_4: reghdfe dlnprice brw dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc year)
eststo annualagg_5: reghdfe dlnprice brw l.lnrSI dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc year)
eststo annualagg_6: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc year)

estfe annualagg_*, labels(group_id "Firm-Product FE" group_id_ipc "Firm-Product-Country FE")
esttab annualagg_* using tables\tables_Oct2024\altagg_annual.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw L.*)

*-------------------------------------------------------------------------------

* B6. Approximate time match

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo app1_1: reghdfe dlnprice_YoY_app1 brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo app1_2: reghdfe dlnprice_YoY_app1 brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo app1_3: reghdfe dlnprice_YoY_app1 brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

eststo app2_1: reghdfe dlnprice_YoY_app2 brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo app2_2: reghdfe dlnprice_YoY_app2 brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo app2_3: reghdfe dlnprice_YoY_app2 brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe app1_* app2_*, labels(firm_id "Firm FE")
esttab app1_* app2_* using tables\tables_Oct2024\approximate.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("+- 1 month" "+- 1 month" "+- 1 month" "+- 2 months" "+- 2 months" "+- 2 months")

*-------------------------------------------------------------------------------

* B7. RMB price

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo RMB_1: reghdfe dlnprice_RMB_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo RMB_2: reghdfe dlnprice_RMB_YoY brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo RMB_3: reghdfe dlnprice_RMB_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo RMB_4: reghdfe dlnprice_RMB brw dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo RMB_5: reghdfe dlnprice_RMB brw l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo RMB_6: reghdfe dlnprice_RMB brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

estfe RMB_*, labels(firm_id "Firm FE")
esttab RMB_* using tables\tables_Oct2024\RMB.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "annual" "annual" "annual")

*-------------------------------------------------------------------------------

* B8. Single product firm

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
keep if HS6_count==1

eststo single_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo single_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo single_3: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
keep if HS6_count==1

eststo single_4: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo single_5: reghdfe dlnprice brw l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo single_6: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

estfe single_*, labels(firm_id "Firm FE")
esttab single_* using tables\tables_Oct2024\single.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B9. Ownership type

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo SOE_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="SOE", a(firm_id) vce(cluster firm_id time)
eststo SOE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="SOE", a(firm_id) vce(cluster firm_id time)
eststo MNE_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="MNE", a(firm_id) vce(cluster firm_id time)
eststo MNE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="MNE", a(firm_id) vce(cluster firm_id time)
eststo DPE_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="DPE", a(firm_id) vce(cluster firm_id time)
eststo DPE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="DPE", a(firm_id) vce(cluster firm_id time)
eststo JV_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="JV", a(firm_id) vce(cluster firm_id time)
eststo JV_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="JV", a(firm_id) vce(cluster firm_id time)

estfe SOE_* DPE_* MNE_* JV_*, labels(firm_id "Firm FE")
esttab SOE_* DPE_* MNE_* JV_* using tables\tables_Oct2024\ownership.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("SOE" "SOE" "DPE" "DPE" "MNE" "MNE"  "JV" "JV")


cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo annual_SOE_1: reghdfe dlnprice brw dlnNER_US if ownership=="SOE", a(firm_id) vce(cluster firm_id year)
eststo annual_SOE_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US if ownership=="SOE", a(firm_id) vce(cluster firm_id year)
eststo annual_MNE_1: reghdfe dlnprice brw dlnNER_US if ownership=="MNE", a(firm_id) vce(cluster firm_id year)
eststo annual_MNE_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US if ownership=="MNE", a(firm_id) vce(cluster firm_id year)
eststo annual_DPE_1: reghdfe dlnprice brw dlnNER_US if ownership=="DPE", a(firm_id) vce(cluster firm_id year)
eststo annual_DPE_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US if ownership=="DPE", a(firm_id) vce(cluster firm_id year)
eststo annual_JV_1: reghdfe dlnprice brw dlnNER_US if ownership=="JV", a(firm_id) vce(cluster firm_id year)
eststo annual_JV_2: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US if ownership=="JV", a(firm_id) vce(cluster firm_id year)

estfe annual_SOE_* annual_DPE_* annual_MNE_* annual_JV_*, labels(firm_id "Firm FE")
esttab annual_SOE_* annual_DPE_* annual_MNE_* annual_JV_* using tables\tables_Oct2024\ownership_annual.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("SOE" "SOE" "DPE" "DPE" "MNE" "MNE"  "JV" "JV")

*-------------------------------------------------------------------------------

* B10. Two-way traders

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge n:1 FRDM year using "D:\Project C\sample_matched\customs_matched_twoway",nogen keep(matched)
xtset firm_id time

eststo twoway_1: reghdfe dlnprice_YoY brw dlnNER_US if twoway_trade==1, a(firm_id) vce(cluster firm_id time)
eststo twoway_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US if twoway_trade==1, a(firm_id) vce(cluster firm_id time)
eststo twoway_3: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if twoway_trade==1, a(firm_id) vce(cluster firm_id time)

eststo oneway_1: reghdfe dlnprice_YoY brw dlnNER_US if twoway_trade==0, a(firm_id) vce(cluster firm_id time)
eststo oneway_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US if twoway_trade==0, a(firm_id) vce(cluster firm_id time)
eststo oneway_3: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if twoway_trade==0, a(firm_id) vce(cluster firm_id time)

estfe twoway_* oneway_*, labels(firm_id "Firm FE")
esttab twoway_* oneway_* using tables\tables_Oct2024\twoway_trade.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
merge n:1 FRDM year using "D:\Project C\sample_matched\customs_matched_twoway",nogen keep(matched)
xtset firm_id year

eststo annual_twoway_1: reghdfe dlnprice brw dlnNER_US if twoway_trade==1, a(firm_id) vce(cluster firm_id year)
eststo annual_twoway_2: reghdfe dlnprice brw l.lnrSI dlnNER_US if twoway_trade==1, a(firm_id) vce(cluster firm_id year)
eststo annual_twoway_3: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US if twoway_trade==1, a(firm_id) vce(cluster firm_id year)

eststo annual_oneway_1: reghdfe dlnprice brw dlnNER_US if twoway_trade==0, a(firm_id) vce(cluster firm_id year)
eststo annual_oneway_2: reghdfe dlnprice brw l.lnrSI dlnNER_US if twoway_trade==0, a(firm_id) vce(cluster firm_id year)
eststo annual_oneway_3: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US if twoway_trade==0, a(firm_id) vce(cluster firm_id year)

estfe annual_twoway_* annual_oneway_*, labels(firm_id "Firm FE")
esttab annual_twoway_* annual_oneway_* using tables\tables_Oct2024\twoway_trade_annual.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B11. Alternative FE and cluster

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo FE_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id year) vce(cluster firm_id time)
eststo FE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id year) vce(cluster firm_id time)

eststo FE_3: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id month) vce(cluster firm_id time)
eststo FE_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id month) vce(cluster firm_id time)

eststo cluster_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster time)
eststo cluster_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster time)

eststo cluster_3: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster cic2)
eststo cluster_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster cic2)

estfe FE_* cluster_* , labels(firm_id "Firm FE" year "Year FE" month "Month FE")
esttab FE_* cluster_* using tables\tables_Oct2024\altFE.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo annual_cluster_1: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster year)
eststo annual_cluster_2: reghdfe dlnprice brw l1.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster year)

eststo annual_cluster_3: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster cic2)
eststo annual_cluster_4: reghdfe dlnprice brw l1.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster cic2)

*-------------------------------------------------------------------------------

* B12. Additional control variables

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

merge n:1 year month using control\china\China_cpi,nogen keep(matched)
gen cpi_cn=cpi_china/100-1
merge n:1 year month using control\china\China_iva,nogen keep(matched)
gen iva_cn=iva_china/100-1
merge n:1 year month using control\us\US_PPI_monthly_unadjusted,nogen keep(matched)
gen ppi_us=ppi_us_ua/100-1
merge n:1 year month using BLS_US\INDPRO_US,nogen keep(matched) keepus(lnindpro)
merge n:1 year month using control\US\US_VIX_monthly,nogen keep(matched)
merge n:1 year month using control\commodity\IMF_commodity,nogen keep(matched) keepus(pindu poilapsp)
merge n:1 year month using control\world\world_import_quarterly_adjusted,nogen keep(matched)
gen lnvix=ln(vix)
gen lnpindu=ln(pindu)
gen lnpoil=ln(poilapsp)
gen lnvalue_imp_w=ln(value_imp_w)
xtset firm_id time

eststo control_1: reghdfe dlnprice_YoY brw l.s12.cpi_cn l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo control_2: reghdfe dlnprice_YoY brw l.s12.iva_cn l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo control_3: reghdfe dlnprice_YoY brw l.s12.lnvalue_imp_w l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo control_4: reghdfe dlnprice_YoY brw l.s12.lnvix l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo control_5: reghdfe dlnprice_YoY brw l.s12.lnpindu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo control_all: reghdfe dlnprice_YoY brw l.s12.cpi_cn l.s12.iva_cn l.s12.lnvix l.s12.lnpindu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe control_*, labels(firm_id "Firm FE")
esttab control_* using tables\tables_Oct2024\control_new.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("CN CPI" "CN Value Added" "VIX" "Input Price" "All") order(brw *cpi* *iva* *vix* *pindu* *ln*)

*-------------------------------------------------------------------------------

* A?. Arrelleno-Bond estimation and Arellano-Bover/Blundell-Bond system estimation

* Difference GMM and System GMM

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo ab_monthly_1: xtabond dlnprice_YoY brw dlnNER_US, lags(1) twostep vce(robust)
eststo ab_monthly_2: xtabond dlnprice_YoY brw l12.lnrSI dlnNER_US, lags(1) twostep vce(robust)

eststo sys_monthly_1: xtdpdsys dlnprice_YoY brw dlnNER_US, lags(1) twostep vce(robust)
eststo sys_monthly_2: xtdpdsys dlnprice_YoY brw l12.lnrSI dlnNER_US, lags(1) twostep vce(robust)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo ab_annual_1: xtabond dlnprice brw dlnNER_US, lags(1) twostep vce(robust)
eststo ab_annual_2: xtabond dlnprice brw l.lnrSI dlnNER_US, lags(1) twostep vce(robust)

eststo sys_annual_1: xtdpdsys dlnprice brw dlnNER_US, lags(1) twostep vce(robust)
eststo sys_annual_2: xtdpdsys dlnprice brw l.lnrSI dlnNER_US, lags(1) twostep vce(robust)

esttab ab_monthly_* ab_annual_* sys_monthly_* sys_annual_* using tables\tables_Oct2024\Arrelleno-Bond.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) compress nogaps

*-------------------------------------------------------------------------------

* FA1. Country heterogeneity

cd "D:\Project E"
use samples\sample_monthly_exp,clear
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched)
keep if rank_exp<=21
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
xtset group_id time

statsby _b _se n=(e(N)), by(countrycode rank_exp) clear: reghdfe dlnprice_YoY brw dlnRER dlnrgdp dlnNER_US, a(group_id) vce(cluster group_id)

graph hbar (asis) _b_brw, over(countrycode, label(labsize(*0.45)) sort(_b_brw) des) ytitle("Export price responses to US monetary policy shocks") nofill

graph export figures\brw_month_country_20.png, as(png) replace

/*
drop if _b_brw==.
gen lower_bound = _b_brw - 1.645 * _se_brw
gen upper_bound = _b_brw + 1.645 * _se_brw

keep countrycode _b_brw _se_brw lower_bound upper_bound rank_exp
drop rank_exp
sort rank_exp

twoway (bar _b_brw rank_exp, horizontal) (rcap lower_bound upper_bound rank_exp, horizontal), ytitle("Country Code") xtitle("Export price responses to US monetary policy shocks")
*/

*-------------------------------------------------------------------------------

* FA?. Monte Carlo permutation tests

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

gen beta_brw=.
gen se_brw=.
gen tval_brw=.
gen pval_brw=.

forvalues i=1/1000{
shufflevar brw
qui reghdfe dlnprice_YoY brw_shuffled dlnNER_US, a(firm_id) vce(cluster firm_id time)
replace beta_brw=_b[brw] if _n==`i'
replace se_brw=_se[brw] if _n==`i'
replace tval_brw=_b[brw]/_se[brw] if _n==`i'
replace pval_brw=2*ttail(e(df_r),abs(tval_brw))
}
keep if beta_brw!=.
keep *_brw
gen sig_brw=0 if abs(pval_brw)>0.1
replace sig_brw=1 if abs(pval_brw)<=0.1
replace sig_brw=2 if abs(pval_brw)<=0.05
replace sig_brw=3 if abs(pval_brw)<=0.01
save tables\shuffle_1000,replace

use figures\shuffle_1000,clear
hist tval_brw, bin(50) kdensity xlabel(-3(1)3) xtitle(T-statistic of beta) xline(-1.96 1.96)
graph export "D:\Project E\figures\permutation_shuffle_1000.png", as(png) replace

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
permute brw _b[brw], r(100) strata(firm_id): reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
ritest brw _b[brw], r(100) strata(firm_id) kdensityplot: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)

graph export "D:\Project E\figures\permutation_ritest_100.png", as(png) replace

*===============================================================================

* Section IV. Mechanism

global liquidtiy "Cash Liquid Apay Arec"
global borrow_cost "IEoL IEoCL FNoL FNoCL"

*-------------------------------------------------------------------------------

* 5. Liquidity (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Liquidity (first stage)
eststo Cash: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo Liquid: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo Apay: reghdfe D.Apay brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo Arec: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe Cash Liquid Apay Arec, labels(firm_id "Firm FE")
esttab Cash Liquid Apay Arec using tables\tables_Oct2024\liquid_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

* 5+. Liquidity (first stage, non-exporter)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int==0

* Liquidity (first stage, non-exporter)
eststo Cash_nonexp: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo Liquid_nonexp: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo Apay_nonexp: reghdfe D.Apay brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo Arec_nonexp: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe Cash_nonexp Liquid_nonexp Apay_nonexp Arec_nonexp, labels(firm_id "Firm FE")
esttab Cash_nonexp Liquid_nonexp Apay_nonexp Arec_nonexp using tables\tables_Oct2024\liquid_nonexp.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 6. Borrowing cost (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Borrowing cost (first stage)
eststo borrow_1: reghdfe D.IEoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_2: reghdfe D.IEoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_3: reghdfe D.FNoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_4: reghdfe D.FNoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Debt (first stage)
eststo debt_1: reghdfe D.lnTL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo debt_2: reghdfe D.lnCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe borrow_* debt_*, labels(firm_id "Firm FE")
esttab borrow_* debt_* using tables\tables_Oct2024\borrow_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

* 6+. Borrowing cost (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int==0

* Borrowing cost (first stage, non-exporter)
eststo borrow_1_nonexp: reghdfe D.IEoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_2_nonexp: reghdfe D.IEoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_3_nonexp: reghdfe D.FNoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_4_nonexp: reghdfe D.FNoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Debt (first stage)
eststo debt_1_nonexp: reghdfe D.lnTL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo debt_2_nonexp: reghdfe D.lnCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe borrow_*_nonexp debt_*_nonexp, labels(firm_id "Firm FE")
esttab borrow_*_nonexp debt_*_nonexp using tables\tables_Oct2024\borrow_nonexp.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* Borrowing cost distribution

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

foreach var of global borrow_cost{
	gen `var'_d=1 if l.`var'>l.`var'_cic2
	replace `var'_d=0 if l.`var'<=l.`var'_cic2
	gen d`var'=D.`var'
	winsor2 d`var',trim
}

twoway (hist dIEoL_tr if IEoL_d==0 & year==2005, color(blue%50) width(0.01) legend(label(1 "Density-Low Cost")) xtitle(Change of Borrowing Costs (IEoL)) ytitle(Density)) (hist dIEoL_tr if IEoL_d==1 & year==2005, color(red%50) width(0.01) legend(label(2 "Density-High Cost"))) (kdensity dIEoL_tr if IEoL_d==0 & year==2005, color(blue) bwidth(0.003) legend(label(3 "Kernel Density-High Cost"))) (kdensity dIEoL_tr if IEoL_d==1 & year==2005, bwidth(0.003) color(red) legend(label(4 "Kernel Density-High Cost")))
graph export figures\dIEoL_hist_2005.png, as(png) replace

preserve
cumul dIEoL_tr if IEoL_d==0 & year==2001, gen(dIEoL_cum_0) 
cumul dIEoL_tr if IEoL_d==1 & year==2001, gen(dIEoL_cum_1) 
twoway (line dIEoL_cum_0 dIEoL_tr if IEoL_d==0 & year==2001,sort xtitle(Change of Borrowing Costs (IEoL)) ytitle(Empirical CDF) legend(label(1 "CDF-Low Cost"))) (line dIEoL_cum_1 dIEoL_tr if IEoL_d==1 & year==2001,sort legend(label(2 "CDF-High Cost")))
graph export figures\dIEoL_CDF_2005.png, as(png) replace
restore

ttest dIEoL_tr if year==2005, by(IEoL_d)

*-------------------------------------------------------------------------------

* C1. Borrowing cost changes with lag interaction

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Borrowing cost (lag)
eststo lag_borrow_1: reghdfe D.IEoL c.brw#c.l.IEoL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_borrow_2: reghdfe D.IEoCL c.brw#c.l.IEoCL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_borrow_3: reghdfe D.FNoL c.brw#c.l.FNoL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_borrow_4: reghdfe D.FNoCL c.brw#c.l.FNoCL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

estfe lag_borrow_*, labels(firm_id "Firm FE" year "Year FE")
esttab lag_borrow_* using tables\tables_Oct2024\borrow_lag.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Liquidity (lag)
eststo lag_Cash: reghdfe D.Cash c.brw#c.l.Cash L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_Liquid: reghdfe D.Liquid c.brw#c.l.Liquid L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

* Liquidity (lag)
eststo lag_Apay: reghdfe D.Apay c.brw#c.l.Apay L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_Arec: reghdfe D.Arec c.brw#c.l.Arec  L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

estfe lag_Cash lag_Liquid lag_Apay lag_Arec, labels(firm_id "Firm FE" year "Year FE")
esttab lag_Cash lag_Liquid lag_Apay lag_Arec using tables\tables_Oct2024\liquid_lag.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

*-------------------------------------------------------------------------------

* 7. Borrowing cost (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* Borrowing cost (interaction)
eststo int_IEoL_1: reghdfe dlnprice_YoY c.brw#c.l12.IEoL_cic2, a(firm_id time) vce(cluster time)
eststo int_IEoL_2: reghdfe dlnprice_YoY c.brw#c.l12.IEoL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster time)
eststo int_IEoCL_1: reghdfe dlnprice_YoY c.brw#c.l12.IEoCL_cic2, a(firm_id time) vce(cluster time)
eststo int_IEoCL_2: reghdfe dlnprice_YoY c.brw#c.l12.IEoCL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster time)
eststo int_FNoL_1: reghdfe dlnprice_YoY c.brw#c.l12.FNoL_cic2, a(firm_id time) vce(cluster time)
eststo int_FNoL_2: reghdfe dlnprice_YoY c.brw#c.l12.FNoL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster time)
eststo int_FNoCL_1: reghdfe dlnprice_YoY c.brw#c.l12.FNoCL_cic2, a(firm_id time) vce(cluster time)
eststo int_FNoCL_2: reghdfe dlnprice_YoY c.brw#c.l12.FNoCL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster time)

estfe int_IEoL_* int_IEoCL_* int_FNoL_* int_FNoCL_*, labels(firm_id "Firm FE" time "Year-month FE")
esttab int_IEoL_* int_IEoCL_* int_FNoL_* int_FNoCL_* using tables\tables_Oct2024\borrow_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

* Borrowing cost (interaction)
eststo annual_IEoL_1: reghdfe dlnprice c.brw#c.l.IEoL_cic2, a(firm_id year) vce(cluster year)
eststo annual_IEoL_2: reghdfe dlnprice c.brw#c.l.IEoL_cic2 l1.lnrSI l.dlnprice, a(firm_id year) vce(cluster year)
eststo annual_IEoCL_1: reghdfe dlnprice c.brw#c.l.IEoCL_cic2, a(firm_id year) vce(cluster year)
eststo annual_IEoCL_2: reghdfe dlnprice c.brw#c.l.IEoCL_cic2 l.lnrSI l.dlnprice, a(firm_id year) vce(cluster year)
eststo annual_FNoL_1: reghdfe dlnprice c.brw#c.l.FNoL_cic2, a(firm_id year) vce(cluster year)
eststo annual_FNoL_2: reghdfe dlnprice c.brw#c.l.FNoL_cic2 l.lnrSI l.dlnprice, a(firm_id year) vce(cluster year)
eststo annual_FNoCL_1: reghdfe dlnprice c.brw#c.l.FNoCL_cic2, a(firm_id year) vce(cluster year)
eststo annual_FNoCL_2: reghdfe dlnprice c.brw#c.l.FNoCL_cic2 l.lnrSI l.dlnprice, a(firm_id year) vce(cluster year)

estfe annual_IEoL_* annual_IEoCL_* annual_FNoL_* annual_FNoCL_*, labels(firm_id "Firm FE" year "Year FE")
esttab annual_IEoL_* annual_IEoCL_* annual_FNoL_* annual_FNoCL_* using tables\tables_Oct2024\borrow_B_annual.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

*-------------------------------------------------------------------------------

* B2. Liquidity (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* Liquidity (interaction)

eststo int_Cash_1: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Cash_2: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo int_Liquid_1: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Liquid_2: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo int_Apay_1: reghdfe dlnprice_YoY c.brw#c.l12.Apay_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Apay_2: reghdfe dlnprice_YoY c.brw#c.l12.Apay_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo int_Arec_1: reghdfe dlnprice_YoY c.brw#c.l12.Arec_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Arec_2: reghdfe dlnprice_YoY c.brw#c.l12.Arec_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

estfe int_Cash_* int_Liquid_* int_Apay_* int_Arec_*, labels(firm_id "Firm FE" time "Year-month FE")
esttab int_Cash_* int_Liquid_* int_Apay_* int_Arec_* using tables\tables_Oct2024\liquid_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

* Liquidity (interaction)

eststo int_Cash_1: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Cash_2: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo int_Liquid_1: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Liquid_2: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo int_Apay_1: reghdfe dlnprice_YoY c.brw#c.l12.Apay_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Apay_2: reghdfe dlnprice_YoY c.brw#c.l12.Apay_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo int_Arec_1: reghdfe dlnprice_YoY c.brw#c.l12.Arec_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Arec_2: reghdfe dlnprice_YoY c.brw#c.l12.Arec_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

estfe int_Cash_* int_Liquid_* int_Apay_* int_Arec_*, labels(firm_id "Firm FE" time "Year-month FE")
esttab int_Cash_* int_Liquid_* int_Apay_* int_Arec_* using tables\tables_Oct2024\liquid_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

*-------------------------------------------------------------------------------

* 8. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo decomp_1: reghdfe D.lnMarkup brw l.lnrSI, a(firm_id) vce(cluster firm_id year)
eststo decomp_2: reghdfe dlnMC brw l.lnrSI, a(firm_id) vce(cluster firm_id year)
eststo decomp_3: reghdfe dlnprice brw D.lnMarkup l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)
eststo decomp_4: reghdfe dlnprice brw dlnMC l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo decomp_5: reghdfe dlnprice_YoY brw S12.lnMarkup l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo decomp_6: reghdfe dlnprice_YoY brw dlnMC_YoY l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe decomp_*, labels(firm_id "Firm FE")
esttab decomp_* using tables\tables_Oct2024\decomposition.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B4. Within-sector and across-sector markup

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_*)
xtset firm_id time

eststo firm_markup_1: reghdfe dlnprice_YoY c.brw#c.l12.Markup_DLWTLD l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)
eststo firm_markup_2: reghdfe dlnprice_YoY c.brw#c.Markup_DLWTLD_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)

eststo within_markup_1: reghdfe dlnprice_YoY c.brw#c.Markup_cic2_High_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)
eststo within_markup_2: reghdfe dlnprice_YoY c.brw#c.Markup_cic4_High_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)

eststo across_markup_1: reghdfe dlnprice_YoY c.brw#c.l12.Markup_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)
eststo across_markup_2: reghdfe dlnprice_YoY c.brw#c.Markup_cic2_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)

eststo across_markup_3: reghdfe dlnprice_YoY c.brw#c.l12.Markup_cic4 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)
eststo across_markup_4: reghdfe dlnprice_YoY c.brw#c.Markup_cic4_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id time)

estfe firm_markup_2 within_markup_* across_markup_*, labels(firm_id "Firm FE" time "Time FE")
esttab firm_markup_2 within_markup_* across_markup_* using tables\tables_Oct2024\markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(*brw*)

* B4*. Within-sector and across-sector markup (Markup change)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_*)
xtset firm_id year

reghdfe D.lnMarkup brw c.brw#c.Markup_cic2_High_1st l.lnrSI, a(firm_id) vce(cluster firm_id time)
reghdfe D.lnMarkup brw c.brw#c.Markup_cic4_High_1st l.lnrSI, a(firm_id) vce(cluster firm_id time)

reghdfe D.lnMarkup brw c.brw#c.l.Markup_cic2 l.lnrSI, a(firm_id) vce(cluster firm_id time)
reghdfe D.lnMarkup brw c.brw#c.Markup_cic2_1st l.lnrSI, a(firm_id) vce(cluster firm_id time)

reghdfe D.lnMarkup brw c.brw#c.l.Markup_cic4 l.lnrSI, a(firm_id) vce(cluster firm_id time)
reghdfe D.lnMarkup brw c.brw#c.Markup_cic4_1st l.lnrSI, a(firm_id) vce(cluster firm_id time)

*-------------------------------------------------------------------------------

* B5. Discussion about other production cost

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

eststo material: reghdfe D.TOIPToS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id time)
eststo wage: reghdfe D.CWPoS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo material_int: reghdfe dlnprice_YoY brw c.brw#c.TOIPToS l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo wage_int: reghdfe dlnprice_YoY brw c.brw#c.CWPoS l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo imp_int: reghdfe dlnprice_YoY brw c.brw#c.imp_int l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe material wage material_int wage_int imp_int, labels(firm_id "Firm FE")
esttab material wage material_int wage_int imp_int using tables\tables_Oct2024\other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

*-------------------------------------------------------------------------------

* 9. FDI (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

gen FDI=1 if ownership=="MNE" | ownership=="JV"
replace FDI=0 if ownership=="SOE" | ownership=="DPE"

eststo domestic_1: reghdfe dlnprice_YoY brw if FDI==0, a(firm_id) vce(cluster firm_id time)
eststo domestic_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY if FDI==0, a(firm_id) vce(cluster firm_id time)
eststo FDI_1: reghdfe dlnprice_YoY brw if FDI==1, a(firm_id) vce(cluster firm_id time)
eststo FDI_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY if FDI==1, a(firm_id) vce(cluster firm_id time)

eststo FDI_int_1: reghdfe dlnprice_YoY brw c.brw#c.FDI l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)
eststo FDI_int_2: reghdfe dlnprice_YoY brw c.brw#c.FDI l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)

estfe domestic_* FDI_*, labels(firm_id "Firm FE")
esttab domestic_* FDI_* using tables\tables_Oct2024\FDI.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

*-------------------------------------------------------------------------------

* 10. Financial development

cd "D:\Project E"
use samples\sample_monthly_exp,clear
merge n:1 year coun_aim using GFDD\GFDD_matched,nogen keep(matched)
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
rename group_id group_id_ipc
xtset group_id_ipc time

eststo fd_cont: reghdfe dlnprice_YoY brw c.brw#c.fd dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)
eststo fd_d50: reghdfe dlnprice_YoY brw c.brw#c.fd_d50 dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)
eststo fd_d75: reghdfe dlnprice_YoY brw c.brw#c.fd_d75 dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)
eststo fd_d90: reghdfe dlnprice_YoY brw c.brw#c.fd_d90 dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc time)

estfe fd*, labels(group_id_ipc "Firm FE")
esttab fd* using tables\tables_Oct2024\fd_fpc.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

*-------------------------------------------------------------------------------

* 11. Ordinary vs Processing

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo ordinary_1: reghdfe dlnprice_YoY brw dlnNER_US if process==0, a(firm_id) vce(cluster firm_id time)
eststo ordinary_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US l.dlnprice_YoY if process==0, a(firm_id) vce(cluster firm_id time)
eststo process_1: reghdfe dlnprice_YoY brw dlnNER_US if process==1, a(firm_id) vce(cluster firm_id time)
eststo process_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if process==1, a(firm_id) vce(cluster firm_id time)
eststo processint_1: reghdfe dlnprice_YoY brw c.brw#c.process dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo processint_2: reghdfe dlnprice_YoY brw c.brw#c.process l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe ordinary_* process_* processint_*, labels(firm_id "Firm FE")
esttab ordinary_* process_* processint_* using tables\tables_Oct2024\process.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("Ordinary" "Ordinary" "Processing" "Processing" "Comparison" "Comparison" )

*-------------------------------------------------------------------------------

* B7. Homogenous vs differentiated good

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo Rauch_1: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_2: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_3: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con_r dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_4: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con_r l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_5: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_6: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_7: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib_r dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo Rauch_8: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib_r l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

estfe Rauch_*, labels(firm_id "Firm FE")
esttab Rauch_* using tables\tables_Oct2024\Rauch.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("Conservative" "Conservative" "Conservative" "Conservative" "Liberal" "Liberal" "Liberal" "Liberal") order(brw c.brw*)

*-------------------------------------------------------------------------------

* 9. Standardized EU shocks and comparison with brw

cd "D:\Project E"
use samples\sample_monthly_exp_firm_ECB,clear
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id time
eststo EU_JK_ECB: reghdfe dlnprice_YoY brw mp_eu cbi_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_monthly_exp_firm_US,clear
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id time
eststo EU_JK_US: reghdfe dlnprice_YoY brw mp_eu cbi_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_monthly_exp_firm_nonUSECB,clear
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id time
eststo EU_JK_non: reghdfe dlnprice_YoY brw mp_eu cbi_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id time
eststo EU_JK_all: reghdfe dlnprice_YoY brw mp_eu cbi_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)
hel
estfe EU_*, labels(firm_id "Firm FE")
esttab EU_* using tables\tables_Oct2024\ECB.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw *_eu *lnrSI *dlnprice*)

cd "D:\Project E"
use samples\sample_matched_exp_firm_ECB,clear
merge m:1 year using MPS\monthly\eu_infoshock_annual,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id year
eststo annual_EU_JK_ECB: reghdfe dlnprice brw mp_eu cbi_eu l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

cd "D:\Project E"
use samples\sample_matched_exp_firm_US,clear
merge m:1 year using MPS\monthly\eu_infoshock_annual,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id year
eststo annual_EU_JK_US: reghdfe dlnprice brw mp_eu cbi_eu l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

cd "D:\Project E"
use samples\sample_matched_exp_firm_nonUSECB,clear
merge m:1 year using MPS\monthly\eu_infoshock_annual,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id year
eststo annual_EU_JK_non: reghdfe dlnprice brw mp_eu cbi_eu l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
merge m:1 year using MPS\monthly\eu_infoshock_annual,nogen keep(matched master)
rename (mp_median_mpd cbi_median_mpd) (mp_eu cbi_eu)
xtset firm_id year
eststo annual_EU_JK_all: reghdfe dlnprice brw mp_eu cbi_eu l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id year)
hel
estfe annual_EU_*, labels(firm_id "Firm FE")
esttab annual_EU_* using tables\tables_Oct2024\ECB_annual.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw *_eu *lnrSI *dlnprice*)