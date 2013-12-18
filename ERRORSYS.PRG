**************************************
//
// Replacement error system for Clipper 5.0
// ERRORSYS.PRG
#include "error.ch"
*******************
// NOTE: This function CANNOT be renamed! Clipper appliations
// automatically call it during start up to set the default
// error handler.
*PROC ErrorSys()
ErrorBlock( {|eObj|DefError(eObj) } )
RETURN

*******************
FUNC DefError(eObj)

LOCAL i, cErrMessage, aPrompts:={ "Abortar" }
LOCAL nChoice

IF eObj:GenCode == EG_ZERODIV
	Logit(eObj)
  RETURN 0
ENDIF
IF eObj:GenCode==EG_OPEN .AND. eObj:GenCode==32 .AND. eObj:CanDefault
	NetErr(.T.)
  RETURN .F.
ENDIF
IF eObj:GenCode == EG_APPENDLOCK .AND. eObj:CanDefault
	NetErr(.T.)
  RETURN .F.
ENDIF
IF !EMPTY(eObj:OsCode)
	Logit(eObj)
  ALERT( ERRORMESSAGE(eObj) + ";DOS Error " + LTRIM(STR(eObj:osCode)), aPrompts )
  ErrorLevel(1)
  Break(eObj)
ELSE
	Logit(eObj)
  IF eObj:canRetry
  	AADD( aPrompts, "Reintentar" )
	ENDIF
  IF eObj:CanDefault
  	AADD( aPrompts, "Ignorar" )
	ENDIF
  nChoice := ALERT(ErrorMessage(eObj),aPrompts)
  IF aPrompts[nChoice] == "Abortar"
  	ErrorLevel(1)
  	Break(eObj)
  ELSEIF aPrompts[nChoice] == "Reintentar"
  	RETURN .T.
  ELSEIF aPrompts[nChoice] == "Ignorar"
  	RETURN .F.
  ELSE
  	ErrorLevel(1)
  	Break(eObj)
  ENDIF
ENDIF

RETURN .F.


*****************************
FUNC Logit(eObj)

LOCAL nProc:=3, lConsole
lConsole := SET(_SET_CONSOLE,.F.)
SET PRINTER TO ERROR.LOG ADDITIVE
SET PRINTER ON
?
? replicate("*",40)
? "ERROR ", DATE(), TIME(), SECONDS()
? "             Args ", IF(eOBJ:Args==NIL, "NIL", eObj:ARGS)
? "       CanDefault ", IF(eObj:CanDefault,"SI","NO")
? "         CanRetry ", IF(eObj:CanRetry,"SI","NO")
? "    CanSubstitute ", IF(eObj:CanSubstitute,"SI","NO")
? "            Cargo ", eObj:Cargo
? "      Descripci¢n ", eObj:Description
? "Nombre de archivo ", eObj:Filename
? "          GenCode ", STR(eObj:GenCode)
? "        Operaci¢n ", eObj:Operation
? "           OsCode ", STR(eObj:OsCode)
? "         Severity ", STR(eObj:Severity)
? "          SubCode ", STR(eObj:Severity)
? "          SubCode ", STR(eObj:SubCode)
? "        SubSystem ", eObj:SubSystem
? "            Tries ", STR(eObj:Tries)
? "           Alias()", alias()
? "        Indexkey()", indexkey()
? "           Puesto ", NETNOM()		//, _NPUESTO_
?
DO WHILE LEN(PROCNAME(nProc)) > 0
 	? "Llamado desde ", PADR(PROCNAME(nProc),30), "    Linea:", LTRIM(STR(PROCLINE(nProc)))
  ++nProc
ENDDO
?
cPanta:=savescreen()
i:=1
for y=1 to 25
	cAux:=""
	for x=1 to 80
  	cAux+=substr(cPanta,i,1)
     i += 2
  next
  ? cAux
next
SET PRINTER OFF
SET PRINTER TO
SET(_SET_CONSOLE,lConsole)

RETURN NIL



***********************

FUNC ERRORMESSAGE(eObj)

LOCAL cErrMessage := "ERROR. "
IF VALTYPE(eObj:SubSystem) == "C"
	cErrMessage += TRIM(eObj:SubSystem)
ENDIF
IF VALTYPE(eObj:SubCode) == "N"
  cErrMessage += "/"+ LTRIM(STR(eObj:SubCode))
ENDIF
IF VALTYPE(eObj:Description) == "C"
  cErrMessage += ";" + TRIM(eObj:Description)
ENDIF
IF LEN(eObj:FileName) > 0
  cErrMessage += ";"+ TRIM(eObj:FileName)
ENDIF
IF LEN(eObj:Operation) > 0
  cErrMessage += ";" + TRIM(eObj:Operation)
ENDIF

RETURN cErrMessage
