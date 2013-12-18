LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

LOGO( .T., " TARJETAS " )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
M->FECHA := VA->FECHA
aCpo:={{  "FECHPAGO",     "Fecha;Pago",             '', 'E', '',	0, 0 },;
			{ "TURNO",			"Tur",                    '', 'E', '', 0, 0 },;
			{ "CODTARJ",		"C¢d.;Tarj",           '!!!', 'E', '', 0, 0 },;
			{ "NUMTARJ",      "N§de;Tarj",              '', 'E', '', 0, 0 },;
			{ "MONTO",			"Monto; ",                '', 'E','',  0, 0 },;
			{ "FECHPRES",     "Fecha;Pres.",            '', 'E','',  0, 0 },;
			{ "FECHCOBRO",    "Fecha;Cobro",            '', 'E','',  0, 0 },;
			{ "ESTADO", 		"Est",                 '!!!', 'E','',  0, 0 },;
			{ "CODCLI", 		"C¢d.;Cli",               '', 'E','',  0, 0 },;
			{ "CONCEPTO",     "Concepto",               '', 'E','',  0, 0 },;
			{ "FECHCIERRE",   "Fecha;Cierre",           '', 'E','',  0, 0 } }

FBASES({ "TARJETAS" })
select TA
EDX := NEWEDIT( "TARJETAS",.F.,.T. )
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
SET ORDER TO TA_FECHPAGO_TURNO
DBGOBOTTOM()

MENUDOWN({ " <+> ºF2 modif.º  F5  ºF6   SHIFT F6º F8  º  F9 º  TAB   ºESC  ",;
				"     ºF3 busca º      ºelimina l¡neaºsuma ºpres.º        º     ",;
				"mueveºF4 busca+ºagregaºF7    imprimeºtarj.ºcobroºclientesºsale "})

SETCOLOR( "W/N,N/W" )
PRIVATE oX := MYBROWSE( 6, 1, 18, 78, aCpo )
oX:CARGO[TB_REFRESH] := 0
oX:GOBOTTOM()

aedits := TBCOLEDIT( "SETEAR", "TARJETAS", OX, aedits )
TBCOLOR(OX)


DO WHILE .T.
	MOVBROW( oX, {||nK==K_F2.OR.nK==K_F5.OR.nK==K_ESC.OR.nK==K_F6.OR.nK==K_F7.OR.nk==K_F8.OR.nk==K_F9.OR.nK==K_ALT_E}, {||NK==999}, {||EMPTY(TA->FECHCIERRE).AND.FIELD->FECHPAGO>VA->FECHSEG} )

	IF oX:Cargo[TB_MSGE] == "MODIF" .AND. EMPTY(TA->FECHCIERRE) .AND. TA->FECHPAGO>VA->FECHSEG
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)

	ELSEIF oX:Cargo[TB_RET] == K_F2 .OR. oX:Cargo[TB_RET] == K_F5
		MODIFICABLE := .T.
		xmenu:=MENUDOWN({"     º  ENTER   º   F10   º ESC  ",;
							  "       º          º graba y º      ",;
							  " mueve º confirma º   sale  º sale "})
		FEDITOR(EDX,"PONEPAN")
		FEDITOR( EDX, "SETVARS", oX:Cargo[TB_RET], .F. )
		IF oX:Cargo[TB_RET] == K_F5
*			EDPONE(EDX,"TA->FECHPAGO", if(empty(VA->FECHA),TA->FECHPAGO,VA->FECHA))
			EDPONE(EDX,"TA->FECHPAGO", TA->FECHPAGO)
			EDPONE(EDX,"TA->TURNO", TA->TURNO)
 			EDPONE(EDX,"TA->CODTARJ", TA->CODTARJ )
			EDPONE(EDX,"TA->ESTADO", 'CAR')
