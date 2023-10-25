* This do-file is to run regressions for the first draft of Li, Lu, and Yao (2023) by Oct 31, 2023.

********************************************************************************

set processor 8

*-------------------------------------------------------------------------------

* 1. Summary Statistics

*-------------------------------------------------------------------------------

* 2. Baseline

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo baseline_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo baseline_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo baseline_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo baseline_4: reghdfe dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo baseline_5: reghdfe dlnprice l.dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo baseline_6: reghdfe dlnprice brw l.dlnprice l.lnrSI, a(firm_id) vce(cluster firm_id)

estfe baseline_*, labels(firm_id "Firm FE")
esttab baseline_* using tables_Oct2023\baseline.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("monthly" "monthly" "monthly" "annual" "annual" "annual")

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
eststo altmps_2: reghdfe dlnprice_YoY NS_shock l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo altmps_3: reghdfe dlnprice_YoY ffr_shock, a(firm_id) vce(cluster firm_id)
eststo altmps_4: reghdfe dlnprice_YoY ffr_shock l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo altmps_5: reghdfe dlnprice_YoY target path, a(firm_id) vce(cluster firm_id)
eststo altmps_6: reghdfe dlnprice_YoY target path l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)
eststo altmps_7: reghdfe dlnprice_YoY mp_median, a(firm_id) vce(cluster firm_id)
eststo altmps_8: reghdfe dlnprice_YoY mp_median l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe altmps_*, labels(firm_id "Firm FE")
esttab altmps_* using tables_Oct2023\altmps.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("NS" "NS" "FFR" "FFR" "Acosta" "Acosta" "JK" "JK") order(*_shock target path mp_median)

*-------------------------------------------------------------------------------

* 4. Alternative aggregation

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear

eststo altagg_1: reghdfe dlnprice_h_YoY brw, a(group_id) vce(cluster group_id)
eststo altagg_2: reghdfe dlnprice_h_YoY l.dlnprice_h_YoY brw, a(group_id) vce(cluster group_id)
eststo altagg_3: reghdfe dlnprice_h_YoY brw l.dlnprice_h_YoY l12.lnrSI, a(group_id) vce(cluster group_id)

cd "D:\Project E"
use samples\sample_monthly_exp,clear
rename group_id group_id_ipc

eststo altagg_4: reghdfe dlnprice_YoY brw, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_5: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(group_id_ipc) vce(cluster group_id_ipc)
eststo altagg_6: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(group_id_ipc) vce(cluster group_id_ipc)

estfe altagg_*, labels(group_id "Firm-Product FE" group_id_ipc "Firm-Product-Country FE")
esttab altagg_* using tables_Oct2023\altagg.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw L.*)

*-------------------------------------------------------------------------------

* 5. Single product firm

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
keep if HS6_count==1

eststo single_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo single_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo single_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear
keep if HS6_count==1

eststo single_4: reghdfe dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo single_5: reghdfe dlnprice l.dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo single_6: reghdfe dlnprice brw l.dlnprice l.lnrSI, a(firm_id) vce(cluster firm_id)

estfe single_*, labels(firm_id "Firm FE")
esttab single_* using tables_Oct2023\single.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 6. Alternative cluster and FE 

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo cluster_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id year)
eststo cluster_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id year)
eststo cluster_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id year)

eststo FE_1: reghdfe dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo FE_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id year) vce(cluster firm_id)
eststo FE_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id year) vce(cluster firm_id)

estfe cluster_* FE_*, labels(firm_id "Firm FE" year "Year FE")
esttab cluster_* FE_* using tables_Oct2023\altFE.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 7. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo markup_1: reghdfe S12.Markup_DLWTLD brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_2: reghdfe dlnMC_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_3: reghdfe dlnprice_YoY brw S12.Markup_DLWTLD l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_4: reghdfe dlnprice_YoY brw dlnMC_YoY l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo markup_5: reghdfe D.Markup_DLWTLD brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_6: reghdfe dlnMC brw l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_7: reghdfe dlnprice brw D.Markup_DLWTLD l.dlnprice l.lnrSI, a(firm_id) vce(cluster firm_id)
eststo markup_8: reghdfe dlnprice brw dlnMC l.dlnprice l.lnrSI, a(firm_id) vce(cluster firm_id)

estfe markup_*, labels(firm_id "Firm FE")
esttab markup_* using tables_Oct2023\markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 8. Borrowing cost and liquidity change

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
esttab borrow_* liquid_* using tables_Oct2023\liquid.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 9. Borrowing cost and liquidity interaction

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo borrow_int_1: reghdfe dlnprice_YoY brw c.brw#c.IEoL_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo borrow_int_2: reghdfe dlnprice_YoY brw c.brw#c.IEoCL_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo borrow_int_3: reghdfe dlnprice_YoY brw c.brw#c.FNoL_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo borrow_int_4: reghdfe dlnprice_YoY brw c.brw#c.FNoCL_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

eststo liquid_int_1: reghdfe dlnprice_YoY brw c.brw#c.WC_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo liquid_int_2: reghdfe dlnprice_YoY brw c.brw#c.Liquid_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo liquid_int_3: reghdfe dlnprice_YoY brw c.brw#c.Cash_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo liquid_int_4: reghdfe dlnprice_YoY brw c.brw#c.Arec_cic2 l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe borrow_int_* liquid_int_*, labels(firm_id "Firm FE")
esttab borrow_int_* liquid_int_* using tables_Oct2023\liquid_int.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 10. Tests of other channels

cd "D:\Project E"
use samples\cie_credit_brw,clear

