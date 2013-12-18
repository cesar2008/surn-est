#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

parameters que
LOCAL xaux := GUARDOPAN(0,0,24,79), op := 2, aaux, facimpresa:=.F.
LOCAL nTotal, OX

PRIVATE AXR := {}, aCpo

RG_CODPROD    := 1
RG_CANTIDAD   := 2
RG_DESCPROD   := 3
RG_PRECBASE   := 4
RG_PRECUNIT   := 5
RG_IMPORTE    := 6
RG_PORCDESC   := 7
RG_DESCUENTO  := 8
RG_IMPINT     := 9
RG_IVA1       := 10
RG_IVA2       := 11
RG_TPRECBASE  := 12
RG_TDESCUENTO := 13
RG_TIMPINT    := 14
RG_TIVA1      := 15
RG_TIVA2      := 16
RG_RUBRO      := 17
RG_TIPOIMPINT := 18
RG_NEGOCIO    := 19
RG_REGISTRO   := 20

aCpo:={;
	{ "CODPROD",    "C¢digo;Prod.",                  '', 'F',  '',  0, 0 },;
	{ "CANTIDAD",   "Cant.; ",                       '', 'F',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                 '', 'F',  '',  0, 0 },;
	{ "PRECBASE",   "Precio;Base",                   '', 'E', 'N', 10, 4 },;
	{ "PRECUNIT",   "Precio;Unitario",               '', 'E',  '',  0, 0 },;
	{ "IMPORTE",    "Importe; ",                     '', 'F', 'N', 10, 3 },;
	{ "PORCDESC",   " % ;Descto",                    '', 'F',  '',  0, 0 },;
	{ "DESCUENTO",  "Descto; ",                      '', 'F',  '',  0, 0 },;
	{ "IMPINT",     "Imp.Int.",                      '', 'F',  '',  0, 0 },;
 	{ "IVA1",       "I.V.A.;"+STR(VA->PIVA1)+"%",     '', 'F',  '',  0, 0 },;
 	{ "IVA2",       "I.V.A.;"+STR(VA->PIVA2)+"%",     '', 'F',  '',  0, 0 },;
 	{ "TPRECBASE",  "Total;Pre.Base",                '', 'F',  '',  0, 0 },;
 	{ "TDESCUENTO", "Total;Descto",                  '', 'F',  '',  0, 0 },;
 	{ "TIMPINT",    "Total;Imp.Int",                 '', 'F',  '',  0, 0 },;
 	{ "TIVA1",      "Total IVA;"+STR(VA->PIVA1)+"%",  '', 'F',  '',  0, 0 },;
 	{ "TIVA2",      "Total IVA;"+STR(VA->PIVA2)+"%",  '', 'F',  '',  0, 0 },;
 	{ "RUBRO",      "Rubro",                         '', 'F',  '',  0, 0 },;
 	{ "TIPOIMPINT", "Tipo;Imp.Int",                  '', 'F', 'C',  1, 0 },;
 	{ "NEGOCIO",    "Negocio",                       '', 'F',  '',  0, 0 },;
 	{ "REGISTRO",   "",                              '', 'F',  '',  0, 0 } }

DBSELECTAREA("RE2")
aCpo := FARRAYAUX( aCpo )

@ 3,3 CLEAR TO 6,77
@ 4,5 SAY "Cliente: " + STR( M->CODCLI, 4)
@ 4,21 SAY FCLIENTE(M->CODCLI,.T.)
M->TPRECBASE := 0
M->TIMPINT   := 0
STORE 0 TO M->TDESCUENTO, M->SUBTOTAL, M->TIVA1, M->TIVA2, M->TOTAL, M->TPRECBASE, M->TIMPINT
M->PORCDESC := 0
NUEVO := .T.

aaux := SETVARSIVA( CL->CATIVA )
nNUMFAC   := 0
cTIPOFAC  := aaux[EST_TIPO]
cCATIVA   := CL->CATIVA
M->PIVA1     := aaux[EST_IVA1]
M->PIVA2     := aaux[EST_IVA2]
M->RAZONSOC := CL->RAZONSOC
M->DOMCOM   := CL->DOMCOM
M->CODLOC   := CL->CODLOC
M->CATIVA   := CL->CATIVA
M->CUIT     := CL->CUIT

IF VAL(SUBSTR(CCV->BORRADOR,2)) # 0
	nNUMFAC := VAL(SUBSTR(CCV->BORRADOR,2))
	IF cTIPOFAC # LEFT(CCV->BORRADOR,1)
  	NUEVO := .T.
  ELSE
		DBSELECTAR( XF )
		NUEVO := !DBSEEK( nNUMFAC )
  ENDIF
