#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

parameters op2
private aux, auxaux, lastcolor, aaux
LOGO(.T., " PAGO A PROVEEDORES "+if(op2==2,"COMPRAS VARIAS","") )

MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
F_ABASE({"CO","PRV"},"CERRAR")
if op2==1
	FBASES({"CCC","OPAGO","COMPRAS","PROVEE","CHEQEMI","CHEQUES","BANCO"})
  M->TIPOPROV := "E"
else
	FBASES({"CCC","OPAGO","COMPRASV","PROVEEV","CHEQEMI","CHEQUES","BANCO"})
  M->TIPOPROV := "V"
endif

aCpo:={;
		{ "NUMPAG",         "N§;Pago",                       '', 'E',  '',  0, 0 },;
		{ "FECHA",          "Fecha; ",                       '', 'E',  '',  0, 0 },;
		{ "APAGAR",         "a Pagar",                       '', 'E',  '',  0, 0 },;
		{ "PAGADO",         "Pagado",                        '', 'E',  '',  0, 0 },;
		{ "SALDOACUM",      "Saldo",                         '', 'E',  '',  0, 0 },;
 		{ "EFECTIVO",       "Efectivo",                      '', 'E',  '',  0, 0 },;
 		{ "CHEQEMI",        "Cheque;Emit",                   '', 'F',  '',  0, 0 },;
 		{ "CHEQUE",         "Cheque;Terc",                   '', 'F',  '',  0, 0 },;
 		{ "TARJETA",        "Tarjeta",                       '', 'E',  '',  0, 0 },;
		{ "OTROS",          "Otros",                         '', 'F',  '',  0, 0 }}

select CCC
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )

M->CODPROV = CO->CODPROV
M->FECHA := date()
if VA->RECALCCCC
	RECALCCOM( {||PRV->RECALCCCC}, .T. )
endif
RECUPAN()

