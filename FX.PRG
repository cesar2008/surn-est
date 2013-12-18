LOCAL guardar, NUEVO, MODIFICABLE, modoaux, xedit, lSalir
PRIVATE EDX, ATOT, aCpoF

SET DELETED ON
#include "BL.CH"
#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

#define ym2   2
#define xm2   0
#define yi		9
#define yf		18
#define FAC_A_CC			(XF=="RE".OR.(XF$"FA FB".and.nMODO==K_F11))

RG_CODPROD	  := 1
RG_CANTIDAD  := 2
RG_DESCPROD  := 3
RG_PRECBASE  := 4
RG_PRECUNIT  := 5
RG_IMPORTE	  := 6
RG_PORCDESC  := 7
RG_DESCUENTO := 8
RG_IMPINT	  := 9
RG_IVA1		  := 10
RG_IVA2		  := 11
RG_TPRECBASE := 12
RG_TDESCUENTO:= 13
RG_TIMPINT	  := 14
RG_TIVA1 	  := 15
RG_TIVA2 	  := 16
RG_RUBRO 	  := 17
RG_TIPOIMPINT:= 18
RG_NEGOCIO	  := 19
RG_REGISTRO  := 20

SETCOLOR(C_FONDO)
MEMOEDIT( MEMOREAD("BOLETA.PAN"), 0, 0, 24, 79, ".F.", 180 )

MENSAJE( 0, 0, 0, .F., " AGUARDE ..." )
FBASES( { "PROD", "GRUPO", "FACA","FACA2", "FACB","FACB2", "REM","REM2", "CLIENTES", "ARTIC", "ARTIC2", "CLA", "TICKETS", "TICKETS2", "RUBRO","_BL","_BL2","EMPLEADO" }, .F. )
XF  := "FA"
XF2 := "FA2"

aCpoF:={;
	{ "CODPROD",	 "C¢digo",										'', 'F',  '',	0, 0 },;
	{ "CANTIDAD",	 "Cantidad",									'', 'M',  '',	0, 0 },;
	{ "DESCPROD",	 "Descripci¢n; ", 							'', 'M',  '',	0, 0 },;
	{ "PRECBASE",	 "",							  '@Z #####.####', 'F',  '',	0, 0 },;
	{ "PRECUNIT",	 "Prec.Unit",					'@Z ####.####', 'F',  '',	0, 0 },;
	{ "IMPORTE",	 "Importe", 				 '@Z ######.####', 'M', 'N', 10, 3 },;
	{ "PORCDESC",	 "",									'@Z ###.##',  '', 'N',	6, 2 },;
	{ "DESCUENTO",  "",								'@Z #####.###',  '', 'N', 10, 5 },;
	{ "IMPINT", 	 "",												'',  '', 'N', 10, 5 },;
	{ "IVA1",		 "",												'',  '', 'N', 10, 5 },;
	{ "IVA2",		 "",												'',  '', 'N', 10, 5 },;
	{ "TPRECBASE",  "",												'',  '', 'N', 10, 5 },;
	{ "TDESCUENTO", "",												'',  '', 'N', 10, 5 },;
	{ "TIMPINT",	 "",												'',  '', 'N', 10, 5 },;
	{ "TIVA1",		 "",												'',  '', 'N', 10, 5 },;
	{ "TIVA2",		 "",												'',  '', 'N', 10, 5 },;
	{ "RUBRO",		 "",												'',  '', 'N',	3, 0 },;
	{ "TIPOIMPINT", "",												'',  '', 'N',	3, 0 },;
	{ "REGISTRO",	 "",												'',  '', 'N',	0, 0 } }

select (XF2)
aCpoF := FARRAYAUX( aCpoF )
aCpoF[RG_CODPROD ,ATB_MASC] := "@Z "+ aCpoF[RG_CODPROD ,ATB_MASC]
aCpoF[RG_DESCPROD,ATB_MASC] := "@K"+ REPLICATE( "!", LEN(aCpoF[RG_DESCPROD,ATB_MASC]) )
aCpoF[RG_CANTIDAD,ATB_MASC] := "@Z "+ aCpoF[RG_CANTIDAD,ATB_MASC]

select TI;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()
select RE;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()
select FB;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()
select FA;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()


AXR	:= {}
lCCV	:= .F.
nMODO := 0
lMODIFICABLE  := .F.
lNuevo		  := .F.
lIMPRESO 	  := .F.

nB 		   := 1
nNUMERO    := 0
RNUMERO	   := nNUMERO
cTURNO	   := "1"
cCLIENTE   := SPACE(LEN(CLA->RAZONSOC))
nCODCLI	   := 0
cDOMCOM	   := SPACE(LEN(CLA->DOMCOM))
cCUIT 	   := SPACE(LEN(CLA->CUIT))
nCODLOC 	:= 0
dFECHA	   := VA->ULFECHA
dFECHEMI   := date()
cCODTARJ   := "   "
cNUMTARJ   := SPACE(LEN(FA->NUMTARJ))
cNUMCUPON  := SPACE(LEN(FA->NUMCUPON))
cVALORIZADO:= "S"
cOBSERV	   := SPACE(10)
nCODCORR   := 0
cCODEMP	   := EST->CODEMP
cID_CCV	   := ""

nTIPOVENTA := 1
nCONDVTA   := 1
cCATIVA	   := "   "
nSeconds   := SECONDS()

bRegVacio := {|a,i|;
	a[i,RG_CODPROD 	] := 0			,;
	a[i,RG_DESCPROD	] := SPACE(20) ,;
	a[i,RG_CANTIDAD	] := 0			,;
	a[i,RG_RUBRO		] := 0			,;
	a[i,RG_PRECBASE	] := 0			,;
	a[i,RG_PORCDESC	] := 0			,;
	a[i,RG_DESCUENTO	] := 0			,;
	a[i,RG_TIPOIMPINT ] := 0			,;
	a[i,RG_IMPINT		] := 0			,;
	a[i,RG_IVA1 		] := 0			,;
	a[i,RG_IVA2 		] := 0			,;
	a[i,RG_TPRECBASE	] := 0			,;
	a[i,RG_TDESCUENTO ] := 0			,;
  a[i,RG_TIMPINT	   ] := 0 			,;
  a[i,RG_TIVA1 	   ] := 0 			,;
	a[i,RG_TIVA2		] := 0			,;
	a[i,RG_PRECUNIT	] := 0			,;
  a[i,RG_IMPORTE	   ] := 0 			,;
  a[i,RG_NEGOCIO	   ] := " "			,;
  a[i,RG_REGISTRO   ] := 0 			}

DATOSCL(nCODCLI,.F.)
bTot := {||.t.}
bDetalle1 := {||.t.}
bDetalle2 := {||.t.}

M->TPRECBASE  := 0
M->PORCDESC   := 0
M->TDESCUENTO := 0
M->TIMPINT	  := 0
M->TIVA1 	  := 0
M->TIVA2 	  := 0
M->TOTAL 	  := 0
M->PIVA1		  := VA->PIVA1
M->PIVA2		  := 0

STORE 0 TO FPRECBASE, FIMPINT, FIMPINT2, FREGART, FPRECCOMPRA, NGRUPO, NUNXCAJA, FPRECVENTA, NRUBRO, NCONIMPINT
FTIPOIMPINT := " "

RECUPAN()

IF procname(1) == "FF"
	aPan := { "BOLETAA", "BOLETAB", "BOLETAR", "TICKETS" }
ELSE
	aPan := { "BOLETAAX", "BOLETABX", "BOLETARX", "TICKETS" }
ENDIF
#ifdef DOCSA
MENUDOWN({ "/ fact. A º+ tik.º  TAB  º  H  º  F2  º  F5  º F6  º  T  º   F9   º  F12  ºESC ",;
				"* fact. B º ant.º  ver  ºcaja º      º      º     ºcamb.ºclientesº agregaº    ",;
				"- Remitos º sig.ºcomprobºchicaºmodif.ºagregaºanulaºturnoº c/CUIT ºsin impºsale"})
#else
MENUDOWN({ "/ fact. A º+ tik.º  TAB  º  F2  º  F5  º F6  º  T  º   F9   º  F12  ºESC ",;
				"* fact. B º ant.º  ver  º      º      º     ºcamb.ºclientesº agregaº    ",;
				"- Remitos º sig.ºcomprobºmodif.ºagregaºanulaºturnoº c/CUIT ºsin impºsale"})
#endif

nB := 1
ATOT := NEWEDIT2( aPan[nB], .F., .F. )
FEDITOR( ATOT,"PONEPAN")
K := 0
lSalir := .F.
DO WHILE !lSalir
	lNuevo := .F.
	DBSELECTAREA( XF )
	RNUMERO := nNUMERO := FNUMERO()
	nCODCLI := FIELD->CODCLI
	DATOSCL(nCODCLI,.F.)
	nSeconds := IF( K==0, nSeconds, SECONDS() )

	SETCOLOR(C_FONDO)
	FVERREG( ATOT,, .T. )
	DETALLE(.T.)
	DBSELECTAREA( XF )
	@ 0, 77 SAY "   "
	@ 0, 0 SAY IF(lPermiso,"P"," ") COLOR "*N/W"

	SET(_SET_CURSOR,SC_OFF)
	K := INKEY(1)
	nMODO := K
	lCtrl := FT_CTRL()

	IF K == 0
  	if file("\SALIR.TMP");  quit;  endif
		@ 23, 72 say time() color C_MENUDN
		DBCOMMITALL()
		DBUNLOCKALL()
		if (SECONDS()-nSeconds) > VA->SECONDS
			if file("SAVSCR.BAT")
				aux := SAVESCREEN(0,0,24,79)
				RUN SAVSCR.BAT
				CLEARTYPEAHEAD()
				RESTSCREEN(0,0,24,79,aux)
			endif
			nSeconds := SECONDS()
		endif
	ELSEIF LASTKEY() == K_CTRL_L .AND. lCtrl
		IF lPermiso
			lPermiso := .F.
		ELSE
			IF FCLAVE(VA->CLAVE)
				lPermiso := .T.
			ELSE
				MENSAJE( 0, 0, 10, .T., " PERMISO DENEGADO !!!" )
				lPermiso := .F.
			ENDIF
		ENDIF
	ELSEIF K == K_UP
		SKIP -1
		IF BOF()
			TONE(500,1)
		ENDIF
	ELSEIF K == K_DOWN
		SKIP
		IF EOF()
			TONE(500,1)
			DBGOBOTTOM()
		ENDIF
	ELSEIF K == K_HOME
		DBGOTOP()
	ELSEIF K == K_END
		DBGOBOTTOM()
	ELSEIF K == K_PGUP
		SKIP -10
		IF BOF()
			TONE(500,1)
			DBGOTOP()
		ENDIF
	ELSEIF K == K_PGDN
		SKIP 10
		IF EOF()
			TONE(500,1)
			DBGOBOTTOM()
		ENDIF
	ELSEIF LASTKEY() == K_ESC
		lSalir := .T.
	ELSEIF LASTKEY() == 47											  //	/				( A )
		DISPBEGIN()
		nB  := 1
		XF  := "FA"
		XF2 := "FA2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == 42											  //	*				( B )
		DISPBEGIN()
		nB  := 2
		XF  := "FB"
		XF2 := "FB2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == 45						 //  -			  ( R )
		DISPBEGIN()
		nB  := 3
		XF  := "RE"
		XF2 := "RE2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == 43											  //	+				( T )
		DISPBEGIN()
		nB  := 4
		XF  := "TI"
		XF2 := "TI2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == K_TAB
		FELEFAC( XF )
	ELSEIF LASTKEY() == K_F9
		FELEGIR("CLA")
	ELSEIF LASTKEY() == K_F1 .and. lPermiso
		STA()
	ELSEIF LASTKEY() == K_ALT_M
		CALC()
	ELSEIF K==K_F5 .OR. (K==K_F2 .AND. FIELD->PASADO==' '.AND. lPermiso) .OR. K==K_F12 .OR. K==K_F11 .or. K==K_ALT_F5
		if K==K_F11
			nTIPOVENTA:=2;  cAux:="F11"
		elseif K==K_ALT_F5
			nTIPOVENTA:=3;  cAux:="AF5"
		else
			nTIPOVENTA:=1;  cAux:=if(K==K_F12,"F12","   ")
		endif
		@ 0, 77 say cAux color "*"+setcolor()
		IF K==K_F5 .OR. K==K_F12 .OR. K==K_F11 .OR. K==K_ALT_F5
			lNuevo  := .T.
			bNoRep  := {|x| IF( FREPEAT(x,"AGREGAR"), EVAL({|| MENSAJE(0,0,10,.T.,"NUMERO REPETIDO !!!" ),.F.}), .T. ) }
			nCODCLI := 0
		ELSE
			lNuevo := .F.
			bNoRep := {|x| IF( FREPEAT(x,"MODIF"), EVAL({|| MENSAJE(0,0,10,.T.,"NUMERO REPETIDO !!!" ),.F.}), .T. ) }
		ENDIF

		RNUMERO := nNUMERO := FNUMERO()
		DATOSCL(nCODCLI,.F.)
		FVERREG( ATOT,, .T. )
		DETALLE(.T.)
		xmenu2:=MENUDOWN({"  ENTER   º ESC  ",;
								"          º      ",;
								" confirma º sale "})
		lCCV := .F.
		ENCABEZADO()
		FVERREG( ATOT,, .T. )

		IF LASTKEY() == K_ENTER .AND. nCODCLI # 0
     	do while .t.
				if DETALLE(.F.)
					if GRABAR()
						if lPUBLICO 				//.OR. ( XF=="RE" .and. "DOCSA"$CURDIR() )
							if nMODO==K_F5 .or. nMODO==K_F11
                    	nUT := nT := 0
								lAux:=IMPRIMIR()
