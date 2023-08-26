* This do-file is to run regressions for Lu and Yao (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* D. Regressions for country-level sample

*-------------------------------------------------------------------------------

* 1. China's national credits

cd "D:\Project E"
use ".\Almanac\bank_credit",clear
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)

* Loans to GDP
binscatter Total_lr brw, xtitle(US monetary policy shock) ytitle(Total loans to GDP ratio) title(US MPS and China's Total Loans) savegraph("D:\Project E\figures\Total_loans.png") replace
binscatter ST_lr brw, xtitle(US monetary policy shock) ytitle(Short-term loans to GDP ratio) title(US MPS and China's Short-term Loans) savegraph("D:\Project E\figures\ST_loans.png") replace
binscatter IST_lr brw, xtitle(US monetary policy shock) ytitle(Short-term Loans to Industrial Sector to GDP ratio) title(US MPS and China's Short-term Loans to Industrial Sector) savegraph("D:\Project E\figures\IST_loans.png") replace
binscatter LT_lr brw, xtitle(US monetary policy shock) ytitle(Long-term loans to GDP ratio) title(US MPS and China's Long-term Loans) savegraph("D:\Project E\figures\LT_loans.png") replace

*-------------------------------------------------------------------------------

* 2. Foreign countries' exposure to China's export

cd "D:\Project E"
use ".\worldbank\wb_exposure_CN",clear
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)
merge m:1 countrycode year using ".\ER\RER_99_19",nogen keep(matched) force
gen brw_exposure_CN=brw*exposure_CN

reghdfe dlnrgdp brw brw_exposure_CN, a(coun_aim) vce(cluster coun_aim year)
reghdfe inflation brw brw_exposure_CN, a(coun_aim) vce(cluster coun_aim year)