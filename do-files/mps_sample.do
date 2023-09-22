* This do-file is to construct samples for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

set processor 8
********************************************************************************

* 1. Monetary policy shocks

* brw: US monetary policy surprise, 1994-2021
cd "D:\Project E\MPS\brw"
use BRW_mps,replace
collapse (sum) brw_fomc, by(year)
rename brw_fomc brw
save brw_94_21,replace

twoway scatter brw year, ytitle(US monetary policy shock) xtitle(Year) title("Monetary policy shock series by BRW(2021)") saving(BRW.png, replace)

cd "D:\Project E\MPS\brw"
use BRW_mps,replace
collapse (sum) brw_fomc, by(year month)
rename brw_fomc brw
save brw_94_21_monthly,replace

* mpu: US monetary policy uncertainty. 1985-2022
cd "D:\Project E\MPS\mpu"
import excel HRS_MPU_monthly.xlsx, sheet("Sheet1") firstrow clear
gen year=substr(Month,1,4) if substr(Month,1,1)!=" "
replace year=substr(Month,2,4) if substr(Month,1,1)==" "
destring year,replace
collapse (sum) USMPU, by(year)
save mpu_85_22,replace

* lsap & fwgd: US large scale asset purchasing and forward guidance
cd "D:\Project E\MPS\lsap"
use lsap_shock,replace
gen year=substr(date,-4,.)
destring year,replace
rename (federalfundsratefactor lsapfactor forwardguidancefactor) (ffr lsap fwgd)
collapse (sum) ffr lsap fwgd, by(year)
save lsap_91_19,replace

********************************************************************************

* 2. Exchange rates and macro variables

* 2.1 Construct exchange rate from PWT10.0