SETCOLOR(C_MENU)
ACC := NEWEDIT( "CCC",,.T. )
i:=EDNUM(ACC,"PRV->RAZONSOC");	ACC[ED_PICTS,i]:="@K "+ACC[ED_PICTS,i]
do while .T.
	store .T. to NUEVO, MODIFICABLE
	do while .T.
		select PRV
		set order to 1
		MENUDOWN({"   F7    º    F9    º   TAB    º   ENTER    º ESC ",;
					 "         º recaclc. º lista de º  cuentas   º     ",;
					 "listados º  saldos  º  provee. º corrientes º sale"})
		k := FVERREG( ACC, {|K|K==K_TAB.OR.K==K_ENTER.OR.K==K_ESC.OR.K==K_F8.OR.K==K_F9.OR.K==K_F7.or.chr(k)$'0123456789ABCDEFGHIJKLMN¥OPQRSTUVWXYZ'} )
		if K == K_ENTER
			exit

		elseif K==K_F2 .or. chr(K)$'0123456789ABCDEFGHIJKLMN¥OPQRSTUVWXYZ'
			xmenu:=MENUDOWN({ "  <+>  º   TAB    º   F10    º  ESC   ",;
									"       º tablas de º graba y  º        ",;
									" mueve º opciones  º contin£a º  sale  "})
			FEDITOR(ACC,"LEER")
			ACC[ED_I] := 2
			ACC[ED_REGISTRO] := 0
			ACC[ED_MODE] = "MOSTRARTODO"
			if K#K_F2
				keyboard chr(K)
			endif
			do while .T.
				FEDITAR( ACC, { K_TAB, K_F10 } )
				if ACC[ED_UPDATE] .OR. ACC[ED_TECLA] == K_TAB
					ACC[ED_MODE] = "MOSTRARTODO"
              nAux := 0
					cAux := alltrim(EDCONT(ACC,"PRV->RAZONSOC"))
					if ACC[ED_TECLA] == K_TAB
						if PROVEEV(,.T.)
                 	nAux := PRV->CODPROV
						endif
					elseif val( cAux ) <> 0
						if dbseek( val(cAux) )
                 	nAux := PRV->CODPROV
						endif
					else
						MENSAJE( 0,0, 0, .F., "buscando "+cAux+"..." )
              	aaux := {}
						locate for cAux $ PRV->RAZONSOC
                 do while found()
							aadd( aaux, str(PRV->CODPROV) +'³' +PRV->RAZONSOC )
							continue
                 enddo
                 RECUPAN()
                 if len(aaux)==1
                    nAux := val(aaux[1])
                 elseif len(aaux)>1
        				setcolor(C_MENU)
							ele = PP_SELEC( 10, 20, 0, 0, aaux, 1, "", "S", .T.)
           			RECUPAN()
                    if lastkey()==K_ENTER
                    	nAux := val(aaux[ele])
                    endif
                 endif
					endif
              if nAux == 0
						MENSAJE( 0,0,10, .T., "NO SE ENCONTRO !", cAux )
						EDPONE(ACC,,ACC[ED_LAST])
              else
              	dbseek(nAux)
						EDPONE(ACC,"PRV->CODPROV",PRV->CODPROV)
						EDPONE(ACC,"PRV->RAZONSOC",PRV->RAZONSOC)
              endif
				elseif ACC[ED_TECLA]==K_ENTER
					KEYBOARD CHR(K_ENTER)
					exit
				elseif ACC[ED_TECLA] == K_ESC
					exit
				endif
			enddo
			PONEPAN(xmenu)
		elseif k == K_F8
			op2 = MENUFLASH( 10, 15, 1, .F., "UTILIDADES", "Pone Nombre de Proveedor en concepto de los Cheques Emitidos" )
			if op2 == 1
				MENSAJE( 0,0, 0, .F., "AGUARDE..." )
           select CCC
           nReg:=recno()
           dbgotop()
           select CHE
           nOrder:=indexord()
           set order to CHE_NUMOPAG
           fflock()
           do while ROSCA() .and. !CCC->(eof())
           	if dbseek(CCC->NUMOPAG)
              	CHE->CONCEPTO:=FPROV(CCC->CODPROV)
              endif
           	skip 1 alias CCC
           enddo
           dbunlock()
           set order to nOrder
           select CCC
           go nReg
        	RECUPAN()
        endif
		elseif k == K_F9
			MENSAJE( 99, 99, 0, .F., "AGUARDE..." )
			aaux := {}
			select PRV
			nReg:=recno()
			dbgotop()
			select CO
			set order to CO_CODPROV_NUMPAG
			select CCC
			set order to CCC_CODPROV_FECHA
			do while ROSCA().AND.!PRV->(EOF())
				select CCC
				M->CODPROV := PRV->CODPROV
				dbseek( M->TIPOPROV+str(M->CODPROV,flen(CCC->CODPROV)), .T. )
				if CCC->TIPOPROV==M->TIPOPROV .and. CCC->CODPROV==M->CODPROV
					SALDARCCC()
				endif
				skip 1 aliAS PRV
			enddo
			select PRV
			go nReg
			RECUPAN()
			FVERREG( ACC,, .T. )
		elseif k == K_TAB
			if PROVEEV(,.T.)
				M->CODPROV = PRV->CODPROV
			endif
		elseif K == K_F7
			op = MENUFLASH( 10, 30, 1, .F., "LISTADOS", "Estado de Cta","Detalle de Pagos","SD de Egresos" )
			if op == 1
				if MARCARPROV()
					if QUEFECHA2(10,30)
						LISTAR("CCC")
					endif
				endif
			elseif op == 2
				if MARCARPROV()
					if QUEFECHA2(10,30)
						LISTAR("CCCD")
					endif
				endif
			elseif op == 3
				if QUEFECHA2(10,30)
					LISTAR("SDEGRE")
				endif
			endif
			RECUPAN()
		elseif K == K_ESC
			exit
		endif
	enddo
	if K == K_ESC;  exit;  endif

	MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
	*:
	*: Set‚a las variables y totales por defecto
	*:
	M->CODPROV := PRV->CODPROV
	store 0 to M->TPRECBASE, M->PORCDESC, M->TDESCUENTO, M->SUBTOTAL,;
		M->PAGADO, M->EFECTIVO, M->CHEQUE, M->TARJETA
	M->TIPOVENTA = 2
	M->FECHVENC = VA->FECHA

	select CCC
	set order to CCC_TIPOPROV_CODPROV_FECHA
	dbseek( M->TIPOPROV+str(M->CODPROV,flen(CCC->CODPROV)), .T. )
	RECUPAN()



	SETCOLOR(C_MENU)
	OX := MYBROWSE( 8, 1, 20, 78, aCpo )
	OX:SKIPBLOCK := { |X| TBWV(X) }
	OX:GOTOPBLOCK	  := { || TBWV(-(lastrec())) }
	OX:GOBOTTOMBLOCK := { || TBWV(lastrec()) }
	OX:CARGO[TB_REFRESH] := 10

	MENUDOWN({"  <+>  º   F2   º   F5   º    F9     º  ESC  ",;
				 "       º modif. º agrega º recalcula º       ",;
				 " mueve º pago   º  pago  º  saldos   º  sale "})
	do while .T.
  	if CCC->TIPOPROV==M->TIPOPROV .and. CCC->CODPROV==M->CODPROV
			if PRV->RECALCCCC
				RECALCCOM( {||PRV->RECALCCCC}, .F. )
			endif
			FVERREG( ACC,, .T. )
			MOVBROW( OX, {||nK==K_TAB.OR.nK==K_ESC.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F9.OR.nK==K_F6.OR.CHR(nK)$'FfDd'},, {||FIELD->FECHA>VA->FECHSEG} )
     else
			OX:Cargo[TB_RET]:=K_F5
  	endif

		if OX:Cargo[TB_MSGE] == "MODIF"
			auxtb := FIELD->&(TBNOC(OX))
			FRLOCK()
			FIELD->&(TBNOC(OX)) := OX:CARGO[TB_CONT]
			SALDARCCC()
			TBPOS(OX)

		elseif OX:Cargo[TB_RET]==K_F2 .or. OX:Cargo[TB_RET]==K_F5
     	if EDPAG( OX:Cargo[TB_RET] )
 				RECALCCOM( {||.T.}, .F. )
				SALDARCCC()
        else
  			if CCC->TIPOPROV#M->TIPOPROV .or. CCC->CODPROV#M->CODPROV
           	exit
        	endif
        endif
			TBPOS(OX,.T.)

		elseif OX:Cargo[TB_RET] == K_TAB
			MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
			private afact := {}; xcant:=0
			select CO
			set order to CO_CODPROV_NUMPAG
			dbseek( str(PRV->CODPROV)+CCC->NUMPAG )
			do while CO->CODPROV==PRV->CODPROV .and. CO->NUMPAG==CCC->NUMPAG .and. !eof()
				if CO->CODPROV # -2 .and. CO->TOTAL#0
					aadd( afact, dtoc(CO->FECHA) +"³"+ CO->NUMFAC +"³"+ str(CO->TOTAL,10,3) + "" )
				endif
				skip
			enddo
			dbseek( str(PRV->CODPROV)+space(len(CCC->NUMPAG)), .T. )
			do while CO->CODPROV==PRV->CODPROV .and. empty(CO->NUMPAG) .and. !eof()
				if CO->CODPROV==PRV->CODPROV .and. CO->TOTAL#0
					AADD( afact, dtoc(CO->FECHA) +"³"+ CO->NUMFAC +"³"+ str(CO->TOTAL,10,3) + " " )
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
        	setcolor(C_MENU)
				ele = PP_SELEC( 10, 20, 0, 0, afact, 1, "", "S", .T.)
           RECUPAN()
			endif

		elseif OX:Cargo[TB_RET] == K_F9
			TBWV(-999)
			SALDARCCC()
			TBPOS(OX,.T.)

		elseif OX:Cargo[TB_RET] == K_F6 .and. FIELD->FECHA>VA->FECHSEG
     	if CCC->CHEQEMI#0 .or. CCC->CHEQUE#0 .or. CCC->TARJETA#0
				MENSAJE(0,0,0,.F.,"primero hay que desmarcar o borrar","los las O.P. de este pago !")
        else
				if PREGUNTA( 12, " ¨ ESTA SEGURO   [ S / N ] ?", "SsNn") $ "Ss"
					MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
					aaux := {}
					select CO
					set order to CO_CODPROV_NUMPAG
					fflock()
					do while dbseek( str(CCC->CODPROV)+CCC->NUMPAG )
						CO->NUMPAG := ""
                 skip 0
					enddo
					dbunlock()
					select CCC
					blankreg()
					dbseek(M->TIPOPROV+str(PRV->CODPROV),.T.)
              if CCC->TIPOPROV#M->TIPOPROV .or. CCC->CODPROV#PRV->CODPROV;  RECUPAN();  exit;  endif
					SALDARCCC()
					RECUPAN()
					CLEARTYPEAHEAD()
					OX:REFRESHALL()
           endif
			endif

		elseif OX:Cargo[TB_RET] == K_ESC
			exit
		endif
	enddo
	dbunlockall()
	dbcommitall()
	RELLENAPAN(8,0,21,80,"°",C_FONDO)

enddo
select PRV
set filter to

return


********************************

FUNC RECALCCOM( bBlock, lTodos )

********************************
local cBase:=dbf(), nReg:=recno()
DEFAULT lTodos to .F.

select PRV
if lTodos;  dbgotop();  endif
select CO
set order to CO_CODPROV_NUMPAG
do while !PRV->(eof())
	if eval(bBlock)
		nAux:=0
		dbseek( str(PRV->CODPROV)+space(len(CO->NUMPAG)), .T. )
		do while CO->CODPROV==PRV->CODPROV .and. empty(CO->NUMPAG)
			nAux += CO->TOTAL
			skip
		enddo
     frlock("PRV")
		PRV->COMAPAGAR := nAux
		PRV->RECALCCCC := .F.
     PRV->(dbunlock())
	endif
  if !lTodos;  exit;  endif
	skip 1 aliAS PRV
