* This do-file is to construct samples for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

set processor 8
********************************************************************************

* 1. Monetary policy shocks

* brw: US monetary policy surprise, 1994-2022
cd "D:\Project E\MPS\brw"
use brw_month,replace
collapse (sum) brw, by(year)
save brw_94_22,replace

cd "D:\Project E\MPS\brw"
use brw_month,replace
drop if brw==0
keep if year<=2021
twoway scatter brw ym, ytitle(US monetary policy shock) xtitle(time) tline(2000m1 2006m12) title("Monetary policy shock series by BRW(2021)") saving(BRW.png, replace)

* mpu: US monetary policy uncertainty, 1985-2022
cd "D:\Project E\MPS\mpu"
import excel HRS_MPU_monthly.xlsx, sheet("Sheet1") firstrow clear
gen year=substr(Month,1,4) if substr(Month,1,1)!=" "
replace year=substr(Month,2,4) if substr(Month,1,1)==" "
destring year,replace
collapse (sum) USMPU, by(year)
save mpu_85_22,replace

* lsap & fwgd: US large scale asset purchasing and forward guidance, 1991-2019
cd "D:\Project E\MPS\lsap"
use lsap_shock,replace
gen year=substr(date,-4,.)
destring year,replace
rename (federalfundsratefactor lsapfactor forwardguidancefactor) (ffr lsap fwgd)
collapse (sum) ffr lsap fwgd, by(year)
save lsap_91_19,replace

* eu: EU monetary policy surprise, 1999-2022
cd "D:\Project E\MPS\monthly"
use eu_infoshock_monthly,replace
collapse (sum) *_mpd, by(year)
save eu_infoshock_annual,replace

* real interest rate

cd "D:\Project E\MPS\monthly"
use ffr, clear
rename date time
gen year=year(time)
gen month=month(time)
gen day=day(time)
collapse (mean) ffr, by(year month)
label variable ffr "monthly average federal fund rate"
egen time_id=group(year month)
tsset time_id
gen d_ffr=d.ffr
label variable d_ffr "difference of monthly average federal fund rate"
gen real_increase=0
replace real_increase=1 if d_ffr>0 & d_ffr !=.
label variable real_increase "dummy, =1 if average ffr increase relative to last month"
gen real_decrease=0
replace real_decrease=1 if d_ffr<0 & d_ffr !=.
label variable real_decrease "dummy, =1 if average ffr decrease relative to last month"
save ffr_monthly,replace

* Weighted shock

cd "D:\Project E\MPS\brw\weight"

* (1) monthly
clear
set obs 333 
gen ym = ym(1994, 12) + _n
format ym %tm
save year_month.dta, replace

use brw_daily.dta, clear
gen year=year(date)
gen month=month(date)
gen ym=ym(year, month)
format ym %tm
tsset ym
tsfill
replace year=year[_n+1] if year==.
replace month=month[_n+1]-1 if month==.
replace brw=0 if brw==.
gen day=day(date)
gen ndays = daysinmonth(date)
gen rdays=ndays-day+1
gen weight=rdays/ndays
replace weight=1 if weight==.
gen brw_weight=brw[_n-1]*(1-weight[_n-1])+brw[_n]*weight[_n]
corr brw brw_weight
keep year month brw_weight
save brw_weight_m.dta, replace

* (2) annually

use brw_daily.dta, clear
generate ndays = cond(isleapyear(date), 366, 365)
gen year=year(date)
gen first_day = mdy(1,1,year)
gen last_day = mdy(12, 31, year)
format date first_day last_day %td
gen rdays=last_day-date+1
gen weight=rdays/ndays
gen brw_thisyear=brw*weight
gen brw_nextyear=brw*(1-weight)

collapse (sum) brw_thisyear brw_nextyear, by(year)
gen brw_weight=brw_thisyear+brw_nextyear[_n-1]

keep year brw_weight
save brw_weight_y.dta, replace

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

