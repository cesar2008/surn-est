LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO( .T., " POSNET " )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
aCpo:={{ "FECHPAGO",   "Fecha;Pago",                         '', 'E',  '',  0, 0 },;
		  { "TURNO",      "Tur",                                '', 'E',  '',  0, 0 },;
		  { "CODTARJ",    "C¢d.;Tarj",                          '', 'E',  '',  0, 0 },;
		  { "LOTE",       "Lo;te",                              '', 'E',  '',  0, 0 },;
		  { "FVECTOR(vtarjeta,CODTARJ)", "Tarjeta", 'XXXXXXXXXXXX', 'F', 'F',  0, 0 },;
		  { "MONTO",      "Monto; ",                            '', 'E',  '',  0, 0 },;
		  { "FECHCOBRO",  "Fecha;Cobro",                        '', 'E',  '',  0, 0 },;
		  { "ESTADO",     "Est",                                '', 'E',  '',  0, 0 },;
		  { "CODCLI",     "C¢d.;Cli",                           '', 'E',  '',  0, 0 },;
		  { "CONCEPTO",   "Concepto",                           '', 'E',  '',  0, 0 },;
		  { "FECHCIERRE", "Fecha;Cierre",                       '', 'F',  '',  0, 0 } }

select 99;  dbclosearea()
cBaseAux := XNAME('XAUX')
dbcreate(cBaseAux,{{"REGISTRO","N",6,0}})
select 99
use (cBaseAux) alias X exclusive
FBASES({ "POSNET" })
select PN
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
EDX := NEWEDIT( "POSNET",.F.,.T. )
SET ORDER TO FORDER({"FECHPAGO","TURNO"})
DBGOBOTTOM()
cCODTARJ   := PN->CODTARJ
nLOTE      := PN->LOTE
dFECHCOBRO := PN->FECHCOBRO

MENUDOWN({"  <+>  º F2 modif. º   F5   º F6   SHIFT F6 º  F9   º   TAB    º ESC  ",;
			  "       º F3 busca  º        º elimina l¡nea º       º tarj,tur,º      ",;
			  " mueve º F4 busca+ º agrega º F7    imprime º cobro º clientes º sale "})

SETCOLOR( "W/N,N/W" )
PRIVATE oX := MYBROWSE( 5, 1, 19, 78, aCpo )
oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()

aedits := TBCOLEDIT( "SETEAR", "POSNET", OX, aedits )
TBCOLOR(OX)

DO WHILE .T.
*	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-6.OR.nk==-9.OR.nK==K_SH_F6.OR.nK==K_ALT_E}, {||NK==999}, {||EMPTY(PN->FECHCIERRE).AND.FIELD->FECHPAGO>VA->FECHSEG} )
	MOVBROW( oX, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_F7.OR.nK==K_F8.OR.nk==K_F9.OR.nK==K_ESC.or.nK==K_ALT_E} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF" .AND. EMPTY(PN->FECHCIERRE)
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB .AND. EMPTY(PN->FECHCIERRE)
		IF TBNOC(OX) == "CODTARJ"
			e = ABRW( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 'vtarjeta', PN->CODTARJ, 'TARJETAS')
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->CODTARJ := LEFT( vtarjeta[e], 3 )
			ENDIF
		ELSEIF TBNOC(OX) == "CODCLI"
			IF FELEGIR( "CLIENTE", M->CODCLI ) # 0
				FRLOCK()
				FIELD->CODCLI := CL->CODCLI
			ENDIF
		ELSEIF TBNOC(OX) == "TURNO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aturno, PN->TURNO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->TURNO := LEFT(aturno[e],1)
			ENDIF
			RECUPAN()
		ELSEIF TBNOC(OX) == "ESTADO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aestado, FIELD->ESTADO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->ESTADO := LEFT(aestado[e],3)
			ENDIF
			RECUPAN()
		ENDIF
     DBUNLOCK()
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F2 .OR. oX:Cargo[TB_RET] == K_F5
		MODIFICABLE := .T.
		xmenu:=MENUDOWN({"     º  ENTER   º   F10   º ESC  ",;
							  "       º          º graba y º      ",;
							  " mueve º confirma º   sale  º sale "})
		FEDITOR(EDX,"PONEPAN")
		FEDITOR( EDX, "SETVARS", oX:Cargo[TB_RET], .F. )
		IF oX:Cargo[TB_RET] == K_F5
			EDPONE(EDX,"PN->FECHPAGO", PN->FECHPAGO)
			EDPONE(EDX,"PN->TURNO", PN->TURNO)
 			EDPONE(EDX,"PN->CODTARJ", PN->CODTARJ )
			EDPONE(EDX,"PN->ESTADO", 'CAR')
