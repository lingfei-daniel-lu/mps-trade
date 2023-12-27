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

esttab sum_stats using "tables_Dec2023_v2\sum_stats.tex", replace cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) p25(fmt(2)) p75(fmt(2))") label booktab nonumber nomtitles

*-------------------------------------------------------------------------------

* F2. Monthly US MPS and China's Export Prices

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

binscatter dlnprice_YoY brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("Monthly US MPS and China's Export Price") savegraph("D:\Project E\tables_Dec2023_v2\brw_monthly.png") replace discrete

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
esttab baseline_* using tables_Dec2023_v2\baseline.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "monthly" "annual" "annual" "annual" "annual")

*-------------------------------------------------------------------------------

* A1. Dynamic regression

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo forward_`i': reghdfe f`i'.dlnprice_YoY brw f`i'.dlnNER_US, a(firm_id) vce(cluster firm_id)
}

estfe forward_*, labels(firm_id "Firm FE")
esttab forward_* using tables_Dec2023_v2\dynamic.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

* FA1. Dynamic regression

gen b=0
gen u=0
gen d=0

* Regression

forv h = 0/12 {
reghdfe f`h'.dlnprice_YoY brw f`i'.dlnNER_US, a(firm_id) vce(cluster firm_id)
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
esttab value_* quant_* using tables_Dec2023_v2\value_quant.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 3. Alternative monetary policy shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

merge m:1 year month using MPS\monthly\NS_shock,nogen keep(matched master) keepus(*_shock)
merge m:1 year month using MPS\monthly\target_path_ns,nogen keep(matched master) keepus(target path)
merge m:1 year month using MPS\monthly\us_infoshock_monthly,nogen keep(matched master) keepus(mp_median)
replace NS_shock=0 if NS_shock==.
replace ffr_shock=0 if ffr_shock==.
replace target=0 if target==.
replace path=0 if path==.
replace mp_median=0 if mp_median==.
xtset firm_id time

eststo altmps_1: reghdfe dlnprice_YoY NS_shock dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_2: reghdfe dlnprice_YoY NS_shock l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_3: reghdfe dlnprice_YoY ffr_shock dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_4: reghdfe dlnprice_YoY ffr_shock l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_5: reghdfe dlnprice_YoY target path dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_6: reghdfe dlnprice_YoY target path l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_7: reghdfe dlnprice_YoY mp_median dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo altmps_8: reghdfe dlnprice_YoY mp_median l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe altmps_*, labels(firm_id "Firm FE")
esttab altmps_* using tables_Dec2023_v2\altmps.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("NS" "NS" "FFR" "FFR" "Acosta" "Acosta" "JK" "JK") order(*_shock target path mp_median)

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

eststo altagg_5: reghdfe dlnprice_YoY brw dlnRER dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_6: reghdfe dlnprice_YoY brw l12.lnrSI dlnRER dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_7: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnRER dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_8: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnRER dlnrgdp dlnNER_US, a(group_id_ipc) vce(cluster group_id_ipc)

estfe altagg_*, labels(group_id "Firm-Product FE" group_id_ipc "Firm-Product-Country FE")
esttab altagg_* using tables_Dec2023_v2\altagg.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw L.*)

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
esttab single_* using tables_Dec2023_v2\single.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* A5. Alternative FE and cluster

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
esttab FE_* cluster_* using tables_Dec2023_v2\altFE.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* A6. RMB price

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
esttab RMB_* using tables_Dec2023_v2\USD.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "monthly" "annual" "annual" "annual" "annual")

*-------------------------------------------------------------------------------

* A7. Additional control variables

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
esttab control_* using tables_Dec2023_v2\control.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("China CPI" "China Value Added" "US CPI" "US PPI" "VIX" "Input Price" "Oil Price" "All") order(brw *_cn *_us *vix *S12*)

*-------------------------------------------------------------------------------

* A8. Ownership type

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
esttab SOE_* DPE_* MNE_* JV_* using tables_Dec2023_v2\ownership.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("SOE" "SOE" "DPE" "DPE" "MNE" "MNE"  "JV" "JV")

*-------------------------------------------------------------------------------

* FA2. Country heterogeneity

cd "D:\Project E"
use samples\sample_monthly_exp,clear
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched)
keep if rank_exp<=21
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
xtset group_id time

statsby _b _se n=(e(N)), by(countrycode) clear: reghdfe dlnprice_YoY brw dlnRER dlnrgdp dlnNER_US, a(group_id) vce(cluster group_id)

graph hbar (asis) _b_brw, over(countrycode, label(labsize(*0.45)) sort(1)) ytitle("Export price responses to US monetary policy shocks") nofill

graph export tables_Dec2023_v2\brw_month_country_20.png, as(png) replace

egen rank = rank(-_b_brw)
gen lower_bound = _b_brw - 1.645 * _se_brw
gen upper_bound = _b_brw + 1.645 * _se_brw

keep countrycode _b_brw _se_brw lower_bound upper_bound rank
sort rank

twoway (bar _b_brw rank, horizontal) ///
       (rcap lower_bound upper_bound rank, horizontal) ///
       , ytitle("Country Code") xtitle("Export price responses to US monetary policy shocks")
	   
*-------------------------------------------------------------------------------

* 4. Liquidity (first stage)

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

