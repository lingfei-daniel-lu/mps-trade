* This do-file is to run regressions for the second draft of Li, Lu, and Yao (2023) by Dec 31, 2023.

********************************************************************************

set processor 8

*-------------------------------------------------------------------------------

* F1. US monetary policy shock

cd "D:\Project E\MPS\brw"
use brw_month,replace
drop if brw==0
keep if year<=2021
twoway scatter brw ym, ytitle(US monetary policy shock) xtitle(time) tline(2000m1 2006m12) title("Monetary policy shock series by BRW(2021)") saving(BRW.png, replace)

*-------------------------------------------------------------------------------

* 1. Summary Statistics

cd "D:\Project E"
use customs_matched\customs_matched_exp_firm,clear

replace value=value/1000

merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched)

eststo sum_stats: estpost sum HS6_count value SI PERSENG Debt IEoL Liquid exp_int imp_int, detail

esttab sum_stats using "tables_Jan2024\sum_stats.tex", replace cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) p25(fmt(2)) p75(fmt(2))") label booktab nonumber nomtitles

*-------------------------------------------------------------------------------

* F2. Monthly US MPS and China's Export Prices

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

binscatter dlnprice_YoY brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("Monthly US MPS and China's Export Price") savegraph("D:\Project E\tables_Jan2024\brw_monthly.png") replace discrete

*-------------------------------------------------------------------------------

* 2. Baseline

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo baseline_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo baseline_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo baseline_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo baseline_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo baseline_5: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo baseline_6: reghdfe dlnprice brw l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo baseline_7: reghdfe dlnprice brw l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo baseline_8: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe baseline_*, labels(firm_id "Firm FE")
esttab baseline_* using tables_Jan2024\baseline.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "monthly" "annual" "annual" "annual" "annual")

*-------------------------------------------------------------------------------

* A1. Dynamic regression

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo forward_`i': reghdfe f`i'.dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY f`i'.dlnNER_US, a(firm_id) vce(cluster firm_id)
}

estfe forward_*, labels(firm_id "Firm FE")
esttab forward_* using tables_Jan2024\dynamic.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

* FA1. Dynamic regression

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

gen b=0
gen u=0
gen d=0

* Regression

