LOCAL xmenu, xmenu2, K, lastcolor:=SETCOLOR("W/N,N/W"), lastbase,;
	lastreg, aaux
PRIVATE ACHE

#include "EST.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

LOGO(.T., " CHEQUES ")
MENSAJE( 0, 0, 0, .F., "AGUARDE . . " )
PROCESO := PROCNAME()
FBASES({ "CHEQUES", "CAJA", "CLIENTES", "PROVEE", "EMPLEADO" }, .F.)
MENUDOWN({"     º  ENTER   º   F5   º   F6    º   F7    º  TAB   º ESC ",;
			  "       º  o  F2   º        º         º         º elije  º     ",;
			  " mueve º modifica º agrega º elimina º imprime º cheque º sale"})
RECUPAN()

SELECT CH
ACHE := NEWEDIT( "CHEQUES" )

DO WHILE .T.
	
	k := FVERREG( ACHE, "K==9.OR.K==-4.OR.K==-5" )
	
	IF k == K_TAB
		SETCOLOR("W/N,N/W")
		PRIVATE bcamp[4], bmasc[4], bcab[4], bedit
		bcamp[ 1] = "RECNO()"
		bcamp[ 2] = "CH->NUMCHEQUE"
		bcamp[ 3] = "CH->CHEQUEDE"
		bcamp[ 4] = "CH->MONTO"
		bmasc[ 1] = ""
		bmasc[ 2] = ""
		bmasc[ 3] = "@!"
		bmasc[ 4] = ""
		bcab[ 1] = "N§ int."
		bcab[ 2] = "N§ cheque"
		bcab[ 3] = "Cheque de"
		bcab[ 4] = "Monto"
		bedit = "FFFF"
		xmenu2:=MENUDOWN({"  <+>  ³  F3   ³  F4    ³ ENTER  ³ ESC  ",;
			"       ³       ³        ³ elije  ³      ",;
			" mueve ³ busca ³ busca+ ³ y sale ³ sale "})
		lastreg = RECNO()
		BROW( 10, 15, 20, 75, "CHEQUES", bcamp, bmasc, bcab, bedit )
		RECUPAN()
		IF LASTKEY() # K_ENTER
			GO lastreg
		ENDIF
		PONEPAN(xmenu2)
		
		
	ELSEIF k == K_ENTER .OR. K==K_F2 .OR. k == K_F5
		FEDITOR( ACHE, "SETVARS", K )
  	FEDCHE( ACHE, K, CTOD('') )

		
	ELSEIF K == K_F6
		IF !EMPTY(CH->FECHCIERRE)
			MENSAJE( 0, 0, 10, .T., "PARA DAR DE BAJA A ESTE CHEQUE,", "HAY QUE SACARLO DE LA CUENTA CORRIENTE !!!" )
		ELSE
			IF PREGUNTA( 12, "¨ ESTAS SEGURO DE ELIMINARLO  [ S / N ]", "SsNn") $ "Ss"
				BLANKREG(.T.)
				DBGOTOP()
				RECUPAN()
			ENDIF
		ENDIF
		
		
	ELSEIF K == K_ESC
		EXIT
		
	ENDIF
	
ENDDO
FEDITOR( ACHE, "SACAPAN" )

SETCOLOR(lastcolor)

RETURN NIL


*********************

FUNC FEDCHE( ACHE, K, _fc )

*********************
LOCAL r := .F., xmenu

xmenu:=MENUDOWN({"     º PgUp PgDown º presione TAB para obtener una º   ESC    ",;
						"       º             º lista de opciones. (solo fun- º          ",;
						" mueve º    mueve+   º ciona en los campos con  ).  º   sale   "})

ACHE[ED_EDIT] := UPPER( ACHE[ED_EDIT] )
IF K == K_F2 .OR. K == K_ENTER
	IF !EMPTY(_fc)
		ACHE[ED_EDIT] := LOWER( ACHE[ED_EDIT] )
	ENDIF
