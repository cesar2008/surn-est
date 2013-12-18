#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PRIVATE FACTURA2, aux, auxaux, lastcolor, aaux
LOGO(.T., " PAGO A PROVEEDORES " )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
FBASES({"CCC","COMPRASV","PROVEEV","CHEQEMI","CHEQUES"})
aCpo:={;
		{ "NUMOPAG",        "Orden;Pago",                    '', 'E',  '',  0, 0 },;
		{ "FECHA",          "Fecha; ",                       '', 'E',  '',  0, 0 },;
		{ "APAGAR",         "Total;a Pagar",                 '', 'E',  '',  0, 0 },;
		{ "PAGADO",         "Total;Pagado",                  '', 'E',  '',  0, 0 },;
		{ "SALDOACUM",      "Saldo",                         '', 'E',  '',  0, 0 },;
 		{ "EFECTIVO",       "Efectivo",                      '', 'E',  '',  0, 0 },;
 		{ "CHEQUE",         "Cheque",                        '', 'F',  '',  0, 0 },;
 		{ "TARJETA",        "Tarjeta",                       '', 'E',  '',  0, 0 },;
		{ "OTROS",          "Otros",                         '', 'F',  '',  0, 0 },;
 		{ "DESCR",          "Descr.",                        '', 'F',  '',  0, 0 }}

select CCC
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )

M->CODPROV = CV->CODPROV
M->FECHA := DATE()
if VA->RECALCCCC
	RECALCCOM( {||PRV->RECALCCCC}, .T. )
endif
RECUPAN()

