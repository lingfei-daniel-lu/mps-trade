* This do-file is to run regressions for the second draft of Li, Lu, and Yao (2023) by Dec 31, 2023.

********************************************************************************

set processor 8

*-------------------------------------------------------------------------------

* 1. Summary Statistics

cd "D:\Project E"
use customs_matched\customs_matched_exp_firm,clear

replace value_RMB=value_RMB/1000

merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched)

eststo sum_stats: estpost sum HS6_count value_RMB SI PERSENG Debt IEoL Liquid exp_int imp_int, detail

esttab sum_stats using "tables_Dec2023\sum_stats.tex", replace cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) p25(fmt(2)) p75(fmt(2))") label booktab nonumber nomtitles

*-------------------------------------------------------------------------------

* F1. Summary Statistics

binscatter dlnprice_YoY brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("Monthly US MPS and China's Export Price") savegraph("D:\Project E\figures\brw_monthly.png") replace discrete

*-------------------------------------------------------------------------------

* 2. Baseline

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo baseline_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo baseline_2: reghdfe dlnprice_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo baseline_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo baseline_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo baseline_5: reghdfe dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo baseline_6: reghdfe dlnprice brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo baseline_7: reghdfe dlnprice brw l.dlnprice, a(firm_id) vce(cluster firm_id)
eststo baseline_8: reghdfe dlnprice brw l.lnrSI l.dlnprice, a(firm_id) vce(cluster firm_id)

estfe baseline_*, labels(firm_id "Firm FE")
esttab baseline_* using tables_Dec2023\baseline.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "monthly" "annual" "annual" "annual" "annual")

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

eststo altmps_1: reghdfe dlnprice_YoY NS_shock, a(firm_id) vce(cluster firm_id)
eststo altmps_2: reghdfe dlnprice_YoY NS_shock l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo altmps_3: reghdfe dlnprice_YoY ffr_shock, a(firm_id) vce(cluster firm_id)
eststo altmps_4: reghdfe dlnprice_YoY ffr_shock l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo altmps_5: reghdfe dlnprice_YoY target path, a(firm_id) vce(cluster firm_id)
eststo altmps_6: reghdfe dlnprice_YoY target path l12.lnrSI l.dlnprice_YoY , a(firm_id) vce(cluster firm_id)
eststo altmps_7: reghdfe dlnprice_YoY mp_median, a(firm_id) vce(cluster firm_id)
eststo altmps_8: reghdfe dlnprice_YoY mp_median l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe altmps_*, labels(firm_id "Firm FE")
esttab altmps_* using tables_Dec2023\altmps.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("NS" "NS" "FFR" "FFR" "Acosta" "Acosta" "JK" "JK") order(*_shock target path mp_median)

*-------------------------------------------------------------------------------

* A2. Alternative aggregation

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear

eststo altagg_1: reghdfe dlnprice_h_YoY brw, a(group_id) vce(cluster group_id)
eststo altagg_2: reghdfe dlnprice_h_YoY brw l12.lnrSI, a(group_id) vce(cluster group_id)
eststo altagg_3: reghdfe dlnprice_h_YoY brw l.dlnprice_h_YoY, a(group_id) vce(cluster group_id)
eststo altagg_4: reghdfe dlnprice_h_YoY brw l12.lnrSI l.dlnprice_h_YoY, a(group_id) vce(cluster group_id)

cd "D:\Project E"
use samples\sample_monthly_exp,clear
rename group_id group_id_ipc
sort group_id_ipc time

eststo altagg_5: reghdfe dlnprice_YoY brw dlnRER dlnrgdp, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_6: reghdfe dlnprice_YoY brw l12.lnrSI dlnRER dlnrgdp, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_7: reghdfe dlnprice_YoY brw l.dlnprice_YoY dlnRER dlnrgdp, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_8: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY dlnRER dlnrgdp, a(group_id_ipc) vce(cluster group_id_ipc)

estfe altagg_*, labels(group_id "Firm-Product FE" group_id_ipc "Firm-Product-Country FE")
esttab altagg_* using tables_Dec2023\altagg.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw L.*)

*-------------------------------------------------------------------------------

* A3. Single product firm

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
keep if HS6_count==1

eststo single_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo single_2: reghdfe dlnprice_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo single_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo single_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
keep if HS6_count==1

eststo single_5: reghdfe dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo single_6: reghdfe dlnprice brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo single_7: reghdfe dlnprice brw l.dlnprice, a(firm_id) vce(cluster firm_id)
eststo single_8: reghdfe dlnprice brw l.lnrSI l.dlnprice, a(firm_id) vce(cluster firm_id)

