cd "D:\Project E\Rauch classification"

import excel "HS1996 to SITC2 Conversion and Correlation Tables.xls", sheet("Conversion Table") cellrange(D7:E5138) firstrow clear
drop if HS96==""
gen sitc2_T4=substr(S2,1,4)
gen sitc2_T3=substr(S2,1,3)
save HS1996-SITC2,replace

use output\Rauch_classification_revised,clear
tostring sitc2_T4,replace
replace sitc2_T4 = "00" + sitc2_T4 if length(sitc2_T4) == 2
replace sitc2_T4 = "0" + sitc2_T4 if length(sitc2_T4) == 3
gen sitc2_T3=substr(sitc2_T4,1,3)
save Rauch_classification_T4,replace

use output\Rauch_classification_revised_T3,clear
tostring sitc2_T3,replace
replace sitc2_T3 = "00" + sitc2_T3 if length(sitc2_T3) == 1
replace sitc2_T3 = "0" + sitc2_T3 if length(sitc2_T3) == 2
save Rauch_classification_T3,replace

cd "D:\Project E\Rauch classification"
use HS1996-SITC2,clear
merge n:1 sitc2_T4 using Rauch_classification_T4, nogen keep(matched master)
merge n:1 sitc2_T3 using Rauch_classification_T3, nogen keep(matched master) update
rename (HS96)(HS6)
gen Rauch_con=1 if con=="w"
replace Rauch_con=0 if con!="w"
gen Rauch_lib=1 if lib=="w"
replace Rauch_lib=0 if lib!="w"
gen Rauch_con_r=1 if con=="w" | con=="r"
replace Rauch_con_r=0 if Rauch_con_r==.
gen Rauch_lib_r=1 if lib=="w" | lib=="r"
replace Rauch_lib_r=0 if Rauch_lib_r==. 
save HS6_Rauch,replace