cd "D:\Project C\PWT10.0"
use PWT100,clear
keep if year>=1999 & year<=2019 
keep countrycode country currency_unit year xr pl_c rgdpna
merge n:1 countrycode country currency_unit using pwt_country_name,nogen
merge n:1 countrycode year using "D:\Project C\IMF CPI\CPI_99_19_code",nogen
replace cpi=100 if year==2010 & coun_aim=="台湾省"
forv i=1999/2019{
	global cpi_TWN_`i'=pl_c[`i'+1530]/pl_c[3540]*100
	replace cpi=${cpi_TWN_`i'} if year==`i' & coun_aim=="台湾省"
}
drop if xr==.
save PWT100_99_19,replace

cd "D:\Project C\PWT10.0"
use PWT100_99_19,clear
* Bilateral nominal exchange rate relative to RMB at the same year
gen NER=8.27825/xr if year==1999
forv i=2000/2019{
	global xr_CN_`i'=xr[`i'-1305]
	replace NER=${xr_CN_`i'}/xr if year==`i'
}
label var NER "Nominal exchange rate in terms of RMB at the same year"
* Bilateral real exchange rate = NER*foreign CPI/Chinese CPI
gen RER=NER*cpi/80.69 if year==1999
forv i=2000/2019{
	global cpi_CN_`i'=cpi[`i'-1305]
	replace RER=NER*cpi/${cpi_CN_`i'} if year==`i'
}
label var RER "Real exchange rate to China price at the same year"
sort coun_aim year
by coun_aim: gen dlnNER= ln(NER)-ln(NER[_n-1]) if year==year[_n-1]+1
by coun_aim: gen dlnRER= ln(RER)-ln(RER[_n-1]) if year==year[_n-1]+1
by coun_aim: gen dlnrgdp=ln(rgdpna)-ln(rgdpna[_n-1]) if year==year[_n-1]+1
by coun_aim: gen inflation=ln(cpi)-ln(cpi[_n-1]) if year==year[_n-1]+1
cd "D:\Project E\ER"
save RER_99_19.dta,replace

use RER_99_19,clear
keep if countrycode=="USA"
keep year NER coun_aim
rename NER NER_US
gen dlnNER_US=ln(NER_US)-ln(NER_US[_n-1]) if year==year[_n-1]+1
save US_NER_99_19.dta,replace

* 2.2 Bank credit

cd "D:\Project E\Almanac"
import excel bankcredit.xlsx, sheet("Sheet1") firstrow clear
drop UsesofFunds
rename (Year TotalLoans ShorttermLoans LoanstoIndustrialSector LongtermLoans) (year Total_loans ST_loans IST_loans LT_loans)
merge 1:1 year using "D:\Project E\control\china\PWT100_CN",nogen keep(matched) keepus(cgdpo)
merge 1:1 year using "D:\Project E\ER\US_NER_99_19",nogen keep(matched) keepus(NER_US)
local varlist "Total ST IST LT"
foreach var of local varlist {
	gen `var'_lr = `var'_loans*100/(cgdpo*NER_US)
}
save bank_credit,replace

* 2.3 World Bank import

cd "D:\Project E\worldbank"
import excel ".\API_NE.IMP.GNFS.CD_DS2_en_excel_v2_5729220.xls", sheet("Data") cellrange(A4:BO270) firstrow clear
drop IndicatorName IndicatorCode CountryName
reshape long imp, i(CountryCode) j(year)
rename (CountryCode imp) (countrycode imp_country)
drop if imp_country==.
save wb_imp_60_22,replace

cd "D:\Project E\worldbank"
import excel ".\API_NE.EXP.GNFS.CD_DS2_en_excel_v2_5728863.xls", sheet("Data") cellrange(A4:BO270) firstrow clear
drop IndicatorName IndicatorCode CountryName
reshape long exp, i(CountryCode) j(year)
rename (CountryCode exp) (countrycode exp_country)
drop if exp_country==.
save wb_exp_60_22,replace

cd "D:\Project E\worldbank"
use "D:\Project D\HS6_exp_00-19",clear
collapse (sum) value, by(coun_aim year)
merge n:1 coun_aim using "D:\Project C\customs data\customs_country_namecode",nogen keep(matched)
merge 1:1 countrycode year using wb_imp_60_22,nogen keep(matched)
gen exposure_CN_imp=value/imp_country
replace exposure_CN=1 if exposure_CN>=1
save wb_exposure_CN,replace

* 2.4 Country characteristics

cd "D:\Project C\PWT10.0"
use PWT100_99_19,clear
keep countrycode country coun_aim currency_unit
duplicates drop
* Flag countries pegged to the US dollar
gen peg_USD=0
local peg_code "ABW BHS PAN BHR BRB BLZ BMU DJI HKG JOR LBN MAC MDV OMN PAN QAT SAU ARE"
foreach code of local peg_code{
	replace peg_USD=1 if countrycode=="`code'"
}
replace peg_USD=1 if currency_unit =="East Caribbean Dollar" | currency_unit =="Netherlands Antillian Guilder"| currency_unit =="US Dollar"
* Other country groups
gen OECD=0
local OECD_code "AUT BEL CAN DEU DNK FRA GRC ISL IRL ITA LUX NLD NOR PRT ESP SWE CHE TUR USA GBR JPN FIN AUS NZL MEX CZE HUN KOR POL SVK CHL SVN EST ISR LVA LTU"
foreach code of local OECD_code{
	replace OECD=1 if countrycode=="`code'"
}
gen EU=0
local EU_code "BEL FRA DEU ITA LUX NLD DNK IRL GRC PRT ESP AUT FIN SWE"
foreach code of local EU_code{
	replace EU=1 if countrycode=="`code'"
}
gen EME=0
local EME_code "TWN BRA CHL COL CZE HUN IND IDN MYS MEX MAR PER PHL POL RUS ZAF KOR THA TUR"
foreach code of local EME_code{
	replace EME=1 if countrycode=="`code'"
}
cd "D:\Project E\country_X"
save country_tag,replace

********************************************************************************

* 3. CIE data with credit constraints

* Construct new CIE data, focus on manufacturing firms
cd "D:\Project A\CIE"
use cie1998.dta,clear
keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE CFS CFC CFL CFI CPHMT CFF)
append using cie1999,keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE TP CFS CFC CFL CFI CPHMT CFF)
rename CPHMT CFHMT
forv i = 2000/2004{
append using cie`i',keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE TP CFS CFC CFL CFI CFHMT CFF)
}
forv i = 2005/2006{
append using cie`i',keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL F334 CWP FN IE TP CFS CFC CFL CFI CFHMT CFF)
}
rename F334 RND
append using cie2007,keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL RND CWP FN IE TP CFS CFC CFL CFI CFHMT CFF)
bys FRDM: egen EN_adj=mode(EN),maxmode
bys FRDM: egen REGTYPE_adj=mode(REGTYPE),maxmode
drop EN REGTYPE
rename (EN_adj REGTYPE_adj) (EN REGTYPE)
gen year_cic=2 if year<=2002
replace year_cic=3 if year>2002
merge n:1 INDTYPE year_cic using "D:\Project A\deflator\cic_adj",nogen keep(matched)
drop year_cic    
destring cic_adj,replace
merge n:1 cic_adj year using "D:\Project A\deflator\input_deflator",nogen keep(matched)
merge n:1 cic_adj year using "D:\Project A\deflator\output_deflator",nogen keep(matched)
merge n:1 year using "D:\Project A\deflator\inv_deflator.dta",nogen keep(matched) keepus(inv_deflator)
*add registration type
gen ownership="SOE" if (REGTYPE=="110" | REGTYPE=="141" | REGTYPE=="143" | REGTYPE=="151" )
replace ownership="DPE" if (REGTYPE=="120" | REGTYPE=="130" | REGTYPE=="142" | REGTYPE=="149" | REGTYPE=="159" | REGTYPE=="160" | REGTYPE=="170" | REGTYPE=="171" | REGTYPE=="172" | REGTYPE=="173" | REGTYPE=="174" | REGTYPE=="190")
replace ownership="JV" if (REGTYPE=="210" | REGTYPE=="220" | REGTYPE=="310" | REGTYPE=="320")
replace ownership="MNE" if (REGTYPE=="230" | REGTYPE=="240" | REGTYPE=="330" | REGTYPE=="340")
replace ownership="DPE" if ownership=="" & (CFS==0 & CFC==0 & CFHMT==0 & CFF==0)
replace ownership="SOE" if ownership=="" & (CFHMT==0 & CFF==0)
replace ownership="MNE" if ownership=="" & (CFHMT!=0 | CFF!=0)
drop CFS CFC CFHMT CFF CFL CFI
sort FRDM year
format EN %30s
save "D:\Project E\CIE\cie_98_07",replace