@0,1 say nUT pict "########"
? nT
							endif
						endif
						if lCCV
							select FAC
							FRLOCK()
							FAC->NUMFACC := nNUMERO
							DBUNLOCK()
							select CCV
							if DBSEEK( STR(nCODCLI,FLEN(CCV->CODCLI))+FTOC(FAC->FECHA) )
								FRLOCK()
								CCV->FACTURA := IF(nB==1,'A','B')+STRZERO(nNUMERO,8)
								DBUNLOCK()
							endif
						endif
					endif
              exit
					nCODCLI := 0
           else
           	exit
				endif
        enddo
		ENDIF
*		FBASES({"-"+cDiscoCentral+UT_SISTEMA+"\EST\FAC"+IF(nB==1,"A","B")+"CC", "-"+cDiscoCentral+UT_SISTEMA+"\EST\FAC"+IF(nB==1,"A","B")+"CC2","CCV"})
		lCCV := .F.
		PONEPAN(xmenu2)
		CLEARTYPEAHEAD()
	ELSEIF CHR(LASTKEY()) $ "Ss"
		SFAC(AXR)
	ELSEIF LASTKEY()==K_ALT_S .and. HASTA_SUC-DESDE_SUC#0
		aaux:={}
		for i=DESDE_SUC to HASTA_SUC
			aadd(aaux,"Sucursal "+str(i))
			if i==val(cSUCURSAL);  op:=i-DESDE_SUC+1;  endif
		next
		op:= PP_SELEC( 10, 30, 0, 0, aaux, op, "", "S", .T.)
		RECUPAN()
		if lastkey()==K_ENTER
			cSUCURSAL:=right(aaux[op],1)
			FREABRIR({"FACA","FACA2","FACB","FACB2"})
		endif
#ifdef ESFISCAL
	ELSEIF LASTKEY()==K_ALT_X .and. lPUBLICO
		if FCLAVE(VA->CLAVEP);  FISCAL("X");  endif
	ELSEIF LASTKEY()==K_ALT_Z .and. lPUBLICO
		if FCLAVE(VA->CLAVEP);  FISCAL("Z");  endif
	ELSEIF LASTKEY()==K_F8 .and. lPUBLICO
		FISCAL("C")
#else
	ELSEIF LASTKEY()==K_ALT_X
		DO REST
	ELSEIF LASTKEY()==K_ALT_Z
		if FCLAVE(VA->CLAVEP);  ZT(.T.);	endif
	ELSEIF CHR(LASTKEY())$"Zz"
		if FCLAVE(VA->CLAVEP);  ZT(.F.);	endif
#endif
	ELSEIF CHR(LASTKEY()) $ 'Tt'
		if CLAVEMP()
			cBase := DBF()
			cColor:=SETCOLOR(C_GET)
			cXmenu := MENUDOWN({ "     º   ENTER  º  ESC   ",;
										"       º          º        ",;
										" mueve º confirma º  sale  "})
			SELECT VA
			FREABRIR({"VARIOS"}) 			  // NUEVO
			EDX := NEWEDIT( "ULT"+cSUCURSAL )
			EDX[ED_MODE] = "MOSTRARTODO"
			FEDITOR( EDX, "SETVARS", K, .F. )
			if lPermiso
				i:=EDNUM(EDX,"VA->ULFECHA");	if i#0;	EDX[ED_EDIT]:=stuff(EDX[ED_EDIT],i,1,"E");  endif
			endif
			DO WHILE .T.
				FEDITAR( EDX, { K_ALT_F8, K_F10 } )
				IF EDX[ED_UPDATE]
					EDX[ED_MODE] = "MOSTRARTODO"
					if EDNOM(EDX)=="VA->ULTURNO"
						if EDCONT(EDX)==VA->ULTURNO
							EDPONE(EDX,"VA->ULFECHA",VA->ULFECHA)
						else
							cProximoTurno:=if( VA->ULTURNO=="3", "1", str(val(VA->ULTURNO)+1,1) )
							if EDCONT(EDX,"VA->ULTURNO") # cProximoTurno
								MENSAJE( 0, 0, 10, .T., "TURNO INCORRECTO !!! " )
								if !lPermiso
									EDPONE(EDX,,VA->ULTURNO)
								endif
							else
								if EDCONT(EDX,"VA->ULTURNO")=="1"
									EDPONE(EDX,"VA->ULFECHA",date()+1)
								endif
							endif
						endif
					endif
				ELSEIF EDX[ED_TECLA] == K_ALT_F8
					aaux := {{"FA","ULFACA"+cSUCURSAL,"NUMFAC"},{"FB","ULFACB"+cSUCURSAL,"NUMFAC"},{"RE","ULREM","NUMFAC"},{"TI","ULTICK","NUMFAC"}}
					FOR i=1 TO LEN(aaux)
						SELECT (aaux[i,1])
						aux := RECNO()
						DBGOBOTTOM()
						EDPONE( EDX, "VA->"+aaux[i,2], (aaux[i,1])->&(aaux[i,3]) )
						GO aux
					NEXT
					EDX[ED_MODE] = "MOSTRARTODO"
				ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
					aux := "S"
					IF EDX[ED_TECLA] == K_F10
						aux := "G"
					ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
						aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					ENDIF
					IF aux == "G"
						SELECT VA
						FEDITOR( EDX, "GRABAR", .F. )
						DBCOMMITALL()
						EXIT
					ELSEIF aux == "S"
						EXIT
					ENDIF
				ENDIF
			ENDDO
			FEDITOR(EDX,"SACAPAN")
			SELECT (cBase)
			PONEPAN(cXmenu)
			SETCOLOR(cColor)
		endif
	ELSEIF LASTKEY() == K_F6 .and. lPermiso
		r := .T.
		if DBF() $ "FA FB RE"
			if !empty(substr(FIELD->ID_CCV,4))
				MENSAJE( 0, 0, 10, .T., "PARA ANULAR ESTE COMPROBANTE HAY QUE DESMARCARLO","DE LA CUENTA CORRIENTE !!!" )
				r := !(dbf()=="RE")
			endif
		else
			r := lPERMISO
		endif
		if r
			set deleted on
			if PREGUNTA( 12, " ¨ ESTA SEGURO ?   [ S / N ]", "SsNn") $ "Ss"
				MENSAJE(0,0,0,.F.,"AGUARDE..." )
				SELECT (XF)
				FRLOCK()
				BLANKREG(,{"NUMFAC","FECHA","TURNO","FECHEMI","HORA","CODEMP"})
				FIELD->CODCLI := -2
				IF nB==1.OR.nB==2
					FIELD->RAZONSOC := "ANULADA"
				ENDIF
				SELECT (xF2)
				SET ORDER TO 1
				SEEK nNUMERO
				SELECT ART
				DO WHILE (XF2)->NUMFAC==nNUMERO
					IF XF$"FA FB" .and.(XF)->TIPOVENTA==2
              ELSE
						IF (XF2)->NEGOCIO == "*"
							SEEK (XF2)->CODPROD
							IF FOUND() .AND. (XF)->FECHA>=ART->FECHA
								FRLOCK()
								ART->STOCKACT += (XF2)->CANTIDAD
								FCOMPUESTO( (xF2)->CODPROD, +(xF2)->CANTIDAD, (xF)->FECHA )
								DBUNLOCK()
							ENDIF
                 ENDIF
					ENDIF
					SKIP 1 ALIAS (XF2)
				ENDDO
				select (XF2)
				do while dbseek(nNUMERO) .and. nNUMERO#0
					BLANKREG()
				enddo
				select (xF)
				cleartypeahead()
				RECUPAN()
			endif
		endif
	ELSEIF LASTKEY() == K_ALT_F6 .AND. lPermiso
		r := .T.
		IF DBF() $ "FA FB RE"
			IF !empty(substr(FIELD->ID_CCV,4))
				MENSAJE( 0, 0, 10, .T., "PARA ELIMINAR ESTE COMPROBANTE HAY QUE DESMARCARLO","DE LA CUENTA CORRIENTE  !!!" )
				r := .F.
			ENDIF
		ENDIF
		if r
			set deleted on
			IF PREGUNTA( 12, " ¨ ESTA SEGURO ?   [ S / N ]", "SsNn") $ "Ss"
				MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
				select (xF2)
				set order to 1
				seek nNUMERO
				select ART
				do while (XF2)->NUMFAC==nNUMERO
					if XF$"FA FB".and.(XF)->TIPOVENTA==2
              else
						if (XF2)->NEGOCIO == "*"
							seek (XF2)->CODPROD
							if found() .and. (XF)->FECHA>=ART->FECHA
								FRLOCK()
								ART->STOCKACT += (XF2)->CANTIDAD
								DBUNLOCK()
								if ART->COMPUESTO # 0
									FCOMPUESTO( (xF2)->CODPROD, +(xF2)->CANTIDAD, (xF)->FECHA )
								endif
							endif
                 endif
					endif
					skip 1 alias (XF2)
				enddo
				select (XF2)
				do while dbseek(nNUMERO)
					BLANKREG(.T.)
				enddo
				select (xF)
				BLANKREG()
				dbseek(nNUMERO,.T.)
				RECUPAN()
			endif
		endif
	ELSEIF LASTKEY() == K_CTRL_F1
		DO CER
	ELSEIF CHR(LASTKEY()) $ "Ff"
		DO FALTAN