SETCOLOR(C_MENU)
ACC := NEWEDIT( "CCC",,.T. )
DO WHILE .T.
	STORE .T. TO NUEVO, MODIFICABLE
	DO WHILE .T.
		select PR
		set order to 1
		MENUDOWN({"   F7    º    F9    º   TAB    º   ENTER    º ESC ",;
					 "         º recaclc. º lista de º  cuentas   º     ",;
					 "listados º  saldos  º  provee. º corrientes º sale"})
		k := FVERREG( ACC, {|K|K==K_TAB.OR.K==K_ENTER.OR.K==K_ESC.OR.K==K_F8.OR.K==K_F9.OR.K==K_F7.or.chr(k)$'0123456789'} )
		IF K == K_ENTER
			exit

		ELSEIF K==K_F2 .or. chr(K)$'0123456789'
			xmenu:=MENUDOWN({ "  <+>  º   TAB    º   F10    º  ESC   ",;
									"       º tablas de º graba y  º        ",;
									" mueve º opciones  º contin£a º  sale  "})
			FEDITOR(ACC,"LEER")
			ACC[ED_I] := 1
			ACC[ED_REGISTRO] := 0
			ACC[ED_MODE] = "MOSTRARTODO"
			if K#K_F2
				keyboard chr(K)
			endif
			DO WHILE .T.
				FEDITAR( ACC, { K_TAB, K_F10 } )
				IF ACC[ED_UPDATE] .OR. ACC[ED_TECLA] == K_TAB
					ACC[ED_MODE] = "MOSTRARTODO"
					if ACC[ED_TECLA] == K_TAB
						if PROVEEV(,.T.)
							EDPONE(ACC,,PRV->CODPROV)
						endif
					else
						if !dbseek(EDCONT(ACC,"PRV->CODPROV"))
							EDPONE(ACC,,ACC[ED_LAST])
						endif
					endif
				ELSEIF ACC[ED_TECLA]==K_ENTER
					KEYBOARD CHR(K_ENTER)
					EXIT
				ELSEIF ACC[ED_TECLA] == K_ESC
					EXIT
				ENDIF
			ENDDO
			PONEPAN(xmenu)
		elseif k == K_F9
			MENSAJE( 99, 99, 0, .F., " AGUARDE . . . " )
			aaux := {}
			select PR
			nReg:=recno()
			dbgotop()
			select CV
			set order to CV_CODPROV_NUMOPAG
			select CCC
			set order to CCC_CODPROV_FECHA
			do while ROSCA().AND.!PRV->(EOF())
				select CCC
				M->CODPROV := PRV->CODPROV
				dbseek( str(M->CODPROV,flen(CCC->CODPROV)), .T. )
				if CCC->CODPROV == M->CODPROV
					SALDARCCC()
				endif
				nAux:=0
				select CV
				dbseek( str(M->CODPROV,flen(CCC->CODPROV)), .T. )
				do while CV->CODPROV==M->CODPROV .and. empty(CV->NUMOPAG)
					nAux += CV->TOTAL
					skip
				enddo
				fflock("PRV")
				PRV->COMAPAGAR := nAux
				PRV->(dbunlock())
				skip 1 alias PR
			enddo
			select PR
			go nReg
			RECUPAN()
			FVERREG( ACC,, .T. )
		ELSEIF k == K_TAB
			IF PROVEEV(,.T.)
				M->CODPROV = PRV->CODPROV
			ENDIF
		ELSEIF K == K_F7
			op = MENUFLASH( 10, 30, 1, .F., "LISTADOS", "Remitos x Per¡odo", "C.C.a Cobrar", "Detalle de Cobros" )
			IF op == 1
				if MARCARCLI()
					if QUEFECHA2(10,30)
						MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
						select PR; aaux:={};  dbeval( {|| aadd(aaux,PRV->CODPROV)}, {|| PRV->MARCA==''} )
						select CV
						nReg := RECNO()
						nOrden := INDEXORD()
						select CV
						dbsetorder( forder({"FECHA","TURNO"}) )
						dbseek( ftoc(DESDE), .T. )
						cBaseAux:=XNAME("XAUX")
						copy to (cBaseAux) rest for FECHA>=DESDE .and. ascan(aaux,CODPROV)#0 while FECHA<=HASTA
						RECUPAN()
						LISTADOR("REMXCLI")
						select CV
						set order to nOrden
						GO nReg
					endif
				endif
			ELSEIF op == 2
				LISTADOR("CCACOB")
			ELSEIF op == 3
				LISTADOR("OPG2")
			ENDIF
			RECUPAN()
		ELSEIF K == K_ESC
			EXIT
		ENDIF
	ENDDO
	if K == K_ESC;  exit;  endif

	M->CODPROV := PRV->CODPROV
	M->PIVA1 := M->PIVA2 := 0

	MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
	*:
	*: Set‚a las variables y totales por defecto
	*:
	STORE 0 TO M->TPRECBASE, M->PORCDESC, M->TDESCUENTO, M->SUBTOTAL,;
		M->TIMPINT, M->TIVA1, M->TIVA2, M->TOTAL, ;
		M->PAGADO, M->EFECTIVO, M->CHEQUE, M->TARJETA
	M->TIPOVENTA = 2
	M->FECHVENC = VA->FECHA

	select CCC
	set order to FORDER({"CODPROV","FECHA"})
	dbseek( str(M->CODPROV,flen(CCC->CODPROV)), .T. )

	RECUPAN()



	SETCOLOR(C_MENU)
	OX := MYBROWSE( 8, 1, 20, 78, aCpo )
	OX:SKIPBLOCK := { |X| TBWV(X) }
	OX:GOTOPBLOCK	  := { || TBWV(-(LASTREC())) }
	OX:GOBOTTOMBLOCK := { || TBWV(LASTREC()) }
	OX:CARGO[TB_REFRESH] := 10

	MENUDOWN({"  <+>  º   F2   º   F5   º    F9     º  ESC  ",;
				 "       º modif. º agrega º recalcula º       ",;
				 " mueve º o.pago º o.pago º  saldos   º  sale "})

	DO WHILE .T.
		if PRV->RECALCCCC
			RECALCCOM( {||PRV->RECALCCCC}, .F. )
		endif
		FVERREG( ACC,, .T. )
		MOVBROW( OX, {||nK==K_TAB.OR.nK==K_ESC.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F9.OR.nK==K_F6.OR.CHR(nK)$'FfDd'},, {||FIELD->FECHA>VA->FECHSEG} )

		IF OX:Cargo[TB_MSGE] == "MODIF"
			auxtb := FIELD->&(TBNOC(OX))
			FRLOCK()
			FIELD->&(TBNOC(OX)) := OX:CARGO[TB_CONT]
			SALDARCCC()
			TBPOS(OX)

		ELSEIF OX:Cargo[TB_RET]==K_F2 .or. OX:Cargo[TB_RET]==K_F5
     	if EDOPAG( OX:Cargo[TB_RET] )
 				RECALCCOM( {||.T.}, .F. )
				SALDARCCC()
				TBPOS(OX,.T.)
        endif

		ELSEIF OX:Cargo[TB_RET] == K_TAB
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
			afact := {}; xcant:=0
			select CV
			set order to CV_CODPROV_NUMOPAG
			dbseek( str(PRV->CODPROV)+CCC->NUMOPAG )
			do while CV->CODPROV==PRV->CODPROV .and. CV->NUMOPAG==CCC->NUMOPAG .and. !eof()
				if CV->CODPROV # -2 .and. CV->TOTAL#0
					aadd( afact, dtoc(CV->FECHA) +"³"+ CV->NUMFAC +"³"+ str(CV->TOTAL,10,3) + "" )
				endif
				skip
			enddo
			dbseek( str(PRV->CODPROV)+space(len(CCC->NUMOPAG)), .T. )
			do while CV->CODPROV==PRV->CODPROV .and. empty(CV->NUMOPAG) .and. !eof()
				if CV->CODPROV==PRV->CODPROV .and. CV->TOTAL#0
					AADD( afact, dtoc(CV->FECHA) +"³"+ CV->NUMFAC +"³"+ str(CV->TOTAL,10,3) + " " )
				endif
				skip
			enddo
        set order to 1
			select CCC
			asort( afact,,, {|x,y| ctod(left(x,8)) < ctod(left(y,8)) } )
			RECUPAN()
			if len(afact) == 0
				MENSAJE( 0, 0, 10, .T., "NO HAY FACTURAS !!!" )
			else
				ele = PP_SELEC( 10, 20, 0, 0, afact, 1, "", "S", .T.)
           RECUPAN()
			ENDIF

		ELSEIF OX:Cargo[TB_RET] == K_F9
			TBWV(-999)
			SALDARCCC()
			TBPOS(OX,.T.)

		ELSEIF OX:Cargo[TB_RET] == K_F6 .AND. FIELD->FECHA>VA->FECHSEG
     	CHOPG("INI")
        count to nAux for XCH->ESTADO=="DEP"
        if nAux>0
				MENSAJE(0,0,0,.F.,"hay "+str(nAux,2)+" cheques depositados.")
        else
				if PREGUNTA( 12, " ¨ ESTA SEGURO   [ S / N ] ?", "SsNn") $ "Ss"
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					aaux := {}
					select CV
					set order to CV_CODPROV_NUMOPAG
					fflock()
					dbseek(str(CCC->CODPROV)+CCC->NUMOPAG )
					do while CV->CODPROV==CCC->CODPROV .and. CV->NUMOPAG==CCC->NUMOPAG
						CV->NUMOPAG := "OPG"
                 skip
					enddo
					select CCC2
					fflock()
					do while dbseek(str(CCC->CODPROV)+CCC->NUMOPAG)
						blankreg()
					enddo
					select ccv
					blankreg()
					dbseek(str(PRV->CODPROV),.T.)
              if CCC->CODPROV#PRV->CODPROV;  RECUPAN();  exit;  endif
					SALDARCCC()
					RECUPAN()
					CLEARTYPEAHEAD()
					OX:REFRESHALL()
           endif
			endif

		ELSEIF OX:Cargo[TB_RET] == K_ESC
			EXIT
		ENDIF
	ENDDO
	dbunlockall()
	dbcommitall()
	RELLENAPAN(8,0,21,80,"°",C_FONDO)