cd "D:\Project E"
use CIE\cie_98_07,clear
keep if year>=1999
tostring cic_adj,replace
gen cic2=substr(cic_adj,1,2)
* Calculate firm-level markup from CIE
merge 1:1 FRDM year using markup\cie9907markup, nogen keepus(Markup_DLWTLD tfp_tld) keep(matched master)
winsor2 Markup_*, trim replace by(cic2)
winsor2 tfp_*, trim replace by(cic2)
* Calculate firm-level real sales and cost
sort FRDM year 
keep if SI>0
gen rSI=SI/OutputDefl*100
gen rTOIPT=TOIPT/InputDefl*100
gen rCWP=CWP/InputDefl*100
gen rkap=FA/inv_deflator*100
gen vc=rTOIPT+rCWP
gen tc=rTOIPT+rCWP+0.15*rkap
* Calculate firm-level financial constraints from CIE
gen Tang=FA/TA
gen Invent=STOCK/SI
gen RDint=RND/SI
gen Cash=(TWC-NAR-STOCK)/TA
gen Liquid=(TWC-CL)/TA
gen Debt=TL/TA
drop if Tang<0 | Invent<0 | RDint<0 | Cash<0 | Debt<0
gen Arec=NAR/SI
gen IEoL=IE/TL
gen IEoS=IE/SI
gen CWPoP=rCWP/PERSENG
gen CoS=vc/rSI
gen TPoS=TP/SI
* Construct industry-level financial constraints by CIC2
bys cic2: egen RDint_cic2=mean(RDint)
local varlist "Tang Invent Arec Debt Cash Liquid IEoL IEoS"
foreach var of local varlist {
	winsor2 `var', replace
	bys cic2: egen `var'_cic2 = median(`var')
}
* Add FLL (2015) measures
merge n:1 cic2 using "D:\Project C\credit\FLL_Appendix\FLL_Appendix_A1",nogen keep(matched) keepus(ExtFin)
rename ExtFin ExtFin_cic2
* Add MWZ (2015) measures
merge n:1 cic_adj using "D:\Project C\credit\CIC_MWZ",nogen keep(matched)
* (PCA) FPC is the first principal component of external finance dependence and asset tangibility
pca Tang_US ExtFin_US
factor Tang_US ExtFin_US,pcf
factortest Tang_US ExtFin_US
rotate, promax(3) factors(1)
predict f1
rename f1 FPC_US
* Match affiliation info
merge n:1 FRDM using "D:\Project C\parent_affiliate\affiliate_2004",nogen keep(matched master)
replace affiliate=0 if affiliate==.
* log sales and costs
local varlist "rSI rCWP CWPoP"
foreach var of local varlist{
gen ln`var'=ln(`var')
}
save CIE\cie_credit_v2,replace

