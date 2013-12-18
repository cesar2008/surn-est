#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PRIVATE APLA, aCPO

LOGO(.T., " LAVADERO ")
MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
FBASES({ "LAV", "LAV2", "EMPLEADO","PLANTLAV" }, .F.)

RG_CODPROD   := 1
RG_DESCPROD  := 2
RG_CANTIDAD  := 3
RG_IMPORTE   := 4
RG_PRECBASE  := 5
RG_IMPINT    := 6
RG_IVA       := 7
RG_PRECUNIT  := 8
RG_TPRECBASE := 9
RG_TIMPINT   := 10
RG_TIVA      := 11
RG_REGISTRO  := 12

aCpo:={	                                                                      ;
	{ "CODPROD",    "Prod",                               '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n",         REPLICATE("X",30), 'E',  '',  0, 0 },;
	{ "CANTIDAD",   "Cantidad",                           '', 'E',  '',  0, 0 },;
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
SELECT LV2
aCpo := FARRAYAUX( aCpo )
SELECT LV
DBGOBOTTOM()

SETCOLOR(C_GET)
SET(_SET_INTENSITY,.T.)

MODIFICABLE = .F.
NUEVO = .F.
APLA      := NEWEDIT( "LAV1",,.T. )
AX_FECHA  := ASCAN( APLA[ED_FIELDS], "LV->FECHA" )
AX_TURNO  := ASCAN( APLA[ED_FIELDS], "LV->TURNO" )
AX_NUMPARTE := ASCAN( APLA[ED_FIELDS], "LV->NUMPARTE" )
auxaux    := APLA[ED_EDIT]
RECUPAN()

DO WHILE .T.
	F10 := .F.
	
	RELLENAPAN( 9, 0, 21, 80, "°", C_FONDO )
	SELECT LV
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
			lSalir := EDCONT(APLA,"LV->NUMPARTE")#0
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
				APLA[ED_CONT,AX_NUMPARTE] := ULTIMO("LV","LV->NUMPARTE",1)+1
				NUEVO := .T.
			ENDIF
			APLA[ED_MODE] = "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( APLA, { 9, K_F10 } )
				IF APLA[ED_UPDATE] .OR. APLA[ED_TECLA] == K_TAB
					APLA[ED_MODE] = "MOSTRARTODO"
					IF EDNOM(APLA) == "LV->TURNO" .AND. APLA[ED_TECLA] == K_TAB
						ele = PP_SELEC( APLA[ED_Y], APLA[ED_X], 0, 0, aturno, EDCONT(APLA), "", "S", .T., .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(APLA,,LEFT(aturno[ele],1))
						ENDIF
						RECUPAN()
					ELSEIF "CODEMP" $ EDNOM(APLA) .AND. APLA[ED_TECLA] == K_TAB
						IF FELEGIR("EMPLEADO", EDCONT(APLA)) # 0
							EDPONE(APLA,, EM->CODEMP)
						ENDIF
					ENDIF
					IF EDNOM(APLA) $ "LV->FECHA LV->TURNO" .AND. 1==2
              	SET ORDER TO FORDER({"FECHA","TURNO"})
						IF FREPEAT( FTOC(EDCONT(APLA,"LV->FECHA"))+EDCONT(APLA,"LV->TURNO"), APLA[ED_MODAPP] )
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
						lSalir := EDCONT(APLA,"LV->NUMPARTE")#0
						EXIT
					ENDIF
				ELSEIF APLA[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			PONEPAN(xmenu)
		ELSEIF k == K_TAB
			private bcamp[10], bmasc[10], bcab[10], bedit
			bcamp[ 1] := "LV->NUMPARTE"
			bcamp[ 2] := "LV->FECHA"
			bcamp[ 3] := "LV->TURNO"
			bcamp[ 4] := "LV->TOTAL"
			bcamp[ 5] := "LV->MARCA"
			bcamp[ 6] := "LV->PATENTE"
			bcamp[ 7] := "LV->FECH_NAC"
			bcamp[ 8] := "LV->CODEMP1"
			bcamp[ 9] := "LV->APENOM"
			bcamp[10] := "LV->TELEFONO"
			afill(bmasc,"")
			bmasc[ 3] := "!!!!!!!!!!"
			bmasc[ 4] := "######.###"
			bcab[ 1] := "Parte"
			bcab[ 2] := "Fecha"
			bcab[ 3] := "Turno"
			bcab[ 4] := "Total"
			bcab[ 5] := "Marca"
			bcab[ 6] := "Patente"
			bcab[ 7] := "Fecha;Nacim"
			bcab[ 8] := "C¢d;Empl"
			bcab[ 9] := "Apellido, Nombre"
			bcab[10] := "Tel‚fono"
			bedit = replic("F",len(bcamp))
			xmenu:=MENUDOWN({"  <+>  º  F3   º   F4   º  ENTER  º  ESC   ",;
								  "       º       º        º elige y º        ",;
								  " mueve º busca º busca+ º  sale   º  sale  "})
			select LV
			_lastreg = RECNO()
			BROW( 8, 1, 18, 78, "PARTES", bcamp, bmasc, bcab, bedit )
			if lastkey() # K_ENTER
				GO _lastreg
			endif
			RECUPAN()
			PONEPAN(xmenu)
		ELSEIF K == K_F7
			op1 := MENUFLASH( 10, 30, 1, .T.,"", "Ventas Lavadero          ",;
 															 "Ventas x Producto        " )
			IF op1 == 1
				LST_LAV("LAVADERO")
        elseif op1 == 2
				LST_LAV("LAVENXPR")
        endif
		ELSEIF K == K_F10
			FEDITOR( APLA, "LEER" )
			F10 := .T.
			lSalir := EDCONT(APLA,"LV->NUMPARTE")#0
		ELSEIF K == K_ALT_F6
			IF PREGUNTA( 10, "¨ ESTAS SEGURO DE ELIMINAR  [ S / N ] ?","SsNn") $ "Ss"
				MENSAJE( 0, 0, 0, .F., " ELIMINANDO ..." )
				FEDITOR( APLA, "LEER" )
					*** 1§ deja el Stock como estaba
				SELECT LV2
				SEEK APLA[ED_CONT,AX_NUMPARTE]
				SELECT PRD
 				SET ORDER TO 1
				FFLOCK()
				DO WHILE LV2->NUMPARTE==APLA[ED_CONT,AX_NUMPARTE]
					SEEK LV2->CODPROD
        		IF FOUND() .AND. LV2->FECHA>=PRD->FECHA .AND. PRD->CONSURT#"S"
 	         		PRD->VENTAS -= LV2->CANTIDAD
           		PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
					ENDIF
					SKIP 1 ALIAS LV2
				ENDDO
					***
        	SELECT LV2
           SET ORDER TO 1
				DO WHILE DBSEEK( APLA[ED_CONT,AX_NUMPARTE] )
           	BLANKREG()
           ENDDO
           SELECT LV
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
	select LV2
	IF APLA[ED_CONT,AX_NUMPARTE]#0 .AND. DBSEEK( APLA[ED_CONT,AX_NUMPARTE] )
		NUEVO = .F.
		select LV2
		SEEK APLA[ED_CONT,AX_NUMPARTE]
		DO WHILE LV2->NUMPARTE == APLA[ED_CONT,AX_NUMPARTE]
			AADD( AXR, ARRAY( RG_REGISTRO ) )
			i := LEN(AXR)
			AXR[ i,RG_CODPROD  ] := FIELD->CODPROD
			AXR[ i,RG_DESCPROD ] := FIELD->DESCPROD
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
	aedits := TBCOLEDIT( "SETEAR", "LAVADERO", OX, aedits )
	IF MODIFICABLE
		OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
	ELSE
		OX:CARGO[TB_EDIT] := LOWER( OX:CARGO[TB_EDIT] )
	ENDIF
	TBCOLOR(OX)
	
	
	MENUDOWN({"    F2    º    F3    º    TAB   º   F10   º    P    º ESC  ",;
				 "          º  busca   º  elegir  º graba y º         º      ",;
				 " modifica º producto º producto º  sale   ºplantillaº sale "})
	
	guardar = .F.
  @ 20, 1 CLEAR TO 20,78
	DO WHILE .T.
		@ 20,50 SAY "Total:"+trans(M->TOTAL,"#######.##")
		MOVABROW( OX, AXR, {||nK==K_TAB.OR.nK==37.OR.nK==K_ESC.OR.nK==K_F7.OR.nK==K_F3.OR.nK==K_F10.OR.nK==K_F9.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_SH_F6.OR.nK==K_ALT_E.OR.CHR(nK)$'Pp'},;
			{||nK==999} )
		
		IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET]==K_TAB .OR. OX:Cargo[TB_RET]==K_F3 ) .AND. MODIFICABLE
			IF TBNOC(OX) $ "CODPROD CANTIDAD CANTIDAD IMPORTE"
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
				ENDIF
				IF TBNOC(OX) $ "CODPROD"
					IF AXR[NROW,RG_CODPROD] == 0
						AXR[NROW,RG_CANTIDAD] := 0
					ENDIF
				ENDIF
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
     			IF PLANT( aaux, ALLTRIM(PLT->DESCPLANT) )
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
           	n := ASCAN( aa, {|a| a[RG_CODPROD]==aaux[z,1]} )
              IF n == 0
						AXR[z,RG_CODPROD ] := aaux[z,1]
						AXR[z,RG_DESCPROD] := FPRODUCTO(AXR[z,RG_CODPROD])
						AXR[z,RG_PRECBASE] := FPRECBASE
						AXR[z,RG_IMPINT  ] := FIMPINT
						AXR[z,RG_IVA     ] := AXR[z,RG_PRECBASE] * M->PIVA1 /100
						AXR[z,RG_PRECUNIT] := AXR[z,RG_PRECBASE] + AXR[z,RG_IMPINT] + AXR[z,RG_IVA]
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
        ENDIF

		ELSEIF OX:Cargo[TB_RET] == K_F5 .AND. MODIFICABLE
			AADD( AXR, AREG0(aCpo) )
        AINS( AXR, NROW )
			AXR[NROW] := AREG0(aCpo)
			OX:RefreshAll()

		ELSEIF OX:Cargo[TB_RET] == K_ALT_E
			TBCOLEDIT( "CAMBIAR", "LAVADERO", OX, aedits, "EDITS.EST" )
			
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
		SELECT LV2
		SEEK APLA[ED_CONT,AX_NUMPARTE]
		SELECT PRD
 		SET ORDER TO 1
		FFLOCK()
		DO WHILE LV2->NUMPARTE==APLA[ED_CONT,AX_NUMPARTE]
			SEEK LV2->CODPROD
        IF FOUND() .AND. LV2->FECHA>=PRD->FECHA .AND. PRD->CONSURT#"S"
 	         PRD->VENTAS -= LV2->CANTIDAD
           PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
			ENDIF
			SKIP 1 ALIAS LV2
		ENDDO
			***

		FFLOCK("LV")
		FFLOCK("LV2")
		SELECT LV
		IF !DBSEEK( APLA[ED_CONT,AX_NUMPARTE] )
			F_ALTA( {||LV->NUMPARTE#0} )
		ENDIF
     APLA[ED_REGISTRO] := recno()
		FEDITOR(APLA,"GRABAR",.F.)
     FRLOCK()
 		LV->TOTAL   := M->TOTAL
		SELECT LV2
		FOR i=1 TO LEN(AXR)
			IF empty(AXR[i,RG_DESCPROD])
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
					BLANKREG()
				ENDIF
			ELSEIF AXR[i,RG_CANTIDAD] # 0
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
				ELSE
					F_ALTA( {||LV2->NUMPARTE#0} )
				ENDIF
				FRLOCK()
				LV2->FECHA    := APLA[ED_CONT,AX_FECHA]
				LV2->TURNO    := APLA[ED_CONT,AX_TURNO]
           LV2->NUMPARTE := APLA[ED_CONT,AX_NUMPARTE]
				LV2->CODPROD   := AXR[ i,RG_CODPROD  ]
				LV2->DESCPROD  := AXR[ i,RG_DESCPROD ]
				LV2->CANTIDAD  := AXR[ i,RG_CANTIDAD ]
				LV2->PRECBASE  := AXR[ i,RG_PRECBASE ]
				LV2->IMPINT    := AXR[ i,RG_IMPINT   ]
				LV2->PRECUNIT  := AXR[ i,RG_PRECUNIT ]
				LV2->IVA       := AXR[ i,RG_IVA      ]
				LV2->IMPORTE   := AXR[ i,RG_IMPORTE  ]
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
					PRD->VENTAS += AXR[i,RG_CANTIDAD]
					PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
           ENDIF
			ENDIF
		NEXT i
     SELECT LV2

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

***********************

STATIC FUNC LST_LAV( listado )

***********************
LOCAL nOrder, nReg
#define    lxp		60

bLastErr := ErrorBlock()
bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
begin sequence

	IF listado $ "LAVENXPR"
		IF QUEFECHA2( 10, 30 )
			LISTADOR( "INI" )
			DO ICARGA WITH listado
 			if !SETIMPRESORA("INI");  break(nil);  endif
        SELECT LV
        nReg:=RECNO()
        nOrder := INDEXORD()
        SET ORDER TO FORDER({"FECHA","TURNO"})
        dbseek(FTOC(DESDE),.T.)
        aaux := LV2->(dbstruct())
        cBaseAux:=xname('XAUX')
        select 99;  dbclosearea()
        dbcreate(cBaseAux,aaux)
        select 99
        use (cBaseAux) alias X exclusive
        index on X->CODPROD to (cBaseAux)

        do while LV->FECHA>=DESDE .and. LV->FECHA<=HASTA .and. !LV->(EOF())
           LV2->(dbseek( LV->NUMPARTE ))
           do while LV2->NUMPARTE==LV->NUMPARTE .and. !LV2->(eof())
        		if !dbseek(LV2->CODPROD)
           		append blank
              	X->CODPROD := LV2->CODPROD
           	endif
        		X->CANTIDAD += LV2->CANTIDAD
              X->IMPORTE  += LV2->IMPORTE
              skip 1 ALIAS LV2
           enddo
           skip 1 alias LV
        enddo
        nCant:=0
        M->IMPORTE  := 0
        dbgotop()
        do while !eof()
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
           M->IMPORTE  += X->IMPORTE
				SKIP
			ENDDO
 			CABEZA( 2 )
 			I_CL += 2
 			? I_esp + ARMOLIN(I_cab)
 			? I_esp + ARMOLIN(I_cab+2)
        SELECT LV
        SET ORDER TO 1
        GO nReg
        RECUPAN()
			LISTADOR( "FIN" )
     ENDIF

	ELSEIF listado $ "LAVADERO"
		IF QUEFECHA2( 10, 30 )
			LISTADOR( "INI" )
			DO ICARGA WITH listado
 			if !SETIMPRESORA("INI");  break(nil);  endif
        SELECT LV
        nReg:=RECNO()
        nOrder := INDEXORD()
        SET ORDER TO FORDER({"FECHA","TURNO"})
        nCant:=0
        DBSEEK(FTOC(DESDE),.T.)
			M->TOTAL   := 0
        M->CANTIDAD := 0
        DO WHILE LV->FECHA>=DESDE .AND. LV->FECHA<=HASTA .AND. !LV->(EOF())
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
				M->TOTAL   += LV->TOTAL
        	M->CANTIDAD += 1
				SKIP
			ENDDO
 			CABEZA( 2 )
 			I_CL += 2
 			? I_esp + ARMOLIN(I_cab)
 			? I_esp + ARMOLIN(I_cab+2)
        SELECT LV
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

STATIC FUNC PLANT()

****************
PARAMETERS AXR, ctitulo
LOCAL aCPO, OX, NROWR:=NROW

ctitulo := IF( ctitulo==NIL, " PLANTILLA ", ctitulo )
aCpo:={                                                                        ;
  { "CODPROD",    "C¢d;Prod",                      '99999', 'M', 'N',  5, 0 },;
  { "DESCPROD",   "Descripci¢n; ",          REPLIC('X',20), 'F', 'C', 20, 0 }}

SETCOLOR("W/N,N/W")
SET(_SET_INTENSITY,.T.)

NROW := 1
IF LEN(AXR) == 0
	AADD( AXR, AREG0( aCpo ) )
ENDIF

SETCOLOR( "W/N,N/W" )
MARCO( 5, 30, 19, 78, ctitulo, "D", .T., 0 )
OX := MYABROWSE( 5, 30, 19, 78, aCpo, AXR, "AXR" )
OX:CARGO[TB_REFRESH] := 0
OX:GOTOP()


MENUDOWN({"  <+>  º    F2    º    F3    º   F5    º   F6    º    TAB   º ESC  ",;
          "       º          º  busca   º inserta º elimina º  elegir  º      ",;
          " mueve º modifica º producto º  l¡nea  º  l¡nea  º producto º sale "})

guardar = .F.
DO WHILE .T.
	
	MOVABROW( OX, AXR, {||nK==K_TAB.OR.NK==K_ESC.OR.nK==K_F10.OR.nK==K_F5.OR.nK==K_F6},;
	  {||nK==999} )
	
	IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB ) .AND. MODIFICABLE
		IF TBNOC(OX) $ "CODPROD"
			IF OX:CARGO[TB_MSGE] == "MODIF"
				AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
			ENDIF
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
			ENDIF
		ENDIF
		OX:RefreshCurrent()
		
	ELSEIF OX:Cargo[TB_RET] == K_F5 .AND. MODIFICABLE
		AADD( AXR, AREG0(aCpo) )
		AINS( AXR, NROW )
		AXR[NROW] := AREG0(aCpo)
		OX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
		IF AXR[NROW,RG_CODPROD] # 0 .AND. NROW==LEN(AXR)
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
NROW := NROWR

IF OX:Cargo[TB_RET] == K_F10
	i := ASCAN( AXR,{|a| EMPTY(a[RG_DESCPROD])} )
	DO WHILE i # 0
		ADEL( AXR, i )
		ASIZE( AXR, LEN(AXR)-1 )
		i := ASCAN( AXR,{|a| EMPTY(a[RG_DESCPROD])} )
	ENDDO
ENDIF

RETURN ( OX:Cargo[TB_RET] == K_F10 )
