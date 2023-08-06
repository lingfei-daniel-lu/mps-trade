* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* A. Regressions for firm-level sample (2000-2007)

*-------------------------------------------------------------------------------

* 1. Baseline

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Price
eststo firm_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag: reghdfe dlnprice_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Quantity
eststo firm_brw0_quant: reghdfe dlnquant_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_lag: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw0 firm_brw firm_brw_lag firm_brw_quant0 firm_brw_quant firm_brw_quant_lag using tables\table_brw.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_lag)

binscatter dlnprice_tr brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("US MPS and China's Export Price") savegraph("D:\Project E\figures\US_shock.png") replace

* USD price
eststo firm_brw0_USD: reghdfe dlnprice_USD_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_USD: reghdfe dlnprice_USD_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag_USD: reghdfe dlnprice_USD_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

*-------------------------------------------------------------------------------

* 2. Alternative shocks

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Large scale asset purchase and forward guidance
eststo firm_lsap: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_lsap_lag: reghdfe dlnprice_tr dlnRER lsap_lag fwgd_lag dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_fixed: reghdfe dlnprice_tr dlnRER lsap fwgd dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

* EU shock
eststo firm_eus0: reghdfe dlnprice_tr target_ea path_ea dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus: reghdfe dlnprice_tr target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_lag: reghdfe dlnprice_tr target_ea_lag path_ea_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_fixed: reghdfe dlnprice_tr dlnRER target_ea path_ea dlnrgdp if year<=2005, a(group_id) vce(cluster group_id year)

esttab firm_eus0 firm_eus firm_eus_lag firm_eus_fixed using "D:\Project E\tables\table_eus.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_ea path_ea target_ea_lag path_ea_lag)

binscatter dlnprice_tr target_ea, xtitle(EU monetary policy shock) ytitle(China's export price change) title(EU MPS and China's Export Price) savegraph("D:\Project E\figures\EU_shock.png") replace

*-------------------------------------------------------------------------------

* 3. Firm-level heterogeneity

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Firm size: US shock
gen brw_rSI=brw*ln(rSI)
eststo firm_brw_rSI: reghdfe dlnprice_tr dlnRER brw brw_rSI dlnrgdp, a(group_id) vce(cluster group_id year)

* Two-way traders: US shock
gen brw_twoway=brw*twoway_trade
eststo firm_brw_twoway: reghdfe dlnprice_tr brw brw_twoway dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Import intensity: US shock
gen brw_imp = imp_int*brw
bys year: egen imp_int_q4=pctile(imp_int), p(75)
gen imp_q4d=1 if imp_int>=imp_int_q4
replace imp_q4d=0 if imp_q4d==.
gen brw_imp_q4d = imp_q4d*brw
eststo firm_brw_imp_int: reghdfe dlnprice_tr brw brw_imp dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_imp_q4d: reghdfe dlnprice_tr brw brw_imp_q4d dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Interest burden ratio: US shock
gen brw_IEoS = imp_int*IEoS
bys year: egen IEoS_q4=pctile(IEoS), p(75)
gen IEoS_q4d=1 if IEoS>=IEoS_q4
replace IEoS_q4d=0 if IEoS_q4d==.
gen brw_IEoS_q4d = IEoS_q4d*brw
eststo firm_brw_IEoS: reghdfe dlnprice_tr brw brw_IEoS dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_IEoS_q4d: reghdfe dlnprice_tr brw brw_IEoS_q4d dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Ownership: US shock
gen SOE=1 if ownership=="SOE"
replace SOE=0 if SOE==.
gen MNE=1 if ownership=="MNE"
replace MNE=0 if MNE==.
gen brw_SOE=brw*SOE
gen brw_MNE=brw*MNE
eststo firm_brw_SOE: reghdfe dlnprice_tr brw brw_SOE dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_MNE: reghdfe dlnprice_tr brw brw_MNE dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_rSI firm_brw_twoway firm_brw_imp_q4d firm_brw_IEoS_q4d using "D:\Project E\tables\table_brw_hetero.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_* dlnRER dlnrgdp)

* Firm size: EU shock
gen target_ea_rSI=target_ea*ln(rSI)
gen path_ea_rSI=path_ea*ln(rSI)
eststo firm_eus_rSI: reghdfe dlnprice_tr dlnRER target_ea target_ea_rSI path_ea path_ea_rSI dlnrgdp, a(group_id) vce(cluster group_id year)

* Two-way traders: EU shock
gen target_ea_twoway=target_ea*twoway_trade
gen path_ea_twoway=path_ea*twoway_trade
eststo firm_eus_twoway: reghdfe dlnprice_tr target_ea target_ea_twoway path_ea path_ea_twoway dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* US and EU exposure
gen brw_exposure_US=brw*exposure_US
eststo firm_brw_expoUS: reghdfe dlnprice_tr brw brw_exposure_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen brw_exposure_EU=brw*exposure_EU
eststo firm_brw_expoEU: reghdfe dlnprice_tr brw brw_exposure_EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
gen eus_exposure_EU=target_ea*exposure_EU

*-------------------------------------------------------------------------------

* 4. Subsamples

cd "D:\Project E"
use samples\sample_matched_exp,clear

