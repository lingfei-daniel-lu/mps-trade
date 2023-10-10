* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* A. Regressions for matched firm-level annual sample (2000-2007)

*-------------------------------------------------------------------------------

* 1. Baseline

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Price
eststo price_brw_noRER: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_lag: reghdfe dlnprice_tr L.brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* Quantity
eststo quant_brw_noRER: reghdfe dlnquant_tr brw dlnrgdp, a(group_id) vce(cluster group_id)
eststo quant_brw: reghdfe dlnquant_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo quant_brw_lag: reghdfe dlnquant_tr L.brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab price_brw_noRER price_brw price_brw_lag quant_brw_noRER quant_brw quant_brw_lag using tables\table_brw.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw* dlnRER)

binscatter dlnprice_tr brw, xtitle(US monetary policy shock) ytitle(China's export price change) title("US MPS and China's Export Price") savegraph(figures\US_shock.png) replace

* USD price
eststo price_brw_USD_noRER: reghdfe dlnprice_USD_tr brw dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_USD: reghdfe dlnprice_USD_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_USD_lag: reghdfe dlnprice_USD_tr L.brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* Fixed regime
eststo price_brw_fixed: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id)
eststo quant_brw_fixed: reghdfe dlnquant_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id)
eststo price_brw_USD_fixed: reghdfe dlnprice_USD_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id)

esttab price_brw_USD_noRER price_brw_USD price_brw_USD_lag using tables\table_brw_USD.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw* dlnRER)

*-------------------------------------------------------------------------------

* 2. Alternative shocks

cd "D:\Project E"
use samples\sample_matched_exp,clear
merge m:1 year using MPS\others\shock_ea,nogen keep(matched)
sort group_id year

* EU shock
eststo price_eus_noRER: reghdfe dlnprice_tr target_ea path_ea dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_eus: reghdfe dlnprice_tr target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_eus_lag: reghdfe dlnprice_tr L.target_ea L.path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab price_eus_noRER price_eus price_eus_lag using tables\table_eus.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_ea path_ea L.target_ea L.path_ea)

binscatter dlnprice_tr target_ea, xtitle(EU monetary policy shock) ytitle(China's export price change) title(EU MPS and China's Export Price) savegraph(figures\EU_shock.png) replace

*-------------------------------------------------------------------------------

* 3. Firm-level heterogeneity

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Firm size
eststo price_brw_rSI: reghdfe dlnprice_tr c.brw#c.L.lnrSI dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* Two-way traders
eststo price_brw_twoway: reghdfe dlnprice_tr c.brw#c.L.twoway_trade dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* Import and export intensity
eststo price_brw_imp_int: reghdfe dlnprice_tr c.brw#c.L.imp_int dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_exp_int: reghdfe dlnprice_tr c.brw#c.L.exp_int dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* Ownership
gen SOE=1 if ownership=="SOE"
replace SOE=0 if SOE==.
gen MNE=1 if ownership=="MNE"
replace MNE=0 if MNE==.
eststo price_brw_SOE: reghdfe dlnprice_tr c.brw#c.SOE dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_MNE: reghdfe dlnprice_tr c.brw#c.MNE dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_rSI price_brw_twoway price_brw_imp_int price_brw_exp_int price_brw_SOE price_brw_MNE using tables\table_brw_x.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw* dlnRER dlnrgdp)

*-------------------------------------------------------------------------------

* 4. Trade exposure to certain markets

cd "D:\Project E"
use samples\sample_matched_exp,clear

gen value_year_US=value_year if coun_aim=="美国"
replace value_year_US=0 if value_year_US==.
gen value_year_EU=value_year if EU==1
replace value_year_EU=0 if value_year_EU==.

* Firm-level export exposure
bys FRDM year: egen export_sum_US=total(value_year_US) 
gen exposure_US=export_sum_US/export_sum
bys FRDM year: egen export_sum_EU=total(value_year_EU) 
gen exposure_EU=export_sum_EU/export_sum

* Firm-product-level export exposure
bys FRDM HS6 year: egen export_sum_US_HS6=total(value_year_US) 
gen exposure_US_HS6=export_sum_US_HS6/export_sum
bys FRDM HS6 year: egen export_sum_EU_HS6=total(value_year_EU) 
gen exposure_EU_HS6=export_sum_EU_HS6/export_sum

sort group_id year

