LOCAL guardar, NUEVO, MODIFICABLE, modoaux
PRIVATE EDX, ATOT, aCPO

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"


#define AX_NUMFAC		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->NUMFAC") ]
#define AX_CODPROV		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->CODPROV") ]
#define AX_FECHA 		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->FECHA") ]
#define AX_FECHVENC		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->FECHVENC") ]
#define AX_TIPOCOMPRA	EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->TIPOCOMPRA") ]
#define AX_CATIVA 		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->CATIVA") ]
#define AX_OPROVIS 		EDX[ ED_CONT, ASCAN(EDX[ED_FIELDS],"CO->OPROVIS") ]

RG_CODPROD    := 1
RG_XCANT      := 2
RG_UNXCAJA    := 3
RG_DESCPROD   := 4
RG_PRECBASE   := 5
RG_IMPORTE    := 6
RG_BONIF      := 7
RG_RECARGO    := 8
RG_IMPINT     := 9
RG_TIMPINT    := 10
RG_IVA        := 11
RG_TPRECBASE  := 12
RG_TIVA       := 13
RG_PRECUNIT   := 14
RG_CANTIDAD   := 15
RG_TIPOIMPINT := 16
RG_GRUPO      := 17
RG_CONIMPINT  := 18
RG_REGISTRO   := 19

ym2 = 2
xm2 = 0

M->TIPOPROV := "E"
LOGO(.T., " COMPRAS ")

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
F_ABASE({"CO","PRV"},"CERRAR")
FBASES( { "COMPRAS","COMPRAS2", "PROVEE","OPROVIS","OPROVIS2","CCC" }, .F. )

aCpo:={;
	{ "CODPROD",    "C¢digo;Prod.",                       '', 'M',  '',  0, 0 },;
	{ "XCANT",      "Cant.; ",                            '', 'M',  '',  0, 0 },;
	{ "UNXCAJA",    "UxC; ",                              '', 'F',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                      '', 'E',  '',  0, 0 },;
	{ "PRECBASE",   "Precio; ",                   '999.9999', 'M',  '',  0, 0 },;
	{ "IMPORTE",    "Importe; ",                          '', 'M', 'N', 10, 3 },;
	{ "BONIF",      "Bonifi-;caci¢n",                     '', 'M',  '',  0, 0 },;
	{ "RECARGO",    "Recargo",                            '', 'E',  '',  0, 0 },;
	{ "IMPINT",     "Imp.;Int.",                  '999.9999', 'F', 'N', 10, 5 },;
	{ "TIMPINT",    "Total;Imp.Int.",             '999.9999', 'F', 'N', 10, 5 },;
	{ "IVA",        "I.V.A.;"+STR(VA->PIVA1)+"%", '999.9999', 'F',  '',  0, 0 },;
	{ "TPRECBASE",  "",                                   '',  '', 'N', 10, 5 },;
	{ "TIVA",       "",                                   '',  '', 'N', 10, 5 },;
	{ "PRECUNIT",   "",                                   '',  '',  '',  0, 0 },;
	{ "CANTIDAD",   "",                                   '',  '',  '',  0, 0 },;
	{ "TIPOIMPINT", "",                                   '',  '', 'C',  1, 0 },;
	{ "GRUPO",      "",                                   '',  '', 'N',  3, 0 },;
	{ "CONIMPINT",  "",                                   '',  '', 'N',  1, 0 },;
	{ "REGISTRO",   "",                                   '',  '', 'N',  0, 0 } }

select CO2
set order to FORDER({"CODPROV","NUMFAC"})
aCpo := FARRAYAUX( aCpo )

select CO
dbgobottom()

STORE CO->NUMFAC TO RNUMFAC
RFECHA := CO->FECHA
setcolor(C_MENU)
SET(_SET_INTENSITY,.T.)

MODIFICABLE = .F.
NUEVO = .F.
EDX := NEWEDIT( "COMPRA1",,.T. )
PROVEEV( EDCONT(EDX,"CO->CODPROV") )

RECUPAN()