* US vs ROW
eststo firm_brw_US: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_nonUS: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim!="美国", a(group_id) vce(cluster group_id year)
eststo firm_brw_EU: reghdfe dlnprice_tr brw dlnRER dlnrgdp if EU==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_OECD: reghdfe dlnprice_tr brw dlnRER dlnrgdp if OECD==1, a(group_id) vce(cluster group_id year)
eststo firm_brw_EME: reghdfe dlnprice_tr brw dlnRER dlnrgdp if EME==1, a(group_id) vce(cluster group_id year)

esttab firm_brw_US firm_brw_nonUS firm_brw_EU firm_brw_OECD firm_brw_EME using "D:\Project E\tables\table_brw_country_sub.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw dlnRER dlnrgdp)

* Other trading partners
eststo firm_brw_HK: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="香港", a(group_id) vce(cluster group_id year)
eststo firm_brw_JPN: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="日本", a(group_id) vce(cluster group_id year)
eststo firm_brw_KOR: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="韩国", a(group_id) vce(cluster group_id year)
eststo firm_brw_GER: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="德国", a(group_id) vce(cluster group_id year)
eststo firm_brw_NL: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="荷兰", a(group_id) vce(cluster group_id year)
eststo firm_brw_UK: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="英国", a(group_id) vce(cluster group_id year)
eststo firm_brw_SGP: reghdfe dlnprice_tr brw dlnRER dlnrgdp if coun_aim=="新加坡", a(group_id) vce(cluster group_id year)

esttab firm_brw_HK firm_brw_JPN firm_brw_KOR firm_brw_GER firm_brw_NL firm_brw_UK firm_brw_SGP using "D:\Project E\tables\table_brw_country_major.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw dlnRER dlnrgdp) mtitle(HK JPN KOR GER NL UK SGP)

*-------------------------------------------------------------------------------

* 5. Credit constraints

cd "D:\Project E"
use samples\sample_matched_exp,clear

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

* 6. Markups and marginal costs

cd "D:\Project E"
use samples\sample_matched_exp,clear

gen dMarkup=Markup_DLWTLD-Markup_lag
winsor2 dMarkup, trim

* MC and Markup: US shock
eststo firm_brw_MC0: reghdfe dlnMC_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup0: reghdfe dMarkup_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Price with MC and Markup controls: US shock
eststo firm_brw_MC: reghdfe dlnprice_tr brw dlnMC_tr dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup: reghdfe dlnprice_tr brw dMarkup_tr dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_MC0 firm_brw_Markup0 firm_brw_MC firm_brw_Markup using "D:\Project E\tables\table_brw_markup.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw)

* MC and Markup: EU shock
eststo firm_eus_MC0: reghdfe dlnMC_tr target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_Markup0: reghdfe dMarkup_tr target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Price with MC and Markup controls: EU shock
eststo firm_eus_MC: reghdfe dlnprice_tr target_ea path_ea dlnMC_tr dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_eus_Markup: reghdfe dlnprice_tr target_ea path_ea dMarkup_tr dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_eus_MC0 firm_eus_Markup0 firm_eus_MC firm_eus_Markup using "D:\Project E\tables\table_eus_markup.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_ea path_ea)

* Marginal cost and credit constraints

local varlist "FPC_US ExtFin_US Tang_US"
foreach var of local varlist {
	gen brw_`var' = `var'*brw
}

eststo firm_brw_MC0_FPC_US: reghdfe dlnMC_tr brw brw_FPC_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup0_FPC_US: reghdfe dMarkup brw brw_FPC_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_MC0_ExtFin_US: reghdfe dlnMC_tr brw brw_ExtFin_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup0_ExtFin_US: reghdfe dMarkup brw brw_ExtFin_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_MC0_Tang_US: reghdfe dlnMC_tr brw brw_Tang_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Markup0_Tang_US: reghdfe dMarkup brw brw_Tang_US dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

esttab firm_brw_MC0_FPC_US firm_brw_Markup0_FPC_US firm_brw_MC0_ExtFin_US firm_brw_Markup0_ExtFin_US firm_brw_MC0_Tang_US firm_brw_Markup0_Tang_US using "D:\Project E\tables\table_brw_markup_credit.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw brw_*)

*-------------------------------------------------------------------------------

* 7. Import prices

cd "D:\Project E"
use samples\sample_matched_imp,clear

* Price
eststo firm_brw_imp: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag_imp: reghdfe dlnprice_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Quantity
eststo firm_brw_quant: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_quant_lag_imp: reghdfe dlnquant_tr brw_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

binscatter dlnprice_tr brw, xtitle(US monetary policy shock) ytitle(China's import price change) title("US MPS and China's Import Price") savegraph("D:\Project E\figures\US_shock_imp.png") replace

*-------------------------------------------------------------------------------

* 8. Firm-level credits

cd "D:\Project E"
use samples\cie_credit_brw,clear

* Account receivable to sales income
eststo Arec_brw: reghdfe dArec_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)

* Financial expense and interest expense to total liability
eststo FNoL_brw: reghdfe dFNoL_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)
eststo IEoL_brw: reghdfe dIEoL_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)

* Wage payment per worker
eststo CWPoP_brw: reghdfe dlnCWPoP_tr brw lnSI_lag, a(FRDM) vce(cluster FRDM)

esttab Arec_brw FNoL_brw IEoL_brw CWPoP_brw using "D:\Project E\tables\table_brw_interest.csv", replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw)