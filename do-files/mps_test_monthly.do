* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* E. Regressions for monthly data (2000-2006)

set processor 8
*-------------------------------------------------------------------------------

* 1. Baseline

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_firm_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_4: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id year)

estfe month_brw_firm_*, labels(firm_id "Firm FE")
esttab month_brw_firm_* using tables\month_baseline.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 2. Firm-product price index

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear

eststo month_brw_HS6_1: reghdfe dlnprice_h_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_2: reghdfe dlnprice_h_YoY l.dlnprice_h_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_3: reghdfe dlnprice_h_YoY brw l.dlnprice_h_YoY l12.lnrSI, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_4: reghdfe dlnprice_h_YoY brw l.dlnprice_h_YoY l12.lnrSI, a(group_id) vce(cluster group_id year)

estfe month_brw_HS6_*, labels(group_id "Firm-Product FE")
esttab month_brw_HS6_* using tables\month_HS6.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 3. USD price index

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_firm_USD_1: reghdfe dlnprice_USD_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_USD_2: reghdfe dlnprice_USD_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_USD_3: reghdfe dlnprice_USD_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_brw_firm_USD_4: reghdfe dlnprice_USD_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id year)

estfe month_brw_firm_USD_*, labels(firm_id "Firm FE")
esttab month_brw_firm_USD_* using tables\month_USD.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 4. Long-term effect

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo month_brw_f_`i': reghdfe f`i'.dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
}

estfe month_brw_f_*, labels(firm_id "Firm FE")
esttab month_brw_f_* using tables\month_forward.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 5. Alternative monetary policy shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

merge m:1 year month using MPS\monthly\target_path_ns,nogen keep(matched master) keepus(target path)
xtset firm_id time

eststo month_NS_1: reghdfe dlnprice_YoY NS_shock, a(firm_id) vce(cluster firm_id)
eststo month_NS_2: reghdfe dlnprice_YoY NS_shock l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_Acosta_1: reghdfe dlnprice_YoY target path, a(firm_id) vce(cluster firm_id)
eststo month_Acosta_2: reghdfe dlnprice_YoY target path l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)
eststo month_FFR_1: reghdfe dlnprice_YoY ffr_shock, a(firm_id) vce(cluster firm_id)
eststo month_FFR_2: reghdfe dlnprice_YoY ffr_shock l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)

estfe month_NS_* month_Acosta_* month_FFR_*, labels(firm_id "Firm FE")
esttab month_NS_* month_Acosta_* month_FFR_* using tables\month_alt_measure.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*_shock target path)

*-------------------------------------------------------------------------------

* 6. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_Markup_brw: reghdfe S12.Markup_DLWTLD brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_MC_brw: reghdfe dlnMC_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_Markup_high_brw: reghdfe S12.Markup_DLWTLD brw c.brw#c.Markup_High l12.lnrSI, a(firm_id) vce(cluster firm_id)

eststo month_brw_Markup: reghdfe dlnprice_YoY brw S12.Markup_DLWTLD l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_brw_MC: reghdfe dlnprice_YoY brw dlnMC_YoY l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_brw_Markup_high: reghdfe dlnprice_YoY brw c.brw#c.Markup_High l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe month_*_brw month_brw_Markup month_brw_MC month_brw_Markup_high, labels(firm_id "Firm FE")
esttab month_*_brw  month_brw_Markup month_brw_MC month_brw_Markup_high using tables\month_markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

*-------------------------------------------------------------------------------

* 7. Interaction with liquidity

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_IEoL: reghdfe dlnprice_YoY brw c.brw#c.IEoL_cic2, a(firm_id) vce(cluster firm_id)
eststo month_brw_IEoCL: reghdfe dlnprice_YoY brw c.brw#c.IEoCL_cic2, a(firm_id) vce(cluster firm_id)
eststo month_brw_FNoL: reghdfe dlnprice_YoY brw c.brw#c.FNoL_cic2, a(firm_id) vce(cluster firm_id)
eststo month_brw_FNoCL: reghdfe dlnprice_YoY brw c.brw#c.FNoCL_cic2, a(firm_id) vce(cluster firm_id)

eststo month_brw_WC: reghdfe dlnprice_YoY brw c.brw#c.WC_cic2, a(firm_id) vce(cluster firm_id)
eststo month_brw_Liquid: reghdfe dlnprice_YoY brw c.brw#c.Liquid_cic2, a(firm_id) vce(cluster firm_id)
eststo month_brw_Cash: reghdfe dlnprice_YoY brw c.brw#c.Cash_cic2, a(firm_id) vce(cluster firm_id)
eststo month_brw_Arec: reghdfe dlnprice_YoY brw c.brw#c.Arec_cic2, a(firm_id) vce(cluster firm_id)

