cd "D:\Project E\BLS_US"

use price_index_import_FRED.dta, clear
keep ym year month ln_pim dln_pim
merge 1:1 year month using "D:\Project E\MPS\monthly\brw_month",nogen keep(matched)
merge 1:1 year month using dollar_index_month_fed,nogen keep(matched)
merge 1:1 year month using CPI_month,nogen keep(matched)
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