ENDDO
SELECT PR
SET FILTER TO

RETURN


********************************

FUNC RECALCCOM( bBlock, lTodos )

********************************
local cBase:=dbf(), nReg:=recno()
DEFAULT lTodos TO .F.

select PR
if lTodos;  dbgotop();  endif
select CV
set order to CV_CODPROV_NUMOPAG
do while !PRV->(eof())
	if eval(bBlock)
		nAux:=0
		dbseek( str(PRV->CODPROV)+space(len(CV->NUMOPAG)), .T. )
		do while CV->CODPROV==PRV->CODPROV .and. empty(CV->NUMOPAG)
			nAux += CV->TOTAL
			skip
		enddo
     frlock("PRV")
		PRV->COMAPAGAR := nAux
		PRV->RECALCCCC := .F.
     PRV->(dbunlock())
	endif
  if !lTodos;  exit;  endif
	skip 1 alias PR
enddo
set order to 1
frlock("VA");	VA->RECALCCCC:=.F.
dbunlockall()
select (cBase)
go nReg

return


************

FUNC SALDARCCC

************
LOCAL xreg:=RECNO(), nSaldo

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
FFLOCK()
SKIP -1
IF CCC->CODPROV # M->CODPROV
	GO xreg
ENDIF
IF RECNO() == xreg
	FIELD->SALDO := PRV->SALDOINI + FIELD->APAGAR - FIELD->PAGADO
	FIELD->SALDOACUM := FIELD->SALDO