cd "D:\Project E\ER"
use NER_US_month,clear
gen dlnNER_US=ln(NER_US)-ln(NER_US[_n-12])
save NER_US_month.dta,replace

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

* 2.5 Macro time series control of China

cd "D:\Project E\control\china"

use raw\China_cpi,clear
rename (截止日期_End 居民消费价格指数CPI_当月同比上年同月100_CPI_Y) (date cpi_china)
gen year=year(date)
gen month=month(date)
keep year month cpi_china
save China_cpi,replace

use raw\China_ppi,clear
rename (截止日期_End 工业品出厂价格指数PPI上年100_累计同比_Indus) (date ppi_china)
gen year=year(date)
gen month=month(date)
keep year month ppi_china
save China_ppi,replace

use raw\China_policy_rate,clear
gen year=year(date)
gen month=month(date)
collapse (mean) ROO7, by (year month)
save China_policy_rate,replace

use raw\China_gdp,clear
rename (截止日期_End 规模以上工业增加值_当月同比上年同月100_Anov) (date iva_china)
gen year=year(date)
gen month=month(date)
keep year month iva_china
save China_iva,replace

use raw\China_central_bank,clear
rename (截止日期_End 货币和准货币广义货币M2_MonAndQuaMon) (date m2_china)
gen year=year(date)
gen month=month(date)
collapse (mean) m2_china, by(year month)
gen time=monthly(string(year)+"-"+string(month),"YM")
format time %tm
tsset time
gen m2g_YoY=(m2_china-l12.m2_china)/l12.m2_china
gen m2g_MoM=(m2_china-l.m2_china)/l.m2_china
save China_m2g,replace

********************************************************************************

* 3. CIE data with credit constraints

* Construct new CIE data, focus on manufacturing firms
cd "D:\Project A\CIE"
use cie1998.dta,clear
keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE CFS CFC CFL CFI CPHMT CFF)
append using cie1999,keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE TP CFS CFC CFL CFI CPHMT CFF)
rename CPHMT CFHMT
forv i = 2000/2003{
append using cie`i',keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE TP CFS CFC CFL CFI CFHMT CFF)
}
append using cie2004,keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL CWP FN IE TP CFS CFC CFL CFI CFHMT F389)
forv i = 2005/2006{
append using cie`i',keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL F334 CWP FN IE TP CFS CFC CFL CFI CFHMT CFF F389)
}
rename F334 RND
rename F389 AP
append using cie2007,keep(FRDM EN year INDTYPE REGTYPE GIOV_CR PERSENG TOIPT SI TWC NAR STOCK FA TA CL TL RND CWP FN IE TP CFS CFC CFL CFI CFHMT CFF AP)
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
* drop unwanted firms
drop if FRDM==""
keep if TA>TWC
keep if TA>FA
keep if SI>0
keep if PERSENG>=10
* Calculate firm-level real sales and cost
sort FRDM year 
gen rSI=SI/OutputDefl*100
gen CoS=(CWP+TOIPT+0.15*FA)/SI
/*
gen rTOIPT=TOIPT/InputDefl*100
gen rCWP=CWP/InputDefl*100
gen rkap=FA/inv_deflator*100
gen vc=rTOIPT+rCWP
gen tc=rTOIPT+rCWP+0.15*rkap 
*/
* Calculate firm-level financial constraints from CIE
gen Tang=FA/TA
gen Invent=STOCK/SI
gen Turnover=1/Invent
gen Cash=(TWC-NAR-STOCK)/TA
gen WC=TWC/TA
gen Liquid=(TWC-CL)/TA
gen Debt=TL/TA
gen NArec=NAR/TA
gen Apay=AP/TA
gen Arec=(NAR+AP)/TA
gen IEoL=IE/TL
gen IEoCL=IE/CL
gen FNoL=FN/TL
gen FNoCL=FN/CL
gen CWPoS=CWP/SI
gen TOIPToS=TOIPT/SI
* Construct industry-level financial constraints by CIC2
local varlist "CoS Tang Invent Turnover IEoL IEoCL FNoL FNoCL Debt WC Liquid Cash Arec Apay NArec"
foreach var of local varlist {
	winsor2 `var', replace
	bys year cic2: egen `var'_cic2 = median(`var')
}
* Add FLL (2015) measures
merge n:1 cic2 using "D:\Project C\credit\FLL_Appendix\FLL_Appendix_A1",nogen keep(matched) keepus(ExtFin)
rename ExtFin ExtFin_cic2
* Add MWZ (2015) measures
merge n:1 cic_adj using "D:\Project C\credit\CIC_MWZ",nogen keep(matched)
* (PCA) FPC is the first principal component of external finance dependence and asset tangibility
* Manova FPC
pca Tang_US ExtFin_US
factor Tang_US ExtFin_US,pcf
factortest Tang_US ExtFin_US
rotate, promax(3) factors(1)
predict f1
rename f1 FPC_US
* LLWY FPC
pca Liquid Cash
factor Liquid Cash,pcf
factortest Liquid Cash
rotate, promax(3) factors(1)
predict f1
rename f1 FPC_liquid
pca Liquid_cic2 Cash_cic2
factor Liquid_cic2 Cash_cic2,pcf
factortest Liquid_cic2 Cash_cic2
rotate, promax(3) factors(1)
predict f1
rename f1 FPC_liquid_cic2
* Match affiliation info
merge n:1 FRDM using "D:\Project C\parent_affiliate\affiliate_2004",nogen keep(matched master)
replace affiliate=0 if affiliate==.
* log sales and costs
local varlist "rSI STOCK TP TL CL"
foreach var of local varlist{
gen ln`var'=ln(`var')
}
save CIE\cie_credit_v2,replace

