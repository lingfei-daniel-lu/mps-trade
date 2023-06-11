* This do-file is to construct samples for Yao and Lu (2023)

* Note: brw is monetary policy surprise; mpu is monetary policy uncertainty; lsap is large scale asset purchasing; fwgd is forward guidance.

********************************************************************************

* 1. Monetary policy shocks

* brw: US monetary policy surprise, 1994-2021
cd "D:\Project E\MPS\brw"
use BRW_mps,replace
collapse (sum) brw_fomc, by(year)
rename brw_fomc brw
gen brw_lag=brw[_n-1]
save brw_94_21,replace

twoway scatter brw year, xtitle(US monetary policy shock) ytitle(Year) title("Monetary policy shock series by BRW(2021)") savegraph("D:\Project E\figures\BRW.png") replace

* mpu: US monetary policy uncertainty. 1985-2022
cd "D:\Project E\MPS\mpu"
import excel HRS_MPU_monthly.xlsx, sheet("Sheet1") firstrow clear
gen year=substr(Month,1,4) if substr(Month,1,1)!=" "
replace year=substr(Month,2,4) if substr(Month,1,1)==" "
destring year,replace
collapse (sum) USMPU, by(year)
gen USMPU_lag=USMPU[_n-1]
save mpu_85_22,replace

* lsap & fwgd: US large scale asset purchasing and forward guidance
cd "D:\Project E\MPS\lsap"
use lsap_shock,replace
gen year=substr(date,-4,.)
destring year,replace
rename (federalfundsratefactor lsapfactor forwardguidancefactor) (ffr lsap fwgd)
collapse (sum) ffr lsap fwgd, by(year)
gen ffr_lag=ffr[_n-1]
gen lsap_lag=lsap[_n-1]
gen fwgd_lag=fwgd[_n-1]
save lsap_91_19,replace

* ea shock: EU monetary policy 1999-2021
cd "D:\Project E\MPS\others"
use shock_ea,replace
gen target_ea_lag=target_ea[_n-1]
gen path_ea_lag=path_ea[_n-1]
gen lsap_ea_lag=lsap_ea[_n-1]
save ea_99_19,replace

* uk shock: UK and Japan monetary policy, 1998-2015
cd "D:\Project E\MPS\others"
use shock_uk,replace
gen shock_uk_lag=shock_uk[_n-1]
save uk_98_15,replace

* japan shock: Japan monetary policy, 1999-2020
cd "D:\Project E\MPS\others"
use shock_japan,replace
gen target_japan_lag=target_japan[_n-1]
gen path_japan_lag=path_japan[_n-1]
save japan_99_20,replace

********************************************************************************

* 2. Exchange rates and macro variables

* Construct exchange rate from PWT10.0
cd "D:\Project C\PWT10.0"
use PWT100,clear
keep if year>=1999 & year<=2019 
keep countrycode country currency_unit year xr pl_c rgdpna
merge n:1 countrycode country currency_unit using pwt_country_name,nogen
merge n:1 countrycode year using "D:\Project C\IMF CPI\CPI_99_19_code",nogen
drop if xr==.
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
* Flag countries pegged to the US dollar
gen peg_USD=1 if countrycode=="ABW" | countrycode=="BHS" | countrycode=="PAN" | countrycode=="BHR"  | countrycode=="BRB" | countrycode=="BLZ" | countrycode=="BMU" | currency_unit =="East Caribbean Dollar" | currency_unit =="Netherlands Antillian Guilder"| currency_unit =="US Dollar" | countrycode=="DJI" | countrycode=="HKG" | countrycode=="JOR" | countrycode=="LBN" | countrycode=="MAC" | countrycode=="MDV" | countrycode=="OMN" | countrycode=="PAN" | countrycode=="QAT" | countrycode=="SAU" | countrycode=="ARE" | xr==1
replace peg_USD=0 if peg_USD==.
gen OECD=1 if countrycode=="AUT" | countrycode=="BEL" | countrycode=="CAN" | countrycode=="DEU"  | countrycode=="DNK" | countrycode=="FRA" | countrycode=="GRC" | countrycode=="ISL" | countrycode=="IRL" | countrycode=="ITA" | countrycode=="LUX" | countrycode=="NLD" | countrycode=="NOR" | countrycode=="PRT" | countrycode=="ESP" | countrycode=="SWE" | countrycode=="CHE" | countrycode=="TUR" | countrycode=="USA" | countrycode=="GBR" | countrycode=="JPN" | countrycode=="FIN" | countrycode=="AUS" | countrycode=="NZL" | countrycode=="MEX" | countrycode=="CZE" | countrycode=="HUN" | countrycode=="KOR" | countrycode=="POL" | countrycode=="SVK" | countrycode=="CHL" | countrycode=="SVN" | countrycode=="EST" | countrycode=="ISR" | countrycode=="LVA" | countrycode=="LTU" 
replace OECD=0 if OECD==.
gen EU=1 if coun_aim=="比利时" | coun_aim=="比利时" | coun_aim=="法国" | coun_aim=="德国" | coun_aim=="意大利" | coun_aim=="卢森堡" | coun_aim=="荷兰" | coun_aim=="丹麦" | coun_aim=="爱尔兰" | coun_aim=="希腊" | coun_aim=="葡萄牙" | coun_aim=="西班牙" | coun_aim=="奥地利" | coun_aim=="芬兰" | coun_aim=="瑞典"
replace EU=0 if EU==.
cd "D:\Project E\ER"
save RER_99_19.dta,replace