eststo material: reghdfe D.TOIPToS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo wage: reghdfe D.CWPoS brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo material_int: reghdfe dlnprice_YoY brw c.brw#c.TOIPToS l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo wage_int: reghdfe dlnprice_YoY brw c.brw#c.CWPoS l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

eststo imp_int: reghdfe dlnprice_YoY brw c.brw#c.imp_int l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo exp_int: reghdfe dlnprice_YoY brw c.brw#c.exp_int l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo trade_int: reghdfe dlnprice_YoY brw c.brw#c.trade_int l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe material wage *_int, labels(firm_id "Firm FE")
esttab material wage *_int using tables_Oct2023\other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw c.brw*)

*-------------------------------------------------------------------------------

* 11. Dynamic regression

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo forward_`i': reghdfe f`i'.dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
}

estfe forward_*, labels(firm_id "Firm FE")
esttab forward_* using tables_Oct2023\dynamic.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 12. Fixed and floating regime

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo fixed_1: reghdfe dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo fixed_3: reghdfe dlnprice_YoY l.dlnprice_YoY l12.lnrSI brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

eststo float_1: reghdfe dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo float_3: reghdfe dlnprice_YoY l.dlnprice_YoY l12.lnrSI brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

estfe fixed_* float_*, labels(firm_id "Firm FE")
esttab fixed_* float_* using tables_Oct2023\regime.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("fixed" "fixed" "fixed" "floating" "floating" "floating")

*-------------------------------------------------------------------------------

* 13. USD price index

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo USD_1: reghdfe dlnprice_USD_YoY brw, a(firm_id) vce(cluster firm_id)
eststo USD_2: reghdfe dlnprice_USD_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo USD_3: reghdfe dlnprice_USD_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

eststo USD_4: reghdfe dlnprice_USD brw, a(firm_id) vce(cluster firm_id)
eststo USD_5: reghdfe dlnprice_USD l.dlnprice brw, a(firm_id) vce(cluster firm_id)
eststo USD_6: reghdfe dlnprice_USD brw l.dlnprice l.lnrSI, a(firm_id) vce(cluster firm_id)

estfe USD_*, labels(firm_id "Firm FE")
esttab USD_* using tables_Oct2023\USD.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("monthly" "monthly" "monthly" "annual" "annual" "annual")

*-------------------------------------------------------------------------------

* 14. Homogenous vs differentiated good

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo Rauch_1: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con, a(firm_id) vce(cluster firm_id)
eststo Rauch_2: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo Rauch_3: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con_r, a(firm_id) vce(cluster firm_id)
eststo Rauch_4: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_con_r l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo Rauch_5: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib, a(firm_id) vce(cluster firm_id)
eststo Rauch_6: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo Rauch_7: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib_r, a(firm_id) vce(cluster firm_id)
eststo Rauch_8: reghdfe dlnprice_USD_YoY brw c.brw#c.Rauch_lib_r l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe Rauch_*, labels(firm_id "Firm FE")
esttab Rauch_* using tables_Oct2023\Rauch.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("Conservative" "Conservative" "Conservative" "Conservative" "Liberal" "Liberal" "Liberal" "Liberal") order(brw c.brw*)

*-------------------------------------------------------------------------------

* 15. Ordinary vs Processing

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo ordinary_1: reghdfe dlnprice_YoY brw if process==0, a(firm_id) vce(cluster firm_id)
eststo ordinary_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if process==0, a(firm_id) vce(cluster firm_id)
eststo process_1: reghdfe dlnprice_YoY brw if process==1, a(firm_id) vce(cluster firm_id)
eststo process_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if process==1, a(firm_id) vce(cluster firm_id)
eststo process_int_1: reghdfe dlnprice_YoY brw c.brw#c.process, a(firm_id) vce(cluster firm_id)
eststo process_int_2: reghdfe dlnprice_YoY brw c.brw#c.process l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe ordinary_* process_* process_int_*, labels(firm_id "Firm FE")
esttab ordinary_* process_* process_int_* using tables_Oct2023\process.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("ordinary" "ordinary" "processing" "processing" "comparison" "comparison")

*-------------------------------------------------------------------------------

* 16. EU and UK shocks

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* add monetary policy shocks
merge m:1 year month using MPS\monthly\eu_shock_monthly,nogen keep(matched master) keepus(target_ea path_ea)
replace target_ea=0 if target_ea==.
replace path_ea=0 if path_ea==.
xtset firm_id time

eststo EU_1: reghdfe dlnprice_YoY target_ea path_ea, a(firm_id) vce(cluster firm_id)
eststo EU_2: reghdfe dlnprice_YoY target_ea path_ea l.dlnprice_YoY, a(firm_id) vce(cluster firm_id)
eststo EU_3: reghdfe dlnprice_YoY target_ea path_ea l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

cd "D:\Project E"
use samples\sample_matched_exp_firm,clear

* add monetary policy shocks
merge m:1 year using MPS\others\shock_ea,nogen keep(matched master) keepus(target_ea path_ea)
replace target_ea=0 if target_ea==.
replace path_ea=0 if path_ea==.
xtset firm_id year

eststo EU_4: reghdfe dlnprice target_ea path_ea, a(firm_id) vce(cluster firm_id)
eststo EU_5: reghdfe dlnprice l.dlnprice target_ea path_ea, a(firm_id) vce(cluster firm_id)
eststo EU_6: reghdfe dlnprice target_ea path_ea l.dlnprice l.lnrSI, a(firm_id) vce(cluster firm_id)

estfe EU_*, labels(firm_id "Firm FE")
esttab EU_* using tables_Oct2023\EU.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_* path_*)