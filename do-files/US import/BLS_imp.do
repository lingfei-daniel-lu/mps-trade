cd "D:\Project E\BLS_US"
import excel GDP.xls, sheet("FRED Graph") cellrange(A11:B321) firstrow clear
gen year=year(observation_date)
gen month=month(observation_date)
gen quarter=1 if month==1
replace quarter=2 if month==4
replace quarter=3 if month==7
replace quarter=4 if month==10
drop observation_date month
sort year quarter
gen dlnGDP=ln(GDP)-ln(GDP[_n-1])
save GDP_US_quarterly,replace

import excel GDP.xls, sheet("FRED Graph") cellrange(A11:B321) firstrow clear
gen year=year(observation_date)
collapse (sum) GDP, by(year)
gen dlnGDP=ln(GDP)-ln(GDP[_n-1])
drop if year==2024
save GDP_US_annual,replace

cd "D:\Project E\BLS_US"
use price_index_import_FRED.dta, clear
keep ym year month ln_pim dln_pim
gen quarter=1 if month<=3
replace quarter=2 if month>=4 & month<=6
replace quarter=3 if month>=7 & month<=9
replace quarter=4 if month>=10
merge 1:1 year month using "D:\Project E\MPS\monthly\brw_month",nogen keep(matched)
merge 1:1 year month using dollar_index_month_fed,nogen keep(matched)
merge 1:1 year month using CPI_month,nogen keep(matched)
merge n:1 year quarter using GDP_US_quartly,nogen keep(matched)
merge 1:1 year month using INDPRO_US,nogen keep(matched)
tsset ym
save sample_BLS,replace

cd "D:\Project E\BLS_US"
use sample_BLS,clear
binscatter dln_pim brw, n(300)

cd "D:\Project E"
use BLS_US\sample_BLS,clear
eststo BLS_9519_1: reg dln_pim brw dlndollar dlnGDP, r
eststo BLS_9519_2: reg dln_pim brw l.dln_pim dlndollar dlnGDP, r
eststo BLS_0006_1: reg dln_pim brw dlndollar dlnGDP if year>=2000 & year<=2006, r
eststo BLS_0006_2: reg dln_pim brw l.dln_pim dlndollar dlnGDP if year>=2000 & year<=2006, r
esttab BLS* using tables\tables_Sep2024\BLS.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate(`r(indicate_fe)') compress nogaps