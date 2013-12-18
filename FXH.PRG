FUNC FX
local guardar, NUEVO, MODIFICABLE, modoaux, xedit, lSalir
PRIVATE EDX, ATOT, aCpoF
if file("\salir.tmp");  return;  endif

set deleted on
#include "BL.CH"
#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"
#include "HFISCAL.CH"

#define ym2   2
#define xm2   0
#define yi		9
#define yf		18
#define FAC_A_CC			(XF=="RE".OR.(XF$"FA FB".and.(nMODO==K_F11.or.cTIPOVENTA=="2")))

RG_CODPROD	   := 1
RG_CANTIDAD   := 2
RG_DESCPROD   := 3
RG_PRECBASE   := 4
RG_PRECUNIT   := 5
RG_IMPORTE	   := 6
RG_PORCDESC   := 7
RG_DESCUENTO  := 8
RG_IMPINT	   := 9
RG_IVA1		   := 10
RG_IVA2		   := 11
RG_TPRECBASE  := 12
RG_TDESCUENTO := 13
RG_TIMPINT	   := 14
RG_TIVA1 	   := 15
RG_TIVA2 	   := 16
RG_RUBRO 	   := 17
RG_TIPOIMPINT := 18
RG_NEGOCIO	   := 19
RG_REGISTRO   := 20

SETCOLOR(C_FONDO)
MEMOEDIT( MEMOREAD("BOLETA.PAN"), 0, 0, 24, 79, ".F.", 180 )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
DBFABRIR()
select PRD
*FBASES( { "PROD", "GRUPO", "FACA","FACA2", "FACB","FACB2", "REM","REM2", "CLIENTES", "ARTIC", "ARTIC2", "CLA", "TICKETS", "TICKETS2", "RUBRO","EMPLEADO" }, .F. )
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
aCpoF[RG_CANTIDAD,ATB_MASC] := "@Z #####.####"

select TI;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()
select RE;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()
select FB;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()
select FA;	dbsetorder( forder({"NUMFAC"}) );	dbgobottom()

cSTOCKACT := "STOCKACT"+if("2"$curdir(),"2","")

AXR	:= {}
lCCV	:= .F.
nMODO := 0
cMODO := "   "
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
cNUMCOB	   := ""
nPPERC     := 0

cTIPOVENTA := "1"
nCONDVTA   := 1
cCATIVA	   := "   "
nSeconds   := nSeconds2 := SECONDS()

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
M->TPERCIB   := 0
M->TOTAL 	  := 0
M->PIVA1     := VA->PIVA1
M->PIVA2	  := 0

STORE 0 TO FPRECBASE, FIMPINT, FIMPINT2, FREGART, FPRECCOMPRA, NGRUPO, NUNXCAJA, FPRECVENTA, NRUBRO, NCONIMPINT
FTIPOIMPINT := " "