ENDIF
IF NUEVO .OR. nNUMFAC == 0
	DBSELECTAR( XF )
	DBGOBOTTOM()
	nNUMFAC := ULTIMO(XF, "FIELD->NUMFAC", 1 ) + 1
ELSEIF que == NIL
	op = MENUFLASH( 10, 30, 1, .T., "", "VER LA FACTURA YA GRABADA", "HACER DE NUEVO LA FACTURA", "HACER OTRA FACTURA" )
ELSE
	op := 1
ENDIF

@ 3, 50 SAY "Tipo Factura: (" + cTIPOFAC +")"
@ 4, 50 SAY "N§ Factura: " + STRZERO( nNUMFAC, 8 )

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
aaux := {}
IF op == 1
	DBSELECTAR( XF )
  SET ORDER TO 1
	SEEK nNUMFAC
	DBSELECTAR( XF2 )
	SEEK nNUMFAC
	DO WHILE FIELD->NUMFAC == nNUMFAC .AND. !EOF()
     FPRODUCTO(FIELD->CODPROD)
		AADD( AXR, ARRAY( RG_REGISTRO ) )
		i := LEN(AXR)
		AXR[ i,RG_CODPROD  ] := FIELD->CODPROD
		AXR[ i,RG_DESCPROD ] := FIELD->DESCPROD
		AXR[ i,RG_CANTIDAD ] := FIELD->CANTIDAD
		AXR[ i,RG_TPRECBASE] := FIELD->TPRECBASE
		AXR[ i,RG_TIMPINT  ] := FIELD->TIMPINT
		AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
		AXR[ i,RG_TDESCUENTO]:= FIELD->TDESCUENTO
		AXR[ i,RG_TIMPINT  ] := FIELD->TIMPINT
		AXR[ i,RG_TIVA1    ] := FIELD->TIVA1
		AXR[ i,RG_TIVA2    ] := FIELD->TIVA2
		AXR[ i,RG_PRECBASE ] := AXR[i,RG_TPRECBASE] / AXR[i,RG_CANTIDAD]
		AXR[ i,RG_IMPINT   ] := AXR[i,RG_TIMPINT] / AXR[i,RG_CANTIDAD]
		AXR[ i,RG_IVA1      ] := AXR[i,RG_PRECBASE] * M->PIVA1 / 100
		AXR[ i,RG_IMPORTE  ] := (AXR[i,RG_PRECBASE]+AXR[i,RG_IMPINT]+AXR[i,RG_IVA1]) * AXR[i,RG_CANTIDAD]
		AXR[ i,RG_IMPORTE  ] := FIELD->IMPORTE
     ********************************
		AXR[ i,RG_RUBRO      ] := NRUBRO
		AXR[ i,RG_DESCUENTO  ] := AXR[i,RG_PRECBASE] * FIELD->PORCDESC / 100
		AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
		AXR[ i,RG_IVA1       ] := AXR[i,RG_PRECBASE] * M->PIVA1 / 100
		AXR[ i,RG_IVA2       ] := AXR[i,RG_PRECBASE] * M->PIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[i,RG_RUBRO]==1,0,1)
		AXR[ i,RG_PORCDESC   ] := FIELD->PORCDESC
		AXR[ i,RG_PRECUNIT   ] := FIELD->PRECUNIT
		AXR[ i,RG_NEGOCIO    ] := FIELD->NEGOCIO
     *********************************
		AXR[i,RG_REGISTRO  ] := RECNO()
		SKIP
	ENDDO
  facimpresa := (XF)->IMPRESO
ELSEIF op == 2
	aaux := SETVARSIVA( CL->CATIVA )
  IF op == 3
		nNUMFAC := ULTIMO(XF, "FIELD->NUMFAC", 1 ) + 1
  ENDIF
	cTIPOFAC  := aaux[EST_TIPO]
	M->PIVA1   := aaux[EST_IVA1]
	M->PIVA2   := aaux[EST_IVA2]
	aaux := {}