enddo
set order to 1
if lTodos
	frlock("VA");	VA->RECALCCCC:=.F.
endif
dbunlockall()
select (cBase)
go nReg

return


**************

FUNC SALDARCCC

**************
local xreg:=recno(), nSaldo

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
FFLOCK()
skip -1
if CCC->TIPOPROV # M->TIPOPROV .or. CCC->CODPROV # M->CODPROV
	GO xreg
endif
if recno() == xreg
	FIELD->PAGADO := FIELD->EFECTIVO + FIELD->CHEQEMI + FIELD->CHEQUE + FIELD->TARJETA + FIELD->OTROS
	FIELD->SALDO := PRV->SALDOINI + FIELD->APAGAR - FIELD->PAGADO
	FIELD->SALDOACUM := FIELD->SALDO
endif
nSaldo := FIELD->SALDOACUM
skip
do while CCC->TIPOPROV==M->TIPOPROV .and. CCC->CODPROV==M->CODPROV .AND. !EOF()
	FIELD->PAGADO := FIELD->EFECTIVO + FIELD->CHEQEMI + FIELD->CHEQUE + FIELD->TARJETA + FIELD->OTROS
	FIELD->SALDO := FIELD->APAGAR - FIELD->PAGADO
	FIELD->SALDOACUM := nSaldo + FIELD->SALDO
	nSaldo := FIELD->SALDOACUM
	skip
enddo
dbgoto( xreg )
frlock("PRV");	PRV->SALDOACUM:=nSaldo;	PRV->(dbunlock())
FVERREG( ACC,, .T. )
dbunlock()
RECUPAN()

return .T.



***************************

STATIC FUNCTION TBWV(N)

***************************
LOCAL I := 0

if N == 0 .OR. lastrec() == 0
	skip 0

