//
// Agrega el campo NUMOPAG y
// cambia la relaci¢n de STR(CODPROV)+FTOC(FECHCC) por STR(CODPROV)+NUMOPAG
//
SET DATE BRITISH
CLEAR

select 1
USE CCC ALIAS CCC
replace NUMOPAG with strzero(recno(),6) FOR ROSCA().AND.empty(NUMOPAG)
INDEX ON STR(CCC->CODPROV)+FTOC(CCC->FECHCC) TO QQ

PASAR("COMPRAS")
PASAR("CCC2")
PASAR("CHEQUES")

return


*******************

FUNC PASAR( cBase )

******************
? cBase
select 2
use (cBase) alias X
nCant := lastrec()
aaux := dbstruct()
i=ascan(aaux,{|a|UPPER(a[1])=="NUMOPAG"})
if i==0
	aadd(aaux,{"NUMOPAG","C",6,0})
  dbcreate("QQ",aaux)
  select 2
  use qq alias X
  append from (cBase) FOR ROSCA()
  if nCant#lastrec()
  	? "no se pasaron todos los registros "+str(nCant,9),str(lastrec(),9)
     wait
  	return
  endif
  use
  ERASE (cBase+".dbf")
  RENAME qq.dbf to (cBase+".dbf")
* copy file qq.dbf to (cBase+".dbf")
endif
select 2
use (cBase) alias X

if ascan(aaux,{|a|UPPER(a[1])=="FECHCC"}) # 0
	select X
	GO TOP
	DO WHILE ROSCA() .AND. !X->(EOF())
		IF CCC->(DBSEEK(STR(X->CODPROV)+FTOC(X->FECHCC)))
  		X->NUMOPAG := CCC->NUMOPAG
  	ENDIF
		SKIP 1 ALIAS X
	ENDDO
endif

return

************
FUNC ROSCA()
************
@ 24,70 SAY RECNO() PICT "######"

return .T.