#ifdef DOCSA
	ELSEIF CHR(LASTKEY()) $ "Hh"
		DO CAJCH
#endif
	ELSEIF K == K_F11 .AND. lPermiso
		STA()
	ENDIF
	IF lSalir
		IF procname(1) # "FF"
			EXIT
		ENDIF
		IF FCLAVE(VA->CLAVE)
			EXIT
		ELSE
			lSalir := .F.
		ENDIF
	ENDIF
	CLEARTYPEAHEAD()

ENDDO

RETURN



***********************

FUNC DETALLE( solover )

***********************
if nB==4
	AXR:=array(LINXTICK)
else
	if cSUCURSAL $ "24" .and. XF=="FB"
  	AXR:=array(LINXFAC_2)
  else
  	AXR:=array(LINXFAC)
  endif
endif
for i=1 to len(AXR)
	AXR[i] := array(RG_REGISTRO)
	eval( bRegVacio, @AXR, i )
next
bTot := {||;
		DEVPOS( 21, 1 ), QQOUT( TRANS(M->TDESCUENTO ,"#######.##") ),;
		DEVPOS( 21,14 ), QQOUT( TRANS(M->TPRECBASE  ,"#######.##") ),;
		DEVPOS( 21,27 ), QQOUT( TRANS(M->TIMPINT	  ,"#######.##") ),;
		DEVPOS( 21,40 ), QQOUT( TRANS(M->TIVA1 	  ,"#######.##") ),;
		DEVPOS( 21,53 ), QQOUT( TRANS(M->TIVA2 	  ,"#######.##") ),;
		DEVPOS( 21,66 ), QQOUT( TRANS(M->TOTAL 	  ,"#######.##") ) }

bDetalle1 := {|i,y|;
	DEVPOS( y,	0 ), QQOUT( TRANS(AXR[i,RG_NEGOCIO ], "X" ) ),;
	DEVPOS( y,	1 ), QQOUT( TRANS(AXR[i,RG_CODPROD ], aCpoF[RG_CODPROD ,ATB_MASC]) ),;
	DEVPOS( y, 40 ), QQOUT( TRANS(AXR[i,RG_PRECUNIT], aCpoF[RG_PRECUNIT,ATB_MASC]) ),;
	DEVPOS( y, 58 ), QQOUT( TRANS(AXR[i,RG_TDESCUENTO], '@Z #####.###') ) }

bDetalle2 := {|i,y|;
	DEVPOS( y,	7 ), QQOUT( TRANS(AXR[i,RG_DESCPROD], aCpoF[RG_DESCPROD,ATB_MASC]) ),;
	DEVPOS( y, 28 ), QQOUT( TRANS(AXR[i,RG_CANTIDAD], aCpoF[RG_CANTIDAD,ATB_MASC]) ),;
	DEVPOS( y, 50 ), QQOUT( TRANS(AXR[i,RG_PORCDESC], aCpoF[RG_PORCDESC,ATB_MASC]) ),;
	DEVPOS( y, 68 ), QQOUT( TRANS(AXR[i,RG_IMPORTE ], aCpoF[RG_IMPORTE ,ATB_MASC]) ) }

STORE 0 TO M->TDESCUENTO, M->TIVA1, M->TIVA2, M->TOTAL,;
	M->TPRECBASE, M->TIMPINT, M->PORCDESC

M->PIVA1		 := VA->PIVA1
M->PIVA2		 := 0
IF cCATIVA == "RNI"
	M->PIVA2		 := VA->PIVA2
ENDIF

SELECT (XF2)
IF lCCV
	bCond := {|| FAC2->NUMFAC==FAC->NUMFAC}
	SELECT FAC2
	SEEK FAC->NUMFAC
ELSE
	bCond := {|| (XF2)->NUMFAC==nNUMERO}
	SEEK nNUMERO
ENDIF
i := 0
DO WHILE EVAL(bCond) .AND. !EOF() .AND. i<LEN(AXR)
	++i
	FPRODUCTO(FIELD->CODPROD)
	AXR[ i,RG_RUBRO		] := NRUBRO
	AXR[ i,RG_PRECBASE	] := FPRECBASE
	AXR[ i,RG_DESCUENTO	] := FPRECBASE * FIELD->PORCDESC / 100
	AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
	AXR[ i,RG_IMPINT		] := FIMPINT
	AXR[ i,RG_IVA1 		] := AXR[i,RG_PRECBASE] * M->PIVA1 / 100
	AXR[ i,RG_IVA2 		] := AXR[i,RG_PRECBASE] * M->PIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[i,RG_RUBRO]==1,0,1)

	AXR[ i,RG_CODPROD 	] := FIELD->CODPROD
	AXR[ i,RG_DESCPROD	] := FIELD->DESCPROD
	AXR[ i,RG_CANTIDAD	] := FIELD->CANTIDAD
	AXR[ i,RG_TPRECBASE	] := FIELD->TPRECBASE
	AXR[ i,RG_PORCDESC	] := FIELD->PORCDESC
	AXR[ i,RG_TDESCUENTO ] := FIELD->TDESCUENTO
	AXR[ i,RG_TIMPINT 	] := FIELD->TIMPINT
	AXR[ i,RG_TIVA1		] := FIELD->TIVA1
	AXR[ i,RG_TIVA2		] := FIELD->TIVA2
	AXR[ i,RG_PRECUNIT	] := FIELD->PRECUNIT
	AXR[ i,RG_NEGOCIO 	] := FIELD->NEGOCIO
	AXR[ i,RG_IMPORTE 	] := FIELD->IMPORTE
	AXR[i,RG_REGISTRO 	] := if(lCCV,0,RECNO())
	SKIP
ENDDO
SELECT (XF2)

SETCOLOR(C_FONDO)
i:=0;  FOR y=yi+1 TO yf;		  EVAL( bDetalle1, ++i, y );		 NEXT
SETCOLOR(C_GET)
i:=0;  FOR y=yi+1 TO yf;		  EVAL( bDetalle2, ++i, y );		 NEXT
FXTOTAL()
EVAL( bTot )
IF solover
	RETURN .F.
ENDIF
aaux:={ " <+> ºC¢digo del Producto,º  F9    º  F10  ºESC ",;
			"     ºparte de la Descrip-º modif. ºgraba eº    ",;
			"mueveºci¢n o TAB p/ elegirºencabez.ºimprimeºsale"}
if lNUEVO
	aaux[1]:=strtran(aaux[1],"","")
	aaux[2]:=strtran(aaux[2],"","")
	aaux[3]:=strtran(aaux[3],"","")
else
	aaux[1]:=strtran(aaux[1],"","º  F7   ")
	aaux[2]:=strtran(aaux[2],"","º       ")
	aaux[3]:=strtran(aaux[3],"","ºimprime")
endif
if nB==4
	aaux[1]:=strtran(aaux[1],"","")
	aaux[2]:=strtran(aaux[2],"","")
	aaux[3]:=strtran(aaux[3],"","")
else
	aaux[1]:=strtran(aaux[1],"","ºagregar un * a la")
	aaux[2]:=strtran(aaux[2],"","ºDescr.o al c¢digo")
	aaux[3]:=strtran(aaux[3],"","ºpara servicompras")
endif
MENUDOWN(aaux)
********************
nLin := nCol := 1
nPy	:= yi + 1
READEXIT( .T. )
IF !EMPTY(AXR[1,RG_DESCPROD])
	DO WHILE !EMPTY(AXR[nLin,RG_DESCPROD]) .AND. nLin<LEN(AXR)
		++nPy
		++nLin
		IF nPy > yf
			nPy := yf
			SCROLL( yi+1, 0, yf, 79, 1 )
			SETCOLOR(C_FONDO)
			@ nPy, 0 SAY "      ³                    ³          ³          ³       ³         ³           "
			EVAL( bDetalle1, nLin, nPy )
			SETCOLOR(C_GET)
			EVAL( bDetalle2, nLin, nPy )
		ENDIF
	ENDDO
