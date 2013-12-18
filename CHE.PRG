LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " CHEQUES " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
aCpo:={{ "FECHPAGO",   "Fecha;Pago",                         '', 'E',  '',  0, 0 },;
		  { "TURNO",      "T",                                  '', 'E',  '',  0, 0 },;
		  { "CODBAN",     "Banco; ",                            '', 'E',  '',  0, 0 },;
		  { "NUMCHEQUE",  "N§de;Cheque",                        '', 'E',  '',  0, 0 },;
		  { "MONTO",      "Monto; ",                            '', 'E',  '',  0, 0 },;
		  { "FECHA",      "Fecha;Cobro",                        '', 'E',  '',  0, 0 },;
		  { "CODCLI",     "C¢d.;Cli",                           '', 'E',  '',  0, 0 },;
		  { "ESTADO",     "Est",                                '', 'E',  '',  0, 0 },;
		  { "FECHSALIO",  "Fecha;Salida",                       '', 'E',  '',  0, 0 },;
		  { "CONCEPTO",   "Concepto; ",                         '', 'E',  '',  0, 0 },;
		  { "FECHCIERRE", "Fecha;Cierre",                       '', 'F',  '',  0, 0 } }

FBASES({ "CHEQCAR","PROVEEV" })
select CH
aCpo := FBASEAUX( aCpo, "CH", SELECT(), .F. )
EDX := NEWEDIT( "CHEQCAR",.F.,.T. )
SET ORDER TO CH_FECHPAGO_TURNO
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º   F5   º F6   Shift F6 º  F9   º   TAB    º  ESC   ",;
			  "       º F3 busca  º        º elimina l¡nea º depo- º banc,tur,º        ",;
			  " mueve º F4 busca+ º agrega º F7    imprime º sitos º clientes º  sale  "})
SETCOLOR(C_MENU)

PRIVATE oX := MYBROWSE( 5, 1, 19, 78, aCpo )
oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "CHEQUES", OX, aedits )
TBCOLOR(OX)

DO WHILE .T.
*	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-6.OR.nk==-9.OR.nK==K_SH_F6.OR.nK==K_ALT_E},{||NK=999},{||EMPTY(CH->FECHCIERRE).AND.FIELD->FECHPAGO>VA->FECHSEG} )
	MOVBROW( oX, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_F7.OR.nK==K_F8.OR.nk==K_F9.OR.nK==K_ESC.or.nK==K_ALT_E} )
	
  xreg := RECNO()
	IF oX:Cargo[TB_MSGE] == "MODIF" .AND. EMPTY(CH->FECHCIERRE)
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET]==K_F2 .or. oX:Cargo[TB_RET]==K_F5
		MODIFICABLE := .T.
		xmenu:=MENUDOWN({"     º  ENTER   º   F10   º ESC  ",;
							  "       º          º graba y º      ",;
							  " mueve º confirma º   sale  º sale "})
		FEDITOR(EDX,"PONEPAN")
		FEDITOR( EDX, "SETVARS", oX:Cargo[TB_RET], .F. )
		IF oX:Cargo[TB_RET] == K_F5
			EDPONE(EDX,"CH->FECHPAGO", CH->FECHPAGO)
			EDPONE(EDX,"CH->TURNO", CH->TURNO)
			EDPONE(EDX,"CH->ESTADO", 'CAR')
     ENDIF
		EDX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( EDX, { K_F10 } )
			IF ( EDX[ED_UPDATE] .OR. EDX[ED_TECLA]==K_TAB )
				EDX[ED_MODE] = "MOSTRAR"
				IF EDNOM(EDX) == "CH->TURNO" .AND. EDX[ED_TECLA]==K_TAB
					ele = PP_SELEC( EDX [ED_Y], EDX[ED_X], 0, 0, aturno, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(aturno[ele],1))
					ENDIF
					RECUPAN()
				ELSEIF EDNOM(EDX) == "CH->CODBAN" .AND. EDX[ED_TECLA]==K_TAB
					ele = ABRW( EDX[ED_Y], EDX[ED_X], 0, 'vbanco', CH->CODBAN, 'BANCOS')
					if lastkey() == K_ENTER
						EDPONE(EDX,,LEFT(vbanco[ele],3))
					endif
				ELSEIF EDNOM(EDX) == "CH->CODCLI" .AND. EDX[ED_TECLA]==K_TAB
					IF FELEGIR( "CLIENTE", EDCONT(EDX) ) # 0
						EDPONE(EDX,,CL->CODCLI)
					ENDIF
				ELSEIF EDNOM(EDX)=="CH->CODPROV" .AND. EDX[ED_TECLA]==K_TAB
					if PROVEEV( EDCONT(EDX), .T. )
						EDPONE(EDX,,PRV->CODPROV )
              endif
				ENDIF
			ELSEIF ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==rat("M",EDX[ED_EDIT]) ) .OR. EDX[ED_TECLA]==K_ESC .OR. EDX[ED_TECLA]==K_F10
				r := "S"
				IF EDX[ED_TECLA] == K_F10 .OR. EDX[ED_TECLA]==K_ENTER
					r := "G"
				ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
					r := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
				ENDIF
				if r == "G"
					if EDCONT(EDX,"CH->FECHPAGO")<=VA->FECHSEG
						MENSAJE(0,0,10,.T., "FECHA MENOR O IGUAL A LA DE CIERRE" )
                 r :="C"
              endif
           endif
				if r == "G"
					r := "G"
					IF oX:Cargo[TB_RET] == K_F5
						F_ALTA({||!empty(FIELD->FECHPAGO)})
              ENDIF
					EDX[ED_REGISTRO] := RECNO()
					FEDITOR( EDX, "GRABAR", .F. )
					EXIT
				elseif r == "S"
					EXIT
				endif
			ENDIF
		ENDDO
		FEDITOR(EDX,"SACAPAN")
		MENUDOWN(xmenu)
		oX:RefreshAll()

 	ELSEIF oX:Cargo[TB_RET] == K_F5
		aaux := { CH->FECHPAGO, CH->TURNO, CH->CODBAN }
		F_ALTA( FTOC(CTOD(""))+" " )
		FRLOCK()
		CH->FECHPAGO := aaux[1]
		CH->TURNO    := aaux[2]
		CH->CODBAN    := aaux[3]
     CH->FECHA    := aaux[1]
		CH->ESTADO   := "CAR"
