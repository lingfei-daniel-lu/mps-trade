cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

bys time: egen total_value=total(value)
gen value_share=value/total_value

preserve
gen dlnprice_YoY_i=dlnprice_YoY*value_share
collapse (sum) dlnprice_YoY_total=dlnprice_YoY_i (mean) brw, by (time year month)
merge 1:1 year month using MPS\brw\brw_month, nogen keep(matched) keepus(brw)
save samples\price_ts\price_YoY,replace
restore

preserve
gen dlnprice_MoM_i=dlnprice_MoM*value_share
collapse (sum) dlnprice_MoM_total=dlnprice_MoM_i (mean) brw , by(time year month)
merge 1:1 year month using MPS\brw\brw_month, nogen keep(matched) keepus(brw)
save samples\price_ts\price_MoM,replace
restore

cd "D:\Project E\samples\price_ts"
use price_YoY,clear
drop if brw==0
twoway (scatter brw time) (line dlnprice_YoY_total time, yaxis(2)), ytitle("Monetary policy shocks") ytitle("{&Delta} log price", axis(2)) legend(order(1 "Monetary policy shocks" 2 "Export price changes"))
twoway (line brw time) (line dlnprice_YoY_total time, yaxis(2)), ytitle("Monetary policy shocks") ytitle("{&Delta} log price", axis(2)) legend(order(1 "Monetary policy shocks" 2 "Export price changes"))