A_CODPROD := 1
A_TOTALITROS := 0
A_PORCDESC := 0
A_LXF_MIN := 0
A_LXF_MAX := 0

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
	nSeconds2 := IF( K==0, nSeconds2, SECONDS() )

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
		@ 23, 72 say time() color C_MENUDN
		DBCOMMITALL()
		DBUNLOCKALL()
		if (seconds()-nSeconds2) > 60*60
     	DBFABRIR()
			nSeconds2 := SECONDS()
		elseif (SECONDS()-nSeconds) > VA->SECONDS
			if file("SAVSCR.BAT")
				aux := SAVESCREEN(0,0,24,79)
				RUN SAVSCR.BAT
				CLEARTYPEAHEAD()
				RESTSCREEN(0,0,24,79,aux)
			endif
			nSeconds := SECONDS()
		endif
     if file("\salir.tmp");  exit;  endif
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
	ELSEIF LASTKEY() == 47 .AND. "FA"$cCOMPR_PERMIT	  //	/				( A )
		DISPBEGIN()
		nB  := 1
		XF  := "FA"
		XF2 := "FA2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == 42 .AND. "FB"$cCOMPR_PERMIT	  //	*				( B )
		DISPBEGIN()
		nB  := 2
		XF  := "FB"
		XF2 := "FB2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == 45 .AND. "RE"$cCOMPR_PERMIT	 //  -			  ( R )
		DISPBEGIN()
		nB  := 3
		XF  := "RE"
		XF2 := "RE2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == 43 .AND. "TI"$cCOMPR_PERMIT	  //	+				( T )
		DISPBEGIN()
		nB  := 4
		XF  := "TI"
		XF2 := "TI2"
		ATOT := NEWEDIT2( aPan[nB], .F., .F. )
		FEDITOR( ATOT,"PONEPAN")
		DISPEND()
	ELSEIF LASTKEY() == K_TAB
		FELEFAC( XF )
	ELSEIF K == K_F8 .and. XF="FB" 	//.and. lPUBLICO
		if file("AUTOFAC.MEM")
			RESTORE FROM AUTOFAC.MEM ADDITIVE
		endif
		xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
                 	  "       º         º        ",;
                 	  " mueve º procede º  sale  "})
		aaux := NEWEDIT2( "AUTOFAC",,.T. )
		aaux[ED_I] := 1
		aaux[ED_MODE] = "MOSTRARTODO"
		do while .T.
			FEDITAR2( aaux, { K_F10 } )
			if aaux[ED_UPDATE]
				aaux[ED_MODE] = "MOSTRAR"
			elseif aaux[ED_TECLA] == K_TAB .AND. EDNOM(aaux)== "A_CODPROD"
				if FELEGIR( "PRODUCTO", A_CODPROD ) # 0
					A_CODPROD := PRD->CODPROD
					aaux[ED_MODE] = "MOSTRARTODO"
				endif
			elseif aaux[ED_TECLA] == K_F10
 				SAVE ALL LIKE A_* TO AUTOFAC.MEM
				exit
			elseif aaux[ED_TECLA] == K_ESC
				exit
			endif
		enddo
		FEDITOR(aaux,"SACAPAN")
		MENUDOWN(xmenu)
		if aaux[ED_TECLA] # K_ESC
		MENSAJE(0,0,0,.F.,"FACTURANDO..." )
     do while A_TOTALITROS>0
     	select (XF)
			cTIPOVENTA:="1";  cMODO:="   ";	nMODO:=K_F5
			@ 0, 77 say cMODO color "*"+setcolor()
			lNuevo  := .T.
			bNoRep  := {|x| IF( FREPEAT(x,"AGREGAR"), EVAL({|| MENSAJE(0,0,10,.T.,"NUMERO REPETIDO !!!" ),.F.}), .T. ) }
			nCODCLI := 0

			RNUMERO := nNUMERO := FNUMERO()
			DATOSCL(nCODCLI,.F.)
			lCCV := .F.
			FVERREG( ATOT,, .T. )

			nLin := 1
			AXR[nLin,RG_CODPROD		] := A_CODPROD
			AXR[nLin,RG_NEGOCIO		] := " "
			AXR[nLin,RG_DESCPROD 	] := LEFT(FPRODUCTO(AXR[nLin,RG_CODPROD],AXR[nLin,RG_NEGOCIO]),20)
			AXR[nLin,RG_RUBRO			] := NRUBRO
			AXR[nLin,RG_PRECBASE		] := FPRECBASE
			AXR[nLin,RG_PORCDESC		] := A_PORCDESC
			AXR[nLin,RG_DESCUENTO	] := AXR[nLin,RG_PRECBASE] * A_PORCDESC / 100
			AXR[nLin,RG_TIPOIMPINT	] := FTIPOIMPINT
			AXR[nLin,RG_IMPINT		] := FIMPINT
			AXR[nLin,RG_IVA1 		   ] := AXR[nLin,RG_PRECBASE] * M->PIVA1 / 100
			AXR[nLin,RG_IVA2 		   ] := AXR[nLin,RG_PRECBASE] * M->PIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[nLin,RG_RUBRO]==1,0,1)


			i := xrandom(A_LXF_MAX-A_LXF_MIN) + A_LXF_MIN
        if A_TOTALITROS-i<0
        	i := A_TOTALITROS
        endif
			AXR[nLin,RG_CANTIDAD		] := i
     	A_TOTALITROS -= i
			AXR[nLin, RG_PRECUNIT	] := FPRECVENTA
			AXR[nLin,RG_IMPORTE 		] := AXR[nLin,RG_CANTIDAD] * AXR[nLin,RG_PRECUNIT]

			FCALCPRECIO( AXR, nLin )
			FXTOTAL()

			if lPUBLICO
				aRet:=FISCAL(XF)
           if len(aRet[F_ERRORES]) > 0
					MARCO( 5, 20, len(aRet[F_ERRORES]), 70, "ERRORES", "D", .T., 0 )
              for i=1 to len(aRet[F_ERRORES])
                 @ 4+i,20 say aRet[F_ERRORES,i]
              next
					TONE(500, 5);  TONE(100, 1)
              inkey(3)
              RECUPAN()
           endif
				GRABAR()
			endif
        if lastkey()==K_ESC; exit; endif
        k:=inkey(1)
        if k==K_ESC; exit; endif
     enddo
     RECUPAN()
     endif
		nCODCLI := 0
		CLEARTYPEAHEAD()
	ELSEIF LASTKEY() == K_F9
		FELEGIR("CLA")
	ELSEIF LASTKEY() == K_F1 .and. lPermiso
		STA()
	ELSEIF LASTKEY() == K_ALT_M
		CALC()
	ELSEIF K==K_F5 .OR. (K==K_F2 .AND. FIELD->PASADO==' '.AND. lPermiso) .OR. K==K_F12 .OR. K==K_F11 .or. K==K_ALT_F5
		if K==K_F11
			cTIPOVENTA:="2";  cMODO:="F11"
		elseif K==K_ALT_F5
			cTIPOVENTA:="3";  cMODO:="AF5"
		else
			cTIPOVENTA:="1";  cMODO:=if(K==K_F12,"F12","   ")
		endif
		@ 0, 77 say cMODO color "*"+setcolor()
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
					if lPUBLICO 				//.OR. ( XF=="RE" .and. "DOCSA"$CURDIR() )
						if nMODO==K_F5 .or. nMODO==K_F11
							aRet:=FISCAL(XF)
                    if nMODO==K_F11
                    	aRetAux := aclone(aRet)
								FISCAL("RE")
                       aRet := aclone(aRetAux)
                    endif
                    if len(aRet[F_ERRORES]) > 0
								MARCO( 5, 20, len(aRet[F_ERRORES]), 70, "ERRORES", "D", .T., 0 )
                    	for i=1 to len(aRet[F_ERRORES])
                       	@ 4+i,20 say aRet[F_ERRORES,i]
                       next
								TONE(500, 5);  TONE(100, 1)
                       inkey(0)
                       RECUPAN()