use RER_99_19,clear
keep if countrycode=="USA"
keep year NER coun_aim
rename NER NER_US
gen dlnNER_US=ln(NER_US)-ln(NER_US[_n-1]) if year==year[_n-1]+1
save US_NER_99_19.dta,replace

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

********************************************************************************

* 3. CIE data with credit constraints

cd "D:\Project C\CIE"
use cie_98_07,clear
keep if year>=1999
drop CFS CFC CFHMT CFF CFL CFI
tostring cic_adj,replace
gen cic2=substr(cic_adj,1,2)
* Add markup and tfp info
merge 1:1 FRDM year using "D:\Project C\markup\cie_99_07_markup", nogen keepus(Markup_DLWTLD Markup_lag tfp_tld tfp_lag) keep(matched master)
winsor2 Markup_*, trim replace by(cic2)
winsor2 tfp_*, trim replace by(cic2)
* Calculate firm-level markup from CIE
sort FRDM year 
keep if SI>0
gen rSI=SI/OutputDefl*100
gen rTOIPT=TOIPT/InputDefl*100
gen rCWP=CWP/InputDefl*100
gen rkap=FA/inv_deflator*100
gen vc=rTOIPT+rCWP
gen tc=rTOIPT+rCWP+0.15*rkap
gen SoC=rSI/tc
winsor2 SoC*, trim replace by(cic2)
* Calculate firm-level financial constraints from CIE
gen Tang=FA/TA
gen Invent=STOCK/SI
gen RDint=RND/SI
gen Cash=(TWC-NAR-STOCK)/TA
gen Liquid=(TWC-CL)/TA
gen Levg=TA/TL
gen Arec=NAR/SI
gen FNr=FN/TL
gen IEr=IE/TL
sort FRDM year
drop if Tang<0 | Invent<0 | RDint<0 | Cash<0 | Levg<0
bys cic2: egen RDint_cic2=mean(RDint)
local varlist "Tang Invent Cash Liquid Levg Arec"
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
pca Tang_cic2 ExtFin_cic2
factor Tang_cic2 ExtFin_cic2,pcf
factortest Tang_cic2 ExtFin_cic2
rotate, promax(3) factors(1)
predict f1
rename f1 FPC_cic2
* Match affiliation info
merge n:1 FRDM using "D:\Project C\parent_affiliate\affiliate_2004",nogen keep(matched master)
replace affiliate=0 if affiliate==.
sort FRDM EN year
save cie_credit_v2,replace

********************************************************************************

* 4. Sample Construction

* 4.1 Firm-level matched sample, 2000-2007

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
merge n:1 FRDM year using customs_twoway,nogen keep(matched) keepus(twoway_trade export_sum import_sum)
merge n:1 coun_aim using customs_matched_top_partners,nogen keep(matched) keepus(rank_*)
merge n:1 coun_aim using "D:\Project C\gravity\distance_CHN",nogen keep(matched)
replace dist=dist/1000
replace distw=distw/1000
* drop trade service firms
foreach key in 贸易 外贸 经贸 工贸 科贸 商贸 边贸 技贸 进出口 进口 出口 物流 仓储 采购 供应链 货运{
	drop if strmatch(EN, "*`key'*") 
}
cd "D:\Project E"
save customs_matched_exp,replace