ENDIF
********************
DO WHILE .T.

	SET(_SET_CURSOR,SC_ON)
	SET KEY K_LEFT TO CLEAR_GETS()
	SET KEY K_RIGHT TO CLEAR_GETS()
	SET KEY K_F10 TO CLEAR_GETS()
	SET KEY K_CTRL_F10 TO CLEAR_GETS()
	SET KEY K_F7 TO CLEAR_GETS()
	SET KEY K_F9 TO CLEAR_GETS()
	SET KEY K_ALT_F8 TO CLEAR_GETS()
	SET KEY K_F7 TO CLEAR_GETS()
	SET KEY K_F2 TO CLEAR_GETS()
	SET KEY K_F12 TO CLEAR_GETS()
	SET KEY K_ALT_M TO CLEAR_GETS()
	SET KEY K_SH_TAB TO CLEAR_GETS()
	SET KEY K_ALT_F TO CLEAR_GETS()
	SET KEY 10 TO CLEAR_GETS()
	IF nCol == 2
		SET KEY 67 TO CLEAR_GETS()
		SET KEY 99 TO CLEAR_GETS()
	ENDIF
	* @ nPy, {7,28,50,68}[nCol] GET AXR[nLin,{RG_DESCPROD,RG_CANTIDAD,RG_PORCDESC,RG_IMPORTE}[nCol]] PICT aCpoF[{RG_DESCPROD,RG_CANTIDAD,RG_PORCDESC,RG_IMPORTE}[nCol],ATB_MASC]
	* READ
	*********
	xAux := AXR[nLin,{RG_DESCPROD,RG_CANTIDAD,RG_PORCDESC,RG_IMPORTE}[nCol]]
	@ nPy, {7,28,50,68}[nCol] GET xAux PICT aCpoF[{RG_DESCPROD,RG_CANTIDAD,RG_PORCDESC,RG_IMPORTE}[nCol],ATB_MASC]
	READ
	K := LASTKEY()
	lRepant := .F.
	AXR[nLin,{RG_DESCPROD,RG_CANTIDAD,RG_PORCDESC,RG_IMPORTE}[nCol]] := xAux
	*********
	SET KEY 10 TO CLEAR_GETS()
	SET KEY K_F7 TO
	SET KEY K_ALT_M TO
	SET KEY K_SH_TAB TO
	SET KEY K_F9 TO
	SET KEY K_F2 TO
	SET KEY K_F12 TO
	SET KEY K_ALT_F8 TO
	SET KEY K_LEFT TO
	SET KEY K_RIGHT TO
	SET KEY K_F10 TO
	SET KEY K_CTRL_F10 TO
	SET KEY K_F7 TO
	SET KEY K_ALT_F TO
	SET KEY 67 TO
	SET KEY 99 TO

	K := LASTKEY()
	lRepant := .F.
	IF UPDATED() .OR. K == K_TAB .OR. K==K_SH_TAB .OR. K==10
		lRepant := .T.
		IF nCol == 1 .AND. (K==10.or.val(AXR[nLin,RG_DESCPROD])>99999)
			aux := DBF()
			SELECT ART
			SET ORDER TO ART_CODSCAN
			DBSEEK( ALLTRIM(AXR[nLin,RG_DESCPROD]), .T. )
			AXR[nLin,RG_CODPROD] := ART->CODPROD
			AXR[nLin,RG_NEGOCIO] := "*"
			KEYBOARD CHR(K_ENTER)+"1"+CHR(K_ENTER)
			SET ORDER TO 1
			SELECT (aux)
		ELSEIF nCol == 1 .AND. ( "*" $ AXR[nLin,RG_DESCPROD] .OR. K==K_SH_TAB .OR. nB==4 )
			IF K == K_SH_TAB .OR. (K==K_TAB.AND.nB==4)
				IF FELEGIR( "ART", AXR[nLin,RG_CODPROD] ) # 0
					AXR[nLin,RG_CODPROD] := ART->CODPROD
					AXR[nLin,RG_NEGOCIO] := "*"
					KEYBOARD CHR(K_ENTER)
				ENDIF
			ELSEIF VAL(AXR[nLin,RG_DESCPROD]) # 0
				IF !EMPTY( FPRODUCTO(VAL(AXR[nLin,RG_DESCPROD]),"*") )
					AXR[nLin,RG_CODPROD] := VAL(AXR[nLin,RG_DESCPROD])
					AXR[nLin,RG_NEGOCIO] := "*"
					KEYBOARD CHR(K_ENTER)
				ENDIF
			ELSEIF !EMPTY( AXR[nLin,RG_DESCPROD] )
				r := SELECTAR( AXR[nLin,RG_DESCPROD] )
				IF r # 0
					AXR[nLin,RG_CODPROD] := r
					AXR[nLin,RG_NEGOCIO] := "*"
					KEYBOARD CHR(K_ENTER)
				ENDIF
			ELSEIF EMPTY( AXR[nLin,RG_DESCPROD] )
				AXR[nLin,RG_CODPROD] := 0
			ENDIF
		ELSEIF nCol == 1		// CODPROD, DESCPROD
			IF K == K_TAB
				IF FELEGIR( "PRODUCTO", AXR[nLin,RG_CODPROD] ) # 0
					AXR[nLin,RG_CODPROD] := PRD->CODPROD
					AXR[nLin,RG_NEGOCIO] := " "
					KEYBOARD CHR(K_ENTER)
				ENDIF
			ELSEIF VAL(AXR[nLin,RG_DESCPROD]) # 0
				IF !EMPTY( FPRODUCTO(VAL(AXR[nLin,RG_DESCPROD])) )
					AXR[nLin,RG_CODPROD] := VAL(AXR[nLin,RG_DESCPROD])
					AXR[nLin,RG_NEGOCIO] := " "
					KEYBOARD CHR(K_ENTER)
				ENDIF
			ELSEIF !EMPTY( AXR[nLin,RG_DESCPROD] )
				r := SELECTPRD( AXR[nLin,RG_DESCPROD] )
				IF r # 0
					AXR[nLin,RG_CODPROD] := r
					AXR[nLin,RG_NEGOCIO] := " "
					KEYBOARD CHR(K_ENTER)
				ENDIF
			ELSEIF EMPTY( AXR[nLin,RG_DESCPROD] )
				AXR[nLin,RG_CODPROD] := 0
			ENDIF
			IF FAC_A_CC
				FOR i=1 TO 4
					IF CL->&("CODPROD"+STR(i,1)) == AXR[nLin,RG_CODPROD]
						AXR[nLin,RG_PORCDESC] := CL->&("PORCDESC"+STR(i,1))
					ENDIF
				NEXT
			ELSE
				IF nCODCLI > 0
					FOR i=1 TO 3
						IF CLA->&("CODPROD"+STR(i,1)) == AXR[nLin,RG_CODPROD]
							AXR[nLin,RG_PORCDESC] := CLA->&("PORCDESC"+STR(i,1))
						ENDIF
					NEXT
				ENDIF
			ENDIF
		ELSEIF nCol == 2																			// CANTIDAD
			if !lPermiso;	AXR[nLin,RG_CANTIDAD]:=abs(AXR[nLin,RG_CANTIDAD]);  endif
			IF CHR(LASTKEY()) $ "Cc"
				AXR[nLin,RG_PORCDESC] := PRD->PORCDESC
				AXR[nLin,RG_CANTIDAD] := AXR[nLin,RG_CANTIDAD] * PRD->UNXCAJA
			ENDIF
			AXR[nLin,RG_IMPORTE ] := AXR[nLin,RG_CANTIDAD] * AXR[nLin,RG_PRECUNIT]
			KEYBOARD CHR(LASTKEY())
			IF UPDATED()
				KEYBOARD CHR(K_ENTER) + CHR(K_ENTER) + CHR(K_ENTER)
			ELSE
				KEYBOARD CHR(K_ENTER) + CHR(K_ENTER)
			ENDIF
		ELSEIF nCol == 3																			// PORCDESC
			if nB==4
				if !lPermiso;	AXR[nLin,RG_PORCDESC]:=0;	endif
			endif
			KEYBOARD CHR(K_ENTER)
		ELSEIF nCol == 4																			// IMPORTE
			if !lPermiso;	AXR[nLin,RG_IMPORTE]:=abs(AXR[nLin,RG_IMPORTE]);  endif
			AXR[nLin,RG_CANTIDAD] := AXR[nLin,RG_IMPORTE] / AXR[nLin,RG_PRECUNIT]
			IF AXR[nLin,RG_IMPORTE] # 0
				KEYBOARD CHR(LASTKEY())
			ENDIF
		ENDIF
		IF K # K_F2 .AND. K # K_F12
			AXR[ nLin, RG_DESCPROD	 ] := LEFT(FPRODUCTO(AXR[nLin,RG_CODPROD],AXR[nLin,RG_NEGOCIO]),20)
			AXR[ nLin, RG_RUBRO		 ] := NRUBRO
			AXR[ nLin, RG_PRECBASE	 ] := FPRECBASE
			AXR[ nLin, RG_TIPOIMPINT ] := FTIPOIMPINT
			AXR[ nLin, RG_IMPINT 	 ] := FIMPINT
			AXR[ nLin, RG_PRECUNIT	 ] := FPRECVENTA
		ENDIF
		FCALCPRECIO( AXR, nLin )
		FXTOTAL()
	ELSEIF K == K_ENTER
 		IF !EMPTY(AXR[nLin,RG_DESCPROD])
 			i:=IF( nCol==2, nCol+=2, ++nCol )
 			IF nCol > 4 .AND. AXR[nLin,RG_IMPORTE]#0;  ++nLin; ++nPy;  nCol:=1; ENDIF
 		ENDIF
	ELSEIF K == K_F9
		if XF=="TI"
			NUMFECH()
     else
			ENCABEZADO()
		endif
	ELSEIF K == K_ALT_F .AND. lPermiso
		REFAC(AXR)
		SETCOLOR(C_FONDO)
		i:=0;  FOR y=yi+1 TO yf;		  EVAL( bDetalle1, ++i, y );		 NEXT
		SETCOLOR(C_GET)
		i:=0;  FOR y=yi+1 TO yf;		  EVAL( bDetalle2, ++i, y );		 NEXT
		FXTOTAL()
		EVAL( bTot )
	ELSEIF K == K_F7 .and. !lNUEVO
		IF PREGUNTA( 12, " ¨ ESTA SEGURO ?   [ S / N ]", "SsNn") $ "Ss"
			IMPRIMIR()
		ENDIF
	ELSEIF K == K_DOWN
		++nLin;	++nPy
	ELSEIF K == K_UP
		--nLin;	--nPy
	ELSEIF K == K_RIGHT
		++nCol
	ELSEIF K == K_LEFT
		--nCol
	ELSEIF K == K_ALT_M
		CALC()
	ELSEIF K == K_CTRL_F10
		DO DIFAC
		nTIPOVENTA := 3
		FXTOTAL()
		FVERREG( ATOT,, .T. )
		lRepant := .T.
	ELSEIF K == K_ESC
		aux := PREGUNTA( 12, "[ G ] graba    [ S ] sale     [ C ] contin£a", "GgSsCc" )
		IF aux $ "Gg"
			K := K_F10
			if xF=="TI" .and.M->TOTAL == 0
				MENSAJE( 0, 0, 10, .T., "TICKET EN 0 !" )
     	else
     		exit
  		endif
		ELSEIF aux $ "Ss"
			K := K_ESC
			EXIT
		ENDIF
	ELSEIF K == K_F10
		if xF=="TI" .and.M->TOTAL == 0
			MENSAJE( 0, 0, 10, .T., "TICKET EN 0 !" )
     else
     	exit
  	endif
	ENDIF
	IF nPy <= yi
		nPy := yi + 1
		IF nLin > 0
			SCROLL( yi+1, 0, yf, 79, -1 )
			@ nPy, 0 SAY "      ³                    ³          ³          ³       ³         ³           " COLOR C_FONDO
			lRepant := .T.
		ENDIF
	ENDIF
	IF nPy > yf
		nPy := yf
		IF nLin <= LEN(AXR)
			SCROLL( yi+1, 0, yf, 79, 1 )
			@ nPy, 0 SAY "      ³                    ³          ³          ³       ³         ³           " COLOR C_FONDO
			lRepant := .T.
		ENDIF
	ENDIF
	IF nLin < 1;  nLin := 1;		ENDIF
	IF nLin > len(AXR);	 nLin:=len(AXR);	ENDIF
	IF nCol < 1;			 nCol := 1;  ENDIF
	IF nCol > 4;  nCol := 4;  ENDIF

#ifdef NADA
	F:=nLin
  cSep:="³"
				nDif := AXR[F,RG_PRECUNIT] - (AXR[F,RG_IMPINT]+AXR[F,RG_PRECBASE])
				nPIVA := nDif * 100 / AXR[F,RG_PRECUNIT]
           nPIVA:=if(BETWEEN(nPIVA,0,VA->PIVA1),nPIVA,VA->PIVA1)/100
           cPIVA:=trans(nPIVA,"##.####");  cPIVA:=substr(cPIVA,4)

				cCmdData			:= padr(AXR[F,RG_DESCPROD],20,' ')+;
							cSep+ str0(AXR[F,RG_CANTIDAD],7,3)+;
									cSep+ str0(AXR[F,RG_PRECUNIT],8,2)+;
							cSep+ cPIVA+;
							cSep+ "M"+;
				cSep+ "00001"+;
				cSep+ "00000000"
