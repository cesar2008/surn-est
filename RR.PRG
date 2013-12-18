LOCAL oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " REMITOS " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
FBASES({ "REM", "REM2", "CCV" })

RG_CODPROD    := 1
RG_CANTIDAD   := 2
RG_DESCPROD   := 3
RG_PRECUNIT   := 4
RG_IMPORTE    := 5
RG_PORCDESC   := 6
RG_DESCUENTO  := 7
RG_PRECBASE   := 8
RG_NETO_VENTA := 9
RG_IMPINT     := 10
RG_IVA1       := 11
RG_IVA2       := 12
RG_TPRECBASE  := 13
RG_TDESCUENTO := 14
RG_TNETO_VENTA:= 15
RG_TIMPINT    := 16
RG_TIVA1      := 17
RG_TIVA2      := 18
RG_RUBRO      := 19
RG_TIPOIMPINT := 20
RG_REGISTRO   := 21

#define RE_Y1		  14
#define RE_X1		   9
#define RE_Y2		  20
#define RE_X2		  78

aCpo2:={;
	{ "CODPROD",    "C¢digo",                             '', 'M',  '',  0, 0 },;
	{ "CANTIDAD",   "Cantidad",                           '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                      '', 'F',  '',  0, 0 },;
	{ "PRECUNIT",   "Prec.Unit",              '@Z ####.####', 'F',  '',  0, 0 },;
	{ "IMPORTE",    "Importe",               '@Z #####.####', 'M', 'N', 10, 3 },;
	{ "PORCDESC",   "",                          '@Z ###.##',  '', 'N',  6, 2 },;
	{ "DESCUENTO",  "",                       '@Z #####.###',  '', 'N', 10, 5 },;
	{ "PRECBASE",   "",                      '@Z #####.####', 'F',  '',  0, 0 },;
	{ "NETO_VENTA", "",                                   '',  '', 'N', 10, 5 },;
	{ "IMPINT",     "",                                   '',  '', 'N', 10, 5 },;
	{ "IVA1",       "",                                   '',  '', 'N', 10, 5 },;
	{ "IVA2",       "",                                   '',  '', 'N', 10, 5 },;
	{ "TPRECBASE",  "",                                   '',  '', 'N', 10, 5 },;
	{ "TDESCUENTO", "",                                   '',  '', 'N', 10, 5 },;
	{ "TNETO_VENTA","",                                   '',  '', 'N', 10, 5 },;
	{ "TIMPINT",    "",                                   '',  '', 'N', 10, 5 },;
	{ "TIVA1",      "",                                   '',  '', 'N', 10, 5 },;
	{ "TIVA2",      "",                                   '',  '', 'N', 10, 5 },;
	{ "RUBRO",      "",                                   '',  '', 'N',  3, 0 },;
	{ "TIPOIMPINT", "",                                   '',  '', 'N',  3, 0 },;
	{ "REGISTRO",   "",                                   '',  '', 'N',  0, 0 } }

SELECT RE2
aCpo2 := FARRAYAUX( aCpo2 )
aCpo2[RG_CODPROD ,ATB_MASC] := "@Z "+ aCpo2[RG_CODPROD ,ATB_MASC]
aCpo2[RG_DESCPROD,ATB_MASC] := "@K"+ REPLICATE( "!", LEN(aCpo2[RG_DESCPROD,ATB_MASC]) )
aCpo2[RG_CANTIDAD,ATB_MASC] := "@Z "+ aCpo2[RG_CANTIDAD,ATB_MASC]

INICIO=.T.

AXR:={}
AADD( AXR, AREG0( aCpo2 ) )
STORE 0 TO M->DESCUENTO, M->SUBTOTAL, M->TIVA1, M->TIVA2, M->TOTAL,;
		M->TPRECBASE, M->TIMPINT, M->PORCDESC, M->PIVA, M->PIVA1, M->PIVA2
MODIFICABLE := .T.


NROW=1
SETCOLOR( "W/N,W/N" )
OX2:=MYABROWSE( RE_Y1, RE_X1, RE_Y2, RE_X2, aCpo2, AXR, "AXR" )
OX2:CARGO[TB_REFRESH] := .1
OX2:GOTOP()
OX2:CARGO[TB_EDIT] := LOWER( OX2:CARGO[TB_EDIT] )
aedits := TBCOLEDIT( "SETEAR", "REM2", OX2, aedits )
TBCOLOR(OX2)
SETCOLOR( "W/N,N/W" )

aCpo:={;
	{ "NUMFAC"       ,"N§Remito"            ,'', 'E',  '',  0, 0 },;
	{ "FECHA"        ,"Fecha"               ,'', 'M',  '',  0, 0 },;
	{ "TURNO"        ,"T;u"                 ,'', 'M',  '',  0, 0 },;
	{ "CODCLI"       ,"C¢d;cli"             ,'', 'M',  '',  0, 0 },;
	{ "FCLIENTE(CODCLI)" ,"Cliente", REPLIC('X',20), "F", 'F', 20, 0 },;
	{ "TOTAL"        ,"Total"                   ,'', 'E',  '',  0, 0 },;
	{ "CCV->FECHCIERRE","Fecha;cierre"          ,'', 'F', 'F',  8, 0 },;
	{ "ID_CCV"       ,"C¢digo;CCV"              ,'', 'E',  '',  0, 0 }}

select CCV
SET ORDER TO FORDER({"CODCLI","ID_CCV"})
SELECT RE
aCpo := FBASEAUX( aCpo, "RE", SELECT(), .F. )
DBGOBOTTOM()
nORDEN := 1
SET ORDER TO nORDEN

arem := NEWEDIT( "REM",.F.,.T. )

MENUDOWN({"  <+>  º F2 modif. º   F5   º  F7   º  F8   º  * / \  º  TAB   º ESC  ",;
			  "       º F3 busca  º        ºremitosº  suma º detalle º produc-º      ",;
			  " mueve º F4 busca+ º agrega ºx cli. º x dia º remito  º   tos  º sale "})

SETCOLOR( "W/N,N/W" )

DISPBOX( 2,0,13,79,"ÜÜÜÞßßßÝ","W+/N")
oX := MYBROWSE( 3, 1, 12, 78, aCpo )
oX:COLORSPEC := "W/N, W+/N, N/W, *N/W"
oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "REM", OX, aedits )
TBCOLOR(OX)

