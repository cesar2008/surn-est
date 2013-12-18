PRIVATE APLA, APLA2, ATOT, aCPO

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

LOGO(.T., " PLANILLAS ")
MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
FBASES({ "PLAN", "PLAN2", "CAJA", "EMPLEADO", "PLANT" }, .F.)

RG_CODPROD   :=  1
RG_SURTIDOR  :=  2
RG_DESCPROD  :=  3
RG_INGRESO   :=  4
RG_TOTAL     :=  5
RG_CERRO     :=  6
RG_CANTIDAD  :=  7
RG_IMPORTE   :=  8
RG_DESCUENTO :=  9
RG_ABRIO     :=  10
RG_PRECBASE  :=  11
RG_IMPINT    :=  12
RG_IVA       :=  13
RG_PRECUNIT  :=  14
RG_TPRECBASE :=  15
RG_TIMPINT   :=  16
RG_TIVA      :=  17
RG_TURNO     :=  18
RG_REGISTRO  :=  19

aCpo:={	                                                                      ;
	{ "CODPROD",    "Prod",                               '', 'M',  '',  0, 0 },;
	{ "SURTIDOR",   "Su",                                 '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n",         REPLICATE("X",11), 'E',  '',  0, 0 },;
	{ "INGRESO",    "Ingreso",                            '', 'E',  '',  0, 0 },;
	{ "TOTAL",      "Abri¢+Ingr.",                        '', 'E',  '',  0, 0 },;
	{ "CERRO",      "Cerr¢",                              '', 'M',  '',  0, 0 },;
	{ "CANTIDAD",   "Cant.",                              '', 'M',  '',  0, 0 },;
	{ "IMPORTE",    "Importe",                            '', 'F', 'N', 10, 3 },;
	{ "DESCUENTO",  "Descuento",                          '', 'E', 'N',  0, 0 },;
	{ "ABRIO",      "Abri¢",                              '', 'E',  '',  0, 0 },;
	{ "PRECBASE",   "",                                   '',  '',  '',  0, 0 },;
	{ "IMPINT",     "",                                   '',  '',  '',  0, 0 },;
	{ "IVA",        "",                                   '',  '',  '',  0, 0 },;
	{ "PRECUNIT",   "",                                   '',  '',  '',  0, 0 },;
	{ "TPRECBASE",  "",                                   '',  '', 'N', 10, 5 },;
	{ "TIMPINT",    "",                                   '',  '', 'N', 10, 5 },;
	{ "TIVA",       "",                                   '',  '', 'N', 10, 5 },;
	{ "TURNO",      "",                                   '',  '', 'C',  1, 0 },;
	{ "REGISTRO",   "",                                   '',  '', 'N',  0, 0 } }

SELECT PL2
aCpo := FARRAYAUX( aCpo )
SELECT PL
DBGOBOTTOM()

SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

MODIFICABLE = .F.
NUEVO = .F.
APLA      := NEWEDIT( "PLA1",,.T. )
AX_FECHA  := ASCAN( APLA[ED_FIELDS], "PL->FECHA" )
AX_TURNO  := ASCAN( APLA[ED_FIELDS], "PL->TURNO" )
auxaux    := APLA[ED_EDIT]
APLA2     := NEWEDIT( "PLA2",.F.,.T. )
RECUPAN()

DO WHILE .T.
	F10 := .F.
	
	RELLENAPAN( 9, 0, 21, 80, "°", C_FONDO )
	SELECT PL
	MENUDOWN({"    TAB    º    F2    º   F5   º  Alt F6  º   F10   º  ENTER   º ESC  ",;
				 " lista de  º          º        º elimina  º resumen º          º      ",;
				 " planillas º modifica º agrega º planilla º del d¡a º confirma º sale "})
	NUEVO = .F.
	salir = .F.
	APLA[ED_EDIT] := auxaux
	DO WHILE !salir
		k := FVERREG( APLA, {|K|K==9.OR.K==-4.OR.K==K_ALT_F6.OR.K==13.OR.K==-1.OR.K==-9} )
		IF K == K_ENTER
			MODIFICABLE = .F.
			NUEVO = .F.
			salir = .T.
			FEDITOR( APLA, "LEER" )

		ELSEIF (K==K_F2.AND.FIELD->FECHA>VA->FECHSEG) .OR. k == K_F5
			xmenu:=MENUDOWN({"  <+>  º   TAB    º   F10    º  ESC   ",;
								  "       º tablas de º graba y  º        ",;
								  " mueve º   ayuda   º contin£a º  sale  "})
			MODIFICABLE = .T.
			NUEVO := .F.
			FEDITOR(APLA,"SETVARS",K,.F.)
			APLA[ED_I] := 1
			APLA[ED_REGISTRO] := 0
			IF K == K_F5
				DBGOBOTTOM()
				APLA[ED_CONT,AX_FECHA]   := VA->FECHA
				APLA[ED_CONT,AX_TURNO]    := ' '
				NUEVO := .T.
			ENDIF
			APLA[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( APLA, { 9, K_F10 } )
				IF APLA[ED_UPDATE] .OR. APLA[ED_TECLA] == K_TAB
					APLA[ED_MODE] = "MOSTRARTODO"
					IF EDNOM(APLA) == "PL->TURNO" .AND. APLA[ED_TECLA] == K_TAB
						ele = PP_SELEC( APLA[ED_Y], APLA[ED_X], 0, 0, aturno, EDCONT(APLA), "", "S", .T., .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(APLA,,LEFT(aturno[ele],1))
						ENDIF
						RECUPAN()
					ENDIF
				ELSEIF ( APLA[ED_TECLA] == K_ENTER .AND. APLA[ED_I] == LEN(APLA[ED_EDIT]) ) .OR. APLA[ED_TECLA] == K_F10
*					FEDITOR( APLA, "LEER" )
					IF EMPTY(APLA[ED_CONT,AX_FECHA])
						MENSAJE( 0, 0, 10, .T., " FALTA FECHA !!!" )
					ELSEIF ASCAN( aturno, {|x| LEFT(x,1)==APLA[ED_CONT,AX_TURNO] } ) == 0
						MENSAJE( 0, 0, 10, .T., " FALTA TURNO !!!" )
					ELSE
						salir := .T.
						EXIT
					ENDIF
				ELSEIF APLA[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			PONEPAN(xmenu)
		ELSEIF k == K_TAB
			PRIVATE bcamp[3], bmasc[3], bcab[3], bedit
			bcamp[ 1] = "PL->FECHA"
			bcamp[ 2] = "PL->TURNO"
			bcamp[ 3] = "PL->TOTAL"
			bmasc[ 1] = ""
			bmasc[ 2] = "!!!!!!!!!!"
			bmasc[ 3] = "######.###"
			bcab[ 1] = "Fecha"
			bcab[ 2] = "Tipo"
			bcab[ 3] = "Total"
			bedit = "FFF"
			xmenu:=MENUDOWN({"  <+>  º  F3   º   F4   º  ENTER  º  ESC   ",;
								  "       º       º        º elige y º        ",;
								  " mueve º busca º busca+ º  sale   º  sale  "})
			SELECT PL
			_lastreg = RECNO()
			BROW( 8, 15, 18, 75, "PLANILLAS", bcamp, bmasc, bcab, bedit )
			IF LASTKEY() # K_ENTER
				GO _lastreg
			ENDIF
			RECUPAN()
			PONEPAN(xmenu)
		ELSEIF K == K_F7
			I_TITULO = IF( F10, "DIARIA", SUBSTR(FARRAY(aturno,APLA[ED_CONT,AX_TURNO]+'-'),3) )
			LISTADOR( "PLAN" )
		ELSEIF K == K_F10
			FEDITOR( APLA, "LEER" )
			F10 := .T.
			salir:= .T.
		ELSEIF K == K_ALT_F6
			IF PREGUNTA( 10, "¨ ESTAS SEGURO DE ELIMINAR  [ S / N ] ?","SsNn") $ "Ss"
				MENSAJE( 0, 0, 0, .F., " ELIMINANDO ..." )
				FEDITOR( APLA, "LEER" )
        	SELECT PL2
           SET ORDER TO 1
           SEEK FTOC(PL->FECHA)+PL->TURNO
           DO WHILE FOUND()
           	BLANKREG()
           	SEEK FTOC(PL->FECHA)+PL->TURNO
           ENDDO
           SELECT PL
          	BLANKREG()
           DBSEEK( FTOC(APLA[ED_CONT,AX_FECHA])+APLA[ED_CONT,AX_TURNO], .T. )
           RECUPAN()
        ENDIF
		ELSEIF K == K_ESC
			F10 := .F.
			salir:= .T.
		ENDIF
	ENDDO
	IF K == K_ESC
		EXIT
	ELSEIF K == K_ENTER
		FEDITOR( APLA2, "PONEPAN" )
		FVERREG( APLA2,, .T. )
	ELSEIF K == K_F5 .OR. K == K_F2
		MENUDOWN({"  <+>  º   TAB    º   F10    º  ESC   ",;
					 "       º tablas de º graba y  º        ",;
					 " mueve º   ayuda   º contin£a º  sale  "})
		FEDITOR( APLA2, "PONEPAN" )
		APLA2[ED_EDIT] := UPPER(APLA2[ED_EDIT])
		FEDITOR( APLA2, "SETVARS", K, .F. )
		APLA2[ED_I] := 1
		APLA2[ED_REGISTRO] := 0
		APLA2[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( APLA2, { 9, K_F10 } )
			IF APLA2[ED_UPDATE] .OR. APLA2[ED_TECLA] == K_TAB
				APLA2[ED_MODE] = "MOSTRARTODO"
				IF "CODEMP" $ EDNOM(APLA2) .AND. APLA2[ED_TECLA] == K_TAB
*					IF FELEGIR("EMPLEADO", EDCONT(APLA2)) # 0
					IF EMP( EDCONT(APLA2), .T.)
						EDPONE(APLA2,, EM->CODEMP)
					ENDIF
				ENDIF
			ELSEIF ( APLA2[ED_TECLA] == K_ENTER .AND. APLA2[ED_I] == LEN(APLA2[ED_EDIT]) ) .OR. APLA2[ED_TECLA] == K_F10
				EXIT
			ELSEIF APLA2[ED_TECLA] == K_ESC
				EXIT
			ENDIF
		ENDDO
		IF APLA2[ED_TECLA] == K_ESC
			FEDITOR( APLA2, "SACAPAN" )
			LOOP
		ENDIF
	ENDIF
	
	
	************************
	* Carga de la planilla *
	************************
	MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
	M->PIVA1 := ( VA->PIVA1 * .0001 / .0001 )
	M->PIVA2 := 0
	PRIVATE AXR := {}
	STORE 0 TO M->TIVA1, M->TIVA2, M->TOTAL, M->TPRECBASE, M->TIMPINT, M->PORCDESC, M->DESCUENTO
	IF F10
		NUEVO = .F.
		MODIFICABLE = .F.
		FVERREG( APLA,, .T. )
		SELECT PL2
		SET ORDER TO FORDER({"FECHA","TURNO"})
		DBSEEK( FTOC(APLA[ED_CONT,AX_FECHA]), .T. )
		DO WHILE PL2->FECHA==APLA[ED_CONT,AX_FECHA]
			i = ASCAN( AXR, {|a| a[RG_CODPROD]==PL2->CODPROD.AND.a[RG_SURTIDOR]==PL2->SURTIDOR } )
			IF i == 0
				AADD( AXR, AREG0( aCpo ) )
				i := LEN(AXR)
				AXR[ i, RG_CODPROD   ] := FIELD->CODPROD
				AXR[ i, RG_SURTIDOR  ] := FIELD->SURTIDOR
				AXR[ i, RG_ABRIO     ] := FIELD->ABRIO
				AXR[ i, RG_TOTAL     ] := FIELD->ABRIO
				AXR[ i, RG_TURNO     ] := FIELD->TURNO
			ENDIF
			AXR[ i,RG_DESCPROD  ] := FIELD->DESCPROD
				*** si es combustible me quedo con el mayor CIERRE
       	IF PL2->TURNO $ UT_TURCONARR
*				IF VXS( AXR[i,RG_CODPROD] )
*					AXR[ i,RG_CERRO    ] := IF( FIELD->CERRO > AXR[i,RG_CERRO], FIELD->CERRO, AXR[i,RG_CERRO] )
*				ELSE
					AXR[ i,RG_CERRO    ] := FIELD->CERRO
*				ENDIF
				AXR[ i,RG_INGRESO  ] += FIELD->INGRESO
			ENDIF
			AXR[ i,RG_CANTIDAD ] += FIELD->CANTIDAD
			AXR[ i,RG_PRECBASE ] := FIELD->PRECBASE
			AXR[ i,RG_IMPINT   ] := FIELD->IMPINT
			AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
			AXR[ i,RG_TPRECBASE] += FIELD->PRECBASE * FIELD->CANTIDAD
			AXR[ i,RG_DESCUENTO] += FIELD->DESCUENTO
			AXR[ i,RG_TIMPINT  ] += FIELD->IMPINT * FIELD->CANTIDAD
			AXR[ i,RG_IVA      ] := FIELD->PRECBASE * VA->PIVA1 / 100
*			AXR[ i,RG_IMPORTE  ] := (AXR[i,RG_PRECBASE]+AXR[i,RG_IMPINT]+AXR[i,RG_IVA]) * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_IMPORTE  ] += FIELD->IMPORTE
			AXR[i,RG_REGISTRO  ] := RECNO()
			SKIP 1 ALIAS PL2
		ENDDO
		AEVAL( AXR, {|a| M->TPRECBASE += a[RG_TPRECBASE], M->TIMPINT += a[RG_TIMPINT], M->DESCUENTO += a[RG_DESCUENTO]} )
	ELSE
		SET SOFTSEEK OFF
		SELECT PL
		SEEK FTOC(APLA[ED_CONT,AX_FECHA])+APLA[ED_CONT,AX_TURNO]
		IF FOUND()
			NUEVO = .F.
			SELECT PL2
			SEEK FTOC(APLA[ED_CONT,AX_FECHA]) + APLA[ED_CONT,AX_TURNO]
			DO WHILE PL2->FECHA==APLA[ED_CONT,AX_FECHA] .AND. PL2->TURNO==APLA[ED_CONT,AX_TURNO]
				AADD( AXR, ARRAY( RG_REGISTRO ) )
				i := LEN(AXR)
				AXR[ i,RG_CODPROD  ] := FIELD->CODPROD
				AXR[ i,RG_SURTIDOR ] := FIELD->SURTIDOR
				AXR[ i,RG_DESCPROD ] := FIELD->DESCPROD
				AXR[ i,RG_ABRIO    ] := FIELD->ABRIO
				AXR[ i,RG_INGRESO  ] := FIELD->INGRESO
				AXR[ i,RG_TOTAL    ] := FIELD->TOTAL
				AXR[ i,RG_CERRO    ] := FIELD->CERRO
				AXR[ i,RG_CANTIDAD ] := FIELD->CANTIDAD
				AXR[ i,RG_PRECBASE ] := FIELD->PRECBASE
				AXR[ i,RG_IMPINT   ] := FIELD->IMPINT
				AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
				AXR[ i,RG_TPRECBASE] := AXR[i,RG_PRECBASE] * AXR[i,RG_CANTIDAD]
				AXR[ i,RG_DESCUENTO] := FIELD->DESCUENTO
				AXR[ i,RG_TIMPINT  ] := AXR[i,RG_IMPINT] * AXR[i,RG_CANTIDAD]
				AXR[ i,RG_IVA      ] := AXR[i,RG_PRECBASE] * M->PIVA1 / 100
*				AXR[ i,RG_IMPORTE  ] := (AXR[i,RG_PRECBASE]+AXR[i,RG_IMPINT]+AXR[i,RG_IVA]) * AXR[i,RG_CANTIDAD]
				AXR[ i,RG_IMPORTE  ] := FIELD->IMPORTE
				AXR[i,RG_REGISTRO  ] := RECNO()
				M->TPRECBASE += AXR[i,RG_TPRECBASE]
				M->TIMPINT   += AXR[i,RG_TIMPINT]
				SKIP
			ENDDO
		ELSE
			NUEVO = .T.
		ENDIF
	ENDIF
	NROW := 1
	IF MODIFICABLE .OR. LEN(AXR) == 0
		AADD( AXR, AREG0( aCpo ) )
	ENDIF
	FTOTALIZAR()
	
	RECUPAN()
	
	
	SETCOLOR( "W/N,N/W" )
	OX := MYABROWSE( 10, 1, 18, 78, aCpo, AXR, "AXR" )
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	
	aedits := TBCOLEDIT( "SETEAR", "PLANILLAS", OX, aedits )
	
	IF MODIFICABLE
		OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
	ELSE
		OX:CARGO[TB_EDIT] := LOWER( OX:CARGO[TB_EDIT] )
	ENDIF
	TBCOLOR(OX)
	
	
	
	MENUDOWN({"    F2    º    F3    º    TAB   º   F8   º   R   º     P     º   F10   º ESC  ",;
				 "          º  busca   º  elegir  º subto- ºrastr‚aº plantilla º graba y º      ",;
				 " modifica º producto º producto º tales  ºproductº de prod.  º  sale   º sale "})
	ATOT := NEWEDIT2( "TOT1",,.F. )
	FVERREG( ATOT,, .T. )
	
	guardar = .F.
	DO WHILE .T.
		
		MOVABROW( OX, AXR, {||nK==K_TAB.OR.nK==37.OR.nK==K_ESC.OR.nK==K_F7.OR.nK==K_F3.OR.nK==K_F10.OR.nK==K_F9.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_SH_F6.OR.nK==K_F8.OR.nK==K_ALT_E.OR.CHR(nK)$'PpRr'},;
			{||nK==999}, {||DEVPOS(19,49),QQOUT(AXR[NROW,RG_DESCPROD]),.F.} )
		
		IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB .OR. OX:Cargo[TB_RET] == K_F3 ) .AND. MODIFICABLE
			IF TBNOC(OX) $ "CODPROD SURTIDOR CANTIDAD ABRIO INGRESO CERRO IMPORTE DESCUENTO"
				auxsu := AXR[NROW,RG_SURTIDOR]
				auxtb := AXR[NROW,RG_CODPROD]
				IF OX:CARGO[TB_MSGE] == "MODIF"
					AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
				ENDIF
				M->TPRECBASE  -= AXR[NROW,RG_TPRECBASE]
				M->TIMPINT    -= AXR[NROW,RG_TIMPINT]
				IF TBNOC(OX) == "CODPROD"
					r := 0
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
					AXR[NROW,RG_DESCPROD ] := FPRODUCTO(AXR[NROW,RG_CODPROD])
					AXR[NROW,RG_PRECBASE ] := FPRECBASE
					AXR[NROW,RG_IMPINT   ] := FIMPINT
					AXR[NROW,RG_IVA      ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 /100
					AXR[NROW,RG_PRECUNIT ] := AXR[NROW,RG_PRECBASE] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA]
					IF VXS(	AXR[NROW,RG_CODPROD] )
						IF NROW > 1
							IF AXR[NROW,RG_SURTIDOR] == 0
								AXR[NROW,RG_SURTIDOR] := AXR[NROW-1,RG_SURTIDOR] + 1
                    ENDIF
						ELSE
							IF AXR[NROW,RG_SURTIDOR] == 0
								AXR[NROW,RG_SURTIDOR] := 1
                    ENDIF
						ENDIF
					ENDIF
				ENDIF
				IF TBNOC(OX) $ "CODPROD SURTIDOR"
					IF AXR[NROW,RG_CODPROD] == 0
						AXR[NROW,RG_ABRIO]    := 0
						AXR[NROW,RG_CERRO]    := 0
						AXR[NROW,RG_CANTIDAD] := 0
					ELSE
							*** tomo el £ltimo CERRO de las planillas
						SELECT PL2
						SET ORDER TO FORDER({"SURTIDOR","FTOCI(PL2->FECHA)"})
						aux:=''; AEVAL(aturno,{|a,i| aux+=LEFT(aturno[LEN(aturno)-i+1],1) })
 						aux1 := STR(AXR[NROW,RG_SURTIDOR],2) + STR(AXR[NROW,RG_CODPROD],FLEN(PRD->CODPROD)) + FTOCI(APLA[ED_CONT,AX_FECHA])+CHR(AT(APLA[ED_CONT,AX_TURNO],aux))
						DBSEEK( aux1, .T. )
						DO WHILE PL2->CODPROD==AXR[NROW,RG_CODPROD] .AND. PL2->SURTIDOR==AXR[NROW,RG_SURTIDOR]
							AXR[NROW,RG_ABRIO]    := PL2->CERRO
                 	IF APLA[ED_CONT,AX_TURNO] $ UT_TURCONARR
								AXR[NROW,RG_CERRO] := IF( AXR[NROW,RG_CERRO]==0, AXR[NROW,RG_ABRIO], AXR[NROW,RG_CERRO] )
								IF VXS(	AXR[NROW,RG_CODPROD] )
									AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_CERRO] - AXR[NROW,RG_ABRIO]
								ELSE
									AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_ABRIO] - AXR[NROW,RG_CERRO]
								ENDIF
                    ELSE
								AXR[NROW,RG_CERRO] := AXR[NROW,RG_ABRIO]
                    ENDIF
                    EXIT
							SKIP
                 ENDDO
						SET ORDER TO FORDER({"FECHA","TURNO"})
					ENDIF
				ELSEIF TBNOC(OX) $ "CERRO ABRIO INGRESO"
					IF APLA[ED_CONT,AX_TURNO] $ UT_TURCONARR
						IF VXS(	AXR[NROW,RG_CODPROD] )
							AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_CERRO] - AXR[NROW,RG_ABRIO] - AXR[NROW,RG_INGRESO]
						ELSE
							AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_ABRIO] + AXR[NROW,RG_INGRESO] - AXR[NROW,RG_CERRO]
						ENDIF
              ELSE
						AXR[NROW,RG_CERRO] := AXR[NROW,RG_ABRIO] + AXR[NROW,RG_INGRESO]
              ENDIF
				ELSEIF TBNOC(OX) $ "CANTIDAD IMPORTE DESCUENTO"
					IF TBNOC(OX) == "IMPORTE"
						AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_IMPORTE] / AXR[NROW,RG_PRECUNIT]
					ELSEIF TBNOC(OX) == "DESCUENTO"
						AXR[NROW,RG_IMPORTE  ] -= AXR[NROW,RG_DESCUENTO]
						AXR[NROW,RG_PRECUNIT ] := ( AXR[NROW,RG_IMPORTE] / AXR[NROW,RG_CANTIDAD] )
					ENDIF
 					IF APLA[ED_CONT,AX_TURNO] $ UT_TURCONARR
						IF VXS(	AXR[NROW,RG_CODPROD] )
							AXR[NROW,RG_CERRO] := AXR[NROW,RG_TOTAL] + AXR[NROW,RG_CANTIDAD]
						ELSE
							AXR[NROW,RG_CERRO] := AXR[NROW,RG_TOTAL] - AXR[NROW,RG_CANTIDAD]
						ENDIF
              ENDIF
				ENDIF
           if HAYSTOCK(NROW)
					AXR[NROW,RG_TOTAL    ] := AXR[NROW,RG_ABRIO] + AXR[NROW,RG_INGRESO]
					AXR[NROW,RG_TPRECBASE] := AXR[NROW,RG_PRECBASE] * AXR[NROW,RG_CANTIDAD]
					AXR[NROW,RG_TIMPINT  ] := AXR[NROW,RG_IMPINT] * AXR[NROW,RG_CANTIDAD]
					AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
					M->TPRECBASE  += AXR[NROW,RG_TPRECBASE]
					M->TIMPINT    += AXR[NROW,RG_TIMPINT]
           endif
				FTOTALIZAR()
			ELSEIF TBNOC(OX) == "DESCPROD" .AND. OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			FVERREG( ATOT,, .T. )
			OX:RefreshCurrent()


		ELSEIF CHR(OX:Cargo[TB_RET]) $ 'Pp'
			xmenu:=MENUDOWN({ "  <+>  º   F2     º   F5   º    TAB    º   ENTER   º  ESC   ",;
								  	"       º          º        º actualiza º aplica la º        ",;
								  	" mueve º modifica º agrega º plantilla º plantilla º  sale  "})
        DO WHILE .T.
				PRIVATE bcamp[2], bmasc[2], bcab[2], bedit
				bcamp[ 1] = "RECNO()"
				bcamp[ 2] = "PLT->DESCPLANT"
				bmasc[ 1] = "999"
				bmasc[ 2] = "@!"
				bcab[ 1] = ""
				bcab[ 2] = "Plantilla"
				bedit = "FE"
				SELECT PLT
				lastreg = RECNO()
				r = BROW( 10, 1, 18, 50, "PLANTILLAS", bcamp, bmasc, bcab, bedit, "REEVARIOS(tecla)", "tecla=-1.OR.tecla=-5.OR.tecla=9" )
				RECUPAN()
        	IF LASTKEY()==K_ENTER .OR. LASTKEY()==K_ESC
              EXIT
        	ELSEIF LASTKEY() == K_TAB
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
        	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
				aaux := STOA( PLT->PLANTILLA )
				M->TPRECBASE := 0
				M->TIMPINT   := 0
           aa := ACLONE(AXR)
           *AXR := ARRAY( LEN(aaux) )
     		FOR z=1 TO LEN(aaux)
           	IF z > LEN(AXR)
              	AADD( AXR, AREG0(aCpo) )
              ELSE
						AXR[z] := AREG0( aCpo )
              ENDIF
           	n := ASCAN( aa, {|a| a[RG_CODPROD]==aaux[z,1].AND.a[RG_SURTIDOR]==aaux[z,2]} )
              IF n == 0
						AXR[z,RG_CODPROD ] := aaux[z,1]
						AXR[z,RG_SURTIDOR] := aaux[z,2]
						AXR[z,RG_DESCPROD] := FPRODUCTO(AXR[z,RG_CODPROD])
						AXR[z,RG_PRECBASE] := FPRECBASE
						AXR[z,RG_IMPINT  ] := FIMPINT
						AXR[z,RG_IVA     ] := AXR[z,RG_PRECBASE] * M->PIVA1 /100
						AXR[z,RG_PRECUNIT] := AXR[z,RG_PRECBASE] + AXR[z,RG_IMPINT] + AXR[z,RG_IVA]
							*** tomo el £ltimo CERRO de las planillas
						SELECT PL2
						SET ORDER TO PL2_SURARTFETU
						SET SOFTSEEK ON
						aux:=''; AEVAL(aturno,{|a,i| aux+=LEFT(aturno[LEN(aturno)-i+1],1) })
						aux1 := STR(AXR[z,RG_SURTIDOR],2) + STR(AXR[z,RG_CODPROD],FLEN(PRD->CODPROD)) + FTOCI(APLA[ED_CONT,AX_FECHA])+CHR(AT(APLA[ED_CONT,AX_TURNO],aux))
						SEEK aux1
						DO WHILE PL2->CODPROD==AXR[z,RG_CODPROD] .AND. PL2->SURTIDOR==AXR[z,RG_SURTIDOR]
							AXR[z,RG_ABRIO ] := PL2->CERRO
							AXR[z,RG_TOTAL ] := AXR[z,RG_ABRIO ]
                		IF APLA[ED_CONT,AX_TURNO] $ UT_TURCONARR
								AXR[z,RG_TOTAL ] := AXR[z,RG_ABRIO] + AXR[z,RG_INGRESO]
								AXR[z,RG_CERRO]  := IF( AXR[z,RG_CERRO]==0, AXR[z,RG_ABRIO], AXR[z,RG_CERRO] )
								IF VXS(	AXR[z,RG_CODPROD] )
									AXR[z,RG_CANTIDAD] := AXR[z,RG_CERRO] - AXR[z,RG_ABRIO]
								ELSE
									AXR[z,RG_CANTIDAD] := AXR[z,RG_ABRIO] - AXR[z,RG_CERRO]
								ENDIF
                 	ELSE
								AXR[z,RG_CERRO]  := AXR[z,RG_TOTAL]
                 	ENDIF
                 	EXIT
							SKIP
              	ENDDO
 						SET ORDER TO PL2_FECHATURN
 						SET SOFTSEEK OFF
						AXR[z,RG_TPRECBASE] := AXR[z,RG_PRECBASE] * AXR[z,RG_CANTIDAD]
						AXR[z,RG_TIMPINT  ] := AXR[z,RG_IMPINT] * AXR[z,RG_CANTIDAD]
						AXR[z,RG_IMPORTE  ] := AXR[z,RG_PRECUNIT] * AXR[z,RG_CANTIDAD]
              ELSE
						AEVAL(aa[n],{|a,x|AXR[z,x]:=aa[n,x]})
              ENDIF
					M->TPRECBASE  += AXR[z,RG_TPRECBASE]
					M->TIMPINT    += AXR[z,RG_TIMPINT]
				NEXT
           RECUPAN()
           for z=1 to len(AXR)
           	HAYSTOCK(z)
           next
           OX:configure()
				OX:RefreshAll()
				FTOTALIZAR()
				M->TPRECBASE  := 0
				M->TIMPINT    := 0
				AEVAL( AXR, {|a| M->TPRECBASE += a[RG_TPRECBASE], M->TIMPINT += a[RG_TIMPINT], M->DESCUENTO += a[RG_DESCUENTO]} )
        ENDIF

		ELSEIF CHR(OX:Cargo[TB_RET]) $ 'Rr'
			xmenu:=MENUDOWN({'','',''})
			MENSAJE(99,99, 0, .F., "RASTREANDO ...")
			aaux := {}
			SELECT PL2
			SET ORDER TO FORDER({"SURTIDOR","FTOCI(PL2->FECHA)"})
			aux:=''; AEVAL(aturno,{|a,i| aux+=LEFT(aturno[LEN(aturno)-i+1],1) })
 			aux1 := STR(AXR[NROW,RG_SURTIDOR],2) + STR(AXR[NROW,RG_CODPROD],FLEN(PRD->CODPROD)) + FTOCI(APLA[ED_CONT,AX_FECHA])+CHR(AT(APLA[ED_CONT,AX_TURNO],aux))
			DBSEEK( aux1, .T. )
			DO WHILE PL2->CODPROD==AXR[NROW,RG_CODPROD] .AND. PL2->SURTIDOR==AXR[NROW,RG_SURTIDOR] .AND. LEN(aaux) < 100
        	AADD( aaux, "" )
           AINS( aaux, 1 )
           aaux[1] := DTOC(PL2->FECHA) +'³'+ PL2->TURNO +'³'+ STR(PL2->ABRIO) +'³'+ STR(PL2->INGRESO) +'³'+ STR(PL2->TOTAL) +'°'+ STR(PL2->CERRO) +'°'+ STR(PL2->CANTIDAD)
           @ 23,70 SAY LEN(aaux)
				SKIP
           IF INKEY() == K_ESC
           	EXIT
           ENDIF
        ENDDO
			SET ORDER TO FORDER({"FECHA","TURNO"})
        RECUPAN()
        IF LEN( aaux) # 0
				aux := {{"Fecha   ³t³       Abrio³   Ingreso³ Total Abrio±       Cerro±Cantidad",;
							"ÄÄÄÄÄÄÄÄÅÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ±ÄÄÄÄÄÄÄÄÄÄÄÄ±ÄÄÄÄÄÄÄÄ"},;
							{ ALLTRIM(STR(AXR[NROW,RG_CODPROD]))+STR(AXR[NROW,RG_SURTIDOR],3)+'³'+ALLTRIM(AXR[NROW,RG_DESCPROD]), "=" }}
				PP_SELEC( 7, 5, 0, 0, aaux, LEN(aaux), aux, "S", .T., .T.)
        	RECUPAN()
        ENDIF
			PONEPAN(xmenu)

			
		ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
			IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
				AADD( AXR, AREG0(aCpo) )
			ENDIF
			OX:RefreshAll()
			
		ELSEIF OX:Cargo[TB_RET] == K_F5 .AND. MODIFICABLE
			AADD( AXR, AREG0(aCpo) )
        AINS( AXR, NROW )
			AXR[NROW] := AREG0(aCpo)
			OX:RefreshAll()

		ELSEIF OX:Cargo[TB_RET] == K_F8
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			XX_GRUPO    := 1
			XX_DESCGRUP := 2
			XX_CANTIDAD := 3
			XX_TOTAL    := 4
			SELECT GR
			aaux := {}
			DBEVAL( {|| AADD( aaux, ARRAY(XX_TOTAL) ),i:=LEN(aaux) 		,;
				aaux[i,XX_GRUPO   ]:=RECNO() 							,;
				aaux[i,XX_DESCGRUP]:=GR->DESCGRUP 					,;
				aaux[i,XX_CANTIDAD]:=0            					,;
				aaux[i,XX_TOTAL   ]:=0            				  },;
				{|| !DELETED() } )
			AADD( aaux, ARRAY(XX_TOTAL) )
			AFILL( aaux[LEN(aaux)], 0 )
			aaux[LEN(aaux),XX_DESCGRUP]:="OTROS               "
        FOR x=1 TO LEN(AXR)
				FPRODUCTO(AXR[x,RG_CODPROD])
				i := ASCAN( aaux, {|a| a[XX_GRUPO]==NGRUPO} )
				IF i == 0
					i := LEN(aaux)
				ENDIF
				aaux[i,XX_CANTIDAD] += AXR[x,RG_CANTIDAD]
				aaux[i,XX_TOTAL   ] += AXR[x,RG_IMPORTE]
				SKIP
			NEXT
			AADD( aaux, ARRAY(XX_TOTAL) )
			x := LEN(aaux)
			AFILL( aaux[x], 0 )
			aaux[x,XX_DESCGRUP] := "TOTAL =             "
			AEVAL( aaux,{|a|  aaux[x,XX_CANTIDAD] += a[XX_CANTIDAD],;
				aaux[x,XX_TOTAL]    += a[XX_TOTAL]   }, 1, x-1 )
			AEVAL( aaux,{|a,i| aaux[i] := a[XX_DESCGRUP] +"³"+ STR(a[XX_CANTIDAD],9,3) +"³"+ STR(a[XX_TOTAL],10,3) })
        RECUPAN()
			aux := {"Producto            ³  Cant.  ³  Total    ",;
				     "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ" }
			ele := PP_SELEC( 7, 30, 0, 0, aaux, 1, {aux}, "S", .T.)
			RECUPAN()



		ELSEIF OX:Cargo[TB_RET] == K_ALT_E
			TBCOLEDIT( "CAMBIAR", "PLANILLAS", OX, aedits, "EDITS.EST" )
			
			
		ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. MODIFICABLE
			IF PREGUNTA( 0, "¨ ESTAS SEGURO   [ S / N ] ?", "SsNn" ) $ "Ss"
				aux := AXR[NROW,RG_REGISTRO]
				AXR[NROW] := AREG0( aCpo )
				AXR[NROW,RG_REGISTRO] := aux
				OX:RefreshAll()
			ENDIF
		ELSEIF oX:Cargo[TB_RET] == K_SH_F6
			aux := AXR[NROW,RG_REGISTRO]
			AXR[NROW] := AREG0( aCpo )
			AXR[NROW,RG_REGISTRO] := aux
			oX:RefreshAll()

		ELSEIF OX:Cargo[TB_RET] == K_F7
			I_TITULO = IF( F10, "PLAYA", SUBSTR(FARRAY(aturno,APLA[ED_CONT,AX_TURNO]+'-'),3) )
			lastreg = RECNO()
			LISTADOR("PLAN")
			GO lastreg
			
		ELSEIF OX:Cargo[TB_RET] == K_F9
			M->TPRECBASE := 0
			M->TIMPINT   := 0
        M->TOTAL     := 0
			FOR i=1 TO LEN(AXR)
				M->TPRECBASE += AXR[i,RG_TPRECBASE]
				M->TIMPINT   += AXR[i,RG_TIMPINT]
           M->TOTAL     += AXR[i,RG_IMPORTE]
			NEXT
			FTOTALIZAR()
			FVERREG( ATOT,, .T. )
			
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
*		CLEARTYPEAHEAD()
	ENDDO
	
	
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
	IF guardar

			*** deja el Stock como estaba
		SELECT PL2
		SEEK FTOC(APLA[ED_CONT,AX_FECHA]) + APLA[ED_CONT,AX_TURNO]
		SELECT PRD
 		SET ORDER TO 1
		FFLOCK()
		DO WHILE PL2->FECHA==APLA[ED_CONT,AX_FECHA] .AND. PL2->TURNO==APLA[ED_CONT,AX_TURNO]
			SEEK PL2->CODPROD
        IF FOUND() .AND. PL2->FECHA >= PRD->FECHA
 	         PRD->VENTAS -= PL2->CANTIDAD
           PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
			ENDIF
			SKIP 1 ALIAS PL2
		ENDDO
			***

		FFLOCK("PL")
		FFLOCK("PL2")
		SELECT PL
		SEEK FTOC(APLA[ED_CONT,AX_FECHA]) + APLA[ED_CONT,AX_TURNO]
		IF !FOUND()
			SEEK FTOC(CTOD('')) + " "
			IF !FOUND()
				ADD_REC()
			ENDIF
		ENDIF
		PL->FECHA   := APLA[ED_CONT,AX_FECHA]
		PL->TURNO   := APLA[ED_CONT,AX_TURNO]
		PL->CODEMP1 := EDCONT(APLA2,"PL->CODEMP1")
		PL->CODEMP2 := EDCONT(APLA2,"PL->CODEMP2")
		PL->CODEMP3 := EDCONT(APLA2,"PL->CODEMP3")
		PL->CODEMP4 := EDCONT(APLA2,"PL->CODEMP4")
		PL->CODEMP5 := EDCONT(APLA2,"PL->CODEMP5")
		PL->CODEMP6 := EDCONT(APLA2,"PL->CODEMP6")
		PL->TOTAL   := M->TOTAL
     PL->DESCUENTO := M->DESCUENTO
		SELECT PL2
		FOR i=1 TO LEN(AXR)
