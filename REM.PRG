PARAMETERS TIPOFAC, cualcli
LOCAL guardar, NUEVO, MODIFICABLE, modoaux
PRIVATE EDX, ATOT, aCPO

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"


#define AX_TIPOREM		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->TIPOREM") ]
#define AX_NUMFAC		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->NUMFAC") ]
#define AX_CODCLI		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->CODCLI") ]
#define AX_FECHA 		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->FECHA") ]
#define AX_FECHVENC		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->FECHVENC") ]
#define AX_TURNOVENTA	EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->TURNOVENTA") ]
#define AX_TURNO     	EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"RE->TURNO") ]

#define RG_CODPROD        1
#define RG_CANTIDAD      2
#define RG_DESCPROD       3
#define RG_PRECBASE      4
#define RG_PRECUNIT      5
#define RG_IMPORTE       6
#define RG_IMPINT        7
#define RG_IVA           8
#define RG_TPRECBASE     9
#define RG_TIMPINT       10
#define RG_TIVA          11
#define RG_REGISTRO		  12

PROCESO := PROCNAME()
ym2 = 2
xm2 = 0

IF PCOUNT() > 1
	modoaux = "APPEND"
ELSE
	modoaux = ''
	cualcli = 0
ENDIF
IF TIPOFAC=="A"
	XBAS = "RA"
	XBAS2 = "RA2"
	aux = ""
ELSE
	XBAS = "RB"
	XBAS2 = "RB2"
	aux = ""
ENDIF
LOGO(.T., " REMITOS ")

MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
FBASES( { "REM", "REM2", "CAJA", "CLIENTES" }, .F. )

aCpo:={	                                                                      ;
	{ "CODPROD",     "C¢digo;Prod.",                       '', 'M',  '',  0, 0 },;
	{ "CANTIDAD",   "Cant.; ",                            '', 'M',  '',  0, 0 },;
	{ "DESCPROD",    "Descripci¢n; ",                      '', 'E',  '',  0, 0 },;
	{ "PRECBASE",   "Precio;Base",                        '', 'F',  '',  0, 0 },;
	{ "PRECUNIT",   "Precio;Unitario",                    '', 'F',  '',  0, 0 },;
	{ "IMPORTE",    "Importe; ",                          '', 'M', 'N', 10, 3 },;
	{ "IMPINT",     "Imp.;Int.",                          '', 'F',  '',  0, 0 },;
	{ "IVA",        "I.V.A.;"+STR(VA->PIVA1)+"%",          '', 'F',  '',  0, 0 },;
	{ "TPRECBASE",  "",                                   '',  '', 'N', 10, 5 },;
	{ "TIMPINT",    "",                                   '',  '', 'N', 10, 5 },;
	{ "TIVA",       "",                                   '',  '', 'N', 10, 5 },;
	{ "REGISTRO",   "",                                   '',  '', 'N',  0, 0 } }

SELECT RE2
aCpo := FARRAYAUX( aCpo )

SELECT RE
DBGOBOTTOM()

STORE RE->NUMFAC TO RNUMFAC, M->NUMFAC
SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

MODIFICABLE = .F.
NUEVO = .F.
EDX := NEWEDIT( "REM1",,.T. )
AX_CODCLI := cualcli
FCLI( EDCONT(EDX,"RE->CODCLI"), .T. )

RECUPAN()


