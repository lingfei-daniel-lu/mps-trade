cd "D:\Project C\CIE"
use cie_98_07,clear
destring INDTYPE,replace
gen type=floor(cic_adj/100)
gen sector=type-12 if type<=37
replace sector=type-13 if type>37
egen newid=group(FRDM)
gen y_output=log(GIOV_CR/OutputDefl)
gen rkap1=FA/inv_deflator
gen realmat=TOIPT/InputDefl  /*real material input*/
gen k=log(rkap1)
gen m=log(realmat)
gen l=log(PERSENG)
drop if y_output==. | l==. | k==.| m==.
cd "D:\Project E\markup"
save cie9807.newid.dta,replace

set processors 12

forvalues sec=1/29 {
clear all
set more off

use cie9807.newid, clear 
*********************
*Step 1
************************
set more off
replace FRDM=upper(FRDM)
*Select industry for procedure
tsset newid year, yearly
keep if sector==`sec'
local M=3
local N=3
forvalues i=1/`M' {
gen l`i'=l^(`i')
gen m`i'=m^(`i')
gen k`i'=k^(`i')
local `N'=`M'-`i'
*interaction terms
forvalues j=1/`N' {
gen l`i'm`j'=l^(`i')*m^(`j')
gen l`i'k`j'=l^(`i')*k^(`j')
gen k`i'm`j'=k^(`i')*m^(`j')
}
}
gen l1k1m1=l*k*m


xi: reg y_output l1 k1 m1 l2 k2 m2 l1k1 l1m1 k1m1 l3 k3 m3 l2k1 l2m1 l1k2 k2m1 l1m2 k1m2 l1k1m1 i.year
*****************************
*i.nace
**************************
gen blols=_b[l1]
gen bkols=_b[k1]
gen bmols=_b[m1]
gen bl2ols=_b[l2]
gen bk2ols=_b[k2]
gen bm2ols=_b[m2]
gen bl1k1ols=_b[l1k1]
gen bl1m1ols=_b[l1m1]
gen bk1m1ols=_b[k1m1]
gen bl3ols=_b[l3]
gen bk3ols=_b[k3]
gen bm3ols=_b[m3]
gen bl2k1ols=_b[l2k1]
gen bl2m1ols=_b[l2m1]
gen bl1k2ols=_b[l1k2]
gen bk2m1ols=_b[k2m1]
gen bl1m2ols=_b[l1m2]
gen bk1m2ols=_b[k1m2]
gen blkmols=_b[l1k1m1]

gen b_mOLS=bmols+2*bm2ols*m1+bl1m1ols*l1+bk1m1ols*k1+3*bm3ols*m2+bl2m1ols*l2+bk2m1ols*k2 + 2*bl1m2ols*l1m1+2*bk1m2ols*k1m1+blkmols*l1k1 

*------FIRST STAGE ----------------------------------------------------------*
xi: reg y_output l* k* m* i.year
******************************
*ask e*(l* m* k*)
*********************************
predict phi
predict epsilon, res
label var phi "phi_it"
label var epsilon "measurement error first stage"
gen phi_lag=L.phi
*----------------------------------------------------------------------------------------------------*
gen l_lag=L.l
gen m_lag=L.m
gen k_lag=L.k
gen l_lag2=l_lag^2
gen k_lag2=k_lag^2
gen m_lag2=m_lag^2

gen l_lagk=l_lag*k
gen l_lagk2=l_lag*k^2
gen l_lagk_lag=l_lag*k_lag
gen l_lagk_lag2=l_lag*k_lag^2
gen l_lag2k=l_lag^2*k
gen l_lag2k_lag=l_lag^2*k_lag

gen km_lag=m_lag*k
gen km_lag2=m_lag^2*k
gen k2m_lag=m_lag*k^2
gen k_lagm_lag=m_lag*k_lag
gen k_lag2m_lag=m_lag*k_lag^2
gen k_lagm_lag2=m_lag^2*k_lag

gen l_lagm_lag=l_lag*m_lag
gen l_lag2m_lag=l_lag^2*m_lag
gen l_lagm_lag2=l_lag*m_lag^2

gen l_lag3=l_lag^3
gen k_lag3=k_lag^3
gen m_lag3=m_lag^3

gen l_lagkm_lag=l_lag*k*m_lag
gen l_lagk_lagm_lag=l_lag*k_lag*m_lag

gen alpha_m=TOIPT/GIOV_CR 
drop _I*
sort newid year
gen const=1
drop if y_output==.
drop if l_lag==.
drop if k==.
drop if k_lag==.
drop if m_lag==.
drop if phi==.
drop if phi_lag==.


****************************************
*Step 2
*****************************************
gmm (phi-{betal}*l1-{betak}*k1-{betam}*m1-{betal2}*l2-{betak2}*k2-{betam2}*m2-{betalk}*l1k1-{betalm}*l1m1-{betakm}*k1m1 ///
- {betal3}*l3 - {betak3}*k3 - {betam3}*m3 - {betal2k1}*l2k1 - {betal2m1}*l2m1 - {betal1k2}*l1k2 - {betak2m1}*k2m1 - {betal1m2}*l1m2 - {betak1m2}*k1m2 - {betalkm}*l1k1m1  ///
-{alpha1}*(phi_lag-{betal}*l_lag-{betak}*k_lag-{betam}*m_lag-{betal2}*l_lag2-{betak2}*k_lag2-{betam2}*m_lag2-{betalk}*l_lagk_lag-{betalm}*l_lagm_lag-{betakm}*k_lagm_lag  ///
- {betal3}*l_lag3 - {betak3}*k_lag3 - {betam3}*m_lag3 - {betal2k1}*l_lag2k_lag - {betal2m1}*l_lag2m_lag - {betal1k2}*l_lagk_lag2 - {betak2m1}*k_lag2m_lag - {betal1m2}*l_lagm_lag2 - {betak1m2}*k_lagm_lag2 - {betalkm}*l_lagk_lagm_lag) ///
-{alpha2}*(phi_lag-{betal}*l_lag-{betak}*k_lag-{betam}*m_lag-{betal2}*l_lag2-{betak2}*k_lag2-{betam2}*m_lag2-{betalk}*l_lagk_lag-{betalm}*l_lagm_lag-{betakm}*k_lagm_lag  ///
- {betal3}*l_lag3 - {betak3}*k_lag3 - {betam3}*m_lag3 - {betal2k1}*l_lag2k_lag - {betal2m1}*l_lag2m_lag - {betal1k2}*l_lagk_lag2 - {betak2m1}*k_lag2m_lag - {betal1m2}*l_lagm_lag2 - {betak1m2}*k_lagm_lag2 - {betalkm}*l_lagk_lagm_lag)^2  ///
-{alpha3}*(phi_lag-{betal}*l_lag-{betak}*k_lag-{betam}*m_lag-{betal2}*l_lag2-{betak2}*k_lag2-{betam2}*m_lag2-{betalk}*l_lagk_lag-{betalm}*l_lagm_lag-{betakm}*k_lagm_lag  ///
- {betal3}*l_lag3 - {betak3}*k_lag3 - {betam3}*m_lag3 - {betal2k1}*l_lag2k_lag - {betal2m1}*l_lag2m_lag - {betal1k2}*l_lagk_lag2 - {betak2m1}*k_lag2m_lag - {betal1m2}*l_lagm_lag2 - {betak1m2}*k_lagm_lag2 - {betalkm}*l_lagk_lagm_lag)^3)  ///
, instruments(k1 k2 k3 l_lag m_lag k_lag l_lag2 k_lag2 m_lag2 l_lag3 k_lag3 m_lag3 km_lag km_lag2 k2m_lag k_lagm_lag k_lag2m_lag k_lagm_lag2 l_lagm_lag l_lag2m_lag l_lagm_lag2 ///
 l_lagk l_lagk2 l_lagk_lag l_lagk_lag2 l_lag2k l_lag2k_lag l_lagkm_lag l_lagk_lagm_lag)

gen betal1_tld=_b[/betal]
gen betak1_tld=_b[/betak]
gen betam1_tld=_b[/betam]
gen betal2_tld=_b[/betal2]
gen betak2_tld=_b[/betak2]
gen betam2_tld=_b[/betam2]
gen betal1k1_tld=_b[/betalk]
gen betal1m1_tld=_b[/betalm]
gen betak1m1_tld=_b[/betakm]

gen betal3_tld=_b[/betal3]
gen betak3_tld=_b[/betak3]
gen betam3_tld=_b[/betam3]
gen betal2k1_tld = _b[/betal2k1]
gen betal2m1_tld = _b[/betal2m1]
gen betal1k2_tld = _b[/betal1k2]
gen betak2m1_tld = _b[/betak2m1]
gen betal1m2_tld = _b[/betal1m2]
gen betak1m2_tld = _b[/betak1m2]
gen betalkm_tld = _b[/betalkm]

gen betam_tld=betam1_tld+2*betam2_tld*m1+betal1m1_tld*l1+betak1m1_tld*k1+3*betam3_tld*m2+betal2m1_tld*l2+betak2m1_tld*k2 + 2*betal1m2_tld*l1m1+2*betak1m2_tld*k1m1+betalkm_tld*l1k1 

gen Markup_ols=b_mOLS/alpha_m
gen Markup_DLWTLD=betam_tld/alpha_m
sum Markup_ols Markup_DLWTLD, detail
keep year FRDM newid Markup_ols Markup_DLWTLD type sector betal1_tld betak1_tld betam1_tld betal2_tld betak2_tld betam2_tld betal1k1_tld betal1m1_tld betak1m1_tld  /// 
     betal3_tld betak3_tld betam3_tld betal2k1_tld betal2m1_tld betal1k2_tld betak2m1_tld betal1m2_tld betak1m2_tld betalkm_tld

save cie9807.markup.trans3rd.sector_`sec'.dta, replace
}


clear all
set more off

use cie9807.markup.trans3rd.sector_1.dta, clear
forvalues sec=2/29 {
append using cie9807.markup.trans3rd.sector_`sec'.dta
}
compress
save cie9807.markup.beta.trans3rd.dta, replace

use cie9807.markup.beta.trans3rd.dta, clear
merge 1:1 newid year using cie_98_07_newid
keep if _merge==3
drop _merge
tab year
gen tfp_tld= y_output - betal1_tld*l- betak1_tld*k- betam1_tld*m -betal2_tld*l*l- betak2_tld*k*k- betam2_tld*m*m- betal1k1_tld*l*k- betal1m1_tld*l*m - betak1m1_tld*k*m ///
 - betal3_tld*l*l*l - betak3_tld*k*k*k - betam3_tld*m*m*m - betal2k1_tld*l*l*k - betal2m1_tld*l*l*m - betal1k2_tld*l*k*k - betak2m1_tld*k*k*m - betal1m2_tld*l*m*m - betak1m2_tld*k*m*m - betalkm_tld*l*k*m 
compress
save cie9907markup.dta, replace