cd "D:\Project E"
use CIE\cie_credit_v2,clear
* calculate trade intensity
merge n:1 FRDM year using "D:\Project C\sample_matched\customs_matched_twoway",nogen keep(master matched) keepus(twoway_trade export_sum import_sum)
replace twoway_trade=0 if twoway_trade==. 
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
gen exp_int=export_sum*NER_US/(SI*1000)
gen imp_int=import_sum*NER_US/(TOIPT*1000)
gen trade_int=(import_sum+export_sum)*NER_US/(SI*1000)
replace exp_int=0 if exp_int==.
replace imp_int=0 if imp_int==.
replace trade_int=0 if trade_int==.
replace exp_int=1 if exp_int>=1
replace imp_int=1 if imp_int>=1
keep FRDM year twoway_trade *_int
duplicates drop
save CIE\cie_int,replace

cd "D:\Project E"
use CIE\cie_credit_v2,clear
* Calculate firm-level markup from CIE
merge 1:1 FRDM year using markup\cie9907markup, nogen keep(matched master) keepus(Markup_* tfp_*)
merge n:1 FRDM using markup\cie9907markup_1st, nogen keep(matched master)
winsor2 Markup_*, trim replace
winsor2 tfp_*, trim replace
keep FRDM year cic_adj cic2 Markup_* tfp_*
* High-Markup vs Low-Markup
** across sector
bys year cic_adj: egen Markup_cic4=median(Markup_DLWTLD)
bys year cic_adj: egen Markup_cic4_1st=median(Markup_DLWTLD_1st)
bys year cic2: egen Markup_cic2=median(Markup_DLWTLD)
bys year cic2: egen Markup_cic2_1st=median(Markup_DLWTLD_1st)
** within sector
gen Markup_cic2_High=1 if Markup_DLWTLD!=. & Markup_DLWTLD > Markup_cic2
replace Markup_cic2_High=0 if Markup_DLWTLD!=. & Markup_DLWTLD <= Markup_cic2
gen Markup_cic2_High_1st=1 if Markup_DLWTLD_1st!=. & Markup_DLWTLD_1st > Markup_cic2_1st
replace Markup_cic2_High_1st=0 if Markup_DLWTLD_1st!=. & Markup_DLWTLD_1st <= Markup_cic2_1st
gen Markup_cic4_High=1 if Markup_DLWTLD!=. & Markup_DLWTLD > Markup_cic4
replace Markup_cic4_High=0 if Markup_DLWTLD!=. & Markup_DLWTLD <= Markup_cic4
gen Markup_cic4_High_1st=1 if Markup_DLWTLD_1st!=. & Markup_DLWTLD_1st > Markup_cic4_1st
replace Markup_cic4_High_1st=0 if Markup_DLWTLD_1st!=. & Markup_DLWTLD_1st <= Markup_cic4_1st
* High-TFP vs Low-TFP
** across sector
bys year cic_adj: egen tfp_cic4=median(tfp_tld)
bys year cic_adj: egen tfp_cic4_1st=median(tfp_tld_1st)
bys year cic2: egen tfp_cic2=median(tfp_tld)
bys year cic2: egen tfp_cic2_1st=median(tfp_tld_1st)
** within sector
gen tfp_High=1 if tfp_tld!=. & tfp_tld > tfp_cic2
replace tfp_High=0 if tfp_tld!=. & tfp_tld <= tfp_cic2
gen tfp_High_1st=1 if tfp_tld_1st!=. & tfp_tld_1st > tfp_cic2_1st
replace tfp_High_1st=0 if tfp_tld_1st!=. & tfp_tld_1st <= tfp_cic2_1st
save CIE\cie_markup,replace