*                      loop
                    endif
						endif
              else
              	aRet := array(F_ERRORES)
                 afill(aRet,0)
                 aRet[F_FECHA] := ctod('')
                 aRet[F_HORA]  := ""
              endif
					if GRABAR()
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
			FREABRIR({"FACA","FACA2","FACB","FACB2","TICKETS","TICKETS2"})
        select FA;  dbgobottom()
        select FB;  dbgobottom()
        select RE;  dbgobottom()
        select TI;  dbgobottom()
        select (XF)
		endif
#ifdef ESFISCAL
	ELSEIF LASTKEY()==K_ALT_X .and. lPUBLICO
		if FCLAVE(VA->CLAVEP);  aRet:=FISCAL("X");  endif
	ELSEIF LASTKEY()==K_ALT_Z .and. lPUBLICO
		if FCLAVE(VA->CLAVEP);  aRet:=FISCAL("Z");  endif
	ELSEIF LASTKEY()==K_ALT_F8
		op2 = MENUFLASH( 10, 30, 1, .F., "", "Tomar Fecha y Hora del Controlador", "Cancelar" )
     if op2==1
			aRet:=FISCAL("GETDATETIME")
     elseif op2==2
			aRet:=FISCAL("CANCELAR")
     endif
     RECUPAN()
#else
	ELSEIF LASTKEY()==K_ALT_X
		DO REST
	ELSEIF LASTKEY()==K_ALT_Z
		if FCLAVE(VA->CLAVEP);  ZT(.T.);	endif
	ELSEIF CHR(LASTKEY())$"Zz"
		if FCLAVE(VA->CLAVEP);  ZT(.F.);	endif
#endif
	ELSEIF CHR(LASTKEY()) $ 'Tt'
*		if CLAVEMP()
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
*				i:=EDNUM(EDX,"VA->ULFECHA");	if i#0;	EDX[ED_EDIT]:=stuff(EDX[ED_EDIT],i,1,"E");  endif
			endif
*       EDPONE(EDX,"VA->ULFECHA",date())
			do while .T.
				FEDITAR( EDX, { K_ALT_F8, K_F10 } )
				if EDX[ED_UPDATE]
					EDX[ED_MODE] = "MOSTRARTODO"
#ifdef NADA
							cProximoTurno:=if( VA->ULTURNO=="3", "1", str(val(VA->ULTURNO)+1,1) )
							if EDCONT(EDX,"VA->ULTURNO") # cProximoTurno
								MENSAJE( 0, 0, 10, .T., "TURNO INCORRECTO !!! " )
								if !lPermiso
									EDPONE(EDX,,VA->ULTURNO)
								endif
							else
								if EDCONT(EDX,"VA->ULTURNO")=="1"
									EDPONE(EDX,"VA->ULFECHA",date())
								endif
							endif
#endif
#ifdef NADA
					if EDNOM(EDX)=="VA->ULTURNO"
						if !EDCONT(EDX,"VA->ULTURNO") $ "123"
							MENSAJE( 0, 0, 10, .T., "TURNO INCORRECTO !!! " )
							EDPONE(EDX,"VA->ULTURNO",EDX[ED_LAST])
                 endif
					elseif EDNOM(EDX)=="VA->ULFECHA"
						if EDCONT(EDX,"VA->ULFECHA") < (date()-1)
							MENSAJE( 0, 0, 10, .T., "FECHA INCORRECTA !!! " )
							EDPONE(EDX,"VA->ULFECHA",EDX[ED_LAST])
                 endif
					endif
#endif
				elseif EDX[ED_TECLA] == K_ALT_F8
					aaux := {{"FA","ULFACA"+cSUCURSAL,"NUMFAC"},{"FB","ULFACB"+cSUCURSAL,"NUMFAC"},{"RE","ULREM","NUMFAC"},{"TI","ULTICK","NUMFAC"}}
					FOR i=1 TO LEN(aaux)
						SELECT (aaux[i,1])
						aux := RECNO()
						DBGOBOTTOM()
						EDPONE( EDX, "VA->"+aaux[i,2], (aaux[i,1])->&(aaux[i,3]) )
						GO aux
					NEXT
					EDX[ED_MODE] = "MOSTRARTODO"
				elseif EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
					aux := "S"
					IF EDX[ED_TECLA] == K_F10
						aux := "G"
					ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
						aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					ENDIF
					IF aux == "G"
#ifdef NADA
						if EDCONT(EDX,"VA->ULTURNO")$"12" .and. EDCONT(EDX,"VA->ULFECHA")#date()
							MENSAJE( 0, 0, 10, .T., "EL TURNO O LA FECHA ESTAN MAL !" )
                    aux := "C"
                 endif