cd "D:\Project E"
use CIE\cie_credit_v2,clear
* calculate trade intensity
merge n:1 FRDM year using "D:\Project C\sample_matched\customs_matched_twoway",nogen keep(master matched) keepus(export_sum import_sum)
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
gen exp_int=export_sum*NER_US/(SI*1000)
gen imp_int=import_sum*NER_US/(vc*InputDefl*10)
gen trade_int=(import_sum+export_sum)*NER_US/(SI*1000)
replace exp_int=0 if exp_int==.
replace imp_int=0 if imp_int==.
replace exp_int=1 if exp_int>=1
replace imp_int=1 if imp_int>=1
drop *_sum
* merge with monetary policy shocks
merge m:1 year using MPS\brw\brw_94_21,nogen keep(matched)
egen firm_id=group(FRDM)
xtset firm_id year
save samples\cie_credit_brw,replace

********************************************************************************

* 4. Customs data

* 4.1 Matched customs data, 2000-2007

cd "D:\Project C\sample_matched"
use customs_matched,clear
* keep only export records
keep if exp_imp =="exp"
drop exp_imp
* mark processing or assembly trade
gen process = 1 if shipment=="进料加工贸易" | shipment=="来料加工装配贸易" | shipment=="来料加工装配进口的设备"
replace process=0 if process==.
collapse (sum) value_year quant_year, by(FRDM EN year coun_aim HS6 process)
* add other firm-level variables
merge n:1 FRDM year using customs_matched_twoway,nogen keep(matched) keepus(twoway_trade export_sum import_sum)
merge n:1 coun_aim using customs_matched_top_partners,nogen keep(matched) keepus(rank_*)
merge n:1 coun_aim using "D:\Project C\gravity\distance_CHN",nogen keep(matched)
replace dist=dist/1000
replace distw=distw/1000
* drop trade service firms
foreach key in 贸易 外贸 经贸 工贸 科贸 商贸 边贸 技贸 进出口 进口 出口 物流 仓储 采购 供应链 货运{
	drop if strmatch(EN, "*`key'*") 
}
cd "D:\Project E\customs"
save customs_matched_exp,replace

cd "D:\Project C\sample_matched"
use customs_matched,clear
* keep only import records
keep if exp_imp =="imp"
drop exp_imp
* mark processing or assembly trade
gen process = 1 if shipment=="进料加工贸易" | shipment=="来料加工装配贸易" | shipment=="来料加工装配进口的设备"
replace process=0 if process==.
collapse (sum) value_year quant_year, by(FRDM EN year coun_aim HS6 process)
* add other firm-level variables
merge n:1 FRDM year using customs_matched_twoway,nogen keep(matched) keepus(twoway_trade export_sum import_sum)
merge n:1 coun_aim using customs_matched_top_partners,nogen keep(matched) keepus(rank_*)
merge n:1 coun_aim using "D:\Project C\gravity\distance_CHN",nogen keep(matched)
replace dist=dist/1000
replace distw=distw/1000
* drop trade service firms
foreach key in 贸易 外贸 经贸 工贸 科贸 商贸 边贸 技贸 进出口 进口 出口 物流 仓储 采购 供应链 货运{
	drop if strmatch(EN, "*`key'*") 
}
cd "D:\Project E\customs"
save customs_matched_imp,replace

