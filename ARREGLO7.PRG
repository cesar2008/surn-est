clear


abase:= {}


Juntar( "\SUR\EST\" )
Juntar( "\SUR2\EST\" )
Juntar( "\SURN\EST\" )
Juntar( "\SURN2\EST\" )

select 1
use \sur\est\CLA exclusive
replace PASADO with " " all
set index to \sur\est\CLACOD

for i:=1 to len(abase)
	?
	? i, abase[i]
	r := row()
  select 2
  use (abase[i]) alias X shared
  dbgobottom()
  ?? lastrec()
  dbgotop()
  select CLA
  st := 0
  do while !X->(eof())
  	if dbseek(X->CODCLI)
  		CLA->PASADO := "1"
     endif
     @r,60 say ++st
  	skip 1 alias X
  enddo
next

select CLA
delete for PASADO<>"1" .and. year(fechmodif)<2012
delete for CODCLI=0
pack


quit

********************
procedure Juntar(dd)
********************

aa:=directory(dd+"FACA_*.DBF")
for i:=1 to len(aa)
	aadd( abase, dd+aa[i,1] )
next

aa:=directory(dd+"FACB_*.DBF")
for i:=1 to len(aa)
	aadd( abase, dd+aa[i,1] )
next

return
