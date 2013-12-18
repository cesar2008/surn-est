//
// Agrega el campo ID_CCV y
// cambia la relaci¢n de STR(CODCLI)+FTOC(FECHCIERRE) por STR(CODCLI)+ID_CCV
//
SET DATE BRITISH
CLEAR

select 1
USE CCV ALIAS CCV
replace ID_CCV with "CCV"+F_ID() FOR ROSCA().AND.empty(ID_CCV)
INDEX ON STR(CCV->CODCLI)+FTOC(CCV->FECHCIERRE) TO QQ

PASAR("FACACC")
PASAR("FACBCC")
PASAR("CCV2")
PASAR("REM")
PASAR("CHEQUES")
PASAR("TARJETAS")

return


*******************

FUNC PASAR( cBase )

******************
? cBase
select 2
use (cBase) alias X
nCant := lastrec()
aaux := dbstruct()
i=ascan(aaux,{|a|UPPER(a[1])=="ID_CCV"})
if i==0
	aadd(aaux,{"ID_CCV","C",12,0})
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

if ascan(aaux,{|a|UPPER(a[1])=="FECHCIERRE"}) # 0
	select X
	GO TOP
	DO WHILE ROSCA() .AND. !X->(EOF())
		IF CCV->(DBSEEK(STR(X->CODCLI)+FTOC(X->FECHCIERRE)))
  		X->ID_CCV := CCV->ID_CCV
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