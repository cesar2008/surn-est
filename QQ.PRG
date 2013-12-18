use FACA_8
*copy to qq for TEXENTO<>0
replace TEXENTO with 0 for TEXENTO<>0


quit

use TICKETS
copy to \surn2\min\tickets for YEAR(FECHA)=2010

use TICKETS2
copy to \surn2\min\tickets2 for YEAR(FECHA)=2010