FREM(OX)
set relation to str(RE->CODCLI)+RE->ID_CCV into CCV
DO WHILE .T.
	MOVBROW( oX, {||nK==K_TAB.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_F10.OR.nK==K_F8.OR.CHR(nK)$'*/'.OR.nK==K_F7.OR.nK==K_ALT_E.OR.nK==K_F3.OR.nK==K_F4}, {||FREM(OX)}, {||EMPTY(CCV->FECHCIERRE).AND.FIELD->FECHA>VA->FECHSEG} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF" .OR. oX:Cargo[TB_RET] == K_TAB
		IF TBNOC(OX) == "FECHA"
			FRLOCK()
			RE->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
			oX:RefreshAll()
		ELSEIF TBNOC(OX) == "NUMFAC" .AND. RE->&(TBNOC(OX)) # oX:CARGO[TB_CONT] .AND. oX:Cargo[TB_MSGE] == "MODIF"
			M->NUMFAC   := oX:CARGO[TB_CONT]
			CAMBIOREM(OX)
			FREM(OX)
		ELSEIF TBNOC(OX) == "CODCLI"
			ele := RE->CODCLI
			IF oX:Cargo[TB_RET] == K_TAB
				IF FELEGIR("CLIENTE",RE->CODCLI) # 0
					ele := CL->CODCLI
				ENDIF
			ENDIF
			FCLIENTE(ele)
			r := .T.
			M->NUMFAC  := RE->NUMFAC
        IF ele # RE->CODCLI
				FRLOCK()
				RE->CODCLI  := ele
				UNLOCK
				oX:RefreshAll()
        ENDIF
		ELSEIF oX:Cargo[TB_MSGE] == "MODIF"
			FRLOCK()
			RE->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
			UNLOCK
			oX:RefreshAll()
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F5
		MODIFICABLE := .T.
		xmenu:=MENUDOWN({"     º     +     º     -      º  ENTER   º    *    º ESC  ",;
							  "       º suma 1 al º resta 1 al º          º graba y º      ",;
							  " mueve º n§ remito º n§ remito  º confirma º   sale  º sale "})
		FEDITOR(arem,"PONEPAN")
		FEDITOR( arem, "LEER" )
		arem[ED_I] := 1
		arem[ED_REGISTRO] := RECNO()
		EDPONE(arem,"RE->NUMFAC", ULREM()+1 )
		EDPONE(arem,"RE->FECHA",  VA->FECHA)
		EDPONE(arem,"RE->TURNO",  VA->TURNO)
		EDPONE(arem,"RE->CODCLI", VA->CODCLI)
		arem[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( arem, { 42, 43, 45 } )
			IF ( arem[ED_UPDATE] .OR. arem[ED_TECLA]==K_TAB ) .AND.  arem[ED_TECLA]#42
				arem[ED_MODE] = "MOSTRAR"
				IF EDNOM(arem) == "RE->CODCLI"
					IF arem[ED_TECLA] == K_TAB
						IF FELEGIR("CLIENTE") # 0
							EDPONE( arem,, CL->CODCLI )
						ENDIF
					ENDIF
             	FCLIENTE( EDCONT(arem,"RE->CODCLI") )
				ELSEIF EDNOM(arem) == "RE->TURNO" .AND. arem[ED_TECLA]==K_TAB
					ele = PP_SELEC( arem [ED_Y], arem[ED_X], 0, 0, aturno, EDCONT(arem), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(arem,,LEFT(aturno[ele],1))
					ENDIF
					RECUPAN()
				ENDIF
				arem[ED_MODE] := "MOSTRARTODO"
			ELSEIF arem[ED_TECLA] == 43 .AND. EDNOM(arem)=="RE->NUMFAC"
				EDPONE( arem, "RE->NUMFAC", EDCONT(arem)+1 )
				arem[ED_MODE] := "MOSTRAR"
			ELSEIF arem[ED_TECLA] == 45 .AND. EDNOM(arem)=="RE->NUMFAC"
				EDPONE( arem, "RE->NUMFAC", EDCONT(arem)-1 )
				arem[ED_MODE] := "MOSTRAR"
			ELSEIF ( arem[ED_TECLA] == K_ENTER .AND. arem[ED_I] == LEN(arem[ED_EDIT]) ) .OR. arem[ED_TECLA] == K_ESC .OR. arem[ED_TECLA] == 42
				FCLIENTE( EDCONT(arem,"RE->CODCLI") )
				r := "C"
				IF arem[ED_TECLA] == 42
					r := "G"
				ELSEIF FEDITOR( arem, "HUBOCAMBIOS" )
					r := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
				ENDIF
				IF r == "G"
					r := "G"
					IF EDCONT(arem,"RE->NUMFAC") == 0
						MENSAJE( 0, 0, 10, .T., " NUMERO DE REMITO INCORRECTO !!!")
						r := "C"
					ELSEIF oX:Cargo[TB_RET] == K_F5
              	xord:=INDEXORD()
                 DBSETORDER( 1 )
						SEEK EDCONT(arem,"RE->NUMFAC")
						IF FOUND()
							MENSAJE( 0, 0, 10, .T., "REMITO REPETIDO !!!")
							r := "C"
						ELSE
							arem[ED_REGISTRO] := F_ALTA( "        0" )
						ENDIF
                 SET ORDER TO xord
					ENDIF
					IF r == "G"
						GO arem[ED_REGISTRO]
						FEDITOR(arem,"GRABAR",.F.)
                 FRLOCK("VA")
                 IF VA->TURNO # EDCONT(arem,"RE->TURNO")
                 	VA->TURNO := EDCONT(arem,"RE->TURNO")
                 ENDIF
                 IF VA->CODCLI # EDCONT(arem,"RE->CODCLI")
                 	VA->CODCLI := EDCONT(arem,"RE->CODCLI")
                 ENDIF
                 IF VA->ULREM < EDCONT(arem,"RE->NUMFAC")
                 	VA->ULREM := EDCONT(arem,"RE->NUMFAC")
                 ENDIF
						DBUNLOCK()
						EXIT
					ENDIF
				ELSEIF r == "S"
					EXIT
				ENDIF
			ENDIF
		ENDDO
		FEDITOR(arem,"SACAPAN")
		MENUDOWN(xmenu)
		oX:GOTOP()
		oX:RefreshAll()
		DBGOTO( arem[ED_REGISTRO] )
		FREM(OX)
		IF r == "G"
			DISPBOX(2,0,13,79,"°°°°°°°°","W+/N")
			MODIFICABLE := .T.
			OX:COLORRECT( { OX:ROWPOS, 1, OX:ROWPOS, OX:COLCOUNT }, { 4, 4 } )
			oX:RefreshCurrent()
			RREM()
			DISPBOX( 2, 0, 13, 79,"ÜÜÜÞßßßÝ","+W/N")
			FREM(OX)
			oX:RefreshCurrent()
		ENDIF
	ELSEIF CHR(oX:Cargo[TB_RET]) $ "*/\"
		IF EMPTY(CCV->FECHCIERRE).AND.FIELD->FECHA>VA->FECHSEG
			DISPBOX(2,0,13,79,"°°°°°°°°","W+/N")
			MODIFICABLE := .T.
			OX:COLORRECT( { OX:ROWPOS, 1, OX:ROWPOS, OX:COLCOUNT }, { 4, 4 } )
			oX:RefreshCurrent()
			RREM()
			DISPBOX( 2, 0, 13, 79,"ÜÜÜÞßßßÝ","+W/N")
			FREM(OX)
			oX:RefreshCurrent()
     ELSE
     	TONE(100,1)
     ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_F3 .OR. OX:Cargo[TB_RET] == K_F4
  	BUSCADOR( OX:CARGO[TB_RET], OX )
	ELSEIF oX:Cargo[TB_RET] == K_F7
		if MARCARCLI()
     	IF QUEFECHA2(10,30)
				MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
     		select CL; aaux := {};  dbeval( {|| aadd(aaux,CL->CODCLI)}, {|| CL->MARCA==''} )
           select RE
        	xreg := RECNO()
           xord := INDEXORD()
           select RE
           dbsetorder( FORDER({"FECHA","TURNO"}) )
           dbseek( FTOC(DESDE), .T. )
           aux := XNAME("XAUX")
           copy to (aux) rest for FECHA>=DESDE .and. ascan(aaux,CODCLI)#0 while FECHA<=HASTA
#ifdef SUR
				select 99
           use (aux) alias X
           append from \SUR2\EST\REM for FECHA>=DESDE .and. FECHA<=HASTA .and. ASCAN(aaux,CODCLI)#0
           select 99;  dbclosearea()
#endif
           RECUPAN()
           LISTADOR("REMXCLI")
           select RE
           SET ORDER TO xord
           GO xreg
			ENDIF
		endif
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF EMPTY(CCV->FECHCIERRE)
			IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
				SELECT RE2
				SEEK RE->NUMFAC
				DO WHILE FOUND()
					BLANKREG()
					SEEK RE->NUMFAC
				ENDDO
				SELECT RE
				BLANKREG(.T.)
				SKIP -1
				FREM(OX)
				oX:RefreshAll()
			ENDIF
		ELSE
			MENSAJE( 0, 0, 10, .T., "PARA BORRARLO DEBE","DESMARCARLO DE LA CTA.CTE. !!!" )
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F8
  	nReg := RECNO()
  	DESDE := VA->FECHA
		DESDE := QUEFECHA( 10, 20, DESDE )
     IF LASTKEY() == K_ENTER
			MENSAJE( 99, 99, 0, .F., " SUMANDO ... " )
			aaux := {}
			SELECT RE
        nOrder := INDEXORD()
			DBSETORDER( FORDER({"FECHA","TURNO"}) )
			DBSEEK( FTOC(DESDE), .T. )
			DO WHILE FIELD->FECHA == DESDE .AND. !EOF()
  			AADD( aaux, { FIELD->TURNO, FIELD->CODCLI, FIELD->NUMFAC, FIELD->TOTAL } )
  			SKIP
			ENDDO
        SET CONSOLE OFF
        SET ALTERNATE TO "LISTADO.TXT"
        SET ALTERNATE ON
			IF LEN(aaux) == 0
  			? "* * *    NO HAY REMITOS   * * *"
			ELSE
  			ASORT( aaux,,,{|x,y| x[1]+STR(x[3],8) < y[1]+STR(x[3],8) } )
           xtur := aaux[1,1]
  			xcant:=xtot:=0
  			aa := {{},{}}; x:=1
           ? "--------------- turno: "+aaux[1,1] +" ---------------------"
           ?
  			FOR i=1 TO LEN(aaux)
     			IF aaux[i,1] # xtur
                 ?        "----------------------------------------"
  					? USING( "                      (üüü)   üüüüüüü.üü",{xcant,xtot})
                 xtur := aaux[i,1]
  					xcant:=xtot:=0
                 ?
           		? "--------------- turno: "+aaux[i,1] +" ---------------------"
              ENDIF
     			?     USING("üüüüüüüü ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ üüüüüüü.üü", {aaux[i,3],FCLIENTE(aaux[i,2]),aaux[i,4]} )
              ++xcant
              xtot += aaux[i,4]
           NEXT
           ?              "----------------------------------------"
  			?        USING("                      (üüü)   üüüüüüü.üü",{xcant,xtot})
			ENDIF
        SET ALTERNATE TO
        SET CONSOLE ON
        SET ORDER TO nOrder
        GO nReg
        RECUPAN()
  		mbuz:=MENUDOWN({"  <+>  º  ESC   ",;
                  		 "       º        ",;
                  		 " mueve º  sale  "})
  		MARCO( 1, 1, 20, 78, "", "D", .T., 0 )
  		MEMOEDIT( MEMOREAD('LISTADO.TXT'), 1, 1, 20, 78, .F., "FOUND()", 99 )
  		RECUPAN()
  		PONEPAN(mbuz)
 		ENDIF


	ELSEIF oX:Cargo[TB_RET] == K_F8
		aaux := { "RE->NUMFAC","RE->FECHA","RE->TURNO","RE->CODCLI","RE->TOTAL","CCV->FECHCIERRE" }
		AEVAL( aaux, {|a,i| aaux[i]:=LEFT(STRTRAN(a,"RE->","")+SPACE(14),14)+TRANS(ASCAN(axrem,a),"@Z 9") } )
		xmenu:=MENUDOWN({"     º ESPACIO  º      F8      º  ENTER   º ESC  ",;
							  "       º marca y  º   vuelve al  º          º      ",;
							  " mueve º desmarca º orden normal º confirma º sale "})
		lastcolor:=SETCOLOR("N/W,W+/N,,,N/W")
		aach := NEWACHO(aaux,,{7,30,0,0} )
		aach[ACH_CONDEXIT] := {|| k==32.OR.K==K_F8.OR.k==K_ENTER }
		MARCO( 4, 1, 4, 78, " ORDENADO POR ", "S", .T. )
		MARCO( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], " CAMPOS ", "S", .T. )
		DO WHILE .T.
			ASORT( aaux,,,{|x,y| RIGHT(x,1) < RIGHT(y,1)} )
			@ 4, 1 CLEAR TO 4, 78
			@ 4, 1 SAY AEVAL( aaux, {|a,i| QQOUT(IF(VAL(RIGHT(a,1))==0,"",TRIM(LEFT(a,11))+"+")) } )
			e := ACHOICE( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], aaux, .T., "funcacho", aach[ACH_ELE], aach[ACH_REL] )
			IF aach[ACH_TECLA] == K_SPACE
				IF RIGHT(aaux[e],1) = " "
					aux:=0 ; AEVAL( aaux, {|a| aux:=MAX(aux,VAL(RIGHT(a,1))) } )
					aaux[e] := LEFT(aaux[e],LEN(aaux[e])-1) + STR(aux+1,1)
				ELSE
					aux:=RIGHT(aaux[e],1)
					aaux[e] := LEFT(aaux[e],LEN(aaux[e])-1) + " "
					AEVAL(aaux, {|a,i| aaux[i]:=LEFT(aaux[i],14) + IF(RIGHT(a,1)>aux,STR(VAL(RIGHT(a,1))-1,1)," ")} )
				ENDIF
			ELSEIF aach[ACH_TECLA] == K_F8
				nORDEN := 1
				EXIT
			ELSEIF aach[ACH_TECLA] == K_ESC .OR. aach[ACH_TECLA]==K_ENTER
				EXIT
			ENDIF
		ENDDO
		RECUPAN()
		RECUPAN()
		IF aach[ACH_TECLA] == K_ENTER
			xaux := {} ; AEVAL( aaux, {|a,i| IF(RIGHT(a,1)==' ',,AADD(xaux,"RE->"+TRIM(LEFT(a,11))) ) } )
			aux := ARMARNTX(xaux)
			IF !EMPTY(aux)
*				IF aux == ARMARNTX(axrem)
*					r := ( UPPER( PREGUNTA( 12, "¨ REORDENO  [ S / N ] ?", "SsNn") ) == "S" )
*				ELSE
 					r := .T.
*				ENDIF
				IF r
					MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
					axrem := ACLONE(xaux)
					FAARCH("REMUS.SEQ","GRABAR",axrem)
              SELECT RE
              ********************
					aux := ARMARNTX(axrem)
              xaux := XNAME("XREM")
              cPath := ""
              base  := "REM"
					IF !EMPTY(aux)
						ABRIR_BASE( cPath+base, "RE", aux, cPath+xaux, .T. )
						IF INDEXKEY() # aux
							ABRIR_BASE( cPath+base, "RE", aux, cPath+xaux, .T. )
						ENDIF
  				ELSE
						ABRIR_BASE( cPath+base, "RE", "RE->NUMFAC", cPath+xaux, .T. )
					ENDIF
					USE (cPath+base) ALIAS RE INDEX (cPath+"RENUMFAC"), (cPath+"RECLIFC"), (cPath+"REFECTUR"), (cPath+xaux)
					SET ORDER TO 1
              *********************
*					FBASES({"-REM"})
*					FBASES({"+REM"})
					RECUPAN()
				ENDIF
			ENDIF
			nORDEN := FORDER({aux})
		ENDIF
		MENUDOWN(xmenu)
		SETCOLOR(lastcolor)
		SET ORDER TO nORDEN
		oX:RefreshAll()
	ELSEIF oX:Cargo[TB_RET] == K_F10
		MARCO( 10, 30, 11, 60, "", "S", .T., 0 )
		@ 10, 30 SAY "Desde:" GET DESDE
		@ 11, 30 SAY "Hasta:" GET HASTA
		READ
		RECUPAN()
		IF LASTKEY() == K_ENTER
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
		ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "REM", OX, aedits, "EDITS.EST" )
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO
select RE
set relation to
select CCV
SET ORDER TO 1
DBUNLOCKALL()
DBCOMMITALL()

