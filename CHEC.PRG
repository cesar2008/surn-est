LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " CHEQUES PROPIOS " )

aCpo:={{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
		  { "BANCO",      "Banco",                              '', 'M',  '',  0, 0 },;
		  { "NUMCHEQUE",  "N§;Cheque",                          '', 'M',  '',  0, 0 },;
		  { "CHEQUEPARA", "Concepto",                           '', 'M',  '',  0, 0 },;
 		  { "MONTO",      "Monto",                              '', 'M',  '',  0, 0 },;
 		  { "ESTADO",     "Estado; ",                           '', 'F',  '',  0, 0 },;
 		  { "CODPROV",    "C¢d;Prov",                           '', 'F',  '',  0, 0 },;
 		  { "FECHCC",     "Fecha;Cheque",                       '', 'F',  '',  0, 0 }}

FBASES({ "CHEQUEST" })
SELECT CHC
aCpo := FBASEAUX( aCpo, "CHC", SELECT(), .F. )
SET ORDER TO CH_FECHPAGO_TURNO
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º   F5   º F6   Shift F6 º  F9   º   TAB    º  ESC   ",;
			  "       º F3 busca  º        º elimina l¡nea º depo- º banc,tur,º        ",;
			  " mueve º F4 busca+ º agrega º F7    imprime º sitos º clientes º  sale  "})

SETCOLOR( "W/N,N/W" )

PRIVATE oX := MYBROWSE( 5, 1, 19, 78, aCpo )

oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "CHEQUEST", OX, aedits )
TBCOLOR(OX)

DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-6.OR.nk==-9.OR.nK==K_SH_F6.OR.nK==K_ALT_E},{||NK=999},{||EMPTY(CHC->FECHCC).AND.FIELD->FECHPAGO>VA->FECHSEG} )
	
  xreg := RECNO()
	IF oX:Cargo[TB_MSGE] == "MODIF" .AND. EMPTY(CHC->FECHCC)
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB .AND. EMPTY(CHC->FECHCC)
		IF TBNOC(OX) == "BANCO"
			e = ABRW( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 'vbanco', CHC->BANCO, 'BANCOS')
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->BANCO := LEFT( vbanco[e], 3 )
			ENDIF
		ELSEIF TBNOC(OX) == "CODCLI"
			IF FELEGIR( "CLIENTE", M->CODCLI ) # 0
				FRLOCK()
				FIELD->CODCLI := CL->CODCLI
			ENDIF
		ELSEIF TBNOC(OX) == "TURNO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aturno, CHC->TURNO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->TURNO := LEFT(aturno[e],1)
			ENDIF
			RECUPAN()
		ELSEIF TBNOC(OX) == "ESTADO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aestado, FIELD->ESTADO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->ESTADO := LEFT(aestado[e],1)
			ENDIF
			RECUPAN()
		ELSEIF TBNOC(OX) == "CODEMP"
			IF FELEGIR( "EMPLEADO", CHC->CODEMP ) # 0
				FRLOCK()
				FIELD->&(TBNOC(OX)) := EM->CODEMP
			ENDIF
		ENDIF
		TBPOS(OX)
*    GO xreg
*		oX:RefreshAll()
*    GO xreg
	ELSEIF oX:Cargo[TB_RET] == K_F5
		aaux := { CHC->FECHPAGO, CHC->TURNO, CHC->BANCO }
		F_ALTA( FTOC(CTOD(""))+" " )
		FRLOCK()
		CHC->FECHPAGO := aaux[1]
		CHC->TURNO    := aaux[2]
		CHC->BANCO    := aaux[3]
     CHC->FECHA    := aaux[1]
		CHC->ESTADO   := "CAR"
* 	oX:PANHOME()
*		oX:GOBOTTOM()
*		oX:RefreshAll()
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == 999
  	SKIP
     IF EOF()
			DBGOBOTTOM()
 			IF FIELD->MONTO # 0
				aaux := { CHC->FECHPAGO, CHC->TURNO, CHC->BANCO }
				xreg := F_ALTA( FTOC(CTOD(""))+" " )
				FRLOCK()
				CHC->FECHPAGO := aaux[1]
				CHC->TURNO    := aaux[2]
				CHC->BANCO    := aaux[3]
     		CHC->FECHA    := aaux[1]
				CHC->ESTADO   := "CAR"
     		DBGOTO(xreg)
				TBPOS(OX,.T.)