*-------------------------------------------------------------------------------

* 4.2 Universal customs data from Tengyu, 2000-2015

cd "D:\Project E\custom_0015"
use custom_0015_exp,clear
rename (hs_2 hs_4 hs_6) (HS2 HS4 HS6)
merge n:1 country using "D:\Project C\customs data\customs_country_namecode",nogen keep(matched)
sort party_id HS6 coun_aim year
order party_id HS* coun* year
format coun_aim %20s
save customs_00_15_exp,replace

*-------------------------------------------------------------------------------

* 4.3 Monthly customs data, 2000-2006

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

* Append 2000-2006
cd "D:\Project E\customs_raw"
local direction "exp imp"
foreach var of local direction {
use tradedata_2000_monthly,clear
forv j=1/6{
append using tradedata_200`j'_monthly
}
keep if exp_imp=="`var'"
drop exp_imp
gen HS6=substr(HS8,1,6)
gen HS2=substr(HS8,1,2)
collapse (sum) value quantity, by(party_id EN HS6 HS2 coun_aim year month CompanyType)
destring year month,replace
format EN %30s
format coun_aim %20s
save tradedata_monthly_`var',replace
}
forv j=0/6{
erase tradedata_200`j'_monthly.dta
}

cd "D:\Project E"
use customs_matched\party_id\customs_matched_partyid,clear
keep if exp_imp=="exp"
drop exp_imp
save customs_matched\party_id\customs_matched_exp_partyid,replace

cd "D:\Project E"
use customs_raw\tradedata_monthly_exp,clear
destring year month, replace
merge n:1 party_id year using customs_matched\party_id\customs_matched_exp_partyid,nogen keep(matched)
merge n:1 coun_aim using "D:\Project C\customs data\customs_country_name",nogen keep(matched)
drop coun_aim
rename country_adj coun_aim
drop if coun_aim==""|coun_aim=="中华人民共和国"
gen HS2002=HS6 if year<2007 & year>=2002
merge n:1 HS2002 using "D:\Project C\HS Conversion\HS2002to1996.dta",nogen update replace
replace HS1996=HS6 if year<2002
drop HS6 HS2002
rename HS1996 HS6
drop if HS6=="" | FRDM=="" | quant==0 | value==0
collapse (sum) value quant, by (FRDM EN HS6 coun_aim year month)
sort FRDM EN HS6 coun_aim year month
save customs_matched\customs_matched_monthly_exp,replace

cd "D:\Project E"
use customs_matched\customs_matched_monthly_exp,clear
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
gen value_RMB=value*NER_US
gen price_RMB=value_RMB/quantity
collapse (sum) value_RMB quantity (mean) price_hit=price_RMB [aweight=value], by(FRDM year month HS6)
gen time=monthly(string(year)+"-"+string(month),"YM")
format time %tm
save customs_matched\customs_matched_monthly_exp_HS6,replace

cd "D:\Project E"
use customs_matched\customs_matched_monthly_exp_HS6,clear
bys FRDM time: egen share_it=pc(value),prop
egen group_id=group(FRDM HS6)
xtset group_id time
by group_id: gen share_bar=0.5*(share_it+L.share_it)
by group_id: gen dlnprice_hit=ln(price_hit)-ln(L.price_hit)
by group_id: gen share_bar_YoY=0.5*(share_it+L12.share_it)
by group_id: gen dlnprice_hit_YoY=ln(price_hit)-ln(L12.price_hit)
sort FRDM time
by FRDM time: egen dlnprice=sum(dlnprice_hit*share_bar), missing
by FRDM time: egen dlnprice_YoY=sum(dlnprice_hit_YoY*share_bar_YoY), missing
by FRDM time: egen value_firm=sum(value_RMB),missing
keep FRDM time year month value_firm dlnprice dlnprice_YoY
duplicates drop
label var value_firm "Total export value in RMB"
label var dlnprice "Month-on-month price growth rate"
label var dlnprice_YoY "Year-on-year price growth rate"
save customs_matched\customs_matched_monthly_exp_firm,replace

********************************************************************************

* 5. Sample Construction (unit value)

* 5.1 Firm-level matched sample, 2000-2007

cd "D:\Project E"
use customs_matched\customs_matched_exp,replace
* merge with CIE data
merge n:1 FRDM year using samples\cie_credit_brw,nogen keep(matched) keepus(cic2 Markup_* tfp_* Arec Debt Cash Liquid IEoL IEoS *_cic2 *_US *_int ln* ownership affiliate)
* add exchange rates and other macro variables
merge n:1 year coun_aim using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
* calculate changes of price, quantity and marginal cost
gen price_RMB=value_year*NER_US/quant_year
gen price_USD=value_year/quant_year
gen MC_RMB=price_RMB/Markup_DLWTLD
sort FRDM HS6 coun_aim year
by FRDM HS6 coun_aim: gen dlnquant=ln(quant_year)-ln(quant_year[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnMC=ln(MC_RMB)-ln(MC_RMB[_n-1]) if year==year[_n-1]+1
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value_year),prop
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_21,nogen keep(matched)
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* construct group id
egen group_id=group(FRDM HS6 coun_aim)
* drop outliers
winsor2 dlnprice* dlnquant dlnMC, trim
xtset group_id year
format EN %30s
save samples\sample_matched_exp,replace

*-------------------------------------------------------------------------------

* 5.2 Product-level matched sample, 2000-2019

cd "D:\Project E"
use "D:\Project D\HS6_exp_00-19",clear
* add exchange rates and other macro variables
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
merge n:1 year coun_aim using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
* calculate changes of price, quantity and marginal cost
gen price_RMB=value*NER_US/quant
gen price_USD=value/quant
sort HS6 coun_aim year
by HS6 coun_aim: gen dlnquant=ln(quant)-ln(quant[_n-1]) if year==year[_n-1]+1
by HS6 coun_aim: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by HS6 coun_aim: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value),prop
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_21,nogen keep(matched)
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* construct group id
egen group_id=group(HS6 coun_aim)
* drop outliers
winsor2 dlnprice* dlnquant, trim
xtset group_id year
save samples\sample_HS6,replace

*-------------------------------------------------------------------------------

* 5.3 Customs universal sample, 2000-2015

cd "D:\Project E"
use custom_0015\customs_00_15_exp,clear
* add exchange rates and other macro variables
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
merge n:1 year coun_aim using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
* calculate changes of price, quantity and marginal cost
gen price_RMB=value*NER_US/quant
gen price_USD=value/quant
sort party_id HS6 coun_aim year
by party_id HS6 coun_aim: gen dlnquant=ln(quant)-ln(quant[_n-1]) if year==year[_n-1]+1
by party_id HS6 coun_aim: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by party_id HS6 coun_aim: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value),prop
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_21,nogen keep(matched)
* drop special products
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* drop outliers
winsor2 dlnprice* dlnquant, trim
save samples\sample_customs_exp,replace

*-------------------------------------------------------------------------------

* 5.4 Customs monthly sample, 2000-2006

cd "D:\Project E"
use customs_matched\customs_matched_monthly_exp,clear
* add exchange rates and other macro variables
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
merge n:1 year coun_aim using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
* calculate changes of price, quantity and marginal cost
gen price_RMB=value*NER_US/quant
gen price_USD=value/quant
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_21,nogen keep(matched)
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
sort FRDM HS6 coun_aim year month
save samples\sample_monthly_exp,replace

********************************************************************************

* 6. Sample Construction (firm-level price index)

cd "D:\Project E"
use customs_matched\customs_matched_monthly_exp_firm,clear
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 Markup_* tfp_* Arec Debt Cash Liquid IEoL IEoS *_cic2 *_US ln* ownership affiliate)
* add exchange rates and other macro variables
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
* add monetary policy shocks
merge m:1 year month using MPS\brw\brw_94_21_monthly,nogen keep(matched master)
sort FRDM time
save samples\sample_monthly_exp_firm,replace