#endif
              endif
					IF aux == "G"
						SELECT VA
						FEDITOR( EDX, "GRABAR", .F. )
						DBCOMMITALL()
						EXIT
					ELSEIF aux == "S"
						EXIT
					endif
				endif
			enddo
			FEDITOR(EDX,"SACAPAN")
			SELECT (cBase)
			PONEPAN(cXmenu)
			SETCOLOR(cColor)
*		endif
	ELSEIF LASTKEY() == K_F6 .and. lPermiso
		r := .T.
		if DBF() $ "FA FB RE"
			if val(FIELD->NUMCOB)#0
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
					IF XF$"FA FB" .and.(XF)->TIPOVENTA=="2"
              ELSE
						IF (XF2)->NEGOCIO == "*"
							SEEK (XF2)->CODPROD
							IF FOUND() .AND. (XF)->FECHA>=ART->FECHA
								FRLOCK()
								ART->&(cSTOCKACT) += (XF2)->CANTIDAD
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
			IF val(FIELD->NUMCOB)#0
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
					if XF$"FA FB".and.(XF)->TIPOVENTA=="2"
              else
						if (XF2)->NEGOCIO == "*"
							seek (XF2)->CODPROD
							if found() .and. (XF)->FECHA>=ART->FECHA
								FRLOCK()
								ART->&(cSTOCKACT) += (XF2)->CANTIDAD
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
*AXR := array(if(nB==4,30,11))
if cSUCURSAL=="1"
	AXR := array(150)
else
	AXR := array(50)
endif
for i=1 to len(AXR)
	AXR[i] := array(RG_REGISTRO)
	eval( bRegVacio, @AXR, i )
next
bTot := {||;
		DEVPOS( 21, 1 ), QQOUT( TRANS(M->TDESCUENTO ,"#######.##") ),;
		DEVPOS( 21,14 ), QQOUT( TRANS(M->TPRECBASE  ,"#######.##") ),;
		DEVPOS( 21,27 ), QQOUT( TRANS(M->TIMPINT	  ,"#######.##") ),;
		DEVPOS( 21,39 ), QQOUT( TRANS(M->TIVA1 	   ,"######.##") ),;
		DEVPOS( 21,50 ), QQOUT( TRANS(M->TIVA2   	    ,"#####.##") ),;
		DEVPOS( 21,60 ), QQOUT( TRANS(M->TPERCIB	     ,"####.##") ),;
		DEVPOS( 21,69 ), QQOUT( TRANS(M->TOTAL 	  ,"#######.##") ) }

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

M->PIVA1	 := VA->PIVA1
M->PIVA2	 := 0
IF cCATIVA == "RNI"
	M->PIVA2		 := VA->PIVA2
ENDIF

select (XF2)
if lCCV
	bCond := {|| FAC2->NUMFAC==FAC->NUMFAC}
	SELECT FAC2
	SEEK FAC->NUMFAC
else
	bCond := {|| (XF2)->NUMFAC==nNUMERO}
	SEEK nNUMERO
endif
i := 0
do while eval(bCond) .and. !EOF() .and. i<len(AXR)
	++i
	FPRODUCTO(FIELD->CODPROD,FIELD->NEGOCIO)
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
	skip