*			EDX[ED_I] := 2
     ENDIF
		EDX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( EDX, { K_F10 } )
			IF ( EDX[ED_UPDATE] .OR. EDX[ED_TECLA]==K_TAB )
				EDX[ED_MODE] = "MOSTRAR"
				IF EDNOM(EDX) == "TA->TURNO" .AND. EDX[ED_TECLA]==K_TAB
					ele = PP_SELEC( EDX [ED_Y], EDX[ED_X], 0, 0, aturno, EDCONT(EDX), "", "S", .T.)
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(aturno[ele],1))
					ENDIF
					RECUPAN()
				ELSEIF EDNOM(EDX) == "TA->CODTARJ" .AND. EDX[ED_TECLA]==K_TAB
					ele = ABRW( EDX [ED_Y], EDX[ED_X], 0, 'vtarjeta', EDCONT(EDX), 'TARJETAS')
					IF LASTKEY() == K_ENTER
						EDPONE(EDX,,LEFT(vtarjeta[ele],3))
					ENDIF
				ENDIF
				EDX[ED_MODE] := "MOSTRARTODO"
			ELSEIF ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==rat("M",EDX[ED_EDIT]) ) .OR. EDX[ED_TECLA]==K_ESC .OR. EDX[ED_TECLA]==K_F10
				r := "S"
				if EDX[ED_TECLA] == K_F10 .OR. EDX[ED_TECLA]==K_ENTER
					r := "G"
				elseif FEDITOR( EDX, "HUBOCAMBIOS" )
					r := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
				endif
				if r == "G"
					if EDCONT(EDX,"TA->FECHPAGO")<=VA->FECHSEG
						MENSAJE(0,0,10,.T., "FECHA MENOR O IGUAL A LA DE CIERRE" )
                 r :="C"
              endif
           endif
				if r == "G"
					r := "G"
					if oX:Cargo[TB_RET] == K_F5
						F_ALTA({||!empty(FIELD->FECHPAGO)})
              endif
					EDX[ED_REGISTRO] := RECNO()
					FEDITOR( EDX, "GRABAR", .F. )
					exit
				elseif r == "S"
					EXIT
				endif
			ENDIF
		ENDDO
		FEDITOR(EDX,"SACAPAN")
		MENUDOWN(xmenu)
		oX:RefreshAll()

	ELSEIF oX:Cargo[TB_RET] == K_F6 .AND. TA->FECHPAGO>VA->FECHSEG
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
			xreg:=RECNO(); SKIP -1; xreg2:=RECNO(); GO xreg
			BLANKREG(.T.)
			GO xreg2
			TBPOS(OX,.T.)
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F7
		op = MENUFLASH( 10, 30, 1, .T., "³ LISTADO ³", "TARJETAS EN CARTERA", "TARJETAS COBRADAS" )
		IF op == 1
			LISTAR( "TARJCAR" )
		ELSEIF op == 2
			LISTAR( "TARJCOB" )
		ENDIF


	ELSEIF oX:Cargo[TB_RET] == K_F8
		nReg := RECNO()
		DESDE := VA->FECHA
		DESDE := QUEFECHA( 10, 20, DESDE )
		IF LASTKEY() == K_ENTER
			MENSAJE( 99, 99, 0, .F., "SUMANDO..." )
			aaux := {}
			select TA
			nOrder := indexord()
			DBSETORDER( FORDER({"FECHPAGO","TURNO"}) )
			DBSEEK( FTOC(DESDE), .T. )
			DO WHILE FIELD->FECHPAGO == DESDE .AND. !EOF()
				AADD( aaux, { FIELD->TURNO, FIELD->CODTARJ, FIELD->NUMTARJ, FIELD->MONTO } )
				SKIP
			ENDDO
			SET CONSOLE OFF
			SET ALTERNATE TO (XNAME("XLIS")+".TXT")
			SET ALTERNATE ON
			IF LEN(aaux) == 0
				? "* * *    NO HAY TARJETAS   * * *"
			ELSE
				ASORT( aaux,,,{|x,y| x[1]+x[2] < y[1]+y[2] } )
				xtur := aaux[1,1]
				xtar := aaux[1,2]
				xcant:=xtcant:=0
				xtot:=xttot:=0
				aa := {{},{}}; x:=1
				? "--------------- turno: "+aaux[1,1] +" -------------"+dtoc(DESDE)
				?
				? ALLTRIM(FVECTOR(vtarjeta,aaux[1,2]))
				FOR i=1 TO LEN(aaux)
					IF aaux[i,1] # xtur
						? USING( "(üüü)))))))))))üüüüüüü.üü",{xcant,xtot})
						? 											 "=========================="
						? USING( "(üüü)          üüüüüüü.üü",{xtcant,xttot})
						? 											 "=========================="
						xtur := aaux[i,1]
						xtar := aaux[i,2]
						xcant:=xtcant:=0
						xtot:=xttot:=0
						?
						? "--------------- turno: "+aaux[i,1] +" ---------------------"
						?
						? ALLTRIM(FVECTOR(vtarjeta,aaux[i,2]))
					ENDIF
					IF aaux[i,2] # xtar .AND. xtcant # 0
						? USING( "(üüü)))))))))))üüüüüüü.üü",{xcant,xtot})
						xtar := aaux[i,2]
						xcant:=0
						xtot:=0
						?
						? ALLTRIM(FVECTOR(vtarjeta,aaux[i,2]))
					ENDIF
					? 							 USING("ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ üüüüüüü.üü", {aaux[i,3],aaux[i,4]} )
					++xcant
					++xtcant
					xtot += aaux[i,4]
					xttot += aaux[i,4]
				NEXT
				? USING( "(üüü)          üüüüüüü.üü",{xcant,xtot})
				? 							 "=========================="
				? USING( "(üüü)          üüüüüüü.üü",{xtcant,xttot})
				? 							 "=========================="
			ENDIF
			SET ALTERNATE TO
			SET CONSOLE ON
			SET ORDER TO nOrder
			GO nReg
			RECUPAN()
			mbuz:=MENUDOWN({"  <+>  º  ESC   ",;
								 "       º        ",;
								 " mueve º  sale  "})
			MARCO( 1, 1, 20, 78, "", "D", .T., 0 )
			MEMOEDIT( MEMOREAD(XNAME("XLIS")+".TXT" ), 1, 1, 20, 78, .F., "FOUND()", 99 )
			RECUPAN()
			PONEPAN(mbuz)
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F9
		nReg:=recno()
		cBaseAux:=xname("XAUX")

		op2 = MENUFLASH( 10, 30, 1, .T., "", "PRESENTACION DE TARJETAS", "COBRO DE TARJETAS" )
		if lastkey()==K_ENTER
			aCp:={{  "FECHPAGO",		"Fecha;Pago", 				'', 'F',	'', 0, 0 },;
					 { "TURNO", 		"Tur",						'', 'F', '', 0, 0 },;
					 { "CODTARJ", 		"C¢d.;Tarj", 			'!!!', 'F',	'', 0, 0 },;
					 { "NUMTARJ", 		"N§de;Tarj", 				'', 'F', '', 0, 0 },;
					 { "MONTO", 		"Monto; ",					'', 'F', '', 0, 0 },;
					 { "FECHPRES",		"Fecha;Pres.", 			'', 'F',	'', 0, 0 },;
					 { "FECHCOBRO", 	"Fecha;Cobro",			 	'', 'F',	'', 0, 0 },;
					 { "ESTADO",		"Est",					'!!!', 'F', '', 0, 0 },;
					 { "MARCA", 		"M",							'', 'F', '', 0, 0 }}
			aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
			ele = ABRW( 10, 30, 0, 'vtarjeta', 1, 'TARJETAS')
			M->CODTARJ := left(vtarjeta[ele],3)
		endif
		if lastkey() == K_ENTER
			select 99;	dbclosearea()
			aaux:=TA->(dbstruct())
			aadd(aaux,{"REGISTRO","N",6,0})
			dbcreate(cBaseAux,aaux)
			select 99
			use (cBaseAux) alias X exclusive
			index on X->CODTARJ+ftoc(X->FECHPAGO) to (cBaseAux)
			if op2==1
				M->FECHA := INGRVAL( 10, 20, "Fecha Presentaci¢n", M->FECHA, "", "")
				if lastkey() == K_ENTER
					M->ESTADO := "CAR"
				endif
				cTitulo :=" PRESENTACION DE TARJETAS "+DTOC(M->FECHA)
			elseif op2 == 2
				M->FECHA := INGRVAL( 10, 20, "Fecha Cobro", M->FECHA, "", "")
				if lastkey() == K_ENTER
					M->ESTADO := "PRE"
				endif
				cTitulo :=" COBRO DE TARJETAS "+DTOC(M->FECHA)
			endif
			if lastkey() == K_ENTER
				MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
				select TA
				set order to TA_ESTADO
				dbseek(M->ESTADO,.T.)
				aaux:=TA->(dbstruct())
				select X
				do while ROSCA() .and. TA->ESTADO==M->ESTADO
					if TA->CODTARJ==M->CODTARJ
						append blank
						aeval( aaux, {|a,i| fieldput(i,TA->(fieldget(i)))} )
						X->MARCA := " "
						X->REGISTRO := TA->(recno())
					endif
					skip 1 alias TA
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
* 							 nReg:=recno()
* 							 sum MONTO to M->MONTO for TA->MARCA==""
* 							 go nReg
						OTC := OCH:GETCOLUMN( 5 )
						OTC:FOOTING := TRANS(M->MONTO,"#######.##")
						OTC:FOOTSEP := "Ä"
						OCH:SETCOLUMN( 5, OTC )
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
						select TA
						fflock()
						do while ROSCA() .and. !X->(eof())
							if X->MARCA#" "
								go X->REGISTRO
								if op2==1
									replace TA->ESTADO with "PRE", TA->FECHPRES with M->FECHA
								elseif op2 == 2
									replace TA->ESTADO with "COB", TA->FECHCOBRO with M->FECHA
								endif
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
		endif
		dbcommitall()
		select TA
		SET ORDER TO TA_FECHPAGO_TURNO
		DBGOTO(nReg)
		oX:RefreshAll()

	ELSEIF OX:Cargo[TB_RET] == K_ALT_E
		TBCOLEDIT( "CAMBIAR", "TARJETAS", OX, aedits, "EDITS.EST" )

	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
  select TA
	DBUNLOCKALL()

ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN



***************************

FUNC FEDTAR( ATAR, K, _fc )

***************************
LOCAL r := .F., xmenu

xmenu:=MENUDOWN({"     º PgUp PgDown º presione TAB para obtener una º   ESC    ",;
	"       º             º lista de opciones. (solo fun- º          ",;
	" mueve º    mueve+   º ciona en los campos con  ).  º   sale   "})

ATAR[ED_EDIT] := UPPER( ATAR[ED_EDIT] )
IF K == K_F2 .OR. K == K_ENTER
	IF !EMPTY(_fc)
		ATAR[ED_EDIT] := LOWER( ATAR[ED_EDIT] )
	ENDIF
ELSEIF K==K_F5
	IF EMPTY(_fc)
		EDPONE(ATAR,"TA->FECHPAGO",VA->FECHA)
	ENDIF
ENDIF
ATAR[ED_MODE] = "MOSTRARTODO"
DO WHILE .T.
	FEDITAR( ATAR, { 9 } )

	IF ATAR[ED_UPDATE]
		ATAR[ED_MODE] = "MOSTRAR"
	ELSEIF ATAR[ED_TECLA] == K_TAB
		ATAR[ED_MODE] = "MOSTRAR"
		IF EDNOM(ATAR) == "TA->CODTARJ"
			e = ABRW( ATAR[ED_Y], ATAR[ED_X], 0, 'vtarjeta', EDCONT(ATAR), 'TARJETAS')
			IF LASTKEY() == K_ENTER
				EDPONE(ATAR,,LEFT( vtarjeta[e], 3 ))
			ENDIF
		ELSEIF EDNOM(ATAR) == "TA->CODCLI"
			IF FELEGIR( "CLIENTE", M->CODCLI ) # 0
				M->CODCLI = CL->CODCLI
				EDPONE(ATAR,,CL->RAZONSOC)
				EDPONE( ATAR, "TA->CODCLI", CL->CODCLI )
				ATAR[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ATAR) == "TA->TARJETAPARA"
			IF FELEGIR( "PROVEE", M->CODPROV ) # 0
				EDPONE(ATAR,,PRV->RAZONSOC)
				EDPONE( ATAR,"TA->CODPROV", PRV->CODPROV )
				ATAR[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ELSEIF EDNOM(ATAR) == "TA->TURNO"
			e = PP_SELEC( ATAR[ED_Y], ATAR[ED_X], 0, 0, aturno, EDCONT(ATAR), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE(ATAR,,LEFT(aturno[e],1))
			ENDIF
			RECUPAN()
		ELSEIF EDNOM(ATAR) == "TA->CODPROV"
			IF FELEGIR( "PROVEE", EDCONT(ATAR) ) # 0
				EDPONE(ATAR,,PRV->CODPROV)
			ENDIF
		ELSEIF EDNOM(ATAR) == "TA->CODEMP"
			IF FELEGIR( "EMPLEADO", EDCONT(ATAR) ) # 0
				EDPONE(ATAR,,EM->CODEMP)
			ENDIF
		ENDIF

	ELSEIF ATAR[ED_TECLA] == K_ESC .OR. ( ATAR[ED_TECLA]==K_ENTER .AND. ATAR[ED_I]==LEN(ATAR[ED_FIELDS]) )
		IF FEDITOR( ATAR, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
			IF aux =="G"
				FEDITOR( ATAR, "GRABAR", .F. )
				r := .T.
				EXIT
			ELSEIF aux == "S"
				r := .F.
				EXIT
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDIF

ENDDO
PONEPAN(xmenu)

RETURN r


*****************************

STATIC FUNC LISTAR( listado )

*****************************
local cBaseAux:=XNAME("XAUX"), nOrd, cBase:=dbf()
select 99;  dbclosearea()

IF listado == "TARJCAR"
	aaux:={};  aeval(vtarjeta,{|a|aadd(aaux,a+" ")}, 1,LV(vtarjeta) )
	if MARCABRW( 7, 30, aaux, len(aaux) ) # 0
		op2 = MENUFLASH( 10, 30, 1, .T., "", "Ordenado X Monto", "Ordenado X Fecha" )
     if lastkey()==K_ENTER
  		aeval( aaux, {|a,i| aaux[i]:=if(right(a,1)=="",left(a,3),"") })
			LISTADOR( "INI" )
			if !SETIMPRESORA("INI");	break(nil);  endif
			do icarga with listado
			select TA
			nOrd := indexord()
			nReg := RECNO()
			set order to TA_ESTADO
			dbseek("CAR",.t.)
			copy to (cBaseAux) rest for MONTO#0.and.ascan(aaux,CODTARJ)#0 while ESTADO=="CAR"
			select 99
			use (cBaseAux) alias X exclusive
     	if op2==1
				index on X->CODTARJ+FTOC(X->FECHPAGO) to (cBaseAux)
     	else
				index on X->CODTARJ+str(X->MONTO) to (cBaseAux)
     	endif
			dbgotop()
			I_codtarj := "@"
			I_TOTAL  := 0
			I_CANT	:= 0
			I_TTOTAL := 0
			I_TCANT  := 0
			do while !eof() .and. !SALIR()
				if I_codtarj # X->CODTARJ
					IF I_codtarj # "@"
						CABEZA( 1 ); ++I_CL
						?  I_esp + ARMOLIN(I_cab+2)
					ENDIF
					CABEZA( 2 ); I_CL += 2
					?
					? I_esp + FVECTOR(vtarjeta,X->CODTARJ)
					I_codtarj = X->CODTARJ
					I_TOTAL := 0
					I_CANT	:= 0
				endif
				CABEZA( 1 ); ++I_CL
				? I_esp + ARMOLIN(I_cab+1)
				I_TOTAL += X->MONTO
				I_TTOTAL += X->MONTO
				++I_CANT
				++I_TCANT
				skip
			enddo
			CABEZA( 5 ); I_CL += 5
			? I_esp + ARMOLIN(I_cab+2)
			?
			I_CANT := I_TCANT
			I_TOTAL := I_TTOTAL
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+2)
			? I_esp + ARMOLIN(I_cab)
			select 99; DBCLOSEAREA()
			select TA
			set order to nOrd
			go nReg
			RECUPAN()
			LISTADOR( "FIN" )
		endif
  endif

ELSEIF listado = "TARJCOB"
	if QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");	break(nil);  endif
		DO ICARGA WITH listado
		select 99; dbclosearea()
		select TA
		nOrd := indexord()
		nReg := RECNO()
		set order to TA_ESTADO
		dbseek("COB")
		copy to (cBaseAux) rest for MONTO#0.and.BETWEEN(FECHCOBRO,DESDE,HASTA)
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
		select TA
		set order to nOrd
		go nReg
		RECUPAN()
		LISTADOR( "FIN" )
  endif
endif
set printer to
set alternate to
set device to screen
set console on

return