ELSEIF K==K_F5
	IF EMPTY(_fc)
		EDPONE(ACHE,"CH->FECHPAGO",VA->FECHA)
  ENDIF
ENDIF
ACHE[ED_MODE] := "MOSTRARTODO"
DO WHILE .T.
	
	FEDITAR( ACHE, { 9 } )
	
	IF ACHE[ED_UPDATE]
		ACHE[ED_MODE] = "MOSTRAR"
	ELSEIF ACHE[ED_TECLA] == K_TAB
		ACHE[ED_MODE] = "MOSTRAR"
		IF EDNOM(ACHE) == "CH->BANCO"
			e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbanco', EDCONT(ACHE), 'BANCOS')
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT( vbanco[e], 3 ))
			ENDIF
		ELSEIF EDNOM(ACHE) == "CH->CODCLI"
			IF FELEGIR( "CLIENTE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,CL->(RECNO()))
				EDPONE( ACHE, "CH->CHEQUDE", CL->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CH->CODPROV"
			IF FELEGIR( "PROVEE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,PRV->(RECNO()))
				EDPONE( ACHE, "CH->CHEQUEPARA", PRV->PROVEEDOR )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CH->TIPO"
			e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, atipo, EDCONT(ACHE), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT(atipo[e],1))
			ENDIF
			RECUPAN()
		ELSEIF EDNOM(ACHE) == "CH->CODEMP"
			IF FELEGIR( "EMPLEADO", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,EM->CODEMP)
			ENDIF
		ENDIF
		
	ELSEIF ACHE[ED_TECLA] == K_ESC .OR. ( ACHE[ED_TECLA]==K_ENTER .AND. ACHE[ED_I]==LEN(ACHE[ED_FIELDS]) )
  	r := .F.
		IF FEDITOR( ACHE, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
			IF EMPTY(_fc) .AND. aux == "G"
				IF VA->CHEQUES == "S"
					SELECT CA
					SET ORDER TO CA_FECHA_TURNO
					IF ACHE[ED_MODAPP] == "MODIFICAR"
						SEEK FTOC(CH->FECHPAGO) + CH->TIPO
						DO WHILE CA->FECHA == CH->FECHPAGO .AND. CA->TIPO == CH->TIPO
							IF CA->CODCONCINT == nCHEQUES
								FRLOCK()
								CA->INGRESO -= CH->MONTO
								EXIT
							ENDIF
							SKIP
						ENDDO
					ENDIF
					SELECT CH
				ENDIF
				FEDITOR( ACHE, "GRABAR", .F. )
           r := .T.
				IF VA->CHEQUES == "S"
					aux := 0
					SELECT CA
					SEEK FTOC(CH->FECHPAGO) + CH->TIPO
					DO WHILE CA->FECHA == CH->FECHPAGO .AND. CA->TIPO == CH->TIPO
						IF CA->CODCONCINT == nCHEQUES
							aux := RECNO()
							EXIT
						ENDIF
						SKIP
					ENDDO
					IF aux == 0
						DBGOTOP()
						IF !EMPTY(CA->FECHA)
							ADD_REC()
						ENDIF
					ELSE
						DBGOTO(aux)
					ENDIF
					FRLOCK()
					CA->FECHA   := CH->FECHPAGO
					CA->TIPO    := CH->TIPO
					CA->INGRESO += CH->MONTO
					CA->CODCONCINT := nCheques
					CA->CODCONC    := 'CH'
					CA->CONCEPTO   := FVECTOR(vconc,CA->CODCONC)
					SELECT CH
				ENDIF
				EXIT
			ELSEIF aux =="G"
				FEDITOR( ACHE, "GRABAR", .F. )
           r := .T.
           EXIT
			ELSEIF aux == "S"
				EXIT
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDIF
	
ENDDO
PONEPAN(xmenu)

RETURN r