#ifdef POWEROIL
	DBSELECTAREA("RE")
	SET ORDER TO FORDER({"CODCLI","ID_CCV"})
	SEEK str(CL->CODCLI)+CCV->ID_CCV
	DBSELECTAREA("RE2")
	DO WHILE RE->CODCLI==CL->CODCLI .and. RE->ID_CCV==CCV->ID_CCV
  	nTotal := 0
		SEEK RE->NUMFAC
		DO WHILE RE2->NUMFAC == RE->NUMFAC
     	cAux:=FPRODUCTO(FIELD->CODPROD,RE2->NEGOCIO)
			i := ASCAN( AXR, {|a| a[RG_CODPROD]==RE2->CODPROD .and.a[RG_NEGOCIO]==RE2->NEGOCIO } )
			IF i == 0
				AADD( AXR, AREG0(aCpo) )
				i := LEN(AXR)
				AXR[ i,RG_CODPROD  ] := RE2->CODPROD
				AXR[ i,RG_DESCPROD ] := cAux
				AXR[ i,RG_NEGOCIO  ] := RE2->NEGOCIO
			ENDIF
			AXR[ i,RG_CANTIDAD ] += RE2->CANTIDAD
			AXR[ i,RG_PRECUNIT ] := RE2->PRECUNIT
			AXR[ i,RG_TPRECBASE] += RE2->TPRECBASE
			AXR[ i,RG_TIMPINT  ] += RE2->TIMPINT
			AXR[ i,RG_TIVA1    ] += RE2->TIVA1
			AXR[ i,RG_TIVA2    ] += RE2->TIVA2
 			AXR[ i,RG_TDESCUENTO]+= RE2->TDESCUENTO
        nTotal += RE2->IMPORTE
				AXR[ i,RG_PRECBASE ] := ( FIELD->TPRECBASE / FIELD->CANTIDAD )
				AXR[ i,RG_IMPINT   ] := FIELD->TIMPINT / FIELD->CANTIDAD
				AXR[ i,RG_IVA1     ] := AXR[i,RG_TPRECBASE] * M->PIVA1 / 100
				AXR[ i,RG_IMPORTE  ] := AXR[i,RG_TPRECBASE]+AXR[i,RG_TIMPINT]+AXR[i,RG_TIVA1]
			AXR[i,RG_REGISTRO  ] := 0
			SKIP
		ENDDO
     IF ROUND(RE->TOTAL,0) # ROUND(nTotal,0)
     	AADD( aaux, STR(RE->NUMFAC) +"³"+ DTOC(RE->FECHA) +"³"+ STR(RE->TOTAL)+"³"+STR(nTotal,10,2) )
     ENDIF
		SKIP 1 ALIAS RE
	ENDDO