RETURN



***************

FUNC FREM(OX)

***************
LOCAL r, K

DO WHILE .NOT. OX:Stabilize()
	IF INKEY() <> 0
		EXIT
	ENDIF
ENDDO

OX2:CARGO[TB_EDIT] := LOWER( OX2:CARGO[TB_EDIT] )
OX2:autoLite := .F.

M->TPRECBASE  := 0
M->PORCDESC   := 0
M->TDESCUENTO := 0
M->TNETO_VENTA:= 0
M->TIMPINT    := 0
M->TIVA1      := 0
M->TIVA2      := 0
M->TOTAL      := 0
M->PIVA1       := VA->PIVA1
M->PIVA2       := 0

STORE 0 TO FPRECBASE, FIMPINT, FREGART, FTIPOIMPINT, FPRECCOMPRA, NGRUPO, NUNXCAJA, FPRECVENTA, NRUBRO

ASIZE( AXR, 0 )
SELECT RE2
SEEK RE->NUMFAC
DO WHILE RE2->NUMFAC==RE->NUMFAC .AND. !RE2->(EOF())
	AADD( AXR, ARRAY( RG_REGISTRO ) )
	i := LEN(AXR)
  FPRODUCTO(FIELD->CODPROD)
	AXR[ i,RG_RUBRO      ] := NRUBRO
	AXR[ i,RG_PRECBASE   ] := FPRECBASE
	AXR[ i,RG_DESCUENTO  ] := FPRECBASE * FIELD->PORCDESC / 100
	AXR[ i,RG_NETO_VENTA ] := FPRECBASE - AXR[i,RG_DESCUENTO]
	AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
	AXR[ i,RG_IMPINT     ] := FIMPINT
	AXR[ i,RG_IVA1       ] := AXR[i,RG_NETO_VENTA] * M->PIVA1 / 100
	AXR[ i,RG_IVA2       ] := AXR[i,RG_NETO_VENTA] * M->PIVA2 / 100 * IF(CL->CATIVA=="RNI".AND.AXR[i,RG_RUBRO]==1,0,1)

	AXR[ i,RG_CODPROD    ] := FIELD->CODPROD
	AXR[ i,RG_DESCPROD   ] := FIELD->DESCPROD
	AXR[ i,RG_CANTIDAD   ] := FIELD->CANTIDAD
	AXR[ i,RG_TPRECBASE  ] := FIELD->TPRECBASE
	AXR[ i,RG_PORCDESC   ] := FIELD->PORCDESC
	AXR[ i,RG_TDESCUENTO ] := FIELD->TDESCUENTO
	AXR[ i,RG_TNETO_VENTA] := FIELD->TPRECBASE - FIELD->TDESCUENTO
	AXR[ i,RG_TIMPINT    ] := FIELD->TIMPINT
	AXR[ i,RG_TIVA1      ] := FIELD->TIVA1
	AXR[ i,RG_TIVA2      ] := FIELD->TIVA2
	AXR[ i,RG_PRECUNIT   ] := FIELD->PRECUNIT
	AXR[ i,RG_IMPORTE    ] := AXR[i,RG_PRECUNIT] * AXR[i,RG_CANTIDAD]

	AXR[i,RG_REGISTRO    ] := RECNO()
	SKIP