set alternate to q
set alternate on
@23,0 say "ZAPATILLAS NIKE     |00000001|00006000|2100|M|00001|00000000"
? cCmdData
set alternate to
#endif

	IF lRepant
		SETCOLOR(C_FONDO)
		EVAL( bDetalle1, nLin, nPy )
		SETCOLOR(C_GET)
		EVAL( bDetalle2, nLin, nPy )
		EVAL( bTot )
	ENDIF

ENDDO

RETURN( K == K_F10 )


*************

FUNC GRABAR()

*************
MENSAJE( 0, 0, 0, .F., "GRABANDO ..." )
IF nB == 1
	xB := "FA";  cTIPOFAC := "A"
ELSEIF nB == 2
	xB := "FB";  cTIPOFAC := "B"
ELSEIF nB == 3
	xB := "RE";  cTIPOFAC := "R"
ELSEIF nB == 4
	xB := "TI";  cTIPOFAC := "T"
ENDIF
xB2 := xB + "2"

private bLastErr := ErrorBlock()
private bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )

select (xB)
set order to 1
cHORA := TIME()
if RNUMERO # 0 			//  busca y borra el anterior
	cHORA := if(dbseek(RNUMERO),FIELD->HORA,TIME())
	if (XF$"FA FB".and.(XF)->TIPOVENTA==2)
  else
		select (xB2)
		set order to 1
		do while dbseek(RNUMERO)
			if (xB2)->NEGOCIO=="*"		// .and. (XF$"FA FB".and.(XF)->TIPOVENTA#2)
				select ART
				if dbseek((xB2)->CODPROD) .and. (xB)->FECHA>=ART->FECHA
					frlock()
					ART->STOCKACT += (xB2)->CANTIDAD
					dbunlock()
					if ART->COMPUESTO # 0
						FCOMPUESTO( (xB2)->CODPROD, +(xB2)->CANTIDAD, (xB)->FECHA )
					endif
				endif
				select (xB2)
			endif
			BLANKREG()
		enddo
  endif
	select (xB)
	do while dbseek(RNUMERO)
		BLANKREG()
	enddo
endif
if lNUEVO
	do while dbseek(nNUMERO)
		++nNUMERO
	enddo
endif

set deleted off
select (xB)
if !dbseek( 0 )
	ADD_REC()
else
	frlock()
	recall
endif
frlock()
set deleted on

IF nB == 1
	FA->NUMFAC		:= nNUMERO
	FA->FECHVENC	:= FA->FECHA
	FRLOCK("VA");	VA->&("ULFACA"+cSUCURSAL) := MAX( VA->&("ULFACA"+cSUCURSAL), nNUMERO )
ELSEIF nB == 2
	FB->NUMFAC		:= nNUMERO
	FRLOCK("VA");	VA->&("ULFACB"+cSUCURSAL) := MAX( VA->&("ULFACB"+cSUCURSAL), nNUMERO )
ELSEIF nB == 3
	RE->NUMFAC	  := nNUMERO
	RE->CODCLI	  := nCODCLI
	RE->FECHVENC  := FCIERRE( RE->FECHA )
	RE->FECHVENC  := RE->FECHA
	RE->VALORIZADO:= cVALORIZADO
	RE->ID_CCV	  := if(lNUEVO,"",cID_CCV)
	FRLOCK("VA");	VA->ULREM := MAX( VA->ULREM, nNUMERO );  VA->RECALCCCV:=.T.
	FRLOCK("CL");	CL->RECALCCCV := .T.
ELSEIF nB == 4
	TI->NUMFAC	  := nNUMERO
	TI->CODCLI	  := -1
	FRLOCK("VA");	VA->ULTICK := MAX( VA->ULTICK, nNUMERO )
ENDIF
if xB $ "FA FB"
	FIELD->CODCLI	 := nCODCLI
	FIELD->RAZONSOC := cCLIENTE
	FIELD->CATIVA	 := cCATIVA
	FIELD->CUIT 	 := cCUIT
	FIELD->TIPOVENTA:= if(nMODO==K_ALT_F5,3,nTIPOVENTA)
	FIELD->CONDVTA  := nCONDVTA
	FIELD->ID_CCV	 := if(lNUEVO,"",cID_CCV)
	FIELD->CODTARJ := cCODTARJ
	FIELD->NUMTARJ := cNUMTARJ
	FIELD->NUMCUPON:= cNUMCUPON
	FIELD->NEGOCIO := if( ascan(AXR,{|a,i|a[RG_NEGOCIO]=="*"})==0, " ", "*" )
elseif nB == 3
	FIELD->OBSERV	:= cOBSERV
endif
(xB)->TURNO 	 := cTURNO
(xB)->FECHA 	 := dFECHA
(xB)->FECHEMI	 := dFECHEMI
(xB)->TPRECBASE := M->TPRECBASE
(xB)->PORCDESC  := M->PORCDESC
(xB)->TDESCUENTO:= M->TDESCUENTO
(xB)->TNETO 	 := M->TPRECBASE
(xB)->TIMPINT	 := M->TIMPINT
(xB)->TIVA1 	 := M->TIVA1
(xB)->TIVA2 	 := M->TIVA2
(xB)->TOTAL 	 := M->TOTAL
(xB)->IMPRESO	 := lIMPRESO
(xB)->PASADO	 := " "
if nMODO == K_F11
	(xB)->ID_CCV := "CCV"
	(xB)->CODCORR:= nCODCORR
elseif lCCV
	(xB)->CODCORR:= nCODCORR
endif

select (xB2)
fflock()
FOR i=1 TO LEN(AXR)
	IF AXR[i,RG_IMPORTE]#0 .OR. AXR[i,RG_CODPROD]==-1
		if dbseek(0)
			dbrecall()
		else
			ADD_REC()
		endif
		(xB2)->NUMFAC	  := nNUMERO
		(xB2)->FECHA	  := dFECHA
		(xB2)->CODPROD   := AXR[i,RG_CODPROD]
		(xB2)->CANTIDAD  := AXR[i,RG_CANTIDAD]
		(xB2)->DESCPROD  := AXR[i,RG_DESCPROD]
		(xB2)->TPRECBASE := AXR[i,RG_TPRECBASE]
		(xB2)->PORCDESC  := AXR[i,RG_PORCDESC]
		(xB2)->TDESCUENTO:= AXR[i,RG_TDESCUENTO]
		(xB2)->TIMPINT   := AXR[i,RG_TIMPINT]
		(xB2)->TIVA1	  := AXR[i,RG_TIVA1]
		(xB2)->TIVA2	  := AXR[i,RG_TIVA2]
		(xB2)->PRECUNIT  := AXR[i,RG_PRECUNIT]
		(xB2)->IMPORTE   := AXR[i,RG_IMPORTE ]
		(xB2)->NEGOCIO   := AXR[i,RG_NEGOCIO ]
		if (XF$"FA FB".and.(XF)->TIPOVENTA==2)
  	else
			if (xB2)->NEGOCIO == "*"
				select ART
				if dbseek((xB2)->CODPROD) .and. (xB)->FECHA>=ART->FECHA
					frlock()
					ART->STOCKACT -= (xB2)->CANTIDAD
					dbunlock()
					if ART->COMPUESTO # 0
						FCOMPUESTO( (xB2)->CODPROD, -(xB2)->CANTIDAD, (xB)->FECHA )
              endif
				endif
        endif
		endif
		select (xB2)
	endif
NEXT
if lNUEVO
	if EST->CODEMP # UT_CLAVECER
		(xB)->HORA	 := cHORA
		(xB)->CODEMP := if(procname(2)=="FF",EST->CODEMP,"")
	endif
endif
dbunlockall()
dbcommitall()
recupan()
ErrorBlock(bLastErr)

return .T.


*************

FUNC DATOSCL( cual, lcomo )

*************
LOCAL r := 0

DBSELECTAREA( XF )

cCLIENTE   := SPACE(LEN(CLA->RAZONSOC))
cDOMCOM	  := SPACE(LEN(CLA->DOMCOM))
cCUIT 	  := SPACE(LEN(CLA->CUIT))
*nTIPOVENTA := 1
cCATIVA	  := "   "
nCODLOC	  := 0
cVALORIZADO:= "S"
nCODCORR   := 0
cID_CCV	  := ""

IF XF$"FA FB" .and. nMODO==K_F11
	select (XF)
	if CL->(dbseek(cual))
		cCLIENTE   := CL->RAZONSOC
		cDOMCOM	  := CL->DOMCOM
		cCUIT 	  := CL->CUIT
		nTIPOVENTA := 2
		cCATIVA	  := CL->CATIVA
		nCODLOC	  := CL->CODLOC
		cVALORIZADO:= CL->VALORIZADO
		nCODCORR   := CL->CODCORR
		SELECT (XF)
	ENDIF

ELSEIF nB == 1
	select FA
	IF lNUEVO .OR. lcomo
		if CLA->(dbseek(cual))
			cCLIENTE   := CLA->RAZONSOC
			cCUIT 	  := CLA->CUIT
			cCATIVA	  := CLA->CATIVA
			cDOMCOM	  := CLA->DOMCOM
			nCODLOC	  := CLA->CODLOC
		ENDIF
	ELSE
		if FIELD->TIPOVENTA == 2
			CL->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			nTIPOVENTA := FIELD->TIPOVENTA
			cCATIVA	  := FIELD->CATIVA
			cDOMCOM	  := CL->DOMCOM
			nCODLOC	  := CL->CODLOC
			cVALORIZADO:= CL->VALORIZADO
			nCODCORR   := CL->CODCORR
			cID_CCV	  := FIELD->ID_CCV
		else
			CLA->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			nTIPOVENTA := FIELD->TIPOVENTA
			cCATIVA	  := FIELD->CATIVA
			cDOMCOM	  := CLA->DOMCOM
			nCODLOC	  := CLA->CODLOC
		endif
	ENDIF

ELSEIF nB == 2
	SELECT FB
	IF lNUEVO .OR. lcomo
		if CLA->(dbseek(cual)) .and. cual#0
			cCLIENTE   := CLA->RAZONSOC
			cCUIT 	  := CLA->CUIT
			cCATIVA	  := CLA->CATIVA
			cDOMCOM	  := CLA->DOMCOM
			nCODLOC	  := CLA->CODLOC
		else
			cCLIENTE := JUSTIF("CONSUMIDOR FINAL", LEN(CLA->RAZONSOC), "<" )
			cCATIVA	:= "CF "
			nCODCLI	:= -1
		endif
	ELSE
		if FIELD->TIPOVENTA == 2
			CL->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			nTIPOVENTA := FIELD->TIPOVENTA
			cCATIVA	  := FIELD->CATIVA
			cDOMCOM	  := CL->DOMCOM
			nCODLOC	  := CL->CODLOC
			cVALORIZADO:= CL->VALORIZADO
			nCODCORR   := CL->CODCORR
			cID_CCV	  := FIELD->ID_CCV
		else
			CLA->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			cCATIVA	  := FIELD->CATIVA
			nTIPOVENTA := FIELD->TIPOVENTA
			cDOMCOM	  := CLA->DOMCOM
			nCODLOC	  := CLA->CODLOC
		endif
		IF EMPTY(FIELD->RAZONSOC)
			IF FIELD->CATIVA == "EX "
				cCLIENTE := JUSTIF("EXENTO", LEN(CLA->RAZONSOC), "<" )
				cCATIVA	:= "EX "
			ELSE
				cCLIENTE := JUSTIF("CONSUMIDOR FINAL", LEN(CLA->RAZONSOC), "<" )
				cCATIVA	:= "CF "
			ENDIF
		ENDIF
	ENDIF