DO WHILE .T.
	
	RELLENAPAN( 9, 0, 21, 80, "°", C_FONDO )
	select CO
	SET ORDER TO CO_CODPROV_NUMFAC
	MENUDOWN({"   factura º   F2   º   F5   º   F6    º   TAB    º    O   º ENTER  º ESC  ",;
				 "   siguiente º modif. º  nueva º         º lista de ºOrden deº  ver   º      ",;
				 "    anterior º facturaº facturaº elimina º facturas º Provis.º facturaº sale "})
	NUEVO = .F.
	lSalir = .F.
	DO WHILE !lSalir
		k := FVERREG( EDX, {|K|K==9.OR.K==-4.OR.K==-5.OR.K==13.OR.K==-1.or.k==K_F8.or.chr(k)$'OoPp'} )
		
		IF K == K_ENTER
			modoaux = "VER"
			FEDITOR(EDX,"LEER")
			MODIFICABLE = .F.
			NUEVO = .F.
        lSalir := .T.
			
		ELSEIF K==K_F2 .OR. k == K_F5
			xmenu:=MENUDOWN({"  <+>  º   TAB    º   F10    º  ESC   ",;
								  "       º tablas de º graba y  º        ",;
								  " mueve º   ayuda   º contin£a º  sale  "})
			MODIFICABLE = .T.
			NUEVO := .F.
			FEDITOR(EDX,"SETVARS",K,.F.)
			EDX[ED_I] := 1
			AX_NUMFAC := FIELD->NUMFAC
			EDX[ED_REGISTRO] := 0
        modoaux := "EDIT"
			IF K == K_F5
				DBGOBOTTOM()
				AX_NUMFAC    := SPACE(LEN(CO->NUMFAC))
				AX_FECHA     := VA->FECHA
				AX_TIPOCOMPRA:= 2
				AX_FECHVENC  := FFECHVENC( AX_FECHA, 2 )
				NUEVO := .T.
        	modoaux := "APPEND"
			ENDIF
			EDX[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( EDX, { 9, K_F10 } )
				
				IF EDX[ED_UPDATE] .OR. EDX[ED_TECLA] == K_TAB
					IF EDNOM(EDX) $ "CO->NUMFAC CO->CODPROV"
						IF EDNOM(EDX) == "CO->CODPROV"
							IF EDX[ED_TECLA] == K_TAB
								IF PROVEEV( EDCONT(EDX,"CO->CODPROV"),.T.)
									EDPONE( EDX,,PRV->CODPROV )
								ENDIF
							ENDIF
							PROVEEV( EDCONT(EDX) )
                 	EDPONE( EDX, "CO->RAZONSOC", PRV->RAZONSOC)
                 	EDPONE( EDX, "CO->CUIT", PRV->CUIT)
                 	EDPONE( EDX, "CO->CATIVA", PRV->CATIVA)
							AX_NUMFAC := IF( AX_CATIVA=="RI ", "FA", "FC" ) + SUBSTR(AX_NUMFAC,3)
						ELSEIF EDNOM(EDX) == "CO->NUMFAC"
        				aaux:=FNUMFAC(AX_NUMFAC)
        				AX_NUMFAC := padr(left(aaux[1],3),3,' ')+aaux[2]+"-"+aaux[3]
						ENDIF
						IF EDNOM(EDX) $ "CO->NUMFAC CO->CODPROV"
							IF FREPEAT( STR(AX_CODPROV,4)+AX_NUMFAC, IF(NUEVO,"APPEND","EDIT") )
								MENSAJE( 0, 0, 10, .T., " FACTURA REPETIDA !!!" )
								EDX[ED_TECLA] := 0
								EDPONE(EDX,, EDX[ED_LAST])
							ENDIF
                 ENDIF
						EDX[ED_MODE] = "MOSTRARTODO"
					ELSEIF EDNOM(EDX) == "CO->FECHVENC"
 						IF EDX[ED_TECLA] == K_TAB
							aux := EDCONT(EDX) - EDCONT(EDX,"CO->FECHA")
							aux := INGRVAL(EDX[ED_Y], EDX[ED_X], "A cuantos d¡as", aux, "###", "")
							IF LASTKEY() == K_ENTER
								EDPONE(EDX,,EDCONT(EDX,"CO->FECHA") + aux )
							ENDIF
                 ENDIF
						EDX[ED_MODE] = "MOSTRARTODO"
					ELSEIF EDNOM(EDX) $ "CO->TIPOCOMPRA CO->FECHA"
						IF EDX[ED_TECLA] == K_TAB .AND. EDNOM(EDX) == "CO->TIPOCOMPRA"
							ele = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, atipoventa, EDCONT(EDX), "", "S", .T.,.T.)
							IF LASTKEY() == K_ENTER
								EDPONE(EDX,,VAL(atipoventa[ele]) )
							ENDIF
							RECUPAN()
						ENDIF
                 IF EDCONT(EDX,"CO->TIPOCOMPRA") == 1
                 	AX_FECHVENC := EDCONT(EDX,"CO->FECHA")
                 ELSE
							AX_FECHVENC := FFECHVENC( AX_FECHA, 2 )
                 ENDIF
						EDX[ED_MODE] = "MOSTRARTODO"
					ELSEIF EDNOM(EDX) == "CO->CATIVA" .AND. EDX[ED_TECLA] == K_TAB
						ele := PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, acativa, EDCONT(EDX), "", "S", .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(EDX,,LEFT(acativa[ele],3))
						ENDIF
						RECUPAN()
					ELSEIF EDNOM(EDX) == "CO->OPROVIS"
						IF EDX[ED_TECLA] == K_TAB
							IF OP( EDCONT(EDX), EDX )
								EDPONE( EDX,,OP->OPROVIS )
							ENDIF
                 ENDIF
					ELSEIF EDNOM(EDX) == "CO->CODLOC" .AND. EDX[ED_TECLA] == K_TAB
						ele = ABRW( EDX[ED_Y], EDX[ED_X], 0, 'vlocalid', EDCONT(EDX), 'LOCALIDADES')
						IF LASTKEY() == K_ENTER
							EDPONE(EDX,,ele)
						ENDIF
					ELSEIF EDNOM(EDX) $ "CO->LOCALIDAD CO->CODPOS"
						IF CP( EDCONT(EDX,"CO->LOCALIDAD") )
							EDPONE(EDX,"CO->LOCALIDAD",CP->LOCALIDAD)
							EDPONE(EDX,"CO->CODPOS",CP->CODPOS)
							EDX[ED_MODE] = "MOSTRARTODO"
						ENDIF
					ENDIF
					
				ELSEIF ( EDX[ED_TECLA] == K_ENTER .AND. EDX[ED_I] == LEN(EDX[ED_EDIT]) ) .OR. EDX[ED_TECLA] == K_F10
					IF EMPTY( EDCONT(EDX,"CO->FECHA") )
						MENSAJE( 0, 0, 10, .T., " FALTA LA FECHA DE COMPRA " )
					ELSEIF EDCONT(EDX,"CO->FECHVENC") < EDCONT(EDX,"CO->FECHA")
						MENSAJE( 0, 0, 10, .T., " LA FECHA DE VENCIMIENTO ", " ES MENOR A LA DE VENTA !!!" )
					ELSEIF VA->PIVA1 = 0
						MENSAJE( 0, 0, 10, .T., " % I.V.A. INCORRECTO !!!" )
					ELSEIF VA->PIVA2 = 0 .AND. M->CATIVA=="RNI"
						MENSAJE( 0, 0, 10, .T., " FALTA EL I.V.A. NO RESPONSABLE !!!" )
					ELSEIF empty(AX_NUMFAC)
						MENSAJE( 0, 0, 10, .T., " FALTA NUMERO DE FACTURA !!!" )
					ELSE
						lSalir := .T.
						EXIT
					ENDIF
					
				ELSEIF EDX[ED_TECLA] == K_ESC
					EXIT
					
				ENDIF
			ENDDO
			PONEPAN(xmenu)
			
		ELSEIF k == K_F8
     	if QUEFECHA2(10,30)
        	PRORRATEAR()
        endif
			
		ELSEIF CHR(k) $ 'Oo'
     	OP()
			
		ELSEIF CHR(k) $ 'Pp'
*    	if CO->TIPOCOMPRA==1
				nReg:=recno()
				FBASES({"+CHEQEMI","+CHEQUES","+BANCO"})
           M->CODPROV := CO->CODPROV
				select CCC
     		dbsetorder(CCC_NUMOPAG)
        	dbseek(CO->NUMOPAG)
     		EDOPAG( if(found(),K_F2,K_F5) )
           select CO
           go nReg