#else
	SELECT GR
	nCodServ := GR->(LASTREC())+1
	DBSELECTAREA("RE")
	SET ORDER TO FORDER({"CODCLI","ID_CCV"})
	SEEK str(CL->CODCLI)+CCV->ID_CCV
	DBSELECTAREA("RE2")
	DO WHILE RE->CODCLI==CL->CODCLI .and. RE->ID_CCV==CCV->ID_CCV
  	nTotal := 0
		SEEK RE->NUMFAC
		DO WHILE RE2->NUMFAC == RE->NUMFAC
     	IF RE2->NEGOCIO == "*"
     		FPRODUCTO(FIELD->CODPROD,"*")
           NGRUPO := nCodServ
				i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO } )
				IF i == 0
					AADD( AXR, AREG0(aCpo) )
					i := LEN(AXR)
					AXR[ i,RG_CODPROD  ] := NGRUPO
					AXR[ i,RG_DESCPROD ] := JUSTIF("ART.SERVICOMPRAS",FLEN(GR->DESCGRUP),"<")
				ENDIF
				AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
				AXR[ i,RG_CANTIDAD ] += FIELD->CANTIDAD
				AXR[ i,RG_TPRECBASE] += FIELD->TPRECBASE
				AXR[ i,RG_TIMPINT  ] += FIELD->TIMPINT
				AXR[ i,RG_TIVA1    ] += FIELD->TIVA1
				AXR[ i,RG_TIVA2    ] += FIELD->TIVA2
 				AXR[ i,RG_TDESCUENTO]+= FIELD->TDESCUENTO
        ELSE
     		FPRODUCTO(FIELD->CODPROD)
				i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO } )
				IF i == 0
					AADD( AXR, AREG0(aCpo) )
					i := LEN(AXR)
					AXR[ i,RG_CODPROD  ] := NGRUPO
					AXR[ i,RG_DESCPROD ] := FGRUPO(NGRUPO)
					AXR[ i,RG_DESCPROD ] := IF( EMPTY(AXR[i,RG_DESCPROD]), "VARIOS    ", AXR[i,RG_DESCPROD] )
				ENDIF
				AXR[ i,RG_CANTIDAD ] += FIELD->CANTIDAD
				AXR[ i,RG_NEGOCIO  ] += FIELD->NEGOCIO
           IF CL->VALORIZADO == 'S'
					AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
					AXR[ i,RG_TPRECBASE] += FIELD->TPRECBASE
					AXR[ i,RG_TIMPINT  ] += FIELD->TIMPINT
					AXR[ i,RG_TIVA1    ] += FIELD->TIVA1
					AXR[ i,RG_TIVA2    ] += FIELD->TIVA2
 					AXR[ i,RG_TDESCUENTO]+= FIELD->TDESCUENTO
           ELSE
 					AXR[ i, RG_RUBRO      ] := NRUBRO
 					AXR[ i, RG_PRECBASE   ] := FPRECBASE
 					AXR[ i, RG_TIPOIMPINT ] := FTIPOIMPINT
 					AXR[ i, RG_IMPINT     ] := FIMPINT
 					AXR[ i, RG_PRECUNIT   ] := FPRECVENTA
              FCALCPRECIO(AXR,i)
           ENDIF
        ENDIF
        IF CL->VALORIZADO == 'S'
				AXR[ i,RG_PRECBASE ] := ( FIELD->TPRECBASE / FIELD->CANTIDAD )
				AXR[ i,RG_IMPINT   ] := FIELD->TIMPINT / FIELD->CANTIDAD
				AXR[ i,RG_IVA1      ] := AXR[i,RG_TPRECBASE] * M->PIVA1 / 100
				AXR[ i,RG_IMPORTE  ] := AXR[i,RG_TPRECBASE]+AXR[i,RG_TIMPINT]+AXR[i,RG_TIVA1]
			ENDIF
        nTotal += RE2->IMPORTE
			AXR[i,RG_REGISTRO  ] := 0
			SKIP
		ENDDO
     IF ROUND(RE->TOTAL,0) # ROUND(nTotal,0)
     	AADD( aaux, STR(RE->NUMFAC) +"³"+ DTOC(RE->FECHA) +"³"+ STR(RE->TOTAL)+"³"+STR(nTotal,10,2) )
     ENDIF
		SKIP 1 ALIAS RE
	ENDDO
#endif
  IF nNUMFAC # 0
  	i := 0
		DBSELECTAR( XF2 )
		SEEK nNUMFAC
		DO WHILE FIELD->NUMFAC == nNUMFAC .AND. !EOF()
  		IF ++i > LEN(AXR)
				AADD( AXR, AREG0(aCpo) )
				i := LEN(AXR)
     	ENDIF
			AXR[i,RG_REGISTRO  ] := RECNO()
			SKIP
		ENDDO
  ENDIF
ENDIF
RECUPAN()
IF LEN(aaux) # 0
	PP_SELEC( 7, 30, 0, 0, aaux, 1, "REVISAR ESTOS REMITOS", "S", .T.)
  RECUPAN()
ENDIF