*			EDX[ED_I] := 2
     ENDIF
		EDX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( EDX, { K_F10 } )
			IF ( EDX[ED_UPDATE] .OR. EDX[ED_TECLA]==K_TAB )
				EDX[ED_MODE] = "MOSTRAR"
				IF EDNOM(EDX) == "PN->TURNO" .AND. EDX[ED_TECLA]==K_TAB
					ele = PP_SELEC( EDX [ED_Y], EDX[ED_X], 0, 0, aturno, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(aturno[ele],1))
					ENDIF
					RECUPAN()
				ELSEIF EDNOM(EDX) == "PN->CODTARJ" .AND. EDX[ED_TECLA]==K_TAB
					ele = ABRW( EDX [ED_Y], EDX[ED_X], 0, 'vtarjeta', EDCONT(EDX), 'TARJETAS')
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(vtarjeta[ele],3))
					ENDIF
				ENDIF
				EDX[ED_MODE] := "MOSTRARTODO"
			ELSEIF ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==rat("M",EDX[ED_EDIT]) ) .OR. EDX[ED_TECLA]==K_ESC .OR. EDX[ED_TECLA]==K_F10
				r := "S"
				IF EDX[ED_TECLA] == K_F10 .OR. EDX[ED_TECLA]==K_ENTER
					r := "G"
				ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
					r := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
				ENDIF
				if r == "G"
					if EDCONT(EDX,"PN->FECHPAGO")<=VA->FECHSEG
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
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
			BLANKREG(.T.)
			GO xreg2
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
     xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
		BLANKREG(.T.)
		GO xreg2
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F7
		op2 = MENUFLASH( 10, 30, 1, .T., "³ LISTADOS ³", "LOTE         ", "POSNET EN CARTERA", "POSNET COBRADOS" )
		IF op2 == 1
			LISTAR( "POSLOTE" )
		ELSEIF op2 == 2
			LISTAR( "POSCAR" )
		ELSEIF op2 == 3
			LISTAR( "POSCOB" )
		ENDIF
		
	ELSEIF oX:Cargo[TB_RET] == K_F9
		xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
							  "       º graba y º        ",;
							  " mueve º procede º  sale  "})
		aaux := NEWEDIT2( "POSCOB",,.T. )
		aaux[ED_I] := 1
		aaux[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR2( aaux, { K_F10 } )
			IF aaux[ED_UPDATE]
				aaux[ED_MODE] = "MOSTRAR"
			ELSEIF aaux[ED_TECLA] == K_TAB
           IF EDNOM(aaux) == "cCODTARJ"
					ele := ABRW( 10, 20, 0, 'vtarjeta', cCodTarj, 'TARJETAS')
     			IF LASTKEY() == K_ENTER
						cCodTarj := left(vtarjeta[ele],3)
					ENDIF
					aaux[ED_MODE] = "MOSTRARTODO"
           ENDIF
			ELSEIF aaux[ED_TECLA] == K_F10
				MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
           nReg := recno()
				SET ORDER TO FORDER({"ESTADO"})
           dbseek( "CAR" )
           select X
           zap
           nCant := nMonto := 0
           do while PN->ESTADO=='CAR' .and. !PN->(eof())
           	if empty(PN->FECHCOBRO) .and. PN->CODTARJ==cCodTarj .and. PN->LOTE==nLote
              	APPEND BLANK
                 X->REGISTRO := PN->(RECNO())
                 @ 24,70 say lastrec() pict "9999"
                 ++nCant
                 nMonto += PN->MONTO
              endif
           	skip 1 alias PN
           enddo
           go top
           RECUPAN()
				MARCO( 10, 25, 12, 70, "", "D", .T. )
           @10,25 say "Cantidad de cupones "+alltrim(str(nCant,3))+" X $ "+alltrim(str(nMonto,10,2))
           @12,25 say "[ ENTER ]  contin£a.      [ ESC ] cancela."
           k:=inkey(0)
           select PN
				SET ORDER TO FORDER({"FECHPAGO","TURNO"})
           RECUPAN()
           if k==K_ENTER
					MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
           	FFLOCK()
           	do while !X->(EOF())
           		go X->REGISTRO
              	PN->FECHCOBRO := dFECHCOBRO
              	PN->ESTADO    := "COB"
              	skip 1 alias X
           	enddo
           	DBUNLOCK()
           	RECUPAN()
           endif
           go nReg
				EXIT
			ELSEIF aaux[ED_TECLA] == K_ESC
				EXIT
			ENDIF
		ENDDO
		FEDITOR(aaux,"SACAPAN")
		MENUDOWN(xmenu)
     TBPOS(OX,.T.)
		
	ELSEIF oX:Cargo[TB_RET] == K_F9
		SETCOLOR("N/W,W/N,,,N/W+")
		op = MENUFLASH( 10, 30, 1, .T., "", "PONER FECHA DE PRESENTACION", "MARCAR TARJETAS COBRADAS" )
		xreg := RECNO()
		IF op == 1
     	IF QUEFECHA2()
        rDESDE := DESDE
        nT := 1
        DO WHILE .T.
        DESDE := rDESDE
			nT := ABRW( 10, 20, 0, 'vtarjeta', nT, 'TARJETAS')
     	IF LASTKEY() == K_ENTER
				MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
           M->CODTARJ := LEFT(vtarjeta[nT],3)
				SELECT PN
				SET ORDER TO FORDER({"ESTADO"})
				aaux := {}; xaux := 0; xcant := 0
				SEEK "CAR"
				DO WHILE PN->ESTADO == "CAR"
           	IF PN->CODTARJ == M->CODTARJ .AND. PN->FECHPAGO>=DESDE .AND. PN->FECHPAGO<=HASTA
 						AADD( aaux, PN->CODTARJ+"³"+ STR(PN->LOTE)+"³"+ DTOC(PN->FECHPAGO)+"³"+ PN->TURNO+"³"+ STR(PN->MONTO)+"³"+ DTOC(PN->FECHPRES)+ STR(RECNO(),5) + PN->CODTARJ+FTOC(PN->FECHPAGO) )
						IF !EMPTY(PN->FECHPRES)
							++xcant
 							xaux += FIELD->MONTO
           		ENDIF
              ENDIF
					SKIP
				ENDDO
 				ASORT( aaux,,,{|x,y| RIGHT(x,6) < RIGHT(y,6)} )
				areg := ARRAY( LEN(aaux) )
				RECUPAN()
				IF LEN(aaux) # 0
					aux := LEN(aaux[1])-11;		AEVAL( aaux, {|a,i| areg[i]:=VAL(RIGHT(a,11)), aaux[i]:=LEFT(a,aux)} )
					DESDE := DATE()
					ym4 := 7
					xm4 := CENTRO(80,LEN(aaux[1]))
					xmenu:=MENUDOWN({"     º ESPACIO  º     F5     º     F6     º    F8    º  F9   º  ENTER  º ESC  ",;
									  	  "       º marca y  º   marca    º  desmarca  º fecha de º recal-º graba y º      ",;
									  	  " mueve º desmarca ºhacia abajo ºhacia abajo º present. º cula  º  sale   º sale "})
					ele  := Rrel := 0
					modo := 0
					btecla := {|k| k==32.OR.k==-4.OR.K==-5.OR.K==-7.OR.K==13.OR.K==-8}
					ym44 = IF( ym4+LEN(aaux)+1>19, 19, ym4+LEN(aaux)+1 )
					MARCO( ym4-3, xm4, ym4-3, xm4+14, "PRESENTACION", "D", .T. )
					MARCO( ym4, xm4, ym44, xm4+LEN(aaux[1]), ALLTRIM(LEFT(vtarjeta[nT],LEN(vtarjeta[nT])-3))+" a PRESENTAR ", "D", .T. )
					@ ym4  , xm4 SAY "Tar³Lot³Recibida³T³Monto     ³Fech.Pres"
					@ ym4+1, xm4 SAY "ÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÄÅÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ"
					@ ym4-3, xm4 SAY DESDE
					DO WHILE .T.
						@ ym44+1, xm4+2 SAY xcant PICT "(9999)"
						@ ym44+1, xm4+15 SAY xaux PICT "#######.##"
						ele := ACHOICE(ym4+2, xm4, ym44, xm4+LEN(aaux[1]), aaux, .T., "achfunc", ele, Rrel)
						IF modo == K_SPACE
							IF EMPTY(CTOD(RIGHT(aaux[ele],8)))
								aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-8) + DTOC(DESDE)
                    	xaux += VAL(SUBSTR(aaux[ele],20))
								++xcant
							ELSE
								aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-8) + "  /  /  "
                    	xaux -= VAL(SUBSTR(aaux[ele],20))
								--xcant
							ENDIF
                 	KEYBOARD CHR(K_DOWN)
						ELSEIF modo == K_F5
							FOR i=ele TO LEN(aaux)
								IF RIGHT(aaux[i],2) == "  "
									aaux[i] := LEFT(aaux[i], LEN(aaux[i])-8) + DTOC(DESDE)
                    		xaux += VAL(SUBSTR(aaux[i],20))
									++xcant
								ENDIF
							NEXT
						ELSEIF modo == K_F6
							FOR i=ele TO LEN(aaux)
								IF RIGHT(aaux[i],2) # "  "
									aaux[i] := LEFT(aaux[i], LEN(aaux[i])-8) + "  /  /  "
                    		xaux -= VAL(SUBSTR(aaux[i],20))
									--xcant
								ENDIF
							NEXT
						ELSEIF modo == K_F9
							xaux := xcant := 0
							FOR i=1 TO LEN(aaux)
								IF RIGHT(aaux[i],2) # "  "
									xaux += VAL(SUBSTR(aaux[i],20))
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
						AEVAL( areg, {|a,i| DBGOTO(a), PN->FECHPRES:=CTOD(RIGHT(aaux[i],8)) } )
						RECUPAN()
					ENDIF
					PONEPAN(xmenu)
           ENDIF
        ELSE
        	EXIT
			ENDIF
        ENDDO
        ENDIF

			* * *   Tarjetas Cobradas
		ELSEIF op == 2
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			SELECT PN
			SET ORDER TO FORDER({"ESTADO"})
			aaux := {}; xcant := xaux := 0
			SEEK "CAR"
			DO WHILE PN->ESTADO == "CAR"
				IF !EMPTY(PN->FECHPRES)
					AADD( aaux, PN->CODTARJ+"³"+ STR(PN->LOTE)+"³"+ DTOC(PN->FECHPAGO) +"³"+ STR(PN->MONTO) +"³"+ DTOC(PN->FECHPRES) +" "+ STR(RECNO(),5) )
				ENDIF
				SKIP
			ENDDO
			ASORT(aaux,,,{|x,y| left(x,4)+DTOS(CTOD(SUBSTR(x,9,8))) < left(y,4)+DTOS(CTOD(SUBSTR(y,9,8))) } )
			areg := ARRAY( LEN(aaux) )
			AEVAL( aaux, {|a,i| areg[i]:=VAL(RIGHT(a,5)), aaux[i]:=LEFT(a,LEN(a)-5)} )
			RECUPAN()
			IF LEN(aaux) # 0
				ym4 := 7
				xm4 := CENTRO(80,LEN(aaux[1]))
				xmenu:=MENUDOWN({"     º ESPACIO  º     F5     º     F6     º   F9   º  ENTER  º ESC  ",;
									  "       º marca y  º   marca    º  desmarca  º recal- º graba y º      ",;
									  " mueve º desmarca ºhacia abajo ºhacia abajo º  cula  º  sale   º sale "})
				ele  := Rrel := 0
				modo := 0
				btecla := {|k| k==32.OR.k==-4.OR.K==-5.OR.K==-7.OR.K==13.OR.k==-8}
				ym44 = IF( ym4+LEN(aaux)+1>19, 19, ym4+LEN(aaux)+1 )
				MARCO( ym4, xm4, ym44, xm4+LEN(aaux[1]), " TARJ.PRESENTADAS ", "D", .T. )
				@ ym4  , xm4 SAY "Tar³Lot³Recibida³     Monto³Fech.Pres "
				@ ym4+1, xm4 SAY "ÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ"
				DO WHILE .T.
					@ ym44+1, xm4+2 SAY xcant PICT "(9999)"
					@ ym44+1, xm4+13 SAY xaux PICT "#######.##"
					ele := ACHOICE(ym4+2, xm4, ym44, xm4+LEN(aaux[1]), aaux, .T., "achfunc", ele, Rrel)
					IF modo == K_SPACE
						IF RIGHT(aaux[ele],1) == ' '
							aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-1) + ''
                    xaux += VAL(SUBSTR(aaux[ele],18))
							++xcant
						ELSE
							aaux[ele] := LEFT(aaux[ele], LEN(aaux[1])-1) + ' '
                    xaux -= VAL(SUBSTR(aaux[ele],18))
							--xcant
						ENDIF
                 KEYBOARD CHR(K_DOWN)
					ELSEIF modo == K_F5
						FOR i=ele TO LEN(aaux)
							IF RIGHT(aaux[i],1) == " "
								aaux[i] := LEFT(aaux[i], LEN(aaux[i])-1) + ''
                    	xaux += VAL(SUBSTR(aaux[i],18))
                       ++xcant
							ENDIF
						NEXT
					ELSEIF modo == K_F6
						FOR i=ele TO LEN(aaux)
							IF RIGHT(aaux[i],1) # "  "
								aaux[i] := LEFT(aaux[i], LEN(aaux[i])-1) + ' '
                    	xaux -= VAL(SUBSTR(aaux[i],18))
								--xcant
							ENDIF
						NEXT
					ELSEIF modo == K_F9
						xaux := xcant := 0
						FOR i=1 TO LEN(aaux)
							IF RIGHT(aaux[i],1) == ""
								xaux += VAL(SUBSTR(aaux[i],18))
                       ++xcant
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
					AEVAL( areg, {|a,i| DBGOTO(a), PN->ESTADO:=IF(RIGHT(aaux[i],1)=='','PRE','CAR') } )
					RECUPAN()
				ENDIF
				PONEPAN(xmenu)
			ENDIF
		
		ENDIF
		SET ORDER TO FORDER({"FECHPAGO","TURNO"})
		DBGOTO(xreg)
		oX:RefreshAll()
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "POSNET", OX, aedits, "EDITS.EST" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
  DBUNLOCK()

ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN


*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nOrder
local cBaseAux := XNAME("XAUX")
		
IF listado = "POSCOB"
	if QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");	break(nil);  endif
		DO ICARGA WITH listado
		select 99; dbclosearea()
		select PN
		xord := INDEXORD()
		nReg := RECNO()
		set order to forder({"ESTADO"})
		dbseek("COB")
		copy to (cBaseAux) rest for ESTADO=="COB".and.BETWEEN(FECHCOBRO,DESDE,HASTA)
		select 99
		use (cBaseAux) alias X exclusive
		index on X->CODTARJ+FTOC(X->FECHCOBRO) TO (cBaseAux)
		dbgotop()
		I_codtarj := "@"
		I_TTOTAL := I_TOTAL := 0
		I_TCANT := I_CANT := 0
		do while !eof() .and. !SALIR()
			if I_codtarj # X->CODTARJ
				if I_codtarj # "@"
					CABEZA( 2 );  I_CL += 2
					? I_esp + ARMOLIN(I_cab+2)
				endif
				CABEZA( 2 ); I_CL+=2
				?
				? I_esp + FVECTOR(vtarjeta,X->CODTARJ)
				I_codtarj := X->CODTARJ
				I_CANT    := 0
				I_TOTAL 	 := 0
			endif
			CABEZA( 1 );  ++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			++I_CANT
			++I_TCANT
			I_TOTAL += X->MONTO
			I_TTOTAL += X->MONTO
			skip
		enddo
		CABEZA( 2 );  I_CL += 2
		? I_esp + ARMOLIN(I_cab+2)
		CABEZA( 4 );	 I_CL += 4
     ?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+3)
		? I_esp + ARMOLIN(I_cab)
		select 99; dbclosearea()
		select PN
		set order to xord
		go nReg
		RECUPAN()
		LISTADOR( "FIN" )
  endif