*       endif

		ELSEIF k == K_TAB
			aCp:={;
				{ "NUMFAC",     "N§;Factura",                         '', 'F',  '',  0, 0 },;
				{ "CODPROV",    "C¢d;PR",                            '', 'F',  '',  0, 0 },;
				{ "RAZONSOC",   "Proveedor",              replic('X',20), 'F', 'F', 20, 0 },;
				{ "FECHA",      "Fecha",                              '', 'F',  '',  0, 0 },;
				{ "FECHVENC",   "Fecha;Venc.",                        '', 'F',  '',  0, 0 },;
				{ "TOTAL",      "Total",                              '', 'F',  '',  0, 0 },;
				{ "NUMOPAG",    "Orden;Pago",                         '', 'F',  '',  0, 0 }}
			select CO
        nReg:=recno()
			aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
        aOrdenNtx := {{"C¢d.Prov. y N§ Fact.",{"CODPROV","NUMFAC"}},;
							  {"Fecha de Compra y C¢d.Prov.",{"FECHA","CODPROV"}},;
							  {"Fecha de Venc.",{"FECHVENC"}}}
        nOrden := 1
			cMenu2:=MENUDOWN({"  <+>  º           º F8    ùver º    O     º  ESC   ",;
			  			 			"       º F3 busca  º compras en º Orden de º        ",;
			  			 			" mueve º F4 busca+ º otro orden ºProvisi¢n º  sale  "})
			SETCOLOR( C_MENU )
			MARCO( 7, 5, 20, 78, "<< BOLETAS DE COMPRA >>", "D", .T., 0 )
			oX := MYBROWSE( 7, 5, 20, 78, aCp )
			oX:CARGO[TB_REFRESH] := 10
			OX:FREEZE:=3
			DO WHILE .T.
        	@ 21,5 say "Ordenado x:"+padr(UPPER(aOrdenNtx[nOrden,1]),30,' ')
				MOVBROW( oX, {||nK==K_ENTER.or.nK==K_ESC.or.nK==K_F8.OR.chr(nK)$'Oo'} )
				IF oX:Cargo[TB_MSGE] == "MODIF" .and. .f.
 					FRLOCK()
					FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
					UNLOCK
					TBPOS(OX)
				ELSEIF chr(oX:Cargo[TB_RET]) $ 'Oo'
        		OP()
				ELSEIF oX:Cargo[TB_RET] == K_F8
					op3 = MENUFLASH( 10, 30, nOrden, .T., "ORDENADO X", aOrdenNtx[1,1], aOrdenNtx[2,1], aOrdenNtx[3,1] )
					IF LASTKEY() == K_ENTER
              	nOrden := op3
						set order to FORDER(aOrdenNtx[nOrden,2])
						TBPOS(OX,.T.)
					ENDIF
				ELSEIF oX:Cargo[TB_RET] == K_ENTER
					EXIT
				ELSEIF oX:Cargo[TB_RET] == K_ESC
           	go nReg
					EXIT
				ENDIF
			ENDDO
			set order to 1
			DBUNLOCKALL()
			DBCOMMITALL()
        RECUPAN()
        MENUDOWN(cMenu2)

		ELSEIF K == K_F7
			LISTADOR( "COMPRAS" )
			
		ELSEIF K == K_F6 .AND. val(right(CO->NUMFAC,8))#0
			IF PREGUNTA( 12, " ¨ ESTAS SEGURO ?   [ S / N ]", "SsNn") $ "Ss"
				MENSAJE(0,0,0,.F.,"ELIMINANDO...")
				aux := STR(CO->CODPROV)+CO->NUMFAC
				SELECT CO2
 				SEEK aux
				SELECT PRD
				FFLOCK()
 				SET ORDER TO 1
 				DO WHILE CO2->CODPROV==CO->CODPROV .AND. CO2->NUMFAC==CO->NUMFAC .AND. !CO2->(EOF())
					SEEK CO2->CODPROD
        		IF FOUND() .AND. CO2->FECHA >= PRD->FECHA
 	         		PRD->COMPRAS  -= CO2->CANTIDAD
           		PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
					ENDIF
        		if OP2->( dbseek( str(CO->OPROVIS,10)+str(CO2->CODPROD) ) )
           		frlock("OP2")
 						OP2->CANTUSADO -= CO2->CANTIDAD
              	OP2->(dbunlock())
           	ENDIF
					skip 1 alias CO2
				ENDDO
           select CO2
           do while dbseek( aux )
					BLANKREG()
           enddo
           select CO
				BLANKREG(.T.)
           dbseek( aux, .T. )
           if eof();  dbgobottom();  endif
           RECUPAN()
			ENDIF
			
		ELSEIF K == K_ESC
			lSalir:= .T.
		ENDIF
		
	ENDDO
	******************************************************************************
	******************************************************************************
	
	
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
	RCODPROV := AX_CODPROV
	RNUMFAC  := AX_NUMFAC
  ROPROVIS := 0
	IF LASTKEY()==27 .OR. modoaux=='SALIR'
		EXIT
	ELSEIF modoaux=="EDIT"
		RCODPROV := CO->CODPROV
		RNUMFAC  := CO->NUMFAC
  	ROPROVIS := CO->OPROVIS
	ENDIF
	SETCOLOR("W/N,N/W")
	modoaux = ''
	
	HUBOCAMBIOS := .F.
	PAGADO      := .F.
	IF !NUEVO
		PAGADO = IF( EMPTY(CO->FECHCIERRE), .F., .T. )
	ENDIF
	M->PIVA1 = VA->PIVA1
	IF M->CATIVA=="RNI"						&& Resp.No Inscr.
		M->PIVA2 = VA->PIVA2
	ELSE
		M->PIVA2 = 0
	ENDIF
	
	********************
	* Carga la factura *
	********************
	PUBLIC AXR := {}
	STORE 0 TO M->BONIF, M->SUBTOTAL, M->SUBTOTAL2, M->TIVA1, M->TIVA2, M->TOTAL,;
		M->TPRECBASE, M->TIMPINT, M->PORCPERC, M->PERCEPCION, M->PORCBON,;
		M->PORCFIN, M->FINANC, M->PORCIIBB, M->IIBB, M->TRECARGO
	
	IF !NUEVO .AND. !PAGADO
		SELECT CO2
		SEEK STR(RCODPROV,4) + RNUMFAC
		DO WHILE CO->CODPROV==RCODPROV .AND. CO2->NUMFAC==RNUMFAC .AND. !CO2->(EOF())
     	FPRODUCTO( FIELD->CODPROD )
			AADD( AXR, ARRAY( RG_REGISTRO ) )
			i := LEN(AXR)
			AXR[ i,RG_CODPROD  ] := FIELD->CODPROD
			AXR[ i,RG_DESCPROD ] := FIELD->DESCPROD
			AXR[ i,RG_XCANT    ] := IF( VAL(FIELD->XCANT)==0, STR(FIELD->CANTIDAD,9,1), FIELD->XCANT )
			AXR[ i,RG_CANTIDAD ] := FIELD->CANTIDAD
			AXR[ i,RG_PRECBASE ] := FIELD->PRECBASE
        AXR[ i,RG_RECARGO  ] := FIELD->RECARGO
			AXR[ i,RG_IMPINT   ] := FIELD->IMPINT
        AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
			AXR[ i,RG_TPRECBASE] := AXR[i,RG_PRECBASE] * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_TIMPINT  ] := AXR[i,RG_IMPINT] * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_IVA      ] := (AXR[i,RG_PRECBASE]+AXR[i,RG_RECARGO]) * M->PIVA1 / 100
        AXR[ i,RG_BONIF    ] := FIELD->BONIF
			AXR[ i,RG_IMPORTE  ] := AXR[i,RG_TPRECBASE] + AXR[i,RG_RECARGO]
			AXR[ i,RG_UNXCAJA  ] := FIELD->UNXCAJA
			AXR[ i,RG_TIPOIMPINT]:= FTIPOIMPINT
			AXR[ i,RG_GRUPO    ] := NGRUPO
			AXR[ i,RG_CONIMPINT] := NCONIMPINT
			AXR[ i,RG_REGISTRO ] := RECNO()
			SKIP
		ENDDO
	ENDIF
	IF !NUEVO
		M->PORCBON    := CO->PORCBON
		M->BONIF      := CO->BONIF
     M->TRECARGO   := CO->TRECARGO
		M->PORCIIBB   := CO->PORCIIBB
		M->IIBB       := CO->IIBB
		M->PORCFIN    := CO->PORCFIN
		M->FINANC     := CO->FINANC
		M->TPRECUNIT  := CO->TPRECUNIT
		M->TIMPORTE   := CO->TIMPORTE
		M->TPRECBASE  := CO->TPRECBASE
		M->TIMPINT    := CO->TIMPINT
		M->TIVA1      := CO->TIVA1
		M->PORCPERC   := CO->PORCPERC
		M->PERCEPCION := CO->PERCEPCION
		M->TOTAL      := CO->TOTAL
	ENDIF
	IF MODIFICABLE .OR. LEN(AXR) == 0
		AADD( AXR, AREG0( aCpo ) )
	ENDIF
	FTOTCOMPRA(.F.)
	
	RECUPAN()
	
	
	SETCOLOR(C_MENU)
	OX := MYABROWSE( 9, 1, 17, 78, aCpo, AXR, "AXR" )
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	IF MODIFICABLE
		OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
	ELSE
		OX:CARGO[TB_EDIT] := LOWER( OX:CARGO[TB_EDIT] )
	ENDIF
	
	
	MENUDOWN({" <+>   º    F2    º    F3    º     %    º   TAB    º    F9    º   F10   º ESC  ",;
				 "       º          º  busca   º bonif.,  º  elegir  º  recalc. º graba y º      ",;
				 " mueve º modifica º producto º totales  º producto º importes º  sale   º sale "})
	
	ATOT := NEWEDIT2( "COMPRA2",,.F. )
	FVERREG( ATOT,, .T. )
	
	guardar = .F.
	DO WHILE .T.
		
		MOVABROW( OX, AXR, {|| nK==K_TAB.OR.nK==37.OR.nK==K_ESC.OR.nK==K_F7.OR.nK==K_F3.OR.nK==K_F10.OR.nK==K_F9},;
			{||nK==999} )
		
		IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB .OR. OX:Cargo[TB_RET] == K_F3 ) .AND. MODIFICABLE
			IF TBNOC(OX) $ "CODPROD XCANT PRECBASE IMPORTE BONIF RECARGO"
				M->TPRECBASE -= AXR[NROW,RG_IMPORTE]
				M->TIMPINT   -= AXR[NROW,RG_TIMPINT]
				M->TRECARGO  -= AXR[NROW,RG_RECARGO]
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
     			aux := FPRODUCTO( AXR[NROW,RG_CODPROD] )
					AXR[NROW,RG_TIPOIMPINT] := FTIPOIMPINT
					AXR[NROW,RG_GRUPO   ] := NGRUPO
					AXR[NROW,RG_DESCPROD] := aux
