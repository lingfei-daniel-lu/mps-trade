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

use sample_BLS,clear
binscatter dln_pim brw, n(300)

use sample_BLS,clear
reg dln_pim brw dlndollar d_lnindpro, r
reg dln_pim brw l.dln_pim dlndollar d_lnindpro, r

reg dln_pim brw l.dlndollar l.d_lnindpro, r
reg dln_pim brw l.dln_pim l.dlndollar l.d_lnindpro, r