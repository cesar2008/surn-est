#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

parameters dFecha, lCREAR
DEFAULT lCREAR TO .F.

cAno := strzero(year(dFecha),4)
cMes := strzero(month(dFecha),2)
cDir := "\"+curdir()
if !lCREAR
	cDest := cDir+"\"+cAno+"\"+cMes
  return cDest
endif

MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
cAux:=memoread("CB.ARR",0)
aBase:=stoa(cAux)
for b=1 to len(aBase)
	cDir:=iif("TICKETS"$aBase[b],"..\MIN\","")
	n := 0
	if len(directory( cDir+cAno, "D" )) == 0
 		n := FT_MKDIR( cDir+cAno )
	endif
	if n == 0
		cDest := cDir+cAno+"\"+cMes+"\"
		if len(directory( cDest, "D" )) == 0
 			n := FT_MKDIR( cDest )
		endif
	endif
	if !file(cDest+aBase[b])
  	CREAR(aBase[b],cDest)
  endif
next b
RECUPAN()

return if(n==0,cDest,"")


*************************

STATIC FUNC CREAR( cCual, cDest )

*************************

if !file( cDest+cCual+".DBF" )
	@ 24,70 SAY PADR(cCual,9," ")
  if ".DBF"$cCual
		use (cDir+cCual) new
		copy stru to (cDest+cCual)
  	use
  else
  	copy file (cCual) to (cDest+cCual)
  endif
endif

return .T.


**************

FUNC FCAMINOS(dDesde,dHasta)

**************
LOCAL aaux:={}, aa, mm, cAux

aa:=YEAR(dDesde)
mm:=MONTH(dDesde)
DO WHILE STRZERO(aa,4)+STRZERO(mm,2) <= STRZERO(YEAR(dHasta),4)+STRZERO(MONTH(dHasta),2)
  cAux := "\"+ CURDIR() +"\"+ STRZERO(aa,4) +"\"+ STRZERO(mm,2)
	if file(cAux+"\*.DBF")
  	AADD( aaux, cAux )
  endif
  IF ++mm > 12
  	++aa
     mm := 1
  ENDIF
ENDDO

RETURN aaux
