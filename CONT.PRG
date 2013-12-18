#include "EST.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"
#include "EDI.CH"
#include "COMMON.CH"

PARAMETERS parametro
LOCAL guardar, NUEVO, MODIFICABLE, modoaux, xedit
PRIVATE EDX, ATOT, aCPO
parametro := IF( parametro==NIL, "", "TRANSMITIR" )

verindex := .T.
SET TALK OFF
SET STATUS OFF
SET SCOREBOARD OFF
SET DELETED ON
SET DATE FRENCH
SET CONFIRM ON
SET(_SET_INTENSITY,.T.)

cCaminoSis := '\SISTEMAS\EST\'
cCaminoSis := ''

aaux := FDE()
DEQUIEN := aaux[1]

lPUBLICO := .F.
aux := GETE("_NPUESTO_")
lPUBLICO := ("PUBLICO"$aux)
nPUESTO := VAL( aux )
lPermiso := (!lPUBLICO)

RESTORE FROM EST.CFG ADDITIVE
aRosca := {"|","/","-","\"};   nRosca  := 1

IF FILE("TODOBIEN.EST")
	ERASE TODOBIEN.EST
ELSEIF lPUBLICO
	IF !"PENELOPE" $ VOLUMEN()
		IF PREGUNTA( 12, " ¨ ACTUALIZO LOS INDICES ?   [ S / N ]", "SsNn") $ "Ss"
			ERASEFILE( "*.NTX" )
     ENDIF
  ENDIF
ENDIF


PUBLIC acativa[4], atipoventa[2]
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

sTURNOS:=''; AEVAL( aturno, {|a|sTURNOS+=LEFT(a,1)} )

atipoventa[1] = "1-CONTADO         "
atipoventa[2] = "2-CUENTA CORRIENTE"

axrem  := FAARCH("REMUS.SEQ","CARGAR")

PUBLIC acopia  := { "ORIGINAL", "DUPLICADO", "TRIPLICADO" }
PUBLIC acopiaA := { "ORIGINAL", "TRIPLICADO", "DUPLICADO" }

*DO CARGAVEC WITH "LOCALID", 30
DO CARGAVEC WITH "LETRA", 11
DO CARGAVEC WITH "TARJETA", 30
FT_NUMLOCK(.T.)

DBCREATE("CONT",{{"ASIENTO","N",2,0},;
                 {"DCONC","C",30,0},{"DEBE","N",12,2},;
                 {"HCONC","C",30,0},{"HABER","N",12,2}} )

FBASES({"*..\DBFS"})
FBASES({"*CONT","*VARIOS","*SETIMP", "*ESTADOS"})
SELECT CON
ZAP
cDiscoCentral := ALLTRIM( VA->DISCOCENTR )
**********
PUBLIC UNI[29], DEC[9], CENT[9]

UNI[1] = "UN"
UNI[2] = "DOS"
UNI[3] = "TRES"
UNI[4] = "CUATRO"
UNI[5] = "CINCO"
UNI[6] = "SEIS"
UNI[7] = "SIETE"
UNI[8] = "OCHO"
UNI[9] = "NUEVE"
UNI[10] = "DIEZ"
UNI[11] = "ONCE"
UNI[12] = "DOCE"
UNI[13] = "TRECE"
UNI[14] = "CATORCE"
UNI[15] = "QUINCE"
UNI[16] = "DIECISEIS"
UNI[17] = "DIECISIETE"
UNI[18] = "DIECIOCHO"
UNI[19] = "DIECINUEVE"
UNI[20] = "VEINTE"
UNI[21] = "VEINTIUN"
UNI[22] = "VEINTIDOS"
UNI[23] = "VEINTITRES"
UNI[24] = "VEINTICUATRO"
UNI[25] = "VEINTICINCO"
UNI[26] = "VEINTISEIS"
UNI[27] = "VEINTISIETE"
UNI[28] = "VEINTIOCHO"
UNI[29] = "VEINTINUEVE"

DEC[3] = "TREINTA"
DEC[4] = "CUARENTA"
DEC[5] = "CINCUENTA"
DEC[6] = "SESENTA"
DEC[7] = "SETENTA"
DEC[8] = "OCHENTA"
DEC[9] = "NOVENTA"

CENT[1] = "CIENTO"
CENT[2] = "DOSCIENTOS"
CENT[3] = "TRESCIENTOS"
CENT[4] = "CUATROCIENTOS"
CENT[5] = "QUINIENTOS"
CENT[6] = "SEISCIENTOS"
CENT[7] = "SETECIENTOS"
CENT[8] = "OCHOCIENTOS"
CENT[9] = "NOVECIENTOS"
**********
asetprn := { 0, SPACE(50), SPACE(50) }
IF FILE( "_SETPRN.BL" )
	asetprn[1] := MEMOREAD( "_SETPRN.BL" )
	FOR i=2 TO BL_SETFIN
		asetprn[i] := MEMOLINE( asetprn[1], 99, i )
	NEXT i
	asetprn[1] = VAL(asetprn[1])
ENDIF
CLEAR
cBaseAux := XNAME('XAUX')




**************************
DESDE := HASTA := DATE()
aAsiento := ARRAY(8);	AFILL(aAsiento," ")
IF FILE( "ASIENTO.ARR" )
	aAsiento := STOA(MEMOREAD( "ASIENTO.ARR" ))
	DESDE := aAsiento[7]
	HASTA := aAsiento[8]
ENDIF
cLIVAC := padr(aAsiento[6],40,' ')

DO WHILE .T.
	CLEAR
	xmenu:=MENUDOWN({"     º   F10    º    F12   º  ESC   ",;
						  "       º          º    ver   º        ",;
						  " mueve º confirma º asientos º  sale  "})
	aed := NEWEDIT2( "ASIENTO",,.T. )
	aed[ED_MODE] = "MOSTRARTODO"
	aed[ED_I] := 1
	DO WHILE .T.
		FEDITAR2( aed, { K_F10, K_F12 } )
		IF aed[ED_UPDATE]
     	if EDNOM(aed) == "cLIVAC"
        	if !file(cLIVAC)
					MENSAJE( 0, 0, 10, .T., "NO ENCONTRADO !!!" )
           endif
        endif
			aed[ED_MODE] := "MOSTRAR"
		ELSEIF aed[ED_TECLA] == K_ESC
			EXIT
		ELSEIF aed[ED_TECLA] == K_F12
  		aaux := DIRECTORY("AS\*.TXT")
        IF LEN(aaux) == 0
				MENSAJE( 0, 0, 10, .T., "NO ENCONTRADO !!!" )
        ELSE
        	AEVAL( aaux, {|a,i| aaux[i]:=a[1]} )
				op = PP_SELEC(10, 25, LEN(aaux), 0, aaux, 1, "", "S", .T. )
           RECUPAN()
           IF LASTKEY() == K_ENTER
     			VERAS( "AS\"+aaux[op] )
           ENDIF
        ENDIF

		ELSEIF aed[ED_TECLA] == K_F10
			EXIT
		ENDIF
	ENDDO
	FEDITOR(aed,"SACAPAN")
	MENUDOWN(xmenu)

	IF aed[ED_TECLA] == K_ESC
  	EXIT
	ELSEIF aed[ED_TECLA] == K_F10
		aAsiento[6] := cLIVAC
		cLIVAC := alltrim(aAsiento[6])
		aAsiento[7] := DESDE
		aAsiento[8] := HASTA
		MEMOWRIT("ASIENTO.ARR",ATOS(aAsiento))
     ax := ARRAY(10); AFILL(ax,DATE())
  	IF aAsiento[1] == "S"
			A1( {DESDE,HASTA} )
     ENDIF
  	IF aAsiento[2] == "S"
			A2( {DESDE,HASTA} )
  	ENDIF
		IF aAsiento[3] == "S"
			A3( {DESDE,HASTA} )
  	ENDIF
		IF aAsiento[4] == "S"
			A4( {DESDE,HASTA} )
  	ENDIF

		cArch := space(8)
		do while empty(cArch)
			cArch := INGRVAL( 10, 20, "Nombre Arch.:", cArch, "XXXXXXX", "")
     enddo
		cArch := "AS\"+alltrim(cArch)+".txt"
		SET CONSOLE OFF
		SET ALTERNATE TO (cArch)
		SET ALTERNATE ON
		? DESDE, "-", HASTA
		?"============================= ============ ============"
		SELECT CON
		GO TOP
		nA := 0
		DO WHILE !EOF()
			if nA # CON->ASIENTO
  			?
           ?
           ?
     		? "  * * *  ASIENTO:",CON->ASIENTO, "  * * *"
           ?
     		nA := CON->ASIENTO
  		endif
			IF EMPTY(CON->HCONC)
				? CON->DCONC + STR(CON->DEBE)
  		ELSE
				? SPACE(13)+ CON->HCONC + STR(CON->HABER)
  		ENDIF
  		SKIP
		ENDDO
		?
     ?
     ? "---------------------------------------"
     ? "pasado desde"
*    ? "Fact.A",ax[1], "  Fact.B",ax[2], "   Z",ax[3], "  Remitos",ax[4]
     ? "Tarj-Posnet",ax[5]
     ? "Cta.Cte.", ax[6]
     ? "Deposit.Tarj", ax[7]
     ?
		SET ALTERNATE OFF
		SET ALTERNATE TO
		SET CONSOLE ON
     SET CURSOR ON
     VERAS(cArch)
	ENDIF
ENDDO
SAVE ALL LIKE VA->FECHA TO TODOBIEN.EST
SET COLOR TO W/N
SETCURSOR(SC_ON)
CLEAR

RETURN


************
FUNC ROSCA()
************
IF ++nRosca > 4
	nRosca := 1
ENDIF
@ 24,78 SAY aRosca[nRosca]

return .T.


************

FUNC VERAS(cArch)

************
LOCAL cPan:=SALVAPAN(0,0,24,79)
cAux := MEMOREAD(cArch)
set cursor on
MEMOEDIT(cAux)
MEMOWRIT(cArch,cAux)
IF UPPER(PREGUNTA( 12, " ¨ IMPRIMO ?   [ S / N ]", "SsNn")) == "S"
	type (cArch) to printer
ENDIF
RECUPAN()

RETURN NIL


**********

FUNC NFTOC

**********
PARAMETERS _dia, _mes, _anio

RETURN ( CHR(_anio) + CHR(_mes) + CHR(_dia) )
