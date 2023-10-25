cd "D:\Project E\customs_raw"

* 2000-2001
forv j=0/1{
use 200`j'\tradedata_200`j'_1,clear
forv i=2/12{
append using 200`j'\tradedata_200`j'_`i'
}
gen year=substr(shipment_date,1,4)
gen month=substr(shipment_date,5,2)
drop shipment_date
rename (hs_id company country) (HS8 EN coun_aim)
collapse (sum) value quantity, by(exp_imp party_id CompanyType EN HS8 coun_aim year month)
replace exp_imp="imp" if exp_imp=="1"
replace exp_imp="exp" if exp_imp=="0"
drop if party_id==""
save tradedata_200`j'_monthly.dta,replace
}

* 2002
use 2002\tradedata_2002_1,clear
forv i=2/12{
append using 2002\tradedata_2002_`i'
}
gen year=substr(shipment_date,1,4)
gen month=substr(shipment_date,5,2)
drop shipment_date
rename (hs_id pname 国家名称_C 进出口_C companytype) (HS8 EN coun_aim exp_imp CompanyType)
collapse (sum) value quantity, by(exp_imp party_id CompanyType EN HS8 coun_aim year month)
replace exp_imp="imp" if exp_imp=="进口"
replace exp_imp="exp" if exp_imp=="出口"
drop if party_id==""
save tradedata_2002_monthly.dta,replace

* 2003-2004
forv j=3/4{
use 200`j'\tradedata_200`j'_1,clear
forv i=2/12{
append using 200`j'\tradedata_200`j'_`i'
}
gen year=substr(日期,1,4)
gen month=substr(日期,5,2)
drop 日期
rename (进口或出口 企业编码 经营单位 企业性质 税号编码 起运国或目的国 金额 数量) (exp_imp party_id EN CompanyType HS8 coun_aim value quantity)
collapse (sum) value quantity, by(exp_imp party_id CompanyType EN HS8 coun_aim year month)
replace exp_imp="imp" if exp_imp=="进口"
replace exp_imp="exp" if exp_imp=="出口"
drop if party_id==""
save tradedata_200`j'_monthly.dta,replace
}

* 2005
use 2005\tradedata_2005_1,clear
forv i=2/12{
append using 2005\tradedata_2005_`i'
}
gen year=substr(shipment_date,1,4)
gen month=substr(shipment_date,5,2)
drop shipment_date
replace CompanyType=companyType if CompanyType==""
rename (exp_or_imp company hs_id country) (exp_imp EN HS8 coun_aim)
collapse (sum) value quantity, by(exp_imp party_id CompanyType EN HS8 coun_aim year month)
replace exp_imp="imp" if exp_imp=="进口"
replace exp_imp="exp" if exp_imp=="出口"
drop if party_id==""
save tradedata_2005_monthly.dta,replace

* 2006
use 2006\tradedata_2006_1,clear
forv i=2/12{
append using 2006\tradedata_2006_`i'
}
gen year=substr(月度,1,4)
gen month=substr(月度,5,2)
drop 月度
rename (进出口 企业代码 企业名称 企业类型 商品代码 var18 金额 数量) (exp_imp party_id EN CompanyType HS8 coun_aim value quantity)
destring value quantity,replace
collapse (sum) value quantity, by(exp_imp party_id CompanyType EN HS8 coun_aim year month)
replace exp_imp="imp" if exp_imp=="进口"
replace exp_imp="exp" if exp_imp=="出口"
drop if party_id==""
format EN %30s
save tradedata_2006_monthly.dta,replace