eststo price_brw_expUS: reghdfe dlnprice_tr c.brw#c.L.exposure_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_expEU: reghdfe dlnprice_tr c.brw#c.L.exposure_EU dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_expUS_HS6: reghdfe dlnprice_tr c.brw#c.L.exposure_US_HS6 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_expEU_HS6: reghdfe dlnprice_tr c.brw#c.L.exposure_EU_HS6 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_expUS price_brw_expEU price_brw_expUS_HS6 price_brw_expEU_HS6 using tables\table_brw_exposure.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw* dlnRER dlnrgdp)

*-------------------------------------------------------------------------------

* 5. Country heterogeneity

* 5.1 Subsamples

cd "D:\Project E"
use samples\sample_matched_exp,clear
gen USA=1 if coun_aim=="美国"

eststo price_brw_USA: reghdfe dlnprice_tr c.brw#c.USA dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_EU: reghdfe dlnprice_tr c.brw#c.EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_OECD: reghdfe dlnprice_tr c.brw#c.OECD dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_EME: reghdfe dlnprice_tr c.brw#c.EME dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab price_brw_USA price_brw_EU price_brw_OECD price_brw_EME using tables\table_brw_country.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw* dlnRER dlnrgdp)

cd "D:\Project E"
use samples\sample_matched_exp,clear
keep if rank_exp<=54
statsby _b _se n=(e(N)), by(coun_aim countrycode) clear: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
graph hbar (asis) _b_brw, over(coun_aim, label(labsize(*0.45)) sort(1)) ytitle("Export price responses to US monetary policy shocks") nofill
graph export figures\brw_country.png, as(png) replace

*-------------------------------------------------------------------------------

* 6. Industry and product heterogeneity

cd "D:\Project E"
use samples\sample_matched_exp,clear
statsby _b _se n=(e(N)), by(cic2): reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
graph hbar (asis) _b_brw, over(cic2, label(labsize(*0.45)) sort(cic2)) ytitle("Export price responses to US monetary policy shocks")
graph export figures\brw_cic2.png, as(png) replace

cd "D:\Project E"
use samples\sample_matched_exp,clear
statsby _b _se n=(e(N)), by(HS2): reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
drop if HS2=="01"
graph hbar (asis) _b_brw, over(HS2, label(labsize(*0.3)) sort(HS2)) ytitle("Export price responses to US monetary policy shocks")
graph export figures\brw_HS2.png, as(png) replace

*-------------------------------------------------------------------------------

* 7. Credit constraints

* 7.1 Manova's credit constraint measure

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Credit constraint from US measures
eststo price_brw_FPC_US: reghdfe dlnprice_tr c.brw#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_ExtFin_US: reghdfe dlnprice_tr c.brw#c.ExtFin_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Tang_US: reghdfe dlnprice_tr c.brw#c.Tang_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Invent_US: reghdfe dlnprice_tr c.brw#c.Invent_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_TrCredit_US: reghdfe dlnprice_tr c.brw#c.TrCredit_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_FPC_US price_brw_ExtFin_US price_brw_Tang_US price_brw_Invent_US price_brw_TrCredit_US using tables\table_brw_credit.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

