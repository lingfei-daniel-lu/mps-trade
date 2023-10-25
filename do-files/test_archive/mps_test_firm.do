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

* Interest expense to total/current liability

eststo IEoL_brw: reghdfe D.IEoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo IEoCL_brw: reghdfe D.IEoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

eststo FNoL_brw: reghdfe D.FNoL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo FNoCL_brw: reghdfe D.FNoCL brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Working capital to total asset
eststo WC_brw: reghdfe D.WC brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Net liquid asset to total asset
eststo Liquid_brw: reghdfe D.Liquid brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Cash to total asset
eststo Cash_brw: reghdfe D.Cash brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Account receivable to sales income
eststo Arec_brw: reghdfe D.Arec brw L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe IEo* FNo* WC_* Liquid_* Cash_* Arec_*, labels(firm_id "Firm FE")
esttab IEo* FNo* WC_* Liquid_* Cash_* Arec_* using tables\firm_liquid.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

*-------------------------------------------------------------------------------

* 2. Firm performance

cd "D:\Project E"
use samples\cie_credit_brw,clear

* Sales income level
eststo SI_brw: reghdfe D.lnrSI brw lnrSI, a(firm_id) vce(cluster firm_id)

* Wage payment per worker
eststo CWP_brw: reghdfe D.lnrCWP brw lnrSI, a(firm_id) vce(cluster firm_id)
eststo CWPoP_brw: reghdfe D.lnCWPoP brw lnrSI, a(firm_id) vce(cluster firm_id)

* Total profit to sales income
eststo TPoS_brw: reghdfe D.TPoS brw lnrSI, a(firm_id) vce(cluster firm_id)