*					AXR[NROW,RG_PRECBASE] := FPRECCOMPRA
					AXR[NROW,RG_PRECBASE] := FNETOCOMPRA
					AXR[NROW,RG_UNXCAJA ] := NUNXCAJA
					AXR[NROW,RG_IMPINT  ] := FIMPINT
					AXR[NROW,RG_IVA     ] := (AXR[NROW,RG_PRECBASE]+AXR[NROW,RG_RECARGO]) * M->PIVA1 /100
					AXR[NROW,RG_PRECUNIT] := (AXR[NROW,RG_PRECBASE]+AXR[NROW,RG_RECARGO]) + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA]
					AXR[NROW,RG_CONIMPINT]:= NCONIMPINT
					AXR[NROW,RG_RECARGO ] := FRECARGO * AXR[NROW,RG_CANTIDAD]
				ELSEIF TBNOC(OX) == "PRECBASE"
					FPRODUCTO( AXR[NROW,RG_CODPROD] )
					AXR[NROW,RG_IMPINT  ] := FIMPINT
					AXR[NROW,RG_IVA     ] := (AXR[NROW,RG_PRECBASE]+AXR[NROW,RG_RECARGO]) * M->PIVA1 /100
					AXR[NROW,RG_PRECUNIT] := (AXR[NROW,RG_PRECBASE]+AXR[NROW,RG_RECARGO]) + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA]
 				ELSEIF TBNOC(OX) == "XCANT"
 					AXR[NROW,RG_CANTIDAD] := FCANT( AXR[NROW,RG_XCANT], AXR[NROW,RG_UNXCAJA] )
*					AXR[NROW,RG_PRECUNIT] := AXR[NROW,RG_IMPORTE] / AXR[NROW,RG_CANTIDAD]
				ELSEIF TBNOC(OX) == "IMPORTE"
					FPRODUCTO( AXR[NROW,RG_CODPROD] )
					AXR[NROW,RG_PRECUNIT] := AXR[NROW,RG_IMPORTE] / AXR[NROW,RG_CANTIDAD]
*					AXR[NROW,RG_PRECBASE] := FNETOVENTA( NGRUPO, AXR[NROW,RG_PRECUNIT], AXR[NROW,RG_CONIMPINT] )
					AXR[NROW,RG_PRECBASE] := AXR[NROW,RG_PRECUNIT] - AXR[NROW,RG_RECARGO]
					AXR[NROW,RG_IMPINT  ] := FIMPINT
					AXR[NROW,RG_IVA     ] := (AXR[NROW,RG_PRECBASE]+AXR[NROW,RG_RECARGO]) * M->PIVA1 /100
				ELSEIF TBNOC(OX) == "IMPORTE"
					FPRODUCTO( AXR[NROW,RG_CODPROD] )
					AXR[NROW,RG_PRECBASE] := FNETOVENTA( NGRUPO, AXR[NROW,RG_PRECUNIT], AXR[NROW,RG_CONIMPINT] )
					AXR[NROW,RG_IMPINT  ] := FIMPINT
					AXR[NROW,RG_IVA     ] := (AXR[NROW,RG_PRECBASE]+AXR[NROW,RG_RECARGO]) * M->PIVA1 /100
				ENDIF
				AXR[NROW,RG_CANTIDAD ] := FCANT( AXR[NROW,RG_XCANT], AXR[NROW,RG_UNXCAJA] )
				AXR[NROW,RG_TPRECBASE] := AXR[NROW,RG_PRECBASE ] * AXR[NROW,RG_CANTIDAD]
				AXR[NROW,RG_TIMPINT  ] := AXR[NROW,RG_IMPINT   ] * AXR[NROW,RG_CANTIDAD]
 				AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECBASE ] * AXR[NROW,RG_CANTIDAD]
