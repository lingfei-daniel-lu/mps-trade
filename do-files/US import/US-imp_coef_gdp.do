cd "D:\Project C\PWT10.0"
use PWT100,clear
keep year countrycode country year rgdpna pop
keep if year>=1999
gen lngdp_pc=ln(rgdpna/pop)
cd "D:\Project E\country_X"
save country_GDP,replace

import excel "D:\Project E\tables\tables_Aug2024\US-imp_coefficients.xlsx", sheet("Sheet1") firstrow clear
save "D:\Project E\US_import\US-imp_coef.dta",replace

cd "D:\Project E\country_X"
use country_GDP,clear
keep if year>=2000 & year<=2006
collapse (mean) lngdp_pc, by(countrycode country)
merge 1:1 countrycode using "D:\Project E\US_import\US-imp_coef.dta",nogen keep(matched)
merge 1:1 countrycode using "D:\Project E\country_X\country_advanced.dta",nogen keep(matched) keepus(AD)
replace AD=1 if countrycode=="KOR" | countrycode=="TWN"
drop if countrycode=="VEN"
cd "D:\Project E\US_import"
save US-imp_coef_GDP.dta,replace

cd "D:\Project E\US_import"
use US-imp_coef_GDP.dta,clear

replace coefficient1=0.6 if coefficient1>0.6

twoway (scatter coefficient1 lngdp_pc, mlabel(countrycode)) (lfit coefficient1 lngdp_pc), xtitle(Log GDP per capita) ytitle(Coefficients of price response) yline(0) legend (label(1 "Price change") label(2 "Fitted line"))

reg coefficient1 lngdp_pc
predict yhat1

twoway (hist coefficient1, width(0.2) start(-0.2) frequency legend(off)) (scatteri 0 0 16 0,recast(line) lcolor(blue) lpattern(dash)) (scatteri 0 0.162 16 0.162, recast(line) lcolor(red) lpattern(solid) text(16 0.165 "China, 0.162", color(red) place(e)))

graph export "D:\Project E\figures\US-imp_ctr_30_raw_hist.png", as(png) replace

cd "D:\Project E\US_import"
use US-imp_coef_GDP.dta,clear

replace coefficient2=0.6 if coefficient2>0.6

twoway (scatter coefficient1 lngdp_pc if AD==1, mlabel(countrycode) mcolor(blue)) (scatter coefficient1 lngdp_pc if AD==0, mlabel(countrycode) mcolor(maroon))  (lfit coefficient1 lngdp_pc), xtitle(Log GDP per capita) ytitle(Coefficients of price response) legend (label(1 "Developed") label(2 "Developing") label(3 "Fitted line")) yline(0)

reg coefficient2 lngdp_pc
predict yhat2

twoway (scatter coefficient2 lngdp_pc if AD==1, mlabel(countrycode) mcolor(blue)) (scatter coefficient2 lngdp_pc if AD==0, mlabel(countrycode) mcolor(maroon))  (lfit coefficient2 lngdp_pc), xtitle(Log GDP per capita) ytitle(Coefficients of price response) legend (label(1 "Developed") label(2 "Developing") label(3 "Fitted line")) yline(0)

twoway (hist coefficient2, width(0.2) start(-0.2) frequency legend(off)) (scatteri 0 0 16 0,recast(line) lcolor(blue) lpattern(dash)) (scatteri 0 0.298 16 0.298, recast(line) lcolor(red) lpattern(solid) text(16 0.3 "China, 0.298", color(red) place(e)))

graph export "D:\Project E\figures\US-imp_ctr_30_control_hist.png", as(png) replace