*				oX:RefreshAll()
        ENDIF
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
			BLANKREG(.T.)
*			GO xreg2
*			oX:RefreshAll()
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
     xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
		BLANKREG(.T.)
*		GO xreg2
*		oX:RefreshAll()
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F7
		op = MENUFLASH( 10, 30, 1, .T., "", "CHEQUES EN CARTERA" )
		IF op == 1
			LISTADOR( "CHEQCAR" )
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F9
		SETCOLOR("N/W,W/N,,,N/W+")
		op = MENUFLASH( 10, 30, 1, .T., "", "DEPOSITAR CHEQUES" )
		xreg := RECNO()
		IF op == 1
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			SELECT CH
			aaux := {}; xaux := 0; xcant := 0
			DBSETORDER( FORDER({"CHC->ESTADO"}) )
			SEEK "CAR"
			DO WHILE CHC->ESTADO == "CAR"
				IF !EMPTY(CHC->FECHA)
					AADD( aaux, CHC->BANCO +"³"+ DTOC(CHC->FECHPAGO) +"³"+ STR(CHC->MONTO) +"³"+ DTOC(CHC->FECHA) +"³"+ DTOC(CHC->FECHSALIO) + STR(RECNO(),5) )
              IF EMPTY(CHC->FECHSALIO)
              	++xcant
						xaux += CHC->MONTO
              ENDIF
				ENDIF
				SKIP
			ENDDO
			ASORT(aaux,,,{|x,y| CTOD(SUBSTR(x,5,8)) < CTOD(SUBSTR(y,5,8)) } )
			areg := ARRAY( LEN(aaux) )
			AEVAL( aaux, {|a,i| areg[i]:=VAL(RIGHT(a,5)), aaux[i]:=LEFT(a,LEN(a)-5)} )
			RECUPAN()
			IF LEN(aaux) # 0
				DESDE := DATE()
				ym4 := 7
				xm4 := CENTRO(80,LEN(aaux[1]))
				xmenu:=MENUDOWN({"     º ESPACIO  º     F5     º     F6     º   F7    º  ENTER  º ESC  ",;
									  "       º marca y  º   marca    º  desmarca  º         º graba y º      ",;
									  " mueve º desmarca ºhacia abajo ºhacia abajo º imprime º  sale   º sale "})
				ele  := Rrel := 0
				modo := 0
				btecla := {|k|k==32.OR.k==-4.OR.K==-5.OR.K==-7.OR.K==13.OR.K==-8}
				ym44 = IF( ym4+LEN(aaux)+1>19, 19, ym4+LEN(aaux)+1 )
				MARCO( ym4-3, xm4, ym4-3, xm4+14, "FECHA DEPOSITO", "D", .T. )
				MARCO( ym4, xm4, ym44, xm4+LEN(aaux[1]), " CHEQUES A DEPOSITAR ", "D", .T. )
				@ ym4  , xm4 SAY "Ban³Recibido³Monto     ³Fech.Cob³Fech.Dep"
				@ ym4+1, xm4 SAY "ÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ"
				@ ym4-3, xm4 SAY DESDE
				DO WHILE .T.
					@ ym44+1, xm4+2 SAY xcant PICT "(9999)"
					@ ym44+1, xm4+13 SAY xaux PICT "#######.##"
					ele := ACHOICE(ym4+2, xm4, ym44, xm4+LEN(aaux[1]), aaux, .T., "achfunc", ele, Rrel)
					IF modo == K_SPACE
						IF EMPTY(CTOD(RIGHT(aaux[ele],8)))
							aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-8) + DTOC(DESDE)
                    xaux += VAL(SUBSTR(aaux[ele],14))
							++xcant
						ELSE
							aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-8) + "  /  /  "
                    xaux -= VAL(SUBSTR(aaux[ele],14))
							--xcant
						ENDIF
                 KEYBOARD CHR(K_DOWN)
					ELSEIF modo == K_F5
						FOR i=ele TO LEN(aaux)
							IF RIGHT(aaux[i],2) == "  "
								aaux[i] := LEFT(aaux[i], LEN(aaux[i])-8) + DTOC(DESDE)
                    	xaux += VAL(SUBSTR(aaux[i],14))
								++xcant
							ENDIF
						NEXT
					ELSEIF modo == K_F6
						FOR i=ele TO LEN(aaux)
							IF RIGHT(aaux[i],2) # "  "
								aaux[i] := LEFT(aaux[i], LEN(aaux[i])-8) + "  /  /  "
                    	xaux -= VAL(SUBSTR(aaux[i],14))
								--xcant
							ENDIF
						NEXT
					ELSEIF modo == K_F9
						xaux := xcant := 0
						FOR i=1 TO LEN(aaux)
							IF RIGHT(aaux[i],2) # "  "
								xaux += VAL(SUBSTR(aaux[i],14))
                       ++xcant
							ENDIF
						NEXT
					ELSEIF modo == K_F8
						DESDE := QUEFECHA( ym4-3, xm4, DESDE )
						@ ym4-3, xm4 SAY DESDE
					ELSEIF modo == K_ESC .OR. modo == K_ENTER
						EXIT
					ENDIF
					modo := 0
				ENDDO
				RECUPAN()
				RECUPAN()
				IF modo == K_ENTER
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					FFLOCK()
              FOR i=1 TO LEN(aaux)
						GO areg[i]
						CHC->FECHSALIO := CTOD(RIGHT(aaux[i],8))
						CHC->ESTADO    := IF( EMPTY(CHC->FECHSALIO), "CAR", "DEP" )
              NEXT
					RECUPAN()
				ENDIF
				PONEPAN(xmenu)
			ENDIF

		ELSEIF op == 2
			IF QUEFECHA2( 10, 25 )
				MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
				SELECT CH
				SET ORDER TO CH_ESTADO
				aaux := {}
				xaux := 0
				SEEK "COB"
				DO WHILE CHC->ESTADO == "COB"
					IF CHC->FECHA>=DESDE .AND. CHC->FECHA<=HASTA
						AADD( aaux, CHC->BANCO +"³"+ DTOC(CHC->FECHPAGO) +"³"+ STR(CHC->MONTO) +"³"+ DTOC(CHC->FECHA) + STR(RECNO(),5) )
						++xaux
					ENDIF
					SKIP
				ENDDO
				ASORT(aaux)
				areg := ARRAY( LEN(aaux) )
				AEVAL( aaux, {|a,i| areg[i]:=VAL(RIGHT(a,5)), aaux[i]:=LEFT(a,LEN(a)-5)+""} )
				RECUPAN()
				IF LEN(aaux) # 0
					DESDE := DATE()
					ym4 := 7
					xm4 := CENTRO(80,LEN(aaux[1]))
					xmenu:=MENUDOWN({"     º ESPACIO  º     F5     º     F6     º  ENTER  º ESC  ",;
						"       º marca y  º   marca    º  desmarca  º graba y º      ",;
						" mueve º desmarca ºhacia abajo ºhacia abajo º  sale   º sale "})
					ele  := Rrel := 0
					modo := 0
					btecla := {|k|k==32.OR.k==-4.OR.K==-5.OR.K==-7.OR.K==13}
					ym44 = IF( ym4+LEN(aaux)+1>19, 19, ym4+LEN(aaux)+1 )
					SETCOLOR("W/N,N/W")
					MARCO( ym4, xm4, ym44, xm4+LEN(aaux[1]), " CHEQUES COBRADOS ", "ÜÜÜÞßßßÝ", .T. )
					@ ym4  , xm4 SAY "Tar³Recibida³Monto     ³Fecha Cob."
					@ ym4+1, xm4 SAY "ÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ"
					SETCOLOR("W+/N,N/W")
					DO WHILE .T.
						@ ym44+1, xm4+2 SAY "Cobradas:"+STR(xaux,3)
						ele := ACHOICE(ym4+2, xm4, ym44, xm4+LEN(aaux[1]), aaux, .T., "achfunc", ele, Rrel)
						IF modo == K_SPACE
							IF RIGHT(aaux[ele],1) == ' '
								aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-1) + ''
								++xaux
							ELSE
								aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-1) + ' '
								--xaux
							ENDIF
						ELSEIF modo == K_F5
							FOR i=ele TO LEN(aaux)
								IF RIGHT(aaux[i],1) == " "
									++xaux
									aaux[i] := LEFT(aaux[i], LEN(aaux[i])-1) + ''
								ENDIF
							NEXT
						ELSEIF modo == K_F6
							FOR i=ele TO LEN(aaux)
								IF RIGHT(aaux[i],1) # "  "
									--xaux
									aaux[i] := LEFT(aaux[i], LEN(aaux[i])-1) + ' '
								ENDIF
							NEXT
						ELSEIF modo == K_ESC .OR. modo == K_ENTER
							EXIT
						ENDIF
						modo := 0
					ENDDO
					RECUPAN()
					IF modo == K_ENTER
						MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
						FFLOCK()
						AEVAL( areg, {|a,i| DBGOTO(a), IF(RIGHT(aaux[i],1)=='',,CHC->ESTADO:='CAR') } )
						RECUPAN()
					ENDIF
					PONEPAN(xmenu)
				ENDIF
			ENDIF
		ENDIF
		SET ORDER TO CH_FECHPAGO_TURNO
		DBGOTO(xreg)
		TBPOS(OX,.F.)
		
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "CHEQUEST", OX, aedits, "EDITS.EST" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN



*********************

FUNC FEDCHEC( ACHE, K, bAaux )

*********************
LOCAL r := .F., xmenu

xmenu:=MENUDOWN({"     º PgUp PgDown º presione TAB para obtener una º   ESC    ",;
						"       º             º lista de opciones. (solo fun- º          ",;
						" mueve º    mueve+   º ciona en los campos con  ).  º   sale   "})

ACHE[ED_EDIT] := UPPER( ACHE[ED_EDIT] )
IF K == K_F2 .OR. K == K_ENTER
	IF bAaux # NIL
		ACHE[ED_EDIT] := LOWER( ACHE[ED_EDIT] )
 		EVAL(bAaux,ACHE)
	ENDIF
ELSEIF K==K_F5
	IF bAaux # NIL
		EVAL(bAaux,ACHE)
  ENDIF
ENDIF
ACHE[ED_MODE] := "MOSTRARTODO"
DO WHILE .T.
	
	FEDITAR( ACHE, { 9 } )
	
	IF ACHE[ED_UPDATE]
		ACHE[ED_MODE] = "MOSTRAR"
	ELSEIF ACHE[ED_TECLA] == K_TAB
		ACHE[ED_MODE] = "MOSTRAR"
		IF EDNOM(ACHE) == "CHC->BANCO"
			e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbancocta', EDCONT(ACHE), 'BANCOS')
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT( vbancocta[e], 3 ))
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->CODCLI"
			IF FELEGIR( "CLIENTE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,CL->CODCLI)
				EDPONE( ACHE, "CHC->CHEQUDE", CL->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->CODPROV"
			IF FELEGIR( "PROVEE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,PRV->CODPROV)
				EDPONE( ACHE, "CHC->CHEQUEPARA", PRV->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CHC->TIPO"
			e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, atipo, EDCONT(ACHE), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT(atipo[e],1))
			ENDIF
			RECUPAN()
		ELSEIF EDNOM(ACHE) == "CHC->CODEMP"
			IF FELEGIR( "EMPLEADO", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,EM->CODEMP)
			ENDIF
		ENDIF
		
	ELSEIF ACHE[ED_TECLA] == K_ESC .OR. ( ACHE[ED_TECLA]==K_ENTER .AND. ACHE[ED_I]==LEN(ACHE[ED_FIELDS]) )
  	r := .F.
		IF FEDITOR( ACHE, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
			IF aux =="G"
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