elseif N > 0 .AND. recno() != lastrec() + 1
	do while I < N
		skip 1
		if ( EOF() .OR. FIELD->TIPOPROV # M->TIPOPROV .or. FIELD->CODPROV # M->CODPROV )
			skip -1
			exit
		endif
		I++
	enddo

elseif N < 0
	do while I > N
		skip -1
		if FIELD->TIPOPROV # M->TIPOPROV .or. FIELD->CODPROV # M->CODPROV
			skip
			exit
		elseif BOF()
			exit
		endif
		I--
	enddo

endif

return I

***************************

STATIC FUNCTION TBWV2(N)

***************************
LOCAL I := 0

if N == 0 .OR. lastrec() == 0
	skip 0

elseif N > 0 .AND. recno() != lastrec() + 1
	do while I < N
		skip 1
		if EOF() .OR. FIELD->NUMOPAG # M->NUMOPAG
			skip -1
			exit
		endif
		I++
	enddo

elseif N < 0
	do while I > N
		skip -1
		if FIELD->NUMOPAG # M->NUMOPAG
			skip
			exit
		elseif BOF()
			exit
		endif
		I--
	enddo

endif

return I


*********************************

FUNC DEUDAXPR( cualprov, _fecha )

*********************************
LOCAL nSaldoCC := nRemNoMarc:=0, nFacNoMarc:=0, cBase:=dbf(), nOrder
DEFAULT _fecha to ctod('31/12/2100')

* * *   toma el £ltimo saldo acumulado
select CCC
nOrder := INDEXORD()
set order to OPG_CODPROV_FECHA
seek M->TIPOPROV+STR(cualprov,LEN_CODPROV)
do while CCC->TIPOPROV==M->TIPOPROV .and. CCC->CODPROV==cualprov .and. CCC->FECHA <= _fecha
	nSaldoCC := CCC->SALDOACUM
	skip
enddo
* * *   junta todos los remitos no marcados
select CO
set order to CO_CODPROV_NUMPAG
seek str(cualprov,LEN_CODPROV)
do while FIELD->CODPROV==cualprov .and. empty(FIELD->NUMPAG)
	if FIELD->CODPROV # -2 .AND. CO->FECHA <= _fecha
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
set order to FAC_CODPROV_NUMPAG
dbseek( str(cualprov,LEN_CODPROV), .T. )
do while FIELD->CODPROV==cualprov
	if left(FIELD->NUMPAG,3)=='OPG'.and.empty(substr(FIELD->NUMPAG,4))
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


***************

FUNC EDPAG( K )

***************
local afact := {}, xcant:=0, cAux
xmenu2:=MENUDOWN({"     º    TAB    º   F10   º  ESC   ",;
						 "       º facturass º graba y º        ",;
						 " mueve º   O.P.    º procede º  sale  "})
AX := NEWEDIT( "PAGOSCCC",,.T. )
FEDITOR( AX, "SETVARS", K,.F. )
EDPONE(AX,"CCC->CODPROV",M->CODPROV)
EDPONE(AX,"CCC->TIPOPROV",M->TIPOPROV)
if K==K_F5 .OR. val(EDCONT(AX,"CCC->NUMPAG"))==0
	EDPONE(AX,"CCC->NUMPAG",NUEVOCOD(dbf(),"NUMPAG",CCC_NUMPAG))
	EDPONE(AX,"CCC->FECHA",date())
  if procname(1)=="COM"
		EDPONE(AX,"CCC->FECHA",CO->FECHA)
		afact := { dtoc(CO->FECHA) +"³"+ CO->NUMFAC +"³"+ str(CO->TOTAL,10,3) + "" }
		EDPONE(AX,"CCC->APAGAR",CO->TOTAL)
  endif
endif
M->NUMPAG := EDCONT(AX,"CCC->NUMPAG")
OPAG("INI")
CHECCC("INI")

AX[ED_MODE] = "MOSTRARTODO"
nTab:=0
do while .T.
  EDPONE( AX, "CCC->PAGADO", EDCONT(AX,"CCC->EFECTIVO")+EDCONT(AX,"CCC->CHEQEMI")+EDCONT(AX,"CCC->CHEQUE")+EDCONT(AX,"CCC->OTROS") )
	FEDITAR( AX, { K_F10 } )
	if AX[ED_UPDATE]
		AX[ED_MODE] = "MOSTRAR"
		if EDNOM(AX) == "CCC->NUMPAG"
			if FREPEAT( EDCONT(AX), AX[ED_MODAPP] )
				MENSAJE ( 0, 0, 10, .T.,"N§ PAGO REPETIDO !!! ")
				EDPONE( AX,, AX[ED_LAST] )
				AX[ED_TECLA] := 0
			endif
			AX[ED_MODE] := "MOSTRARTODO"
     else
			AX[ED_MODE] := "MOSTRARTODO"
		endif
	elseif AX[ED_TECLA] == K_TAB
		if EDNOM(AX) == "CCC->APAGAR"
     	if nTab==0
        	++nTab
				MENSAJE( 0, 0, 0, .F., "AGUARDE..." )
				select CO
				set order to CO_CODPROV_NUMPAG
				dbseek( str(PRV->CODPROV)+EDCONT(AX,"CCC->NUMPAG") )
				do while CO->CODPROV==PRV->CODPROV .and. CO->NUMPAG==EDCONT(AX,"CCC->NUMPAG") .and. !eof()
					if CO->CODPROV # -2 .and. CO->TOTAL#0
						aadd( afact, dtoc(CO->FECHA) +"³"+ CO->NUMFAC +"³"+ str(CO->TOTAL,10,3) + "" )
					endif
					skip
				enddo
				dbseek( str(PRV->CODPROV), .T. )
				do while CO->CODPROV==PRV->CODPROV .and. empty(CO->NUMPAG) .and. !eof()
					if CO->CODPROV==PRV->CODPROV .and. CO->TOTAL#0
						aadd( afact, dtoc(CO->FECHA) +"³"+ CO->NUMFAC +"³"+ str(CO->TOTAL,10,3) + " " )
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
				lastcolor = SETCOLOR(C_GET)
				MARCO( ym3, xm3, ym33, xm33, "FACTURAS", "S", .T. )
				do while .T.
					xaux := xcant := 0
					for i=1 to LEN(afact)
						if right(afact[i],1) == ""
							xaux += VAL(right(afact[i],11))
							++xcant
						endif
					next
					@ ym33+1, xm3+1 SAY xcant PICT "(999)"
					@ ym33+1, xm33-11 SAY xaux PICT "#######.##"
					e = ACHOICE(ym3, xm3, ym33, xm33, afact, .T., "achfunc", RELE, Rrel)
					if modo == K_SPACE
						if right(afact[e],1) = " "
							afact[e] := left(afact[e],LEN(afact[e])-1) + ""
						else
							afact[e] := left(afact[e],LEN(afact[e])-1) + " "
						endif
						KEYBOARD CHR(K_DOWN)
					elseif modo == 43
						aux := 0
						for i=e to LEN(afact)
							if right(afact[i],1) = " "
								afact[i] := left(afact[i],LEN(afact[i])-1) + ""
							endif
						next
					elseif modo == 45
						for i=e to LEN(afact)
							if right(afact[i],1) == ""
								afact[i] := left(afact[i],LEN(afact[i])-1) + " "
							endif
						next
					elseif modo == K_ESC .OR. modo==K_ENTER
						exit
					endif
				enddo
				if modo == K_ENTER .AND. EDCONT(AX,"CCC->FECHA")>VA->FECHSEG
					EDPONE(AX,"CCC->APAGAR",xaux)
				endif
				RECUPAN()
				PONEPAN(xmenu)
				CLEARTYPEAHEAD()
				SETCOLOR(lastcolor)
			endif
		elseif EDNOM(AX) == "CCC->PAGADO"
     	M->APAGAR := EDCONT(AX,"CCC->APAGAR")
			M->MARCADOS:= M->EFECTIVO:= M->CHEQEMI:= M->CHEQUE:= M->TARJETA:= M->OTROS:= 0
			OPAG("ELEGIR")
        EDPONE(AX,"CCC->EFECTIVO",M->EFECTIVO)
        EDPONE(AX,"CCC->CHEQEMI",M->CHEQEMI)
        EDPONE(AX,"CCC->CHEQUE",M->CHEQUE)
        EDPONE(AX,"CCC->TARJETA",M->TARJETA)
        EDPONE(AX,"CCC->OTROS",M->OTROS)
        select CCC
		endif
		AX[ED_MODE] = "MOSTRARTODO"
	elseif AX[ED_TECLA] == K_ESC .OR. AX[ED_TECLA] == K_F10
		if AX[ED_TECLA] == K_ESC
			cAux := "S"
			if FEDITOR( aX, "HUBOCAMBIOS" )
				cAux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
			endif
		else
			cAux :="G"
		endif
     select CCC
		if cAux == "G"
			if "AGREG" $ AX[ED_MODAPP]
				F_ALTA({||val(CCC->NUMPAG)#0})
			endif
			AX[ED_REGISTRO]:=recno()
			FEDITOR(AX,"GRABAR",.F.)
        select CO
        set order to CO_CODPROV_NUMFAC
        for i=1 to len(afact)
        	cAux := substr( afact[i], at("³",afact[i])+1,len(CO->NUMFAC) )
        	if dbseek( str(M->CODPROV,LEN_CODPROV)+cAux )
           	frlock()
					if right(afact[i],1) == ""
						CO->NUMPAG := CCC->NUMPAG
              else
              	CO->NUMPAG := ""
              endif
              dbunlock()
           	skip
           endif
        next
			OPAG("GRABAR")
			CHECCC("GRABAR")
        set order to 1
        select CCC
        cAux := "G"
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

STATIC FUNC OPAG( cModo, nCHEQUE )

*********************************
local cMenu, cMenu2, r
local cBaseAux:=XNAME('XOPG')

if cModo=="INI"
	aaux:=OPG->(dbstruct())
	aadd(aaux,{"MARCA","C",1,0})
	aadd(aaux,{"MARCA2","C",1,0})
	aadd(aaux,{"MODIFICADO","L",1,0})
	aadd(aaux,{"REGISTRO","N",6,0})
	select 99;	dbclosearea()
	dbcreate(cBaseAux,aaux)
	select 99
	use (cBaseAux) alias XOPG exclusive
	index on XOPG->NUMOPAG+ftoc(XOPG->FECHA) to (cBaseAux)
	select OPG
	set order to OPG_NUMPAG
	dbseek( M->NUMPAG )
	aaux:=OPG->(dbstruct())
	select XOPG
	do while OPG->NUMPAG==M->NUMPAG .and. !OPG->(eof())
		append blank
		aeval( aaux, {|a,i| fieldput(i,OPG->(fieldget(i)))} )
		XOPG->MARCA := XOPG->MARCA2 := ""
		XOPG->REGISTRO := OPG->(recno())
		skip 1 alias OPG
	enddo

elseif cModo=="ELEGIR"
	aCp:={{ "NUMOPAG",    "N§;O.P.",       				'', 'F',  '',	0, 0 },;
			{ "FECHA",      "Fecha; ",				         '', 'F',  '',	0, 0 },;
			{ "TURNO",		 "T", 								'', 'F',  '',	0, 0 },;
			{ "EFECTIVO", 	 "Efectivo", 						'', 'F',  '',	0, 0 },;
			{ "CHEQEMI", 	 "Cheques;Emitidos",				'', 'F',  '',	0, 0 },;
			{ "CHEQUE", 	 "Cheques;Tercero",				'', 'F',  '',	0, 0 },;
			{ "OTROS",  	 "Otros",              			'', 'F',  '',	0, 0 },;
			{ "MARCA",		 "M", 								'', 'F',  '',	0, 0 }}
	select XOPG
	aCp := FBASEAUX( aCp, dbf(), select(), .F. )
	dbgotop()

	cMenu:=MENUDOWN({" <+> º F2 modif. º  F5  º   F6  º ESPACIO  º  +      -  º ENTER  º ESC  ",;
						  "     º F3 busca  º      º       º marca y  ºmarca/desmarº        º      ",;
						  "mueveº F4 busca+ ºagregaºeliminaº desmarca ºhacia abajo ºconfirmaº sale "})
	SETCOLOR(C_MENU)
	MARCO(10,1,17,65," ORDENES DE PAGO ", "S", .T., 0 )
	OOPG := MYBROWSE(10,1,17,65, aCp )
	OOPG:CARGO[TB_REFRESH] := 0
	OOPG:GOBOTTOM()
	TBCOLOR(OOPG)
	lDispTot:=lRecontar:=.T.
	do while .T.
		if lRecontar
			M->MARCADOS:= M->EFECTIVO:= M->CHEQEMI:= M->CHEQUE:= M->TARJETA:= M->OTROS:= 0
			FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->EFECTIVO+=(FIELD->EFECTIVO*n),M->CHEQEMI+=(FIELD->CHEQEMI*n),M->CHEQUE+=(FIELD->CHEQUE*n),M->OTROS+=(FIELD->OTROS*n)})
			lDispTot:=.T.
			lRecontar:=.F.
		endif
		if lDispTot
			nReg:=recno()
        sum EFECTIVO, CHEQEMI, CHEQUE, OTROS to M->EFECTIVO, M->CHEQEMI, M->CHEQUE, M->OTROS for XOPG->MARCA==""
     	go nReg
			OTC := OOPG:GETCOLUMN( 4 )
			OTC:FOOTING := TRANS(M->EFECTIVO,"#######.##")
			OTC:FOOTSEP := "Ä";  OOPG:SETCOLUMN( 4, OTC )
			OTC := OOPG:GETCOLUMN( 5 )
			OTC:FOOTING := TRANS(M->CHEQEMI,"#######.##")
			OTC:FOOTSEP := "Ä";  OOPG:SETCOLUMN( 5, OTC )
			OTC := OOPG:GETCOLUMN( 6 )
			OTC:FOOTING := TRANS(M->CHEQUE,"#######.##")
			OTC:FOOTSEP := "Ä";  OOPG:SETCOLUMN( 6, OTC )
			OTC := OOPG:GETCOLUMN( 7 )
			OTC:FOOTING := TRANS(M->OTROS,"#######.##")
			OTC:FOOTSEP := "Ä";  OOPG:SETCOLUMN( 7, OTC )
			lDispTot := .F.
			TBPOS(OOPG,.t.)
		endif
		@ 18, 1 say "Marc."+str(M->MARCADOS,4) color "+"+C_FONDO
		@ 18,50 say "Total"+str(M->EFECTIVO+ M->CHEQEMI+ M->CHEQUE+ M->TARJETA+ M->OTROS,10,2)  color "+"+C_FONDO
		MOVBROW( OOPG, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_F9.OR.nK==K_ESC.OR.chr(nK)$" +-".or.nK==K_ENTER} )
		if OOPG:Cargo[TB_MSGE] == "MODIF"
			FRLOCK()
			FIELD->&(TBNOC(OOPG)) := OOPG:CARGO[TB_CONT]
			TBPOS(OOPG)
		elseif OOPG:Cargo[TB_RET]==K_F2 .or. OOPG:Cargo[TB_RET]==K_F5
			EDOPAG( OOPG:Cargo[TB_RET] )
			if OOPG:Cargo[TB_RET] == K_F5
        	XOPG->MARCA := ""
        endif
			lRecontar := .T.
			TBPOS(OOPG,.T.)
		elseif OOPG:Cargo[TB_RET] == K_F9
			lRecontar := .T.
			lDispTot := .T.
			TBPOS(OOPG,.T.)
		elseif chr(OOPG:Cargo[TB_RET])$" +-"
			lRecontar := .T.
			lDispTot := .T.
			TBPOS(OOPG,.T.)
		elseif OOPG:Cargo[TB_RET] == K_F6
			if UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
				BLANKREG(.F.,{"NUMPAG","REGISTRO","MODIFICADO"})
				lRecontar := .T.
				TBPOS(OOPG,.T.)
			endif
		elseif OOPG:Cargo[TB_RET] == K_ESC
			replace XOPG->MARCA with XOPG->MARCA2 all
			exit
		elseif OOPG:Cargo[TB_RET] == K_ENTER
			replace XOPG->MARCA2 with XOPG->MARCA all
			exit
		endif
	enddo
	RECUPAN()
	PONEPAN(cMenu)
	dbunlockall()
	dbcommitall()