*			IF AXR[i,RG_IMPORTE] + AXR[i,RG_CERRO]==0
			IF AXR[i,RG_CANTIDAD]+AXR[i,RG_INGRESO] == 0
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
					BLANKREG()
				ENDIF
			ELSE
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
				ELSE
					SEEK FTOC(CTOD(''))+' '
					IF !FOUND()
						ADD_REC()
					ENDIF
				ENDIF
				FRLOCK()
				PL2->FECHA    := APLA[ED_CONT,AX_FECHA]
				PL2->TURNO    := APLA[ED_CONT,AX_TURNO]
				PL2->SURTIDOR := AXR[ i, RG_SURTIDOR]
				PL2->CODPROD  := AXR[i,RG_CODPROD]
				PL2->ABRIO    := AXR[i,RG_ABRIO]
				PL2->INGRESO  := AXR[i,RG_INGRESO]
				PL2->TOTAL    := AXR[i,RG_TOTAL]
				PL2->CERRO    := AXR[i,RG_CERRO]
				PL2->CANTIDAD := AXR[i,RG_CANTIDAD]
				PL2->DESCPROD := AXR[i,RG_DESCPROD]
				PL2->PRECBASE := AXR[i,RG_PRECBASE]
				PL2->IMPINT   := AXR[i,RG_IMPINT]
				PL2->IVA      := AXR[i,RG_IVA]
				PL2->PRECUNIT := AXR[i,RG_PRECUNIT]
				PL2->IMPORTE  := AXR[i,RG_IMPORTE]
				PL2->DESCUENTO:= AXR[i,RG_DESCUENTO]
			ENDIF
		NEXT

			*** actualiza el Stock
		SELECT PRD
 		SET ORDER TO 1
		FFLOCK()
		FOR i=1 TO LEN(AXR)
			IF AXR[i,RG_IMPORTE]+AXR[i,RG_CERRO] # 0
				SEEK AXR[i,RG_CODPROD]
        	IF FOUND() .AND. APLA[ED_CONT,AX_FECHA] >= PRD->FECHA
 	         	PRD->VENTAS += AXR[i,RG_CANTIDAD]
           	PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
           ENDIF
			ENDIF
		NEXT i
     SELECT PL

	ENDIF
 	DBUNLOCKALL()
 	DBCOMMITALL()
	RECUPAN()
	IF !F10
		FEDITOR( APLA2, "SACAPAN" )
	ENDIF
	