enddo
select (XF2)

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
        if alltrim(ART->CODSCAN)==alltrim(AXR[nLin,RG_DESCPROD])
				AXR[nLin,RG_CODPROD] := ART->CODPROD
				AXR[nLin,RG_NEGOCIO] := "*"
				KEYBOARD CHR(K_ENTER)+"1"+CHR(K_ENTER)
        endif
			SET ORDER TO 1
			SELECT (aux)
		ELSEIF nCol==1 .and. (nB==4 .and. !"*"$AXR[nLin,RG_DESCPROD] .and. K#K_SH_TAB) .or. (nB#4.and.("*"$AXR[nLin,RG_DESCPROD] .or. K==K_SH_TAB))
			IF (K==K_SH_TAB.and.nB#4) .OR. (K==K_TAB.AND.nB==4)
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
			IF K==K_TAB .OR. K==K_SH_TAB
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
				r := SELECTPRD( strtran(AXR[nLin,RG_DESCPROD],"*","") )
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
*				AXR[nLin,RG_PORCDESC] := PRD->PUTILM
				AXR[nLin,RG_CANTIDAD] := AXR[nLin,RG_CANTIDAD] * PRD->UNXCAJA
			ENDIF
			AXR[nLin,RG_IMPORTE ] := AXR[nLin,RG_CANTIDAD] * AXR[nLin,RG_PRECUNIT]
			KEYBOARD CHR(LASTKEY())
			IF UPDATED()
				KEYBOARD CHR(K_ENTER) + CHR(K_ENTER) + CHR(K_ENTER)
			ELSE
				KEYBOARD CHR(K_ENTER) + CHR(K_ENTER)
			ENDIF
		ELSEIF nCol == 3												// PORCDESC
			if nB==4
				if !lPermiso;	AXR[nLin,RG_PORCDESC]:=0;	endif
			endif
			KEYBOARD CHR(K_ENTER)
		ELSEIF nCol == 4												// IMPORTE
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
			aRet:=FISCAL(XF)
        if len(aRet[F_ERRORES]) > 0
				MARCO( 5, 20, 5+len(aRet[F_ERRORES]), 70, "ERRORES", "D", .T., 0 )
           for i=1 to len(aRet[F_ERRORES])
           	@ 5+i,20 say aRet[F_ERRORES,i]
          	next
				TONE(500, 5);  TONE(100, 1)
          	inkey(0)
          	RECUPAN()
			endif
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
		cTIPOVENTA := "3"
		FXTOTAL()
		FVERREG( ATOT,, .T. )
		lRepant := .T.
	ELSEIF K == K_ESC .or. K==K_F10
		if K == K_ESC
			aux := PREGUNTA( 12, "[ G ] graba    [ S ] sale     [ C ] contin£a", "GgSsCc" )
			if aux $ "Gg"
				K := K_F10
			elseif aux $ "Ss"
				K := K_ESC
				exit
        endif
		endif
		if K == K_F10
			if xF=="TI" .and. M->TOTAL == 0
				MENSAJE( 0, 0, 10, .T., "TICKET EN 0 !" )
  		endif
*			if (VA->LIM_PERIB<>0) .and. (VA->PPERCIB1+VA->PPERCIB2<>0)
*				if (M->TPRECBASE+M->TIMPINT) >= VA->LIM_PERIB
*					if UPPER( PREGUNTA( 11, "Se aplicar  sobretasa a esta factura.  Contin£a [S/N] ?", "SsNn") )=="S"
*          		exit
*          	endif
*       	endif
*    	endif
			if xF=="TI" .and.M->TOTAL == 0
				MENSAJE( 0, 0, 10, .T., "TICKET EN 0 !" )
			elseif xF $ "TI FB" .and. M->TOTAL>1000 .and. !lPermiso
				MENSAJE( 0, 0, 10, .T., "EL TICKET/FACTURA 'B' NO PUEDE SUPERAR LOS $1000" )
			elseif xF $ "FA" .and. M->TOTAL>5000 .and. !lPermiso
				MENSAJE( 0, 0, 10, .T., "EL TICKET/FACTURA NO PUEDE SUPERAR LOS $5000" )
     	else
     		exit
  		endif
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
	if lRepant
		SETCOLOR(C_FONDO)
		EVAL( bDetalle1, nLin, nPy )
		SETCOLOR(C_GET)
		EVAL( bDetalle2, nLin, nPy )
		EVAL( bTot )
	endif

ENDDO

return( K == K_F10 )


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

cHORA:=time()
if XF $ "FA FB TI RE" .and. (nMODO==K_F5.or.nMODO==K_F11)
	if XF=="TI"
		nNUMERO := aRet[F_ULTTICK]
 		if nNUMERO==0;	nNUMERO:=VA->&("ULTICK")+1;  endif
	elseif XF=="FB"
		nNUMERO := aRet[F_ULTFACB]
 		if nNUMERO==0;	nNUMERO:=VA->&("ULFACB"+cSUCURSAL)+1;  endif
	elseif XF=="FA"
		nNUMERO := aRet[F_ULTFACA]
 		if nNUMERO==0;	nNUMERO:=VA->&("ULFACA"+cSUCURSAL)+1;  endif
  endif
	dFECHEMI := aRet[F_FECHA]
  cHORA    := aRet[F_HORA]
  RNUMERO  := nNUMERO
endif

select (xB)
set order to 1
cHORA := if(val(strtran(cHORA,":",""))==0,time(),cHORA)
if RNUMERO # 0 			//  busca y borra el anterior
*	cHORA := if(dbseek(RNUMERO),FIELD->HORA,TIME())
*	if (XF$"FA FB".and.(XF)->TIPOVENTA=="2")
* else
 		select (xB2)
 		set order to 1
		do while dbseek(RNUMERO)
			if (xB2)->NEGOCIO=="*"		// .and. (XF$"FA FB".and.(XF)->TIPOVENTA#"2")
				select ART
				if dbseek((xB2)->CODPROD) .and. (xB)->FECHA>=ART->FECHA
					frlock()
					ART->&(cSTOCKACT) += (xB2)->CANTIDAD
					dbunlock()
					if ART->COMPUESTO # 0
						FCOMPUESTO( (xB2)->CODPROD, +(xB2)->CANTIDAD, (xB)->FECHA )
					endif
				endif
				select (xB2)
			endif
			BLANKREG()
		enddo
* endif
	select (xB)
	do while dbseek(RNUMERO)
		BLANKREG()
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
	RE->NUMCOB	  := if(lNUEVO,"",cNUMCOB)
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
	FIELD->TIPOVENTA:= if(nMODO==K_ALT_F5,"3",cTIPOVENTA)
	FIELD->CONDVTA  := nCONDVTA
	FIELD->NUMCOB	 := if(lNUEVO,"",cNUMCOB)
	FIELD->CODTARJ := cCODTARJ
	FIELD->NUMTARJ := cNUMTARJ
	FIELD->NUMCUPON:= cNUMCUPON
	FIELD->NEGOCIO := if( ascan(AXR,{|a,i|a[RG_NEGOCIO]=="*"})==0, " ", "*" )
	FIELD->PERCIB   := M->TPERCIB
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
*	(xB)->NUMCOB := "CCV"
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
*		if (XF$"FA FB".and.(XF)->TIPOVENTA=="2")
* 	else
			if (xB2)->NEGOCIO == "*"
				select ART
				if dbseek((xB2)->CODPROD) .and. (xB)->FECHA>=ART->FECHA
					frlock()
					ART->&(cSTOCKACT) -= (xB2)->CANTIDAD
					dbunlock()
					if ART->COMPUESTO # 0
						FCOMPUESTO( (xB2)->CODPROD, -(xB2)->CANTIDAD, (xB)->FECHA )
              endif
				endif
        endif
*		endif
		select (xB2)
	endif
NEXT
if lNUEVO
	(xB)->HORA	 := cHORA
endif
dbunlockall()
dbcommitall()
recupan()

return .T.


*************

FUNC DATOSCL( cual, lcomo )

*************
local r := 0

dbselectarea( XF )

cCLIENTE   := SPACE(LEN(CLA->RAZONSOC))
cDOMCOM	   := SPACE(LEN(CLA->DOMCOM))
cCUIT 	   := SPACE(LEN(CLA->CUIT))
*cTIPOVENTA := "1"
cCATIVA	   := "   "
nCODLOC	   := 0
cVALORIZADO:= "S"
nCODCORR   := 0
cNUMCOB	   := ""
nPPERC     := 0

if XF$"FA FB" .and. nMODO==K_F11 .or. (lcomo.and.cTIPOVENTA=="2")
	select (XF)
	if CL->(dbseek(cual))
		cCLIENTE   := CL->RAZONSOC
		cDOMCOM	  := CL->DOMCOM
		cCUIT 	  := CL->CUIT
		cTIPOVENTA := "2"
		cCATIVA	  := CL->CATIVA
		nCODLOC	  := CL->CODLOC
		cVALORIZADO:= CL->VALORIZADO
		nCODCORR   := CL->CODCORR
		SELECT (XF)
	endif

elseif nB == 1
	select FA
	if lNUEVO .OR. lcomo
		if CLA->(dbseek(cual))
			cCLIENTE   := CLA->RAZONSOC
			cCUIT 	  := CLA->CUIT
			cCATIVA	  := CLA->CATIVA
			cDOMCOM	  := CLA->DOMCOM
			nCODLOC	  := CLA->CODLOC
		ENDIF
	else
		if FIELD->TIPOVENTA == "2"
			CL->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			cTIPOVENTA := FIELD->TIPOVENTA
			cCATIVA	  := FIELD->CATIVA
			cDOMCOM	  := CL->DOMCOM
			nCODLOC	  := CL->CODLOC
			cVALORIZADO:= CL->VALORIZADO
			nCODCORR   := CL->CODCORR
			cNUMCOB	  := FIELD->NUMCOB
		else
			CLA->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			cTIPOVENTA := FIELD->TIPOVENTA
			cCATIVA	  := FIELD->CATIVA
			cDOMCOM	  := CLA->DOMCOM
			nCODLOC	  := CLA->CODLOC
		endif
	endif

elseif nB == 2
	select FB
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
		if FIELD->TIPOVENTA == "2"
			CL->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			cTIPOVENTA := FIELD->TIPOVENTA
			cCATIVA	  := FIELD->CATIVA
			cDOMCOM	  := CL->DOMCOM
			nCODLOC	  := CL->CODLOC
			cVALORIZADO:= CL->VALORIZADO
			nCODCORR   := CL->CODCORR
			cNUMCOB	  := FIELD->NUMCOB
		else
			CLA->(dbseek(cual))
			cCLIENTE   := FIELD->RAZONSOC
			cCUIT 	  := FIELD->CUIT
			cCATIVA	  := FIELD->CATIVA
			cTIPOVENTA := FIELD->TIPOVENTA
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

elseif nB == 3
	select RE
	if CL->(dbseek(cual))
		cCLIENTE   := CL->RAZONSOC
		cDOMCOM	  := CL->DOMCOM
		cCUIT 	  := CL->CUIT
		cTIPOVENTA := "2"
		cCATIVA	  := CL->CATIVA
		nCODLOC	  := CL->CODLOC
		cVALORIZADO:= CL->VALORIZADO
		nCODCORR   := CL->CODCORR
		SELECT RE
	ENDIF
	IF !lNUEVO .OR. !lcomo
		cNUMCOB	  := FIELD->NUMCOB
	ENDIF

elseif nB == 4
	select TI
	cCLIENTE   := "CONSUMIDOR FINAL"
	cTIPOVENTA := "1"
	cCATIVA	  := "CF "
	nCODLOC	  := -1
endif
if cual == -2
	cCLIENTE := JUSTIF("ANULADA", LEN(CLA->RAZONSOC), "<" )
endif
	IF lNUEVO .OR. lcomo
		cTURNO	  := VA->ULTURNO
	ENDIF
dbselectarea( XF )
if VA->AG_RETIB=="S"
	if cCATIVA$"RI RM "
 		caux := strtran(cCUIT,"-","")
 		if PIB->(dbseek(caux))
  		nPPERC := PIB->PPERC
  	endif
	endif
	@24,1 say nPPERC pict "##.##"
endif

return cCLIENTE


**************

FUNC FNUMERO()

**************
cTURNO		 := " "
cVALORIZADO := "S"
cCODTARJ   := "   "
cNUMTARJ   := SPACE(LEN(FA->NUMTARJ))
cNUMCUPON  := SPACE(LEN(FA->NUMCUPON))
cOBSERV	   := space(len(RE->OBSERV))
cCODEMP	   := EST->CODEMP
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
//	cCODEMP	 := FIELD->CODEMP
	dFECHEMI  := FIELD->FECHEMI
	nNUMERO	 := FIELD->NUMFAC
	IF nB==1 .or. nB==2
		select ({"FA","FB"}[nB])
		cCODTARJ  := FIELD->CODTARJ
		cNUMTARJ  := FIELD->NUMTARJ
		cNUMCUPON := FIELD->NUMCUPON
		nCONDVTA  := FIELD->CONDVTA
	ELSEIF nB == 3
		select RE
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
local xreg	 := RECNO(), OX, aCpo, cBase:=DBF()
local aFF := {{"FA","ULFACA"+cSUCURSAL},{"FB","ULFACB"+cSUCURSAL},{"RE","ULREM"},{"TI","ULTICK"}}
local xmenu  :=MENUDOWN({ "º  <+>  º PgUp   º  F3   º   F4   º   F8   º   F9   º ESPACIO  º ENTER  º ESC  º",;
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
			{ "NUMCOB", 		  "N§;Cobro",							  '', 'E',	'',  0, 0 },;
			{ "CCV->FECHA",     "Fecha;Cierre", 					  '', 'F',	'',  0, 0 } }
	FBASES({"+CCV"})
	select CCV
	set order to CCV_NUMCOB
	select (XF)
	set relation to (XF)->NUMCOB into CCV
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
			{ "NUMCOB", 		  "C¢digo", 							  '', 'E',	'',  0, 0 } }
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
		set order to CCV_NUMCOB
		if dbseek((XF)->NUMCOB)
			MENSAJE( 0, 0, 10, .T., dtoc(CCV->FECHA) )
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
M->TPERCIB   := 0

FOR i=1 TO LEN(AXR)
	M->TPRECBASE  += AXR[i,RG_TPRECBASE]
	M->TDESCUENTO += AXR[i,RG_TDESCUENTO]
	M->TIMPINT	  += AXR[i,RG_TIMPINT]
	M->TIVA1 	  += AXR[i,RG_TIVA1]
	M->TIVA2 	  += AXR[i,RG_TIVA2]
NEXT
M->PORCDESC 	:= M->TDESCUENTO * 100 / IF(M->TPRECBASE==0,1,M->TPRECBASE)
M->TOTAL 		:= M->TPRECBASE + M->TIMPINT + M->TIVA1 + M->TIVA2

if VA->AG_RETIB=="S"
        baseimponible := M->TOTAL - M->TIVA1 - M->TIVA2
        if baseimponible>50 .and. (cCATIVA $ " RM RI ")
           nAux := FPPERC(cCUIT)
				M->TPERCIB := baseimponible * naux / 100
     	endif
			M->TOTAL := M->TOTAL + M->TPERCIB
endif

RETURN M->TOTAL

*********************

STATIC FUNC NUMFECH()

*********************
local EDX := NEWEDIT2( "NUMFECH",,.F. )
select (XF)
EDX[ED_REGISTRO] := 0
EDX[ED_MODE] = "MOSTRARTODO"
EDX[ED_TECLA] = 0
EDX[ED_I] = 1
@ 0, 77 say cMODO color "*"+setcolor()
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
local xmenu, xmenu3

ATOT[ED_REGISTRO] := 0
ATOT[ED_MODE] = "MOSTRARTODO"
ATOT[ED_TECLA] = 0
ATOT[ED_I] = if(nB==3,EDNUM(ATOT,"cOBSERV"),1)
IF (nMODO==K_F12 .or. nMODO==K_ALT_F5)	// .and. procname(1)=="FF"
	op2 = MENUFLASH( 10, 30, 1, .T., "", "1-CONTADO", "2-CUENTA CORRIENTE" )
  cTIPOVENTA := if(op2#2,"1","2")
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
	FEDITAR2( ATOT, {K_TAB, K_ALT_N, K_F1, K_ALT_V} )
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
			if lastkey() == K_TAB
				if FAC_A_CC
					aux := if(FELEGIR("CLI")==0,0,CL->CODCLI)
					if aux # 0
						if !empty(CL->FECHBAJA) .and. CL->FECHBAJA<=dFECHA
							MENSAJE( 0, 0, 10, .T., "Cta.Cte.CERRADA el "+dtoc(CL->FECHBAJA) +" !!!" )
							if !lPermiso;	aux:=0;	endif
						endif
					endif
				else
					aux := if(FELEGIR("CLA")==0,0,CLA->CODCLI)
				endif
				if aux # 0
					nCODCLI := aux
					DATOSCL(nCODCLI,.T.)
				endif
			elseif nB == 2 .and. alltrim(cCLIENTE) $ "CF EX -1 -3 -4"
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
			elseif !empty(cCLIENTE) .and. updated() .and. lBuscar
				if val(cCliente)==0 .and. len(alltrim(cCLIENTE)) < 2
					MENSAJE(0,0,10,.T., "SEA MAS ESPECIFICO !" )
				else
					set order to
					select ( "CL"+IF(FAC_A_CC,"","A") )
					aaux := {}
					// busca CUIT
					if VAL(cCLIENTE) # 0 .AND. "-" $ cCLIENTE
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
					else        // busca RAZONSOC
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
					endif
					if len(aaux) == 0
						MENSAJE( 0, 0, 10, .T., "NO encontr‚ nada con: "+ aux +" !!!" )
						IF !FAC_A_CC
							IF PREGUNTA( 12, "¨ QUERES AGREGARLO ?   [ S / N ]", "SsNn") $ "Ss"
								IF CLA( K_F5 )
									nCODCLI	  := CLA->CODCLI
									cCLIENTE   := CLA->RAZONSOC
									cDOMCOM	  := CLA->DOMCOM
									cCUIT 	  := CLA->CUIT
									cTIPOVENTA := "1"
									cCATIVA	  := CLA->CATIVA
									nCODLOC	  := CLA->CODLOC
								ENDIF
							ENDIF
						ENDIF
					elseif len(aaux) > 1
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
					endif
					******************
					if LEN(aaux) # 0
						if FAC_A_CC
							dbseek( val(aaux[1]) )
							if !empty(CL->FECHBAJA) .and. CL->FECHBAJA<=dFECHA
								MENSAJE( 0, 0, 10, .T., "Cta.Cte.CERRADA el "+dtoc(CL->FECHBAJA) +" !!!" )
								if !lPermiso;	aaux:={};  endif
							endif
						endif
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
	ELSEIF ATOT[ED_TECLA] == K_ALT_V
		aux := cTIPOVENTA
		aux := INGRVAL( 10, 20, "Tipo Vta:", aux, "9", "")
		if lastkey() == K_ENTER
			cTIPOVENTA := aux
     endif
	ELSEIF ATOT[ED_TECLA] == K_ALT_N
		NUMFECH()
		ATOT[ED_MODE] = "MOSTRARTODO"
		* * *   Ver quincenas p/facturar   * * *
	ELSEIF ATOT[ED_TECLA] == K_F1 .AND. ( XF$"FA FB" )
		IF FILE("FAC"+IF(nB==1,"A","B")+"CC.DBF")
			FBASES({"+FAC"+IF(nB==1,"A","B")+"CC", "+FAC"+IF(nB==1,"A","B")+"CC2","+CCV"})
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
					cTIPOVENTA := FAC->TIPOVENTA
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
		if nB == 4
			cCLIENTE := JUSTIF("CONSUMIDOR FINAL", len(CLA->RAZONSOC), "<" )
			cCATIVA	:= "CF "
			nCODCLI	:= -1
		endif
		if !empty(cCLIENTE)
     	lAux:=.T.
			if XF=="FA"
        	if !cCATIVA $ "RI RNI"
					MENSAJE( 0, 0, 10, .T., "le corresponde ticket-factura B !" )
              lAux:=.F.
           elseif val(cCUIT)#0
           	if !FCUIT(cCUIT)
						MENSAJE( 0, 0, 10, .T., "CUIT INCORRECTO !" )
              	lAux:=.F.
              endif
           endif
        elseif XF=="FB"
				if cCATIVA $ "RI RNI"
					MENSAJE( 0, 0, 10, .T., "le corresponde ticket-factura A !" )
              lAux:=.F.
           elseif val(cCUIT)#0
           	if !FCUIT(cCUIT)
						MENSAJE( 0, 0, 10, .T., "CUIT INCORRECTO !" )
              	lAux:=.F.
              endif
				endif
			endif
        if lAux
				if nB == 3
					if ASCAN(aturno,{|a,i| left(a,1)==cTURNO} ) # 0
						exit
					endif
				else
					exit
				endif
        endif
		endif
	ELSEIF ATOT[ED_TECLA] == K_ESC
		EXIT
	ENDIF
ENDDO
PONEPAN(xmenu3)
SET(_SET_CURSOR,SC_ON)

RETURN


*************

FUNC DBFABRIR

*************
local cBaseAux:=alias(), nReg:=recno()

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
F_ABASE({"PRD","GR","FA","FA2","FB","FB2","RE","RE2","CL","ART","CLA","TI","TI2","RU","EM"},"CERRAR")
FBASES( { "PROD", "GRUPO", "FACA","FACA2", "FACB","FACB2", "REM","REM2", "CLIENTES", "ARTIC", "ARTIC2", "CLA", "TICKETS", "TICKETS2", "RUBRO","EMPLEADO","PADRONIB" }, .F. )
select PRD
*set filter to PRD->TIPO=" " .or. PRD->TIPO=cTIPO
select (cBaseAux)
go nReg
RECUPAN()

return