elseif cModo=="GRABAR"
	select XOPG
	dbgotop()
	select OPG
  set order to OPG_NUMPAG
	do while !XOPG->(eof())
		if XOPG->PAGADO==0
			if XOPG->REGISTRO#0
				dbgoto(XOPG->REGISTRO);  blankreg()
			endif
		else
			if XOPG->REGISTRO#0
				dbgoto(XOPG->REGISTRO)
			else
				F_ALTA({||!empty(OPG->NUMPAG)})
			endif
			frlock()
*			aeval(dbstruct(),{|a,i|if(fieldget(i)==NIL,,fieldput(i,XOPG->(fieldget(i))))})
        for i=1 to fcount()
        	OPG->&(field(i)) := XOPG->&(field(i))
        next
        OPG->TIPOPROV := M->TIPOPROV
			OPG->CODPROV  := CCC->CODPROV
			OPG->NUMPAG   := CCC->NUMPAG
		endif
		skip 1 alias XOPG
	enddo

endif

return r


****************

FUNC EDOPAG( K )

****************
local afact := {}, xcant:=0, cAux
xmenu2:=MENUDOWN({"     º   TAB    º   F10   º  ESC   ",;
						 "       º cheques  º graba y º        ",;
						 " mueve º tarjetas º procede º  sale  "})
select XOPG
AX2 := NEWEDIT( "OPAG",,.T. )
FEDITOR( AX2, "SETVARS", K,.F. )
EDPONE(AX2,"XOPG->CODPROV",M->CODPROV)
EDPONE(AX2,"XOPG->TIPOPROV",M->TIPOPROV)
M->NUMOPAG := EDCONT(AX2,"XOPG->NUMOPAG")
if K==K_F5
	nAux := val(NUEVOCOD("OPG","NUMOPAG",OPG_NUMOPAG))
	M->NUMOPAG := NUEVOCOD("XOPG","NUMOPAG",1)
  M->NUMOPAG := strzero( max( val(M->NUMOPAG), nAux ), 6 )
	EDPONE( AX2, "XOPG->FECHA", EDCONT(AX,"CCC->FECHA") )
  if procname(1)=="COM"
		EDPONE(AX2,"XOPG->FECHA",CO->FECHA)
		afact := { dtoc(CO->FECHA) +"³"+ CO->NUMFAC +"³"+ str(CO->TOTAL,10,3) + "" }
		EDPONE(AX2,"XOPG->APAGAR",CO->TOTAL)
  endif
