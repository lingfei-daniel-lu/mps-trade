* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* E. Regressions for firm information (2000-2007)

set processor 8

*-------------------------------------------------------------------------------

cd "D:\Project E"
use CIE\cie_credit_v2,clear
merge n:1 year using MPS\brw\brw_94_22,keep(matched master)
egen firm_id=group(FRDM)
xtset firm_id year
save samples\cie_credit_brw,replace

*-------------------------------------------------------------------------------

* 1. Borrowing cost and liquidity

cd "D:\Project E"
use samples\cie_credit_brw,clear

* Interest expense to total liability
eststo IEoL_brw1: reghdfe D.IEoL brw, a(firm_id) vce(cluster firm_id)
eststo IEoL_brw2: reghdfe D.IEoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Working apital to total asset
eststo WC_brw1: reghdfe D.WC brw, a(firm_id) vce(cluster firm_id)
eststo WC_brw2: reghdfe D.WC brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Net liquid asset to total asset
eststo Liquid_brw1: reghdfe D.Liquid brw, a(firm_id) vce(cluster firm_id)
eststo Liquid_brw2: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Cash to total asset
eststo Cash_brw1: reghdfe D.Cash brw, a(firm_id) vce(cluster firm_id)
eststo Cash_brw2: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Account receivable to sales income
eststo Arec_brw1: reghdfe D.Arec brw, a(firm_id) vce(cluster firm_id)
eststo Arec_brw2: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Inventory to sales income
eststo Invent_brw1: reghdfe D.Invent brw, a(firm_id) vce(cluster firm_id)
eststo Invent_brw2: reghdfe D.Invent brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe IEoL_* WC_* Liquid_* Cash_* Arec_* Invent_*, labels(firm_id "Firm FE")
esttab IEoL_* WC_* Liquid_* Cash_* Arec_* Invent_* using tables\brw_firm_liquid.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 2. Other firm performance

cd "D:\Project E"
use samples\cie_credit_brw,clear

* Sales income level
eststo SI_brw: reghdfe D.lnrSI brw lnrSI, a(firm_id) vce(cluster firm_id)

* Wage payment per worker
eststo CWP_brw: reghdfe D.lnrCWP brw lnrSI, a(firm_id) vce(cluster firm_id)
eststo CWPoP_brw: reghdfe D.lnCWPoP brw lnrSI, a(firm_id) vce(cluster firm_id)

* Total cost to sales income
eststo CoS_brw: reghdfe D.CoS brw lnrSI, a(firm_id) vce(cluster firm_id)

* Total profit to sales income
eststo TPoS_brw: reghdfe D.TPoS brw lnrSI, a(firm_id) vce(cluster firm_id)