estfe month_brw_*o*L month_brw_WC month_brw_Liquid month_brw_Cash month_brw_Arec, labels(firm_id "Firm FE")
esttab month_brw_*o*L month_brw_WC month_brw_Liquid month_brw_Cash month_brw_Arec using tables\month_liquid.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 8. Interaction with industry-level credit constraints

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_FPC_US: reghdfe dlnprice_YoY brw c.brw#c.FPC_US, a(firm_id) vce(cluster firm_id)
eststo month_brw_ExtFin_US: reghdfe dlnprice_YoY brw c.brw#c.ExtFin_US, a(firm_id) vce(cluster firm_id)
eststo month_brw_Tang_US: reghdfe dlnprice_YoY brw c.brw#c.Tang_US, a(firm_id) vce(cluster firm_id)
eststo month_brw_Invent_US: reghdfe dlnprice_YoY brw c.brw#c.Invent_US, a(firm_id) vce(cluster firm_id)
eststo month_brw_TrCredit_US: reghdfe dlnprice_YoY brw c.brw#c.TrCredit_US, a(firm_id) vce(cluster firm_id)

estfe month_brw_*_US, labels(firm_id "Firm FE")
esttab month_brw_*_US using tables\month_credit.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 9. Ownership type

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_SOE_1: reghdfe dlnprice_YoY brw if ownership=="SOE", a(firm_id) vce(cluster firm_id)
eststo month_brw_SOE_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if ownership=="SOE", a(firm_id) vce(cluster firm_id)
eststo month_brw_MNE_1: reghdfe dlnprice_YoY brw if ownership=="MNE", a(firm_id) vce(cluster firm_id)
eststo month_brw_MNE_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if ownership=="MNE", a(firm_id) vce(cluster firm_id)
eststo month_brw_DPE_1: reghdfe dlnprice_YoY brw if ownership=="DPE", a(firm_id) vce(cluster firm_id)
eststo month_brw_DPE_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if ownership=="DPE", a(firm_id) vce(cluster firm_id)
eststo month_brw_JV_1: reghdfe dlnprice_YoY brw if ownership=="JV", a(firm_id) vce(cluster firm_id)
eststo month_brw_JV_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if ownership=="JV", a(firm_id) vce(cluster firm_id)

estfe month_brw_SOE_* month_brw_MNE_* month_brw_DPE_* month_brw_JV_*, labels(firm_id "Firm FE")
esttab month_brw_SOE_* month_brw_MNE_* month_brw_DPE_* month_brw_JV_* using tables\month_ownership.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("SOE" "SOE" "MNE" "MNE" "DPE" "DPE" "JV" "JV")

*-------------------------------------------------------------------------------

* 10. Ordinary vs Processing

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_ordinary_1: reghdfe dlnprice_YoY brw if process==0, a(firm_id) vce(cluster firm_id)
eststo month_brw_ordinary_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if process==0, a(firm_id) vce(cluster firm_id)
eststo month_brw_process_1: reghdfe dlnprice_YoY brw if process==1, a(firm_id) vce(cluster firm_id)
eststo month_brw_process_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if process==1, a(firm_id) vce(cluster firm_id)
eststo month_brw_assembly_1: reghdfe dlnprice_YoY brw if assembly==1, a(firm_id) vce(cluster firm_id)
eststo month_brw_assembly_2: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI if assembly==1, a(firm_id) vce(cluster firm_id)

estfe month_brw_ordinary_* month_brw_process_* month_brw_assembly_*, labels(firm_id "Firm FE")
esttab month_brw_ordinary_* month_brw_process_* month_brw_assembly_* using tables\month_process.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("ordinary" "ordinary" "processing" "processing" "assembly" "assembly")

*-------------------------------------------------------------------------------

* 11. Time periods

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_fixed_1: reghdfe dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo month_brw_fixed_2: reghdfe dlnprice_YoY l.dlnprice_YoY l12.lnrSI brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo month_brw_float_1: reghdfe dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo month_brw_float_2: reghdfe dlnprice_YoY l.dlnprice_YoY l12.lnrSI brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

estfe month_brw_fixed_* month_brw_float_*, labels(firm_id "Firm FE")
esttab month_brw_fixed_* month_brw_float_* using tables\month_regime.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("fixed" "fixed" "float" "float")

*-------------------------------------------------------------------------------

* 12. Single product firm

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear
keep if HS6_count==1