* 	oX:PANHOME()
*		oX:GOBOTTOM()
*		oX:RefreshAll()
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == 999
  	SKIP
     IF EOF()
			DBGOBOTTOM()
 			IF FIELD->MONTO # 0
				aaux := { CH->FECHPAGO, CH->TURNO, CH->CODBAN }
				xreg := F_ALTA( FTOC(CTOD(""))+" " )
				FRLOCK()
				CH->FECHPAGO := aaux[1]
				CH->TURNO    := aaux[2]
				CH->CODBAN    := aaux[3]
     		CH->FECHA    := aaux[1]
				CH->ESTADO   := "CAR"
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
			DBSETORDER( FORDER({"CH->ESTADO"}) )
			SEEK "CAR"
			DO WHILE CH->ESTADO == "CAR"
				IF !EMPTY(CH->FECHA)
					AADD( aaux, CH->CODBAN +"³"+ DTOC(CH->FECHPAGO) +"³"+ STR(CH->MONTO) +"³"+ DTOC(CH->FECHA) +"³"+ DTOC(CH->FECHSALIO) + STR(RECNO(),5) )
              IF EMPTY(CH->FECHSALIO)
              	++xcant
						xaux += CH->MONTO
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
						CH->FECHSALIO := CTOD(RIGHT(aaux[i],8))
						CH->ESTADO    := IF( EMPTY(CH->FECHSALIO), "CAR", "DEP" )
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
				DO WHILE CH->ESTADO == "COB"
					IF CH->FECHA>=DESDE .AND. CH->FECHA<=HASTA
						AADD( aaux, CH->CODBAN +"³"+ DTOC(CH->FECHPAGO) +"³"+ STR(CH->MONTO) +"³"+ DTOC(CH->FECHA) + STR(RECNO(),5) )
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
						AEVAL( areg, {|a,i| DBGOTO(a), IF(RIGHT(aaux[i],1)=='',,CH->ESTADO:='CAR') } )
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
		TBCOLEDIT( "CAMBIAR", "CHEQUES", OX, aedits, "EDITS.EST" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN


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
		IF EDNOM(ACHE) == "CH->CODBAN"
			e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbanco', EDCONT(ACHE), 'BANCOS')
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT( vbanco[e], 3 ))
			ENDIF
		ELSEIF EDNOM(ACHE) == "CH->CODCLI"
			IF FELEGIR( "CLIENTE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,CL->CODCLI)
				EDPONE( ACHE, "CH->CHEQUDE", CL->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CH->CODPROV"
			IF FELEGIR( "PROVEE", EDCONT(ACHE) ) # 0
				EDPONE(ACHE,,PRV->CODPROV)
				EDPONE( ACHE, "CH->CHEQUEPARA", PRV->RAZONSOC )
				ACHE[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ACHE) == "CH->TURNO"
			e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, aturno, EDCONT(ACHE), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE(ACHE,,LEFT(aturno[e],1))
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
	DBUNLOCK()
ENDDO
PONEPAN(xmenu)

RETURN r