*				AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECUNIT ] * AXR[NROW,RG_CANTIDAD]

				IF TBNOC(OX) == "BONIF"
           	M->PORCBON := AXR[NROW,RG_BONIF] / AXR[NROW,RG_TPRECBASE] * 100
           ELSE
           	AXR[NROW,RG_BONIF    ] := AXR[NROW,RG_TPRECBASE] * M->PORCBON / 100
           ENDIF
				IF !EMPTY(FGRUPO(AXR[NROW,RG_GRUPO]))
           	IF AXR[NROW,RG_CONIMPINT] # 0
						IF GR->TIPOIMPINT == "%"
							aux := AXR[NROW,RG_TPRECBASE] - AXR[NROW,RG_BONIF]
							AXR[NROW,RG_TIMPINT] := aux * FIMPINT2 / 100
							AXR[NROW,RG_IMPINT ] := AXR[NROW,RG_TIMPINT] / AXR[NROW,RG_CANTIDAD]
						ENDIF
              ENDIF
				ENDIF
				M->TPRECBASE += AXR[NROW,RG_IMPORTE]
				M->TIMPINT   += AXR[NROW,RG_TIMPINT]
				M->TRECARGO  += AXR[NROW,RG_RECARGO]
				FTOTCOMPRA()
			ELSEIF TBNOC(OX) $ "DESCPROD" .AND. OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			FVERREG( ATOT,, .T. )
			OX:RefreshCurrent()
			
		ELSEIF OX:Cargo[TB_RET] == K_F9 .AND. MODIFICABLE
			M->TPRECBASE := M->TIMPINT := 0
			AEVAL( AXR, {|a,i|									;
				M->TPRECBASE += AXR[i,RG_IMPORTE],			;
				M->TRECARGO  += AXR[i,RG_RECARGO],			;
				M->TIMPINT   += AXR[i,RG_TIMPINT]			;
				} )
			FTOTCOMPRA()
			FVERREG( ATOT,, .T. )
			
		ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
			IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
				AADD( AXR, AREG0(aCpo) )
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F7
			IF PREGUNTA( 10, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
				DO LISTADOR WITH "COMPRA"
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == 37 .AND. MODIFICABLE				&&  %
			ATOT[ED_REGISTRO] := 0
			ATOT[ED_I] = 1
			ATOT[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR2( ATOT, {K_F10} )
				IF ATOT[ED_UPDATE]
					IF EDNOM(ATOT) $ "M->BONIF"
						M->PORCBON := M->BONIF / M->TPRECBASE * 100
					ELSEIF EDNOM(ATOT) $ "M->PORCBON"
						M->BONIF := M->TPRECBASE * M->PORCBON / 100
					ELSEIF EDNOM(ATOT) $ "M->FINANC"
						M->PORCFIN := M->FINANC / M->SUBTOTAL * 100
					ELSEIF EDNOM(ATOT) $ "M->TIVA1"
						M->PIVA1 := M->TIVA1 / M->SUBTOTAL2 * 100
					ELSEIF EDNOM(ATOT) $ "M->PORCPERC"
						M->PERCEPCION := M->SUBTOTAL2 * M->PORCPERC / 100
					ELSEIF EDNOM(ATOT) $ "M->PERCEPCION"
						M->PORCPERC := M->PERCEPCION / M->SUBTOTAL2 * 100
					ELSEIF EDNOM(ATOT) $ "M->IIBB"
						M->PORCIIBB := M->IIBB / (M->SUBTOTAL2+M->TIMPINT) * 100
					ELSEIF EDNOM(ATOT) $ "M->PORCIIBB"
						M->IIBB := (M->SUBTOTAL2+M->TIMPINT) * M->PORCIIBB / 100
					ENDIF
					FTOTCOMPRA(.F.,.T.)
					ATOT[ED_MODE] = "MOSTRARTODO"
				ELSEIF ( ATOT[ED_TECLA] == K_ENTER .AND. ATOT[ED_I] == LEN(ATOT[ED_EDIT]) ) .OR. ATOT[ED_TECLA] == K_F10
					FTOTCOMPRA(.F.)
					EXIT
				ELSEIF ATOT[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
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
	
	MENSAJE( 0, 0, 0, .F., "GRABANDO..." )
	IF guardar
		IF !NUEVO
				*** deja el Stock y la Orden de Provisi¢n como estaba
        IF ROPROVIS # 0
        	OP->(dbseek( str(ROPROVIS,10) ))
        	IF OP->OPROVIS#ROPROVIS;  ROPROVIS:=0;  ENDIF
        ENDIF
			SELECT CO2
 			SEEK STR(RCODPROV,FLEN(CO2->CODPROV)) + RNUMFAC
			SELECT PRD
			FFLOCK()
 			SET ORDER TO 1
 			DO WHILE CO2->CODPROV==RCODPROV .AND. CO2->NUMFAC==RNUMFAC .AND. !CO2->(EOF())
				SEEK CO2->CODPROD
        	IF FOUND() .AND. CO2->FECHA >= PRD->FECHA
 	         	PRD->COMPRAS  -= CO2->CANTIDAD
           	PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
				ENDIF
        	if OP2->( dbseek( str(ROPROVIS,10)+str(CO2->CODPROD) ) )
           	frlock("OP2")
 					OP2->CANTUSADO -= CO2->CANTIDAD
              OP2->(dbunlock())
           ENDIF
				SKIP 1 ALIAS CO2
			ENDDO
		ENDIF

		FFLOCK( "CO" )
		FFLOCK( "CO2" )
		SELECT CO                  &&.facturas.dbf
		IF NUEVO
			DBGOTOP()
*			IF ( CO->CODPROV#0 .AND. VAL(SUBSTR(CO->NUMFAC,6))#0 ) .OR. LASTREC()==0
			IF val(right(CO->NUMFAC,8))#0 .OR. LASTREC()==0
				ADD_REC()
			ENDIF
		ENDIF
     M->TRECARGO:=0;	AEVAL(AXR,{|a| M->TRECARGO+=a[RG_RECARGO]})
     EDX[ED_REGISTRO] := CO->(recno())
		FEDITOR( EDX, "GRABAR", .F. )
		FRLOCK()
		CO->TPRECBASE  := M->TPRECBASE
		CO->PORCBON    := M->PORCBON
		CO->BONIF      := M->BONIF
		CO->TRECARGO   := M->TRECARGO
		CO->TIMPINT    := M->TIMPINT
		CO->PORCFIN    := M->PORCFIN
		CO->FINANC     := M->FINANC
		CO->PORCIIBB   := M->PORCIIBB
		CO->IIBB       := M->IIBB
		CO->TIVA1      := M->TIVA1
		CO->PORCPERC   := M->PORCPERC
		CO->PERCEPCION := M->PERCEPCION
		CO->TOTAL      := M->TOTAL

		M->CARGAS := - M->BONIF + M->TIMPINT + M->TIVA1 + M->PERCEPCION + M->FINANC
		SELECT CO2
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
					IF !empty(CO2->NUMFAC) .OR. LASTREC()==0
						ADD_REC()
					ENDIF
				ENDIF
				FRLOCK()
           CO2->FECHA    := AX_FECHA
				CO2->CODPROV  := AX_CODPROV
				CO2->NUMFAC   := AX_NUMFAC
				CO2->CODPROD  := AXR[i,RG_CODPROD]
				CO2->CANTIDAD := AXR[i,RG_CANTIDAD]
				CO2->XCANT    := AXR[i,RG_XCANT]
				CO2->UNXCAJA  := AXR[i,RG_UNXCAJA]
				CO2->DESCPROD := AXR[i,RG_DESCPROD]
				CO2->PRECBASE := AXR[i,RG_PRECBASE]
				CO2->IMPINT   := AXR[i,RG_IMPINT]
				CO2->BONIF    := AXR[i,RG_BONIF]
				CO2->RECARGO  := AXR[i,RG_RECARGO]
				CO2->PRECUNIT := AXR[i,RG_PRECUNIT]
				CO2->IMPORTE  := AXR[i,RG_IMPORTE]
           **********************
           nporc := AXR[i,RG_IMPORTE] * 100 / M->TPRECBASE
				CO2->PFCOMPRA := CO2->IMPORTE + ( M->CARGAS * nporc / 100 )
           **********************
			ENDIF
		NEXT

			*** actualiza el Stock y la Orden de Provisi¢n
		SELECT PRD
 		SET ORDER TO 1
		FFLOCK()
		FOR i=1 TO LEN(AXR)
			IF AXR[i,RG_IMPORTE] # 0
				SEEK AXR[i,RG_CODPROD]
        	IF FOUND() .AND. AX_FECHA >= PRD->FECHA
 	         	PRD->COMPRAS  += AXR[i,RG_CANTIDAD]
           	PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
           ENDIF
        	if OP2->(dbseek( str(AX_OPROVIS,10)+str(AXR[i,RG_CODPROD],flen(OP2->CODPROD)) ))
     			frlock("OP2")
           	OP2->CANTUSADO += AXR[i,RG_CANTIDAD]
     			OP2->(dbunlock())
           ENDIF
			ENDIF
		NEXT i
			***

			*** actualiza los precios de compra
		SELECT PRD
		FFLOCK()
 		FOR i=1 TO LEN(AXR)
 			IF AXR[i,RG_PRECBASE] > 0
 				SEEK AXR[i,RG_CODPROD]
 				IF FOUND()
 					PRD->NETOCOMPRA :=  AXR[i,RG_PRECBASE]
           	aux := AXR[NROW,RG_BONIF] / AXR[NROW,RG_TPRECBASE] * 100
 					PRD->PRECCOMPRA :=  AXR[i,RG_PRECBASE] - (AXR[i,RG_PRECBASE]*aux/100)
              IF AXR[i,RG_CANTIDAD] # 0
              	PRD->RECARGO :=  AXR[i,RG_RECARGO] / AXR[i,RG_CANTIDAD]
              ENDIF
 				ENDIF
        ENDIF
 		NEXT
     	***
		DBUNLOCKALL()
		DBCOMMITALL()
	ENDIF
	
	RECUPAN()
	
ENDDO

RETURN


**********************

STATIC FUNC FTOTCOMPRA(_conrec,lreciva)

**********************
DEFAULT _conrec TO .T.

IF _conrec
	lreciva := .T.
ELSE
	IF lreciva == NIL
  	lreciva := .F.
  ENDIF
ENDIF

*M->BONIF     := M->TPRECBASE * M->PORCBON / 100
IF _conrec
	M->BONIF:=0 ;  AEVAL( AXR,{|a,i| M->BONIF+=a[RG_BONIF]} )
ENDIF
M->SUBTOTAL   := M->TPRECBASE + M->TRECARGO - M->BONIF
M->FINANC     := M->SUBTOTAL * M->PORCFIN / 100
M->SUBTOTAL2  := M->SUBTOTAL + M->FINANC
IF lreciva
	M->TIVA1      := M->SUBTOTAL2 * M->PIVA1 / 100
ENDIF
M->PERCEPCION := M->SUBTOTAL2 * M->PORCPERC / 100
M->IIBB       := (M->SUBTOTAL2+M->TIMPINT) * M->PORCIIBB / 100
M->TOTAL      := M->SUBTOTAL2 + M->TIMPINT + M->TIVA1 + M->PERCEPCION + M->IIBB

RETURN M->TOTAL


*************************
FUNC FCANT( _cant, _uxc )
*************************

RETURN VAL(_cant) * IF("C"$_cant.OR."c"$_cant, IF(_uxc==0,1,_uxc), 1 )


***********************

FUNC LISTCOM( listado )

***********************
LOCAL nOrder, nReg
#define    lxp		60

	IF listado $ "COMPRAS PERCIIBB"
		IF QUEFECHA2( 10, 30 )
			SETIMPRESORA( "INI", listado)
			DO ICARGA WITH listado
			FBASES({"PROVEE","COMPRAS"},.F.)
        SELECT CO
        nReg:=RECNO()
        nOrder := INDEXORD()
        SET ORDER TO FORDER({"FECHA","CODPROV"})
			nBONIF      := 0
			nTPRECUNIT  := 0
			nTIMPORTE   := 0
        nTRECARGO   := 0
			nTPRECBASE  := 0
			nTIMPINT    := 0
			nTIVA1      := 0
			nPERCEPCION := 0
			nFINANC     := 0
			nIIBB       := 0
			nTOTAL      := 0
        nPERCIIBB   := 0
        nPERCIVA    := 0
        nCant:=0
        bCond := IF( listado=="COMPRAS",{||.T.},{|| CO->IIBB#0})
        DBSEEK(FTOC(DESDE),.T.)
        DO WHILE CO->FECHA>=DESDE .AND. CO->FECHA<=HASTA .AND. !CO->(EOF())
           IF CO->TOTAL # 0 .AND. EVAL(bCond)
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
              ****
					nBONIF      += CO->BONIF
					nTPRECUNIT  += CO->TPRECUNIT
					nTIMPORTE   += CO->TIMPORTE
					nTRECARGO   += CO->TRECARGO
					nTPRECBASE  += CO->TPRECBASE
					nTIMPINT    += CO->TIMPINT
					nTIVA1      += CO->TIVA1
					nPERCEPCION += CO->PERCEPCION
					nFINANC     += CO->FINANC
					nIIBB       += CO->IIBB
					nTOTAL      += CO->TOTAL
        		nPERCIIBB   += CO->PERCIIBB
        		nPERCIVA    += CO->PERCIVA
              ++nCant
              ****
           ENDIF
				SKIP
			ENDDO
			CABEZA( 3 )
			I_CL += 3
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+2)
			? I_esp + ARMOLIN(I_cab)
        SELECT CO
        SET ORDER TO 1
        GO nReg
			RECUPAN()
     ENDIF

	ELSEIF listado == "PROVEE"
     seleCT PRV
     nReg := RECNO()
		SETIMPRESORA( "INI", listado)
		DO ICARGA WITH listado
     GO TOP
  	DO WHILE !EOF()
        IF !EMPTY(PRV->RAZONSOC)
				CABEZA( 1 ); ++I_CL
				? I_esp + ARMOLIN(I_cab+1)
        ENDIF
        SKIP
  	ENDDO
     GO nReg
  	RECUPAN()

	ELSEIF listado == "DCOMXPRD"
  	IF MARCARPROD()
			IF QUEFECHA2( 10, 30 )
				MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
				FBASES({"COMPRAS2"})
				SELECT 99; 		DBCLOSEAREA()
				base = XNAME("XAUX")
				CREARBASE( base, 'CODPROD N 5 0', 'DESCPROD C 30', 'RUBRO N 2',;
					'CANTIDAD N 11 3', 'NUMFAC C 13', 'FECHA D 8', 'IMPORTE N 10 2' )
				USE (base) ALIAS X EXCLUSIVE
				INDEX ON STR(X->CODPROD)+DTOS(X->FECHA) TO (base)
           SELECT PRD
           GO TOP
           SELECT X
           APPEND FROM PROD FOR MARCA==''
				SELECT CO2
           SET ORDER TO
           LOCATE FOR CO2->FECHA >= DESDE
				SELECT X
           DO WHILE !CO2->(EOF())
					IF CO2->FECHA>=DESDE .AND. CO2->FECHA<=HASTA
						DBSEEK( STR(CO2->CODPROD), .T. )
                 IF CO2->CODPROD == X->CODPROD
							IF !DBSEEK( STR(CO2->CODPROD)+DTOS(CO2->FECHA) )
                 		APPEND BLANK
                    	X->CODPROD  := CO2->CODPROD
                       X->DESCPROD := CO2->DESCPROD
                    	X->FECHA    := CO2->FECHA
                    	X->NUMFAC   := CO2->NUMFAC
                 	ENDIF
							X->CANTIDAD += CO2->CANTIDAD
							X->IMPORTE  += CO2->PFCOMPRA
                 ENDIF
					ENDIF
              @ 24, 73 SAY CO2->(LASTREC())-CO2->(RECNO()) PICT "99999"
					SKIP 1 ALIAS CO2
           ENDDO
           RECUPAN()
           ***************************
     		I_SETON  := CHR(27)+"G"
     		I_SETOFF := CHR(27)+"H"
     		IF EST->SALIDA == "PAN"
     			I_SETON  := ""
     			I_SETOFF := ""
     		ENDIF
  			SELECT X
     		SETIMPRESORA("INI","DCOMXPRD")
     		GO TOP
     		M->TOTAL := M->TTOTAL := cant := tcant := aux := 0
    			baux := {|| AADD(aaux, "Fecha    Factura       Litros    "),;
              			AADD(aaux, "======== ============= ==========") }
     		aaux:={}; EVAL(baux)
           aux := 0
     		DO WHILE !EOF()
           	IF X->CANTIDAD # 0
     				IF aux # X->CODPROD
        				IF aux # 0
        					IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF		//
              			AADD( aaux, I_SETON+PADL("("+ALLTRIM(STR(cant))+") "+STR(M->TOTAL,10,2),LEN(aaux[1]),' ')+I_SETOFF )
           			ENDIF
        				IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF			//
     					AADD( aaux, SPACE(LEN(aaux[1])) )
        				IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF			//
     					AADD( aaux, I_SETON+ JUSTIF(ALLTRIM(STR(X->CODPROD))+")"+FPROD(X->CODPROD),LEN(aaux[1]),"="," ") +I_SETOFF )
           			aux := X->CODPROD
        				M->TOTAL := cant := 0
        			ENDIF
        			IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF				//
     				AADD( aaux, DTOC(X->FECHA) +" "+ X->NUMFAC +" "+ STR(X->CANTIDAD,10,2) )
        			M->TOTAL  += X->CANTIDAD; ++cant
        			M->TTOTAL += X->CANTIDAD; ++tcant
              ENDIF
					SKIP
     		ENDDO
     		IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF					//
           AADD( aaux, I_SETON+PADL("("+ALLTRIM(STR(cant))+") "+STR(M->TOTAL,10,2),LEN(aaux[1]),' ')+I_SETOFF )
				i := 0
     		DO WHILE i<=LEN(aaux)
     			? CHR(27)+CHR(77)+CHR(15)
     			?
 					? "      COMPRAS X PRODUCTO"
 					? "      =================="
 					? "      DESDE:", DESDE
 					? "      HASTA:", HASTA
        		?
     			FOR h=1 TO lxp
           		aux:=""
        			FOR x=0 TO 3
        				aux += IF( (i+h)+x*lxp<=LEN(aaux), "     "+aaux[(i+h)+x*lxp], "" )
        			NEXT
           		IF !EMPTY(aux); ? aux; ENDIF
     			NEXT
        		?; ?; ?; ?
        		i += lxp*4
     		ENDDO
     		DBCLOSEAREA()
				I_LMAS = 0
				I_CIERRE := .F.
     		I_IMPRIMIO := .T.
     		RECUPAN()
			ENDIF
     ENDIF

	ELSEIF listado == "COMXPRD"
  	IF MARCARPROD()
			lAux := QUEFECHA2( 10, 30 )
        if lAux
				op3 = MENUFLASH( ym2+2, xm2-2, 1, .F., "", "Inclu¡r Ajustes(LAP)", "NO Inclu¡r Ajustes  " )
        	lAux := (lastkey()==K_ENTER)
			endif
        if lAux
				MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
				FBASES({"COMPRAS2","AJUSTES"})
				SELECT 99; 		DBCLOSEAREA()
				base = XNAME("XAUX")
				CREARBASE( base, 'CODPROD N 5 0', 'DESCPROD C 30', 'RUBRO N 2', 'BONIF N 10 2',;
					'CANTIDAD N 10 1', 'PRECBASE N 10 2', 'IMPINT N 10 2', 'IVA N 10 2',;
					'CAPACIDAD N 10 3', 'IMPORTE N 10 2' )
				USE (base) ALIAS X EXCLUSIVE
				INDEX ON X->CODPROD TO (base)
           SELECT PRD
           GO TOP
           SELECT X
           DO WHILE !PRD->(EOF())
           	IF PRD->MARCA == ""
           		APPEND BLANK
              	X->CODPROD   := PRD->CODPROD
              	X->DESCPROD  := PRD->DESCPROD
              	X->RUBRO     := PRD->RUBRO
                 X->CAPACIDAD := PRD->CAPACIDAD
              ENDIF
           	SKIP 1 ALIAS PRD
           ENDDO
				SELECT X
           GO TOP
				SELECT CO2
				SET ORDER TO 2
           DO WHILE !X->(EOF())
					DBSEEK( STR(X->CODPROD)+FTOC(DESDE),.T. )
					DO WHILE CO2->CODPROD==X->CODPROD .AND. CO2->FECHA>=DESDE .AND. CO2->FECHA<=HASTA
						X->CANTIDAD += CO2->CANTIDAD
						X->PRECBASE += CO2->PRECBASE
  					X->IMPINT   += CO2->IMPINT
                 X->BONIF    += CO2->BONIF
						X->IMPORTE  += CO2->PFCOMPRA
						SKIP 1 ALIAS CO2
					ENDDO
           	SKIP 1 ALIAS X
           ENDDO
           IF op3==1
           	select X
           	GO TOP
					SELECT AJ
					SET ORDER TO 2
           	DO WHILE !X->(EOF())
						DBSEEK( STR(X->CODPROD)+FTOC(DESDE),.T.)
						DO WHILE AJ->CODPROD==X->CODPROD .AND. AJ->FECHA>=DESDE .AND. AJ->FECHA<=HASTA
                 	IF AJ->CODCONC=="LAP"
                    	IF PRD->(dbseek(AJ->CODPROD))
									X->CANTIDAD += AJ->CANTIDAD
*							X->PRECBASE += AJ->PRECBASE
* 						X->IMPINT   += AJ->IMPINT
*                	X->BONIF    += AJ->BONIF
 									X->IMPORTE  += (PRD->PRECCOMPRA*AJ->CANTIDAD)
                       ENDIF
							ENDIF
							SKIP 1 ALIAS AJ
						ENDDO
           		SKIP 1 ALIAS X
           	ENDDO
           endif

           SELECT X
				INDEX ON STR(X->RUBRO)+STR(X->CODPROD) TO &base
				RECUPAN()
				SETIMPRESORA( "INI", listado)
				DO ICARGA WITH listado
				GO TOP
           I_I := -1
				STORE 0 TO M->TCANTIDAD, M->TBONIF, M->TIMPINT, M->TIMPORTE, M->TLITROS
				STORE 0 TO M->TTCANTIDAD, M->TTBONIF, M->TTIMPINT, M->TTIMPORTE
           M->TCANTIDAD := 0
				DO WHILE !EOF() .AND. !SALIR()
           	IF X->CANTIDAD # 0
           		IF I_I # X->RUBRO
              		IF !I_INI
								CABEZA( 2 )
								I_CL += 2
								? I_esp + STRTRAN(ARMOLIN(I_cab),"=","-")
								? I_esp + ARMOLIN(I_cab+2)
                 	ENDIF
							CABEZA( 2 )
							I_CL += 2
              		?
              		? I_esp + FVECTOR(vrubro,X->RUBRO)
           			I_I := X->RUBRO
							STORE 0 TO M->TCANTIDAD, M->TBONIF, M->TIMPINT, M->TIMPORTE, M->TLITROS
              	ENDIF
						CABEZA( 1 )
						I_CL = I_CL + 1
						? I_esp + ARMOLIN(I_cab+1)
           		M->TCANTIDAD  += X->CANTIDAD
						M->TBONIF     += X->BONIF
						M->TIMPINT    += X->IMPINT
						M->TIMPORTE   += X->IMPORTE
           		M->TTCANTIDAD += X->CANTIDAD			//
						M->TTBONIF    += X->BONIF				//
						M->TTIMPINT   += X->IMPINT          //
						M->TTIMPORTE  += X->IMPORTE         //
                 M->TLITROS    += X->CANTIDAD*IF(X->CAPACIDAD==0,1,X->CAPACIDAD)
              ENDIF
					SKIP
				ENDDO
				CABEZA( 6 )
				I_CL += 6
				? I_esp + STRTRAN(ARMOLIN(I_cab),"=","-")
				? I_esp + ARMOLIN(I_cab+2)
				?
				? I_esp + ARMOLIN(I_cab)
				? I_esp + ARMOLIN(I_cab+3)
				? I_esp + ARMOLIN(I_cab)
				RECUPAN()
			ENDIF
     ENDIF
  ENDIF
		
RETURN nil


************************

STATIC FUNC PRORRATEAR()

************************
local nReg:=CO->(recno())
MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
#define RG_CODPROD         1
#define RG_CANTIDAD        2
#define RG_PRECBASE        3
#define RG_IMPINT          4
#define RG_BONIF           5
#define RG_RECARGO         6
#define RG_FINANC          7
#define RG_ESEXENTO        8
#define RG_IVA1            9
#define RG_PERCEPCION     10
#define RG_IIBB           11
#define RG_TOTAL          12
#define RG_REGISTRO       13

select CO
set order to forder({"FECHA"})
dbseek(ftoc(DESDE),.T.)
do while ROSCA() .and. CO->FECHA>=DESDE .and. CO->FECHA<=HASTA .and. !CO->(eof())
 	AXR:={}
  CO2->( dbseek(str(CO->CODPROV)+CO->NUMFAC) )
  do while ROSCA() .and. (CO2->CODPROV==CO->CODPROV .and. CO2->NUMFAC==CO->NUMFAC) .and. !CO2->(eof())
     nPRECBASE   := CO2->PRECBASE * CO2->CANTIDAD
     nIMPINT     := CO2->IMPINT * CO2->CANTIDAD
     nBONIF      := nPRECBASE * CO->PORCBON / 100
		nSUBTOTAL   := nPRECBASE + CO2->RECARGO - nBONIF
		nFINANC     := nSUBTOTAL * CO->PORCFIN / 100
		nSUBTOTAL2  := nSUBTOTAL + nFINANC
		nIVA1       := nSUBTOTAL2 * VA->PIVA1 / 100
		nPERCEPCION := nSUBTOTAL2 * CO->PORCPERC / 100
		nIIBB       := (nSUBTOTAL2+nIMPINT) * CO->PORCIIBB / 100
		nTOTAL      := nSUBTOTAL2 + nIMPINT + nIVA1 + nPERCEPCION + nIIBB

		aadd(AXR,array(RG_REGISTRO))
		NROW := len(AXR)
     aeval( AXR[NROW], {|a,x| AXR[NROW,x]:=0} )
     AXR[NROW,RG_CODPROD   ] := CO2->CODPROD
     AXR[NROW,RG_CANTIDAD  ] := CO2->CANTIDAD
     AXR[NROW,RG_RECARGO   ] := CO2->RECARGO
     AXR[NROW,RG_PRECBASE  ] := nPRECBASE
     AXR[NROW,RG_IMPINT    ] := nIMPINT
     AXR[NROW,RG_BONIF     ] := nBONIF
     AXR[NROW,RG_FINANC    ] := nFINANC
     AXR[NROW,RG_ESEXENTO  ] := 1
     AXR[NROW,RG_IVA1      ] := nIVA1
     AXR[NROW,RG_PERCEPCION] := nPERCEPCION
     AXR[NROW,RG_IIBB      ] := nIIBB
     AXR[NROW,RG_TOTAL     ] := nTOTAL
     AXR[NROW,RG_REGISTRO  ] := CO2->(recno())
     skip 1 alias CO2
	enddo
  cAux := ""
  if int(ASUMA(AXR,RG_PRECBASE)) # int(CO->TPRECBASE)
  	cAux += " precbase"
  endif
  if int(ASUMA(AXR,RG_IMPINT)) # int(CO->TIMPINT)
		cAux += " imp.int"
		for i=1 to LEN(AXR)
 			nPorcentaje := AXR[i,RG_PRECBASE] * 100 / if(CO->TPRECBASE==0,1,CO->TPRECBASE)
			AXR[i,RG_IMPINT] := CO->TIMPINT * nPorcentaje / 100
        CO2->(dbgoto(AXR[i,RG_REGISTRO]))
        frlock("CO2")
        CO2->IMPINT := AXR[i,RG_IMPINT] / AXR[i,RG_CANTIDAD]
        CO2->(dbunlock())
		next
  endif
  if int(ASUMA(AXR,RG_FINANC)) # int(CO->FINANC)
  	nAux := int(ASUMA(AXR,RG_FINANC))
		cAux += " financ"
  endif
  if int(ASUMA(AXR,RG_PERCEPCION)) # int(CO->PERCEPCION)
  	cAux += " percep"
  endif
  if int(ASUMA(AXR,RG_TOTAL)) # int(CO->TOTAL)
  	cAux += " total"
  endif
	if int(ASUMA(AXR,RG_BONIF)) # int(CO->BONIF)
  	cAux += " bonif"
  endif
  if int(ASUMA(AXR,RG_RECARGO)) # int(CO->TRECARGO)
  	cAux += " recargo"
  endif
	if int(ASUMA(AXR,RG_IVA1)) # int(CO->TIVA1)
  	cAux += " iva1"
  endif
  if int(ASUMA(AXR,RG_IIBB)) # int(CO->IIBB)
  	cAux += " iibb"
  endif
  if !empty(cAux)
  	? str(CO->CODPROV)+" "+CO->NUMFAC+cAux
  endif
	skip 1 alias CO
  @ 24,70 say CO->(lastrec())-CO->(recno()) pict "######"
enddo
select CO
set order to 1
go nReg
RECUPAN()

return

************************
STATIC FUNC ASUMA(AXR,n)
************************
local nAux:=0

for i=1 to len(AXR)
	nAux += AXR[i,n]
next
*aeval( aa, {|a,i| nAux+=aa[n]} )

return nAux


**********************

FUNC FNUMFAC( cCual )

**********************
local cTipo:=cSuc:=cNum1:=cNum2:="", cAux

aaux:={""}
n1 := 1
cCual := upper(alltrim(cCual))
for i=1 to len(cCual)
	cAux := substr(cCual,i,1)
  if cAux $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  	cTipo += cAux
  elseif cAux $ "0123456789"
     aaux[n1]  += cAux
  else
  	if aaux[n1]#""
     	aadd(aaux,"")
  		++n1
     endif
  endif
next
for i=1 to 3
	if len(aaux)<i
  	aadd(aaux,"")
  endif
next
cSuc := aaux[1]
cNum1 := aaux[2]
cNum2 := aaux[3]
if val(cNum1) == 0 .and. val(cNum2) # 0
	cNum1 := cNum2
endif
if val(cNum1) == 0 .and. val(cSuc) # 0
	cNum1 := cSuc
  cSuc  := '0000'
endif
if val(cNum2) == 0
	cNum2 := cNum1
endif
cSuc  := strzero(val(cSuc),4)
cNum1 := strzero(val(cNum1),8)
cAux := alltrim(str(val(cNum2)))
cNum2 := left(cNum1,8-len(cAux)) + cAux

return { cTipo, cSuc, cNum1, cNum2 }