forv h = 0/12 {
reghdfe f`h'.dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY f`h'.dlnNER_US, a(firm_id) vce(cluster firm_id)
replace b = _b[brw]                    if _n == `h'+1
replace u = _b[brw] + 1.96* _se[brw]  if _n == `h'+1
replace d = _b[brw] - 1.96* _se[brw]  if _n == `h'+1
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

*-------------------------------------------------------------------------------

* A2. Firm-level value and Firm-product level quantity

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo value_1: reghdfe dlnvalue_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo value_2: reghdfe dlnvalue_YoY brw l12.lnrSI l.dlnvalue_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
eststo value_3: reghdfe dlnvalue brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo value_4: reghdfe dlnvalue brw l.lnrSI l.dlnvalue dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear
eststo quant_1: reghdfe dlnquant_h_YoY brw, a(group_id) vce(cluster group_id)
eststo quant_2: reghdfe dlnquant_h_YoY brw l12.lnrSI l.dlnquant_h_YoY, a(group_id) vce(cluster group_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm_HS6,clear
eststo quant_3: reghdfe dlnquant_h_YoY brw, a(group_id) vce(cluster group_id)
eststo quant_4: reghdfe dlnquant_h_YoY brw l.lnrSI l.dlnquant_h_YoY, a(group_id) vce(cluster group_id)

estfe value_* quant_*, labels(firm_id "Firm FE" group_id "Firm-Product FE")
esttab value_* quant_* using tables_Jan2024\value_quant.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 3. Rescaled monetary policy shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

merge m:1 year month using MPS\monthly\US_shock_scaled,nogen keep(matched master)
xtset firm_id time
replace ffr_shock=0 if ffr_shock==.
replace ns=0 if ns==.
replace target=0 if target==.
replace path=0 if path==.
replace mp=0 if mp==.
replace cbi=0 if cbi==.

eststo scaledmps_1: reghdfe dlnprice_YoY ffr_shock dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_2: reghdfe dlnprice_YoY ffr_shock l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_3: reghdfe dlnprice_YoY ns dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_4: reghdfe dlnprice_YoY ns l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_5: reghdfe dlnprice_YoY target path dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_6: reghdfe dlnprice_YoY target path l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_7: reghdfe dlnprice_YoY mp cbi dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo scaledmps_8: reghdfe dlnprice_YoY mp cbi l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe scaledmps_*, labels(firm_id "Firm FE")
esttab scaledmps_* using tables_Jan2024\scaledmps.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("FFR" "FFR" "NS" "NS" "Acosta" "Acosta" "JK" "JK") order(ffr_shock ns target path mp cbi)

*-------------------------------------------------------------------------------

* 3+. Pair-wise correlation between different shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

merge m:1 year month using MPS\monthly\US_shock_scaled,nogen keep(matched)
xtset firm_id time

corr brw ffr_shock ns target path mp cbi
matrix C = r(C)
esttab matrix(C) using tables_Jan2024/correlation_matrix.csv, replace compress b(2)

*-------------------------------------------------------------------------------

* A3. Alternative aggregation

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
xtset group_id time 

eststo altagg_1: reghdfe dlnprice_h_YoY brw dlnNER_US, a(group_id) vce(cluster group_id)
eststo altagg_2: reghdfe dlnprice_h_YoY brw l12.lnrSI dlnNER_US, a(group_id) vce(cluster group_id)
eststo altagg_3: reghdfe dlnprice_h_YoY brw l.dlnprice_h_YoY dlnNER_US, a(group_id) vce(cluster group_id)
eststo altagg_4: reghdfe dlnprice_h_YoY brw l12.lnrSI l.dlnprice_h_YoY dlnNER_US, a(group_id) vce(cluster group_id)

cd "D:\Project E"
use samples\sample_monthly_exp,clear
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
rename group_id group_id_ipc
sort group_id_ipc time

eststo altagg_5: reghdfe dlnprice_YoY brw dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_6: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_7: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_8: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER inflation dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)

estfe altagg_*, labels(group_id "Firm-Product FE" group_id_ipc "Firm-Product-Country FE")
esttab altagg_* using tables_Jan2024\altagg.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw L.*)

*-------------------------------------------------------------------------------

* A4. Single product firm

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
keep if HS6_count==1

eststo single_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo single_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo single_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo single_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
keep if HS6_count==1

eststo single_5: reghdfe dlnprice brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo single_6: reghdfe dlnprice brw l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo single_7: reghdfe dlnprice brw l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo single_8: reghdfe dlnprice brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe single_*, labels(firm_id "Firm FE")
esttab single_* using tables_Jan2024\single.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* A5. Ownership type

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo SOE_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="SOE", a(firm_id) vce(cluster firm_id)
eststo SOE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="SOE", a(firm_id) vce(cluster firm_id)
eststo MNE_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="MNE", a(firm_id) vce(cluster firm_id)
eststo MNE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="MNE", a(firm_id) vce(cluster firm_id)
eststo DPE_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="DPE", a(firm_id) vce(cluster firm_id)
eststo DPE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="DPE", a(firm_id) vce(cluster firm_id)
eststo JV_1: reghdfe dlnprice_YoY brw dlnNER_US if ownership=="JV", a(firm_id) vce(cluster firm_id)
eststo JV_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if ownership=="JV", a(firm_id) vce(cluster firm_id)

estfe SOE_* DPE_* MNE_* JV_*, labels(firm_id "Firm FE")
esttab SOE_* DPE_* MNE_* JV_* using tables_Jan2024\ownership.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("SOE" "SOE" "DPE" "DPE" "MNE" "MNE"  "JV" "JV")

*-------------------------------------------------------------------------------

* A6. Alternative FE and cluster

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo FE_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id year) vce(cluster firm_id)
eststo FE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id year) vce(cluster firm_id)

eststo FE_3: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id month) vce(cluster firm_id)
eststo FE_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id month) vce(cluster firm_id)

eststo cluster_1: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id time)
eststo cluster_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id time)

eststo cluster_3: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster time)
eststo cluster_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster time)

eststo cluster_5: reghdfe dlnprice_YoY brw dlnNER_US, a(firm_id) vce(cluster cic2)
eststo cluster_6: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster cic2)

estfe FE_* cluster_* , labels(firm_id "Firm FE" year "Year FE" month "Month FE")
esttab FE_* cluster_* using tables_Jan2024\altFE.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* A7. RMB price

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo RMB_1: reghdfe dlnprice_RMB_YoY brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo RMB_2: reghdfe dlnprice_RMB_YoY brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo RMB_3: reghdfe dlnprice_RMB_YoY brw l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo RMB_4: reghdfe dlnprice_RMB_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo RMB_5: reghdfe dlnprice_RMB brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo RMB_6: reghdfe dlnprice_RMB brw l.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo RMB_7: reghdfe dlnprice_RMB brw l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo RMB_8: reghdfe dlnprice_RMB brw l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe RMB_*, labels(firm_id "Firm FE")
esttab RMB_* using tables_Jan2024\RMB.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "monthly" "annual" "annual" "annual" "annual")

*-------------------------------------------------------------------------------

* A8. Additional control variables

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

merge n:1 year month using control\china\China_cpi,nogen keep(matched)
gen cpi_cn=cpi_china/100-1
merge n:1 year month using control\china\China_iva,nogen keep(matched)
gen iva_cn=iva_china/100-1
*merge n:1 year month using control\china\China_ppi,nogen keep(matched)
merge n:1 year month using control\china\China_policy_rate,nogen keep(matched)
merge n:1 year month using control\US\US_CPI_monthly_unadjusted,nogen keep(matched)
gen cpi_us=cpi_us_ua/100-1
merge n:1 year month using control\US\US_PPI_monthly_unadjusted,nogen keep(matched)
gen ppi_us=ppi_us_ua/100-1
merge n:1 year month using control\US\US_VIX_monthly,nogen keep(matched)
gen lnvix=ln(vix)
merge n:1 year month using control\commodity\IMF_commodity,nogen keep(matched) keepus(pindu poilapsp)
gen lnpindu=ln(pindu)
gen lnpoil=ln(poilapsp)

xtset firm_id time

eststo control_1: reghdfe dlnprice_YoY brw l.cpi_cn l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_2: reghdfe dlnprice_YoY brw l.iva_cn l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_3: reghdfe dlnprice_YoY brw l.cpi_us l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_4: reghdfe dlnprice_YoY brw l.ppi_us l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_5: reghdfe dlnprice_YoY brw l.lnvix l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_6: reghdfe dlnprice_YoY brw l.s12.lnpindu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_7: reghdfe dlnprice_YoY brw l.s12.lnpoil l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo control_8: reghdfe dlnprice_YoY brw l.cpi_cn l.iva_cn l.cpi_us l.ppi_us l.lnvix l.s12.lnpindu l.s12.lnpoil l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe control_*, labels(firm_id "Firm FE")
esttab control_* using tables_Jan2024\control.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("China CPI" "China Value Added" "US CPI" "US PPI" "VIX" "Input Price" "Oil Price" "All") order(brw *_cn *_us *vix *S12*)

*-------------------------------------------------------------------------------

* A9. Approximate time match

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo app1_1: reghdfe dlnprice_YoY_app1 brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo app1_2: reghdfe dlnprice_YoY_app1 brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo app1_3: reghdfe dlnprice_YoY_app1 brw l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo app1_4: reghdfe dlnprice_YoY_app1 brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

eststo app2_1: reghdfe dlnprice_YoY_app2 brw dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo app2_2: reghdfe dlnprice_YoY_app2 brw l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo app2_3: reghdfe dlnprice_YoY_app2 brw l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo app2_4: reghdfe dlnprice_YoY_app2 brw l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe app1_* app2_*, labels(firm_id "Firm FE")
esttab app1_* app2_* using tables_Jan2024\approximate.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("+- 1 month" "+- 1 month" "+- 1 month" "+- 1 month" "+- 2 months" "+- 2 months" "+- 2 months" "+- 2 months")

*-------------------------------------------------------------------------------

* FA2. Country heterogeneity

cd "D:\Project E"
use samples\sample_monthly_exp,clear
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched)
keep if rank_exp<=21
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
xtset group_id time

statsby _b _se n=(e(N)), by(countrycode rank_exp) clear: reghdfe dlnprice_YoY brw dlnRER dlnrgdp dlnNER_US, a(group_id) vce(cluster group_id)

graph hbar (asis) _b_brw, over(countrycode, label(labsize(*0.45)) sort(rank_exp)) ytitle("Export price responses to US monetary policy shocks") nofill

graph export tables_Jan2024\brw_month_country_20.png, as(png) replace

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

* 4. Liquidity (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Liquidity (first stage)
eststo liquid_1: reghdfe D.FPC_liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_2: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_3: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_4: reghdfe D.Turnover brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Trade credit (first stage)
eststo liquid_5: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_6: reghdfe D.Apay brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe liquid_*, labels(firm_id "Firm FE")
esttab liquid_* using tables_Jan2024\liquid_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B1. Liquidity with lag level (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Liquidity (first stage)
eststo lag_liquid_1: reghdfe D.FPC_liquid c.brw#c.l.FPC_liquid L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_liquid_2: reghdfe D.Liquid c.brw#c.l.Liquid L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_liquid_3: reghdfe D.Cash c.brw#c.l.Cash L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_liquid_4: reghdfe D.Turnover c.brw#c.l.Turnover L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

* Trade credit (first stage)
eststo lag_liquid_5: reghdfe D.Arec c.brw#c.l.Arec L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_liquid_6: reghdfe D.Apay c.brw#c.l.Apay L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

estfe lag_liquid_*, labels(firm_id "Firm FE" year "Year FE")
esttab lag_liquid_* using tables_Jan2024\liquid_lag_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(*brw*)

*-------------------------------------------------------------------------------

* 5. Liquidity (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* Liquidity (interaction)
eststo int_FPC_1: reghdfe dlnprice_YoY c.brw#c.l12.FPC_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_FPC_2: reghdfe dlnprice_YoY c.brw#c.l12.FPC_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo int_Liquid_1: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Liquid_2: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo int_Cash_1: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_Cash_2: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

estfe int_FPC_* int_Liquid_* int_Cash_*, labels(firm_id "Firm FE" time "Year-month FE")
esttab int_FPC_* int_Liquid_* int_Cash_* using tables_Jan2024\liquid_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

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
esttab borrow_* debt_* using tables_Jan2024\borrow_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B2. Borrowing cost with lag level (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Borrowing cost (first stage)
eststo lag_borrow_1: reghdfe D.IEoL c.brw#c.l.IEoL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_borrow_2: reghdfe D.IEoCL c.brw#c.l.IEoCL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_borrow_3: reghdfe D.FNoL c.brw#c.l.FNoL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_borrow_4: reghdfe D.FNoCL c.brw#c.l.FNoCL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

* Debt (first stage)
eststo lag_debt_1: reghdfe D.lnTL c.brw#c.l.lnTL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)
eststo lag_debt_2: reghdfe D.lnCL c.brw#c.l.lnCL L.lnrSI L.Debt, a(firm_id year) vce(cluster firm_id)

estfe lag_borrow_* lag_debt_*, labels(firm_id "Firm FE" year "Year FE")
esttab lag_borrow_* lag_debt_* using tables_Jan2024\borrow_lag_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 7. Borrowing cost (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* Borrowing cost (interaction)
eststo int_IEoL_1: reghdfe dlnprice_YoY c.brw#c.l12.IEoL_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_IEoL_2: reghdfe dlnprice_YoY c.brw#c.l12.IEoL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo int_IEoCL_1: reghdfe dlnprice_YoY c.brw#c.l12.IEoCL_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_IEoCL_2: reghdfe dlnprice_YoY c.brw#c.l12.IEoCL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo int_FNoL_1: reghdfe dlnprice_YoY c.brw#c.l12.FNoL_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_FNoL_2: reghdfe dlnprice_YoY c.brw#c.l12.FNoL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo int_FNoCL_1: reghdfe dlnprice_YoY c.brw#c.l12.FNoCL_cic2, a(firm_id time) vce(cluster firm_id)
eststo int_FNoCL_2: reghdfe dlnprice_YoY c.brw#c.l12.FNoCL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

estfe int_IEoL_* int_IEoCL_* int_FNoL_* int_FNoCL_*, labels(firm_id "Firm FE")
esttab int_IEoL_* int_IEoCL_* int_FNoL_* int_FNoCL_* using tables_Jan2024\borrow_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

*-------------------------------------------------------------------------------

* B4. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo decomp_1: reghdfe S12.Markup_DLWTLD brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo decomp_2: reghdfe dlnMC_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo decomp_3: reghdfe dlnprice_YoY brw S12.Markup_DLWTLD l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo decomp_4: reghdfe dlnprice_YoY brw dlnMC_YoY l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo decomp_5: reghdfe D.Markup_DLWTLD brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo decomp_6: reghdfe dlnMC brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo decomp_7: reghdfe dlnprice brw D.Markup_DLWTLD l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo decomp_8: reghdfe dlnprice brw dlnMC l.lnrSI l.dlnprice dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe decomp_*, labels(firm_id "Firm FE")
esttab decomp_* using tables_Jan2024\decomposition.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* B5. Within-sector and across-sector markup

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_*)
xtset firm_id time

eststo firm_markup_1: reghdfe dlnprice_YoY c.brw#c.l12.Markup_DLWTLD l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo firm_markup_2: reghdfe dlnprice_YoY c.brw#c.Markup_DLWTLD_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo within_markup_1: reghdfe dlnprice_YoY c.brw#c.Markup_cic2_High_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo within_markup_2: reghdfe dlnprice_YoY c.brw#c.Markup_cic4_High_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo across_markup_1: reghdfe dlnprice_YoY c.brw#c.l12.Markup_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo across_markup_2: reghdfe dlnprice_YoY c.brw#c.Markup_cic2_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

eststo across_markup_3: reghdfe dlnprice_YoY c.brw#c.l12.Markup_cic4 l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)
eststo across_markup_4: reghdfe dlnprice_YoY c.brw#c.Markup_cic4_1st l12.lnrSI l.dlnprice_YoY, a(firm_id time) vce(cluster firm_id)

estfe firm_markup_2 within_markup_* across_markup_*, labels(firm_id "Firm FE" time "Time FE")
esttab firm_markup_2 within_markup_* across_markup_* using tables_Jan2024\markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(*brw*)

*-------------------------------------------------------------------------------

* B6. Tests of other channels

cd "D:\Project E"
use samples\cie_credit_brw,clear

eststo material: reghdfe D.TOIPToS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo wage: reghdfe D.CWPoS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo material_int: reghdfe dlnprice_YoY brw c.brw#c.TOIPToS l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo wage_int: reghdfe dlnprice_YoY brw c.brw#c.CWPoS l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo imp_int: reghdfe dlnprice_YoY brw c.brw#c.imp_int l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe material wage material_int wage_int imp_int, labels(firm_id "Firm FE")
esttab material wage material_int wage_int imp_int using tables_Jan2024\other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

*-------------------------------------------------------------------------------

* 8. Ordinary vs Processing

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo ordinary_1: reghdfe dlnprice_YoY brw dlnNER_US if process==0, a(firm_id) vce(cluster firm_id)
eststo ordinary_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US l.dlnprice_YoY if process==0, a(firm_id) vce(cluster firm_id)
eststo process_1: reghdfe dlnprice_YoY brw dlnNER_US if process==1, a(firm_id) vce(cluster firm_id)
eststo process_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if process==1, a(firm_id) vce(cluster firm_id)
eststo process_int_1: reghdfe dlnprice_YoY brw c.brw#c.process dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo process_int_2: reghdfe dlnprice_YoY brw c.brw#c.process l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe ordinary_* process_* process_int_*, labels(firm_id "Firm FE")
esttab ordinary_* process_* process_int_* using tables_Jan2024\process.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("ordinary" "ordinary" "processing" "processing" "comparison" "comparison")

*-------------------------------------------------------------------------------

* 9. Homogenous vs differentiated good

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo Rauch_1: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_2: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_3: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con_r dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_4: reghdfe dlnprice_YoY brw c.brw#c.Rauch_con_r l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_5: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_6: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_7: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib_r dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Rauch_8: reghdfe dlnprice_YoY brw c.brw#c.Rauch_lib_r l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe Rauch_*, labels(firm_id "Firm FE")
esttab Rauch_* using tables_Jan2024\Rauch.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("Conservative" "Conservative" "Conservative" "Conservative" "Liberal" "Liberal" "Liberal" "Liberal") order(brw c.brw*)

*-------------------------------------------------------------------------------

* 10. Market-specific exposure

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge n:1 FRDM year using customs_matched\customs_matched_exposure,nogen keep(matched)
xtset firm_id time

eststo exposure_US: reghdfe dlnprice_YoY brw c.brw#c.exposure_US l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo exposure_EU: reghdfe dlnprice_YoY brw c.brw#c.exposure_EU l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo exposure_OECD: reghdfe dlnprice_YoY brw c.brw#c.exposure_OECD l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo exposure_EME: reghdfe dlnprice_YoY brw c.brw#c.exposure_EME l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo exposure_all: reghdfe dlnprice_YoY brw c.brw#c.exposure_US c.brw#c.exposure_EU c.brw#c.exposure_OECD c.brw#c.exposure_EME l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe exposure_*, labels(firm_id "Firm FE")
esttab exposure_* using tables_Jan2024\exposure.csv, replace b(3) se(3) noconstant nogap star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw *brw*)

*-------------------------------------------------------------------------------

* 11. Standardized EU shocks and comparison with brw

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge m:1 year month using MPS\monthly\shock_std,nogen keep(matched master)
local std_shock "brw_std target_eu path_eu mp_eu cbi_eu"
foreach var of local std_shock{
	replace `var'=0 if `var'==.
}
xtset firm_id time

