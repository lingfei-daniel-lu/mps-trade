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

cd "D:\Project E"
use custom_0015\customs_00_15_exp,clear
collapse (sum) value quant=quantity, by(party_id HS6 HS4 HS2 year)
* calculate RMB value and price
merge n:1 year using ER\US_NER_99_19,nogen keep(matched)
gen price_RMB=value*NER_US/quant
gen price_USD=value/quant
egen group_id=group(party_id HS6)
xtset group_id year
by group_id: gen dlnprice_h_RMB=ln(price_RMB)-ln(L.price_RMB)
by group_id: gen dlnprice_h=ln(price_USD)-ln(L.price_USD)
bys party_id year: egen share_it=pc(value),prop
by party_id year: egen HS6_count=nvals(HS6)
sort group_id year
by group_id: gen share_bar=0.5*(share_it+L.share_it)
replace share_bar=share_it if share_bar==.
sort party_id year
by party_id year: egen dlnprice_RMB=sum(dlnprice_h_RMB*share_bar), missing
by party_id year: egen dlnprice=sum(dlnprice_h*share_bar), missing
collapse (sum) value, by(party_id year dlnprice_RMB dlnprice HS6_count)
save custom_0015\customs_00_15_exp_firm,replace

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
by party_id HS6 coun_aim: gen dlnprice=ln(price_USD)-ln(price_USD[_n-1]) if year==year[_n-1]+1
by party_id HS6 coun_aim: gen dlnprice_RMB=ln(price_RMB)-ln(price_RMB[_n-1]) if year==year[_n-1]+1
* calculate market shares
bys HS6 coun_aim year: egen MS=pc(value),prop
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
* drop special products
drop if HS2=="93"|HS2=="97"|HS2=="98"|HS2=="99"
* drop outliers
winsor2 dlnprice* dlnquant, trim
save samples\sample_customs_exp,replace

cd "D:\Project E"
use custom_0015\customs_00_15_exp_firm,replace
* add exchange rates and other macro variables
merge n:1 year using ER\US_NER_99_19,nogen keep(matched)
* add monetary policy shocks
merge m:1 year using MPS\brw\brw_94_22,nogen keep(matched)
drop if dlnprice==.
* construct firm id
egen firm_id=group(party_id)
xtset firm_id year
* drop outliers
winsor2 dlnprice*, replace trim
save samples\sample_customs_exp_firm,replace