cd "D:\Project E"
use CIE\cie_credit_v2,clear
merge n:1 year using MPS\brw\brw_94_22, nogen keep(matched)
merge n:1 FRDM year using CIE\cie_int, nogen keep(matched master)
merge n:1 FRDM year using customs_matched\customs_matched_exposure, nogen keep(matched master)
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
* add other country-level variables
merge n:1 coun_aim using customs_matched_top_partners,nogen keep(matched) keepus(rank_*)
merge n:1 coun_aim using "D:\Project C\gravity\distance_CHN",nogen keep(matched)
replace dist=dist/1000
replace distw=distw/1000
* drop trade service firms
foreach key in 贸易 外贸 经贸 工贸 科贸 商贸 边贸 技贸 进出口 进口 出口 物流 仓储 采购 供应链 货运{
	drop if strmatch(EN, "*`key'*") 
}
cd "D:\Project E"
save customs_matched\customs_matched_exp,replace

cd "D:\Project E"
use customs_matched\customs_matched_exp,clear
collapse (sum) value_year, by (FRDM year coun_aim countrycode)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
merge n:1 FRDM year using "D:\Project C\sample_matched\customs_matched_twoway",nogen keep(master matched) keepus(export_sum)
gen value_year_US=value_year if coun_aim=="美国"
replace value_year_US=0 if value_year_US==.
local group "EU OECD EME peg_USD"
foreach var of local group{
	gen value_year_`var'=value_year if `var'==1
	replace value_year_`var'=0 if value_year_`var'==.
}
* Firm-level export exposure
bys FRDM year: egen export_sum_US=total(value_year_US) 
gen exposure_US=export_sum_US/export_sum
local group "EU OECD EME peg_USD"
foreach var of local group{
	bys FRDM year: egen export_sum_`var'=total(value_year_`var') 
	gen exposure_`var'=export_sum_`var'/export_sum
}
/* Firm-product-level export exposure
bys FRDM HS6 year: egen export_sum_US_HS6=total(value_year_US) 
gen exposure_US_HS6=export_sum_US_HS6/export_sum
bys FRDM HS6 year: egen export_sum_EU_HS6=total(value_year_EU) 
gen exposure_EU_HS6=export_sum_EU_HS6/export_sum 
*/
collapse (mean) exposure_*, by (FRDM year)
by FRDM: egen exposure_US_mean=mean(exposure_US)
by FRDM: egen exposure_EU_mean=mean(exposure_EU)
save customs_matched\customs_matched_exposure,replace

