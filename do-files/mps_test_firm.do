* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* A. Regressions for firm-level sample (2000-2007)

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

esttab price_brw_USD_noRER price_brw_USD price_brw_USD_lag using tables\table_brw_USD.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw* dlnRER)

* Fixed regime
eststo price_brw_fixed: reghdfe dlnprice_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id)
eststo quant_brw_fixed: reghdfe dlnquant_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id)
eststo price_brw_USD_fixed: reghdfe dlnprice_USD_tr brw dlnRER dlnrgdp if year<=2005, a(group_id) vce(cluster group_id)

*-------------------------------------------------------------------------------

* 2. Alternative shocks

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Large scale asset purchase and forward guidance
eststo price_lsap_noRER: reghdfe dlnprice_tr lsap fwgd dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_lsap: reghdfe dlnprice_tr lsap fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_lsap_lag: reghdfe dlnprice_tr lsap_lag fwgd_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* EU shock
eststo price_eus_noRER: reghdfe dlnprice_tr target_ea path_ea dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_eus: reghdfe dlnprice_tr target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_eus_lag: reghdfe dlnprice_tr target_ea_lag path_ea_lag dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab price_eus_noRER price_eus price_eus_lag using tables\table_eus.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_ea path_ea target_ea_lag path_ea_lag)

binscatter dlnprice_tr target_ea, xtitle(EU monetary policy shock) ytitle(China's export price change) title(EU MPS and China's Export Price) savegraph(figures\EU_shock.png) replace

*-------------------------------------------------------------------------------

* 3. Firm-level heterogeneity

* Price
cd "D:\Project E"
use samples\sample_matched_exp,clear

* Firm size
eststo price_brw_rSI: reghdfe dlnprice_tr c.brw#c.L.lnrSI dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* Two-way traders
eststo price_brw_twoway: reghdfe dlnprice_tr c.brw#c.L.twoway_trade dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* Import intensity
eststo price_brw_imp_int: reghdfe dlnprice_tr c.brw#c.L.imp_int dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* Interest expense ratio
eststo price_brw_IEoS: reghdfe dlnprice_tr c.brw#c.L.IEoS dlnRER dlnrgdp, a(group_id year) vce(cluster group_id year)
eststo price_brw_IEoL: reghdfe dlnprice_tr c.brw#c.L.IEoS dlnRER dlnrgdp, a(group_id year) vce(cluster group_id year)

* Ownership
gen SOE=1 if ownership=="SOE"
replace SOE=0 if SOE==.
gen MNE=1 if ownership=="MNE"
replace MNE=0 if MNE==.
eststo price_brw_SOE: reghdfe dlnprice_tr c.brw#c.SOE dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_MNE: reghdfe dlnprice_tr c.brw#c.MNE dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

* US and EU exposure
eststo price_brw_exp_int: reghdfe dlnprice_tr c.brw#c.L.exp_int dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_expUS: reghdfe dlnprice_tr c.brw#c.L.exposure_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_expEU: reghdfe dlnprice_tr c.brw#c.L.exposure_EU dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_rSI price_brw_twoway price_brw_imp_int price_brw_IEoS price_brw_SOE price_brw_MNE price_brw_exp_int price_brw_expUS price_brw_expEU using tables\table_brw_x.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw* dlnRER dlnrgdp)

*-------------------------------------------------------------------------------

* 4. Country heterogeneity

cd "D:\Project E"
use samples\sample_matched_exp,clear

eststo price_brw_USA: reghdfe dlnprice_tr c.brw#c.USA dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_EU: reghdfe dlnprice_tr c.brw#c.EU dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_OECD: reghdfe dlnprice_tr c.brw#c.OECD dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo price_brw_EME: reghdfe dlnprice_tr c.brw#c.EME dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab price_brw_USA price_brw_EU price_brw_OECD price_brw_EME using tables\table_brw_country1.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw* dlnRER dlnrgdp)

use samples\sample_matched_exp,clear
keep if rank_exp<=54
statsby _b _se n=(e(N)), by(coun_aim countrycode) saving(tables\table_brw_country2,replace): reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

use tables\table_brw_country2,clear
graph hbar (asis) _b_brw, over(coun_aim, label(labsize(*0.45)) sort(1)) ytitle("Export price responses to US monetary policy shocks")
graph export figures\brw_country.png, as(png) name("Graph") replace

*-------------------------------------------------------------------------------

* 5. Credit constraints

cd "D:\Project E"
use samples\sample_matched_exp,clear

