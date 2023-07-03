* This do-file is to run regressions for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* A. Regressions for firm-level sample

*-------------------------------------------------------------------------------

* 1. Regressions of price change on monetary policy shocks

*-------------------------------------------------------------------------------

* 1.1 Baseline

cd "D:\Project E"
use sample_matched_exp,clear

* Baseline
eststo firm_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag: reghdfe dlnprice_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Quantity
eststo firm_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_lag: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw0 firm_brw firm_brw_lag firm_brw_quant firm_brw_quant_lag using "D:\Project E\tables\table_brw.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_lag)

binscatter dlnprice_tr brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("US MPS and China's Export Price") savegraph("D:\Project E\figures\US_shock.png") replace

* USD price
eststo firm_brw_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag_USD: reghdfe dlnprice_USD_tr dlnRER brw_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

*-------------------------------------------------------------------------------

* 1.2 Alternative shocks

cd "D:\Project E"
use sample_matched_exp,clear

* Large scale asset purchase and forward guidance
eststo firm_lsap: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_lsap_lag: reghdfe dlnprice_tr dlnRER lsap_lag fwgd_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed: reghdfe dlnprice_tr dlnRER lsap fwgd dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* EU shock
eststo firm_eus0: reghdfe dlnprice_tr target_ea path_ea dlnrgdp, absorb(group_id) vce(cluster group_id year)
eststo firm_eus: reghdfe dlnprice_tr target_ea path_ea dlnRER dlnrgdp, absorb(group_id) vce(cluster group_id year)
eststo firm_eus_lag: reghdfe dlnprice_tr target_ea_lag path_ea_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_fixed: reghdfe dlnprice_tr dlnRER target_ea path_ea dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_eus0 firm_eus firm_eus_lag firm_eus_fixed using "D:\Project E\tables\table_eus.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_ea path_ea target_ea_lag path_ea_lag)

binscatter dlnprice_tr target_ea, xtitle(EU monetary policy shock) ytitle(China's export price change) title(EU MPS and China's Export Price) savegraph("D:\Project E\figures\EU_shock.png") replace

*-------------------------------------------------------------------------------

* 1.3 Firm-level heterogeneity

cd "D:\Project E"
use sample_matched_exp,clear

* Firm size
gen brw_rSI=brw*ln(rSI)
eststo firm_brw_rSI: reghdfe dlnprice_tr dlnRER brw brw_rSI dlnrgdp, a(group_id) vce(cluster group_id year)

* Two-way traders
gen brw_twoway=brw*twoway_trade
eststo firm_brw_twoway: reghdfe dlnprice_tr brw brw_twoway dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Import intensity
gen brw_imp = imp_int*brw
bys year: egen imp_int_q4=pctile(imp_int), p(75)
gen imp_major=1 if imp_int>=imp_int_q4
replace imp_major=0 if imp_major==.
gen brw_imp_major = imp_major*brw

* Interest burden ratio
gen brw_IEoS = imp_int*IEoS
bys year: egen IEoS_q4=pctile(IEoS), p(75)
gen IEoS_major=1 if IEoS>=IEoS_q4
replace IEoS_major=0 if IEoS_major==.
gen brw_IEoS_major = IEoS_major*brw

eststo firm_brw_imp_int: reghdfe dlnprice_tr brw brw_imp dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_imp_major: reghdfe dlnprice_tr brw brw_imp_major dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

eststo firm_brw_IEoS: reghdfe dlnprice_tr brw brw_IEoS dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_IEoS_major: reghdfe dlnprice_tr brw brw_IEoS_major dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_rSI firm_brw_twoway firm_brw_imp_major firm_brw_IEoS_major using "D:\Project E\tables\table_brw_twoway.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_* dlnRER dlnrgdp)

* US and EU exposure
gen brw_exposure_US=brw*exposure_US
eststo firm_brw_expoUS: reghdfe dlnprice_tr brw brw_exposure_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen brw_exposure_EU=brw*exposure_EU
eststo firm_brw_expoEU: reghdfe dlnprice_tr brw brw_exposure_EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen eus_exposure_EU=target_ea*exposure_EU

*-------------------------------------------------------------------------------

* 1.4 Subsamples

cd "D:\Project E"
use sample_matched_exp,clear

* US vs ROW
eststo firm_brw_US: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_nonUS: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim!="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_EU: reghdfe dlnprice_tr brw dlnRER dlnrgdp if EU==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_OECD: reghdfe dlnprice_tr brw dlnRER dlnrgdp if OECD==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_EME: reghdfe dlnprice_tr brw dlnRER dlnrgdp if EME==1, a(group_id) vce(cluster group_id year)

