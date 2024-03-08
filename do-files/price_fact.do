cd "D:\Project E"
use samples\sample_monthly_exp_firm,clear

bys time: egen total_value=total(value)
gen value_share=value/total_value

preserve
gen dlnprice_YoY_i=dlnprice_YoY*value_share
collapse (sum) dlnprice_YoY_total=dlnprice_YoY_i brw, by (time)
line dlnprice_YoY_total time, sort
restore

preserve
gen dlnprice_MoM_i=dlnprice_MoM*value_share
collapse (sum) dlnprice_MoM_total=dlnprice_MoM_i brw , by (time)
line dlnprice_MoM_total time, sort
restore