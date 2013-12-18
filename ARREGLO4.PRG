//
// Unifica los Proveedores de la Estacion y Compras Varias
//
SET DATE BRITISH
CLEAR

select 1
use PROVEE aliAS PRV
index on PRV->CODPROV to QQ
dbgobottom()
nUltimo:=PRV->CODPROV
aaux:=dbstruct()
if ascan(aaux,{|a|a[1]=="CCC"})==0
	aadd(aaux,{"CCC","C",1,0})
	dbcreate("QQ",aaux)
	select 1
	use QQ
	append from PROVEE
  dbclosearea()
  copy file QQ.DBF to PROVEE.DBF
endif

select 1
use PROVEEV aliAS PRV
aaux:=dbstruct()
if ascan(aaux,{|a|a[1]=="CODPROV2"})==0
	aadd(aaux,{"CODPROV2","N",4,0})
	dbcreate("QQ",aaux)
	select 1
	use QQ
	append from PROVEEV
  dbclosearea()
  copy file QQ.DBF to PROVEEV.DBF
endif
select 1
use PROVEEV aliAS PRV
replace PRV->CODPROV2 with PRV->CODPROV all
replace PRV->CODPROV with PRV->CODPROV2+nUltimo all
index on PRV->CODPROV2 to QQ
select 2
use COMPRASV alias CV
do while ROSCA().and.!CV->(eof())
	if PRV->(dbseek(CV->CODPROV))
  	CV->CODPROV := PRV->CODPROV
  endif
	skip 1
enddo

select 1
use PROVEE aliAS PRV
replace PRV->CCC with "S" all
append from PROVEEV


return

************
FUNC ROSCA()
************
@ 24,70 SAY RECNO() PICT "######"

return .T.