cd "D:\Project E"
use customs_matched\customs_matched_exp,clear
collapse (sum) value_year quant_year (mean) process dist distw [aweight=value_year], by(FRDM HS6 year)
* calculate RMB value and price
merge n:1 year using ER\US_NER_99_19,nogen keep(matched)
gen price_RMB=value_year*NER_US/quant_year
gen price_USD=value_year/quant_year
egen group_id=group(FRDM HS6)
xtset group_id year
by group_id: gen dlnprice_h=ln(price_USD)-ln(L.price_USD)
by group_id: gen dlnprice_h_RMB=ln(price_RMB)-ln(L.price_RMB)
save customs_matched\customs_matched_exp_HS6,replace

cd "D:\Project E"
use customs_matched\customs_matched_exp_HS6,clear
bys FRDM year: egen share_it=pc(value_year),prop
by FRDM year: egen HS6_count=nvals(HS6)
sort group_id year
by group_id: gen share_bar=0.5*(share_it+L.share_it)
replace share_bar=share_it if share_bar==.
sort FRDM year
by FRDM year: egen dlnprice=sum(dlnprice_h*share_bar), missing
by FRDM year: egen dlnprice_RMB=sum(dlnprice_h_RMB*share_bar), missing
collapse (sum) value=value_year (mean) process dist distw, by(FRDM year dlnprice dlnprice_RMB HS6_count)
save customs_matched\customs_matched_exp_firm,replace

* Construct matching directory
use "D:\Project A\customs merged\cust.matched.all.dta",clear
keep FRDM party_id year exp_imp
tostring party_id,replace
duplicates drop party_id year exp_imp,force
cd "D:\Project E"
save customs_matched\party_id\customs_matched_partyid,replace

cd "D:\Project E"
use customs_matched\party_id\customs_matched_partyid,clear
keep if exp_imp=="exp"
drop exp_imp
save customs_matched\party_id\customs_matched_exp_partyid,replace

*-------------------------------------------------------------------------------

* 4.2 Monthly customs data, 2000-2006

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
collapse (sum) value quantity, by(party_id EN HS6 HS2 coun_aim year month CompanyType shipment)
destring year month,replace
format EN %30s
format coun_aim %20s
save tradedata_monthly_`var',replace
}

cd "D:\Project E"
use customs_raw\tradedata_monthly_exp,clear
destring year month, replace
merge n:1 party_id year using customs_matched\party_id\customs_matched_exp_partyid,nogen keep(matched)
* clean the country names
merge n:1 coun_aim using "D:\Project C\customs data\customs_country_name",nogen keep(matched)
drop coun_aim
rename country_adj coun_aim
drop if coun_aim==""|coun_aim=="中华人民共和国"
* clean the HS codes
gen HS2002=HS6 if year<2007 & year>=2002
merge n:1 HS2002 using "D:\Project C\HS Conversion\HS2002to1996.dta",nogen update replace
replace HS1996=HS6 if year<2002
drop HS6 HS2002
rename HS1996 HS6
drop if HS6=="" | FRDM=="" | quant==0 | value==0
* mark processing or assembly trade
gen process = 1 if shipment=="进料加工贸易" | shipment=="来料加工装配贸易" | shipment=="来料加工装配进口的设备"
replace process=0 if process==.
gen assembly = 1 if shipment=="来料加工装配贸易" | shipment=="来料加工装配进口的设备"
replace assembly=0 if assembly==.
* drop trade service firms
foreach key in 贸易 外贸 经贸 工贸 科贸 商贸 边贸 技贸 进出口 进口 出口 物流 仓储 采购 供应链 货运{
	drop if strmatch(EN, "*`key'*") 
}
collapse (sum) value quant, by (FRDM HS6 coun_aim year month process)
* add Rauch (1999) classification
merge m:1 HS6 using "Rauch classification\HS6_Rauch", nogen keep(matched master) keepus(Rauch_*)
* calculate RMB value and price
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
gen price_RMB=value*NER_US/quantity
gen price_USD=value/quantity
gen time=monthly(string(year)+"-"+string(month),"YM")
format time %tm
sort FRDM HS6 coun_aim time
save customs_matched\customs_monthly_exp,replace