eststo std_brw: reghdfe dlnprice_YoY brw_std l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

* Miranda-Agrippino & Nenova
eststo std_EU_MAN_1: reghdfe dlnprice_YoY target_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo std_EU_MAN_2: reghdfe dlnprice_YoY path_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo std_EU_MAN_3: reghdfe dlnprice_YoY target_eu path_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

* Jarocinski & Karadi
eststo std_EU_JK_1: reghdfe dlnprice_YoY mp_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo std_EU_JK_2: reghdfe dlnprice_YoY cbi_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo std_EU_JK_3: reghdfe dlnprice_YoY mp_eu cbi_eu l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe std_*, labels(firm_id "Firm FE")
esttab std_* using tables_Jan2024\EU.csv, replace b(4) se(4) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw_std *_eu *lnrSI *dlnprice*)

*-------------------------------------------------------------------------------

* 12. Fixed and floating regime

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo fixed_1: reghdfe dlnprice_YoY brw dlnNER_US if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER_US if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

eststo float_1: reghdfe dlnprice_YoY brw dlnNER_US if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER_US if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnNER_US if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

estfe fixed_* float_*, labels(firm_id "Firm FE")
esttab fixed_* float_* using tables_Jan2024\regime.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("fixed" "fixed" "fixed" "fixed" "floating" "floating" "floating" "floating")

*-------------------------------------------------------------------------------

* 13. Asymmetric impact

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
merge m:1 year month using MPS\monthly\ffr_monthly,nogen keep(matched master)
xtset firm_id time

eststo up_1: reghdfe dlnprice_YoY brw c.brw#c.real_increase dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo up_2: reghdfe dlnprice_YoY brw c.brw#c.real_increase l.dlnprice_YoY l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo down_1: reghdfe dlnprice_YoY brw c.brw#c.real_decrease dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo down_2: reghdfe dlnprice_YoY brw c.brw#c.real_decrease l.dlnprice_YoY l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe up_* down_*, labels(firm_id "Firm FE")
esttab up_* down_* using tables_Jan2024\asymmetry.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("tightening" "tightening" "easing" "easing" "any change" "any change") order(brw c.brw*)