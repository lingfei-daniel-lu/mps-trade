* This do-file is to construct samples for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* 1. Introduce monetary policy shocks

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
rename (federalfundsratefactor lsapfactor forwardguidancefactor) (ffr lsap fwgd)
collapse (sum) ffr lsap fwgd, by(year)
gen ffr_lag=ffr[_n-1]
gen lsap_lag=lsap[_n-1]
gen fwgd_lag=fwgd[_n-1]
save lsap_91_19,replace

********************************************************************************

* 2. Sample Construction

* Firm-level matched sample, 2000-2007
cd "D:\Project C\sample_matched"
use customs_matched,clear
* keep only export records
keep if exp_imp =="exp"
drop exp_imp
* mark processing or assembly trade
gen process = 1 if shipment=="进料加工贸易" | shipment=="来料加工装配贸易" | shipment=="来料加工装配进口的设备"
replace process=0 if process==.
gen assembly = 1 if shipment=="来料加工装配贸易" | shipment=="来料加工装配进口的设备"
replace assembly=0 if assembly==.
collapse (sum) value_year quant_year, by(FRDM EN year coun_aim HS6 process assembly)
* add other firm-level variables
merge n:1 FRDM year using customs_twoway,nogen keep(matched) keepus(twoway_trade)
merge n:1 FRDM year using ".\CIE\cie_credit",nogen keep(matched) keepusing (FRDM year EN cic_adj cic2 Markup_* tfp_* rSI rTOIPT rCWP rkap tc scratio scratio_lag *_cic2 *_US ownership affiliate)
merge n:1 coun_aim using customs_matched_top_partners,nogen keep(matched)
merge n:1 FRDM year HS6 using customs_matched_destination,nogen keep(matched)
merge n:1 coun_aim using "D:\Project C\gravity\distance_CHN",nogen keep(matched)
replace dist=dist/1000
replace distw=distw/1000
gen lnrSI=ln(rSI)
* drop trade service firms
foreach key in 贸易 外贸 经贸 工贸 科贸 商贸 边贸 技贸 进出口 进口 出口 物流 仓储 采购 供应链 货运{
	drop if strmatch(EN, "*`key'*") 
}
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value_year),prop
* add exchange rates and other macro variables
merge n:1 year using "D:\Project C\PWT10.0\US_NER_99_19",nogen keep(matched)
merge n:1 year coun_aim using "D:\Project C\PWT10.0\RER_99_19.dta",nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation peg_USD OECD EU)
* calculate price changes
sort FRDM HS6 coun_aim year
gen price_RMB=value_year*NER_US/quant_year
gen price_US=value_year/quant_year
by FRDM HS6 coun_aim: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen MS_lag=MS[_n-1] if year==year[_n-1]+1
by FRDM HS6 coun_aim: egen year_count=count(year)
drop if dlnRER==. | dlnprice==.
* add monetary policy shocks
cd "D:\Project E"
merge m:1 year using ".\monetary policy\brw\brw_94_21",nogen keep(matched)
merge m:1 year using ".\monetary policy\mpu\mpu_85_22",nogen keep(matched)
merge m:1 year using ".\monetary policy\lsap\lsap_91_19",nogen keep(matched)
* construct country exposures
bys FRDM year: egen export_sum=total(value_year)
gen value_year_US=value_year if coun_aim=="美国"
replace value_year_US=0 if value_year_US==.
bys FRDM year: egen export_sum_US=total(value_year_US) 
gen exposure_US=export_sum_US/export_sum
gen value_year_EU=value_year if EU==1
replace value_year_EU=0 if value_year_US==.
bys FRDM year: egen export_sum_EU=total(value_year_EU) 
gen exposure_EU=export_sum_EU/export_sum
* construct group id
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
egen group_id=group(FRDM HS6 coun_aim)
* drop outliers
winsor2 dlnprice, trim
winsor2 dlnprice_USD, trim
* construct interaction terms
local varlist "FPC_US ExtFin_US Invent_US Tang_US"
foreach var of local varlist {
	gen brw_`var' = `var'*brw
}
xtset group_id year
format EN %30s
save sample_matched_exp_mp,replace