eststo liquid_1: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_2: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_3: reghdfe D.Turnover brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_4: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe liquid_*, labels(firm_id "Firm FE")
esttab liquid_* using tables_Dec2023_v2\liquid_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 5. Liquidity (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo int_liquid_1: reghdfe dlnprice_YoY c.brw#c.l12.Liquid_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)
eststo int_liquid_2: reghdfe dlnprice_YoY c.brw#c.l12.Cash_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)
eststo int_liquid_3: reghdfe dlnprice_YoY c.brw#c.l12.Turnover_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)
eststo int_liquid_4: reghdfe dlnprice_YoY c.brw#c.l12.Arec_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)

estfe int_liquid_*, labels(firm_id "Firm FE")
esttab int_liquid_* using tables_Dec2023_v2\liquid_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

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
esttab borrow_* debt_* using tables_Dec2023_v2\borrow_A.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 7. Borrowing cost (interaction)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* Borrowing cost (interaction)
eststo int_borrow_1: reghdfe dlnprice_YoY c.brw#c.l12.IEoL_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)
eststo int_borrow_2: reghdfe dlnprice_YoY c.brw#c.l12.IEoCL_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)
eststo int_borrow_3: reghdfe dlnprice_YoY c.brw#c.l12.FNoL_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)
eststo int_borrow_4: reghdfe dlnprice_YoY c.brw#c.l12.FNoCL_cic2 l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id time) vce(cluster firm_id)

estfe int_borrow_*, labels(firm_id "Firm FE")
esttab int_borrow_* using tables_Dec2023_v2\borrow_B.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(c.brw*)

*-------------------------------------------------------------------------------

* A9. Decomposition into markup and marginal cost

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
esttab decomp_* using tables_Dec2023_v2\decomposition.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* A10. Tests of other channels

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
esttab material wage material_int wage_int imp_int using tables_Dec2023_v2\other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

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
esttab ordinary_* process_* process_int_* using tables_Dec2023_v2\process.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("ordinary" "ordinary" "processing" "processing" "comparison" "comparison")

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
esttab Rauch_* using tables_Dec2023_v2\Rauch.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("Conservative" "Conservative" "Conservative" "Conservative" "Liberal" "Liberal" "Liberal" "Liberal") order(brw c.brw*)

*-------------------------------------------------------------------------------

* 10. EU shocks

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* add monetary policy shocks (Miranda-Agrippino & Nenova)
merge m:1 year month using MPS\monthly\eu_shock_monthly,nogen keep(matched)
rename target_ea eu_shock
replace eu_shock=0 if eu_shock==.
xtset firm_id time

eststo EU_1: reghdfe dlnprice_YoY eu_shock dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo EU_2: reghdfe dlnprice_YoY eu_shock l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo EU_3: reghdfe dlnprice_YoY eu_shock l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo EU_4: reghdfe dlnprice_YoY eu_shock l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* add monetary policy shocks 
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched) keepus(mp_median_mpd)
rename mp_median_mpd eu_shock
replace eu_shock=0 if eu_shock==.
xtset firm_id time

eststo EU_5: reghdfe dlnprice_YoY eu_shock dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo EU_6: reghdfe dlnprice_YoY eu_shock l12.lnrSI dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo EU_7: reghdfe dlnprice_YoY eu_shock l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo EU_8: reghdfe dlnprice_YoY eu_shock l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe EU_*, labels(firm_id "Firm FE")
esttab EU_* using tables_Dec2023_v2\EU.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(eu_shock *lnrSI *dlnprice*)

*-------------------------------------------------------------------------------

* 11. Fixed and floating regime

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
esttab fixed_* float_* using tables_Dec2023_v2\regime.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("fixed" "fixed" "fixed" "fixed" "floating" "floating" "floating" "floating")

*-------------------------------------------------------------------------------

* 12. Asymmetric impact

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo up_1: reghdfe dlnprice_YoY brw dlnNER_US if brw>0, a(firm_id) vce(cluster firm_id)
eststo up_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US if brw>0, a(firm_id) vce(cluster firm_id)
eststo up_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER_US if brw>0, a(firm_id) vce(cluster firm_id)
eststo up_4: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI dlnNER_US if brw>0, a(firm_id) vce(cluster firm_id)

eststo down_1: reghdfe dlnprice_YoY brw dlnNER_US if brw<0, a(firm_id) vce(cluster firm_id)
eststo down_2: reghdfe dlnprice_YoY brw l12.lnrSI dlnNER_US if brw<0, a(firm_id) vce(cluster firm_id)
eststo down_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnNER_US if brw<0, a(firm_id) vce(cluster firm_id)
eststo down_4: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI dlnNER_US if brw<0, a(firm_id) vce(cluster firm_id)

estfe up_* down_*, labels(firm_id "Firm FE")
esttab up_* down_* using tables_Dec2023_v2\asymmetry.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("tightening" "tightening" "tightening" "tightening" "easing" "easing" "easing" "easing")

*-------------------------------------------------------------------------------

* A11. Firm heterogeneity: high markup vs low markup

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo Markup_1: reghdfe dlnprice_YoY brw c.brw#c.Markup_High l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Markup_2: reghdfe dlnprice_YoY brw c.brw#c.l.Markup_High l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Markup_3: reghdfe dlnprice_YoY brw c.brw#c.Markup_High_1st l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

eststo Markup_4: reghdfe dlnprice_YoY brw c.brw#c.Markup_DLWTLD l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Markup_5: reghdfe dlnprice_YoY brw c.brw#c.l.Markup_DLWTLD l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)
eststo Markup_6: reghdfe dlnprice_YoY brw c.brw#c.Markup_DLWTLD_1st l12.lnrSI l.dlnprice_YoY dlnNER_US, a(firm_id) vce(cluster firm_id)

estfe Markup_*, labels(firm_id "Firm FE")
esttab Markup_* using tables_Dec2023_v2\markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("dummy" "dummy" "dummy" "level" "level" "level") order(*brw*)