estfe single_*, labels(firm_id "Firm FE")
esttab single_* using tables_Dec2023\single.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* A4. Alternative FE and cluster

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo FE_1: reghdfe dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo FE_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id year) vce(cluster firm_id)

eststo FE_3: reghdfe dlnprice_YoY brw, a(firm_id month) vce(cluster firm_id)
eststo FE_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id month) vce(cluster firm_id)

eststo cluster_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id time)
eststo cluster_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id time)

eststo cluster_3: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster time)
eststo cluster_4: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster time)

eststo cluster_5: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster cic2)
eststo cluster_6: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster cic2)

estfe FE_* cluster_* , labels(firm_id "Firm FE" year "Year FE" month "Month FE")
esttab FE_* cluster_* using tables_Dec2023\altFE.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 4. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo markup_1: reghdfe S12.Markup_DLWTLD brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_2: reghdfe dlnMC_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_3: reghdfe dlnprice_YoY brw S12.Markup_DLWTLD l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo markup_4: reghdfe dlnprice_YoY brw dlnMC_YoY l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo markup_5: reghdfe D.Markup_DLWTLD brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_6: reghdfe dlnMC brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_7: reghdfe dlnprice brw D.Markup_DLWTLD l.lnrSI l.dlnprice, a(firm_id) vce(cluster firm_id)
eststo markup_8: reghdfe dlnprice brw dlnMC l.lnrSI l.dlnprice, a(firm_id) vce(cluster firm_id)

estfe markup_*, labels(firm_id "Firm FE")
esttab markup_* using tables_Dec2023\markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 5. Borrowing cost and liquidity change

* 5.1 Panel A: exporters

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

* Borrowing cost
eststo exp_borrow_1: reghdfe D.IEoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_borrow_2: reghdfe D.IEoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_borrow_3: reghdfe D.FNoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_borrow_4: reghdfe D.FNoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Liquidity condition
eststo exp_liquid_1: reghdfe D.WC brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_liquid_2: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_liquid_3: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_liquid_4: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe exp_borrow_* exp_liquid_*, labels(firm_id "Firm FE")
esttab exp_borrow_* exp_liquid_* using tables_Dec2023\liquid_exp.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

* 5.2 Panel B: all firms

cd "D:\Project E"
use samples\cie_credit_brw,clear

* Borrowing cost
eststo borrow_1: reghdfe D.IEoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_2: reghdfe D.IEoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_3: reghdfe D.FNoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo borrow_4: reghdfe D.FNoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Liquidity condition
eststo liquid_1: reghdfe D.WC brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_2: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_3: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo liquid_4: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe borrow_* liquid_*, labels(firm_id "Firm FE")
esttab borrow_* liquid_* using tables_Dec2023\liquid_all.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

*-------------------------------------------------------------------------------

* 6. Tests of other channels

cd "D:\Project E"
use samples\cie_credit_brw,clear

eststo material: reghdfe D.TOIPToS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo wage: reghdfe D.CWPoS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo material_int: reghdfe dlnprice_YoY brw c.brw#c.TOIPToS l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo wage_int: reghdfe dlnprice_YoY brw c.brw#c.CWPoS l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo imp_int: reghdfe dlnprice_YoY brw c.brw#c.imp_int l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe material wage material_int wage_int imp_int, labels(firm_id "Firm FE")
esttab material wage material_int wage_int imp_int using tables_Dec2023\other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

*-------------------------------------------------------------------------------

* 7. Borrowing cost and liquidity interaction

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo borrow_int_1: reghdfe dlnprice_YoY brw c.brw#c.IEoL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo borrow_int_2: reghdfe dlnprice_YoY brw c.brw#c.IEoCL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo borrow_int_3: reghdfe dlnprice_YoY brw c.brw#c.FNoL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo borrow_int_4: reghdfe dlnprice_YoY brw c.brw#c.FNoCL_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

eststo liquid_int_1: reghdfe dlnprice_YoY brw c.brw#c.WC_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo liquid_int_2: reghdfe dlnprice_YoY brw c.brw#c.Liquid_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo liquid_int_3: reghdfe dlnprice_YoY brw c.brw#c.Cash_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo liquid_int_4: reghdfe dlnprice_YoY brw c.brw#c.Arec_cic2 l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe borrow_int_* liquid_int_*, labels(firm_id "Firm FE")
esttab borrow_int_* liquid_int_* using tables_Dec2023\liquid_int.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(brw c.brw*)

*-------------------------------------------------------------------------------