* Credit constraint from US measures
eststo price_brw_FPC_US: reghdfe dlnprice_tr c.brw#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_ExtFin_US: reghdfe dlnprice_tr c.brw#c.ExtFin_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Tang_US: reghdfe dlnprice_tr c.brw#c.Tang_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Invent_US: reghdfe dlnprice_tr c.brw#c.Invent_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_TrCredit_US: reghdfe dlnprice_tr c.brw#c.TrCredit_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_FPC_US price_brw_ExtFin_US price_brw_Tang_US price_brw_Invent_US price_brw_TrCredit_US using tables\table_brw_credit.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* Credit constraint from CN measures
eststo price_brw_FPC_cic2: reghdfe dlnprice_tr c.brw#c.FPC_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_ExtFin_cic2: reghdfe dlnprice_tr c.brw#c.ExtFin_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Tang_cic2: reghdfe dlnprice_tr c.brw#c.Tang_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Invent_cic2: reghdfe dlnprice_tr c.brw#c.Invent_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_Arec_cic2: reghdfe dlnprice_tr c.brw#c.Arec_cic2 dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab price_brw_FPC_cic2 price_brw_ExtFin_cic2 price_brw_Tang_cic2 price_brw_Invent_cic2 price_brw_Arec_cic2 using tables\table_brw_credit_cic2.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* Debt, Cash and Liquidity
eststo price_brw_FPC_Debt: reghdfe dlnprice_tr c.brw#c.L.Debt dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_FPC_Cash: reghdfe dlnprice_tr c.brw#c.L.Cash dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo price_brw_FPC_Liquid: reghdfe dlnprice_tr c.brw#c.L.Liquid dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

*-------------------------------------------------------------------------------

* 6. Markups and marginal costs

cd "D:\Project E"
use samples\sample_matched_exp,clear

gen dMarkup=Markup_DLWTLD-D.Markup_DLWTLD

* MC and Markup: US shock
eststo MC_brw: reghdfe dlnMC_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo Markup_brw: reghdfe dMarkup brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* Price with Markup controls: US shock
eststo price_brw_Markup: reghdfe dlnprice_tr brw dMarkup dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab MC_brw Markup_brw price_brw_Markup using tables\table_brw_markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw dlnRER dlnrgdp)

* MC and Markup: EU shock
eststo MC_eus: reghdfe dlnMC_tr target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id)
eststo Markup_eus: reghdfe dMarkup target_ea path_ea dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

* Price with Markup controls: EU shock
eststo price_eus_Markup: reghdfe dlnprice_tr target_ea path_ea dMarkup dlnRER dlnrgdp, a(group_id) vce(cluster group_id)

esttab MC_eus Markup_eus price_eus_Markup using tables\table_eus_markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(target_ea path_ea)

* Markup and credit constraints
eststo Markup_brw_FPC_US: reghdfe dMarkup c.brw#c.FPC_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo Markup_brw_ExtFin_US: reghdfe dMarkup c.brw#c.ExtFin_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)
eststo Markup_brw_Tang_US: reghdfe dMarkup c.brw#c.Tang_US dlnRER dlnrgdp, a(group_id year) vce(cluster group_id)

esttab Markup_brw_FPC_US Markup_brw_ExtFin_US Markup_brw_Tang_US using tables\table_brw_markup_credit.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(*brw*)

* Export to US
eststo MC_brw_US: reghdfe dlnMC_tr brw dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id)
eststo Markup_brw_US: reghdfe dMarkup brw dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id)
eststo price_brw_Markup_US: reghdfe dlnprice_tr brw dMarkup dlnRER dlnrgdp if coun_aim=="美国", a(group_id) vce(cluster group_id)

*-------------------------------------------------------------------------------

* 7. Firm-level credits

cd "D:\Project E"
use samples\cie_credit_brw,clear

* Sales income level
eststo SI_brw: reghdfe D.lnrSI brw, a(firm_id) vce(cluster firm_id)

* Account receivable to sales income
eststo Arec_brw: reghdfe D.Arec brw, a(firm_id) vce(cluster firm_id)

* Interest expense to total liability
eststo IEoL_brw: reghdfe D.IEoL brw, a(firm_id) vce(cluster firm_id)

* Wage payment per worker
eststo CWP_brw: reghdfe D.lnrCWP brw, a(firm_id) vce(cluster firm_id)
eststo CWPoP_brw: reghdfe D.lnCWPoP brw, a(firm_id) vce(cluster firm_id)

* Total cost to sales income
eststo CoS_brw: reghdfe D.CoS brw, a(firm_id) vce(cluster firm_id)

* Total profit to sales income
eststo TPoS_brw: reghdfe D.TPoS brw, a(firm_id) vce(cluster firm_id)

esttab SI_brw Arec_brw IEoL_brw CWP_brw CWPoP_brw CoS_brw TPoS_brw using tables\table_brw_firm.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress order(brw)