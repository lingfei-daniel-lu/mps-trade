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

* 1.1 All firms

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
esttab IEo* FNo* WC_* Liquid_* Cash_* Arec_* using tables\firm_liquid_all.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

* 1.2 Exporting firms

cd "D:\Project E"
use samples\cie_credit_brw,clear
keep if exp_int>0

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
esttab IEo* FNo* WC_* Liquid_* Cash_* Arec_* using tables\firm_liquid_exp.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress

* 1.3 Exporter vs Non-exporters

cd "D:\Project E"
use samples\cie_credit_brw,clear
gen exp_d=1 if exp_int>0
replace exp_d=0 if exp_d==.

* Liquidity (first stage)
eststo exp_liquid_1: reghdfe D.Liquid brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_liquid_2: reghdfe D.Cash brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_liquid_3: reghdfe D.Turnover brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_liquid_4: reghdfe D.Arec brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Borrowing cost (first stage)
eststo exp_borrow_1: reghdfe D.IEoL brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_borrow_2: reghdfe D.IEoCL brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_borrow_3: reghdfe D.FNoL brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo exp_borrow_4: reghdfe D.FNoCL brw c.brw#c.exp_d L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe exp_liquid_* exp_borrow_*, labels(firm_id "Firm FE")
esttab exp_liquid_* exp_borrow_* using tables\exp_vs_non.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps

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

*-------------------------------------------------------------------------------

* 3. Liquidity/Borrowing cost and markup

cd "D:\Project E"
use samples\cie_credit_brw,clear
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched)
keep if exp_int>0
xtset firm_id year

* Liquidity (first stage)
eststo markup_liquid_1: reghdfe D.Liquid brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo markup_liquid_2: reghdfe D.Cash brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo markup_liquid_3: reghdfe D.Turnover brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo markup_liquid_4: reghdfe D.Arec brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

* Borrowing cost (first stage)
eststo markup_borrow_1: reghdfe D.IEoL brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo markup_borrow_2: reghdfe D.IEoCL brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo markup_borrow_3: reghdfe D.FNoL brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)
eststo markup_borrow_4: reghdfe D.FNoCL brw c.brw#c.l.Markup_High L.lnrSI L.Debt, a(firm_id) vce(cluster firm_id)

estfe markup_liquid_* markup_borrow_*, labels(firm_id "Firm FE")
esttab markup_liquid_* markup_borrow_* using tables\firm_liquid_markup.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps