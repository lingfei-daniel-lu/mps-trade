set processors 12
dis c(processors)

* US monetary policy shock and China's firm prizing

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* 1. Introduce monetary policy shocks

* Collapse brw and mpu to annual level
* brw: US monetary policy surprise, 1994-2021
cd "D:\Project E\monetary policy\brw"
use BRW_mps,replace
collapse (sum) brw_fomc, by(year)
rename brw_fomc brw
gen brw_lag=brw[_n-1]
save brw_94_21,replace

* mpu: US monetary policy uncertainty. 1985-2022
cd "D:\Project E\monetary policy\mpu"
import excel HRS_MPU_monthly.xlsx, sheet("Sheet1") firstrow clear
gen year=substr(Month,1,4) if substr(Month,1,1)!=" "
replace year=substr(Month,2,4) if substr(Month,1,1)==" "
destring year,replace
collapse (sum) USMPU, by(year)
gen USMPU_lag=USMPU[_n-1]
save mpu_85_22,replace

* lsap & fwgd: US large scale asset purchasing and forward guidance, 
cd "D:\Project E\monetary policy\lsap"
use lsap_shock,replace
gen year=substr(date,-4,.)
destring year,replace
rename (lsapfactor forwardguidancefactor) (lasp fwgd)
collapse (sum) lasp fwgd, by(year)
gen lasp_lag=lasp[_n-1]
gen fwgd_lag=fwgd[_n-1]
save lasp_91_19,replace

********************************************************************************

* 2. Sample Construction

* Construct new sample with brw and mpu
* Firm-level matched sample, 2000-2007
cd "D:\Project E"
use "D:\Project C\sample_matched\sample_matched_exp",clear
merge m:1 year using ".\monetary policy\brw\brw_94_21",nogen keep(matched)
merge m:1 year using ".\monetary policy\mpu\mpu_85_22",nogen keep(matched)
merge m:1 year using ".\monetary policy\lsap\lasp_91_19",nogen keep(matched)
gen prezlb=1 if year<2008
replace prezlb =0 if prezlb==.
gen zlb=1 if year>=2008 & year<2016
replace zlb=0 if zlb==.
gen postzlb=1 if year>=2016
replace postzlb=0 if postzlb==.
xtset group_id year
save sample_matched_exp_mp,replace

* HS6 Product-level sample, 2000-2016
cd "D:\Project E"
use "D:\Project D\sample_HS6_00-19",clear
merge m:1 year using ".\monetary policy\brw\brw_94_21",nogen keep(matched)
merge m:1 year using ".\monetary policy\mpu\mpu_85_22",nogen keep(matched)
merge m:1 year using ".\monetary policy\lsap\lasp_91_19",nogen keep(matched)
gen prezlb=1 if year<2008
replace prezlb =0 if prezlb==.
gen zlb=1 if year>=2008 & year<2016
replace zlb=0 if zlb==.
gen postzlb=1 if year>=2016
replace postzlb=0 if postzlb==.
drop dlnprice_tr*
winsor2 dlnprice, trim
xtset group_id year
save sample_HS6_mp,replace

********************************************************************************

* 3. Regressions for firm-level sample

****************************************

* 3.1 Regressions of price change on brw
cd "D:\Project E"
use sample_matched_exp_mp,clear

* Baseline
eststo firm_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw: reghdfe dlnprice_tr dlnRER brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_lag: reghdfe dlnprice_tr dlnRER brw_lag dlnrgdp, a(group_id) vce(cluster group_id year)

* Credit constraints
gen brw_FPC_US=brw*FPC_US
gen brw_ExtFin_US=brw*FPC_US
gen brw_Tang_US=brw*Tang_US
eststo firm_brw_FPC_US: reghdfe dlnprice_tr brw_FPC_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_ExtFin_US: reghdfe dlnprice_tr brw_ExtFin_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_brw_Tang_US: reghdfe dlnprice_tr brw_Tang_US brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Zero lower bound
gen brw_prezlb=brw*prezlb
gen brw_zlb=brw*zlb
gen brw_postzlb=brw*postzlb
eststo firm_brw_zlb: reghdfe dlnprice_tr brw_prezlb brw_zlb brw_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

****************************************

* 3.2 Regression of price change on lsap and fwgd

* Baseline
eststo firm_lsap: reghdfe dlnprice_tr lasp fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Zero lower bound
gen lasp_prezlb=lasp*prezlb
gen lasp_zlb=lasp*zlb
gen lasp_postzlb=lasp*postzlb
gen fwgd_prezlb=fwgd*prezlb
gen fwgd_zlb=fwgd*zlb
gen fwgd_postzlb=fwgd*postzlb

eststo firm_lasp_zlb: reghdfe dlnprice_tr lasp_prezlb lasp_zlb lasp_postzlb fwgd_prezlb fwgd_zlb fwgd_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo firm_lsap_zlb1: reghdfe dlnprice_tr lasp fwgd dlnRER dlnrgdp if zlb==1, a(group_id) vce(cluster group_id year)

********************************************************************************

* 4. Regressions for quantity-level sample

****************************************

* 4.1 Regression of price change on brw
cd "D:\Project E"
use sample_HS6_mp,clear

* Baseline
eststo product_brw0: reghdfe dlnprice_tr brw dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_brw: reghdfe dlnprice_tr brw dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

* Zero lower bound
gen brw_prezlb=brw*prezlb
gen brw_zlb=brw*zlb
gen brw_postzlb=brw*postzlb
eststo product_brw_zlb: reghdfe dlnprice_tr brw_prezlb brw_zlb brw_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

****************************************

* 4.2 Regression of price change on lsap and fwgd

eststo product_lsap: reghdfe dlnprice_tr lasp fwgd dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)

gen lasp_prezlb=lasp*prezlb
gen lasp_zlb=lasp*zlb
gen lasp_postzlb=lasp*postzlb
gen fwgd_prezlb=fwgd*prezlb
gen fwgd_zlb=fwgd*zlb
gen fwgd_postzlb=fwgd*postzlb

eststo product_lasp_zlb: reghdfe dlnprice_tr lasp_prezlb lasp_zlb lasp_postzlb fwgd_prezlb fwgd_zlb fwgd_postzlb dlnRER dlnrgdp, a(group_id) vce(cluster group_id year)
eststo product_lsap_zlb1: reghdfe dlnprice_tr lasp fwgd dlnRER dlnrgdp if zlb==1, a(group_id) vce(cluster group_id year)