esttab firm_brw_US firm_brw_nonUS firm_brw_EU firm_brw_OECD firm_brw_EME using "D:\Project E\tables\table_brw_country_sub.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw dlnRER dlnrgdp)

* 1.5 Credit constraints
cd "D:\Project E"
use sample_matched_exp,clear

* Construct interaction terms
local varlist "FPC_US ExtFin_US Tang_US Invent_US TrCredit_US FPC_cic2 ExtFin_cic2 Tang_cic2 Invent_cic2 Arec Arec_cic2"
foreach var of local varlist {
	gen brw_`var' = `var'*brw
}

* Credit constraint from US measures
eststo firm_brw_FPC_US: reghdfe dlnprice_tr brw_FPC_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_ExtFin_US: reghdfe dlnprice_tr brw_ExtFin_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Tang_US: reghdfe dlnprice_tr brw_Tang_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Invent_US: reghdfe dlnprice_tr brw_Invent_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_TrCredit_US: reghdfe dlnprice_tr brw_TrCredit_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw firm_brw_FPC_US firm_brw_ExtFin_US firm_brw_Tang_US firm_brw_Invent_US firm_brw_TrCredit_US using "D:\Project E\tables\table_brw_credit.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_*)

* Credit constraint from CN measures
eststo firm_brw_FPC_cic2: reghdfe dlnprice_tr brw_FPC_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_ExtFin_cic2: reghdfe dlnprice_tr brw_ExtFin_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Tang_cic2: reghdfe dlnprice_tr brw_Tang_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Invent_cic2: reghdfe dlnprice_tr brw_Invent_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Arec_cic2: reghdfe dlnprice_tr brw_Arec_cic2 brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_FPC_cic2 firm_brw_ExtFin_cic2 firm_brw_Tang_cic2 firm_brw_Invent_cic2 firm_brw_Arec firm_brw_Arec_cic2, star(* .10 ** .05 *** .01) label compress se r2 order(brw brw_*)

*-------------------------------------------------------------------------------

* 2. Regression of markup and marginal cost on monetary policy shocks

cd "D:\Project E"
use sample_matched_exp,clear

gen dMarkup=Markup_DLWTLD-Markup_lag
* Marginal cost
eststo firm_brw_MC0: reghdfe dlnMC_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_MC: reghdfe dlnprice_tr brw dlnMC_tr dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup: reghdfe dlnprice_tr brw dMarkup dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup_lag: reghdfe dlnprice_tr dMarkup brw Markup_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_MC0 firm_brw_MC firm_brw_Markup firm_brw_Markup_lag using "D:\Project E\tables\table_brw_markup.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw)

*-------------------------------------------------------------------------------

* 3. Regression of firm-level variables on monetary policy shocks

cd "D:\Project E"
use cie_credit_brw,clear

* Account receivable to sales income
eststo Arec_brw: reghdfe dArec_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)

* Financial expense and interest expense to total liability
eststo FNoL_brw: reghdfe dFNoL_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)
eststo IEoL_brw: reghdfe dIEoL_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)

* Wage payment per worker
eststo CWPoP_brw: reghdfe dlnCWPoP_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)

esttab Arec_brw FNoL_brw IEoL_brw CWPoP_brw using "D:\Project E\tables\table_brw_interest.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw)

* Loans to GDP
cd "D:\Project E"
use ".\Almanac\bank_credit",clear
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)

binscatter Total_lr brw, xtitle(US monetary policy shock) ytitle(Total loans to GDP ratio) title(US MPS and China's Total Loans) savegraph("D:\Project E\figures\Total_loans.png") replace
binscatter ST_lr brw, xtitle(US monetary policy shock) ytitle(Short-term loans to GDP ratio) title(US MPS and China's Short-term Loans) savegraph("D:\Project E\figures\ST_loans.png") replace
binscatter IST_lr brw, xtitle(US monetary policy shock) ytitle(Short-term Loans to Industrial Sector to GDP ratio) title(US MPS and China's Short-term Loans to Industrial Sector) savegraph("D:\Project E\figures\IST_loans.png") replace
binscatter LT_lr brw, xtitle(US monetary policy shock) ytitle(Long-term loans to GDP ratio) title(US MPS and China's Long-term Loans) savegraph("D:\Project E\figures\LT_loans.png") replace