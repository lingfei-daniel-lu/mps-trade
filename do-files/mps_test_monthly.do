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

eststo month_brw_HS6_1: reghdfe dlnprice_hit_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_2: reghdfe dlnprice_hit_YoY l.dlnprice_hit_YoY brw, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_3: reghdfe dlnprice_hit_YoY brw l.dlnprice_hit_YoY l12.lnrSI, a(group_id) vce(cluster group_id)
eststo month_brw_HS6_4: reghdfe dlnprice_hit_YoY brw l.dlnprice_hit_YoY l12.lnrSI, a(FRDM HS6) vce(cluster FRDM HS6)

estfe month_brw_HS6_*, labels(group_id "Firm-Product FE" FRDM "Firm FE" HS6 "Product FE")
esttab month_brw_HS6_* using tables\month_HS6.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 3. Long-term effect

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

forv i=1/12{
eststo month_brw_f_`i': reghdfe f`i'.dlnprice_YoY brw l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
}

estfe month_brw_f_*, labels(firm_id "Firm FE")
esttab month_brw_f_* using tables\month_long.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 4. Alternative monetary policy shock measures

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_NS_1: reghdfe dlnprice_YoY NS_shock, a(firm_id) vce(cluster firm_id)
eststo month_NS_2: reghdfe dlnprice_YoY NS_shock l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_FFR_1: reghdfe dlnprice_YoY ffr_shock, a(firm_id) vce(cluster firm_id)
eststo month_FFR_2: reghdfe dlnprice_YoY ffr_shock l.dlnprice_YoY l12.lnrSI , a(firm_id) vce(cluster firm_id)

estfe month_NS_* month_FFR_*, labels(firm_id "Firm FE")
esttab month_NS_* month_FFR_* using tables\month_alt_measure.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 5. Decomposition into markup and marginal cost

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_Markup_brw: reghdfe S12.Markup brw l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_MC_brw: reghdfe dlnMC_YoY brw l12.lnrSI, a(firm_id) vce(cluster firm_id)

eststo month_brw_Markup: reghdfe dlnprice_YoY brw S12.Markup l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)
eststo month_brw_MC: reghdfe dlnprice_YoY brw dlnMC_YoY l.dlnprice_YoY l12.lnrSI, a(firm_id) vce(cluster firm_id)

estfe month_*_brw month_brw_Markup month_brw_MC, labels(firm_id "Firm FE")
esttab month_*_brw month_brw_Markup month_brw_MC using tables\month_markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw S12.* dln*)

*-------------------------------------------------------------------------------

* 6. Interaction with liquidity

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

* 7. Interaction with industry-level credit constraints

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

* 8. Ownership type

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

* 9. Ordinary vs Processing

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

* 10. Time periods

cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

eststo month_brw_fixed_1: reghdfe dlnprice_YoY brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo month_brw_fixed_2: reghdfe dlnprice_YoY l.dlnprice_YoY l12.lnrSI brw if time<monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo month_brw_float_1: reghdfe dlnprice_YoY brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)
eststo month_brw_float_2: reghdfe dlnprice_YoY l.dlnprice_YoY l12.lnrSI brw if time>=monthly("2005m7","YM"), a(firm_id) vce(cluster firm_id)

estfe month_brw_fixed_* month_brw_float_*, labels(firm_id "Firm FE")
esttab month_brw_fixed_* month_brw_float_* using tables\month_regime.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress mtitle("fixed" "fixed" "float" "float")