#include "EST.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"
#include "COMMON.CH"

parameters parametro
local guardar, NUEVO, MODIFICABLE, modoaux, xedit
private EDX, ATOT, aCPO
DEFAULT parametro TO ""
cDirAno := ""

SET TALK OFF
SET STATUS OFF
SET SCOREBOARD OFF
SET DELETED ON
SET DATE FRENCH
SET CONFIRM ON
SET(_SET_INTENSITY,.T.)
SET EPOCH TO (year(date())-50)

aaux := FDE()
DEQUIEN := aaux[1]

lPUBLICO := .F.
aux := GETE("_NPUESTO_")
lPUBLICO := ("PUBLICO"$aux)
_NPUESTO_ := VAL( aux )
lPermiso := (!lPUBLICO)
verindex := .F.

UT_SISTEMA   := "\"+LEFT( CURDIR(), RAT("\",CURDIR())-1 )
IF FILE("EST.CFG")
	RESTORE FROM EST.CFG ADDITIVE
ENDIF
cCaminoSis := UT_SISTEMA + '\EST\'
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


PUBLIC acativa[4]
acativa[1] = "CF -CONS.FINAL    "
acativa[2] = "RI -RESP.INSCR.   "
acativa[3] = "RNI-RESP.NO INSCR."
acativa[4] = "EX -EXENTO        "

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
DESDE := HASTA := DATE()

sTURNOS:=''; AEVAL( aturno, {|a|sTURNOS+=LEFT(a,1)} )

public atipoventa:={"1-CONTADO         ",;
							"2-CUENTA CORRIENTE",;
							"3-COMPLEMENTARIA  ",;
							"4-VENTA MAYORISTA " }

axrem  := FAARCH("REMUS.SEQ","CARGAR")

PUBLIC acopia  := { "ORIGINAL", "DUPLICADO", "TRIPLICADO" }
PUBLIC acopiaA := { "ORIGINAL", "TRIPLICADO", "DUPLICADO" }

DO CARGAVEC WITH "LOCALID", 99
DO CARGAVEC WITH "LETRA", 11
DO CARGAVEC WITH "TARJETA", 30
DO CARGAVEC WITH "RUBRO", 30
FT_NUMLOCK(.T.)

FBASES({"*DBFS"})
FBASES({"*VARIOS","*SETIMP", "*ESTADOS","*CODPOS"})
cDiscoCentral := ALLTRIM( VA->DISCOCENTR )
cSTOCKACT := "STOCKACT"+alltrim(VA->SUCURSAL)
cSTOCKINI := "STOCKINI"+alltrim(VA->SUCURSAL)
cFECHAI   := "FECHA"+alltrim(VA->SUCURSAL)
aedits := TBCOLEDIT("CARGAR",,,,"EDITS.EST" )

asetprn := { 0, SPACE(50), SPACE(50) }
IF FILE( "_SETPRN.BL" )
	asetprn[1] := MEMOREAD( "_SETPRN.BL" )
	FOR i=2 TO BL_SETFIN
		asetprn[i] := MEMOLINE( asetprn[1], 99, i )
	NEXT i
	asetprn[1] = VAL(asetprn[1])
ENDIF
select EST
IF EMPTY( NETNOM() )
	LOCATE FOR EMPTY(EST->NOMPUESTO)
ELSE
	LOCATE FOR NETNOM() $ EST->NOMPUESTO
ENDIF
IF !FOUND() .OR. LASTREC() == 0
	ADD_REC()
	FRLOCK()
	EST->NOMPUESTO := NETNOM()
ENDIF

IF parametro == "T2A1"
	DO T2A1
ELSEIF parametro == "T1A2"
	DO T1A2
ELSE
	cDir := left(cdow(date()),4)
  cDest:="C:\COPIASEM"
	if len(directory( cDest, "D" )) == 0
 		n := FT_MKDIR( cDest )
  endif
  cDest:="C:\COPIASEM\"+cDir
	if len(directory( cDest, "D" )) == 0
 		n := FT_MKDIR( cDest )
  endif
	if len(directory( cDest, "D" )) == 0
		MENSAJE(0,0,10,.T.,"NO EXISTE EL DIRECTORIO !" )
	else
     aaux:=directory(cDest+"\*.dbf")
     asort(aaux,{|x,y|x[3]>y[3]})
		MENSAJE(99,99, 0, .F., "AGUARDE..." )
* 	aBase:={{"FACA","FA"},{"FACB","FB"},{"REM","RE"},{"TICKETS","TI"}}
  	aBase:={{"FACA_3","FA"},{"FACB_3","FB"},{"FACA_4","FA"},{"FACB_4","FB"},{"REM","RE"},{"TICKETS","TI"}}
  	for b=1 to len(aBase)
     	lAux:=.T.
     	if len(aaux)#0
     		i:=ascan(aaux,{|a|a+".DBF"==aBase[b,1]})
           if i==0
           	lAux:=.T.
           else
     			lAux:=( aaux[i,3]#date() )
           endif
        endif
     	if lAux
  			@24,70 say aBase[b,1]
  			XF:=aBase[b,2];  XF2:=XF+"2"
				FBASES( {aBase[b,1], strtran(aBase[b,1],"_","2_") }, .T. )
  			select (XF)
  			set order to forder({"FECHA"})
  			dbseek( ftoc(date()-7), .T. )
  			select (XF2)
     		nAux := (XF)->NUMFAC
  			dbseek( nAux, .T. )
  			copy to (cDest+"\"+aBase[b,1]+"2") rest for ROSCA()
  			select (XF)
  			copy to (cDest+"\"+aBase[b,1]) rest for ROSCA()
    		endif
  	next b
  	RECUPAN()
  endif
ENDIF
SET COLOR TO W/N
SETCURSOR(SC_ON)
CLEAR

RETURN
