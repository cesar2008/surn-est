clear

nF:=0
aaux:=directory("*.DBF")
for b=1 to len(aaux)
	use (aaux[b,1])
	aa:=dbstruct()
  i:=ascan(aa,{|a,i|a[1]=="CODPROV"})
  if i#0
  	if aa[i,3]#3
			FREE(aaux[b,1],aa,i)
     endif
  endif
next b

QUIT


****************
FUNC FREE(cBase,aa,i)
****************
@nF,0 say cBase
*nAux:=lastrec()
*REPLACE CODPROV WITH if( val(CODPROV)==0, "", strzero(val(CODPROV),3) ) FOR XVER()
nAux:=lastrec()

aa[i,3]:=3
dbcreate("XTEMP",aa)
use XTEMP
append from (cBase) for XVER()
dbclosearea()
ferase(cBase)
rename XTEMP.DBF to (cBase)
use (cBase)
++nF
return

***********
FUNC XVER()
***********
@nF,20 say --nAux
return .T.
