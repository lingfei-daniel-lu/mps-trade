* US country code conversion
cd "D:\Project E\ER"
use "D:\Project E\US_import\US_country_code\US_country_code_ISO3",clear
keep alpha3code cty_code
rename alpha3code countrycode
destring cty_code, replace
save country_code_index,replace

*-------------------------------------------------------------------------------
* IMF CPI data
cd "D:\Project E\ER"
import excel International_Financial_Statistics_CPI_1980_2023, firstrow clear
rename (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS) (countrycode cpi1980 cpi1981 cpi1982 cpi1983 cpi1984 cpi1985 cpi1986 cpi1987 cpi1988 cpi1989 cpi1990 cpi1991 cpi1992 cpi1993 cpi1994 cpi1995 cpi1996 cpi1997 cpi1998 cpi1999 cpi2000 cpi2001 cpi2002 cpi2003 cpi2004 cpi2005 cpi2006 cpi2007 cpi2008 cpi2009 cpi2010 cpi2011 cpi2012 cpi2013 cpi2014 cpi2015 cpi2016 cpi2017 cpi2018 cpi2019 cpi2020 cpi2021 cpi2022 cpi2023)
reshape long cpi, i(country) j(year)
bys country: egen year_count=count(cpi)
save CPI_80_23,replace

*-------------------------------------------------------------------------------
cd "D:\Project E\ER"
use pwt1001,clear
keep if year>=1980 & year<=2019
keep countrycode country currency_unit year xr pl_c rgdpna
merge n:1 countrycode year using CPI_80_23,nogen
merge n:1 countrycode country currency_unit using "D:\Project C\PWT10.0\pwt_country_name",nogen
replace cpi=100 if year==2010 & coun_aim=="台湾省"
sort countrycode year
forv i=1980/2019{
	global cpi_TWN_`i'=pl_c[`i'+6101]/pl_c[8111]*100
	replace cpi=${cpi_TWN_`i'} if year==`i' & coun_aim=="台湾省"
}
drop if xr==.
save PWT1001_80_19,replace

cd "D:\Project E\ER"
use PWT1001_80_19,clear
* Bilateral nominal exchange rate relative to RMB at the same year
keep if year>=1989
gen NER=3.7651083/xr if year==1989
forv i=1990/2019{
	global xr_CN_`i'=xr[`i'-969]
	replace NER=${xr_CN_`i'}/xr if year==`i'
}
label var NER "Nominal exchange rate in terms of RMB at the same year"
* Bilateral real exchange rate = NER*foreign CPI/Chinese CPI
gen RER=NER*cpi/39.24247 if year==1989
forv i=1990/2019{
	global cpi_CN_`i'=cpi[`i'-969]
	replace RER=NER*cpi/${cpi_CN_`i'} if year==`i'
}
label var RER "Real exchange rate to China price at the same year"
sort coun_aim year
by coun_aim: gen dlnNER= ln(NER)-ln(NER[_n-1]) if year==year[_n-1]+1
by coun_aim: gen dlnRER= ln(RER)-ln(RER[_n-1]) if year==year[_n-1]+1
by coun_aim: gen dlnrgdp=ln(rgdpna)-ln(rgdpna[_n-1]) if year==year[_n-1]+1
by coun_aim: gen inflation=ln(cpi)-ln(cpi[_n-1]) if year==year[_n-1]+1
cd "D:\Project E\ER"
save RER_89_19.dta,replace