ENDDO
IF LEN(AXR) == 0
	AADD( AXR, AREG0(aCpo2) )
ENDIF
SELECT RE

oX2:RefreshAll()
DO WHILE .NOT. OX2:STABILIZE()
	IF INKEY() <> 0
		EXIT
	ENDIF
ENDDO

RETURN .F.


*********

FUNC RREM

*********
LOCAL xmenu, aaux, lhubocambios := .f.
DISPBOX(RE_Y1-1, RE_X1-1, RE_Y2+1, RE_X2+1,"ÜÜÜÞßßßÝ","W+/N")

SETCOLOR( "W/N,N/W" )
aedits := TBCOLEDIT( "SETEAR", "REM2", OX2, aedits )
IF MODIFICABLE
	OX2:CARGO[TB_EDIT] := UPPER( OX2:CARGO[TB_EDIT] )
ELSE
	OX2:CARGO[TB_EDIT] := LOWER( OX2:CARGO[TB_EDIT] )
ENDIF
OX2:autoLite := .T.
OX2:CARGO[TB_REFRESH] := 0

FCLIENTE( RE->CODCLI )
aaux := SETVARSIVA(CL->CATIVA)
M->PIVA1 := aaux[EST_IVA1]
M->PIVA2 := aaux[EST_IVA2]
M->PIVA  := M->PIVA1 + M->PIVA2