ENDIF
nSaldo := FIELD->SALDOACUM
SKIP
DO WHILE CCC->CODPROV == M->CODPROV .AND. !EOF()
	FIELD->SALDO := FIELD->APAGAR - FIELD->PAGADO
	FIELD->SALDOACUM := nSaldo + FIELD->SALDO
	nSaldo := FIELD->SALDOACUM
	SKIP
ENDDO
DBGOTO( xreg )
frlock("PRV");	PRV->SALDOACUM:=nSaldo;	PRV->(dbunlock())
FVERREG( ACC,, .T. )
dbunlock()
RECUPAN()

RETURN .T.


***************************

STATIC FUNCTION TBWV(N)

***************************
LOCAL I := 0

IF N == 0 .OR. LASTREC() == 0
	SKIP 0

ELSEIF N > 0 .AND. RECNO() != LASTREC() + 1
	DO WHILE I < N
		SKIP 1
		IF ( EOF() .OR. FIELD->CODPROV # M->CODPROV )
			SKIP -1
			EXIT
		ENDIF
		I++
	ENDDO

ELSEIF N < 0
	DO WHILE I > N
		SKIP -1
		IF FIELD->CODPROV # M->CODPROV
			SKIP
			EXIT
		ELSEIF BOF()
			EXIT
		ENDIF
		I--
	ENDDO

ENDIF

RETURN I


*********************************

FUNC DEUDAXPR( cualcli, _fecha )

*********************************
LOCAL nSaldoCC := nRemNoMarc:=0, nFacNoMarc:=0, cBase:=DBF(), nOrder
DEFAULT _fecha TO ctod('31/12/2100')

* * *   toma el £ltimo saldo acumulado
select CCC
nOrder := INDEXORD()
set order to OPG_CODPROV_FECHA
seek STR(cualcli,FLEN(CCC->CODPROV))
do while CCC->CODPROV==cualcli .and. CCC->FECHA <= _fecha
	nSaldoCC := CCC->SALDOACUM
	skip
enddo
* * *   junta todos los remitos no marcados
select CV
set order to CV_CODPROV_NUMOPAG
seek str(cualcli,FLEN(CCC->CODPROV))
do while FIELD->CODPROV==cualcli .and. empty(FIELD->NUMOPAG)
	if FIELD->CODPROV # -2 .AND. CV->FECHA <= _fecha
		nRemNoMarc += FIELD->TOTAL
	endif
	skip
enddo
**************
#ifdef NADA
	* * *   junta todos las facturas ccv no marcadas
if PRV->CATIVA $ "CF EX "
	cTIPOFAC := "FB"
  FBASES({"+FACB"},.F.)
else
	cTIPOFAC := "FA"
	FBASES({"+FACA"},.F.)
endif
select (cTIPOFAC)
set order to FAC_CODPROV_NUMOPAG
dbseek( str(cualcli,FLEN(CCC->CODPROV)), .T. )
do while FIELD->CODPROV==cualcli
	if left(FIELD->NUMOPAG,3)=='OPG'.and.empty(substr(FIELD->NUMOPAG,4))
		nFacNoMarc += FIELD->TOTAL
  endif
	skip
enddo
#endif
**************
select CCC
set order to nOrder
select (cBase)

return( {nSaldoCC, nRemNoMarc, nFacNoMarc} )


****************

FUNC EDOPAG( K )

****************
local afact := {}, xcant:=0, cAux
xmenu2:=MENUDOWN({"     º      TAB          º   F10   º  ESC   ",;
						 "       º facturas, cheques º graba y º        ",;
						 " mueve º tarjetas          º procede º  sale  "})
AX := NEWEDIT( "OPAG",,.T. )
FEDITOR( AX, "SETVARS", K,.F. )
EDPONE(AX,"CCC->CODPROV",PRV->CODPROV)
IF K==K_F5 .OR. val(EDCONT(AX,"CCC->NUMOPAG"))==0
	EDPONE(AX,"CCC->NUMOPAG",NUEVOCOD(dbf(),"NUMOPAG",1))
ENDIF
*CHCCC("INI")
AX[ED_MODE] = "MOSTRARTODO"
nTab:=0
DO WHILE .T.
	FEDITAR( AX, { K_F10 } )
	IF AX[ED_UPDATE]
		AX[ED_MODE] = "MOSTRAR"
		IF EDNOM(AX) == "CCC->NUMOPAG"
			IF FREPEAT( EDCONT(AX), AX[ED_MODAPP] )
				MENSAJE ( 0, 0, 10, .T.,"N§ O.P. REPETIDO !!! ")
				EDPONE( AX,, AX[ED_LAST] )
				AX[ED_TECLA] := 0
			ENDIF
			AX[ED_MODE] := "MOSTRARTODO"
     ELSE
     	EDPONE( AX, "CCC->PAGADO", EDCONT(AX,"CCC->EFECTIVO")+EDCONT(AX,"CCC->CHEQEMI")+EDCONT(AX,"CCC->CHEQUE")+EDCONT(AX,"CCC->OTROS") )
			AX[ED_MODE] := "MOSTRARTODO"
		ENDIF
	ELSEIF AX[ED_TECLA] == K_TAB
		IF EDNOM(AX) == "CCC->APAGAR"
     	if nTab==0
        	++nTab
				MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
				select CV
				set order to CV_CODPROV_NUMOPAG
				dbseek( str(PRV->CODPROV)+EDCONT(AX,"CCC->NUMOPAG") )
				do while CV->CODPROV==PRV->CODPROV .and. CV->NUMOPAG==EDCONT(AX,"CCC->NUMOPAG") .and. !eof()
					if CV->CODPROV # -2 .and. CV->TOTAL#0
						aadd( afact, dtoc(CV->FECHA) +"³"+ CV->NUMFAC +"³"+ str(CV->TOTAL,10,3) + "" )
					endif
					skip
				enddo
				dbseek( str(PRV->CODPROV)+space(len(CCC->NUMOPAG)), .T. )
				do while CV->CODPROV==PRV->CODPROV .and. empty(CV->NUMOPAG) .and. !eof()
					if CV->CODPROV==PRV->CODPROV .and. CV->TOTAL#0
						AADD( afact, dtoc(CV->FECHA) +"³"+ CV->NUMFAC +"³"+ str(CV->TOTAL,10,3) + " " )
					endif
					skip
				enddo
        	set order to 1
				select CCC
				asort( afact,,, {|x,y| ctod(left(x,8)) < ctod(left(y,8)) } )
				RECUPAN()
        endif
			if len(afact) == 0
				MENSAJE( 0, 0, 10, .T., "NO HAY FACTURAS !!!" )
			else
				xaux := EDCONT(AX,"CCC->APAGAR")
				xmenu:=MENUDOWN({"     º ESPACIO  º     +      º     -      º   ENTER    º ESC  ",;
									  "       º marca y  º   marca    º  desmarca  º pone saldo º      ",;
									  " mueve º desmarca ºhacia abajo ºhacia abajo º en Cta.Cte º sale "})
				ym3 = 7
				xm3 = 40
				RELE := rrel := 0
				modo = 0
 				if EDCONT(AX,"CCC->FECHA") > VA->FECHSEG
					btecla := {|k|k==43.OR.k=45.OR.k=32.OR.k==13}
           else
					btecla := {|k|k==13}
           endif
				ym33 = ym3 + LEN(afact) - 1
				ym33 = IF( ym33+2>20, 20, ym33 )
				xm33 = xm3+LEN(afact[1])
				lastcolor = SETCOLOR("+W/N,N/W")
				MARCO( ym3, xm3, ym33, xm33, "FACTURAS", "S", .T. )
				DO WHILE .T.
					xaux := xcant := 0
					FOR i=1 TO LEN(afact)
						IF right(afact[i],1) == ""
							xaux += VAL(right(afact[i],11))
							++xcant
						ENDIF
					NEXT
					@ ym33+1, xm3+1 SAY xcant PICT "(999)"
					@ ym33+1, xm33-11 SAY xaux PICT "#######.##"
					e = ACHOICE(ym3, xm3, ym33, xm33, afact, .T., "achfunc", RELE, Rrel)
					IF modo == K_SPACE
						IF right(afact[e],1) = " "
							afact[e] := left(afact[e],LEN(afact[e])-1) + ""
						ELSE
							afact[e] := left(afact[e],LEN(afact[e])-1) + " "
						ENDIF
						KEYBOARD CHR(K_DOWN)
					ELSEIF modo == 43
						aux := 0
						FOR i=e TO LEN(afact)
							IF right(afact[i],1) = " "
								afact[i] := left(afact[i],LEN(afact[i])-1) + ""
							ENDIF
						NEXT
					ELSEIF modo == 45
						FOR i=e TO LEN(afact)
							IF right(afact[i],1) == ""
								afact[i] := left(afact[i],LEN(afact[i])-1) + " "
							ENDIF
						NEXT
					ELSEIF modo == K_ESC .OR. modo==K_ENTER
						EXIT
					ENDIF
				ENDDO
				if modo == K_ENTER .AND. EDCONT(AX,"CCC->FECHA")>VA->FECHSEG
					EDPONE(AX,"CCC->APAGAR",xaux)
				endif
				RECUPAN()
				PONEPAN(xmenu)
				CLEARTYPEAHEAD()
				SETCOLOR(lastcolor)
			endif
		elseif EDNOM(AX) == "CCC->CHEQEMI"
			EDPONE(AX,"CCC->CHEQEMI", CHCCC( "ELEGIR", EDCONT(AX,"CCC->CHEQEMI") ))
		endif
		AX[ED_MODE] = "MOSTRARTODO"
	ELSEIF AX[ED_TECLA] == K_ESC .OR. AX[ED_TECLA] == K_F10
		IF AX[ED_TECLA] == K_ESC
			cAux := "S"
			IF FEDITOR( aX, "HUBOCAMBIOS" )
				cAux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
			ENDIF
		ELSE
			cAux :="G"
		ENDIF
		if cAux == "G"
			if "AGREG" $ AX[ED_MODAPP]
				F_ALTA({||val(CCC->NUMOPAG)#0})
			endif
			AX[ED_REGISTRO]:=RECNO()
			FEDITOR(AX,"GRABAR",.F.)
        select CV
        set order to CV_CODPROV_NUMFAC
        for i=1 to len(afact)
        	if dbseek( str(PRV->CODPROV)+substr(afact[i],10,len(CV->NUMFAC)) )
           	frlock()
              CV->NUMOPAG := if(empty(right(afact[i],1)),"",CCC->NUMOPAG)
              dbunlock()
           endif
        next
        set order to 1
        select CCC
			exit
		elseif cAux == "S"
			exit
		endif
	endif
enddo
FEDITOR(AX,"SACAPAN")
MENUDOWN(xmenu2)

return(cAux=="G")


*********************************

STATIC FUNC CHCCC( cModo, nCHEQUE )

*********************************
local cMenu, cMenu2, r
local cBaseAux:=XNAME('XCHE')

if cModo=="INI"
	aaux:=CHE->(dbstruct())
	aadd(aaux,{"MARCA2","C",1,0})
	aadd(aaux,{"MODIFICADO","L",1,0})
	aadd(aaux,{"REGISTRO","N",6,0})
	select 99;	dbclosearea()
	dbcreate(cBaseAux,aaux)
	select 99
	use (cBaseAux) alias XCHE exclusive
	index on XCHE->NUMOPAG+ftoc(XCHE->FECHA) to (cBaseAux)
	select CHE
	set order to CHE_NUMOPAG
	dbseek( CCC->NUMOPAG )
	aaux:=CHE->(dbstruct())
	select XCHE
	do while CHE->NUMOPAG==CCC->NUMOPAG .and. !CHE->(eof())
		append blank
		aeval( aaux, {|a,i| fieldput(i,CHE->(fieldget(i)))} )
		XCHE->MARCA := XCHE->MARCA2 := ""
		XCHE->REGISTRO := CHE->(recno())
		skip 1 alias CHE
	enddo
  select CHE
	set order to CHE_ESTADO
	dbseek( "CAR" )
  select XCHE
	do while CHE->ESTADO == "CAR"
		if CHE->CODPROV==CCC->CODPROV .and. empty(CHE->NUMOPAG)
			append blank
			aeval( aaux, {|a,i| fieldput(i,CHE->(fieldget(i)))} )
			XCHE->MARCA := XCHE->MARCA2 := " "
			XCHE->REGISTRO := CHE->(recno())
		endif
		skip 1 alias CHE
	enddo

elseif cModo=="ELEGIR"
	aCp:={{ "FECHPAGO",	 "Fecha;Emisi¢n", 							'', 'F',  '',	0, 0 },;
			{ "TURNO",		 "T", 											'', 'F',  '',	0, 0 },;
			{ "FVECTOR(vbanco,XCHE->CODBAN)", "Banco; ",				'', 'F',  '',	0, 0 },;
			{ "NUMCHEQUE",  "N§de;Cheque",								'', 'F',  '',	0, 0 },;
			{ "MONTO",		 "Monto; ", 									'', 'F',  '',	0, 0 },;
			{ "FECHA",		 "Fecha;Efect",								'', 'F',  '',	0, 0 },;
			{ "ESTADO", 	 "EST",											'', 'F',  '',	0, 0 },;
			{ "MARCA",		 "M", 											'', 'F',  '',	0, 0 }}
	select XCHE
	aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
	set index to
	locate for XCHE->NUMOPAG2==nPago
	if !found();	append blank;	XCHE->NUMOPAG2:=nPago;  endif
	index on XCHE->FECHPAGO to (cBaseAux) for XCHE->NUMOPAG2==nPago
	DBGOBOTTOM()

	cMenu:=MENUDOWN({" <+> º F2 modif. º  F5  º   F6  º ESPACIO  º  +      -  º ENTER  º ESC  ",;
						  "     º F3 busca  º      º       º marca y  ºmarca/desmarº        º      ",;
						  "mueveº F4 busca+ ºagregaºeliminaº desmarca ºhacia abajo ºconfirmaº sale "})
	SETCOLOR(C_MENU)
	MARCO(10,1,17,65," CHEQUES EN CARTERA ", "S", .T., 0 )
	OCH := MYBROWSE(10,1,17,65, aCp )
	OCH:CARGO[TB_REFRESH] := 0
	OCH:GOBOTTOM()
	TBCOLOR(OCH)
	lDispTot:=lRecontar:=.T.
	M->MARCADOS := M->MONTO:=0
	DO WHILE .T.
		if lRecontar
			M->MONTO:=0
			FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot:=.T.
			lRecontar:=.F.
		endif
		IF lDispTot
			nReg:=recno()
        sum MONTO to M->MONTO for XCHE->MARCA==""
     	go nReg
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
		ELSEIF OCH:Cargo[TB_RET]==K_F2 .or. OCH:Cargo[TB_RET]==K_F5
			cMenu2:=MENUDOWN({"     º PgUp PgDown º presione   º  F10   º ESC  ",;
									"       º             º TAB en cam-º graba  º      ",;
									" mueve º    mueve+   º pos con   º y sale º sale "})
			ACHE := NEWEDIT( "CHEAUX" )
			FEDITOR( ACHE, "SETVARS", OCH:Cargo[TB_RET] )
        ACHE[ED_EDIT]:=if( CCC->FECHA>VA->FECHSEG, upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
			ACHE[ED_EDIT] := if( EDCONT(ACHE,"XCHE->ESTADO")$"CAR   ", upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
			if empty(EDCONT(ACHE,"XCHE->ESTADO"));	EDPONE(ACHE,"XCHE->ESTADO","CAR");  endif
			if empty(EDCONT(ACHE,"XCHE->FECHPAGO"));  EDPONE(ACHE,"XCHE->FECHPAGO",aPago[nPago,OPG_FECHPAGO]);  endif
			ACHE[ED_MODE] := "MOSTRARTODO"
			DO WHILE .T.
				FEDITAR( ACHE, { 9, K_F10 } )
				IF ACHE[ED_UPDATE]
					ACHE[ED_MODE] = "MOSTRAR"
					IF EDNOM(ACHE) == "XCHE->FECHA"
              	IF EDCONT(ACHE,"XCHE->FECHA")<EDCONT(ACHE,"XCHE->FECHPAGO")
							MENSAJE(0,0,10,.T., "LA FECHA DE EFECTIVIZACION","DEBE SER MAYOR O IGUAL A LA DE EMISION !" )
							EDPONE(ACHE,,ACHE[ED_LAST])
                    ACHE[ED_TECLA]:=0
                 ENDIF
              ENDIF
				ELSEIF ACHE[ED_TECLA] == K_TAB
					ACHE[ED_MODE] = "MOSTRAR"
					IF EDNOM(ACHE) == "XCHE->CODBAN"
						e = ABRW( ACHE[ED_Y], ACHE[ED_X], 0, 'vbanco', EDCONT(ACHE), 'BANCOS')
						IF LASTKEY() == K_ENTER
							EDPONE(ACHE,,left( vbanco[e], 3 ))
						ENDIF
					ELSEIF EDNOM(ACHE) == "XCHE->TURNO"
						e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, aturno, EDCONT(ACHE), "", "S", .T.)
						IF LASTKEY() == K_ENTER
							EDPONE(ACHE,,left(aturno[e],1))
						ENDIF
						RECUPAN()
					ENDIF
				ELSEIF ( ACHE[ED_TECLA]==K_ENTER .AND. ACHE[ED_I]==LEN(ACHE[ED_FIELDS]) ) .or. ACHE[ED_TECLA]==K_ESC .or. ACHE[ED_TECLA]==K_F10
					IF ACHE[ED_TECLA]==K_F10
						cAux:="G"
					ELSEIF FEDITOR( ACHE, "HUBOCAMBIOS" )
						cAux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					ENDIF
					IF cAux=="G"
						set order to
						if "AGRE" $ ACHE[ED_MODAPP]
							locate for empty(XCHE->FECHPAGO) .and. !eof()
							ACHE[ED_REGISTRO] := if(found(), recno(),lastrec()+1)
						endif
						FEDITOR( ACHE, "GRABAR", .F. )
						XCHE->MODIFICADO := .T.
						XCHE->NUMOPAG2	 := nPago
						if "AGRE" $ ACHE[ED_MODAPP]
							XCHE->MARCA:=''
						endif
						set order to 1
						reindex
						M->MONTO:=0;  FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
						lDispTot := .T.
						exit
					ELSEIF cAux == "S"
						exit
					ENDIF
				ENDIF
				DBUNLOCK()
			ENDDO
			FEDITOR2( ACHE, "SACAPAN" )
			PONEPAN(cMenu2)
			TBPOS(OCH,.T.)
		ELSEIF OCH:Cargo[TB_RET]==K_F9
			lRecontar := .T.
			TBPOS(OCH,.T.)
		ELSEIF chr(OCH:Cargo[TB_RET])$" +-"
			FMARCA( OCH:Cargo[TB_RET], "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot := .T.
			TBPOS(OCH,.T.)
		ELSEIF OCH:Cargo[TB_RET] == K_F6 .and. CHE->ESTADO$"CAR   "
			if UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
				BLANKREG(.F.,{"NUMOPAG2","REGISTRO","MODIFICADO"})
				lRecontar := .T.
				TBPOS(OCH,.T.)
			endif
		ELSEIF OCH:Cargo[TB_RET] == K_ESC
			replace XCHE->MARCA with XCHE->MARCA2 all
			r := nCHEQUE
			exit
		ELSEIF OCH:Cargo[TB_RET] == K_ENTER
			replace XCHE->MARCA2 with XCHE->MARCA all
			lModifCh:=(nCHEQUE#M->MONTO)
			r := M->MONTO
			exit
		ENDIF
	ENDDO
	RECUPAN()
	PONEPAN(cMenu)
	dbunlockall()
	dbcommitall()

elseif cModo=="GRABAR"
	select XCHE
	dbgotop()
	select CHE
	do while !XCHE->(eof())
		if XCHE->MONTO==0
			if XCHE->REGISTRO#0
				dbgoto(XCHE->REGISTRO);	blankreg()
			endif
		else
			if XCHE->REGISTRO#0
				dbgoto(XCHE->REGISTRO)
			else
				F_ALTA({||!empty(CHE->NUMOPAG)})
			endif
			frlock()
			aeval(dbstruct(),{|a,i|fieldput(i,XCHE->(fieldget(i)))})
			CHE->CODPROV := CCC->CODPROV
			CHE->NUMOPAG := CCC->NUMOPAG
		endif
		skip 1 alias XCHE
	enddo

endif

return r