cd "D:\Project E"
use customs_matched\customs_monthly_exp,clear
collapse (sum) value quantity (mean) price_h=price_USD price_h_RMB=price_RMB process [aweight=value], by(FRDM time year month HS6 Rauch_*)
egen group_id=group(FRDM HS6)
xtset group_id time
by group_id: gen dlnprice_h_MoM=ln(price_h)-ln(L.price_h)
by group_id: gen dlnprice_h_YoY=ln(price_h)-ln(L12.price_h)
by group_id: gen dlnprice_h_next=ln(price_h)-ln(price_h[_n-1])
by group_id: gen dlnprice_h_YoY_app1=dlnprice_h_YoY
replace dlnprice_h_YoY_app1=ln(price_h)-ln(L11.price_h) if dlnprice_h_YoY_app1==.
replace dlnprice_h_YoY_app1=ln(price_h)-ln(L13.price_h) if dlnprice_h_YoY_app1==.
by group_id: gen dlnprice_h_YoY_app2=dlnprice_h_YoY_app1
replace dlnprice_h_YoY_app2=ln(price_h)-ln(L10.price_h) if dlnprice_h_YoY_app2==.
replace dlnprice_h_YoY_app2=ln(price_h)-ln(L14.price_h) if dlnprice_h_YoY_app2==.
by group_id: gen dlnprice_h_RMB_MoM=ln(price_h_RMB)-ln(L.price_h_RMB)
by group_id: gen dlnprice_h_RMB_YoY=ln(price_h_RMB)-ln(L12.price_h_RMB)
by group_id: gen dlnprice_h_RMB_next=ln(price_h_RMB)-ln(price_h_RMB[_n-1])
save customs_matched\customs_monthly_exp_HS6,replace

cd "D:\Project E"
use customs_matched\customs_monthly_exp_HS6,clear
bys FRDM time: egen share_it=pc(value),prop
by FRDM time: egen HS6_count=nvals(HS6)
sort group_id time
by group_id: gen share_bar_MoM=0.5*(share_it+L.share_it)
replace share_bar_MoM=share_it if share_bar_MoM==.
by group_id: gen share_bar_YoY=0.5*(share_it+L12.share_it)
replace share_bar_YoY=share_it if share_bar_YoY==.
by group_id: gen share_bar_next=0.5*(share_it+share_it[_n-1])
replace share_bar_next=share_it if share_bar_next==.
by group_id: gen share_bar_YoY_app1=share_bar_YoY
replace share_bar_YoY_app1=0.5*(share_it+L11.share_it) if share_bar_YoY_app1==.
replace share_bar_YoY_app1=0.5*(share_it+L13.share_it) if share_bar_YoY_app1==.
by group_id: gen share_bar_YoY_app2=share_bar_YoY_app1
replace share_bar_YoY_app2=0.5*(share_it+L10.share_it) if share_bar_YoY_app2==.
replace share_bar_YoY_app2=0.5*(share_it+L14.share_it) if share_bar_YoY_app2==.
replace share_bar_YoY_app1=share_it if share_bar_YoY_app1==.
replace share_bar_YoY_app2=share_it if share_bar_YoY_app2==.
sort FRDM time
by FRDM time: egen dlnprice_MoM=sum(dlnprice_h_MoM*share_bar_MoM), missing
by FRDM time: egen dlnprice_YoY=sum(dlnprice_h_YoY*share_bar_YoY), missing
by FRDM time: egen dlnprice_next=sum(dlnprice_h_next*share_bar_next), missing
by FRDM time: egen dlnprice_YoY_app1=sum(dlnprice_h_YoY_app1*share_bar_YoY_app1), missing
by FRDM time: egen dlnprice_YoY_app2=sum(dlnprice_h_YoY_app2*share_bar_YoY_app2), missing
by FRDM time: egen dlnprice_RMB_MoM=sum(dlnprice_h_RMB_MoM*share_bar_MoM), missing
by FRDM time: egen dlnprice_RMB_YoY=sum(dlnprice_h_RMB_YoY*share_bar_YoY), missing
by FRDM time: egen dlnprice_RMB_next=sum(dlnprice_h_RMB_next*share_bar_next), missing
collapse (sum) value (mean) process Rauch_*, by(FRDM time year month dlnprice_MoM dlnprice_YoY* dlnprice_next dlnprice_RMB* HS6_count)
save customs_matched\customs_monthly_exp_firm,replace