ELSEIF listado = "POSCAR"
*	if QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");	break(nil);  endif
		DO ICARGA WITH listado
		select 99; dbclosearea()
		select PN
		xord := INDEXORD()
		nReg := RECNO()
		set order to forder({"ESTADO"})
		dbseek("CAR")
		copy to (cBaseAux) rest for ESTADO=="CAR"		//.and.BETWEEN(FECHCOBRO,DESDE,HASTA)
		select 99
		use (cBaseAux) alias X exclusive
		index on X->CODTARJ+FTOC(X->FECHPAGO) TO (cBaseAux)
		dbgotop()
		I_codtarj := "@"
		I_TTOTAL := I_TOTAL := 0
		I_TCANT := I_CANT := 0
		do while !eof() .and. !SALIR()
			if I_codtarj # X->CODTARJ
				if I_codtarj # "@"
					CABEZA( 2 );  I_CL += 2
					? I_esp + ARMOLIN(I_cab+2)
				endif
				CABEZA( 2 ); I_CL+=2
				?
				? I_esp + FVECTOR(vtarjeta,X->CODTARJ)
				I_codtarj := X->CODTARJ
				I_CANT    := 0
				I_TOTAL 	 := 0
			endif
			CABEZA( 1 );  ++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			++I_CANT
			++I_TCANT
			I_TOTAL += X->MONTO
			I_TTOTAL += X->MONTO
			skip
		enddo
		CABEZA( 2 );  I_CL += 2
		? I_esp + ARMOLIN(I_cab+2)
		CABEZA( 4 );	 I_CL += 4
     ?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+3)
		? I_esp + ARMOLIN(I_cab)
		select 99; dbclosearea()
		select PN
		set order to xord
		go nReg
		RECUPAN()
		LISTADOR( "FIN" )
