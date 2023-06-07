* This do-file is to run regressions for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* A. Regressions for firm-level sample

*-------------------------------------------------------------------------------

* 1. Regressions of price change on monetary policy shocks
cd "D:\Project E"
use sample_matched_exp,clear

* 1.1 Baseline

* Baseline
eststo firm_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag: reghdfe dlnprice_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_brw0 firm_brw firm_brw_lag firm_brw_fixed using "D:\Project E\tables\table_brw.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_lag)

binscatter dlnprice_tr brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("US MPS and China's Export Price") savegraph("D:\Project E\figures\US_shock.png") replace

* USD price
eststo firm_brw_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag_USD: reghdfe dlnprice_USD_tr dlnRER brw_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed_USD: reghdfe dlnprice_USD_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* 1.2 Firm-level control

* Firm size
gen brw_rSI=brw*ln(rSI)
gen brw_rCWP=brw*ln(rCWP)
eststo firm_brw_rSI: reghdfe dlnprice_tr dlnRER brw brw_rSI dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_rCWP: reghdfe dlnprice_tr dlnRER brw brw_rCWP dlnrgdp, a(group_id) vce(cluster group_id year)

* Import intensity
gen brw_imp = imp_int*brw
gen imp_major=1 if imp_int>=0.3
replace imp_major=0 if imp_major==.
gen brw_imp_major = imp_major*brw

eststo firm_brw_imp: reghdfe dlnprice_tr brw brw_imp dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_imp_major: reghdfe dlnprice_tr brw brw_imp_major dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* 1.2 Subsamples

* US vs ROW
eststo firm_brw_US: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_ROW: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim!="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_EU: reghdfe dlnprice_tr brw dlnRER dlnrgdp if EU==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_OECD: reghdfe dlnprice_tr brw dlnRER dlnrgdp if OECD==1, a(group_id) vce(cluster group_id year)

esttab firm_brw_US firm_brw_ROW firm_brw_EU firm_brw_OECD, star(* .10 ** .05 *** .01) label compress r2

* Two-way traders
eststo firm_brw_twoway: reghdfe dlnprice_tr dlnRER brw dlnrgdp if twoway_trade==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_oneway: reghdfe dlnprice_tr dlnRER brw dlnrgdp if twoway_trade==0, a(group_id) vce(cluster group_id year)

* 1.3 Alternative shocks

* Large scale asset purchase and forward guidance
eststo firm_lsap: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_lsap_lag: reghdfe dlnprice_tr dlnRER lsap_lag fwgd_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed: reghdfe dlnprice_tr dlnRER lsap fwgd dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* EU shock
eststo firm_eus0: reghdfe dlnprice_tr target_ea path_ea dlnrgdp, absorb(group_id) vce(cluster group_id year)
eststo firm_eus: reghdfe dlnprice_tr target_ea path_ea dlnRER dlnrgdp, absorb(group_id) vce(cluster group_id year)
eststo firm_eus_lag: reghdfe dlnprice_tr target_ea_lag path_ea_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_fixed: reghdfe dlnprice_tr dlnRER target_ea path_ea dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_eus0 firm_eus firm_eus_lag firm_eus_fixed, star(* .10 ** .05 *** .01) label compress r2

binscatter dlnprice_tr target_ea, xtitle(EU monetary policy shock) ytitle(China's export price change) title(EU MPS and China's Export Price) savegraph("D:\Project E\figures\EU_shock.png") replace

* US and EU exposure
gen brw_exposure_US=brw*exposure_US
eststo firm_brw_expoUS: reghdfe dlnprice_tr brw brw_exposure_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen brw_exposure_EU=brw*exposure_EU
eststo firm_brw_expoEU: reghdfe dlnprice_tr brw brw_exposure_EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen eus_exposure_EU=target_ea*exposure_EU

* 1.4 Credit constraints
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

* 2. Regression of other firm changes on monetary policy shocks
cd "D:\Project E"
use sample_matched_exp,clear

* Quantity
eststo firm_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_lag: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_fixed: reghdfe dlnquant_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* Marginal cost
eststo firm_brw_MC: reghdfe dlnMC_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_MC_lag: reghdfe dlnMC_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_MC_fixed: reghdfe dlnMC_tr dlnRER brw dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_brw_quant firm_brw_quant_lag firm_brw_quant_fixed firm_brw_MC firm_brw_MC_lag firm_brw_MC_fixed using "D:\Project E\tables\table_brw_quant&mc.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_lag)

*-------------------------------------------------------------------------------

* 3. Regression of trade credit on monetary policy shocks

cd "D:\Project E"
use "D:\Project C\CIE\cie_credit_v2",clear
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)
sort FRDM year
drop if Arec<0 | FN<0 | IE<0
by FRDM: gen dArec=Arec-Arec[_n-1] if year==year[_n-1]+1
by FRDM: gen dFNr=FNr-FNr[_n-1] if year==year[_n-1]+1
by FRDM: gen dlnFN=ln(FN)-ln(FN[_n-1]) if year==year[_n-1]+1
by FRDM: gen dIEr=IEr-IEr[_n-1] if year==year[_n-1]+1
by FRDM: gen dlnIE=ln(IE)-ln(IE[_n-1]) if year==year[_n-1]+1
winsor2 dArec dFNr dlnFN dIEr dlnIE, trim
save cie_credit_brw,replace

* Account receivable to sales income
eststo Arec_brw: reghdfe dArec_tr brw, a(FRDM) vce(cluster FRDM year)
eststo Arec_brw_lag: reghdfe dArec brw_lag, a(FRDM) vce(cluster FRDM year)

* Financial expense and interest expense to total liability
eststo FNr_brw: reghdfe dFNr_tr brw, a(FRDM) vce(cluster FRDM year)
eststo FN_brw: reghdfe dlnFN_tr brw, a(FRDM) vce(cluster FRDM year)
eststo IEr_brw: reghdfe dIEr_tr brw, a(FRDM) vce(cluster FRDM year)
eststo IE_brw: reghdfe dlnIE_tr brw, a(FRDM) vce(cluster FRDM year)

* Loans to GDP
cd "D:\Project E"
use ".\Almanac\bank_credit",clear
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)

binscatter Total_lr brw, xtitle(US monetary policy shock) ytitle(Total loans to GDP ratio) title(US MPS and China's Total Loans) savegraph("D:\Project E\figures\Total_loans.png") replace
binscatter ST_lr brw, xtitle(US monetary policy shock) ytitle(Short-term loans to GDP ratio) title(US MPS and China's Short-term Loans) savegraph("D:\Project E\figures\ST_loans.png") replace
binscatter IST_lr brw, xtitle(US monetary policy shock) ytitle(Short-term Loans to Industrial Sector to GDP ratio) title(US MPS and China's Short-term Loans to Industrial Sector) savegraph("D:\Project E\figures\IST_loans.png") replace
binscatter LT_lr brw, xtitle(US monetary policy shock) ytitle(Long-term loans to GDP ratio) title(US MPS and China's Long-term Loans) savegraph("D:\Project E\figures\LT_loans.png") replace