********************************************************************************

* 5. Sample Construction (annual)

* 5.1 Firm-level matched sample, 2000-2007

cd "D:\Project E"
use customs_matched\customs_matched_exp,replace
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 *_cic2 *oS ln* ownership affiliate)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched) keepus(*_int)
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_DLWTLD)
* add exchange rates and other macro variables
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
merge n:1 year coun_aim using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
* calculate changes of price, quantity and marginal cost
gen price_RMB=value_year*NER_US/quant_year
gen price_USD=value_year/quant_year
gen MC=price_USD/Markup_DLWTLD
sort FRDM HS6 coun_aim year
by FRDM HS6 coun_aim: gen dlnquant=ln(quant_year)-ln(quant_year[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice=ln(price_USD)-ln(price_USD[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice_RMB=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnMC=ln(MC)-ln(MC[_n-1]) if year==year[_n-1]+1
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value_year),prop
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
replace brw=0 if brw==.
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* construct group id
egen group_id=group(FRDM HS6 coun_aim process)
xtset group_id year
* drop outliers
winsor2 dlnprice* dlnquant dlnMC, trim
format EN %30s
save samples\sample_matched_exp,replace

cd "D:\Project E"
use customs_matched\customs_matched_exp_HS6,replace
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 *_cic2 *oS ln* ownership affiliate)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched) keepus(*_int)
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_DLWTLD)
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
replace brw=0 if brw==.
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* calculate value and quantity change
xtset group_id year
by group_id: gen dlnvalue_h_YoY=ln(value_year)-ln(L.value_year)
by group_id: gen dlnquant_h_YoY=ln(quant_year)-ln(L.quant_year)
* drop outliers
winsor2 dlnprice_h*, replace trim
save samples\sample_matched_exp_firm_HS6,replace

cd "D:\Project E"
use customs_matched\customs_matched_exp_firm,replace
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 *_cic2 *oS ln* ownership affiliate)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched) keepus(*_int)
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_DLWTLD)
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
replace brw=0 if brw==.
merge n:1 year using ER\US_NER_99_19,nogen keep(matched)
* construct firm id
egen firm_id=group(FRDM)
xtset firm_id year
* calculate value change
by firm_id: gen dlnvalue=ln(value)-ln(L.value)
* calculate marginal cost
gen lnMarkup=ln(Markup_DLWTLD)
by firm_id: gen dlnMC=dlnprice-D.lnMarkup
* drop outliers
winsor2 dlnprice dlnMC, replace trim
save samples\sample_matched_exp_firm,replace

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
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* construct group id
egen group_id=group(HS6 coun_aim)
* drop outliers
winsor2 dlnprice* dlnquant, trim replace
xtset group_id year
save samples\sample_HS6_country,replace

cd "D:\Project E"
use "D:\Project D\HS6_exp_00-19",clear
collapse (sum) value quant=quantity, by(HS6 year)
* calculate changes of price and quantity
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
gen value_RMB=value*NER_US
gen price_RMB=value_RMB/quant
gen price_USD=value/quant
sort HS6 year
by HS6: gen dlnquant=ln(quant)-ln(quant[_n-1]) if year==year[_n-1]+1
by HS6: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by HS6: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
merge m:1 year using MPS\lsap\lsap_91_19,nogen keep(matched)
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* drop outliers
winsor2 dlnprice* dlnquant, trim replace
save samples\sample_HS6,replace

********************************************************************************

* 6. Sample Construction (monthly)

* 6.1 Firm-product-country level price