IF LEN(AXR) # 0
	IF op == 1
  	M->TPRECBASE := (XF)->TPRECBASE
     M->TIMPINT   := (XF)->TIMPINT
  ELSE
		AEVAL( AXR, {|a| M->TPRECBASE+=a[RG_TPRECBASE], M->TIMPINT+=a[RG_TIMPINT] } )
  ENDIF
	FTOTALIZAR()

  IF que # NIL
  	RETURN AXR
  ENDIF
	MODIFICABLE := .T.
	
	SETCOLOR( "W/N,N/W" )
	OX := MYABROWSE( 8, 1, 17, 78, aCpo, AXR, "AXR" )
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	IF MODIFICABLE
		OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
	ELSE
		OX:CARGO[TB_EDIT] := LOWER( OX:CARGO[TB_EDIT] )
	ENDIF
	
	MENUDOWN({"  <+>  º    F2    º    F3    º  %   º    TAB   º   F8   º   F10   º ESC  ",;
				 "       º          º  busca   º      º  elegir  º cambia º graba y º      ",;
				 " mueve º modifica º producto º desc º producto º n§Fact º  sale   º sale "})
	ATOT := NEWEDIT( "TOT",,.F. )
	FVERREG( ATOT,, .T. )
	
	guardar = .F.
	DO WHILE .T.
		
		MOVABROW( OX, AXR, {||nK==9.OR.nK==37.OR.nK==27.OR.nK==K_F7.OR.nK==-2.OR.nK==-9.OR.nk==-5.OR.nK==K_F8},;
			{||nK==999} )
		
		IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB .OR. OX:Cargo[TB_RET] == K_F3 ) .AND. MODIFICABLE
			IF TBNOC(OX) $ "CODPROD CANTIDAD IMPORTE"
				IF OX:CARGO[TB_MSGE] == "MODIF"
					AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
				ENDIF
				IF TBNOC(OX) == "CODPROD"
					IF OX:Cargo[TB_RET] == K_TAB
						IF FELEGIR( "PRODUCTO", AXR[NROW,RG_CODPROD] ) # 0
							AXR[NROW,RG_CODPROD] := PRD->CODPROD
						ENDIF
					ELSEIF OX:Cargo[TB_RET] == K_F3
						r := SELECTPRD()
						IF r # 0
							AXR[NROW,RG_CODPROD] := r
						ENDIF
					ENDIF
					AXR[NROW,RG_DESCPROD] := FPRODUCTO(AXR[NROW,RG_CODPROD])
					AXR[NROW,RG_PRECBASE] := FPRECBASE
					AXR[NROW,RG_IMPINT  ] := FIMPINT
					AXR[NROW,RG_IVA1    ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 /100
					AXR[NROW,RG_PRECUNIT] := AXR[NROW,RG_PRECBASE] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA1]

 					AXR[NROW,RG_TPRECBASE] := AXR[NROW,RG_PRECBASE] * AXR[NROW,RG_CANTIDAD]
 					AXR[NROW,RG_TIMPINT  ] := AXR[NROW,RG_IMPINT] * AXR[NROW,RG_CANTIDAD]
 					AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
				ENDIF
				FTOTALIZAR()
			ELSEIF OX:CARGO[TB_MSGE] == "MODIF" .AND. CL->VALORIZADO#'S'
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
           lAux := .F.
				IF TBNOC(OX) $ "PRECBASE"
					AXR[NROW,RG_IVA1     ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 /100
					AXR[NROW,RG_PRECUNIT ] := AXR[NROW,RG_PRECBASE] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA1]
           	lAux := .T.
				ELSEIF TBNOC(OX) $ "PRECUNIT"
					AXR[NROW,RG_PRECBASE ] := ( AXR[NROW,RG_PRECUNIT] - AXR[NROW,RG_IMPINT] ) / (1+((VA->PIVA1)/100))
					AXR[NROW,RG_IVA1     ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 /100
           	lAux := .T.
           ENDIF
           if lAux
 					AXR[NROW,RG_TPRECBASE] := AXR[NROW,RG_PRECBASE] * AXR[NROW,RG_CANTIDAD]
 					AXR[NROW,RG_TIMPINT  ] := AXR[NROW,RG_IMPINT] * AXR[NROW,RG_CANTIDAD]
 					AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
					AXR[NROW,RG_TIVA1    ] := AXR[NROW,RG_IVA1] * AXR[NROW,RG_CANTIDAD]
					AXR[NROW,RG_TIVA2    ] := AXR[NROW,RG_IVA2] * AXR[NROW,RG_CANTIDAD]
*    			FCALCPRECIO( AXR, NROW )
              ***********************
					AXR[ NROW, RG_IMPORTE    ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
              ***********************
					FTOTALIZAR()
           endif
			ENDIF
			FVERREG( ATOT,, .T. )
			OX:RefreshCurrent()
			
		ELSEIF OX:Cargo[TB_RET] == 37 .AND.MODIFICABLE				&&  %
			ATOT[ED_REGISTRO] := 0
			ATOT[ED_I] = 1
			DO WHILE .T.
				ATOT[ED_MODE] = "MOSTRAR"
				FEDITAR( ATOT, {K_F10} )
				IF ATOT[ED_TECLA] == K_ENTER .OR. ATOT[ED_TECLA] == K_F10
					IF ATOT[ED_UPDATE]
						FEDITOR( ATOT, "GRABAR", .F. )
						M->TOTAL       := M->TPRECBASE + M->TIMPINT + M->TIVA1 + M->TIVA2
*						FTOTALIZAR()
					ENDIF
					EXIT
				ELSEIF ATOT[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			FVERREG( ATOT,, .T. )
		ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
			IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
				AADD( AXR, AREG0(aCpo) )
			ENDIF
			
		ELSEIF oX:Cargo[TB_RET] == K_F7
 			LISTADOR( "FAC" + cTIPOFAC )
        facimpresa := .T.
			
			
		ELSEIF OX:Cargo[TB_RET] == K_F8
			DO WHILE .T.
        	SET(_SET_CURSOR,SC_ON)
				@ 4, 50 SAY "N§ Factura:" GET nNUMFAC PICT "99999999"
				READ
				DBSELECTAR( XF )
				IF cTIPOFAC+STRZERO(nNUMFAC,8) # CCV->BORRADOR
					SEEK nNUMFAC
					IF FOUND()
						MENSAJE( 0, 0, 10, .T., "N§ DE FACTURA REPETIDA !!!" )
					ELSE
						EXIT
					ENDIF
				ELSE
					EXIT
				ENDIF
			ENDDO
			@ 3, 50 SAY "Tipo Factura: (" + cTIPOFAC +")"
			@ 4, 50 SAY "N§ Factura: " + STRZERO( nNUMFAC, 8 )
			
		ELSEIF OX:Cargo[TB_RET] == K_ESC
			IF MODIFICABLE
				aux := UPPER( PREGUNTA( 12, "[ G ] graba.       [ S ] sale.       [ C ] contin£a.", "GgSsCc") )
				IF aux $ "GS"
					guardar := ( aux == "G" )
					EXIT
				ENDIF
			ELSE
				EXIT
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F10
			IF MODIFICABLE
				guardar := .T.
			ENDIF
			EXIT
		ENDIF
	ENDDO
	
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
	IF guardar
		FFLOCK( XF )
		FFLOCK( XF2 )
		DBSELECTAR( XF )                  &&.facturas.dbf
*		IF !DBSEEK( val(CCV->BORRADOR,2) )
		IF !DBSEEK( nNUMFAC )
			F_ALTA({||FIELD->NUMFAC#0})
		ENDIF
		(XF)->NUMFAC    := nNUMFAC
		(XF)->FECHA     := CCV->FECHCIERRE
		(XF)->CODCLI    := M->CODCLI
		(XF)->RAZONSOC  := CL->RAZONSOC
		(XF)->DOMCOM    := CL->DOMCOM
		(XF)->CODLOC    := CL->CODLOC
		(XF)->CATIVA    := CL->CATIVA
		(XF)->CUIT      := CL->CUIT
		(XF)->FECHVENC  := CCV->FECHCIERRE
		(XF)->TIPOVENTA := 2
		(XF)->TPRECBASE := M->TPRECBASE
		(XF)->PORCDESC  := M->PORCDESC
		(XF)->TIMPINT   := M->TIMPINT
		(XF)->TIVA1     := M->TIVA1
		(XF)->TIVA2     := M->TIVA2
		(XF)->TOTAL     := M->TOTAL
  	(XF)->FECHCIERRE:= CCV->FECHCIERRE
     (XF)->ID_CCV    := CCV->ID_CCV
  	(XF)->IMPRESO   := facimpresa
		DBSELECTAR( XF2 )
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
					SEEK 0
					IF !FOUND() .OR. LASTREC()==0
						ADD_REC()
					ENDIF
				ENDIF
				(XF2)->NUMFAC    := nNUMFAC
				(XF2)->CODPROD   := AXR[i,RG_CODPROD]
				(XF2)->CANTIDAD  := AXR[i,RG_CANTIDAD]
				(XF2)->DESCPROD  := AXR[i,RG_DESCPROD]
				(XF2)->TPRECBASE := AXR[i,RG_TPRECBASE]
           (XF2)->TDESCUENTO:= AXR[i,RG_TDESCUENTO]
				(XF2)->TIMPINT   := AXR[i,RG_TIMPINT]
				(XF2)->TIVA1     := AXR[i,RG_TIVA1]
				(XF2)->TIVA2     := AXR[i,RG_TIVA2]
				(XF2)->PRECUNIT  := AXR[i,RG_PRECUNIT]
				(XF2)->IMPORTE   := AXR[i,RG_IMPORTE]
			ENDIF
		NEXT
		FRLOCK("CCV")
		CCV->BORRADOR := cTIPOFAC + STRZERO(nNUMFAC,8)
		
		DBUNLOCKALL()
		DBCOMMITALL()
	ENDIF
	RECUPAN()
ENDIF
SELECT CCV

PONEPAN(xaux)

RETURN .T.


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
M->PORCDESC    := M->TDESCUENTO * 100 / IF(M->TPRECBASE==0,1,M->TPRECBASE)
M->TOTAL       := M->TPRECBASE + M->TIMPINT + M->TIVA1 + M->TIVA2

RETURN M->TOTAL