* endif

ELSEIF listado = "POSLOTE"
	M->CODTARJ := "   "
  M->LOTE    := 0
	MARCO( 10, 25, 12, 65, "", "D", .T. )
  do while .T.
  	set key K_TAB to CLEAR_GETS()
  	@10,25 say "Tarjeta:" get M->CODTARJ pict "!!!"
  	@10,38 say fvector(vtarjeta,M->CODTARJ)
  	@11,25 say "   Lote:" get M->LOTE pict "999"
  	read
  	set key K_TAB to
     if lastkey()==K_TAB
			ele = ABRW( 10, 34, 0, 'vtarjeta', M->CODTARJ, 'TARJETAS')
			if lastkey() == K_ENTER
				M->CODTARJ := left(vtarjeta[ele],3)
			endif
     elseif lastkey()==K_ENTER .or. lastkey()==K_ESC
     	exit
     endif
  enddo
  RECUPAN()
  if lastkey()==K_ENTER
  	nAux:=recno()
     nOrder:=indexord()
     nCant:=nMONTO:=0
  	set order to FORDER({"CODTARJ","LOTE"})
     dbseek( M->CODTARJ+str(M->LOTE,flen(PN->LOTE)) )
     do while PN->CODTARJ==M->CODTARJ .and. PN->LOTE==M->LOTE
     	nCant++
        nMONTO+=PN->MONTO
     	skip
     enddo
     set order to nOrder
     dbgoto(nAux)
  	aaux:={fvector(vtarjeta,M->CODTARJ),"Lote:"+str(M->LOTE,3),str(nCant,3),str(nMONTO,10,2)}
		ele = PP_SELEC( 10, 25, 0, 0, aaux, 1, "", "S", .T.)
     RECUPAN()
  endif

endif

return