eststo quant_brw_FPC_US: reghdfe dlnquant_tr c.brw#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo quant_brw_ExtFin_US: reghdfe dlnquant_tr c.brw#c.ExtFin_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo quant_brw_Tang_US: reghdfe dlnquant_tr c.brw#c.Tang_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo quant_brw_Invent_US: reghdfe dlnquant_tr c.brw#c.Invent_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo quant_brw_TrCredit_US: reghdfe dlnquant_tr c.brw#c.TrCredit_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab quant_brw_FPC_US quant_brw_ExtFin_US quant_brw_Tang_US quant_brw_Invent_US quant_brw_TrCredit_US using tables\table_brw_credit_quant.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* Credit constraint from CN measures
eststo price_brw_ExtFin_cic2: reghdfe dlnprice_tr c.brw#c.ExtFin_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Tang_cic2: reghdfe dlnprice_tr c.brw#c.Tang_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Invent_cic2: reghdfe dlnprice_tr c.brw#c.Invent_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Arec_cic2: reghdfe dlnprice_tr c.brw#c.Arec_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_ExtFin_cic2 price_brw_Tang_cic2 price_brw_Invent_cic2 price_brw_Arec_cic2 using tables\table_brw_credit_cic2.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* 7.2 Other financial indicators

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Firm-level Debt, Cash, Liquidity and Interest expense
eststo price_brw_Debt: reghdfe dlnprice_tr c.brw#c.L.Debt dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Cash: reghdfe dlnprice_tr c.brw#c.L.Cash dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Liquid: reghdfe dlnprice_tr c.brw#c.L.Liquid dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_IEoS: reghdfe dlnprice_tr c.brw#c.L.IEoS dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_IEoL: reghdfe dlnprice_tr c.brw#c.L.IEoL dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_Debt price_brw_Cash price_brw_Liquid price_brw_IEoS price_brw_IEoL using tables\table_brw_fina_firm.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* Industry-level Debt, Cash, Liquidity and Interest expense
eststo price_brw_Debt_cic2: reghdfe dlnprice_tr c.brw#c.Debt_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Cash_cic2: reghdfe dlnprice_tr c.brw#c.Cash_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Liquid_cic2: reghdfe dlnprice_tr c.brw#c.Liquid_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_cic2: reghdfe dlnprice_tr c.brw#c.IEoS_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_cic2: reghdfe dlnprice_tr c.brw#c.IEoL_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_Debt_cic2 price_brw_Cash_cic2 price_brw_Liquid_cic2 price_brw_IEoS_cic2 price_brw_IEoL_cic2 using tables\table_brw_fina_cic2.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* 7.3 Triple interactions

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Industry-level triple interactions
eststo price_brw_Debt_cic2_FPC: reghdfe dlnprice_tr c.brw#c.FPC_US c.brw#c.Debt_cic2 c.brw#c.Debt_cic2#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Cash_cic2_FPC: reghdfe dlnprice_tr c.brw#c.FPC_US c.brw#c.Cash_cic2 c.brw#c.Cash_cic2#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Liquid_cic2_FPC: reghdfe dlnprice_tr c.brw#c.FPC_US c.brw#c.Liquid_cic2 c.brw#c.Liquid_cic2#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_IEoS_cic2_FPC: reghdfe dlnprice_tr c.brw#c.FPC_US c.brw#c.IEoS_cic2 c.brw#c.IEoS_cic2#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_IEoL_cic2_FPC: reghdfe dlnprice_tr c.brw#c.FPC_US c.brw#c.IEoL_cic2 c.brw#c.IEoL_cic2#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_Debt_cic2_FPC price_brw_Cash_cic2_FPC price_brw_Liquid_cic2_FPC price_brw_IEoS_cic2_FPC price_brw_IEoL_cic2_FPC using tables\table_brw_fina_triple.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

*-------------------------------------------------------------------------------

* 8. Markup and TFP

cd "D:\Project E"
use samples\sample_matched_exp,clear

* 8.1 Decomposition into markups and marginal costs

* How MC and Markup change?
eststo dMC_brw: reghdfe dlnMC_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo dMarkup_brw: reghdfe d.Markup brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* Price with Markup controls
eststo price_brw_dMarkup: reghdfe dlnprice_tr brw d.Markup dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab dMC_brw dMarkup_brw price_brw_dMarkup using tables\table_brw_dmarkup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw dlnRER dlnrgdp)

* Markup and credit constraints
eststo dMarkup_brw_FPC_US: reghdfe d.Markup c.brw#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo dMarkup_brw_ExtFin_US: reghdfe d.Markup c.brw#c.ExtFin_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo dMarkup_brw_Tang_US: reghdfe d.Markup c.brw#c.Tang_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab dMarkup_brw_FPC_US dMarkup_brw_ExtFin_US dMarkup_brw_Tang_US using tables\table_brw_dmarkup_credit.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* 8.2 Markup and TFP interactions

cd "D:\Project E"
use samples\sample_matched_exp,clear

eststo price_brw_Markup: reghdfe dlnprice_tr c.brw#c.L.Markup_DLWTLD dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_tfp: reghdfe dlnprice_tr c.brw#c.L.tfp_tld dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo quant_brw_Markup: reghdfe dlnquant_tr c.brw#c.L.Markup_DLWTLD dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo quant_brw_tfp: reghdfe dlnquant_tr c.brw#c.L.tfp_tld dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_Markup price_brw_tfp quant_brw_Markup quant_brw_tfp using tables\table_brw_markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)