cd "D:\Project E"
use customs_matched_exp,replace
* merge with CIE data
merge n:1 FRDM year using "D:\Project C\CIE\cie_credit_v2",nogen keep(matched) keepus (FRDM year EN cic_adj cic2 Markup_* tfp_* *Defl rSI rTOIPT rCWP rkap tc vc SoC Arec Fr Ir *_cic2 *_US ownership affiliate)
* add exchange rates and other macro variables
merge n:1 year using ".\ER\US_NER_99_19",nogen keep(matched)
merge n:1 year coun_aim using ".\ER\RER_99_19",nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation peg_USD OECD EU)
drop if dlnRER==.
* calculate import intensity
gen imp_int=import_sum*NER_US/(vc*InputDefl*10)
winsor2 imp_int, trim replace
* calculate changes of price, quantity and marginal cost
gen price_RMB=value_year*NER_US/quant_year
gen price_US=value_year/quant_year
gen MC_RMB=price_RMB/Markup_DLWTLD
sort FRDM HS6 coun_aim year
by FRDM HS6 coun_aim: gen dlnquant=ln(quant_year)-ln(quant_year[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
by FRDM HS6 coun_aim: gen dlnMC=ln(MC_RMB)-ln(MC_RMB[_n-1]) if year==year[_n-1]+1
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value_year),prop
sort FRDM HS6 coun_aim year
by FRDM HS6 coun_aim: gen MS_lag=MS[_n-1] if year==year[_n-1]+1
* add monetary policy shocks
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)
merge m:1 year using ".\MPS\mpu\mpu_85_22",nogen keep(matched)
merge m:1 year using ".\MPS\lsap\lsap_91_19",nogen keep(matched)
merge m:1 year using ".\MPS\others\ea_99_19",nogen keep(matched)
merge m:1 year using ".\MPS\others\uk_98_15",nogen keep(matched)
merge m:1 year using ".\MPS\others\japan_99_20",nogen keep(matched)
* add other time series controls
* merge m:1 year using ".\control\china\pwt100_CN",nogen keep(matched)
merge m:1 year using ".\control\us\vix",nogen keep(matched) keepus(ave_vixcls)
merge m:1 year using ".\control\us\oil_price",nogen keep(matched) keepus(oilprice goilprice)
merge m:1 year using ".\control\us\oil_shock_year",nogen keep(matched)
* construct country exposures
gen value_year_US=value_year if coun_aim=="美国"
replace value_year_US=0 if value_year_US==.
bys FRDM year: egen export_sum_US=total(value_year_US) 
gen exposure_US=export_sum_US/export_sum
gen value_year_EU=value_year if EU==1
replace value_year_EU=0 if value_year_EU==.
bys FRDM year: egen export_sum_EU=total(value_year_EU) 
gen exposure_EU=export_sum_EU/export_sum
drop export_sum_* value_year_*
* construct group id
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
egen group_id=group(FRDM HS6 coun_aim process)
* drop outliers
winsor2 dlnprice dlnprice_USD dlnquant dlnMC, trim
xtset group_id year
format EN %30s
save sample_matched_exp,replace

*-------------------------------------------------------------------------------

* 4.2 Product-level matched sample, 2000-2007

cd "D:\Project E"
use "D:\Project D\HS6_exp_00-19",clear
* add exchange rates and other macro variables
merge n:1 year using ".\ER\US_NER_99_19",nogen keep(matched)
merge n:1 year coun_aim using ".\ER\RER_99_19.dta",nogen keep(matched) keepus(NER RER dlnRER dlnrgdp inflation peg_USD OECD EU)
drop if dlnRER==.
* calculate quantity changes
sort HS6 coun_aim year
by HS6 coun_aim: gen dlnquantity=ln(quantity)-ln(quantity[_n-1]) if year==year[_n-1]+1
* calculate price changes 
sort HS6 coun_aim year
gen price_RMB=value*NER_US/quant
gen price_US=value/quant
by HS6 coun_aim: gen dlnprice=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
by HS6 coun_aim: gen dlnprice_USD=ln(price_US)-ln(price_US[_n-1]) if year==year[_n-1]+1
drop if dlnprice==.
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value),prop
by HS6 coun_aim: gen MS_lag=MS[_n-1] if year==year[_n-1]+1
* add monetary policy shocks
cd "D:\Project E"
merge m:1 year using ".\MPS\brw\brw_94_21",nogen keep(matched)
merge m:1 year using ".\MPS\mpu\mpu_85_22",nogen keep(matched)
merge m:1 year using ".\MPS\lsap\lsap_91_19",nogen keep(matched)
* construct country exposures
bys year: egen export_sum=total(value)
gen value_US=value if coun_aim=="美国"
replace value_US=0 if value_US==.
bys year: egen export_sum_US=total(value_US) 
gen exposure_US=export_sum_US/export_sum
gen value_EU=value if EU==1
replace value_EU=0 if value_US==.
bys year: egen export_sum_EU=total(value_EU) 
gen exposure_EU=export_sum_EU/export_sum
* construct different periods
gen prezlb=1 if year<2008
replace prezlb =0 if prezlb==.
gen zlb=1 if year>=2008 & year<2016
replace zlb=0 if zlb==.
gen postzlb=1 if year>=2016
replace postzlb=0 if postzlb==.
* construct group id
gen HS2=substr(HS6,1,2)
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
egen group_id=group(HS6 coun_aim)
* drop outliers
winsor2 dlnprice, trim
winsor2 dlnprice_USD, trim
xtset group_id year
save sample_HS6,replace