ENDDO

RETURN


***************

STATIC FUNC FTOTALIZAR

***************

M->DESCUENTO := 0
AEVAL( AXR, {|a| M->DESCUENTO += a[RG_DESCUENTO]} )
M->SUBTOTAL  := M->TPRECBASE
M->TIVA1     := M->SUBTOTAL * M->PIVA1 / 100
M->TIVA2     := M->SUBTOTAL * M->PIVA2 / 100
M->TOTAL     := M->SUBTOTAL + M->TIMPINT + M->TIVA1 + M->TIVA2 - M->DESCUENTO
M->SUBTOTAL  := M->TOTAL - M->TIMPINT - M->TIVA1 - M->TIVA2

RETURN M->TOTAL


***************

STATIC FUNC HAYSTOCK(nFila)

***************
local r:=.T., nCant

if VA->CTRLSTOCK # "S"
	return .T.
endif

if PRD->(dbseek(AXR[nFila,RG_CODPROD]))
	nCant := 0
	aeval(AXR,{|a,i| if(a[RG_CODPROD]==AXR[nFila,RG_CODPROD],nCant+=a[RG_CANTIDAD],)} )
	if PRD->STOCKACT-nCant < 0
		CLEARTYPEAHEAD()
		MENSAJE( 0, 0, 10, .T., "STOCK NEGATIVO !!!",str(PRD->CODPROD)+"-"+PRD->DESCPROD+str(PRD->STOCKACT-nCant,10,4) )
*		AXR[nFila] := AREG0(aCpo)
		AXR[nFila,RG_CANTIDAD ] := 0
		AXR[nFila,RG_INGRESO  ] := 0
		AXR[nFila,RG_TOTAL    ] := AXR[NROW,RG_ABRIO] + AXR[NROW,RG_INGRESO]
		AXR[nFila,RG_CERRO    ] := AXR[nFila,RG_TOTAL]
		AXR[nFila,RG_IMPORTE  ] := 0
     r := .F.
  endif
endif

return r

*****************

FUNC VXS( nCual )

*****************
local r := .F.
if PRD->(dbseek(nCual))
	r := (PRD->CONSURT=="S")
endif

return r
