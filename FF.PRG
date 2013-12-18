#include "EST.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"
#include "COMMON.CH"

parameters parametro
local guardar, NUEVO, MODIFICABLE, modoaux, xedit
private EDX, ATOT, aCPO
DEFAULT parametro TO ""
public cDirAno := ""

SET TALK OFF
SET STATUS OFF
SET SCOREBOARD OFF
SET DELETED ON
SET DATE FRENCH
SET CONFIRM ON
SET(_SET_INTENSITY,.T.)
SET EPOCH TO (year(date())-50)
if file("\SALIR.TMP");  quit;  endif

aaux := FDE()
DEQUIEN := aaux[1]


lPUBLICO := .F.
ACTUAL_SUC := ""
cCOMPR_PERMIT := "FA FB TI RE"

cAux := gete("_NPUESTO_")
lPUBLICO := ("PUBLICO"$cAux)
lPUBLICO := .T.
_NPUESTO_ := val(cAux)
lPermiso := (!lPUBLICO)

i:=at("PV:",cAux)		// Punto de Venta
if i#0
	ACTUAL_SUC := str(val(substr(cAux,i+3)),1)
endif
i:=at("CP:",cAux)		// Comprobantes Permitidos
if i#0
	cCOMPR_PERMIT := substr(cAux,i+3)
	i:=at("//",cCOMPR_PERMIT)
	if i#0;  cCOMPR_PERMIT := left(cCOMPR_PERMIT,i);  endif
endif
public cDirAno := ""
public cSUCURSAL:=ACTUAL_SUC
verindex := .F.



*UT_SISTEMA   := "\"+LEFT( CURDIR(), RAT("\",CURDIR())-1 )
IF FILE("EST.CFG")
	RESTORE FROM EST.CFG ADDITIVE
ENDIF
*cCaminoSis := UT_SISTEMA + '\EST\'
aSisCfg := {"","",""}
IF FILE("..\MINCFG.ARR")
	aSisCfg := STOA(MEMOREAD("..\MINCFG.ARR"))
ENDIF

IF FILE("TODOBIEN.EST")
	ERASE TODOBIEN.EST
ELSEIF lPUBLICO
	IF !"PENELOPE" $ VOLUMEN()
*		IF PREGUNTA( 12, " ¨ ACTUALIZO LOS INDICES ?   [ S / N ]", "SsNn") $ "Ss"
*			ERASEFILE( "*.NTX" )
*    ENDIF
  ENDIF
ENDIF


PUBLIC acativa[5], atipoventa[3], aCondVta
acativa[1] = "CF -CONS.FINAL    "
acativa[2] = "RI -RESP.INSCR.   "
acativa[3] = "RNI-RESP.NO INSCR."
acativa[4] = "EX -EXENTO        "
acativa[5] = "RM -RESP.MONOTRIB."

atipoventa[1] = "1-CONTADO         "
atipoventa[2] = "2-CUENTA CORRIENTE"
atipoventa[3] = "3-COMPLEMENTARIA  "

aCondVta:={"1-Contado","2-7 d¡as Fecha Fact","3-10 d¡as Fecha Fact","4-30 d¡as Fecha Fact"}

aturno := { "1-TURNO 1  ",;
				 "2-TURNO 2  ",;
			  	 "3-TURNO 3  ",;
				 "4-TURNO 4  ",;
				 "5-TURNO 5  ",;
				 "6-TURNO 6  ",;
				 "7-TURNO 7  ",;
				 "8-TURNO 8  ",;
				 "9-TURNO 9  ",;
				 ":-TURNO 10 ",;
				 "E-ESTACION ",;
				 "S-SERVICIOS"  }
sTURNOS:=''; AEVAL( aturno, {|a|sTURNOS+=LEFT(a,1)} )

DESDE := HASTA := DATE()

axrem  := FAARCH("REMUS.SEQ","CARGAR")

PUBLIC acopia  := { "ORIGINAL", "DUPLICADO", "TRIPLICADO" }
PUBLIC acopiaA := { "ORIGINAL", "TRIPLICADO", "DUPLICADO" }

DO CARGAVEC WITH "LOCALID", 99
DO CARGAVEC WITH "LETRA", 11
DO CARGAVEC WITH "TARJETA", 30
DO CARGAVEC WITH "RUBRO", 30
FT_NUMLOCK(.T.)

FBASES({"*DBFS"})
FBASES({"*VARIOS","*SETIMP", "*ESTADOS","*EMPLEADO"})
cDiscoCentral := ALLTRIM( VA->DISCOCENTR )
aedits := TBCOLEDIT("CARGAR",,,,"EDITS.EST" )

asetprn := { 0, SPACE(50), SPACE(50) }
IF FILE( "_SETPRN.BL" )
	asetprn[1] := MEMOREAD( "_SETPRN.BL" )
	for i=2 to BL_SETFIN
		asetprn[i] := MEMOLINE( asetprn[1], 99, i )
	next i
	asetprn[1] = VAL(asetprn[1])
ENDIF
select EST
if empty( NETNOM() )
	locate for empty(EST->NOMPUESTO)
else
	locate for left(NETNOM(),len(EST->NOMPUESTO))  $ EST->NOMPUESTO
endif
if !found() .or. lastrec() == 0
	ADD_REC()
	frlock()
	EST->NOMPUESTO := NETNOM()
endif

*if CLAVEMP()
	DO FX
*endif

SAVE ALL LIKE VA->FECHA TO TODOBIEN.EST
SET COLOR TO W/N
SETCURSOR(SC_ON)
CLEAR

return