endif
EDPONE(AX2,"XOPG->NUMOPAG",M->NUMOPAG)
*CHECCC("INI")

AX2[ED_MODE] = "MOSTRARTODO"
nTab:=0
do while .T.
  EDPONE( AX2, "XOPG->PAGADO", EDCONT(AX2,"XOPG->EFECTIVO")+EDCONT(AX2,"XOPG->CHEQEMI")+EDCONT(AX2,"XOPG->CHEQUE")+EDCONT(AX2,"XOPG->OTROS") )
	FEDITAR( AX2, { K_F10 } )
	if AX2[ED_UPDATE]
		AX2[ED_MODE] = "MOSTRAR"
		if EDNOM(AX2) == "XOPG->NUMOPAG"
			if FREPEAT( EDCONT(AX2), AX2[ED_MODAPP] )
				MENSAJE ( 0, 0, 10, .T.,"N§ O.P. REPETIDO !!! ")
				EDPONE( AX2,, AX2[ED_LAST] )
				AX2[ED_TECLA] := 0
			endif
			AX2[ED_MODE] := "MOSTRARTODO"
     else
			AX2[ED_MODE] := "MOSTRARTODO"
		endif
	elseif AX2[ED_TECLA] == K_TAB
		if EDNOM(AX2) == "XOPG->CHEQEMI"
			EDPONE(AX2,"XOPG->CHEQEMI", CHECCC( "ELEGIR", EDCONT(AX2,"XOPG->CHEQEMI") ))
		elseif EDNOM(AX2) == "XOPG->CHEQUE"
			EDPONE(AX2,"XOPG->CHEQUE", CHCCCC( "ELEGIR", EDCONT(AX2,"XOPG->CHEQUE") ))
		endif
		AX2[ED_MODE] = "MOSTRARTODO"
	elseif AX2[ED_TECLA] == K_ESC .OR. AX2[ED_TECLA] == K_F10
		if AX2[ED_TECLA] == K_ESC
			cAux := "S"
			if FEDITOR( aX, "HUBOCAMBIOS" )
				cAux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
			endif
		else
			cAux :="G"
		endif
     select XOPG
		if cAux == "G"
			if "AGREG" $ AX2[ED_MODAPP]
				append blank
			endif
			AX2[ED_REGISTRO]:=recno()
			FEDITOR(AX2,"GRABAR",.F.)
*			CHECCC( "GRABAR" )
        select XOPG
			exit
		elseif cAux == "S"
			exit
		endif
	endif
enddo
FEDITOR(AX2,"SACAPAN")
MENUDOWN(xmenu2)

return(cAux=="G")


*********************************

STATIC FUNC CHECCC( cModo, nCHEQUE )

*********************************
local cMenu, cMenu2, r
local cBaseAux:=XNAME('XCHE')

if cModo=="INI"
	aaux:=CHE->(dbstruct())
	aadd(aaux,{"MARCA2","C",1,0})
	aadd(aaux,{"MODIFICADO","L",1,0})
	aadd(aaux,{"REGISTRO","N",6,0})
	select 100;	dbclosearea()
	dbcreate(cBaseAux,aaux)
	select 100
	use (cBaseAux) alias XCHE exclusive
	index on XCHE->NUMOPAG+ftoc(XCHE->FECHEMI) to (cBaseAux)
  XOPG->(dbgotop())
  do while !XOPG->(eof())
		select CHE
		set order to CHE_NUMOPAG
		dbseek( XOPG->NUMOPAG )
		aaux:=CHE->(dbstruct())
		select XCHE
		do while CHE->NUMOPAG==XOPG->NUMOPAG .and. !CHE->(eof())
			append blank
			aeval( aaux, {|a,i| fieldput(i,CHE->(fieldget(i)))} )
			XCHE->MARCA := XCHE->MARCA2 := ""
			XCHE->REGISTRO := CHE->(recno())
			skip 1 alias CHE
		enddo
     skip 1 alias XOPG
  enddo
  select CHE
	set order to CHE_ESTADO
	dbseek( "EMI" )
  select XCHE
	do while CHE->ESTADO == "EMI"
		if CHE->CODPROV==CCC->CODPROV .and. empty(CHE->NUMOPAG)
			append blank
			aeval( aaux, {|a,i| fieldput(i,CHE->(fieldget(i)))} )
			XCHE->MARCA := XCHE->MARCA2 := " "
			XCHE->REGISTRO := CHE->(recno())
		endif
		skip 1 alias CHE
	enddo

elseif cModo=="ELEGIR"
	aCp:={{ "FECHEMI",    "Fecha;Emisi¢n", 							'', 'F',  '',	0, 0 },;
			{ "TURNO",		 "T", 											'', 'F',  '',	0, 0 },;
			{ "FBAN(XCHE->CODBAN)", "Banco; ",				         '', 'F',  '',	0, 0 },;
			{ "NUMCHEQ",    "N§de;Cheque",								'', 'F',  '',	0, 0 },;
			{ "MONTO",		 "Monto; ", 									'', 'F',  '',	0, 0 },;
			{ "FECHPAGO",	 "Fecha;Efect",								'', 'F',  '',	0, 0 },;
			{ "ESTADO", 	 "EST",											'', 'F',  '',	0, 0 },;
			{ "MARCA",		 "M", 											'', 'F',  '',	0, 0 }}
	select XCHE
	aCp := FBASEAUX( aCp, dbf(), select(), .F. )
	set index to
	locate for XCHE->NUMOPAG==M->NUMOPAG
	if !found();	append blank;	XCHE->NUMOPAG:=M->NUMOPAG;  endif
	index on XCHE->FECHEMI to (cBaseAux) for XCHE->NUMOPAG==M->NUMOPAG
	dbgobottom()

	cMenu:=MENUDOWN({" <+> º F2 modif. º  F5  º   F6  º ESPACIO  º  +      -  º ENTER  º ESC  ",;
						  "     º F3 busca  º      º       º marca y  ºmarca/desmarº        º      ",;
						  "mueveº F4 busca+ ºagregaºeliminaº desmarca ºhacia abajo ºconfirmaº sale "})
	SETCOLOR(C_MENU)
	MARCO(10,1,17,65," CHEQUES EN CARTERA ", "S", .T., 0 )
	OCH := MYBROWSE(10,1,17,65, aCp )
	OCH:SKIPBLOCK := { |X| TBWV2(X) }
	OCH:GOTOPBLOCK	  := { || TBWV2(-(lastrec())) }
	OCH:GOBOTTOMBLOCK := { || TBWV2(lastrec()) }
	OCH:CARGO[TB_REFRESH] := 0
	OCH:GOBOTTOM()
	TBCOLOR(OCH)
	lDispTot:=lRecontar:=.T.
	M->MARCADOS := M->MONTO:=0
	do while .T.
		if lRecontar
			M->MONTO:=0
			FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot:=.T.
			lRecontar:=.F.
		endif
		if lDispTot
			nReg:=recno()
        sum MONTO to M->MONTO for XCHE->MARCA==""
     	go nReg
			OTC := OCH:GETCOLUMN( 5 )
			OTC:FOOTING := TRANS(M->MONTO,"#######.##")
			OTC:FOOTSEP := "Ä"
			OCH:SETCOLUMN( 5, OTC )
			lDispTot := .F.
			TBPOS(OCH,.t.)
		endif
		@ 18,55 say "Marc."+str(M->MARCADOS,4) color "+"+C_FONDO
		MOVBROW( OCH, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_F9.OR.nK==K_ESC.OR.chr(nK)$" +-".or.nK==K_ENTER} )
		if OCH:Cargo[TB_MSGE] == "MODIF"
			FRLOCK()
			FIELD->&(TBNOC(OCH)) := OCH:CARGO[TB_CONT]
			TBPOS(OCH)
		elseif OCH:Cargo[TB_RET]==K_F2 .or. OCH:Cargo[TB_RET]==K_F5
			cMenu2:=MENUDOWN({"     º PgUp PgDown º presione   º  F10   º ESC  ",;
									"       º             º TAB en cam-º graba  º      ",;
									" mueve º    mueve+   º pos con   º y sale º sale "})
			ACHE := NEWEDIT( "CHEAUX" )
			FEDITOR( ACHE, "SETVARS", OCH:Cargo[TB_RET] )