ELSEIF nB == 3
	SELECT RE
	if CL->(dbseek(cual))
		cCLIENTE   := CL->RAZONSOC
		cDOMCOM	  := CL->DOMCOM
		cCUIT 	  := CL->CUIT
		nTIPOVENTA := 2
		cCATIVA	  := CL->CATIVA
		nCODLOC	  := CL->CODLOC
		cVALORIZADO:= CL->VALORIZADO
		nCODCORR   := CL->CODCORR
		SELECT RE
	ENDIF
	IF !lNUEVO .OR. !lcomo
		cID_CCV	  := FIELD->ID_CCV
	ENDIF

ELSEIF nB == 4
	SELECT TI
	cCLIENTE   := "CONSUMIDOR FINAL"
	nTIPOVENTA := 1
	cCATIVA	  := "CF "
	nCODLOC	  := -1
ENDIF
IF cual == -2
	cCLIENTE := JUSTIF("ANULADA", LEN(CLA->RAZONSOC), "<" )
ENDIF
IF 'TRESSAN' $ CURDIR() .AND. nB==3
ELSE
	IF lNUEVO .OR. lcomo
		cTURNO	  := VA->ULTURNO
	ENDIF
ENDIF

DBSELECTAREA( XF )

RETURN cCLIENTE


**************

FUNC FNUMERO()

**************
cTURNO		:= " "
cVALORIZADO := "S"
cCODTARJ   := "   "
cNUMTARJ   := SPACE(LEN(FA->NUMTARJ))
cNUMCUPON  := SPACE(LEN(FA->NUMCUPON))
cOBSERV	  := space(len(RE->OBSERV))
cCODEMP	  := EST->CODEMP
nCONDVTA   := 1
dFECHEMI   := date()
lIMPRESO   := .F.
*FREABRIR({"VARIOS"})			  // NUEVO
if lNuevo
	IF nB == 1
		select FA
		nNUMERO := VA->&("ULFACA"+cSUCURSAL) + 1
	ELSEIF nB == 2
		nNUMERO := VA->&("ULFACB"+cSUCURSAL) + 1
		cTURNO  := FIELD->TURNO
	ELSEIF nB == 3
		nNUMERO := VA->ULREM + 1
	ELSEIF nB == 4
		select TI
		nNUMERO := VA->ULTICK + 1
	ENDIF
	dFECHA  := VA->ULFECHA
	cTURNO  := VA->ULTURNO
else
	dFECHA	 := FIELD->FECHA
	cTURNO	 := FIELD->TURNO
	cCODEMP	 := FIELD->CODEMP
	dFECHEMI  := FIELD->FECHEMI
	nNUMERO	 := FIELD->NUMFAC
	IF nB==1 .or. nB==2
		select ({"FA","FB"}[nB])
		cCODTARJ  := FIELD->CODTARJ
		cNUMTARJ  := FIELD->NUMTARJ
		cNUMCUPON := FIELD->NUMCUPON
		nCONDVTA  := FIELD->CONDVTA
	ELSEIF nB == 3
		SELECT RE
		cVALORIZADO := FIELD->VALORIZADO
		cOBSERV		:= FIELD->OBSERV
	ELSEIF nB == 4
		SELECT TI
	ENDIF
	lIMPRESO := FIELD->IMPRESO
ENDIF

RETURN nNUMERO


****************

FUNC FELEFAC(_cual)

****************
LOCAL xreg	 := RECNO(), OX, aCpo, cBase:=DBF()
LOCAL aFF := {{"FA","ULFACA"+cSUCURSAL},{"FB","ULFACB"+cSUCURSAL},{"RE","ULREM"},{"TI","ULTICK"}}
LOCAL xmenu  :=MENUDOWN({ "º  <+>  º PgUp   º  F3   º   F4   º   F8   º   F9   º ESPACIO  º ENTER  º ESC  º",;
									"º       º PgDown º       º        ºins/elimºbusca n§ºpone pasa-º elige  º      º",;
									"º mueve º mueve+ º busca º busca+ ºnumeros ºfaltanteº do Si/No º y sale º sale º"})
XF := IF(XF==NIL,DBF(),XF)
IF nB == 3
	aCpo := {;
			{ "FECHA",			  "Fecha; ",							  '', 'E', 'F',  3, 0 },;
			{ "TURNO",			  "T; ", 								  '', 'E', 'F',  3, 0 },;
			{ "NUMFAC", 		  "N£mero; ",							  '', 'E',	'',  0, 0 },;
			{ "DATOSCL(FIELD->CODCLI,.F.)", "Cliente; ", REPLIC('X',20), 'F', 'F',	0, 0 },;
			{ "TOTAL",			  "Total; ",							  '', 'F',	'',  0, 0 },;
			{ "HORA",			  "Hora",								  '', 'F',	'',  0, 0 },;
			{ "CODCORR",		  "Corr",								  '', 'E',	'',  0, 0 },;
			{ "ID_CCV", 		  "C¢digo", 							  '', 'E',	'',  0, 0 },;
			{ "CCV->FECHCIERRE","Fecha;Cierre", 					  '', 'F',	'',  0, 0 } }
	FBASES({"+CCV"})
	select CCV
	set order to forder({"CODCLI","ID_CCV"})
	select (XF)
	set relation to str((XF)->CODCLI)+(XF)->ID_CCV into CCV
ELSEIF nB == 4
	aCpo := {;
			{ "FECHA",			  "Fecha; ",							  '', 'E', 'F',  3, 0 },;
			{ "TURNO",			  "T; ", 								  '', 'E', 'F',  3, 0 },;
			{ "NUMFAC", 		  "Ticket; ",							  '', 'E',	'',  0, 0 },;
			{ "TOTAL",			  "Total; ",							  '', 'F',	'',  0, 0 },;
			{ "HORA",			  "Hora",								  '', 'F',	'',  0, 0 } }
ELSE
	aCpo := {;
			{ "FECHA",			  "Fecha; ",							  '', 'E', 'F',  3, 0 },;
			{ "TURNO",			  "T; ", 								  '', 'E', 'F',  3, 0 },;
			{ "NUMFAC", 		  "N£mero; ",							  '', 'E',	'',  0, 0 },;
			{ "RAZONSOC",		  "Cliente; ", 		  REPLIC('X',20), 'F', 'F',  0, 0 },;
			{ "TOTAL",			  "Total; ",							  '', 'F',	'',  0, 0 },;
			{ "HORA",			  "Hora",								  '', 'F',	'',  0, 0 },;
			{ "TIPOVENTA", 	  "Tip;Vta",							  '', 'F',	'',  0, 0 },;
			{ "CODCORR",		  "Corr",								  '', 'E',	'',  0, 0 },;
			{ "ID_CCV", 		  "C¢digo", 							  '', 'E',	'',  0, 0 } }
ENDIF
aadd(aCpo,{"PASADO", 		  "Pasado", 							  '', 'E',	'',  0, 0 })
IF lPUBLICO
	AEVAL( aCpo,{|a,i| aCpo[i,4]:='F'} )