xmenu:=MENUDOWN({"  <+>  º    F2    º    F3    º   TAB    º F10 * / º ESC  ",;
						"       º          º  busca   º  elegir  º graba y º      ",;
						" mueve º modifica º producto º producto º  sale   º sale "})

FTOTALIZAR()
@ 21,69 SAY M->TOTAL PICT "#######.##" COLOR "W+/N"
guardar = .F.
DO WHILE .T.
	
	MOVABROW( OX2, AXR, {||nK==9.OR.nK==27.OR.CHR(nK)$'*/\'.OR.nK==K_F3.OR.nK==K_F10.OR.nK==K_ALT_E},;
		{||nK==999} )
	
	IF ( OX2:Cargo[TB_MSGE] == "MODIF" .OR. OX2:Cargo[TB_RET] == K_TAB .OR. OX2:Cargo[TB_RET] == K_F3 ) .AND. MODIFICABLE
		IF TBNOC(OX2) $ "CODPROD CANTIDAD IMPORTE"
			IF OX2:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX2:ColPos] := OX2:CARGO[TB_CONT]
           lhubocambios := .T.
			ENDIF
			IF TBNOC(OX2) == "CODPROD"
				IF OX2:Cargo[TB_RET] == K_TAB
					IF FELEGIR( "PRODUCTO", AXR[NROW,RG_CODPROD] ) # 0
						AXR[NROW,RG_CODPROD] := PRD->CODPROD
					ENDIF
				ELSEIF OX2:Cargo[TB_RET] == K_F3
					r := SELECTPRD()
					IF r # 0
						AXR[NROW,RG_CODPROD] := r
					ENDIF
				ENDIF
			ELSEIF TBNOC(OX2) == "CANTIDAD"
				AXR[NROW,RG_IMPORTE ] := AXR[NROW,RG_CANTIDAD] / IF(AXR[NROW,RG_PRECUNIT]==0,1,AXR[NROW,RG_PRECUNIT])
			ELSEIF TBNOC(OX2) == "IMPORTE"
				AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_IMPORTE] /  IF(AXR[NROW,RG_PRECUNIT]==0,1,AXR[NROW,RG_PRECUNIT])
			ENDIF
			AXR[ NROW, RG_DESCPROD   ] := LEFT(FPRODUCTO(AXR[NROW,RG_CODPROD]),20)
			AXR[ NROW, RG_RUBRO      ] := NRUBRO
			AXR[ NROW, RG_PRECBASE   ] := FPRECBASE
			AXR[ NROW, RG_DESCUENTO  ] := FPRECBASE * AXR[NROW,RG_PORCDESC] / 100
			AXR[ NROW, RG_NETO_VENTA ] := FPRECBASE - AXR[NROW,RG_DESCUENTO]
			AXR[ NROW, RG_TIPOIMPINT ] := FTIPOIMPINT
			AXR[ NROW, RG_IMPINT     ] := FIMPINT
			AXR[ NROW, RG_IVA1       ] := AXR[NROW,RG_NETO_VENTA] * M->PIVA1 / 100
			AXR[ NROW, RG_IVA2       ] := ( AXR[NROW,RG_NETO_VENTA] * M->PIVA2 / 100 ) * IF(CL->CATIVA=="RNI".AND.AXR[NROW,RG_RUBRO]==1,0,1)
			AXR[ NROW, RG_TPRECBASE  ] := AXR[NROW,RG_PRECBASE] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TDESCUENTO ] := AXR[NROW,RG_DESCUENTO] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TNETO_VENTA] := AXR[NROW,RG_NETO_VENTA] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TIMPINT    ] := AXR[NROW,RG_IMPINT] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TIVA1      ] := AXR[NROW,RG_IVA1] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TIVA2      ] := AXR[NROW,RG_IVA2] * AXR[NROW,RG_CANTIDAD]
 			AXR[ NROW, RG_PRECUNIT   ] := AXR[NROW,RG_NETO_VENTA] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA1] + AXR[NROW,RG_IVA2]
			AXR[ NROW, RG_IMPORTE    ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
*			AXR[ NROW, RG_PRECUNIT   ] := FPRECVENTA
			FTOTALIZAR()
			@ 21,69 SAY M->TOTAL PICT "#######.##" COLOR "W+/N"
		ELSEIF TBNOC(OX2) == "DESCPROD" .AND. OX2:CARGO[TB_MSGE] == "MODIF"
			AXR[NROW,OX2:ColPos] := OX2:CARGO[TB_CONT]
		ENDIF
		OX2:RefreshCurrent()
	ELSEIF OX2:Cargo[TB_RET] == 999 .AND. MODIFICABLE
		IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
			AADD( AXR, AREG0(aCpo2) )
		ENDIF
	ELSEIF CHR(OX2:Cargo[TB_RET]) $ "*/\"
		guardar := IF( ABS(RE->TOTAL-M->TOTAL)>.0009, .T., .F. )
		IF lhubocambios
     	guardar := .T.
     ENDIF
		EXIT
	ELSEIF OX2:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "REM2", OX2, aedits, "EDITS.EST" )
	ELSEIF OX2:Cargo[TB_RET] == K_ESC
		IF MODIFICABLE .AND. IF( RE->TOTAL#M->TOTAL, .T., .F. )
			aux := UPPER( PREGUNTA( 12, "[ G ] graba.       [ S ] sale.       [ C ] contin£a.", "GgSsCc") )
			IF aux $ "GS"
				guardar := ( aux == "G" )
				EXIT
			ENDIF
		ELSE
			EXIT
		ENDIF
	ELSEIF OX2:Cargo[TB_RET] == K_F10
		IF MODIFICABLE
			guardar := .T.
		ENDIF
		EXIT
	ENDIF
ENDDO

IF guardar
	SELECT RE2
	FFLOCK()
	FOR i=1 TO LEN(AXR)
		IF AXR[i,RG_IMPORTE] == 0
			IF AXR[i,RG_REGISTRO] # 0
				DBGOTO( AXR[i,RG_REGISTRO] )
				BLANKREG()
			ENDIF
		ELSE
			IF AXR[i,RG_REGISTRO] # 0
				DBGOTO( AXR[i,RG_REGISTRO] )
			ELSE
				DBGOTOP()
				IF RE2->NUMFAC#0 .OR. LASTREC()==0
					ADD_REC()
				ENDIF
			ENDIF
        FRLOCK()
			RE2->NUMFAC    := RE->NUMFAC
			RE2->FECHA     := RE->FECHA
			RE2->CODPROD   := AXR[i,RG_CODPROD]
			RE2->CANTIDAD  := AXR[i,RG_CANTIDAD]
			RE2->DESCPROD  := AXR[i,RG_DESCPROD]
			RE2->TPRECBASE := AXR[i,RG_TPRECBASE]
			RE2->PORCDESC  := AXR[i,RG_PORCDESC]
			RE2->TDESCUENTO:= AXR[i,RG_TDESCUENTO]
			RE2->TIMPINT   := AXR[i,RG_TIMPINT]
        RE2->TIVA1     := AXR[i,RG_TIVA1]
        RE2->TIVA2     := AXR[i,RG_TIVA2]
			RE2->PRECUNIT  := AXR[i,RG_PRECUNIT]
			RE2->IMPORTE   := AXR[i,RG_IMPORTE]
		ENDIF
	NEXT
	SELECT RE
	FRLOCK()
	RE->TOTAL := M->TOTAL
  RE->TIVA1 := M->TIVA1
  RE->TIVA2 := M->TIVA2
  RE->TIMPINT := M->TIMPINT
	OX:RefreshCurrent()
	DO WHILE .NOT. OX:Stabilize()
		IF INKEY() <> 0
			EXIT
		ENDIF
	ENDDO
	DBUNLOCKALL()
	DBCOMMITALL()
ENDIF
OX2:autoLite := .F.
oX2:RefreshAll()
DO WHILE .NOT. OX2:STABILIZE()
	IF INKEY() <> 0
		EXIT
	ENDIF
ENDDO
SELECT RE

MENUDOWN(xmenu)
DISPBOX(RE_Y1-1, RE_X1-1, RE_Y2+1, RE_X2+1,"°°°°°°°°","W+/N")

RETURN .T.


*******************

FUNC ULREM( cual )

*******************
LOCAL r:=0, xord:=INDEXORD(), xreg:=RECNO()

SET ORDER TO 1
DBGOBOTTOM()
r := FIELD->NUMFAC
SET ORDER TO xord
GO xreg

RETURN r


**************

FUNC CAMBIOREM(OX)

**************
LOCAL xreg:=RECNO(), xord:=INDEXORD(), r:=.T.

DBSETORDER( 1 )
SEEK M->NUMFAC

DO WHILE RE->NUMFAC==M->NUMFAC
	IF RECNO() # xreg
		r := .F.
		EXIT
	ENDIF
	SKIP
ENDDO
IF r
	GO xreg
	SELECT RE2
	FFLOCK()
	SEEK RE->NUMFAC
	DO WHILE FOUND()
		RE2->NUMFAC   := M->NUMFAC
		SEEK RE->NUMFAC
	ENDDO
	SELECT RE
	FRLOCK()
	RE->NUMFAC  := M->NUMFAC
	oX:GOTOP()
	oX:RefreshAll()
	DBGOTO(xreg)
ELSE
	MENSAJE( 0, 0, 10, .T., "REMITO REPETIDO !!!" )
ENDIF
SET ORDER TO xord

RETURN r



**********************

STATIC FUNC FTOTALIZAR

**********************

M->TPRECBASE  := 0
M->TDESCUENTO := 0
M->TIMPINT    := 0
M->TIVA1      := 0
M->TIVA2      := 0

FOR i=1 TO LEN(AXR)
	M->TPRECBASE  += AXR[i,RG_TPRECBASE]
  M->TDESCUENTO += AXR[i,RG_TDESCUENTO]
	M->TIMPINT    += AXR[i,RG_TIMPINT]
  M->TIVA1      += AXR[i,RG_TIVA1]
  M->TIVA2      += AXR[i,RG_TIVA2]
NEXT
M->TNETO_VENTA := M->TPRECBASE - M->TDESCUENTO
M->PORCDESC    := M->TDESCUENTO * 100 / IF(M->TNETO_VENTA==0,1,M->TNETO_VENTA)
M->TOTAL       := M->TNETO_VENTA + M->TIMPINT + M->TIVA1 + M->TIVA2

RETURN M->TOTAL