*       ACHE[ED_EDIT]:=if( CCC->FECHA>VA->FECHSEG, upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
        ACHE[ED_EDIT]:=if( EDCONT(AX2,"XOPG->FECHA")>VA->FECHSEG, upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
			ACHE[ED_EDIT] := if( EDCONT(ACHE,"XCHE->ESTADO")$"EMI   ", upper(ACHE[ED_EDIT]), lower(ACHE[ED_EDIT]) )
			if empty(EDCONT(ACHE,"XCHE->ESTADO"));	EDPONE(ACHE,"XCHE->ESTADO","EMI");  endif
			if empty(EDCONT(ACHE,"XCHE->FECHEMI"));  EDPONE(ACHE,"XCHE->FECHEMI",EDCONT(AX2,"XOPG->FECHA"));  endif
			ACHE[ED_MODE] := "MOSTRARTODO"
			do while .T.
				FEDITAR( ACHE, { 9, K_F10 } )
				if ACHE[ED_UPDATE]
					ACHE[ED_MODE] = "MOSTRAR"
					if EDNOM(ACHE) == "XCHE->FECHEMI"
              	if EDCONT(ACHE,"XCHE->FECHEMI")<EDCONT(ACHE,"XCHE->FECHPAGO")
							MENSAJE(0,0,10,.T., "LA FECHA DE EFECTIVIZACION","DEBE SER MAYOR O IGUAL A LA DE EMISION !" )
							EDPONE(ACHE,,ACHE[ED_LAST])
                    ACHE[ED_TECLA]:=0
                 endif
              endif
				elseif ACHE[ED_TECLA] == K_TAB
					ACHE[ED_MODE] = "MOSTRAR"
					if EDNOM(ACHE) == "XCHE->CODBAN"
						if BAN( ACHE[ED_Y], ACHE[ED_X], EDCONT(ACHE) )
							EDPONE(ACHE,, BA->CODBAN )
						endif
					elseif EDNOM(ACHE) == "XCHE->TURNO"
						e = PP_SELEC( ACHE[ED_Y], ACHE[ED_X], 0, 0, aturno, EDCONT(ACHE), "", "S", .T.)
						if LASTKEY() == K_ENTER
							EDPONE(ACHE,,left(aturno[e],1))
						endif
						RECUPAN()
					endif
				elseif ( ACHE[ED_TECLA]==K_ENTER .AND. ACHE[ED_I]==LEN(ACHE[ED_FIELDS]) ) .or. ACHE[ED_TECLA]==K_ESC .or. ACHE[ED_TECLA]==K_F10
           	cAux := "S"
					if ACHE[ED_TECLA]==K_F10
						cAux:="G"
					elseif FEDITOR( ACHE, "HUBOCAMBIOS" )
						cAux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
					endif
					if cAux=="G"
						set order to
						if "AGRE" $ ACHE[ED_MODAPP]
							locate for empty(XCHE->FECHEMI) .and. !eof()
							ACHE[ED_REGISTRO] := if(found(), recno(),lastrec()+1)
						endif
						FEDITOR( ACHE, "GRABAR", .F. )
						XCHE->MODIFICADO := .T.
						XCHE->NUMOPAG	  := M->NUMOPAG
						XCHE->CONCEPTO	  := FPROV(CCC->CODPROV)
						if "AGRE" $ ACHE[ED_MODAPP]
							XCHE->MARCA:=''
						endif
						set order to 1
						reindex
						M->MONTO:=0;  FMARCA( K_F9, "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
						lDispTot := .T.
						exit
					elseif cAux == "S"
						exit
					endif
				endif
				DBUNLOCK()
			enddo
			FEDITOR2( ACHE, "SACAPAN" )
			PONEPAN(cMenu2)
			TBPOS(OCH,.T.)
		elseif OCH:Cargo[TB_RET]==K_F9
			lRecontar := .T.
			TBPOS(OCH,.T.)
		elseif chr(OCH:Cargo[TB_RET])$" +-"
			FMARCA( OCH:Cargo[TB_RET], "M->MARCADOS", {||.T.},{|n|M->MONTO+=(FIELD->MONTO*n)})
			lDispTot := .T.
			TBPOS(OCH,.T.)
		elseif OCH:Cargo[TB_RET] == K_F6 .and. CHE->ESTADO$"EMI   "
			if UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
				BLANKREG(.F.,{"NUMOPAG","REGISTRO","MODIFICADO"})
				lRecontar := .T.
				TBPOS(OCH,.T.)
			endif
		elseif OCH:Cargo[TB_RET] == K_ESC
			replace XCHE->MARCA with XCHE->MARCA2 all
			r := nCHEQUE
			exit
		elseif OCH:Cargo[TB_RET] == K_ENTER
			replace XCHE->MARCA2 with XCHE->MARCA all
			lModifCh:=(nCHEQUE#M->MONTO)
			r := M->MONTO
			exit
		endif
	enddo
	RECUPAN()
	PONEPAN(cMenu)
	dbunlockall()
	dbcommitall()

elseif cModo=="GRABAR"
	select XCHE
	dbgotop()
	select CHE
	do while !XCHE->(eof())
		if XCHE->MONTO==0 .or. empty(XcHE->MARCA)
			if XCHE->REGISTRO#0
				dbgoto(XCHE->REGISTRO);  blankreg()
			endif
		else
			if XCHE->REGISTRO#0
				dbgoto(XCHE->REGISTRO)
			else
				F_ALTA({||!empty(CHE->NUMOPAG)})
			endif
			frlock()
*			aeval(dbstruct(),{|a,i|if(fieldget(i)==NIL,,fieldput(i,XCHE->(fieldget(i))))})
        for i=1 to fcount()
        	CHE->&(field(i)) := XCHE->&(field(i))
        next
        CHE->TIPOPROV := M->TIPOPROV
			CHE->CODPROV  := M->CODPROV
		endif
		skip 1 alias XCHE
	enddo

endif

return r

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nReg:=PRV->CODPROV

if listado == "CCC"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	DO ICARGA WITH listado
	PRV->(dbgotop())
  select CCC
	do while !PRV->(eof())
  	if PRV->MARCA==""
     	lAux := .T.
     	dbseek( M->TIPOPROV+str(PRV->CODPROV,LEN_CODPROV)+ftoc(DESDE), .T. )
        do while CCC->TIPOPROV==M->TIPOPROV .and. CCC->CODPROV==PRV->CODPROV .and. BETWEEN(CCC->FECHA,DESDE,HASTA) .and. !CCC->(eof())
        	if lAux
					CABEZA( 1 );  I_CL+=1
					? I_esp + ARMOLIN(I_cab+1)
           endif
				CABEZA( 1 );  I_CL+=1
				? I_esp + ARMOLIN(I_cab+2)
     		lAux := .F.
        	skip 1 alias CCC
        enddo
     endif
		skip 1 alias PRV
	enddo
	CABEZA( 1 )
	I_CL += 1
	?  I_esp + ARMOLIN(I_cab)
	LISTADOR( "FIN" )

elseif listado == "CCCD"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	DO ICARGA WITH listado
	PRV->(dbgotop())
  select CCC
	do while !PRV->(eof())
  	if PRV->MARCA==""
     	aaux:={0,0,0}
     	dbseek( M->TIPOPROV+str(PRV->CODPROV,LEN_CODPROV)+ftoc(DESDE), .T. )
        do while CCC->TIPOPROV==M->TIPOPROV .and. CCC->CODPROV==PRV->CODPROV .and. BETWEEN(CCC->FECHA,DESDE,HASTA) .and. !CCC->(eof())
        	if ++aaux[1]==1
              if I_INI
						CABEZA( 2 );  I_CL+=2
              else
						CABEZA( 3 );  I_CL+=3
              	? I_esp+replic( "-", len(LI[I_cab]) )
              endif
              ?
					? I_esp + ARMOLIN(I_cab+1)
           endif
				CABEZA( 3 );  I_CL+=3
           ?;  ?
				? I_esp + ARMOLIN(I_cab+2)
           	//  comprobantes
           select CO
				dbsetorder( CO_CODPROV_NUMPAG )
				dbseek( str(PRV->CODPROV)+CCC->NUMPAG )
				do while CO->CODPROV==PRV->CODPROV .and. CO->NUMPAG==CCC->NUMPAG .and. !eof()
					if CO->CODPROV # -2 .and. CO->TOTAL#0
              	if ++aaux[2]==1
							CABEZA( 3 );  I_CL+=3
                    ?
							? I_esp + ARMOLIN(I_cab+3)
							? I_esp + ARMOLIN(I_cab+4)
                 endif
						CABEZA( 1 );  I_CL+=1
						? I_esp + ARMOLIN(I_cab+5)
					endif
					skip 1 alias CO
				enddo
           	// O.P.
				select OPG
				set order to OPG_NUMPAG
				dbseek( CCC->NUMPAG )
				do while OPG->NUMPAG==CCC->NUMPAG .and. !OPG->(eof())
              if ++aaux[3]==1
						CABEZA( 3 );  I_CL+=3
                 ?
						? I_esp + ARMOLIN(I_cab+6)
						? I_esp + ARMOLIN(I_cab+7)
              endif
					CABEZA( 1 );  I_CL+=1
					? I_esp + ARMOLIN(I_cab+8)
					skip
           enddo
        	skip 1 alias CCC
        enddo
     endif
		skip 1 alias PRV
	enddo
*	CABEZA( 1 );  I_CL += 1
*	?  I_esp + ARMOLIN(I_cab)
	LISTADOR( "FIN" )

elseif listado == "SDEGRE"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	DO ICARGA WITH listado
	select CHE
  set order to CHE_FECHA
  dbseek( ftoc(DESDE), .T. )
	if BETWEEN(CHE->FECHEMI,DESDE,HASTA)
		CABEZA( 3 );  I_CL+=3
     ?
		? I_esp + "CHEQUES EMITIDOS"
		? I_esp + ARMOLIN(I_cab)
  endif
  M->TOTAL := M->TOTAL2 := 0
	do while BETWEEN(CHE->FECHEMI,DESDE,HASTA) .and. !CHE->(eof())
		CABEZA( 1 );  I_CL+=1
		? I_esp + ARMOLIN(I_cab+1)
     M->TOTAL  += CHE->MONTO
     M->TOTAL2 += CHE->MONTO
		skip
	enddo
  if M->TOTAL # 0
		CABEZA( 2 );  I_CL+=2
		? I_esp + strtran(ARMOLIN(I_cab),"=","-")
		? I_esp + ARMOLIN(I_cab+3)
  endif

  set order to 1
	select OPG
  set order to OPG_FECHA_TURNO
  dbseek( ftoc(DESDE), .T. )
	if BETWEEN(OPG->FECHA,DESDE,HASTA)
		CABEZA( 3 );  I_CL+=3
     ?
		? I_esp + "EFECTIVO"
		? I_esp + ARMOLIN(I_cab)
  endif
  M->TOTAL := 0
	do while BETWEEN(OPG->FECHA,DESDE,HASTA) .and. !OPG->(eof())
  	if OPG->EFECTIVO#0
			CABEZA( 1 );  I_CL+=1
			? I_esp + ARMOLIN(I_cab+2)
     	M->TOTAL  += OPG->EFECTIVO
     	M->TOTAL2 += OPG->EFECTIVO
     endif
		skip
	enddo
  if M->TOTAL # 0
		CABEZA( 2 );  I_CL+=2
		? I_esp + strtran(ARMOLIN(I_cab),"=","-")
		? I_esp + ARMOLIN(I_cab+3)
  endif
  set order to 1
  if M->TOTAL2 # 0
		CABEZA( 4 );  I_CL+=4
     M->TOTAL := M->TOTAL2
     ?
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+3)
		? I_esp + ARMOLIN(I_cab)
  endif
	LISTADOR( "FIN" )

endif
PRV->(dbgoto( nReg ))
RECUPAN()

return