DO WHILE .T.
	
	RELLENAPAN( 9, 0, 21, 80, "°", C_FONDO )
	SELECT RE
	SET ORDER TO RE_NUMFAC
	MENUDOWN({"          º         º   F2   º   F5   º    F6    º   TAB    º ENTER  º ESC  ",;
		"  remito   º  remito  º modif. º nuevo  º anula /  º lista de º  ver   º      ",;
		" siguiente º anteri¢r º remito º remito º desanula º remitos  º remito º sale "})
	NUEVO = .F.
	salir = .F.
	DO WHILE !salir
		
		k := FVERREG( EDX, {||K==9.OR.K==-4.OR.K==-5.OR.K==13.OR.K==-1} )
		M->ANULADO = RE->ANULADO
		
		
		IF K == K_ENTER
			modoaux = "VER"
			MODIFICABLE = .F.
			NUEVO = .F.
			salir = IF( RE->ANULADO=="A", .F., .T. )
			
			
		ELSEIF K==K_F2 .OR. k == K_F5
			xmenu:=MENUDOWN({"  <+>  º   TAB    º   F10    º  ESC   ",;
				"       º tablas de º graba y  º        ",;
				" mueve º   ayuda   º contin£a º  sale  "})
			MODIFICABLE = .T.
			NUEVO := .F.
			FEDITOR(EDX,"SETVARS",K,.F.)
			EDX[ED_I] := 1
			M->NUMFAC := FIELD->NUMFAC
			EDX[ED_REGISTRO] := 0
			IF K == K_F5
				DBGOBOTTOM()
				M->NUMFAC    := FIELD->NUMFAC + 1
				AX_NUMFAC    := M->NUMFAC
				AX_FECHA     := VA->FECHA
				AX_TURNO      := FIELD->TURNO
				AX_TURNOVENTA := 2
				AX_FECHVENC  := FFECHVENC( AX_FECHA, 2 )
				NUEVO := .T.
			ENDIF
			EDX[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( EDX, { 9, K_F10 } )
				
				IF EDX[ED_UPDATE] .OR. EDX[ED_TECLA] == K_TAB
					EDX[ED_MODE] = "MOSTRARTODO"
					IF EDNOM(EDX) == "RE->NUMFAC"
						IF NUEVO
							lastreg = RECNO()
							SEEK EDCONT(EDX)
							IF FOUND()
								MENSAJE( 0, 0, 10, .T., " N§ DE REMITO REPETIDO !!!" )
								EDPONE(EDX,,EDX[ED_LAST])
							ENDIF
							GO lastreg
						ELSE
							lastreg = RECNO()
							SEEK EDCONT(EDX)
							DO WHILE RE->NUMFAC==EDCONT(EDX,"RE->NUMFAC")
								IF RECNO() != lastreg
									MENSAJE( 0, 0, 10, .T., " N§ DE REMITO REPETIDO !!!" )
									EDPONE(EDX,,EDX[ED_LAST] )
									EXIT
								ENDIF
								SKIP
							ENDDO
							GO lastreg
						ENDIF
						
					ELSEIF EDNOM(EDX) == "RE->CODCLI"
						IF EDX[ED_TECLA] == K_TAB
							ele := FELEGIR("CLIENTES")
							RECUPAN()
						ELSE
							ele := EDCONT(EDX)
						ENDIF
						IF ele # 0
							EDPONE(EDX,,ele)
						ENDIF
						FCLI( EDCONT(EDX), .T. )
						
					ELSEIF EDNOM(EDX) == "RE->FECHVENC" .AND. EDX[ED_TECLA] == K_TAB
						aux := EDCONT(EDX) - EDCONT(EDX,"RE->FECHA")
						aux := INGRVAL(EDX[ED_Y], EDX[ED_X], "A cuantos d¡as", aux, "###", "")
						IF LASTKEY() == K_ENTER
							EDPONE(EDX,,EDCONT(EDX,"RE->FECHA") + aux )
						ENDIF
						
					ELSEIF EDNOM(EDX) == "RE->TURNO" .AND. EDX[ED_TECLA] == K_TAB
						ele = PP_SELEC( 4, 30, 0, 0, aturno, EDCONT(EDX), "", "S", .T., .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(EDX,,LEFT(aturno[ele],1) )
						ENDIF
						RECUPAN()
						
					ELSEIF EDNOM(EDX) $ "RE->TURNOVENTA RE->FECHA"
						IF EDX[ED_TECLA] == K_TAB .AND. EDNOM(EDX) == "RE->TURNOVENTA"
							ele = PP_SELEC( 5, 20, 0, 0, atipoventa, EDCONT(EDX), "", "S", .T.,.T.)
							IF LASTKEY() == K_ENTER
								EDPONE(EDX,,VAL(atipoventa[ele]) )
							ENDIF
							RECUPAN()
						ENDIF
						AX_FECHVENC := FFECHVENC( AX_FECHA, 2 )
					ENDIF
				ELSEIF ( EDX[ED_TECLA] == K_ENTER .AND. EDX[ED_I] == LEN(EDX[ED_EDIT]) ) .OR. EDX[ED_TECLA] == K_F10
					IF EDCONT(EDX,"RE->CODCLI") == 0
						MENSAJE( 0, 0, 10, .T., " CLIENTE INCORRECTO !!!" )
					ELSEIF EMPTY( EDCONT(EDX,"RE->FECHA") )
						MENSAJE( 0, 0, 10, .T., " FALTA LA FECHA DE VENTA " )
					ELSEIF EDCONT(EDX,"RE->FECHVENC") < EDCONT(EDX,"RE->FECHA")
						MENSAJE( 0, 0, 10, .T., " LA FECHA DE VENCIMIENTO ", " ES MENOR A LA DE VENTA !!!" )
					ELSEIF VA->PIVA1 = 0
						MENSAJE( 0, 0, 10, .T., " % I.V.A. INCORRECTO !!!" )
					ELSEIF VA->PIVA2 = 0 .AND. M->CATIVA=="RNI"
						MENSAJE( 0, 0, 10, .T., " FALTA EL I.V.A. NO RESPONSABLE !!!" )
					ELSEIF EDCONT(EDX,"RE->NUMFAC") == 0
						MENSAJE( 0, 0, 10, .T., " FALTA NUMERO DE REMITO !!!" )
					ELSEIF .NOT. EDCONT(EDX,"RE->TURNO") $ "123ES"
						MENSAJE( 0, 0, 10, .T., " FALTA TURNO (TURNO) !!!" )
					ELSE
						salir := .T.
						EXIT
					ENDIF
					
				ELSEIF EDX[ED_TECLA] == K_ESC
					EXIT
					
				ENDIF
			ENDDO
			PONEPAN(xmenu)
			
		ELSEIF k == K_TAB
			SELECT RE
			PRIVATE bcamp[6], bmasc[6], bcab[6], bedit
			bcamp[ 1] = "RE->NUMFAC"
			bcamp[ 2] = "FCLI(RE->CODCLI)"
			bcamp[ 3] = "RE->FECHA"
			bcamp[ 4] = "RE->NUMFAC"
			bcamp[ 5] = "RE->TOTAL"
			bcamp[ 6] = "RE->ANULADO"
			bmasc[ 1] = ""
			bmasc[ 2] = "!!!!!!!!!!!!!!!!!!!!"
			bmasc[ 3] = ""
			bmasc[ 4] = ""
			bmasc[ 5] = ""
			bmasc[ 6] = "X"
			bcab[ 1] = "N§Remito"
			bcab[ 2] = "Cliente"
			bcab[ 3] = "Fecha"
			bcab[ 4] = "Factura"
			bcab[ 5] = "Total"
			bcab[ 6] = "Anul"
			bedit = "FFFFFF"
			xmenu:=MENUDOWN({"  <+>  º  F3   º   F4   º  ENTER  º  ESC   ",;
				"       º       º        º elige y º        ",;
				" mueve º busca º busca+ º  sale   º  sale  "})
			SET DELETED OFF
			_lastreg = RECNO()
			BROW( 8, 10, 18, 75, "REMITOS", bcamp, bmasc, bcab, bedit )
			SET DELETED ON
			IF LASTKEY() # K_ENTER
				GO _lastreg
			ENDIF
			RECUPAN()
			PONEPAN(xmenu)
			
		ELSEIF K == K_F7
			LISTADOR( "REMITOS" )
			
		ELSEIF K == K_F6
			IF RE->ANULADO=="A"   				&& F6 DESANULA
				IF PREGUNTA( 12, " ¨ ESTE REMITO FUE ANULADO, DESEA DESANULAR ?   [ S / N ]", "SsNn") $ "Ss"
					FRLOCK()
					REPLACE RE->ANULADO WITH " "
					UNLOCK
				ENDIF
			ELSE											&& ANULA
				IF RE->NUMCTA == 0
					IF PREGUNTA( 12, " ¨ ESTA SEGURO ?  [ S / N ]", "SsNn") $ "Ss"
						MENSAJE( 0, 0, 0, .F., " ANULANDO REMITO . . ." )
						SELECT RE
						FRLOCK()
						REPLACE RE->ANULADO WITH "A"
						SELECT RE2
						FFLOCK()
						SEEK RE->NUMFAC
						DO WHILE FOUND()
							BLANKREG()
							SEEK RE->NUMFAC
						ENDDO
						RECUPAN()
					ENDIF
					SELECT RE
					UNLOCK ALL
				ELSE
					MENSAJE( 0, 0, 10, .T., " NO PUEDO ANULAR ESTE REMITO ",;
						" PORQUE HA SIDO USADO EN LA CUENTA N§"+STRZERO(RE->NUMCTA)+" !!!" )
				ENDIF
			ENDIF
			
		ELSEIF K == K_ESC
			salir:= .T.
		ENDIF
		
	ENDDO
	******************************************************************************
	******************************************************************************
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
	
	lastcolor=SETCOLOR("N/W,W/N")
	@ ym2-1,70 SAY IF( NUEVO,"NUEVO", IF(MODIFICABLE,"MODIF","VER  ") )
	SETCOLOR(lastcolor)
	RNUMFAC = M->NUMFAC
	IF LASTKEY()==27 .OR. modoaux=='SALIR'
		EXIT
	ELSEIF modoaux=="EDIT" .OR. modoaux=="APPEND"
		IF modoaux=="APPEND"
			GO BOTTOM
			M->NUMFAC = RE->NUMFAC + 1
			RNUMFAC = M->NUMFAC
		ENDIF
	ENDIF
	SETCOLOR("W/N,N/W")
	modoaux = ''
	
	**************************************
	* ingreso de los datos de la factura *
	**************************************
	ANULADA = RE->(DELETED())
	PAGADO = IF( RE->NUMFAC=0, .F., .T. )
	STORE .F. TO HUBOCAMBIOS
	M->PIVA1 = VA->PIVA1
	IF M->CATIVA=="RNI"						&& Resp.No Inscr.
		M->PIVA2 = VA->PIVA2
	ELSE
		M->PIVA2 = 0
	ENDIF
	
	*******************
	* Carga el remito *
	*******************
	PUBLIC AXR := {}
	STORE 0 TO M->DESCUENTO, M->SUBTOTAL, M->TIVA1, M->TIVA2, M->TOTAL, M->TPRECBASE, M->TIMPINT
	M->PORCDESC = IF( NUEVO, 0, RE->PORCDESC )
	RNUMFAC := 0
	RFECHA  := CTOD('')
	RTURNO   := ' '
	RTOTAL  := 0
	
	IF !NUEVO
		STORE .F. TO ANULADA, PAGADO
		RNUMFAC := RE->NUMFAC
		RTOTAL  := RE->TOTAL
		RFECHA  := RE->FECHA
		RTURNO   := RE->TURNO
		SELECT RE2
		SEEK RNUMFAC
		DO WHILE RE2->NUMFAC == RNUMFAC .AND. !RE2->(EOF())
			AADD( AXR, ARRAY( RG_REGISTRO ) )
			i := LEN(AXR)
			AXR[ i,RG_CODPROD   ] := FIELD->CODPROD
			AXR[ i,RG_DESCPROD  ] := FIELD->DESCPROD
			AXR[ i,RG_CANTIDAD ] := FIELD->CANTIDAD
			AXR[ i,RG_PRECBASE ] := FIELD->PRECBASE
			AXR[ i,RG_IMPINT   ] := FIELD->IMPINT
			AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
			AXR[ i,RG_TPRECBASE] := AXR[i,RG_PRECBASE] * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_TIMPINT  ] := AXR[i,RG_IMPINT] * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_IVA      ] := AXR[i,RG_PRECBASE] * M->PIVA1 / 100
			AXR[ i,RG_IMPORTE  ] := (AXR[i,RG_PRECBASE]+AXR[i,RG_IMPINT]+AXR[i,RG_IVA]) * AXR[i,RG_CANTIDAD]
			AXR[i,RG_REGISTRO  ] := RECNO()
			M->TPRECBASE += AXR[i,RG_TPRECBASE]
			M->TIMPINT   += AXR[i,RG_TIMPINT]
			SKIP
		ENDDO
	ENDIF
	IF MODIFICABLE .OR. LEN(AXR) == 0
		AADD( AXR, AREG0( aCpo ) )
	ENDIF
	FTOTALIZAR()
	
	RECUPAN()
	
	
	SETCOLOR( "W/N,N/W" )
	OX := MYABROWSE( 9, 1, 17, 78, aCpo, AXR, "AXR" )
	OX:CARGO[TB_BARRAY] := OX:CARGO[TB_BARRAX] := .F.
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	IF MODIFICABLE
		OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
	ELSE
		OX:CARGO[TB_EDIT] := LOWER( OX:CARGO[TB_EDIT] )
	ENDIF
	
	
	MENUDOWN({" <+>   º    F2    º    F3    º     %     º    TAB   º   F10   º ESC  ",;
		"       º          º  busca   º           º  elegir  º graba y º      ",;
		" mueve º modifica º producto º descuento º producto º  sale   º sale "})
	ATOT := NEWEDIT( "TOT",,.F. )
	FVERREG( ATOT,, .T. )
	
	guardar = .F.
	DO WHILE .T.
		
		MOVABROW( OX, AXR, {||nK==9.OR.nK==37.OR.nK==27.OR.nK==-6.OR.nK==-2.OR.nK==-9},;
			{||nK==999} )
		
		IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB .OR. OX:Cargo[TB_RET] == K_F3 ) .AND. MODIFICABLE
			IF TBNOC(OX) $ "CODPROD CANTIDAD IMPORTE"
				IF OX:CARGO[TB_MSGE] == "MODIF"
					AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
				ENDIF
				M->TPRECBASE -= AXR[NROW,RG_TPRECBASE]
				M->TIMPINT   -= AXR[NROW,RG_TIMPINT]
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
					AXR[NROW,RG_DESCPROD ] := FPRODUCTO(AXR[NROW,RG_CODPROD])
					AXR[NROW,RG_PRECBASE] := FPRECBASE
					AXR[NROW,RG_IMPINT  ] := FIMPINT
					AXR[NROW,RG_IVA     ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 /100
					AXR[NROW,RG_PRECUNIT] := AXR[NROW,RG_PRECBASE] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA]
				ELSEIF TBNOC(OX) == "IMPORTE"
					AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_IMPORTE] / AXR[NROW,RG_PRECUNIT]
				ENDIF
				AXR[NROW,RG_TPRECBASE] := AXR[NROW,RG_PRECBASE] * AXR[NROW,RG_CANTIDAD]
				AXR[NROW,RG_TIMPINT  ] := AXR[NROW,RG_IMPINT] * AXR[NROW,RG_CANTIDAD]
				AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
				M->TPRECBASE += AXR[NROW,RG_TPRECBASE]
				M->TIMPINT   += AXR[NROW,RG_TIMPINT]
				FTOTALIZAR()
			ELSEIF TBNOC(OX) == "DESCPROD" .AND. OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			FVERREG( ATOT,, .T. )
			OX:RefreshCurrent()
			
		ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
			IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
				AADD( AXR, AREG0(aCpo) )
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F7
			IF PREGUNTA( 10, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
				DO LISTADOR WITH "REMITO"
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == 37.AND.MODIFICABLE				&&  %
			ATOT[ED_REGISTRO] := 0
			ATOT[ED_I] = 1
			DO WHILE .T.
				ATOT[ED_MODE] = "MOSTRAR"
				FEDITAR( ATOT, {} )
				IF ATOT[ED_TECLA] == K_ENTER
					IF ATOT[ED_UPDATE]
						FEDITOR( ATOT, "GRABAR", .F. )
						FTOTALIZAR()
					ENDIF
					EXIT
				ELSEIF ATOT[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			FVERREG( ATOT,, .T. )
			
		ELSEIF OX:Cargo[TB_RET] == K_ALT_M
			CALC()
			
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
		FFLOCK( "RE" )
		FFLOCK( "RE2" )
		SELECT RE                  &&.facturas.dbf
		IF NUEVO
			SEEK 0
			IF !FOUND()
				ADD_REC()
			ENDIF
		ENDIF
		RE->NUMFAC    := AX_NUMFAC
		RE->FECHA     := AX_FECHA
		RE->CODCLI    := AX_CODCLI
		RE->FECHVENC  := AX_FECHVENC
		RE->TURNOVENTA := AX_TURNOVENTA
		RE->TPRECBASE := M->TPRECBASE
		RE->PORCDESC  := M->PORCDESC
		RE->TIMPINT   := M->TIMPINT
		RE->IVA1      := M->PIVA1
		RE->IVA2      := M->PIVA2
		RE->TOTAL     := M->TOTAL
		RE->TURNO      := AX_TURNO
		SELECT RE2
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
					IF !FOUND()
						ADD_REC()
					ENDIF
				ENDIF
				RE2->NUMFAC   := AX_NUMFAC
				RE2->CODPROD   := AXR[i,RG_CODPROD]
				RE2->CANTIDAD := AXR[i,RG_CANTIDAD]
				RE2->DESCPROD  := AXR[i,RG_DESCPROD]
				RE2->PRECBASE := AXR[i,RG_PRECBASE]
				RE2->IMPINT   := AXR[i,RG_IMPINT]
				RE2->PRECUNIT := AXR[i,RG_PRECUNIT]
			ENDIF
		NEXT
		
		IF VA->REMITOS == "S" .and. 1==2
			* * * actualizar CAJA * * *
			SELECT CA
			FFLOCK()
			IF !NUEVO
				SEEK FTOC(RFECHA) + RTURNO
				DO WHILE CA->FECHA==RFECHA .AND. CA->TURNO==RTURNO
					IF CA->CODCONCINT==nRemitos
						CA->INGRESO -= RTOTAL
						EXIT
					ENDIF
					SKIP
				ENDDO
			ENDIF
			aux := .F.
			SEEK FTOC(AX_FECHA) + AX_TURNO
			IF !FOUND()
				SEEK FTOC(CTOD('')) + " "
				aux := FOUND()
			ELSE
				DO WHILE CA->FECHA==AX_FECHA .AND. CA->TURNO==AX_TURNO
					IF CA->CODCONCINT==nRemitos
						aux = .T.
						EXIT
					ENDIF
					SKIP
				ENDDO
			ENDIF
			IF !aux
				ADD_REC()
			ENDIF
			FRLOCK()
			CA->FECHA      := AX_FECHA
			CA->TURNO       := AX_TURNO
			CA->CODCONCINT := nRemitos
			CA->CONCEPTO   := aconcint[nRemitos]
			CA->INGRESO    += M->TOTAL
		ENDIF
		DBUNLOCKALL()
		DBCOMMITALL()
	ENDIF
	
	RECUPAN()
	
ENDDO

RETURN