eststo month_brw_single_1: reghdfe dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_single_2: reghdfe dlnprice_YoY l.dlnprice_YoY brw, a(firm_id) vce(cluster firm_id)
eststo month_brw_single_3: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_brw_single_4: reghdfe dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id year)

estfe month_brw_single_*, labels(firm_id "Firm FE")
esttab month_brw_single_* using tables\month_single.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 13. Interaction with trade intensity

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_imp_int: reghdfe dlnprice_YoY brw c.brw#c.imp_int, a(firm_id) vce(cluster firm_id)
eststo month_brw_exp_int: reghdfe dlnprice_YoY brw c.brw#c.exp_int, a(firm_id) vce(cluster firm_id)
eststo month_brw_trade_int: reghdfe dlnprice_YoY brw c.brw#c.trade_int, a(firm_id) vce(cluster firm_id)

estfe month_brw_*_int, labels(firm_id "Firm FE")
esttab month_brw_*_int using tables\month_trade_int.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 14. Fim-product level quantity

cd "D:\Project E"
use samples\sample_monthly_exp_firm_HS6,clear

eststo month_brw_quant_1: reghdfe dlnquant_h_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_quant_2: reghdfe dlnquant_h_YoY l.dlnquant_h_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_quant_3: reghdfe dlnquant_h_YoY brw l.dlnquant_h_YoY l12.lnrSI, a(group_id) vce(cluster group_id)
eststo month_brw_quant_4: reghdfe dlnquant_h_YoY brw l.dlnquant_h_YoY l12.lnrSI, a(group_id) vce(cluster group_id year)

estfe month_brw_quant_*, labels(firm_id "Firm FE")
esttab month_brw_quant_* using tables\month_quant.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 15. EU, UK, Japan shock

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* add monetary policy shocks
merge m:1 year month using MPS\monthly\eu_shock_monthly,nogen keep(matched master) keepus(target_ea path_ea)
merge m:1 year month using MPS\monthly\uk_shock_monthly,nogen keep(matched master) keepus(shock_uk)
merge m:1 year month using MPS\monthly\japan_shock_monthly,nogen keep(matched master) keepus(target_japan path_japan)
replace target_ea=0 if target_ea==.
replace path_ea=0 if path_ea==.
replace shock_uk=0 if shock_uk==.
replace target_japan=0 if target_japan==.
replace path_japan=0 if path_japan==.
xtset firm_id time

eststo month_EU_1: reghdfe dlnprice_YoY target_ea path_ea, a(firm_id) vce(cluster firm_id)
eststo month_EU_2: reghdfe dlnprice_YoY target_ea path_ea l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_UK_1: reghdfe dlnprice_YoY shock_uk, a(firm_id) vce(cluster firm_id)
eststo month_UK_2: reghdfe dlnprice_YoY shock_uk l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)
eststo month_Japan_1: reghdfe dlnprice_YoY target_japan path_japan, a(firm_id) vce(cluster firm_id)
eststo month_Japan_2: reghdfe dlnprice_YoY target_japan path_japan l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)

estfe month_EU_* month_UK_* month_Japan_*, labels(firm_id "Firm FE")
esttab month_EU_* month_UK_* month_Japan_* using tables\month_EUshock.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_* path_* shock_*)

*-------------------------------------------------------------------------------

* 16. Info shock

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

* add monetary policy shocks
merge m:1 year month using MPS\monthly\us_infoshock_monthly,nogen keep(matched master) keepus(mp_median cbi_median)
merge m:1 year month using MPS\monthly\eu_infoshock_monthly,nogen keep(matched master) keepus(mp_median_mpd cbi_median_mpd)
replace mp_median=0 if mp_median==.
replace cbi_median=0 if cbi_median==.
replace mp_median_mpd=0 if mp_median_mpd==.
replace cbi_median_mpd=0 if cbi_median_mpd==.
xtset firm_id time

eststo month_USinfo_1: reghdfe dlnprice_YoY mp_median cbi_median, a(firm_id) vce(cluster firm_id)
eststo month_USinfo_2: reghdfe dlnprice_YoY mp_median cbi_median l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)
eststo month_EUinfo_1: reghdfe dlnprice_YoY mp_median_mpd cbi_median_mpd, a(firm_id) vce(cluster firm_id)
eststo month_EUinfo_2: reghdfe dlnprice_YoY mp_median_mpd cbi_median_mpd l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe month_USinfo_* month_EUinfo_*, labels(firm_id "Firm FE")
esttab month_USinfo_* month_EUinfo_* using tables\month_infoshock.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(mp_median cbi_median mp_median_mpd cbi_median_mpd)