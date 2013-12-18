#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"
#include "TB.CH"
#include "COMMON.CH"

set talk off
set status off
set scoreboard off
set deleted on
set date french
set confirm on
set epoch to (year(date())-50)

EXTERNAL Clear_gets
PARAMETERS cParam

*::::::::::::::::::::::::::::::::::::::::
*: Inicializaci¢n de Variables Especiales
*::::::::::::::::::::::::::::::::::::::::
public cDirAno := ""

aBol:={ "FACA", "FACB" }

*** leer seteo de impresora
asetprn := { 0, SPACE(50), SPACE(50) }
if file( "_SETPRN.BL" )
	asetprn[1] := MEMOREAD( "_SETPRN.BL" )
	for i=2 to BL_SETFIN
		asetprn[i] := MEMOLINE( asetprn[1], 99, i )
	next i
	asetprn[1] = val(asetprn[1])
endif
DO CARGAVEC WITH "LETRA", 11
DO CARGAVEC WITH "GASTO", 50
DO CARGAVEC WITH "BANCOCTA", 5

*::::::::::::::::::::::::::::::::::::::::::::::::::
* Inicializaci¢n de Variables y Arrays del Sistema
*::::::::::::::::::::::::::::::::::::::::::::::::::
STORE .F. TO HUBOCAMBIOS, ESTAIMPRESO, ANULADA, PROCESO
XF = CHR(27) +" "+ CHR(26)

menuno:={;
	{"Productos/Stock þ",  "Clientes þ       " },;
	{"Listados þ       ",  "Facturaci¢n      " },;
	{"",                   "Z"                 },;
	{"Planillas        ",  "Cobranzas        " },;
	{"Servicios þ      ",  ""                  },;
	{"Ajustes          ",  "Proveedores þ    " },;
	{"Tarjetas         ",  "Compras          " },;
	{"Posnet           ",  "Compras Varias   " },;
	{"Cheques          ",  "Pagos þ          " },;
	{"Copres           ",  ""                  },;
	{"Caja Chica       ",  ""                  },;
	{""                 ,  "Utilidades þ     " },;
	{"Caja             ",  "Salida           " }}

for y=1 to len(menuno)
	aeval(menuno[y],{|a,x| menuno[y,x]:=strtran(a,"þ",+CHR(26)) } )
	aeval(menuno[y],{|a,x| if(a=="",,menuno[y,x]:=justif(a,len(menuno[1,1]),"="))} )
next

public acativa[5], atipoventa[3], aCondVta
acativa[1] = "CF -CONS.FINAL    "
acativa[2] = "RI -RESP.INSCR.   "
acativa[3] = "RNI-RESP.NO INSCR."
acativa[4] = "EX -EXENTO        "
acativa[5] = "RM -RESP.MONOTRIB."

atipoventa[1] = "1-CONTADO         "
atipoventa[2] = "2-CUENTA CORRIENTE"
atipoventa[3] = "3-COMPLEMENTO     "

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
				 ";-TURNO 11 ",;
				 "<-TURNO 12 ",;
				 "E-ESTACION ",;
				 "S-SERVICIOS"  }
sTURNOS:='';  AEVAL( aturno, {|a|sTURNOS+=LEFT(a,1)} )

acopia := { "ORIGINAL", "DUPLICADO", "TRIPLICADO" }

aestado:= {"CAR-CARTERA   ",;
				"DEP-DEPOSITADO",;
				"PRE-PRESENTADO",;
				"COB-COBRADO   ",;
				"END-ENDOSO    " }

aTipoLiq := {"Q-Quincenal","M-Mensual"}

store "" to Buscado, Buscar
PRIHOJA      := 0
UT_largo     := 71
UT_clave     := "732"
UT_FALTANTE  := ""
UT_VALES     := ""
UT_GASTOS    := ""
UT_TURCONARR := sTURNOS
UT_SISTEMA   := "\"+LEFT( CURDIR(), RAT("\",CURDIR())-1 )
UT_CLAVECER  := "$$$"

lPUBLICO := .F.
ACTUAL_SUC := ""
cCOMPR_PERMIT := "FA FB TI RE"

cAux := gete("_NPUESTO_")
lPUBLICO  := ("PUBLICO"$cAux)
_NPUESTO_ := val(cAux)
lPermiso  := (!lPUBLICO)

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
aaux:=directory("..\SUC_SERV.*")
SUC_SERV := ACTUAL_SUC
if len(aaux)>0
	SUC_SERV  := substr(aaux[1,1],10)
endif
verindex := .F.


FESCOMBUST := FTIPOIMPINT := " "
STORE 0 TO FNETOCOMPRA, FPRECBASE, FIMPINT2, FIMPINT, FREGART, FPRECCOMPRA, NGRUPO, NUNXCAJA, FPRECVENTA, NRUBRO, NCONIMPINT, FRECARGO
STORE 0 TO TOTAL, SUBTOT1, SUBTOT2, DESCUENTO, FCODPROD

if file("EST.CFG")
	RESTORE FROM EST.CFG ADDITIVE
endif
if cParam # NIL
	UT_SISTEMA := PADR(UT_SISTEMA,60," ")
	@0,0 SAY "UT_SISTEMA ('\EST\' se le agrega solo):" GET UT_SISTEMA
  READ
	UT_SISTEMA := ALLTRIM(UT_SISTEMA)
endif
cCaminoSis := UT_SISTEMA + '\EST\'

aSisCfg := {"","",""}
if file("..\MINCFG.ARR")
	aSisCfg := STOA(MEMOREAD("..\MINCFG.ARR"))
endif

***
* Abro las Bases
***
if file("TODOBIEN.EST")
	ERASE TODOBIEN.EST
else
	*	ERASEFILE( "*.NTX" )
endif

CLEAR
SET EXCLUSIVE OFF

DO CARGAVEC WITH "RUBRO", 30
DO CARGAVEC WITH "CATEG", 10
DO CARGAVEC WITH "BANCO", 99
DO CARGAVEC WITH "TARJETA", 30
DO CARGAVEC WITH "LOCALID", 99
*DO CARGAVEC WITH "CONC", 50
DO CARGAVEC WITH "OPERAC", 50

FBASES({"*DBFS"})
IF !FILE( "ESTADOS.DBF" )
	CREARBASE( "ESTADOS.DBF", "DISCOAUX C 2", "IMPRESORA N 1", "CTRLSTOCK C 1","SALIDA C 3", "NOMPUESTO C 15", "TIPOIMPR C 10","CODEMP C 3","NIVEL N 1","LARGOHOJA N 3","PORTFISCAL N 1 0"  )
ENDIF
SET EXCLUSIVE OFF
FBASES( {"*ESTADOS"} )
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
if EST->LARGOHOJA==0;  frlock();  EST->LARGOHOJA:=UT_largo;  dbunlock();  endif
FTECLAS("INI")

FBASES( {"*VARIOS", "*PROD", "*GRUPO", "*CLIENTES", "*EMPLEADO","*CODPOS" } )
FBASES( {"*SETIMP","*FERIADOS","*PLANCTA"})
cDiscoCentral := ALLTRIM( VA->DISCOCENTR )
__arranco = .F.

STORE VA->FECHA TO DESDE, HASTA

******************** PUBLICACION DE CAMPOS **********************
axrem  := FAARCH("REMUS.SEQ","CARGAR")
aordfac := STOA( MEMOREAD("ORDFAC.SEQ") )

FBASES( { "PROVEE" } )
** Clientes:
select CL
FOR i=1 TO FCOUNT()
	campo = FIELD(i)
	M->&campo := CAMPOVACIO( FIELD(i) )
NEXT i

** Proveedores:
seleCT PRV
FOR i=1 TO FCOUNT()
	campo = FIELD(i)
	M->&campo = CAMPOVACIO( FIELD(i) )
NEXT i

** Stock/Inventario

** Facturaci¢n:
M->CODCLI = 0
M->FECHA = VA->FECHA
M->FECHVENC = CTOD("")
M->PIVA1 = VA->PIVA1
M->PIVA2 = VA->PIVA2
M->NUMFAC = 0
M->RAZONSOC = SPACE(LEN(CL->RAzonsoc))
M->TURNOVENTA = 2
M->NUMFAC = 0

TIPOFACTURA = "A"
XBASE = "FA"
XBASE2 = "FA2"
NUEVO = .F.


aedits := TBCOLEDIT("CARGAR",,,,"EDITS.EST" )

STORE 0 TO M->TPRECBASE, M->PORCDESC, M->DESCUENTO, M->SUBTOTAL,;
M->TIMPINT, M->TIVA1, M->TIVA2, M->TOTAL, M->PIVA1, M->PIVA2
M->TIPOVENTA = "2"
M->FECHVENC  = VA->FECHA
M->NUMFAC   := 0
M->TIPOFAC  := "A"
M->TIPOPROV := "E"

*****************************************************************

***
*
* C O M I E N Z O     D E     P R O C E S O
*
***
SETCOLOR(C_FONDO)

aaux := FDE()
DEQUIEN := aaux[1]
IF !VERIFICAR( aaux[2] )
	*	QUIT
ENDIF
DEQUIEN := aaux[1]

FT_NUMLOCK(.T.)
SET KEY K_ALT_H TO  VERBASES()
SET KEY K_INS TO INSTOGGLE()

CLEAR

ym1 := 5
xm1 := 20

opc = { 1, 0, 0 }
DO WHILE .T.
	DISPBEGIN()
	LOGO(.T., " MENU PRINCIPAL " )
