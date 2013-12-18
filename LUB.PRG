#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PRIVATE APLA, aCPO

LOGO(.T., " LUBRICENTRO ")
MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
FBASES({ "LUB", "LUB2", "MODU", "EMPLEADO" }, .F.)

RG_CODPROD   :=  1
RG_SURTIDOR  :=  2
RG_DESCPROD  :=  3
RG_CANTXMOD  :=  4
RG_CANTOTAL  :=  5
RG_CANTIDAD  :=  6
RG_IMPORTE   :=  7
RG_PRECBASE  :=  8
RG_IMPINT    :=  9
RG_IVA       :=  10
RG_PRECUNIT  :=  11
RG_TPRECBASE :=  12
RG_TIMPINT   :=  13
RG_TIVA      :=  14
RG_REGISTRO  :=  15

aCpo:={	                                                                      ;
	{ "CODPROD",    "Prod",                               '', 'M',  '',  0, 0 },;
	{ "SURTIDOR",   "Su",                                 '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n",         REPLICATE("X",21), 'E',  '',  0, 0 },;
	{ "CANTXMOD",   "Cant.x;M¢dulo",                      '', 'M',  '',  0, 0 },;
	{ "CANTOTAL",   "Cant.;Total",                        '', 'M',  '',  0, 0 },;
	{ "CANTIDAD",   "Agregado",                           '', 'E',  '',  0, 0 },;
	{ "IMPORTE",    "Importe",                            '', 'F', 'N', 10, 3 },;
	{ "PRECBASE",   "",                                   '',  '',  '',  0, 0 },;
	{ "IMPINT",     "",                                   '',  '',  '',  0, 0 },;
	{ "IVA",        "",                                   '',  '',  '',  0, 0 },;
	{ "PRECUNIT",   "",                                   '',  '',  '',  0, 0 },;
	{ "TPRECBASE",  "",                                   '',  '', 'N', 10, 5 },;
	{ "TIMPINT",    "",                                   '',  '', 'N', 10, 5 },;
	{ "TIVA",       "",                                   '',  '', 'N', 10, 5 },;
	{ "REGISTRO",   "",                                   '',  '', 'N',  0, 0 } }

aSurt := {}
IF FILE("SURTIDOR.ARR")
  aSurt := STOA(MEMOREAD("SURTIDOR.ARR"))
ENDIF
SELECT LU2
aCpo := FARRAYAUX( aCpo )
SELECT LU
DBGOBOTTOM()

SETCOLOR(C_GET)
SET(_SET_INTENSITY,.T.)

MODIFICABLE = .F.
NUEVO = .F.
APLA      := NEWEDIT( "LUB1",,.T. )
AX_FECHA  := ASCAN( APLA[ED_FIELDS], "LU->FECHA" )
AX_TURNO  := ASCAN( APLA[ED_FIELDS], "LU->TURNO" )
AX_NUMPARTE := ASCAN( APLA[ED_FIELDS], "LU->NUMPARTE" )
auxaux    := APLA[ED_EDIT]
RECUPAN()

DO WHILE .T.
	F10 := .F.
	
	RELLENAPAN( 9, 0, 21, 80, "°", C_FONDO )
	SELECT LU
	MENUDOWN({"    TAB    º    F2    º   F5   º  Alt F6  º    F7    º  ENTER   º ESC  ",;
				 " lista de  º          º        º elimina  º          º          º      ",;
				 " planillas º modifica º agrega º planilla º listados º confirma º sale "})
	NUEVO = .F.
	lSalir = .F.
	APLA[ED_EDIT] := auxaux
	DO WHILE !lSalir
		k := FVERREG( APLA, {|K|K==9.OR.K==-4.OR.K==K_ALT_F6.OR.K==13.OR.K==-1.OR.K==-9.OR.K==K_F7} )
		IF K == K_ENTER
			MODIFICABLE = .F.
			NUEVO = .F.
			lSalir := EDCONT(APLA,"LU->NUMPARTE")#0
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
				APLA[ED_CONT,AX_FECHA]    := VA->FECHA
				APLA[ED_CONT,AX_TURNO]    := ' '
				APLA[ED_CONT,AX_NUMPARTE] := ULTIMO("LU","LU->NUMPARTE",1)+1
				NUEVO := .T.
			ENDIF
			APLA[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( APLA, { 9, K_F10 } )
				IF APLA[ED_UPDATE] .OR. APLA[ED_TECLA] == K_TAB
					APLA[ED_MODE] = "MOSTRARTODO"
					IF EDNOM(APLA) == "LU->TURNO" .AND. APLA[ED_TECLA] == K_TAB
						ele = PP_SELEC( APLA[ED_Y], APLA[ED_X], 0, 0, aturno, EDCONT(APLA), "", "S", .T., .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(APLA,,LEFT(aturno[ele],1))
						ENDIF
						RECUPAN()
					ELSEIF EDNOM(APLA) == "LU->CODMOD"
 						IF APLA[ED_TECLA] == K_TAB
							IF FMODU( EDCONT(APLA,"LU->CODMOD"), .T. )
								EDPONE(APLA,"LU->CODMOD",MO->CODMOD)
                    ENDIF
                 ENDIF
						if empty(FMODU(EDCONT(APLA,"LU->CODMOD")))
							EDPONE(APLA,"LU->CANTIDAD",0)
							EDPONE(APLA,"LU->PRECXMOD",0)
                 else
							IF EDCONT(APLA,"LU->CANTIDAD")==0
								EDPONE(APLA,"LU->CANTIDAD",1)
                 	ENDIF
							EDPONE(APLA,"LU->PRECXMOD",MO->PRECXMOD)
                 endif
						EDPONE(APLA,"LU->TMODULO",EDCONT(APLA,"LU->PRECXMOD")*EDCONT(APLA,"LU->CANTIDAD"))
					ELSEIF EDNOM(APLA) $ "LU->CANTIDAD LU->PRECXMOD"
              	EDPONE(APLA,"LU->TMODULO",EDCONT(APLA,"LU->CANTIDAD")*EDCONT(APLA,"LU->PRECXMOD"))
					ELSEIF "CODEMP" $ EDNOM(APLA) .AND. APLA[ED_TECLA] == K_TAB
						IF FELEGIR("EMPLEADO", EDCONT(APLA)) # 0
							EDPONE(APLA,, EM->CODEMP)
						ENDIF
					ENDIF
					IF EDNOM(APLA) $ "LU->FECHA LU->TURNO" .AND. 1==2
              	SET ORDER TO FORDER({"FECHA","TURNO"})
						IF FREPEAT( FTOC(EDCONT(APLA,"LU->FECHA"))+EDCONT(APLA,"LU->TURNO"), APLA[ED_MODAPP] )
							MENSAJE( 0, 0, 10, .T., "FECHA Y TURNO REPETIDOS  !!!" )
                    EDPONE(APLA,,APLA[ED_LAST])
                    APLA[ED_TECLA] := 0
                 ENDIF
                 SET ORDER TO 1
              ENDIF
				ELSEIF ( APLA[ED_TECLA] == K_ENTER .AND. APLA[ED_I]==LEN(APLA[ED_EDIT]) ) .OR. APLA[ED_TECLA]==K_F10
*					FEDITOR( APLA, "LEER" )
					IF EMPTY(APLA[ED_CONT,AX_FECHA])
						MENSAJE( 0, 0, 10, .T., " FALTA FECHA !!!" )
					ELSEIF ASCAN( aturno, {|x| LEFT(x,1)==APLA[ED_CONT,AX_TURNO] } ) == 0
						MENSAJE( 0, 0, 10, .T., " FALTA TURNO !!!" )
					ELSE
						lSalir := EDCONT(APLA,"LU->NUMPARTE")#0
						EXIT
					ENDIF
				ELSEIF APLA[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			PONEPAN(xmenu)
		ELSEIF k == K_TAB
			private bcamp[14], bmasc[14], bcab[14], bedit
			bcamp[ 1] := "LU->NUMPARTE"
			bcamp[ 2] := "LU->FECHA"
			bcamp[ 3] := "LU->TURNO"
			bcamp[ 4] := "LU->TOTAL+LU->TMODULO"
			bcamp[ 5] := "LU->CODMOD"
			bcamp[ 6] := "LU->CANTIDAD"
			bcamp[ 7] := "LU->TOTAL"
			bcamp[ 8] := "LU->MARCA"
			bcamp[ 9] := "LU->PATENTE"
			bcamp[10] := "LU->KM"
			bcamp[11] := "LU->FECH_NAC"
			bcamp[12] := "LU->CODEMP1"
			bcamp[13] := "LU->APENOM"
			bcamp[14] := "LU->TELEFONO"
			afill(bmasc,"")
			bmasc[ 3] := "!!!!!!!!!!"
			bmasc[ 4] := "######.###"
			bcab[ 1] := "Parte"
			bcab[ 2] := "Fecha"
			bcab[ 3] := "Turno"
			bcab[ 4] := "Total"
			bcab[ 5] := "C¢d;Mod"
			bcab[ 6] := "Cantidad"
			bcab[ 7] := "Total"
			bcab[ 8] := "Marca"
			bcab[ 9] := "Patente"
			bcab[10] := "KM"
			bcab[11] := "Fecha;Nacim"
			bcab[12] := "C¢d;Empl"
			bcab[13] := "Apellido, Nombre"
			bcab[14] := "Tel‚fono"
			bedit = replic("F",len(bcamp))
			xmenu:=MENUDOWN({"  <+>  º  F3   º   F4   º  ENTER  º  ESC   ",;
								  "       º       º        º elige y º        ",;
								  " mueve º busca º busca+ º  sale   º  sale  "})
			select LU
			_lastreg = RECNO()
			BROW( 8, 1, 18, 78, "PARTES", bcamp, bmasc, bcab, bedit )
			if lastkey() # K_ENTER
				GO _lastreg
			endif
			RECUPAN()
			PONEPAN(xmenu)
		ELSEIF K == K_F7
			op1 := MENUFLASH( 10, 30, 1, .T.,"", "Ventas Lubricentro       ",;
															 "Ventas x Fecha Cumplea¤os",;
 															 "Ventas x Producto        " )
			IF op1 == 1
				LST_LUB("LUBRICEN")
        elseif op1 == 2
				LST_LUB("CUMPLEANO")
        elseif op1 == 3
				LST_LUB("LUBVEXPR")
        endif
		ELSEIF K == K_F10
			FEDITOR( APLA, "LEER" )
			F10 := .T.
			lSalir := EDCONT(APLA,"LU->NUMPARTE")#0
		ELSEIF K == K_ALT_F6
			IF PREGUNTA( 10, "¨ ESTAS SEGURO DE ELIMINAR  [ S / N ] ?","SsNn") $ "Ss"
				MENSAJE( 0, 0, 0, .F., " ELIMINANDO ..." )
				FEDITOR( APLA, "LEER" )
					*** 1§ deja el Stock como estaba
				SELECT LU2
				SEEK APLA[ED_CONT,AX_NUMPARTE]
				SELECT PRD
 				SET ORDER TO 1
				FFLOCK()
				DO WHILE LU2->NUMPARTE==APLA[ED_CONT,AX_NUMPARTE]
					SEEK LU2->CODPROD
        		IF FOUND() .AND. LU2->FECHA>=PRD->FECHA .AND. PRD->CONSURT#"S"
 	         		PRD->VENTAS -= LU2->CANTOTAL
           		PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
					ENDIF
					SKIP 1 ALIAS LU2
				ENDDO
					***
        	SELECT LU2
           SET ORDER TO 1
				DO WHILE DBSEEK( APLA[ED_CONT,AX_NUMPARTE] )
           	BLANKREG()
           ENDDO
           SELECT LU
          	BLANKREG()
           DBSEEK( APLA[ED_CONT,AX_NUMPARTE], .T. )
           RECUPAN()
        ENDIF
		ELSEIF K == K_ESC
			F10 := .F.
			lSalir:= .T.
		ENDIF
	ENDDO
	IF K == K_ESC
		EXIT
	ENDIF
	
	
	************************
	* Carga de la planilla *
	************************
	MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
	M->PIVA1 := ( VA->PIVA1 * .0001 / .0001 )
	M->PIVA2 := 0
	PRIVATE AXR := {}
	STORE 0 TO M->TIVA1, M->TIVA2, M->TOTAL, M->TPRECBASE, M->TIMPINT
	select LU2
	IF APLA[ED_CONT,AX_NUMPARTE]#0 .AND. DBSEEK( APLA[ED_CONT,AX_NUMPARTE] )
		NUEVO = .F.
		select LU2
		SEEK APLA[ED_CONT,AX_NUMPARTE]
		DO WHILE LU2->NUMPARTE == APLA[ED_CONT,AX_NUMPARTE]
			AADD( AXR, ARRAY( RG_REGISTRO ) )
			i := LEN(AXR)
			AXR[ i,RG_CODPROD  ] := FIELD->CODPROD
			AXR[ i,RG_SURTIDOR ] := FIELD->SURTIDOR
			AXR[ i,RG_DESCPROD ] := FIELD->DESCPROD
			AXR[ i,RG_CANTXMOD ] := FIELD->CANTXMOD
			AXR[ i,RG_CANTOTAL ] := FIELD->CANTOTAL
			AXR[ i,RG_CANTIDAD ] := FIELD->CANTIDAD
			AXR[ i,RG_PRECBASE ] := FIELD->PRECBASE
			AXR[ i,RG_IMPINT   ] := FIELD->IMPINT
			AXR[ i,RG_PRECUNIT ] := FIELD->PRECUNIT
			AXR[ i,RG_TPRECBASE] := AXR[i,RG_PRECBASE] * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_TIMPINT  ] := AXR[i,RG_IMPINT] * AXR[i,RG_CANTIDAD]
			AXR[ i,RG_IVA      ] := AXR[i,RG_PRECBASE] * M->PIVA1 / 100
			AXR[ i,RG_IMPORTE  ] := FIELD->IMPORTE
			AXR[i,RG_REGISTRO  ] := RECNO()
			M->TPRECBASE += AXR[i,RG_TPRECBASE]
			M->TIMPINT   += AXR[i,RG_TIMPINT]
			SKIP
		ENDDO
	ELSE
		NUEVO = .T.
     select MO
		if !empty(FMODU(EDCONT(APLA,"LU->CODMOD")))
			aModulo := STOA( MO->PRODUCTOS )
        for i=1 to len(aModulo)
				AADD( AXR, AREG0( aCpo ) )
				AXR[i,RG_CODPROD  ] := aModulo[i,1]
				AXR[i,RG_SURTIDOR ] := aModulo[i,2]
				AXR[i,RG_DESCPROD ] := FPRODUCTO(AXR[i,RG_CODPROD])
				AXR[i,RG_PRECBASE ] := FPRECBASE
				AXR[i,RG_IMPINT   ] := FIMPINT
				AXR[i,RG_IVA      ] := AXR[i,RG_PRECBASE] * M->PIVA1 /100
				AXR[i,RG_PRECUNIT ] := AXR[i,RG_PRECBASE] + AXR[i,RG_IMPINT] + AXR[i,RG_IVA]
          	AXR[i,RG_CANTXMOD] := aModulo[i,3]
           AXR[i,RG_CANTOTAL] := 0
				M->TPRECBASE  += AXR[i,RG_TPRECBASE]
				M->TIMPINT    += AXR[i,RG_TIMPINT]
     	next
     endif
     select LU
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
	
	aedits := TBCOLEDIT( "SETEAR", "LUBRICENT", OX, aedits )

	IF MODIFICABLE
		OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
     if empty(FMODU(EDCONT(APLA,"LU->CODMOD")))
     	OX:CARGO[TB_EDIT] := stuff(OX:CARGO[TB_EDIT],TBNUC(OX,"CANTXMOD"),1,"F")
     else
     	OX:CARGO[TB_EDIT] := stuff(OX:CARGO[TB_EDIT],TBNUC(OX,"CANTXMOD"),1,"M")
     endif
	ELSE
		OX:CARGO[TB_EDIT] := LOWER( OX:CARGO[TB_EDIT] )
	ENDIF
	TBCOLOR(OX)
	
	
	MENUDOWN({"    F2    º    F3    º    TAB   º   F10   º ESC  ",;
				 "          º  busca   º  elegir  º graba y º      ",;
				 " modifica º producto º producto º  sale   º sale "})
	
	guardar = .F.
  @ 20, 1 CLEAR TO 20,78
	DO WHILE .T.
		@ 20, 1 SAY "Agregado:"+trans(M->TOTAL,"#######.##")
		@ 20,30 SAY "Total M¢dulo:"+trans(EDCONT(APLA,"LU->TMODULO"),"#######.##")
		@ 20,60 SAY "Total:"+trans(EDCONT(APLA,"LU->TMODULO")+M->TOTAL,"#######.##")

		MOVABROW( OX, AXR, {||nK==K_TAB.OR.nK==37.OR.nK==K_ESC.OR.nK==K_F7.OR.nK==K_F3.OR.nK==K_F10.OR.nK==K_F9.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_SH_F6.OR.nK==K_ALT_E.OR.CHR(nK)$'Pp'},;
			{||nK==999} )
		
		IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET]==K_TAB .OR. OX:Cargo[TB_RET]==K_F3 ) .AND. MODIFICABLE
			IF TBNOC(OX) $ "CODPROD SURTIDOR CANTIDAD CANTXMOD CANTOTAL IMPORTE"
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
                 AXR[NROW,RG_CANTXMOD] := MO->CANTXMOD
                 AXR[NROW,RG_CANTIDAD] := MO->CANTXMOD
					ENDIF
				ENDIF
				IF TBNOC(OX) $ "CODPROD SURTIDOR"
					IF AXR[NROW,RG_CODPROD] == 0
						AXR[NROW,RG_CANTXMOD] := 0
						AXR[NROW,RG_CANTOTAL] := 0
						AXR[NROW,RG_CANTIDAD] := 0
					ENDIF
				ENDIF
           IF EDCONT(APLA,"LU->CODMOD") == 0
					AXR[NROW,RG_CANTXMOD] := 0
           ENDIF
				AXR[NROW,RG_CANTIDAD ] := AXR[NROW,RG_CANTOTAL] - AXR[NROW,RG_CANTXMOD]
           nCant := if( AXR[NROW,RG_CANTIDAD]<0, 0, AXR[NROW,RG_CANTIDAD] )
				AXR[NROW,RG_TPRECBASE] := AXR[NROW,RG_PRECBASE] * nCant
				AXR[NROW,RG_TIMPINT  ] := AXR[NROW,RG_IMPINT] * nCant
				AXR[NROW,RG_IMPORTE  ] := AXR[NROW,RG_PRECUNIT] * nCant
				M->TPRECBASE  += AXR[NROW,RG_TPRECBASE]
				M->TIMPINT    += AXR[NROW,RG_TIMPINT]
				FTOTALIZAR()
			ELSEIF TBNOC(OX) == "DESCPROD" .AND. OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			OX:RefreshCurrent()

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

		ELSEIF OX:Cargo[TB_RET] == K_ALT_E
			TBCOLEDIT( "CAMBIAR", "LUBRICANT", OX, aedits, "EDITS.EST" )
			
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
			I_TITULO = IF( F10, "DIARIA", SUBSTR(FARRAY(aturno,APLA[ED_CONT,AX_TURNO]+'-'),3) )
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
		SELECT LU2
		SEEK APLA[ED_CONT,AX_NUMPARTE]
		SELECT PRD
 		SET ORDER TO 1
		FFLOCK()
		DO WHILE LU2->NUMPARTE==APLA[ED_CONT,AX_NUMPARTE]
			SEEK LU2->CODPROD
        IF FOUND() .AND. LU2->FECHA>=PRD->FECHA .AND. PRD->CONSURT#"S"
 	         PRD->VENTAS -= LU2->CANTOTAL
           PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
			ENDIF
			SKIP 1 ALIAS LU2
		ENDDO
			***

		FFLOCK("LU")
		FFLOCK("LU2")
		SELECT LU
		IF !DBSEEK( APLA[ED_CONT,AX_NUMPARTE] )
			F_ALTA( {||LU->NUMPARTE#0} )
		ENDIF
     APLA[ED_REGISTRO] := recno()
		FEDITOR(APLA,"GRABAR",.F.)
     FRLOCK()
 		LU->TOTAL   := M->TOTAL
		SELECT LU2
		FOR i=1 TO LEN(AXR)
			IF empty(AXR[i,RG_DESCPROD])
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
					BLANKREG()
				ENDIF
			ELSEIF AXR[i,RG_CANTOTAL] # 0
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
				ELSE
					F_ALTA( {||LU2->NUMPARTE#0} )
				ENDIF
				FRLOCK()
				LU2->FECHA    := APLA[ED_CONT,AX_FECHA]
				LU2->TURNO    := APLA[ED_CONT,AX_TURNO]
           LU2->NUMPARTE := APLA[ED_CONT,AX_NUMPARTE]
				LU2->CODPROD   := AXR[ i,RG_CODPROD  ]
				LU2->SURTIDOR  := AXR[ i,RG_SURTIDOR ]
				LU2->DESCPROD  := AXR[ i,RG_DESCPROD ]
				LU2->CANTXMOD  := AXR[ i,RG_CANTXMOD ]
				LU2->CANTOTAL  := AXR[ i,RG_CANTOTAL ]
				LU2->CANTIDAD  := AXR[ i,RG_CANTIDAD ]
				LU2->PRECBASE  := AXR[ i,RG_PRECBASE ]
				LU2->IMPINT    := AXR[ i,RG_IMPINT   ]
				LU2->PRECUNIT  := AXR[ i,RG_PRECUNIT ]
				LU2->IVA       := AXR[ i,RG_IVA      ]
				LU2->IMPORTE   := AXR[ i,RG_IMPORTE  ]
			ENDIF
		NEXT

			*** actualiza el Stock
		SELECT PRD
 		SET ORDER TO 1
		FFLOCK()
		FOR i=1 TO LEN(AXR)
			IF !empty(AXR[i,RG_DESCPROD])
				SEEK AXR[i,RG_CODPROD]
        	IF FOUND() .AND. APLA[ED_CONT,AX_FECHA]>=PRD->FECHA .AND. PRD->CONSURT#"S"
					PRD->VENTAS += AXR[i,RG_CANTOTAL]
					PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
           ENDIF
			ENDIF
		NEXT i
     SELECT LU2

	ENDIF
 	DBUNLOCKALL()
 	DBCOMMITALL()
	RECUPAN()
	
ENDDO

RETURN


***************

STATIC FUNC FTOTALIZAR

***************

M->SUBTOTAL  := M->TPRECBASE
M->TIVA1     := M->SUBTOTAL * M->PIVA1 / 100
M->TIVA2     := M->SUBTOTAL * M->PIVA2 / 100
M->TOTAL     := M->SUBTOTAL + M->TIMPINT + M->TIVA1 + M->TIVA2
M->SUBTOTAL  := M->TOTAL - M->TIMPINT - M->TIVA1 - M->TIVA2

RETURN M->TOTAL


****************

FUNC FMODU(nCual, lBrowser )

****************
LOCAL nReg:=RECNO(), OX, aCpo, cBase:=DBF()
LOCAL AX, xmenu, xmenu2
DEFAULT nCual TO recno()
DEFAULT lBrowser TO .F.

SELECT MO
if !lBrowser
	if nCual>0 .and. nCual<=lastrec()
  	go nCual
     r := MO->DESCMOD
  else
  	r := ""
  endif
  select (cBase)
  return r
endif

aCpo:={;
		{ "CODMOD",        "C¢d",                           '', 'E',  '',  0, 0 },;
		{ "DESCMOD",       "Descripci¢n",                   '', 'E',  '',  0, 0 },;
 		{ "PRECXMOD",      "Precio",                        '', 'E',  '',  0, 0 }}

if nCual>0 .and. nCual<=lastrec()
  GO nCual
else
	go top
endif
xmenu:=MENUDOWN({"  <+>  º    F2    º   F5   º  F6   º  ENTER   º ESC  ",;
			  			"       º          º        º       º confirma º      ",;
						" mueve º modifica º agrega ºeliminaº elecci¢n º sale "})

SETCOLOR( "W/N,N/W" )
MARCO( 7, 1, 20, 78, "<< MODULOS >>", "D", .T., 0 )
OX := MYBROWSE( 7, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 0
nreg := RECNO()
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F8} )
	IF OX:Cargo[TB_MSGE] == "MODIF"
	ELSEIF OX:Cargo[TB_RET] == K_F2 .OR. OX:Cargo[TB_RET] == K_F5
		xmenu2:=MENUDOWN({"     º   F10   º  ESC   ",;
								"       º graba y º        ",;
								" mueve º procede º  sale  "})
		AX := NEWEDIT( "MODU",,.T. )
		FEDITOR( AX, "SETVARS", OX:CARGO[TB_RET],.F. )
     EDPONE(AX,"MO->CODMOD",RECNO())
		IF OX:Cargo[TB_RET]==K_F5
     	GO BOTTOM
        AX[ED_EDIT] := STUFF(AX[ED_EDIT],1,1,"M")
        EDPONE(AX,"MO->CODMODU",LASTREC()+1)
			aModulo := {}
     ELSE
			aModulo := STOA( MO->PRODUCTOS )
     ENDIF
		AX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( AX, { K_TAB, K_F10 } )
			IF AX[ED_UPDATE]
				AX[ED_MODE] = "MOSTRAR"
			ELSEIF AX[ED_TECLA] == K_TAB .OR. EDNOM(AX)=="MO->PRODUCTOS"
     		IF PMOD( aModulo, alltrim(EDCONT(AX,"MO->DESCMOD")) )
              EDPONE(AX,"MO->CANTPROD",len(aModulo))
           ENDIF
			ELSEIF AX[ED_TECLA] == K_ESC .OR. AX[ED_TECLA] == K_F10
				IF AX[ED_TECLA] == K_ESC
           	aux := "S"
					IF FEDITOR( aX, "HUBOCAMBIOS" )
						aux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
					ENDIF
           ELSE
           	aux :="G"
           ENDIF
           IF aux == "G"
					IF OX:Cargo[TB_RET]==K_F5
           		locate for empty(MO->DESCMOD)
              	if !found()
              		ADD_REC()
              	endif
           	ENDIF
     			EDPONE(AX,"MO->CODMOD",RECNO())
           	AX[ED_REGISTRO]:=RECNO()
					FEDITOR(AX,"GRABAR",.F.)
              FRLOCK()
					MO->PRODUCTOS := ATOS( aModulo )
              DBUNLOCK()
              EXIT
           ELSEIF aux == "S"
           	exit
				ENDIF
			ENDIF
		ENDDO
		FEDITOR(AX,"SACAPAN")
		MENUDOWN(xmenu2)
 		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_ESC
  	GO nreg
     EXIT
	ELSEIF OX:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
SELECT (cBase)
RECUPAN()
MENUDOWN(xmenu)
select (cBase)

RETURN ( OX:Cargo[TB_RET]==K_ENTER )


***********************

FUNC LST_LUB( listado )

***********************
LOCAL nOrder, nReg
#define    lxp		60

bLastErr := ErrorBlock()
bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
begin sequence

	IF listado $ "LUBVEXPR"
		IF QUEFECHA2( 10, 30 )
			LISTADOR( "INI" )
			DO ICARGA WITH listado
 			if !SETIMPRESORA("INI");  break(nil);  endif
        SELECT LU
        nReg:=RECNO()
        nOrder := INDEXORD()
        SET ORDER TO FORDER({"FECHA","TURNO"})
        dbseek(FTOC(DESDE),.T.)
        aaux := LU2->(dbstruct())
        cBaseAux:=xname('XAUX')
        select 99;  dbclosearea()
        dbcreate(cBaseAux,aaux)
        select 99
        use (cBaseAux) alias X exclusive
        index on X->CODPROD to (cBaseAux)

        do while LU->FECHA>=DESDE .and. LU->FECHA<=HASTA .and. !LU->(EOF())
           LU2->(dbseek( LU->NUMPARTE ))
           do while LU2->NUMPARTE==LU->NUMPARTE .and. !LU2->(eof())
        		if !dbseek(LU2->CODPROD)
           		append blank
              	X->CODPROD := LU2->CODPROD
           	endif
           	X->CANTXMOD += LU2->CANTXMOD
           	X->CANTOTAL += LU2->CANTOTAL
        		X->CANTIDAD += LU2->CANTIDAD
              X->IMPORTE  += LU2->IMPORTE
              skip 1 ALIAS LU2
           enddo
           skip 1 alias LU
        enddo
        nCant:=0
        M->CANTXMOD := 0
        M->CANTOTAL := 0
        M->CANTIDAD := 0
        M->IMPORTE  := 0
        GO TOP
        do while !eof()
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
        	M->CANTXMOD += X->CANTXMOD
        	M->CANTOTAL += X->CANTOTAL
        	M->CANTIDAD += X->CANTIDAD
           M->IMPORTE  += X->IMPORTE
				SKIP
			ENDDO
 			CABEZA( 2 )
 			I_CL += 2
 			? I_esp + ARMOLIN(I_cab)
 			? I_esp + ARMOLIN(I_cab+2)
        SELECT LU
        SET ORDER TO 1
        GO nReg
        RECUPAN()
			LISTADOR( "FIN" )
     ENDIF

	ELSEIF listado $ "LUBRICEN"
		IF QUEFECHA2( 10, 30 )
			LISTADOR( "INI" )
			DO ICARGA WITH listado
 			if !SETIMPRESORA("INI");  break(nil);  endif
        SELECT LU
        nReg:=RECNO()
        nOrder := INDEXORD()
        SET ORDER TO FORDER({"FECHA","TURNO"})
        nCant:=0
        DBSEEK(FTOC(DESDE),.T.)
			M->TMODULO := 0
			M->TOTAL   := 0
        M->CANTIDAD := 0
        DO WHILE LU->FECHA>=DESDE .AND. LU->FECHA<=HASTA .AND. !LU->(EOF())
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
				M->TMODULO += LU->TMODULO
				M->TOTAL   += LU->TOTAL
        	M->CANTIDAD += LU->CANTIDAD
				SKIP
			ENDDO
 			CABEZA( 2 )
 			I_CL += 2
 			? I_esp + ARMOLIN(I_cab)
 			? I_esp + ARMOLIN(I_cab+2)
        SELECT LU
        SET ORDER TO 1
        GO nReg
        RECUPAN()
			LISTADOR( "FIN" )
     ENDIF

	ELSEIF listado $ "CUMPLEANO"
		IF QUEFECHA2( 10, 30 )
     	cAux1 := strzero(month(DESDE),2)+strzero(day(DESDE),2)
     	cAux2 := strzero(month(HASTA),2)+strzero(day(HASTA),2)
			MENSAJE( 99, 99, 0, .F., "ORDENANDO..." )
        select LU
        nReg:=RECNO()
        index on strzero(month(FECH_NAC),2)+strzero(day(FECH_NAC),2) to (XNAME('XAUX'))
        RECUPAN()
			LISTADOR( "INI" )
 			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH "LUBRICEN"
        nCant:=0
			M->TMODULO := 0
			M->TOTAL   := 0
        M->CANTIDAD := 0
        GO TOP
        DO WHILE !eof()
				if strzero(month(FECH_NAC),2)+strzero(day(FECH_NAC),2)>=cAux1 .AND. strzero(month(FECH_NAC),2)+strzero(day(FECH_NAC),2)<=cAux2
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
					M->TMODULO += LU->TMODULO
					M->TOTAL   += LU->TOTAL
        		M->CANTIDAD += LU->CANTIDAD
           endif
				SKIP
			ENDDO
 			CABEZA( 2 )
 			I_CL += 2
 			? I_esp + ARMOLIN(I_cab)
 			? I_esp + ARMOLIN(I_cab+2)
        FREABRIR({"LUB"})
        SELECT LU
        SET ORDER TO 1
        GO nReg
        RECUPAN()
			LISTADOR( "FIN" )
     ENDIF

  ENDIF
end sequence
ErrorBlock(bLastErr)
IF I_errores < 1
	RECUPAN()
ENDIF
		
RETURN nil


****************

FUNC PMOD( aModulo, ctitulo )

****************
LOCAL aCPO, OX

#define RG_CODPROD        1
#define RG_SURTIDOR       2
#define RG_CANTIDAD       3
#define RG_DESCPROD       4

ctitulo := IF( ctitulo==NIL, " PLANTILLA ", ctitulo )
aCpo:={                                                                        ;
  { "CODPROD",    "C¢d;Prod",                      '99999', 'M', 'N',  5, 0 },;
  { "SURTIDOR",   "Su;rt",                            '99', 'M', 'N',  2, 0 },;
  { "CANTIDAD",   "Cantidad",                   '9999.999', 'M', 'N',  8, 3 },;
  { "DESCPROD",   "Descripci¢n; ",          REPLIC('X',20), 'F', 'C', 20, 0 }}

SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

NROW := 1
IF LEN(aModulo) == 0
	AADD( aModulo, AREG0( aCpo ) )
ENDIF

SETCOLOR( "W/N,N/W" )
MARCO( 5, 30, 19, 78, ctitulo, "D", .T., 0 )
OX := MYABROWSE( 5, 30, 19, 78, aCpo, aModulo, "aModulo" )
OX:CARGO[TB_REFRESH] := 0
OX:GOTOP()


MENUDOWN({"  <+>  º    F2    º    F3    º   F5    º   F6    º    TAB   º ESC  ",;
          "       º          º  busca   º inserta º elimina º  elegir  º      ",;
          " mueve º modifica º producto º  l¡nea  º  l¡nea  º producto º sale "})

guardar = .F.
DO WHILE .T.
	
	MOVABROW( OX, aModulo, {||nK==K_TAB.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F5.OR.nK==K_F3.OR.nK==K_F6},;
	  {||nK==999} )
	
	IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB ) .AND. MODIFICABLE
		IF TBNOC(OX) $ "CODPROD SURTIDOR CANTIDAD"
			IF OX:CARGO[TB_MSGE] == "MODIF"
				aModulo[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
			IF TBNOC(OX) == "CODPROD"
				r := 0
				IF OX:Cargo[TB_RET] == K_TAB
					IF FELEGIR( "PRODUCTO", aModulo[NROW,RG_CODPROD] ) # 0
						aModulo[NROW,RG_CODPROD] := PRD->CODPROD
					ENDIF
				ELSEIF OX:Cargo[TB_RET] == K_F3
					r := SELECTPRD()
					IF r # 0
						aModulo[NROW,RG_CODPROD] := r
					ENDIF
				ENDIF
				aModulo[NROW,RG_DESCPROD ] := FPRODUCTO(aModulo[NROW,RG_CODPROD])
			ENDIF
		ENDIF
		OX:RefreshCurrent()
		
	ELSEIF OX:Cargo[TB_RET] == K_F5 .AND. MODIFICABLE
		AADD( aModulo, AREG0(aCpo) )
		AINS( aModulo, NROW )
		aModulo[NROW] := AREG0(aCpo)
		aModulo[NROW,RG_SURTIDOR] := 0
		OX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
		IF aModulo[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(aModulo)
			AADD( aModulo, AREG0(aCpo) )
			aModulo[LEN(aModulo),RG_SURTIDOR] := 0
		ENDIF
		OX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. LEN(aModulo) > 1
		ADEL( aModulo, NROW )
		ASIZE( aModulo, LEN(aModulo)-1 )
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
	*    CLEARTYPEAHEAD()
ENDDO

RECUPAN()

IF OX:Cargo[TB_RET] == K_F10
	i := ASCAN( aModulo,{|a| EMPTY(a[RG_DESCPROD])} )
	DO WHILE i # 0
		ADEL( aModulo, i )
		ASIZE( aModulo, LEN(aModulo)-1 )
		i := ASCAN( aModulo,{|a| EMPTY(a[RG_DESCPROD])} )
	ENDDO
ENDIF

RETURN ( OX:Cargo[TB_RET] == K_F10 )