* 8. Ordinary vs Processing

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo ordinary_1: reghdfe dlnprice_YoY brw if process==0, a(firm_id) vce(cluster firm_id)
eststo ordinary_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY if process==0, a(firm_id) vce(cluster firm_id)
eststo process_1: reghdfe dlnprice_YoY brw if process==1, a(firm_id) vce(cluster firm_id)
eststo process_2: reghdfe dlnprice_YoY brw l12.lnrSI l.dlnprice_YoY if process==1, a(firm_id) vce(cluster firm_id)
eststo process_int_1: reghdfe dlnprice_YoY brw c.brw#c.process, a(firm_id) vce(cluster firm_id)
eststo process_int_2: reghdfe dlnprice_YoY brw c.brw#c.process l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe ordinary_* process_* process_int_*, labels(firm_id "Firm FE")
esttab ordinary_* process_* process_int_* using tables_Dec2023\process.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("ordinary" "ordinary" "processing" "processing" "comparison" "comparison")
*-------------------------------------------------------------------------------

* ?. Dynamic regression

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo forward_`i': reghdfe f`i'.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
}

estfe forward_*, labels(firm_id "Firm FE")
esttab forward_* using tables_Dec2023\dynamic.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
statsby _b _se,clear: reghdfe f`i'.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
}

graph bar (asis) _b_brw, over(coun_aim, label(labsize(*0.45)) sort(1)) ytitle("Dynamic response to monetary policy shocks") nofill
graph export tables_Dec2023\dynamic, as(png) replace

*-------------------------------------------------------------------------------

* 9. Homogenous vs differentiated good

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo Rauch_1: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con, a(firm_id) vce(cluster firm_id)
eststo Rauch_2: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo Rauch_3: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con_r, a(firm_id) vce(cluster firm_id)
eststo Rauch_4: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con_r l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo Rauch_5: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib, a(firm_id) vce(cluster firm_id)
eststo Rauch_6: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo Rauch_7: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib_r, a(firm_id) vce(cluster firm_id)
eststo Rauch_8: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib_r l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

estfe Rauch_*, labels(firm_id "Firm FE")
esttab Rauch_* using tables_Dec2023\Rauch.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("Conservative" "Conservative" "Conservative" "Conservative" "Liberal" "Liberal" "Liberal" "Liberal") order(brw c.brw*)

*-------------------------------------------------------------------------------

* 10. EU shocks

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* add monetary policy shocks
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched master) keepus(mp_median_mpd)
rename mp_median_mpd eu_shock
replace eu_shock=0 if eu_shock==.
xtset firm_id time

eststo EU_1: reghdfe dlnprice_YoY eu_shock, a(firm_id) vce(cluster firm_id)
eststo EU_2: reghdfe dlnprice_YoY eu_shock l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo EU_3: reghdfe dlnprice_YoY eu_shock l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

* add monetary policy shocks
merge m:1 year using MPS\monthly\eu_infoshock_annual,nogen keep(matched master) keepus(mp_median_mpd)
rename mp_median_mpd eu_shock
replace eu_shock=0 if eu_shock==.
xtset firm_id year

eststo EU_4: reghdfe dlnprice eu_shock, a(firm_id) vce(cluster firm_id)
eststo EU_5: reghdfe dlnprice l.dlnprice eu_shock, a(firm_id) vce(cluster firm_id)
eststo EU_6: reghdfe dlnprice eu_shock l.lnrSI l.dlnprice, a(firm_id) vce(cluster firm_id)

estfe EU_*, labels(firm_id "Firm FE")
esttab EU_* using tables_Dec2023\EU.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps order(eu_shock) 

*-------------------------------------------------------------------------------

* 11. Fixed and floating regime

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo fixed_1: reghdfe dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_3: reghdfe dlnprice_YoY l12.lnrSI l.dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

eststo float_1: reghdfe dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_3: reghdfe dlnprice_YoY l12.lnrSI l.dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

estfe fixed_* float_*, labels(firm_id "Firm FE")
esttab fixed_* float_* using tables_Dec2023\regime.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("fixed" "fixed" "fixed" "floating" "floating" "floating")

*-------------------------------------------------------------------------------

* A5. USD price index

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo USD_1: reghdfe dlnprice_USD_YoY brw, a(firm_id) vce(cluster firm_id)
eststo USD_2: reghdfe dlnprice_USD_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo USD_3: reghdfe dlnprice_USD_YoY brw l12.lnrSI l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo USD_4: reghdfe dlnprice_USD brw, a(firm_id) vce(cluster firm_id)
eststo USD_5: reghdfe dlnprice_USD l.dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo USD_6: reghdfe dlnprice_USD brw l.lnrSI l.dlnprice, a(firm_id) vce(cluster firm_id)

estfe USD_*, labels(firm_id "Firm FE")
esttab USD_* using tables_Dec2023\USD.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps mtitle("monthly" "monthly" "monthly" "annual" "annual" "annual")