MENUDOWN({ "  <+>  º      ENTER       ",;
				"       º                  ",;
				" mueve º confirma entrada " })
	SET(_SET_INTENSITY, .T. )
	SETCURSOR(SC_OFF)
  DISPEND()
	
  opc := FMENU2( ym1, xm1, menuno, opc[1], 5, {C_MENUDN1,C_MENUDN2}, {|k|k==K_CTRL_F1} )
	ym2 := opc[2]
	xm2 := opc[3]
  SETCOLOR(C_MENU)
	
	IF opc[5] == K_CTRL_F1
		DO CER
	
	***
	*PRODUCTOS
	***
	ELSEIF "Stock" $ opc[4]
		DO PROD
		
		***
		*LUBRICENTRO
		***
	ELSEIF "Servicio" $ opc[4]
		op = MENUFLASH( ym2, xm2, 1, .F., "",  "Lubricentro","Lavadero" )
     if op==1
			DO LUB
     elseif op==2
			DO LAV
     endif
		
	ELSEIF alltrim(opc[4])=="Z"
		DO Z

		***
		*LISTADOS
		***
	ELSEIF "Listados" $ opc[4]
		aaux:={	"Valorizar Stock                   ",;
					"Ventas              ",;
 					"Compras             ",;
 					"Servicios p/Empleado ",;
 					"Stock               ",;
 					"Remitos x Cliente    ",;
 					"Planillas           ",;
 					"Cuadro Situaci¢n     ",;
 					"Comisiones x Corredor",;
 					"Diferencia (Planillas-Facturaci¢n)" }
		op = PP_SELEC(ym2, xm2, len(aaux), 0, aaux, 1, "LISTADOS", "S", .T. )
 		RECUPAN()
		IF op = 1
			LISTADOR("VALSTOCK")
		ELSEIF op == 2
			aaux := {"x Grupo                 ",;
						"x Producto              ",;
						"de Lubricantes          ",;
						"Venta Comb.p/Plani.Calc.",;
						"x Surtidor / Isla       ",;
						"x Turno                 ",;
						"Facturado x Rubro       ",;
						"Facturado x Producto    ",;
						"Percepciones x Turno    ",;
						"Descuentos x Cliente    " }
			op2 = PP_SELEC(ym2+2, xm2-2, len(aaux), 0, aaux, 1, "VENTAS", "S", .T. )
 			RECUPAN()
			IF op2 == 1
				LISTADOR("VENTXGRU")
        ELSEIF op2 == 2
				LISTADOR("VENTXPRD")
        ELSEIF op2 == 3
				LISTADOR("LUBRIC")
        ELSEIF op2 == 4
				IF QUEFECHA2( 10, 30 )
					MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
              SELECT PRD
              aBase:={{"SUPER",1},{"NORMAL",2},{"GASOIL",3},{"ULTRA",8}}
              aaux:={{"FECHA","D",8,0},{"TURNO1","N",10,2},{"TURNO2","N",10,2},{"TURNO3","N",10,2},{"TOTAL","N",10,2}}
					FBASES({"PLAN2"})
              for b=1 to len(aBase)
              	@23,70 say aBase[b,1]
						select 99;	dbclosearea()
     				dbcreate("\VENXPLAN\"+aBase[b,1],aaux)
                 select 99
						use ("\VENXPLAN\"+aBase[b,1]) alias X exclusive
						index on ftoc(X->FECHA) to (xname('xx'))
						select pl2
						set order to 1
						dbseek( FTOC(DESDE), .T. )
						select 99
						do while BETWEEN( PL2->FECHA, DESDE, HASTA )
                 	if PL2->CODPROD=aBase[b,2]
                    	if !dbseek(ftoc(PL2->FECHA))
                       	append blank
                          X->FECHA := PL2->FECHA
                       endif
                       cAux := "3"
                       cAux:=if(PL2->TURNO$"12","1",cAux)
                       cAux:=if(PL2->TURNO$"34","2",cAux)
                       cAux:="TURNO"+cAux
           				X->&(cAux) += PL2->CANTIDAD
                       X->TOTAL := X->TURNO1 + X->TURNO2 + X->TURNO3
           			endif
                    @24,70 say PL2->FECHA
                    skip 1 alias PL2
                 enddo
					next b
					RECUPAN()
        	ENDIF
        ELSEIF op2 == 5
        	AXR := {}
           IF FILE("SURXISLA.ARR")
        		AXR := STOA(MEMOREAD("SURXISLA.ARR"))
           ENDIF
				aCpo:={	                                                         ;
					{ "ISLA",       "Isla",                '99', 'M', 'N',  2, 0 },;
					{ "SURTIDOR",   "n§;Surt",             '99', 'M', 'N',  2, 0 } }
				NROW := 1
				IF LEN(AXR) == 0
					AADD( AXR, AREG0( aCpo ) )
				ENDIF
				cColor := SETCOLOR(C_GET)
				lIntensity := SET(_SET_INTENSITY,.T.)
				MARCO( 5, 40, 19, 78, "SURT.x ISLA", "D", .T., 0 )
				OX := MYABROWSE( 5, 40, 19, 78, aCpo, AXR, "AXR" )
				OX:CARGO[TB_REFRESH] := 0
				OX:GOTOP()
				MENUDOWN({"  <+>  º    F2    º   F5    º   F6    º ESC  ",;
							 "       º          º inserta º elimina º      ",;
				 			 " mueve º modifica º  l¡nea  º  l¡nea  º sale "})
				DO WHILE .T.
					MOVABROW( OX, AXR, {||nK==K_TAB.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F5.OR.nK==K_F6},{||nK==999} )
					IF OX:CARGO[TB_MSGE] == "MODIF"
						AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
						OX:RefreshCurrent()
					ELSEIF OX:Cargo[TB_RET] == K_F5
						AADD( AXR, AREG0(aCpo) )
						AINS( AXR, NROW )
						AXR[NROW] := AREG0(aCpo)
						OX:RefreshAll()
					ELSEIF OX:Cargo[TB_RET] == 999
						IF AXR[NROW,1] # 0 .AND. NROW==LEN(AXR)
							AADD( AXR, AREG0(aCpo) )
						ENDIF
						OX:RefreshAll()
					ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. LEN(AXR) > 1
						ADEL( AXR, NROW )
        			ASIZE( AXR, LEN(AXR)-1 )
						OX:RefreshAll()
					ELSEIF OX:Cargo[TB_RET] == K_ESC
						aux := UPPER(PREGUNTA( 10, " [ G ] graba     [ S ] sale     [ C ] contin£a ","GgSsCc"))
        			IF aux == "G"
							OX:Cargo[TB_RET] := K_F10
							EXIT
        			ELSEIF aux == "S"
							EXIT
        			ENDIF
					ELSEIF OX:Cargo[TB_RET] == K_F10
						EXIT
					ENDIF
				ENDDO
 				RECUPAN()
				IF OX:Cargo[TB_RET] == K_F10
					MENSAJE( 99, 99, 0, .F., "GRABANDO..." )
  				MEMOWRIT("SURXISLA.ARR",ATOS(AXR))
  				RECUPAN()
				ENDIF
				SETCOLOR(cColor)
				SET(_SET_INTENSITY,lIntensity)
           ****************
				IF QUEFECHA2( 10, 30 )
					MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
              aSurt := {}
					FBASES({"PLAN2"})
					SELECT PL2
					DBSEEK( FTOC(DESDE), .T. )
              DO WHILE PL2->FECHA >= DESDE .AND. PL2->FECHA <= HASTA
           		i := ASCAN( aSurt, {|a|a[1]==PL2->SURTIDOR} )
           		IF i == 0
							AADD( aSurt,{PL2->SURTIDOR,0,0,0} )
                    i := LEN(aSurt)
						ENDIF
                 aSurt[i,2] += PL2->CANTIDAD
                 aSurt[i,3] += PL2->IMPORTE
           		ii := ASCAN( AXR, {|a|a[2]==PL2->SURTIDOR} )
           		IF ii # 0
							aSurt[i,4] := AXR[ii,1]
						ENDIF
                 @ 24,70 SAY PL2->FECHA
						SKIP 1 ALIAS PL2
					ENDDO
					RECUPAN()
					bLastErr := ErrorBlock()
					bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
					begin sequence
					LISTADOR( "INI" )
 					if !SETIMPRESORA("INI");  break(nil);  endif
					DO ICARGA WITH "VENXSUR"
              ASORT(aSurt,,,{|x,y| CHR(x[4])+CHR(x[1]) < CHR(y[4])+CHR(y[1]) })
              aux := -1
              nCANTIDAD := nIMPORTE := 0
              FOR nR=1 TO LEN(aSurt)
              	IF aSurt[nR,1] # 0
                 	IF aux#aSurt[nR,4]
                    	IF aux # -1
									CABEZA( 1 )
									I_CL += 1
									? I_esp + ARMOLIN(I_cab+2)
                       ENDIF
								CABEZA( 2 )
								I_CL += 2
                    	?
								? I_esp + "ISLA "+STRZERO(aSurt[nR,4],2)
                       aux := aSurt[nR,4]
              			nCANTIDAD := nIMPORTE := 0
                    ENDIF
							CABEZA( 1 )
							I_CL += 1
							? I_esp + ARMOLIN(I_cab+1)
                    nCANTIDAD += aSurt[nR,2]
                    nIMPORTE  += aSurt[nR,3]
                 ENDIF
              NEXT
					CABEZA( 1 )
					I_CL += 1
					? I_esp + ARMOLIN(I_cab+2)
              break
					end sequence
					ErrorBlock(bLastErr)
					LISTADOR("FIN")
				ENDIF
        ELSEIF op2 == 6
				IF QUEFECHA2( 10, 30 )
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					FBASES({"PLAN2"})
					cBaseAux = XNAME("XAUX")
					SELECT 99;	DBCLOSEAREA()
					CREARBASE( cBaseAux, "GRUPO N 2", "CANTIDAD N 10 3", "IMPORTE N 12 2", "TURNO C 1", "VTAEST N 12 3", "ESCOMBUST C 1", "FECHADDE D 8", "FECHAHTA D 8" )
					SELECT 99
					USE (cBaseAux) ALIAS X EXCLUSIVE
					INDEX ON X->TURNO+STR(X->GRUPO) TO (cBaseAux)
					SELECT PL2
					DBSEEK( FTOC(DESDE), .T. )
					SELECT 99
					DO WHILE PL2->FECHA >= DESDE .AND. PL2->FECHA <= HASTA
						IF !EMPTY(FPRODUCTO(PL2->CODPROD))
							IF !DBSEEK( PL2->TURNO+STR(PRD->GRUPO) )
								APPEND BLANK
								REPLACE X->TURNO WITH PL2->TURNO, X->GRUPO WITH PRD->GRUPO, X->FECHADDE WITH PL2->FECHA
							ENDIF
							REPLACE X->CANTIDAD WITH X->CANTIDAD+PL2->CANTIDAD,;
								X->IMPORTE WITH X->IMPORTE+PL2->IMPORTE, X->FECHAHTA WITH PL2->FECHA
						ENDIF
						SKIP 1 ALIAS PL2
					ENDDO
					cBaseAux = XNAME("XAU2")
              TOTAL ON X->TURNO+STR(X->GRUPO) FIELDS IMPORTE, CANTIDAD TO (cBaseAux)
              RECUPAN()

					bLastErr := ErrorBlock()
					bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
					begin sequence
					LISTADOR( "INI" )
 					if !SETIMPRESORA("INI");  break(nil);  endif
					DO ICARGA WITH "VENXTUR"

					select 99;  dbclosearea()
              select 99
					use (cBaseAux) alias X exclusive
					GO TOP
					M->TOTAL := M->CANTIDAD := 0
              M->STOTAL := 0
              cTurno := X->TURNO
					DO WHILE !EOF() .AND. !SALIR()
              	if cTurno # X->TURNO
							CABEZA(2); I_CL += 2
							?  I_esp + ARMOLIN(I_cab+2)
                    ?
              		cTurno := X->TURNO
              		M->STOTAL := 0
                 endif
						CABEZA(1); I_CL += 1
						? I_esp + ARMOLIN(I_cab+1)
						M->TOTAL     += X->IMPORTE
						M->STOTAL    += X->IMPORTE
           		M->CANTIDAD  += X->CANTIDAD
						SKIP
					ENDDO
					CABEZA( 5 )
					I_CL += 5
					?  I_esp + ARMOLIN(I_cab+2)
              ?
					?  I_esp + strtran(ARMOLIN(I_cab),"=","-")
					?  I_esp + ARMOLIN(I_cab+3)
					?
					RECUPAN()
					I_IMPRIMIO := .T.

              break
					end sequence
					ErrorBlock(bLastErr)
					LISTADOR("FIN")
           ENDIF
        ELSEIF op2 == 7
				if QUEFECHA2( 10, 30 )
					MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
					cBaseAux := XNAME("XAUX")
					select 99;	DBCLOSEAREA()
					dbcreate( cBaseAux, {{"RUBRO","C",4,0},{"TIPOFAC","C",4,0},{"DESCRUB","C",20,0},{"CANTIDAD","N",10,3},{"TPRECBASE","N",12,2},{"TIMPINT","N",12,3},{"TIVA","N",12,2}} )
					select 99
					use (cBaseAux) alias X exclusive
					index on X->RUBRO+X->TIPOFAC to (cBaseAux)
					FBASES({"ARTIC","RUBRO"})
              aCig:={}
              RU->( dbeval({||aadd(aCig,{RU->CODRUB,RU->DESCRUB})},{||RU->APARTE=="S"} ))
*             aBase:={{"FACA","FA"},{"FACB","FB"},{"TICKETS","TI"}}
              aBase:={{"TICKETS","TI"},{"FACA","FA"},{"FACB","FB"}}
              for b=1 to len(aBase)
              	z1:=z2:=0
                 if aBase[b,2] $ "FA FB"
                 	z1:=DESDE_SUC
                    z2:=HASTA_SUC
                 endif
              	for z=z1 to z2
              		cSUCURSAL := str(z,1)
              		@ 23,70 say aBase[b,1] +" "+cSUCURSAL
							FBASES({"-"+aBase[b,1],"-"+aBase[b,1]+"2"})
							FBASES({"+"+aBase[b,1],"+"+aBase[b,1]+"2"})
              		XF:=aBase[b,2];  XF2:=XF+"2"
							select (XF)
                 	set order to forder({"FECHA"})
							dbseek( ftoc(DESDE), .T. )
							select X
							do while ROSCA().and.BETWEEN((XF)->FECHA,DESDE,HASTA) .and. !(XF)->(eof())
                 		(XF2)->(dbseek((XF)->NUMFAC))
                    	do while (XF2)->NUMFAC==(XF)->NUMFAC .and. !(XF2)->(eof())
                       	if (XF2)->NEGOCIO=="*"
                          	ART->(dbseek((XF2)->CODPROD))
                       		n := ascan( aCig, {|a,i| a[1]==ART->RUBRO} )
*                         	n := if(n==0,-1,aCig[n,1])
                          	n := if(n==0,-1,n)
										if !dbseek( (XF2)->NEGOCIO+str(n,3)+XF+' '+cSUCURSAL )
											append blank
											X->RUBRO   := (XF2)->NEGOCIO+str(n,3)
                                X->TIPOFAC := XF+' '+cSUCURSAL
                            		X->DESCRUB := if(n==-1,"SERVICOMPRAS",aCig[n,2])
                          	endif
                       	else
                          	if "KERO" $ (XF2)->DESCPROD
											if !dbseek( " 444"+XF+' '+cSUCURSAL )
												append blank
                                   X->TIPOFAC := XF+' '+cSUCURSAL
												X->RUBRO   := " 444"
                             		X->DESCRUB := "KEROSENE"
											endif
                             else
                          		PRD->(dbseek((XF2)->CODPROD))
 											if !dbseek( (XF2)->NEGOCIO+str(PRD->RUBRO,3)+XF+' '+cSUCURSAL )
 												append blank
 												X->RUBRO   := (XF2)->NEGOCIO+str(PRD->RUBRO,3)
                                   X->TIPOFAC := XF+' '+cSUCURSAL
                             		X->DESCRUB := fvector(vrubro,PRD->RUBRO)
 											endif
                             endif
                       	endif
                       	if val(substr(X->RUBRO,2))==0
                       		X->DESCRUB := "SIN RUBRO "+if( left(X->RUBRO,1)=="*", "SERVICOMP.","ESTACION" )
                       	endif
*									X->CANTIDAD  += (XF2)->CANTIDAD
									X->TPRECBASE += (XF2)->TPRECBASE
									X->TIMPINT   += (XF2)->TIMPINT
									X->TIVA      += ( (XF2)->TIVA1 + (XF2)->TIVA2 )
									skip 1 alias (XF2)
                    	enddo
              			@ 24,70 say (XF)->FECHA
								skip 1 alias (XF)
							enddo
                 next z
					next b
              sum M->TPRECBASE, M->TIMPINT, M->TIVA to TPRECBASE, TIMPINT, TIVA for left(RUBRO,1)=="*" .and. TIPOFAC#"FA 2"
*          	replace  FIELD->TPRECBASE with FIELD->TPRECBASE * ( M->ZTPRECBASE / M->TPRECBASE ),;
*          				FIELD->TIMPINT with FIELD->TIMPINT * ( M->ZTIMPINT / M->TIMPINT ),;
*          				FIELD->TIVA with FIELD->TIVA * ( M->ZTIVA / M->TIVA ) for left(RUBRO,1)=="*" .and. TIPOFAC#"FA 2"
              RECUPAN()
					bLastErr := ErrorBlock()
					bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
					begin sequence
					LISTADOR( "INI" )
 					if !SETIMPRESORA("INI");  break(nil);  endif
					DO ICARGA WITH "FACXRUB"
					select X
					M->TPRECBASE := M->TIMPINT := M->TIVA := 0
					go top
					do while !eof() .and. !SALIR()
						CABEZA(1); I_CL += 1
						? I_esp + ARMOLIN(I_cab+1)
						M->TPRECBASE += X->TPRECBASE
						M->TIMPINT   += X->TIMPINT
                 M->TIVA      += X->TIVA
						skip
					enddo
					CABEZA( 5 );  I_CL += 5
					?  I_esp + ARMOLIN(I_cab)
					?  I_esp + ARMOLIN(I_cab+2)
					?  I_esp + ARMOLIN(I_cab)
					?
					?  I_esp + ARMOLIN(I_cab)
              index on X->RUBRO to (cBaseAux)
              cBaseAux2:=xname('XX2')
              total on X->RUBRO to (cBaseAux2) field TPRECBASE, TIMPINT, TIVA
              select 99
              use (cBaseAux2) alias X exclusive
              replace X->TIPOFAC with "" all
					M->TPRECBASE := M->TIMPINT := M->TIVA := 0
					go top
					do while !eof() .and. !SALIR()
						CABEZA(1); I_CL += 1
						? I_esp + ARMOLIN(I_cab+1)
						M->TPRECBASE += X->TPRECBASE
						M->TIMPINT   += X->TIMPINT
                 M->TIVA      += X->TIVA
						skip
					enddo
					CABEZA( 3 )
					I_CL += 3
					?  I_esp + ARMOLIN(I_cab)
					?  I_esp + ARMOLIN(I_cab+2)
					?  I_esp + ARMOLIN(I_cab)
					RECUPAN()
					I_IMPRIMIO := .T.
              break
					end sequence
					ErrorBlock(bLastErr)
					LISTADOR("FIN")
           endif
        ELSEIF op2 == 8		// Facturado x Producto
  			IF MARCARPROD()
     			aaux := {};  DBEVAL( {|| AADD(aaux,PRD->CODPROD)}, {|| PRD->MARCA==''} )
					IF QUEFECHA2( 10, 30 )
						MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
						cBaseAux = XNAME("XAUX")
						SELECT 99;	DBCLOSEAREA()
						dbcreate(cBaseAux, {{"CODPROD","N",5,0},{"DESCPROD","C",20,0},{"CANTIDAD","N",10,3},{"TIMPINT","N",12,3},{"TPRECBASE","N",12,2},{"TIVA1","N",12,2},{"TOTAL","N",12,2},{"TDESCUENTO","N",12,2}} )
						select 99
						use (cBaseAux) alias X exclusive
						index on X->CODPROD to (cBaseAux)
              	aBase:={{"FACA","FA"},{"FACB","FB"}}	//,{"REM","RE"}}
              	for b=1 to len(aBase)
              		z1:=z2:=0
                 	if aBase[b,2] $ "FA FB"
                 		z1:=DESDE_SUC
                    	z2:=HASTA_SUC
                 	endif
              		for z=z1 to z2
              			cSUCURSAL := str(z,1)
              			@ 23,70 say aBase[b,1] +" "+cSUCURSAL
								FBASES({"-"+aBase[b,1],"-"+aBase[b,1]+"2"})
								FBASES({"+"+aBase[b,1],"+"+aBase[b,1]+"2"})
              			XF:=aBase[b,2];  XF2:=XF+"2"
								select (XF)
                 		set order to forder({"FECHA"})
								dbseek( ftoc(DESDE), .T. )
								select X
								do while ROSCA().and.BETWEEN( (XF)->FECHA, DESDE, HASTA ) .and. !(XF)->(eof())
                 			(XF2)->(dbseek((XF)->NUMFAC))
                    		do while (XF2)->NUMFAC==(XF)->NUMFAC .and. !(XF2)->(eof())
                       		if (XF2)->NEGOCIO#"*" .and. ascan(aaux,(XF2)->CODPROD) # 0
											if !dbseek( (XF2)->CODPROD )
												append blank
												X->CODPROD := (XF2)->CODPROD
												X->DESCPROD := FPRODUCTO((XF2)->CODPROD,(XF2)->NEGOCIO)
											endif
 							 				X->CANTIDAD  += (XF2)->CANTIDAD
											X->TPRECBASE += (XF2)->TPRECBASE
											X->TIMPINT   += (XF2)->TIMPINT
											X->TIVA1     += (XF2)->TIVA1
                       			X->TOTAL     += (XF2)->IMPORTE
                             	X->TDESCUENTO+= (XF2)->TDESCUENTO
                       		endif
										skip 1 alias (XF2)
                    		enddo
              				@ 24,70 say (XF)->FECHA
									skip 1 alias (XF)
								enddo
                 	next z
						next b
              	FBASES({"PROD"},.F.)
              	RECUPAN()
						LISTADOR( "INI" )
 						if !SETIMPRESORA("INI");  break(nil);  endif
						DO ICARGA WITH "FACXPRD"
						select X
						GO TOP
						M->CANTIDAD := M->TOTAL := M->TPRECBASE := M->TIMPINT := M->TIVA1 := M->TDESCUENTO := 0
						DO WHILE !EOF() .AND. !SALIR()
							CABEZA(1); I_CL += 1
							? I_esp + ARMOLIN(I_cab+1)
							M->CANTIDAD  += X->CANTIDAD
                 	M->TOTAL     += X->TOTAL
							M->TPRECBASE += X->TPRECBASE
							M->TIMPINT   += X->TIMPINT
							M->TIVA1     += X->TIVA1
							M->TDESCUENTO+= X->TDESCUENTO
							SKIP
						ENDDO
 						CABEZA(3)
						I_CL += 3
						?  I_esp + ARMOLIN(I_cab)
						?  I_esp + ARMOLIN(I_cab+2)
						?  I_esp + ARMOLIN(I_cab)
						RECUPAN()
						I_IMPRIMIO := .T.
						LISTADOR("FIN")
           	ENDIF
           endif
        ELSEIF op2 == 9		// Percepciones x Turno
				IF QUEFECHA2( 10, 30 )
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					cBaseAux = XNAME("XAUX")
					SELECT 99;	DBCLOSEAREA()
					dbcreate( cBaseAux, {{"FECHA","D",8,0},{"TURNO","C",1,0},{"TPERCIB","N",10,3},{"CANT_FAC","N",6,0},{"TOTAL","N",12,2}} )
					select 99
					use (cBaseAux) alias X exclusive
					index on ftoc(X->FECHA)+X->TURNO to (cBaseAux)
              aBase:={{"FACA","FA"},{"FACB","FB"}}	//,{"REM","RE"}}
             	aSUCU_NO := {1,2}
              for b=1 to len(aBase)
              	z1:=z2:=0
                 if aBase[b,2] $ "FA FB"
                 	z1:=DESDE_SUC
                    z2:=HASTA_SUC
                 endif
              	for z=z1 to z2
                 	if ascan(aSUCU_NO,z)==0
              			cSUCURSAL := str(z,1)
              			@ 23,70 say aBase[b,1] +" "+cSUCURSAL
								FBASES({"-"+aBase[b,1]})
								FBASES({"+"+aBase[b,1]})
              			XF:=aBase[b,2]
								select (XF)
                 		set order to forder({"FECHA"})
								dbseek( ftoc(DESDE), .T. )
								select X
								do while ROSCA().and.BETWEEN( (XF)->FECHA, DESDE, HASTA ) .and. !(XF)->(eof())
                       	if (XF)->PERCIB<>0
                       		if !X->(dbseek(FTOC((XF)->FECHA)+(XF)->TURNO))
                          		append blank
                             	X->FECHA := (XF)->FECHA
                             	X->TURNO := (XF)->TURNO
                          	endif
                          	X->TPERCIB := X->TPERCIB + (XF)->PERCIB
                          	X->TOTAL   := X->TOTAL   + (XF)->TOTAL
                          	X->CANT_FAC := X->CANT_FAC + 1
                          endif
              				@ 24,70 say (XF)->FECHA
									skip 1 alias (XF)
								enddo
                    endif
                 next z
					next b
              FBASES({"PROD"},.F.)
              RECUPAN()
					LISTADOR( "INI" )
 					SETIMPRESORA("INI")
					DO ICARGA WITH "PERCIBV"
					select X
					dbgotop()
              dAux := X->FECHA
					do while !EOF() .and. !SALIR()
              	if X->FECHA<>dAux
              		dAux := X->FECHA
							CABEZA(1); I_CL += 1;	?
                 endif
						CABEZA(1); I_CL += 1
						? I_esp + ARMOLIN(I_cab+1)
						skip
					enddo
					RECUPAN()
					I_IMPRIMIO := .T.
					LISTADOR("FIN")
           ENDIF
        ELSEIF op2 == 10		// Descuentos x Cliente
				if QUEFECHA2( 10, 30 )
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					cBaseAux = XNAME("XAUX")
					select 99;	dbclosearea()
					dbcreate( cBaseAux, {{"CODCLI","N",5,0},{"CODPROD","N",5,0},{"CANTIDAD","N",12,4},{"PRECBASE","N",10,3},{"TIVA1","N",12,2},{"TIMPINT","N",12,2},{"TDESCUENTO","N",12,2},{"TOTAL","N",12,2}} )
					select 99
					use (cBaseAux) alias X exclusive
					index on str(X->CODCLI)+str(X->CODPROD) to (cBaseAux)
              aBase:={{"FACA","FA"},{"FACB","FB"}}
              for b=1 to len(aBase)
              	z1:=z2:=0
                 if aBase[b,2] $ "FA FB"
                 	z1:=DESDE_SUC
                    z2:=HASTA_SUC
                 endif
              	for z=z1 to z2
              		cSUCURSAL := str(z,1)
              		@ 23,70 say aBase[b,1] +" "+cSUCURSAL
							FBASES({"-"+aBase[b,1],"-"+aBase[b,1]+"2"})
							FBASES({"+"+aBase[b,1],"+"+aBase[b,1]+"2"})
              		XF:=aBase[b,2];	XF2:=aBase[b,2]+"2"
							select (XF)
                 	set order to forder({"FECHA"})
							dbseek( ftoc(DESDE), .T. )
							select X
							do while ROSCA().and.BETWEEN( (XF)->FECHA, DESDE, HASTA ) .and. !(XF)->(eof())
                       if (XF)->TDESCUENTO<>0
                          (XF2)->(dbseek((XF)->NUMFAC))
                          do while (XF2)->NUMFAC==(XF)->NUMFAC .and. !(XF2)->(eof())
                          	if !dbseek( str((XF)->CODCLI) + str((XF2)->CODPROD) )
                                append blank
                                X->CODCLI := (XF)->CODCLI
                                X->CODPROD := (XF2)->CODPROD
                             endif
                             X->CANTIDAD   += (XF2)->CANTIDAD
                             X->PRECBASE   += (XF2)->TPRECBASE
                             X->TDESCUENTO += (XF2)->TDESCUENTO
                             X->TIVA1      += (XF2)->TIVA1
                             X->TIMPINT    += (XF2)->TIMPINT
                             X->TOTAL      += (XF2)->IMPORTE
                             skip 1 alias (XF2)
                          enddo
                       endif
                       skip 1 alias (XF)
                    enddo
                 next z
					next b
              FBASES({"PROD","CLA"},.F.)
              RECUPAN()
					LISTADOR( "INI" )
 					SETIMPRESORA("INI")
					DO ICARGA WITH "DCTOXCLI"
					select X
					dbgotop()
              nAux := -1
					do while !EOF() .and. !SALIR()
              	if X->CODCLI<>nAux
							CABEZA(2); I_CL += 2;	?
							CLA->(dbseek(X->CODCLI))
                    ? I_esp + str(X->CODCLI) +"  "+ CLA->RAZONSOC
              		nAux := X->CODCLI
                 endif
						CABEZA(1); I_CL += 1
						? I_esp + ARMOLIN(I_cab+1)
						skip
					enddo
					I_IMPRIMIO := .T.
					LISTADOR("FIN")
           ENDIF
        ENDIF

		ELSEIF op == 3
			op = MENUFLASH( ym2+2, xm2-2, 1, .F., "COMPRAS",  "X PRODUCTO ", "RESUMEN DE COMPRAS", "X PROD.X DIA", "PERCIIBB" )
			IF op == 1
				LISTADOR("COMXPRD")
			ELSEIF op == 2
				LISTADOR("COMPRAS")
			ELSEIF op == 3
				LISTADOR("DCOMXPRD")
			ELSEIF op == 4
				LISTADOR("PERCIIBB")
        ENDIF
     	RECUPAN()
		ELSEIF op == 4
			LISTADOR( "SERVXEMP")
		ELSEIF op == 5
			op = MENUFLASH( ym2+2, xm2-2, 1, .F., "STOCK","X PRODUCTO   ",;
															  "DE COMBUSTIBLES      " )
			IF op == 1
				LISTADOR( "STKXPRD")
			ELSEIF op == 2
				LISTADOR( "COMBUST")
			ENDIF
     	RECUPAN()
		ELSEIF op == 6
			IF MARCARCLI()
     		IF QUEFECHA2(10,30)
					MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
              select 99;  dbclosearea()
#ifdef SUR
        		aDir := {"\SUR\EST\","\SUR2\EST\"}
        		aSuc := {"1","2"}
#else
        		aDir := {""}
        		aSuc := {""}
#endif
					bLastErr := ErrorBlock()
					bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
					begin sequence
					LISTADOR( "INI" )
 					if !SETIMPRESORA("INI");  break(nil);  endif
					DO ICARGA WITH "DREMXCLI"

					select CL
              go top
           	M->TCANTIDAD  := 0
              do while !CL->(eof())
              	if CL->MARCA==''
              		M->CANTREM := M->TOTALREM := 0
                   	lAux := .F.
							I_CL := UT_largo + 1
        				for b=1 to len(aDir)
        					F_ABASE({"RE","RE2"},"CERRAR")
           				FBASES({"+"+aDir[b]+"REM","+"+aDir[b]+"REM2"})
           				select RE
           				DBSETORDER( FORDER({"FECHA","TURNO"}) )
              			dbseek( ftoc(DESDE), .T. )
                 		do while RE->FECHA>=DESDE .and. RE->FECHA<=HASTA
                       	if RE->CODCLI==CL->CODCLI
                    			lAux := .T.
                 				select RE2
                    			RE2->(DBSEEK( RE->NUMFAC ))
           						M->TCANTIDAD := 0
                    			do while RE2->NUMFAC == RE->NUMFAC
											CABEZA( 1 )
											I_CL += 1
											? I_esp + ARMOLIN(I_cab+IF(M->TCANTIDAD==0,1,2))
           							M->TCANTIDAD += RE2->CANTIDAD
                          		M->CANTREM  += 1
                          		M->TOTALREM += RE2->IMPORTE
                       			skip
                 				enddo
										CABEZA( 1 )
										I_CL += 1
										? I_esp + ARMOLIN(I_cab+3)
                    			skip 1 alias RE
                          endif
              			enddo
                    next b
                    if lAux
								CABEZA( 3 )
								I_CL += 3
                       ?
								? I_esp + ARMOLIN(I_cab)
								? I_esp + ARMOLIN(I_cab+4)
								FOR x = 1 TO UT_largo-I_CL
									?
								NEXT x
                    endif
              	ENDIF
						SKIP 1 ALIAS CL
					ENDDO
					RECUPAN()
              break
					end sequence
					ErrorBlock(bLastErr)
					LISTADOR("FIN")
           ENDIF
			ENDIF
		ELSEIF op == 7
			op2 = MENUFLASH( ym2+2, xm2-2, 1, .F., "", "IMPRIMIR  ",;
                                                   "CONFIGURAR" )
			IF op2 == 1
        ***************************
				FBASES({"PLANT"})
				xmenu:=MENUDOWN({ "  <+>  º   F2     º   F5   º    TAB    º   ENTER   º  ESC   ",;
								  		"       º          º        º actualiza º aplica la º        ",;
								  		" mueve º modifica º agrega º plantilla º plantilla º  sale  "})
        	DO WHILE .T.
					PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
					bcamp[ 1] = "RECNO()"
					bcamp[ 2] = "PLT->DESCPLANT"
					bcamp[ 3] = "PLT->MARCA"
					bmasc[ 1] = "999"
					bmasc[ 2] = "@!"
					bmasc[ 3] = "!"
					bcab[ 1] = ""
					bcab[ 2] = "Plantilla"
					bcab[ 3] = "!"
					bedit = "FEE"
					SELECT PLT
					GO TOP
					r = BROW( 10, 1, 18, 50, "PLANTILLAS", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=-1.OR.tecla=-5.OR.tecla=9.OR.tecla=32" )
					RECUPAN()
        		IF LASTKEY()==K_ENTER .OR. LASTKEY()==K_ESC
              	EXIT
        		ELSEIF LASTKEY() == K_TAB
              	NROW := 1
						aaux := STOA( PLT->PLANTILLA )
     				IF PLT( aaux, ALLTRIM(PLT->DESCPLANT) )
              		FRLOCK()
              		PLT->PLANTILLA := ATOS( aaux )
              		DBUNLOCK()
              	ENDIF
           	ENDIF
        	ENDDO
        	PONEPAN(xmenu)
        	IF LASTKEY() == K_ENTER
           	IMPRPLT()
           ENDIF
			ELSEIF op2 == 2
           CONFIGPLT()
			ENDIF
     	RECUPAN()
		ELSEIF op == 8
			DO ES
		ELSEIF op == 9
     	lAux := .F.
     	if CORR(,.T.,.T.)
        	select COR;  aCorr:={};  dbeval({||aadd(aCorr,COR->CODCORR)},{||COR->MARCA==""})
           if len(aCorr) > 0
					lAux := QUEFECHA2( 10, 30 )
					op2 = MENUFLASH( 10, 30, 1, .T., "",  "S¢lo Venta Contado","S¢lo Venta Cta.Cte.","Todo" )
					lAux := (lastkey()==K_ENTER)
           endif
        endif
			if lAux
				MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
           aRub := { ascan(VRUBRO,{|a| "COMB"$a}), ascan(VRUBRO,{|a| "LUBRIC"$a}) }
				cBaseAux = XNAME("XAUX")
				select 99;	dbclosearea()
           aaux := {{"CODCLI","N",5,0},;
           			{"CODCORR","N",2,0},;
           			{"TIPOFAC","C",2,0},;
           			{"TIPOVENTA","C",1,0},;
           			{"RAZONSOC","C",20,0},;
           			{"SUCURSAL","C",1,0},;
           			{"NUMFAC","N",8,0},;
                    {"FECHA","D",8,0},;
                    {"TOTAL1","N",10,2},;
                    {"TOTAL2","N",10,2},;
                    {"COMIS1","N",10,2},;
                    {"COMIS2","N",10,2},;
                    {"NUMCOB","C",6,0},;
                    {"EFECTIVO","N",10,2},;
                    {"CHEQUE","N",10,2}}
				dbcreate( cBaseAux, aaux )
				select 99
				use (cBaseAux) alias X exclusive
				index on X->CODCORR to (cBaseAux)
           FBASES({"CORR","CCV","CLA"})
				aDir:={""}
				if "SUR" $ curdir()
					aDir:={"","\"+strtran(curdir(),"\EST","2\EST")+"\"}
				endif
				aBase:={{"FACA","FA"},;
						  {"FACB","FB"} }
				for d=1 to len(aDir)
					for b=1 to len(aBase)
  					z1:=DESDE_SUC
     				z2:=HASTA_SUC
     				for z=z1 to z2
     					cSUCURSAL:=str(z,1)
              		@ 23,70 say aBase[b,1] +" "+cSUCURSAL
              		XF:=aBase[b,2];  XF2:=XF+"2"
        				F_ABASE({XF,XF2},"CERRAR")
							FBASES({ "+"+aDir[d]+aBase[b,1], "+"+aDir[d]+aBase[b,1]+"2" })
							select (XF)
                 	set order to forder({"FECHA"})
							dbseek( ftoc(DESDE), .T. )
							select X
							do while ROSCA().and.BETWEEN((XF)->FECHA,DESDE,HASTA) .and. !(XF)->(eof())
                    	if (XF)->TIPOVENTA=="1" .and. (op2==1.or.op2==3)
                       	CLA->(dbseek((XF)->CODCLI))
                    		nCODCORR := CLA->CODCORR
                       elseif (XF)->TIPOVENTA=="2" .and. (op2==2.or.op2==3)
                       	CL->(dbseek((XF)->CODCLI))
                    		nCODCORR := CL->CODCORR
                       else
                    		nCODCORR := 0
                       endif
              			if ascan(aCorr,nCODCORR)#0
              				(XF2)->( dbseek((XF)->NUMFAC) )
                 			nAux1 := nAux2 := 0
                 			do while (XF2)->NUMFAC == (XF)->NUMFAC .and. !(XF2)->(eof())
										if !empty(FPRODUCTO((XF2)->CODPROD))
                    				i := ascan(aRub,NRUBRO)
                       			if i == 1
                       				nAux1 += (XF2)->IMPORTE
                       			elseif i == 2
                       				nAux2 += (XF2)->IMPORTE
                       			endif
                    			endif
										skip 1 alias (XF2)
                 			enddo
                 			append blank
           					X->CODCLI    := (XF)->CODCLI
           					X->CODCORR   := nCODCORR
                          X->RAZONSOC  := (XF)->RAZONSOC
           					X->TIPOFAC   := XF
                          X->TIPOVENTA := (XF)->TIPOVENTA
           					X->SUCURSAL  := cSUCURSAL
           					X->NUMFAC    := (XF)->NUMFAC
                 			X->FECHA     := (XF)->FECHA
                 			X->TOTAL1    := nAux1
                 			X->TOTAL2    := nAux2
                    		X->NUMCOB    := (XF)->NUMCOB
                 		endif
								skip 1 alias (XF)
              		enddo
           		next z
           	next b
           next d
           RECUPAN()

				bLastErr := ErrorBlock()
*				bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
				begin sequence
				LISTADOR( "INI" )
 				if !SETIMPRESORA("INI");  break(nil);  endif
				DO ICARGA WITH "COMIS"

           select X
				go top
           I_CODCORR := -1
				M->TOTAL1 := M->TOTAL2 := 0
				do while !eof() .and. !salir()
              if I_CODCORR # X->CODCORR
              	IF !I_INI
							CABEZA(2); I_CL += 2
							? I_esp + ''+ARMOLIN(I_cab)
							? I_esp + ARMOLIN(I_cab+2)
                 ENDIF
						CABEZA(2); I_CL += 2
                 ?
						? I_esp + CORR(X->CODCORR), "Comb."+alltrim(str(COR->PORCOMIS1))+"%     Lubr."+alltrim(str(COR->PORCOMIS2))+"%"
           		I_CODCORR := X->CODCORR
						M->TOTAL1 := M->TOTAL2 := 0
              endif
					CABEZA(1); I_CL += 1
					? I_esp + ARMOLIN(I_cab+1)
					M->TOTAL1    += X->TOTAL1
					M->TOTAL2    += X->TOTAL2
					skip
				enddo
				CABEZA(2); I_CL += 2
				? I_esp + ARMOLIN(I_cab)
				? I_esp + ARMOLIN(I_cab+2)
				RECUPAN()
				I_IMPRIMIO := .T.

           break
				end sequence
				ErrorBlock(bLastErr)
				LISTADOR("FIN")
     	ENDIF
		ELSEIF op == 10
			cColor := SETCOLOR(C_GET)
			MARCO(10,30,11,60, "", "D", .T., 0 )
*			MENUDOWN({"  <+>  º    F2    º   F5    º   F6    º ESC  ",;
*						 "       º          º inserta º elimina º      ",;
*				 		 " mueve º modifica º  l¡nea  º  l¡nea  º sale "})
        DESDE:=HASTA:=date()
        cTurno1:=cTurno2:="1"
			SET(_SET_INTENSITY,.T.)
        SET(_SET_CURSOR,SC_ON)
			do while .t.
				@ 10,30 say "        desde Fecha:" get DESDE
				@ 11,30 say "        hasta Fecha:" get HASTA
           read
           if lastkey()==K_ENTER .or. lastkey()==K_ESC
           	exit
           endif
        enddo
        recupan()
        if lastkey()==K_ENTER
				MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
#ifdef POWEROIL
				cT1 := {"1","3","5"}[val(cTurno1)]
				cT2 := {"2","4","5"}[val(cTurno2)]
#else
				cT1:=cTurno1
				cT2:=cTurno2
#endif
           aBase:={ {"FACA","FA",{||X->CANTFA+=FA2->CANTIDAD}},;
							{"FACB","FB",{||X->CANTFB+=FB2->CANTIDAD}} }
*							{"REM","RE", {||X->CANTRE+=RE2->CANTIDAD}} }

					// Verifica si faltan comprobantes
           nTmal:=0
           z1:=DESDE_SUC
           z2:=HASTA_SUC
           set console off
  			cArchAux := XNAME("XLIS")+".TXT"
           set alternate to (cArchAux)
           set alternate on
           for b=1 to len(aBase)
          		for z=z1 to z2
           		nRev:=nMal:=0
           		cSUCURSAL:=str(z,1)
              	XF:=aBase[b,2]
                 if XF=="FB" .and. cSUCURSAL==SUC_SERV
                 else
              		F_ABASE({XF},"CERRAR")
              		FBASES({"+"+aBase[b,1]},.F.)
							select (XF)
							set order to FORDER({"FECHA"})
							dbseek(FTOC(DESDE),.T.)
							set order to 1
							nTmal += QUEFALTA( XF, "facturas "+right(XF,1) )
                 endif
           	next z
				next b

					// une los Tickets y las facturas B de la sucursal del Servicompras
				select 99;  dbclosearea()
				FBASES({"+TICKETS"},.F.)
				select TI
				set order to FORDER({"FECHA"})
           dbseek(ftoc(DESDE),.T.)
           copy to QQ fields FECHA, NUMFAC rest while FECHA<=HASTA

				cSUCURSAL:=SUC_SERV
           F_ABASE({"FB"},"CERRAR")
           FBASES({"+FACB"},.F.)
				set order to FORDER({"FECHA"})
           dbseek(ftoc(DESDE),.T.)
           copy to QQ2 fields FECHA, NUMFAC rest while FECHA<=HASTA

				select 99
           use QQ alias X exclusive
           index on NUMFAC to qq
           append from QQ2
           nTmal += QUEFALTA( "X", "Tickets/Facturas B" )
           set alternate to
           set console on

				if nTmal#0
					cAux:=SAVESCREEN(0,0,24,79)
  				TXT( cArchAux )
					RESTSCREEN(0,0,24,79,cAux)
				endif

           cBaseAux:=xname('XAUX')
           aaux:={{"CODPROD","N",5,0},{"CANTPL","N",13,3,0},{"CANTFA","N",13,3,0},{"CANTFB","N",13,3,0},{"CANTRE","N",13,3,0},{"DIFERENCIA","N",13,3,0}}
           select 99;  dbclosearea()
           select 99
           dbcreate(cBaseAux,aaux)
           use (cBaseAux) alias X exclusive
           index on X->CODPROD to (cBaseAux)
					***   turnos para planillas
           FBASES({"PLAN2"})
           select PL2
           dbseek(ftoc(DESDE)+cT1,.T.)
           select X
           do while ROSCA().and.BETWEEN(PL2->FECHA,DESDE,HASTA)
*					if BETWEEN(PL2->TURNO,cT1,cT2)
           		if !dbseek(PL2->CODPROD)
              		append blank
                 	X->CODPROD := PL2->CODPROD
              	endif
              	X->CANTPL += PL2->CANTIDAD
*             endif
              skip 1 alias PL2
           enddo

           for b=1 to len(aBase)
              FX:=aBase[b,2];  FX2:=FX+"2"
              z1:=z2:=0
              if aBase[b,2] $ "FA FB"
                 z1:=DESDE_SUC
                 z2:=HASTA_SUC
              endif
           	for z=z1 to z2
              	cSUCURSAL:=str(z,1)
//BORRAR
if z==3 .and.FX=="FB"
	baux3:={||FRLOCK("FB2"),FB2->DESCPROD:=alltrim(FB2->DESCPROD)+"û",fb2->(dbunlock())}
else
	baux3:={||.t.}
endif
           		FBASES({"-"+aBase[b,1],"-"+aBase[b,1]+"2"})
           		FBASES({"+"+aBase[b,1],"+"+aBase[b,1]+"2"})
              	FX:=aBase[b,2];  FX2:=FX+"2"
              	@ 24,70 say aBase[b,1]
             		select (FX)
              	set order to forder({"FECHA","TURNO"})
              	dbseek(ftoc(DESDE),.T.)
*             	set order to 1
              	if FX=="RE"
                 	bCond:={||.t.}
              	else
                 	bCond:={||(FX)->TIPOVENTA=="1"}		// resta s¢lo facturas comunes, no de Cta.Cte ni Complemento
                 	bCond:={||.t.}
              	endif
              	select X
              	do while ROSCA().and.BETWEEN((FX)->FECHA,DESDE,HASTA)
              		(FX2)->(dbseek((FX)->NUMFAC))
							do while (FX2)->NUMFAC==(FX)->NUMFAC
              			if eval(bCond).and.(FX2)->NEGOCIO#"*"
             					if !dbseek((FX2)->CODPROD)
                 				append blank
                    			X->CODPROD := (FX2)->CODPROD
                 			endif
                 			eval(aBase[b,3])
*eval(bAux3)		//BORRAR
                 		endif
                       skip 1 alias (FX2)
							enddo
                 	skip 1 alias (FX)
              	enddo
           	next z
           next b
           dbeval( {||X->DIFERENCIA:=X->CANTPL-X->CANTFA-X->CANTFB-X->CANTRE} )
           recupan()
           LISTADOR("PLANDIF")
        endif
     ENDIF
     cSUCURSAL:=ACTUAL_SUC
     FBASES({"PROD"})


		***
		*PLANILLAS
		***
	ELSEIF "Planilla" $ opc[4]
		DO PLA
		
		
		***
		*CHEQUES PROPIOS
		***
	ELSEIF "Cheque" $ opc[4] .AND. "Prop" $ opc[4]
		DO CHEC
		
		***
		*CHEQUES ESTACION
		***
	ELSEIF "Cheque" $ opc[4]
		DO CHC
		
		
		***
		*TARJETAS
		***
	ELSEIF "Tarjeta" $ opc[4]
		DO TAR
		
		***
		*POSNET
		***
	ELSEIF "Posnet" $ opc[4]
		DO POS
		
		***
		*COPRES
		***
	ELSEIF "Copres" $ opc[4]
		DO COP
		
		***
		*CAJA
		***
	ELSEIF "Caja  " $ opc[4]
		DO CAJ
		
		
		***
		*CAJA CHICA
		***
	ELSEIF "Caja Chica" $ opc[4]
  	select PRD
		DO CAJCH
		

		***
		*GASTOS
		***
	ELSEIF "Gastos" $ opc[4]
		DO GAS
		
		
		***
		*LIBRO BANCOS
		***
	ELSEIF "Bancos" $ opc[4]
		DO CARGAVEC WITH "BANCOCTA", 5
		op = ABRW( ym2, xm2, 0, 'vbancocta', 1, 'BANCOS')
		IF LASTKEY() == K_ENTER
			DO LB WITH op
		ENDIF
		
		
		***
		*VENCIMIENTOS
		***
	ELSEIF "Vencimiento" $ opc[4]
		CAL( DATE() )
		
		
		***
		*CLIENTES
		***
	ELSEIF "Cliente" $ opc[4]
		op = MENUFLASH( ym2, xm2, 1, .F., "", "CLIENTES CTA.CTE", "CLIENTES c/CUIT" )
     IF op == 1
			DO CLI
     ELSEIF op == 2
			FBASES( { "CLA" } )
        cCLIENTE := SPACE(LEN(CLA->RAZONSOC))
			aux := FELEGIR("CLA")
     ENDIF

		***
		*AJUSTES
		***
	ELSEIF "Ajuste" $ opc[4]
		DO AJU
		
		***
		*CUENTAS CORRIENTES VENTA
		***
	ELSEIF "Cobranza" $ opc[4]
		DO CCV
		
		***
		*FACTURACION
		***
	ELSEIF "Factura" $ opc[4]
  	select PRD
		DO FX
		
		***
		*RETENCIONES CLIENTES
		***
	ELSEIF "Retenc" $ opc[4]
		CR()
		

		***
		*PROVEEDORES
		***
	ELSEIF "Provee" $ opc[4]
		op2 = MENUFLASH( ym2, xm2, 1, .F., "", "Poveedores", "Proveedores Varios" )
     if lastkey()==K_ENTER
  		F_ABASE({"PRV"},"CERRAR")
        if op2==1
     		FBASES({"PROVEE","RETIB"})
           M->TIPOPROV := "E"
        else
     		FBASES({"PROVEEV","RETIB"})
           M->TIPOPROV := "V"
        endif
			PROVEEV(,.T.)
     endif

		***
		*COMPRAS VARIAS
		***
	ELSEIF "Compras Varias" $ opc[4]
		DO COMV

		***
		*CUENTAS CORRIENTES COMPRAS
		***
	ELSEIF "Pagos"$opc[4]
		op2 := MENUFLASH( ym2, xm2, 1, .F., "",  "Compras","Compras Varias" )
     if lastkey()==K_ENTER
			DO CCC WITH op2
     endif
		
		***
		*COMPRAS
		***
	ELSEIF "Compra" $ opc[4]
		DO COM
		

		***
		*UTILIDADES
		***
	ELSEIF "Utilidad" $ opc[4]
		SETCOLOR(C_MENU)
		PRIVATE aaux[17]
		aaux[ 1] = "Cambiar % I.V.A.              "
		aaux[ 2] = "Configuraci¢n                 "
		aaux[ 3] = "Fecha a usar ("+DTOC(VA->FECHA)+")"
		aaux[ 4] = "C¢digos de faltante"
		aaux[ 5] = "C¢digos de vales   "
		aaux[ 6] = "Cambiar A¤o        "
		aaux[ 7] = "% p/planilla de servicios"
		aaux[ 8] = "Dise¤o de Facturas"
		aaux[ 9] = "Control de Remitos"
		aaux[10] = "Fecha Cierre Sistema "+DTOC(VA->FECHSEG)
		aaux[11] = "Cambiar CLAVES "
		aaux[12] = "Pasar facturaci¢n a diskette"
		aaux[13] = "Turnos con arrastre(PLANILLAS)"
		aaux[14] = "Color"
		aaux[15] = "Actualizar Productos desde Suc.1"
		aaux[16] = "Desmarcar Remitos Sin Cierre"
		aaux[17] = "Agente Ret./Perc.IIBB"

		ym2 := ym2 - 7
		xm2 := 75-LEN(aaux[1])

		op = PP_SELEC(ym2, xm2, LEN(aaux), 0, aaux, 1, "UTILIDADES", "S", .T. )
		IF op == 1
			MARCO( ym2+2, xm2, ym2+3, xm2+23, "", "S", .T., 0 )
			M->PIVA1 = VA->PIVA1
			M->PIVA2 = VA->PIVA2
			SETCURSOR(SC_ON)
			@ ym2+2, xm2 SAY "%I.V.A. (1):" GET M->PIVA1 PICT "##.##"
			@ ym2+3, xm2 SAY "%I.V.A. (2):" GET M->PIVA2 PICT "##.##"
			READ
			IF LASTKEY() == K_ENTER
				SELECT VA
				FFLOCK()
				REPLACE VA->PIVA1 WITH M->PIVA1, VA->PIVA2 WITH M->PIVA2
				UNLOCK
				COMMIT
				op = MENUFLASH( ym2+2, xm2-2, 1, .F., "",  "RECALCULAR PRECIO FINAL ",;
															  	  		 "RECALCULAR NETOS        ",;
                                                      "NO RECALCULAR           " )
				IF op == 1
        		MENSAJE( 0, 0, 0, .F., "RECALCULANDO . . ." )
              nReg := RECNO()
              SELECT PRD
              FFLOCK()
              GO TOP
              DO WHILE !EOF()
						PRD->PRECVENTA := PRD->PRECBASE + PRD->IMPINT + (PRD->PRECBASE*VA->PIVA1/100)		//*PRD->EXENTO
              	SKIP
              ENDDO
              GO nReg
              DBUNLOCKALL()
              RECUPAN()
				ELSEIF op == 2
        		MENSAJE( 0, 0, 0, .F., "RECALCULANDO . . ." )
              nReg := RECNO()
              SELECT PRD
              FFLOCK()
              GO TOP
        		DO WHILE !EOF()
						PRD->PRECBASE := FNETOVENTA( PRD->GRUPO, PRD->PRECVENTA, PRD->CONIMPINT )
						M->TIPOIMPINT := FTIPOIMPINT
						PRD->IMPINT   := IF( M->TIPOIMPINT="%", PRD->PRECBASE*FIMPINT/100*PRD->CONIMPINT,FIMPINT*PRD->CONIMPINT )
           		SKIP
        		ENDDO
        		DBUNLOCKALL()
        		GO nReg
        		RECUPAN()
              DBUNLOCKALL()
        	ENDIF
			ENDIF
			RECUPAN()
			
		ELSEIF op == 2 						&& CONFIGURACION
			xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
								  "       º graba y º        ",;
								  " mueve º procede º  sale  "})
			SELECT VA
			aaux := NEWEDIT( "CONFVAR",,.T. )
			FEDITOR( aaux, "LEER" )
			aaux[ED_I] := 1
			aaux[ED_REGISTRO] := RECNO()
			aaux[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( aaux, { K_F10 } )
				IF aaux[ED_UPDATE]
					aaux[ED_MODE] = "MOSTRAR"
				ELSEIF aaux[ED_TECLA] == K_TAB
           	IF EDNOM(aaux) == "EST->DISCOAUX"
						op2 = MENUFLASH( aaux[ED_Y], aaux[ED_X], EST->DISCOAUX, .T., "", "X Def.","C:","D:","E:","F:","G:","H:" )
						IF LASTKEY() == K_ENTER
							EDPONE(aaux,"EST->DISCOAUX", CACHO("  C:D:E:F:G:H:",op2,2) )
						ENDIF
           	ELSEIF EDNOM(aaux) == "EST->SALIDA"
						op2 = MENUFLASH( aaux[ED_Y], aaux[ED_X], IF(EST->SALIDA="IMP",1,2), .T., "", "IMPRESORA", "PANTALLA" )
						IF LASTKEY() == K_ENTER
							EDPONE( aaux, "EST->SALIDA", IF(op2=1,"IMP","PAN") )
                 ENDIF
           	ELSEIF EDNOM(aaux) == "EST->IMPRESORA"
						op2 := MENUFLASH( aaux[ED_Y], aaux[ED_X], EST->IMPRESORA, .T., "", "Impresora ( 1 )", "Impresora ( 2 )", "Impresora ( 3 )" )
						if lastkey() == K_ENTER
							EDPONE( aaux, "EST->IMPRESORA", op2 )
						endif
           	ELSEIF EDNOM(aaux) == "EST->TIPOIMPR"
						op2 := MENUFLASH( aaux[ED_Y], aaux[ED_X], EST->TIPOIMPR, .T., "", "Matriz de Puntos", "Laser / Tinta" )
						if lastkey() == K_ENTER
							EDPONE( aaux, "EST->TIPOIMPR", if(op2==2,"LASER/TINT","MATRICIAL " ))
						endif
              ENDIF
					aaux[ED_MODE] = "MOSTRARTODO"
				ELSEIF ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_F10
           	FRLOCK("VA")
           	FRLOCK("EST")
					FEDITOR(aaux,"GRABAR",.F.)
					UT_largo := EST->LARGOHOJA
					EXIT
				ELSEIF aaux[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			FEDITOR(aaux,"SACAPAN")
			MENUDOWN(xmenu)
			
		ELSEIF op == 3
     	select PRD
			M->FECHA := QUEFECHA( ym2+1, xm2, VA->FECHA )
			IF LASTKEY() == K_ENTER
				SELECT VA
				FFLOCK()
				REPLACE VA->FECHA WITH M->FECHA
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
			
		ELSEIF op == 4					&& FALTANTES
			AEVAL( vconc, {|a,i|vconc[i]:=LEFT(a,LEN(a)-1)+IF(LEFT(a,4)$UT_FALTANTE,""," ")},1,LV(vconc) )
			IF MARCABRW( ym2+2,xm2-20, vconc, LV(vconc) ) # 0
				UT_FALTANTE := ""
				AEVAL( vconc, {|a,i| UT_FALTANTE+=IF(RIGHT(a,1)=="",LEFT(a,4),"")}, 1, LV(vconc) )
				SAVE ALL LIKE UT_* TO EST.CFG
			ENDIF
			
		ELSEIF op == 5					&& VALES
			AEVAL( vconc, {|a,i|vconc[i]:=LEFT(a,LEN(a)-1)+IF(LEFT(a,4)$UT_VALES,""," ")},1,LV(vconc) )
			IF MARCABRW( ym2+2,xm2-20, vconc, LV(vconc) ) # 0
				UT_VALES := ""
				AEVAL( vconc, {|a,i| UT_VALES+=IF(RIGHT(a,1)=="",LEFT(a,4),"")}, 1, LV(vconc) )
				SAVE ALL LIKE UT_* TO EST.CFG
			ENDIF
			
		ELSEIF op == 6
			nAux := if( val(cDirAno)==0, YEAR(DATE()), VAL(cDirAno) )
        DO WHILE .T.
				nAux := INGRVAL( 10, 20, "A¥O", nAux, "9999", "")
        	IF LASTKEY() == K_ENTER
           	if nAux == YEAR(DATE())
              	cDirAno := ""
                 EXIT
        		elseif len( DIRECTORY(STRZERO(nAux,4)+"\*.DBF") ) == 0
						MENSAJE( 0, 0, 10, .T., "NO HAY INFORMACION DEL A¥O"+STR(nAux,5)+" !!!" )
           	else
              	cDirAno := STRZERO(nAux,4)+"\"
                 EXIT
           	endif
        	ELSEIF LASTKEY() == K_ESC
        		EXIT
        	ENDIF
        ENDDO
        FBASES({"PROD"})
			
		ELSEIF op == 7
			MENUDOWN({"  <+>  º PgUp   º  F3   º   F4   º ESC  ",;
				       "       º PgDown º       º        º      ",;
				       " mueve º mueve+ º busca º busca+ º sale "})
			PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
			bcamp[ 1] = "GR->(RECNO())"
			bcamp[ 2] = "GR->DESCGRUP"
			bcamp[ 3] = "GR->PORC"
			bmasc[ 1] = "999"
			bmasc[ 2] = "@!"
			bmasc[ 3] = ""
			bcab[ 1] = "C¢digo"
			bcab[ 2] = "Grupo"
			bcab[ 3] = "Porc."
			bedit = "FFM"
			SELECT GR
			lastreg = RECNO()
			r = BROW(10, 5, 19, 50, "GRUPOS", bcamp, bmasc, bcab, bedit ) 	&&,"REEVARIOS(tecla)", "tecla=-4.OR.tecla=-5.OR.tecla=32" )
			RECUPAN()
			
		ELSEIF op == 8
			BL( 10, 10 )
			
		ELSEIF op == 9
			DO SREM
			
		ELSEIF op == 10
			aux := QUEFECHA( ym2+1, xm2, VA->FECHSEG )
			IF LASTKEY() == K_ENTER
				SELECT VA
				FFLOCK()
				REPLACE VA->FECHSEG WITH aux
				DBUNLOCK()
				DBCOMMIT()
			ENDIF
			
		ELSEIF op == 11						&& CLAVES
			op2:=MENUFLASH( ym2, xm2, 1, .F., "",  "Clave Nivel 1","Clave Nivel 2" )
        if lastkey()==K_ENTER
        	cCampo:=if(op2==1,"CLAVE","CLAVEP")
     		select VA
     		if empty(VA->&(cCampo))
        		aux := VA->&(cCampo)
					aux := INGRVAL( 10, 20, "Nueva Clave:", aux, "XXXXXXXXXX", "")
        		IF LASTKEY() == K_ENTER
        			FRLOCK();	VA->&(cCampo):=aux;	DBUNLOCK()
        		ENDIF
     		else
        		if FCLAVE(VA->&(cCampo))
        			aux := VA->&(cCampo)
						aux := INGRVAL( 10, 20, "Nueva Clave:", aux, "XXXXXXXXXX", "")
           		IF LASTKEY() == K_ENTER
           			FRLOCK();	VA->&(cCampo):=aux;	DBUNLOCK()
           		ENDIF
        		endif
     		endif
        endif
			
		ELSEIF op == 12
     	DO PASFAC
			
		ELSEIF op == 13
     	aaux := ARRAY(LEN(aturno))
			AEVAL( aturno, {|a,i| aaux[i]:=a+IF(LEFT(a,1)$UT_TURCONARR,""," ")})
			IF MARCABRW( ym2+2,xm2-20, aaux, LEN(aaux) ) # 0
				UT_TURCONARR := ""
				AEVAL( aaux, {|a,i| UT_TURCONARR+=IF(RIGHT(a,1)=="",LEFT(a,1),"")})
				SAVE ALL LIKE UT_* TO EST.CFG
			ENDIF
			
		ELSEIF op == 14
     	CFGCOLOR()
			
		ELSEIF op == 15 .and. "SUR2"$curdir()
			MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
			aaux :={ "STOCKMIN",;
						"STOCKMAX",;
						"CONDEP",;
						"DEPOSITO",;
						"FECHA",;
						"STOCKINI",;
						"COMPRAS",;
						"VENTAS",;
						"AJUSTES",;
						"STOCKACT",;
						"CONSTOCK",;
						"CAPACIDAD"}
     	nSelect := 0
        do while .t.
           dbusearea(.T.,, "\SUR\EST\PROD", "X", .T., .T. )
           if dbf()=="X"
           	exit
           endif
        enddo
     	nSelect := select()
        dbgotop()
        nAux := lastrec()
        select PRD
        do while ROSCA().and.!X->(eof())
        	if X->CODPROD#0
        		if !dbseek(X->CODPROD)
           		F_ALTA({||PRD->CODPROD#0})
           	endif
           	frlock()
           	for i=1 to fcount()
           		if ascan(aaux,field(i))==0 .and. PRD->(fieldget(i))#X->(fieldget(i))
              		fieldput( i, X->(fieldget(i)) )
              	endif
           	next
           endif
           @ 24,70 say --nAux pict "#####"
        	skip 1 alias X
        enddo
        dbunlockall()

        select (nSelect);  dbclosearea()
     	nSelect := 0
        do while .t.
           dbusearea(.T.,, "\SUR\EST\GRUPO", "X", .T., .T. )
           if dbf()=="X"
           	exit
           endif
        enddo
     	nSelect := select()
        dbgotop()
        nAux := lastrec()
        select GR
        for r=1 to X->(lastrec())
        	X->(dbgoto(r))
        	if X->(recno())>GR->(lastrec())
        		add_rec()
           endif
        	dbgoto(r)
          	frlock()
           for i=1 to fcount()
              fieldput( i, X->(fieldget(i)) )
           next
           @ 24,70 say --nAux pict "#####"
        next
        dbunlockall()
        select (nSelect);  dbclosearea()
        select PRD
        GO TOP
        RECUPAN()

		ELSEIF op == 16
     	FBASES({"+CCV","+REM"})
  		select CCV
     	set order to forder({"CODCLI","NUMCOB"})
     	select RE
     	set order to forder({"FECHA"})
     	nAux:=0
     	XF:="RE"
     	ym2:=10;  xm2:=30
     	if QUEFECHA2()
        	MENSAJE(99,99,0,.F.,"AGUARDE...")
           DESDE:=if(DESDE<ctod("1/6/97"),ctod("1/7/97"),DESDE)
        	dbseek( ftoc(DESDE), .T. )
        	select CCV
        	do while BETWEEN((XF)->FECHA,DESDE,HASTA) .and. !(XF)->(eof())
     			if dbseek(str((XF)->CODCLI,FLEN(CCV->CODCLI))+(XF)->NUMCOB)
     			else
                 if !empty((XF)->NUMCOB)
              		@24,70 say ++nAux pict "######"
                 endif
						frlock(XF)
              	(XF)->NUMCOB:=""
              	(XF)->(dbunlock())
     			endif
           	skip 1 alias (XF)
        	enddo
     		select PRD
           RECUPAN()
     	endif
     	select CCV
     	set order to 1
     	select RE
     	set order to 1

		ELSEIF op == 17
			do IB

		ENDIF
		RECUPAN()
		
		
	ELSEIF "Salida" $ opc[4]
		EXIT
		
	ENDIF
	
ENDDO

CLOSE DATABASE
SAVE ALL LIKE UT_* TO EST.CFG
SAVE ALL LIKE VA->FECHA TO TODOBIEN.EST
SET COLOR TO W/N
SETCURSOR(SC_ON)
CLEAR
QUIT


************

FUNC QUECOD2

************
PARAMETERS _y, _x, conhoja
_y = IF( PCOUNT()<1, ym2, _y )
_x = IF( PCOUNT()<2, xm2, _x )
conhoja = IF( PCOUNT()<3, 1, conhoja )

SET CONFIRM ON
SETCURSOR( 1 )
STORE 0 TO DESDE, HASTA
MARCO( _y, _x, _y+conhoja, _x+25, "", "S", .T., 0 )
@ _y, _x  SAY "DESDE que C¢digo:" GET DESDE PICT MASCARA("CODPROD") 		&& VALID VALIDO("CODPROD",DESDE)
@ _y+1,_x SAY "HASTA que C¢digo:" GET HASTA PICT MASCARA("CODPROD") 		&& VALID VALIDO("CODPROD",HASTA)
IF conhoja = 2
	@ _y+2,_x SAY "N§ de la 1§ Hoja:" GET PRIHOJA PICT "999"
ENDIF
READ
RECUPAN()
SET CONFIRM OFF

RETURN IF( LASTKEY()=13, .T., .F. )


***************

FUNC QUEFALTA( XF, cTitulo )

***************
DEFAULT cTitulo TO XF
					set order to 1
					nAux:=(XF)->NUMFAC+1
					skip 1
					do while BETWEEN((XF)->FECHA,DESDE,HASTA).and.!(XF)->(eof())
						if (XF)->NUMFAC > nAux
                 	if nMal == 0
								? "Faltan "+cTitulo+" "+cSUCURSAL
								? "---------------------------"
                    endif
							if ( FIELD->NUMFAC-1 - nAux ) > 10
    							? FIELD->FECHA, "("+ alltrim(str(nAux))+ "..."+ alltrim(str(FIELD->NUMFAC-1))+ ")"
       						nMal += (FIELD->NUMFAC-1 - nAux)
     					else
								for i=nAux TO FIELD->NUMFAC-1
     							? FIELD->FECHA, "("+ alltrim(str(i))+ ")"
        						++nMal
								next
							endif
    						@ 23, 65 say nMal pict "####"
						endif
						nAux := FIELD->NUMFAC+1
  					@ 21, 65 say (XF)->FECHA
  					@ 22, 65 say ++nRev pict "####"
  					skip 1 alias (XF)
					enddo
              if nMal>0
						? "---------------"
						? nMal
              endif

return nMal