cd "D:\Project E"
use customs_matched\customs_monthly_exp,clear
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 *_cic2 *oS ln* ownership affiliate)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched) keepus(*_int)
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_DLWTLD)
* add exchange rates and other macro variables
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US)
merge n:1 year coun_aim using ER\RER_99_19,nogen keep(matched) keepus(NER RER dlnNER dlnRER dlnrgdp inflation)
merge n:1 coun_aim using country_X\country_tag, nogen keep(matched) keepus(peg_USD OECD EU EME)
merge n:1 coun_aim using "D:\Project C\sample_matched\customs_matched_top_partners",nogen keep(matched) keepus(rank_exp)
* add monetary policy shocks
merge m:1 year month using MPS\brw\brw_month,nogen keep(matched master) keepus(brw)
replace brw=0 if brw==.
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* construct group id
egen group_id=group(FRDM HS6 coun_aim process)
xtset group_id time
* calculate price change
by group_id: gen dlnprice_YoY=ln(price_USD)-ln(L12.price_USD)
by group_id: gen dlnprice_RMB_YoY=ln(price_RMB)-ln(L12.price_RMB)
* calculate marginal cost
gen MC=price_USD/Markup_DLWTLD
by group_id: gen dlnMC_YoY=ln(MC)-ln(MC)
winsor2 dlnprice_YoY dlnprice_RMB_YoY dlnMC_YoY, trim replace
save samples\sample_monthly_exp,replace

* 6.2 Firm-product level price

cd "D:\Project E"
use customs_matched\customs_monthly_exp_HS6,clear
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 *_cic2 *oS ln* ownership affiliate)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched) keepus(*_int)
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_DLWTLD)
* add monetary policy shocks
merge m:1 year month using MPS\brw\brw_month,nogen keep(matched master) keepus(brw)
replace brw=0 if brw==.
* drop special products
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* calculate value and quantity change
xtset group_id time
by group_id: gen dlnvalue_h_YoY=ln(value)-ln(L12.value)
by group_id: gen dlnquant_h_YoY=ln(quantity)-ln(L12.quantity)
* calculate marginal cost
gen MC_h=price_h/Markup_DLWTLD
by group_id: gen dlnMC_h_YoY=ln(MC_h)-ln(L12.MC_h)
winsor2 dlnprice_h_YoY dlnprice_h_RMB_YoY dlnMC_h_YoY dlnvalue_h_YoY dlnquant_h_YoY, trim replace
save samples\sample_monthly_exp_firm_HS6, replace

* 6.3 Firm-level price index

cd "D:\Project E"
use customs_matched\customs_monthly_exp_firm,clear
* calculate price index
by FRDM: gen price_index=1 if dlnprice_next==.
by FRDM: replace price_index=price_index[_n-1]+dlnprice_next if price_index==. & price_index[_n-1]!=.
* merge with CIE data
merge n:1 FRDM year using CIE\cie_credit_v2,nogen keep(matched) keepus(cic2 *_cic2 *oS ln* ownership affiliate)
merge n:1 FRDM year using CIE\cie_int,nogen keep(matched) keepus(*_int)
merge n:1 FRDM year using CIE\cie_markup,nogen keep(matched) keepus(Markup_DLWTLD)
* add monetary policy shocks
merge m:1 year month using MPS\brw\brw_month,nogen keep(matched master) keepus(brw)
replace brw=0 if brw==.
merge n:1 year month using ER\NER_US_month,nogen keep(matched)
* construct firm id
egen firm_id=group(FRDM)
xtset firm_id time
* calculate value change
by firm_id: gen dlnvalue_YoY=ln(value)-ln(L12.value)
* calculate marginal cost
gen lnMarkup=ln(Markup_DLWTLD)
by firm_id: gen dlnMC_YoY=dlnprice_YoY-S12.lnMarkup
winsor2 dlnprice_YoY dlnprice_RMB_YoY dlnMC_YoY dlnvalue_YoY, trim replace
save samples\sample_monthly_exp_firm,replace