ENDIF
DBSELECTAREA(XF)
aCpo := FARRAYAUX( aCpo )
MARCO( 10, 15, 20, 78, "<< BOLETAS >>", "D", .T., 0 )
OX := MYBROWSE( 10, 15, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 0
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==43.OR.nK==45.OR.nK==K_F3.OR.nK==K_F8.OR.nK==K_ALT_F8.OR.nK==32.OR.nK==K_F9.OR.nK==K_TAB.OR.nK==K_SH_TAB.OR.nK==K_F6.OR.CHR(nK)$"Vv"} )
	IF OX:Cargo[TB_MSGE]=="MODIF" .or. (OX:Cargo[TB_RET]==43 .OR. OX:Cargo[TB_RET]==45) .AND. lPermiso
		nReg := RECNO()
		if TBNOC(OX)=="NUMFAC" .or. (OX:Cargo[TB_RET]==43 .OR. OX:Cargo[TB_RET]==45)
			if  chr(OX:Cargo[TB_RET]) $ "+-"
				aux := (XF)->NUMFAC + if(OX:Cargo[TB_RET]==43,1,-1)
			else
				aux := OX:CARGO[TB_CONT]
			endif
			if dbseek(aux)
				MENSAJE( 0, 0, 10, .T., "NUMERO REPETIDO !!!")
				go nReg
			else
				GO nReg
				select (XF2)
				fflock()
				do while dbseek((XF)->NUMFAC)
					(XF2)->NUMFAC:=aux
				enddo
				select (XF)
				FRLOCK()
				(XF)->NUMFAC:=aux
				DBGOBOTTOM()
				aux1 := aFF[nB,2]
				if VA->&(aux1) # (XF)->NUMFAC
					FRLOCK("VA")
					VA->&(aux1) := (XF)->NUMFAC
				endif
				DBUNLOCKALL()
				GO nReg
				TBPOS(OX,.T.)
			endif
		else
			FRLOCK()
			FIELD->&(TBNOC(OX)) := OX:CARGO[TB_CONT]
			DBUNLOCK()
			IF TBNOC(OX)=="FECHA"
				DBSELECTAREA(XF2)
				FFLOCK()
				SEEK (XF)->NUMFAC
				do while (XF2)->NUMFAC == (XF)->NUMFAC
					(XF2)->FECHA := (XF)->FECHA
					skip
				enddo
				DBUNLOCK()
				DBSELECTAREA(XF)
			ENDIF
		endif
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET]==K_F3 .OR. OX:Cargo[TB_RET]==K_F4
		IF TBNOC(OX)=="FECHA" .AND. OX:Cargo[TB_RET]==K_F3
			aux := FIELD->FECHA
			aux := INGRVAL( 10, 20, "Fecha:", aux, "", "")
			IF LASTKEY() == K_ENTER
				nOrder := INDEXORD()
				SET ORDER TO FORDER({"FECHA","TURNO"})
				DBSEEK(FTOC(aux),.T.)
				SET ORDER TO nOrder
				OX:REFRESHALL()
			ENDIF
		ELSE
			BUSCADOR( OX:CARGO[TB_RET], OX )
		ENDIF
	ELSEIF CHR(OX:Cargo[TB_RET])$"Vv"
		FBASES({"+CCV"})
		select CCV
		set order to forder({"CODCLI","ID_CCV"})
		if dbseek(str((XF)->CODCLI,FLEN(CCV->CODCLI))+(XF)->ID_CCV)
			MENSAJE( 0, 0, 10, .T., dtoc(CCV->FECHCIERRE) )
		else
			MENSAJE( 0, 0, 10, .T., "NO ENCONTRADO..." )
		endif
		select (XF)
	ELSEIF OX:Cargo[TB_RET] == K_TAB .AND. lPermiso
		IF "CODCORR" $ TBNOC(OX)
			IF CORR(FIELD->CODCORR,.T.)
				frlock();  FIELD->CODCORR:=COR->CODCORR;	dbunlock()
				TBPOS(OX)
			ENDIF
		ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_SH_TAB .AND. lPermiso
		DO FNUM2
	ELSEIF OX:Cargo[TB_RET] == K_SH_TAB
		aaux := {}
		aux := 0
		DBSELECTAREA(XF2)
		DBSEEK( (XF)->NUMFAC )
		DO WHILE (XF2)->NUMFAC == (XF)->NUMFAC
			AADD( aaux, STR((XF2)->NUMFAC) +'³'+ (XF2)->DESCPROD +'³'+ STR((XF2)->IMPORTE) )
			aux += (XF2)->IMPORTE
			SKIP
		ENDDO
		IF LEN(aaux) # 0
			PP_SELEC( 1, 1, 0, 0, aaux, 1, STR(aux,10,2), "S", .T.)
			RECUPAN()
		ENDIF
		DBSELECTAREA(XF)
	ELSEIF OX:Cargo[TB_RET] == K_ESC
		GO xreg
		EXIT
	ELSEIF OX:Cargo[TB_RET] == 32
		FRLOCK()
		FIELD->PASADO := IF(FIELD->PASADO=="S"," ","S")
		DBUNLOCK()
		TBPOS(OX)
		OX:DOWN()
	ELSEIF OX:Cargo[TB_RET] == K_F9
		MENSAJE( 99, 99, 0, .F., "BUSCANDO NUMEROS FALTANTES...")
		nReg := RECNO()
		r := .F.
		aux1 := FIELD->NUMFAC
		SKIP
		DO WHILE !EOF()
			IF FIELD->NUMFAC # aux1+1
				r := .T.
				EXIT
			ENDIF
			aux1 := FIELD->NUMFAC
			SKIP
		ENDDO
		RECUPAN()
		IF !r
			MENSAJE( 0, 0, 10, .T., "NO SE ENCONTRARON NUMEROS FALTANTES !!!")
			GO nReg
			TBPOS(OX)
		ELSE
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_ALT_F8 .AND. lPermiso
  	nAux1:=nAux2:=(XF)->NUMFAC
     dFecha := (XF)->FECHA
		MARCO( 10, 30, 12, 60, "", "D", .T., 0 )
     SET(_SET_CURSOR,SC_ON)
     @10,30 say "Desde N§:" get nAux1
     @11,30 say "Hasta N§:" get nAux2
     @12,30 say "   Fecha:" get dFecha
     read
     if lastkey()==K_ENTER
			MENSAJE(99,99, 0, .F., " AGUARDE ..." )
     	nReg:=recno()
        dbseek(nAux1,.T.)
        do while BETWEEN((XF)->NUMFAC,nAux1,nAux2) .and. !(XF)->(eof())
           frlock(XF);  (XF)->FECHA:=dFecha;  (XF)->(dbunlock())
        	(XF2)->(dbseek((XF)->NUMFAC))
           do while ROSCA().and. (XF2)->NUMFAC==(XF)->NUMFAC .and. !(XF)->(eof())
           	frlock(XF2);  (XF2)->FECHA:=dFecha;  (XF2)->(dbunlock())
           	skip 1 alias (XF2)
           enddo
           @ 24,70 say (XF)->NUMFAC
        	skip 1 alias (XF)
        enddo
        go nReg
     	RECUPAN()
     endif
     RECUPAN()
		TBPOS(OX,.T.)

	ELSEIF OX:Cargo[TB_RET] == K_F8 .AND. lPermiso
		nReg := RECNO()
		aux1 := FIELD->NUMFAC
		DBGOBOTTOM(); aux2 := FIELD->NUMFAC
		GO nReg
		aux3 := 1
		cMenu:=MENUDOWN({ "   F10    º  ESC   ",;
								"          º        ",;
								" comienza º  sale  "})
		aaux := NEWEDIT2( "INSNUM" )
		aaux[ED_I] := 1
		aaux[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR2( aaux, { K_F10, K_ESC } )
			IF aaux[ED_UPDATE]
				aaux[ED_MODE] = "MOSTRARTODO"
			ELSEIF aaux[ED_TECLA] == K_ESC .OR. aaux[ED_TECLA] == K_F10
				EXIT
			ENDIF
		ENDDO
		FEDITOR(aaux,"SACAPAN")
		MENUDOWN(cMenu)
		IF aaux[ED_TECLA] == K_F10 .AND. aux3 # 0
			MENSAJE( 99, 99, 0, .F., "REENUMERANDO...")
			IF aux3 > 0
				FOR aux=aux2 TO aux1 STEP -1
					if dbseek(aux+aux3)
						MENSAJE( 0, 0, 10, .T., "ENCONTRADO EL"+STR(aux+aux3,6) +"!!!")
						EXIT
					ELSE
						@ 24, 65 SAY STR(aux,6)+"->"+STR(aux+aux3,6)
						select (xF2)
						fflock()
						do while dbseek( aux )
							(xF2)->NUMFAC := (aux+aux3)
						enddo
						dbunlock()
						select (XF)
						fflock()
						do while dbseek( aux )
							(xF)->NUMFAC := (aux+aux3)
						enddo
						dbunlock()
					ENDIF
				NEXT
			ELSEIF aux3 < 0
				for aux=aux1 TO aux2
					if dbseek(aux+aux3)
						MENSAJE( 0, 0, 10, .T., "HAY SUPERPOSICION "+ STRZERO(aux+aux3,8) +"!!!")
						exit
					else
						@ 24, 65 SAY STR(aux,6)+"->"+STR(aux+aux3,6)
						select (xF2)
						fflock()
						do while dbseek( aux )
							(xF2)->NUMFAC := (aux+aux3)
						enddo
						dbunlock()
						select (xF)
						fflock()
						do while dbseek( aux )
							(xF)->NUMFAC := (aux+aux3)
						enddo
						dbunlock()
					endif
				next
			ENDIF
			** comprueba si el £ltimo valor de VA es menor a la £ltima factura
			DBGOBOTTOM()
			aux1 := aFF[nB,2]
			IF VA->&(aux1) # (XF)->NUMFAC
				FRLOCK("VA")
				VA->&(aux1) := (XF)->NUMFAC
				VA->(DBUNLOCK())
			ENDIF
			DBUNLOCK()
			RECUPAN()
		ENDIF
		GO nReg
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
set relation to
DBSELECTAREA( cBase )
RECUPAN()
PONEPAN(xmenu)

RETURN .T.


************

FUNC FXTOTAL

************
M->TPRECBASE  := 0
M->TDESCUENTO := 0
M->TIMPINT	  := 0
M->TIVA1 	  := 0
M->TIVA2 	  := 0

FOR i=1 TO LEN(AXR)
	M->TPRECBASE  += AXR[i,RG_TPRECBASE]
	M->TDESCUENTO += AXR[i,RG_TDESCUENTO]
	M->TIMPINT	  += AXR[i,RG_TIMPINT]
	M->TIVA1 	  += AXR[i,RG_TIVA1]
	M->TIVA2 	  += AXR[i,RG_TIVA2]
NEXT
M->PORCDESC 	:= M->TDESCUENTO * 100 / IF(M->TPRECBASE==0,1,M->TPRECBASE)
M->TOTAL 		:= M->TPRECBASE + M->TIMPINT + M->TIVA1 + M->TIVA2

RETURN M->TOTAL


*********************

STATIC FUNC NUMFECH()

*********************
LOCAL EDX := NEWEDIT2( "NUMFECH",,.F. )
SELECT (XF)
EDX[ED_REGISTRO] := 0
EDX[ED_MODE] = "MOSTRARTODO"
EDX[ED_TECLA] = 0
EDX[ED_I] = 1
DO WHILE .T.
	FEDITAR2( EDX, {K_TAB} )
	EDX[ED_MODE] = "MOSTRAR"
	IF EDX[ED_UPDATE]
		IF EDNOM(EDX) $ "nNUMERO"
			IF FREPEAT( nNUMERO, IF(nMODO==K_F2,"MODIF","AGRE") )
				MENSAJE( 0, 0, 10, .T., "NUMERO REPETIDO !!!" )
				nNUMERO := EDX[ED_LAST]
				EDX[ED_TECLA] := 0
			ENDIF
		ENDIF
	ELSEIF ( EDX[ED_TECLA] == K_ENTER .AND. EDX[ED_I]==rat("M",EDX[ED_EDIT]) )
		EXIT
	ELSEIF EDX[ED_TECLA] == K_ESC
		EXIT
	ENDIF
ENDDO

RETURN


************************

STATIC FUNC ENCABEZADO()

************************
LOCAL xmenu, xmenu3

ATOT[ED_REGISTRO] := 0
ATOT[ED_MODE] = "MOSTRARTODO"
ATOT[ED_TECLA] = 0
ATOT[ED_I] = if(nB==3,EDNUM(ATOT,"cOBSERV"),1)
IF (nMODO==K_F12 .or. nMODO==K_ALT_F5) .and. procname(1)=="FF"
	NUMFECH()
ENDIF
select (XF)
if XF=="TI"
	keyboard chr(K_ENTER)
	inkey(1)
	ATOT[ED_TECLA] = K_ENTER
	nCODCLI := -1
	return
endif
xmenu3:=MENUDOWN({"      º escriba el C¢digo, parte del º  ALT_N  º  ENTER   º ESC  ",;
						 "        º Nombre, CUIT ¢ presione TAB  º N§ fact.º          º      ",;
						 "  mueve º para escoger al cliente.     º y fecha º confirma º sale "})
DO WHILE .T.
	FEDITAR2( ATOT, {K_TAB, K_ALT_N, K_F1} )
	ATOT[ED_MODE] = "MOSTRAR"
	IF ATOT[ED_UPDATE] .OR. ATOT[ED_TECLA] == K_TAB
		IF EDNOM(ATOT) $ "cCODTARJ"
			ATOT[ED_MODE] = "MOSTRARTODO"
			IF ATOT[ED_TECLA] == K_TAB
				ele = ABRW( 1, 16, 0, 'vtarjeta', cCODTARJ, 'TARJETAS')
				IF LASTKEY() == K_ENTER
					cCODTARJ := LEFT( vtarjeta[ele], 3 )
					ATOT[ED_MODE] = "MOSTRARTODO"
				ENDIF
			ENDIF
		ELSEIF EDNOM(ATOT) == "cCLIENTE"
			lBuscar := .T.
			IF nB == 2 .AND..NOT. ALLTRIM(cCLIENTE) $ "CF EX -1 -3 -4" .AND. LASTKEY() # K_TAB
				lBuscar := ( PREGUNTA( 12, " ¨ LO BUSCO ?   [ S / N ]", "SsNn") $ "Ss" )
			ENDIF
			ATOT[ED_MODE] = "MOSTRARTODO"
			IF lastkey() == K_TAB
				IF FAC_A_CC
					aux := if(FELEGIR("CLI")==0,0,CL->CODCLI)
					if aux # 0
						if !empty(CL->FECHBAJA) .and. CL->FECHBAJA<=dFECHA
							MENSAJE( 0, 0, 10, .T., "Cta.Cte.CERRADA el "+dtoc(CL->FECHBAJA) +" !!!" )
							if !lPermiso;	aux:=0;	endif
						endif
					endif
				ELSE
					aux := if(FELEGIR("CLA")==0,0,CLA->CODCLI)
				ENDIF
				IF aux # 0
					nCODCLI := aux
					DATOSCL(nCODCLI,.T.)
				ENDIF
			ELSEIF nB == 2 .AND. ALLTRIM(cCLIENTE) $ "CF EX -1 -3 -4"
				IF LEFT(cCLIENTE,3) == "EX " .OR. VAL(cCLIENTE) == -3
					nCODCLI	:= -3
					cCLIENTE := JUSTIF("EXENTO", LEN(CLA->RAZONSOC), "<" )
					cCATIVA	:= "EX "
				ELSEIF left(cCLIENTE,3)=="CF " .OR. VAL(cCLIENTE) == -1
					nCODCLI	:= -1
					cCLIENTE := JUSTIF("CONSUMIDOR FINAL", LEN(CLA->RAZONSOC), "<" )
					cCATIVA	:= "CF "
				ELSEIF left(cCLIENTE,3)=="RM ".OR. VAL(cCLIENTE) == -4
					nCODCLI	:= -1
					cCLIENTE := JUSTIF("RESP.MONOTRIB.", LEN(CLA->RAZONSOC), "<" )
					cCATIVA	:= "RM "
				ENDIF
			ELSEIF !EMPTY(cCLIENTE) .AND. UPDATED() .AND. lBuscar
				if val(cCliente)==0 .and. len(alltrim(cCLIENTE)) < 2
					MENSAJE(0,0,10,.T., "SEA MAS ESPECIFICO !" )
				else
					set order to
					select ( "CL"+IF(FAC_A_CC,"","A") )
					aaux := {}
					// busca CUIT
					IF VAL(cCLIENTE) # 0 .AND. "-" $ cCLIENTE
						MENSAJE( 0, 0, 0, .F., "buscando Clientes con "+ ALLTRIM(cCLIENTE) +" en el CUIT ..." )
						aux := strtran( alltrim( cCLIENTE ), "-", "" )
						locate for aux $ FIELD->CUIT
						do while !eof()
							if aux $ FIELD->CUIT
								AADD( aaux, STR(FIELD->CODCLI) +" ³ "+ FIELD->RAZONSOC +" ³ "+ FIELD->CUIT )
							endif
							skip
						enddo
						set order to 1
						RECUPAN()
						// busca RAZONSOC
					ELSE
						aux	:= ALLTRIM(cCLIENTE)
						IF VAL(aux) # 0			// es un C¢digo de Cliente
							aaux := { aux }
						ELSE
							MENSAJE( 0, 0, 0, .F., "buscando " + aux +" . . ." )
							locate for aux $ FIELD->RAZONSOC
							do while !eof()
								if aux $ FIELD->RAZONSOC
									AADD( aaux, STR(FIELD->CODCLI) +" ³ "+ FIELD->RAZONSOC +" ³ "+ FIELD->CUIT )
								endif
								skip
							enddo
							RECUPAN()
						ENDIF
						set order to 1
					ENDIF
					IF LEN(aaux) == 0
						MENSAJE( 0, 0, 10, .T., "NO encontr‚ nada con: "+ aux +" !!!" )
						IF !FAC_A_CC
							IF PREGUNTA( 12, "¨ QUERES AGREGARLO ?   [ S / N ]", "SsNn") $ "Ss"
								IF CLA( K_F5 )
									nCODCLI	  := CLA->CODCLI
									cCLIENTE   := CLA->RAZONSOC
									cDOMCOM	  := CLA->DOMCOM
									cCUIT 	  := CLA->CUIT
									nTIPOVENTA := 1
									cCATIVA	  := CLA->CATIVA
									nCODLOC	  := CLA->CODLOC
								ENDIF
							ENDIF
						ENDIF
					ELSEIF LEN(aaux) > 1
						xcolor:=SETCOLOR(C_GET)
						xmenu := MENUDOWN({"     º  ENTER   º  ESC   ",;
												 "       º          º        ",;
												 " mueve º confirma º  sale  "})
						ele = PP_SELEC( 7, 15, 0, 0, aaux, 1, "", "S", .T., .F. )
						IF LASTKEY() == K_ENTER
							aaux := { aaux[ele] }
						ENDIF
						RECUPAN()
						PONEPAN(xmenu)
						SETCOLOR(xcolor)
					ENDIF
					******************
					if LEN(aaux) # 0
						IF FAC_A_CC
							GO val(aaux[1])
							if !empty(CL->FECHBAJA) .and. CL->FECHBAJA<=dFECHA
								MENSAJE( 0, 0, 10, .T., "Cta.Cte.CERRADA el "+dtoc(CL->FECHBAJA) +" !!!" )
								if !lPermiso;	aaux:={};  endif
							endif
						ENDIF
						if len(aaux) # 0
							nCODCLI := VAL(aaux[1])
							DATOSCL(nCODCLI,.T.)
						endif
					endif
					******************
				endif
			ENDIF
		ELSEIF EDNOM(ATOT) == "cCODEMP"
			IF ATOT[ED_TECLA] == K_TAB
				IF FELEGIR("EMPLEADO", cCODEMP) # 0
					cCODEMP := EM->CODEMP
				ENDIF
			ELSE
				IF EMPTY(EMP(cCODEMP))
					cCODEMP := space(len((XF)->CODEMP))
				ENDIF
			ENDIF
		ELSEIF EDNOM(ATOT) == "cCATIVA"
			IF LASTKEY() == K_TAB
				ele = PP_SELEC( 3, 50, 0, 0, aCatIva, ascan(aCatIva,{|a|left(a,1)==cCATIVA}), "", "S", .T., .F. )
				RECUPAN()
				IF LASTKEY() == K_ENTER
					cCATIVA := LEFT(aCatIva[ele],3)
				ENDIF
			ELSE
				IF cCATIVA == "EX "
					nCODCLI	:= -3
				ELSEIF cCATIVA == "RM "
					nCODCLI	:= -4
				ELSE
					nCODCLI	:= -1
					cCATIVA	:= "CF "
           ENDIF
			ENDIF
		ELSEIF EDNOM(ATOT) == "dFECHA"
			dFECHEMI := dFECHA
		ELSEIF EDNOM(ATOT) == "cTURNO"
			IF LASTKEY() == K_TAB
				ele = PP_SELEC( 3, 50, 0, 0, aturno, ASCAN(aturno,{|a|LEFT(a,1)==cTURNO}), "", "S", .T., .F. )
				RECUPAN()
				IF LASTKEY() == K_ENTER
					cTURNO := LEFT(aturno[ele],1)
				ENDIF
			ENDIF
		ELSEIF EDNOM(ATOT) == "nNUMERO"
			IF FREPEAT( nNUMERO, IF(nMODO==K_F2,"MODIF","AGRE") )
				MENSAJE( 0, 0, 10, .T., "NUMERO REPETIDO !!!" )
				nNUMERO := ATOT[ED_LAST]
				ATOT[ED_TECLA] := 0
			ENDIF
		ENDIF
	ELSEIF ATOT[ED_TECLA] == K_ALT_N
		NUMFECH()
		ATOT[ED_MODE] = "MOSTRARTODO"
		* * *   Ver quincenas p/facturar   * * *
	ELSEIF ATOT[ED_TECLA] == K_F1 .AND. ( XF$"FA FB" )
		IF FILE(cDiscoCentral+UT_SISTEMA+"\EST\FAC"+IF(nB==1,"A","B")+"CC.DBF")
			FBASES({"+"+cDiscoCentral+UT_SISTEMA+"\EST\FAC"+IF(nB==1,"A","B")+"CC", "+"+cDiscoCentral+UT_SISTEMA+"\EST\FAC"+IF(nB==1,"A","B")+"CC2","+CCV"})
			SELECT FAC
			lastmenu:=MENUDOWN({"º  <+>  º PgUp   º  F3   º   F4   º ENTER  º ESC  º",;
								  	  "º       º PgDown º       º        º elige  º      º",;
									  "º mueve º mueve+ º busca º busca+ º y sale º sale º"})
			aCpo := {;
				{ "NUMFAC", 		  "N§;Borrador",					 '', 'F',  '',  0, 0 },;
				{ "FECHA",			  "Fecha",							 '', 'F',  '',  0, 0 },;
				{ "RAZONSOC",		  "Raz¢n Social",  REPLIC('X',20), 'F', 'F',  0, 0 },;
				{ "TOTAL",			  "Total",							 '', 'F',  '',  0, 0 },;
				{ "NUMFACC",		  "Factura",						 '', 'F',  '',  0, 0 } }
			aCpo := FARRAYAUX( aCpo )
			lastreg = RECNO()
			SET ORDER TO 2
			if !DBSEEK( 0, .T. )
				GO TOP
			endif
			SET ORDER TO 1
			MARCO( 10, 1, 20, 60, "³ BORRADOR ³", "D", .T., 0 )
			OX := MYBROWSE( 10, 1, 20, 60, aCpo )
			OX:CARGO[TB_REFRESH] := 0
			DO WHILE .T.
				MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER} )
				IF OX:Cargo[TB_MSGE] == "MODIF"
				ELSEIF OX:Cargo[TB_RET] == K_ENTER
					nCODCLI	  := FAC->CODCLI
					cCLIENTE   := FAC->RAZONSOC
					cCUIT 	  := FAC->CUIT
					nTIPOVENTA := FAC->TIPOVENTA
					cCATIVA	  := FAC->CATIVA
					CL->(dbseek(nCODCLI))
					cDOMCOM	  := CL->DOMCOM
					nCODLOC	  := CL->CODLOC
					nCODCORR   := CL->CODCORR
					KEYBOARD CHR(K_ENTER)
					*K := INKEY(1)
					K := K_ENTER
					lCCV := .T.
					EXIT
				ELSEIF OX:Cargo[TB_RET] == K_ESC
					EXIT
				ENDIF
			ENDDO
			RECUPAN()
			PONEPAN(lastmenu)
		ELSE
			MENSAJE( 0, 0, 10, .T., "NO ME PUEDO CONECTAR CON CENTRAL !!!" )
		ENDIF
		SELECT (XF)
	ELSEIF ( ATOT[ED_TECLA]==K_ENTER .AND. ATOT[ED_I]==LEN(ATOT[ED_EDIT]) )
		dFECHA := IF( EMPTY(dFECHA), VA->ULFECHA, dFECHA )
		IF nB == 4
			cCLIENTE := JUSTIF("CONSUMIDOR FINAL", len(CLA->RAZONSOC), "<" )
			cCATIVA	:= "CF "
			nCODCLI	:= -1
		ENDIF
		IF !EMPTY(cCLIENTE)
			IF nB == 3
				IF ASCAN(aturno,{|a,i| left(a,1)==cTURNO} ) # 0
					EXIT
				ENDIF
			ELSE
				EXIT
			ENDIF
		ENDIF
	ELSEIF ATOT[ED_TECLA] == K_ESC
		EXIT
	ENDIF
ENDDO
PONEPAN(xmenu3)
SET(_SET_CURSOR,SC_ON)

RETURN
