LOCAL aCpo, oGET, nReg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO( .T., " COPRES " )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
aCpo:={{ "FECHA",      "Fecha; ",                            '', 'E',  '',  0, 0 },;
		  { "TURNO",      "Tu;rn",                              '', 'E',  '',  0, 0 },;
		  { "NUMERO",     "N£mero; ",                           '', 'E',  '',  0, 0 },;
		  { "MONTO",      "Monto; ",                            '', 'E',  '',  0, 0 },;
		  { "FECHVENC",   "Fecha;Venc.",                        '', 'E',  '',  0, 0 },;
		  { "ESTADO",     "Est; ",                              '', 'E',  '',  0, 0 },;
		  { "FECHCOBRO",  "Fecha;Cobro",                        '', 'E',  '',  0, 0 }}

FBASES({ "COPRES" })
select COP
aCop := NEWEDIT( "COPRES",.F.,.T. )
aCpo := FBASEAUX( aCpo, dbf(), SELECT(), .F. )
set order to COP_FECHA_TURNO
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º   F5   º F6   SHIFT F6 º   F9    º ESC  ",;
			  "       º F3 busca  º        º elimina l¡nea º presen- º      ",;
			  " mueve º F4 busca+ º agrega º F7    imprime º taci¢n  º sale "})

SETCOLOR( "W/N,N/W" )

PRIVATE oX := MYBROWSE( 5, 1, 19, 78, aCpo )

oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()

aedits := TBCOLEDIT( "SETEAR", "COPRES", OX, aedits )
TBCOLOR(OX)



DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==K_F5.OR.nK==K_F2.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-6.OR.nk==-9.OR.nK==K_SH_F6.OR.nK==K_ALT_E}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
		IF TBNOC(OX) == "TURNO"
			IF oX:Cargo[TB_RET] == K_TAB
				e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aturno, COP->TURNO, "", "S", .T.)
				IF LASTKEY() == K_ENTER
					FRLOCK()
					FIELD->TURNO := LEFT(aturno[e],1)
				ENDIF
				RECUPAN()
        ENDIF
		ELSEIF TBNOC(OX) == "ESTADO"
			IF oX:Cargo[TB_RET] == K_TAB
				e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aestado, FIELD->ESTADO, "", "S", .T.)
				IF LASTKEY() == K_ENTER
					FRLOCK()
					FIELD->ESTADO := LEFT(aestado[e],1)
				ENDIF
				RECUPAN()
        ENDIF
		ENDIF
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F2 .OR. oX:Cargo[TB_RET] == K_F5
		MODIFICABLE := .T.
		xmenu:=MENUDOWN({"     º  ENTER   º   F10   º ESC  ",;
							  "       º          º graba y º      ",;
							  " mueve º confirma º   sale  º sale "})
		FEDITOR(aCop,"PONEPAN")
		FEDITOR( aCop, "SETVARS", oX:Cargo[TB_RET], .F. )
		IF oX:Cargo[TB_RET] == K_F5
			EDPONE(aCop,"COP->FECHA", VA->FECHA)
			EDPONE(aCop,"COP->TURNO", COP->TURNO)
 			EDPONE(aCop,"COP->NUMERO", 0 )
			EDPONE(aCop,"COP->MONTO", COP->MONTO )
			EDPONE(aCop,"COP->ESTADO", 'CAR')
			aCop[ED_I] := 2
     ENDIF
		aCop[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( aCop, { K_F10 } )
			IF ( aCop[ED_UPDATE] .OR. aCop[ED_TECLA]==K_TAB )
				aCop[ED_MODE] = "MOSTRAR"
				IF EDNOM(aCop) == "COP->TURNO" .AND. aCop[ED_TECLA]==K_TAB
					ele = PP_SELEC( aCop [ED_Y], aCop[ED_X], 0, 0, aturno, EDCONT(aCop), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(aCop,,LEFT(aturno[ele],1))
					ENDIF
					RECUPAN()
				ENDIF
				aCop[ED_MODE] := "MOSTRARTODO"
			ELSEIF ( aCop[ED_TECLA] == K_ENTER .AND. aCop[ED_I] == LEN(aCop[ED_EDIT]) ) .OR. aCop[ED_TECLA] == K_ESC .OR. aCop[ED_TECLA] == K_F10
				r := "S"
				IF aCop[ED_TECLA] == K_F10
					r := "G"
				ELSEIF FEDITOR( aCop, "HUBOCAMBIOS" )
					r := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
				ENDIF
				IF r == "G"
					r := "G"
					IF oX:Cargo[TB_RET] == K_F5
						nReg := F_ALTA( FTOC(CTOD(""))+" " )
              ENDIF
					aCop[ED_REGISTRO] := RECNO()
					FEDITOR( aCop, "GRABAR", .F. )
					EXIT
				ELSEIF r == "S"
					EXIT
				ENDIF
			ENDIF
		ENDDO
		FEDITOR(aCop,"SACAPAN")
		MENUDOWN(xmenu)
		oX:RefreshAll()


	ELSEIF oX:Cargo[TB_RET] == K_F5
		aaux := { COP->FECHA, COP->TURNO, COP->FECHVENC }
		nReg := F_ALTA( FTOC(CTOD(""))+" " )
		FRLOCK()
		COP->FECHA    := aaux[1]
		COP->TURNO    := aaux[2]
		COP->FECHVENC := aaux[3]
		COP->ESTADO   := "CAR"
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == 999
  	SKIP
     IF EOF()
			DBGOBOTTOM()
 			IF FIELD->MONTO # 0
				aaux := { COP->FECHA, COP->TURNO, COP->FECHVENC }
				nReg := F_ALTA( FTOC(CTOD(""))+" " )
				FRLOCK()
				COP->FECHA    := aaux[1]
				COP->TURNO    := aaux[2]
				COP->FECHVENC := aaux[3]
				COP->ESTADO   := "CAR"
        ENDIF
			TBPOS(OX,.T.)
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	nReg:=RECNO(); SKIP -1; nReg2:=RECNO(); GO nReg
			BLANKREG(.T.)
			GO nReg2
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
     nReg:=RECNO(); SKIP -1; nReg2:=RECNO(); GO nReg
		BLANKREG(.T.)
		GO nReg2
		TBPOS(OX,.T.)

	ELSEIF oX:Cargo[TB_RET] == K_F7
		op = MENUFLASH( 10, 30, 1, .T., "³ LISTADO ³", "COPRES EN CARTERA", "COPRES COBRADOS" )
		IF op == 1
			LISTAR( "COPCAR" )
		ELSEIF op == 2
			LISTAR( "COPCOB" )
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F9
		nOrder:=indexord()
		nReg:=recno()
		cBaseAux:=xname("XAUX")
		aCp:={{ "FECHA",		"Fecha;Pago", 				'', 'F',	'', 0, 0 },;
				{ "TURNO", 		"Tur",						'', 'F', '', 0, 0 },;
				{ "NUMERO", 	"N§de;Tarj", 				'', 'F', '', 0, 0 },;
				{ "MONTO", 		"Monto; ",					'', 'F', '', 0, 0 },;
				{ "FECHCOBRO",	"Fecha;Cobro",			 	'', 'F',	'', 0, 0 },;
				{ "ESTADO",		"Est",					'!!!', 'F', '', 0, 0 },;
				{ "MARCA", 		"M",							'', 'F', '', 0, 0 }}
		aCp := FBASEAUX( aCp, dbf(), select(), .F. )
		select 99;	dbclosearea()
		aaux:=COP->(dbstruct())
		aadd(aaux,{"REGISTRO","N",6,0})
		dbcreate(cBaseAux,aaux)
		select 99
		use (cBaseAux) alias X exclusive
		index on ftoc(X->FECHA) to (cBaseAux)
		M->FECHA := INGRVAL( 10, 20, "Fecha Cobro", M->FECHA, "", "")
		if lastkey() == K_ENTER
			M->ESTADO := "CAR"
			cTitulo :=" COBRO DE COPRES "+DTOC(M->FECHA)
			MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
			select COP
			set order to COP_ESTADO_FECHA_TURNO
			dbseek(M->ESTADO,.T.)
			aaux:=COP->(dbstruct())
			select X
			do while ROSCA() .and. COP->ESTADO==M->ESTADO
				append blank
				aeval( aaux, {|a,i| fieldput(i,COP->(fieldget(i)))} )
				X->MARCA := " "
				X->REGISTRO := COP->(recno())
				skip 1 alias COP
			enddo
			RECUPAN()
			cMenu:=MENUDOWN({ " <+> º F2 modif. º ESPACIO  º  +      -  º ENTER  º ESC  ",;
									"     º F3 busca  º marca y  ºmarca/desmarº        º      ",;
									"mueveº F4 busca+ º desmarca ºhacia abajo ºconfirmaº sale "})
			SETCOLOR(C_MENU)
			MARCO(7,1,17,75,cTitulo, "S", .T., 0 )
			OCH := MYBROWSE(7,1,17,75, aCp )
			OCH:CARGO[TB_REFRESH] := 0
			dbgotop()
			TBCOLOR(OCH)
			lDispTot:=.T.
			lRecontar:=.F.
			M->MARCADOS := M->MONTO:=0
			do while .T.
				if lRecontar
					M->MONTO:=0
					FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
					lDispTot:=.T.
					lRecontar:=.F.
				endif
				IF lDispTot
*					 nReg:=recno()
*					 sum MONTO to M->MONTO for COP->MARCA==""
*					 go nReg
					OTC := OCH:GETCOLUMN( 4 )
					OTC:FOOTING := TRANS(M->MONTO,"#######.##")
					OTC:FOOTSEP := "Ä"
					OCH:SETCOLUMN( 4, OTC )
					lDispTot := .F.
					TBPOS(OCH,.t.)
				ENDIF
				@ 18,55 say "Marc."+str(M->MARCADOS,4) color "+"+C_FONDO
				MOVBROW( OCH, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_F9.OR.nK==K_ESC.OR.chr(nK)$" +-".or.nK==K_ENTER} )
				IF OCH:Cargo[TB_MSGE] == "MODIF"
					FRLOCK()
					FIELD->&(TBNOC(OCH)) := OCH:CARGO[TB_CONT]
					TBPOS(OCH)
				ELSEIF OCH:Cargo[TB_RET]==K_F9
					lRecontar := .T.
					TBPOS(OCH,.T.)
				ELSEIF chr(OCH:Cargo[TB_RET])$" +-"
					FMARCA( OCH:Cargo[TB_RET], "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
					lDispTot := .T.
					TBPOS(OCH,.T.)
				ELSEIF OCH:Cargo[TB_RET] == K_ESC
					exit
				ELSEIF OCH:Cargo[TB_RET] == K_ENTER
					MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
					dbgotop()
					select COP
					fflock()
					do while ROSCA() .and. !X->(eof())
						if X->MARCA#" "
							go X->REGISTRO
							replace COP->ESTADO with "COB", COP->FECHCOBRO with M->FECHA
						endif
						skip 1 alias X
					enddo
					dbunlock()
					RECUPAN()
					exit
				ENDIF
			enddo
			RECUPAN()
			PONEPAN(cMenu)
		endif
		dbcommitall()
		select COP
		set order to nOrder
		DBGOTO(nReg)
		oX:RefreshAll()
		
	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "COPRES", OX, aedits, "EDITS.EST" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN


*****************************

STATIC FUNC LISTAR( listado )

*****************************
local cBaseAux := XNAME("XAUX")
select 99;  dbclosearea()
if listado == "COPCAR"
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");	break(nil);  endif
		do icarga with listado
		select COP
		xord := indexord()
		nReg := RECNO()
		set order to COP_ESTADO_FECHA_TURNO
		dbseek( "CAR",.t.)
		copy to (cBaseAux) rest while ESTADO=="CAR"
		select 99
		use (cBaseAux) alias X
		index on FTOC(X->FECHA)+X->TURNO to (cBaseAux)
		dbgotop()
		I_codtarj := "@"
		I_TOTAL  := 0
		I_CANT	:= 0
		do while !eof() .and. !SALIR()
			CABEZA( 1 ); ++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			I_TOTAL += X->MONTO
			++I_CANT
			skip
		enddo
		CABEZA( 3 ); I_CL += 3
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		? I_esp + ARMOLIN(I_cab)
		select 99; DBCLOSEAREA()
		select COP
		set order to xord
		go nReg
		RECUPAN()
		LISTADOR( "FIN" )

ELSEIF listado = "COPCOB"
	if QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");	break(nil);  endif
		DO ICARGA WITH listado
		select 99; dbclosearea()
		select COP
		xord := INDEXORD()
		nReg := RECNO()
		set order to COP_ESTADO_FECHA_TURNO
		dbseek("COB",.T.)
		copy to (cBaseAux) rest for BETWEEN(FECHCOBRO,DESDE,HASTA)
		select 99
		use (cBaseAux) alias X exclusive
		index on FTOC(X->FECHA)+X->TURNO TO (cBaseAux)
		dbgotop()
		I_codtarj := "@"
		I_TTOTAL := I_TOTAL := 0
		I_TCANT := I_CANT := 0
		do while !eof() .and. !SALIR()
			CABEZA( 1 );  ++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			++I_CANT
			++I_TCANT
			I_TOTAL += X->MONTO
			I_TTOTAL += X->MONTO
			skip
		enddo
		CABEZA( 3 );  I_CL += 3
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
		? I_esp + ARMOLIN(I_cab)
		select 99; dbclosearea()
		select COP
		set order to xord
		go nReg
		RECUPAN()
		LISTADOR( "FIN" )
  endif
endif

return
