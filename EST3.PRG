#include "EST.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"
#include "EDI.CH"
#include "ERROR.CH"
#include "PRINTER.CH"
#include "COMMON.CH"
#define  lxp		60
#define  ES_LASER_TINTA    ("LASER"$EST->TIPOIMPR .or. "TINT"$EST->TIPOIMPR)

*************

PROC LISTADOR

*************
parameters listado, nh, vertxt
local nOrder, nReg, cAux
private base, xreg

IF listado # "FIN"
	SEMAFORO("OFF")
	PUBLIC block, UT_largo, I_ancho, I_cab, I_seteo, I_esp, I_largo, lVertxt, I_pie
	PUBLIC I_NH      := 0
	PUBLIC I_INI     := .T.
	PUBLIC I_prihoja := .T.
	PUBLIC I_CL      := UT_largo + 1
	PUBLIC I_LMAS    := 0
	PUBLIC I_IMPRIMIO := .F.
	PUBLIC I_CIERRE := .T.
	PUBLIC I_errores := 3
 	public bLastErr := ErrorBlock()
*	public bErr     := ErrorBlock( { |eObj| PRINT_ERROR(eObj) } )
	IF listado == "INI"
		RETURN
	ENDIF
ENDIF

IF listado # "FIN"
begin sequence

	IF listado $ "COMPRAS PERCIIBB" .OR. "COMPV"$listado .OR. listado=="PROVEE" .OR. listado=="COMXPRD" .OR. listado=="DCOMXPRD"
		LISTCOM(listado)

	ELSEIF listado == "VALSTOCK"
     HASTA := DATE()
     MARCO( 10, 20, 10, 60, "", "S", .T. )
     SET(_SET_CURSOR,SC_ON)
     SET(_SET_CONFIRM,.T.)
     @10,20 SAY "Hasta Fecha:" GET HASTA
     READ
     RECUPAN()
     IF LASTKEY() == K_ENTER
			MENSAJE( 99, 99, 0, .F., "RECALCULANDO STOCK..." )
        ***************
     	restscr := 1
        select 99;	dbclosearea()
    		select PRD
     	nReg := RECNO()
     	cBaseAux := XNAME('XX')
     	copy to (cBaseAux) fields CODPROD,DESCPROD,RUBRO,CONDEP,STOCKACT,STOCKINI,;
										                    FECHA,PRECCOMPRA,IMPINT,PRECBASE,PRECVENTA FOR CODPROD#0	//CONSTOCK=='S'
     	GO nReg
        select 99
     	use (cBaseAux) alias X exclusive
     	replace X->STOCKACT with X->STOCKINI all
     	index on X->CODPROD to (cBaseAux)

     	++restscr
			verindex = .T.
    		FBASES({"COMPRAS2"})
        select CO2
        set order to
			INIVER(" COMPRAS ",6,10,60)
     	dbgotop()
     	select X
     	do while !CO2->(EOF())
     		seek CO2->CODPROD
        	if found() .and. CO2->FECHA>=X->FECHA .and. CO2->FECHA<=HASTA
        		X->STOCKACT  += CO2->CANTIDAD
        	endif
				VER('')
        	skip 1 alias CO2
			enddo

     	++restscr
    		FBASES({"PLAN2"})
			select PL2
        set order to
			INIVER(" PLANILLAS ",8,10,60)
     	dbgotop()
     	select X
     	do while !PL2->(EOF()) .and. PL2->FECHA<=HASTA
     		seek PL2->CODPROD
        	if found() .and. PL2->FECHA>=X->FECHA
        		X->STOCKACT -= PL2->CANTIDAD
        	endif
				VER('')
        	skip 1 alias PL2
			enddo

     	++restscr
    		FBASES({"AJUSTES"})
        select AJ
			INIVER(" AJUSTES ",10,10,60)
     	dbgotop()
     	select X
     	do while !AJ->(EOF())
     		seek AJ->CODPROD
        	if found() .and. AJ->FECHA>=X->FECHA .and. AJ->FECHA<=HASTA
        		X->STOCKACT += AJ->CANTIDAD
        	endif
				VER('')
        	skip 1 alias AJ
			enddo
     	FOR i=1 TO restscr
     		RECUPAN()
     	NEXT
        ****************
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			select X
			GO TOP
			nCANTIDAD := 0
			nTPRECCOMPRA := 0
			nTPRECBASE   := 0
			nTIMPINT     := 0
			nTPRECVENTA  := 0
			do while !eof() .and. !SALIR()
        	if X->STOCKACT # 0
					CABEZA(1); I_CL += 1
					? I_esp + ARMOLIN(I_cab+1)
					nTPRECCOMPRA  += X->PRECCOMPRA * X->STOCKACT
					nTPRECBASE    += X->PRECBASE * X->STOCKACT
					nTIMPINT      += X->IMPINT * X->STOCKACT
					nTPRECVENTA   += X->PRECVENTA * X->STOCKACT
        		++nCANTIDAD
           endif
				skip
			enddo
			CABEZA( 2 )
			I_CL += 2
			?  I_esp + strtran(ARMOLIN(I_cab),"=","-")
			?  I_esp + ARMOLIN(I_cab+2)
     	RECUPAN()
     ENDIF
		
	ELSEIF listado = "CCV2"
		if MARCARCLI()
			if QUEFECHA2( 10, 25 )
				DO ICARGA WITH listado
				if !SETIMPRESORA("INI");  break(nil);  endif
				select CL
	        	nReg:=recno()
				go top
				do while !CL->(eof())
					store 0 to TTOTAL, TPAGADO			&& cuando cambio de cliente pongo en 0
					if CL->MARCA==""
						CABEZA( 2 );  I_CL+=2
						?
						? I_esp+alltrim(str(CL->CODCLI)), CL->RAZONSOC
						select CCV2
						set order to 1
						select CCV
						set order to forder({"CODCLI","FECHA"})
						dbseek(str(CL->CODCLI)+ftoc(DESDE),.T.)
						do while CCV->CODCLI==CL->CODCLI .and. BETWEEN(CCV->FECHA,DESDE,HASTA) .and. !CCV->(eof())
							CABEZA( 1 );  I_CL+=1
							? I_esp + ARMOLIN(I_cab+1)
							I_aux := 0
							CCV2->(dbseek(CCV->NUMCOB,.T.))
							do while CCV2->NUMCOB==CCV->NUMCOB .and. !CCV2->(eof())
								if I_aux==0
									CABEZA( 3 );  I_CL+=3
									? I_esp + ARMOLIN(I_cab+2)
									? I_esp + ARMOLIN(I_cab+3)
									? I_esp + ARMOLIN(I_cab+4)
								endif
								CABEZA( 1 );  I_CL+=1
								? I_esp + ARMOLIN(I_cab+5)
								++I_aux
								skip 1 alias CCV2
							enddo
							if I_aux>0
								CABEZA( 1 );  I_CL+=1
								?
							endif
*			aremito := JUNTARFAC("SOLO MARCADO")
*			for I_z:=1 to len(aRemito)
*								CABEZA( 1 );  I_CL+=1
*								? I_esp + ARMOLIN(I_cab+6)
*			next i
							skip 1 alias CCV
		                enddo
	                 endif
					skip 1 alias CL
				enddo
	        	CL->(dbgoto(nReg))
				RECUPAN()
			endif
		endif

	ELSEIF listado == "PLANDIF"
 		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
  	select X;  dbgotop()
  	do while !eof()
     	if X->DIFERENCIA#0
				CABEZA( 1 ); ++I_CL
				? I_esp + ARMOLIN(I_cab+1)
        endif
  		skip
     enddo
*		CABEZA( 2 ); I_CL += 2
*		? I_esp + ARMOLIN(I_cab)
*		? I_esp + ARMOLIN(I_cab+2)
  	RECUPAN()

	ELSEIF listado == "X"
 		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
  	FOR nTurno=1 TO 3
  		aTotal[nTurno] := aTicket[nTurno]+aFactura[nTurno]
			CABEZA( 1 ); ++I_CL
			? I_esp + ARMOLIN(I_cab+1)
  	NEXT
		CABEZA( 2 ); I_CL += 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+2)
  	RECUPAN()


	ELSEIF listado = "REMXCLI"
     I_SETON  := ""
     I_SETOFF := ""
     I_seteo  := ""
     IF !EST->SALIDA $ "PAN TXT "
			IF ES_LASER_TINTA
*          I_SETON  := CHR(27)+"(sïB"
*          I_SETOFF := CHR(27)+"(soïB"
				I_seteo = CHR(27)+"E"+ CHR(27) + "(s15H"
        ELSE
     		I_SETON  := CHR(27)+"G"
     		I_SETOFF := CHR(27)+"H"
     		I_seteo  := CHR(27)+CHR(77)+CHR(15)
        ENDIF
     ENDIF
  	SELECT 99
     USE (cBaseAux) ALIAS X EXCLUSIVE
		INDEX ON FCLIENTE(X->CODCLI)+FTOC(X->FECHA)+X->TURNO TO (cBaseAux)
     if !SETIMPRESORA("INI");  break(nil);  endif
     GO TOP
     M->TOTAL := M->TTOTAL := cant := tcant := aux := 0
    	baux := {|| AADD(aaux, "Remito     Fecha    T      Total"),;
              	AADD(aaux, "========== ======== = ==========") }
     aaux:={}; EVAL(baux)
     DO WHILE !EOF()
     	IF aux # X->CODCLI
        	IF aux # 0
        		IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF		//
              AADD( aaux, I_SETON+"             ("+STR(cant,4)+") - "+STR(M->TOTAL,10,2)+I_SETOFF )
           ENDIF
        	IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF			//
     		AADD( aaux, SPACE(LEN(aaux[1])) )
        	IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF			//
     		AADD( aaux, I_SETON+ JUSTIF(ALLTRIM(STR(X->CODCLI,4))+")"+FCLIENTE(X->CODCLI),LEN(aaux[1]),"="," ") +I_SETOFF )
           aux := X->CODCLI
        	M->TOTAL := cant := 0
        ENDIF
        IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF				//
     	AADD( aaux, "  "+STRZERO(X->NUMFAC,8) +" "+ DTOC(X->FECHA) +" "+ X->TURNO +" "+ STR(X->TOTAL,10,2) )
        M->TOTAL  += X->TOTAL; ++cant
        M->TTOTAL += X->TOTAL; ++tcant
			SKIP
     ENDDO
     IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF					//
     AADD( aaux, I_SETON+ "             ("+STR(cant,4)+") - "+STR(M->TOTAL,10,2) +I_SETOFF )
		i := 0
     DO WHILE i<=LEN(aaux)
     	? I_seteo
     	?
 			? "      REMITOS X CLIENTES"
 			? "      =================="
 			? "      DESDE:", DESDE
 			? "      HASTA:", HASTA
        ?
     	FOR h=1 TO lxp
           aux:=""
        	FOR x=0 TO 3
        		aux += IF( (i+h)+x*lxp<=LEN(aaux), "     "+aaux[(i+h)+x*lxp], "" )
        	NEXT
           IF !EMPTY(aux); ? aux; ENDIF
     	NEXT
        ?; ?; ?; ?
        i += lxp*4
     ENDDO
     IF MOD(LEN(aaux),lxp)==0; EVAL(baux); ENDIF					//
     ? CHR(18)+"  ("+ STR(tcant,4) +")  TOTAL GENERAL:=", STR(M->TTOTAL,15,2)
     DBCLOSEAREA()
		I_LMAS = 0
		I_CIERRE := .F.
     I_IMPRIMIO := .T.
     RECUPAN()


	ELSEIF listado == "COMBUST"
		IF QUEFECHA2( 10, 25 )
     	INVENTARIAR( {||PRD->RUBRO==1} )
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
        SELECT PRD
        GO TOP
        SELECT X
        DO WHILE !PRD->(EOF()) .AND. !SALIR()
     		IF PRD->RUBRO==1
					I_CL = UT_largo + 1
        		I_COMPRAS := I_VENTAS := I_AJUSTES := I_ACUM := 0
          		DBSEEK( STR(PRD->CODPROD)+FTOC(DESDE), .T. )
           	DO WHILE X->CODPROD==PRD->CODPROD .AND. X->FECHA>=DESDE .AND.X->FECHA<=HASTA .AND. !SALIR()
						CABEZA( 1 ); ++I_CL
						? I_esp + ARMOLIN(I_cab+1)
              	I_ACUM    += I_ACUM + X->COMPRAS - X->VENTAS + X->AJUSTES
              	I_COMPRAS += X->COMPRAS
              	I_VENTAS  += X->VENTAS
              	I_AJUSTES += X->AJUSTES
              	SKIP
           	ENDDO
					CABEZA( 2 ); I_CL += 2
					? I_esp + ARMOLIN(I_cab)
					? I_esp + ARMOLIN(I_cab+2)
					FOR x = 1 TO UT_largo-I_CL
						?
					NEXT x
           ENDIF
           SKIP 1 ALIAS PRD
        ENDDO
        RECUPAN()
     ENDIF

	ELSEIF listado == "STKXPRD"
  	IF MARCARPROD()
			IF QUEFECHA2( 10, 25 )
     		INVENTARIAR( {||PRD->MARCA==''} )
				if !SETIMPRESORA("INI");  break(nil);  endif
				DO ICARGA WITH listado
        	SELECT PRD
        	GO TOP
        	SELECT X
        	DO WHILE !PRD->(EOF()) .AND. !SALIR()
     			IF PRD->MARCA==''
						I_CL = UT_largo + 1
        			I_COMPRAS := I_VENTAS := I_AJUSTES := I_ACUM := 0
          			DBSEEK( STR(PRD->CODPROD)+FTOC(DESDE), .T. )
              	DO WHILE X->CODPROD==PRD->CODPROD .AND. X->FECHA>=DESDE .AND.X->FECHA<=HASTA .AND. !SALIR()
							CABEZA( 1 ); ++I_CL
							? I_esp + ARMOLIN(I_cab+1)
                 	I_ACUM    += I_ACUM + X->COMPRAS - X->VENTAS + X->AJUSTES
                 	I_COMPRAS += X->COMPRAS
                 	I_VENTAS  += X->VENTAS
                 	I_AJUSTES += X->AJUSTES
              		SKIP
           		ENDDO
						CABEZA( 2 ); I_CL += 2
						? I_esp + ARMOLIN(I_cab)
						? I_esp + ARMOLIN(I_cab+2)
						FOR x = 1 TO UT_largo-I_CL
							?
						NEXT x
              ENDIF
           	SKIP 1 ALIAS PRD
        	ENDDO
        	RECUPAN()
     	ENDIF
     ENDIF
		
	ELSEIF listado == "LUBRIC"
		IF QUEFECHA2( 10, 25 )
			MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
			FBASES({"+PLAN2"},.F.)
        SELECT PRD
			GO TOP
     	aaux := {};  DBEVAL( {|| AADD(aaux,{PRD->CODPROD,0})}, {|| PRD->RUBRO==2} )
			SELECT PL2
     	DBSETORDER( FORDER({"FECHA","TURNO"}) )
        SET SOFTSEEK ON
        SEEK FTOC(DESDE)
        DO WHILE PL2->FECHA>=DESDE .AND. PL2->FECHA<=HASTA .AND. !EOF()
        	i := ASCAN( aaux, {|a|a[1]==PL2->CODPROD} )
        	IF i # 0
        		aaux[i,2] += PL2->CANTIDAD
              @ 24,71 SAY PL2->FECHA
        	ENDIF
           SKIP
			ENDDO
        SET SOFTSEEK OFF
        RECUPAN()
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
        M->CANTIDAD := 0
        M->LITROS   := 0
			SELECT PRD
        FOR nn=1 TO LEN(aaux)
           IF aaux[nn,2] # 0
        		SEEK aaux[nn,1]
           	IF FOUND()
              	M->CANTIDAD += aaux[nn,2]
              	M->LITROS   += aaux[nn,2]*PRD->CAPACIDAD
						CABEZA( 1 ); ++I_CL
						? I_esp + ARMOLIN(I_cab+1)
              ENDIF
           ENDIF
        NEXT nn
			CABEZA( 2 ); I_CL += 2
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+2)
			RECUPAN()
     ENDIF

	ELSEIF listado = "CHEACOB"
		IF QUEFECHA2( 10, 25 )
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			SELECT CH
			xord := INDEXORD()
			xreg := RECNO()
			SET ORDER TO CH_ESTADO
			aux = .F.
			I_codaux="@"
			I_TOTAL = 0
			SEEK "CAR"
			DO WHILE CH->ESTADO == "CAR" .AND. !SALIR()
				IF CH->FECHA>=DESDE .AND. CH->FECHA<=HASTA
					IF I_codaux # CH->BANCO
						IF I_codaux # "@"
							CABEZA( 1 )
							I_CL = I_CL + 1
							?  I_esp + ARMOLIN(I_cab+2)
						ENDIF
						CABEZA( 2 )
						I_CL = I_CL + 2
						?
						? I_esp + FVECTOR(vbanco,CH->BANCO)
						I_codaux = CH->BANCO
						I_TOTAL = 0
						aux = .T.
					ENDIF
					CABEZA( 2 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
					I_TOTAL = I_TOTAL + CH->MONTO
				ENDIF
				SKIP
			ENDDO
			SET SOFTSEEK OFF
			CABEZA( 1 )
			I_CL = I_CL + 1
			?  I_esp + ARMOLIN(I_cab+2)
			SET ORDER TO xord
			GO xreg
			RECUPAN()
		ENDIF
		
	ELSEIF listado $ "RESFAC"
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		CABEZA( 2 )
		I_CL = I_CL + 2
		?
		? I_esp + JUSTIF("TOTAL PLANILLAS",LEN(LI[I_cab]),"=","-" )
		FOR z=1 TO LEN(aaux)-1
			CABEZA( 1 )
			I_CL = I_CL + 1
			? I_esp + ARMOLIN(I_cab+1)
		NEXT
		CABEZA( 2 )
		I_CL = I_CL + 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+1)
		aaux := ACLONE(aaux2)
		CABEZA( 2 )
		I_CL = I_CL + 2
		?
		? I_esp + JUSTIF("TOTAL FACTURADO",LEN(LI[I_cab]),"=","-" )
		FOR z=1 TO LEN(aaux) - 1
			CABEZA( 1 )
			I_CL = I_CL + 1
			? I_esp + ARMOLIN(I_cab+1)
		NEXT
		CABEZA( 2 )
		I_CL = I_CL + 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+1)
		aaux := ACLONE(aaux3)
		CABEZA( 2 )
		I_CL = I_CL + 2
		?
		? I_esp + JUSTIF("DIFERENCIA",LEN(LI[I_cab]),"=","-" )
		FOR z=1 TO LEN(aaux) - 1
			CABEZA( 1 )
			I_CL = I_CL + 1
			? I_esp + ARMOLIN(I_cab+1)
		NEXT
		CABEZA( 2 )
		I_CL = I_CL + 2
		? I_esp + ARMOLIN(I_cab)
		? I_esp + ARMOLIN(I_cab+1)
		RECUPAN()
		
	ELSEIF listado == "REMITOS"
		IF QUEFECHA2( 10, 30 )
			FBASES({"REM_A","REM_A2", "REM_B","REM_B2"})
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			M->TTPRECBASE = 0
			M->TTIMPINT = 0
			M->TDESCUENTO = 0
			M->TTIVA1 = 0
			M->TTIVA2 = 0
			M->TTOTAL = 0
			SELECT &XBASE
			lastorder = INDEXORD()
			lastreg = RECNO()
			SET ORDER TO 3
			SET SOFTSEEK ON
			SEEK FTOC(DESDE)
			SET SOFTSEEK OFF
			SELECT &XBASE2
			DO WHILE &XBASE->FECHA>=DESDE .AND. &XBASE->FECHA<=HASTA .AND. !SALIR()
				M->TPRECBASE = 0
				M->TIMPINT = 0
				SEEK &XBASE->NUMFAC
				DO WHILE &XBASE2->NUMFAC == &XBASE->NUMFAC
					M->TPRECBASE = M->TPRECBASE + &XBASE2->PRECBASE * &XBASE2->CANTIDAD
					M->TIMPINT = M->TIMPINT + &XBASE2->IMPINT * &XBASE2->CANTIDAD
					SKIP
				ENDDO
				M->DESCUENTO = M->TPRECBASE * M->PORCDESC / 100
				M->SUBTOTAL = M->TPRECBASE - M->DESCUENTO
				AUXILIAR = M->SUBTOTAL + M->TIMPINT
				M->TIVA1 = M->SUBTOTAL * M->PIVA1/100
				M->TIVA2 = M->SUBTOTAL * M->PIVA2/100
				M->TOTAL = AUXILIAR + M->TIVA1 + M->TIVA2
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
				M->TTPRECBASE += M->TPRECBASE
				M->TTIMPINT += M->TIMPINT
				M->TDESCUENTO += M->DESCUENTO
				M->TTIVA1 += M->TIVA1
				M->TTIVA2 += M->TIVA2
				M->TTOTAL += M->TOTAL
				SKIP 1 ALIAS &XBASE
			ENDDO
			CABEZA( 2 )
			I_CL = I_CL + 2
			?
			?  I_esp + ARMOLIN(I_cab+2)
			SELECT &XBASE
			SET ORDER TO lastorder
			GO lastreg
			RECUPAN()
		ENDIF
		
	ELSEIF listado == "DOCS"
		if !SETIMPRESORA("INI");  break(nil);  endif
		FOR i=1 TO MLCOUNT( auxaux, 132 )
			? MEMOLINE( auxaux, 132, i )
		NEXT
		RECUPAN()
		
	ELSEIF listado $ "SERVXEMP"
		IF QUEFECHA2( 10, 30 )
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			FBASES({"PLAN","PLAN2"})
			SELECT 99
			DBCLOSEAREA()
			base = XNAME("XAUX")
			CREARBASE( base, 'CODPROD N 4 0', 'DESCPROD C 30', 'GRUPO N 2',;
				'CANTIDAD N 8 1', 'PRECBASE N 10 2', 'IMPINT N 10 2',;
				'IVA N 10 2', 'IMPORTE N 10 2', 'PORC N 6 2', 'TOTPORC N 10 2' )
			USE &base ALIAS X EXCLUSIVE
			INDEX ON X->CODPROD TO &base
			SELECT PL2
			SET ORDER TO 1
			SET SOFTSEEK ON
			SEEK FTOC(DESDE)
			SET SOFTSEEK OFF
			SELECT X
			DO WHILE PL2->FECHA >= DESDE .AND. PL2->FECHA <= HASTA
				IF PL2->TURNO == "S"
					SEEK PL2->CODPROD
					IF !FOUND()
						APPEND BLANK
						SELECT PRD
						SEEK PL2->CODPROD
						STORE 0 TO aux1, aux2
						IF !EMPTY( FGRUPO( PRD->GRUPO ) )
							aux1 = GR->(RECNO())
							aux2 = GR->PORC
						ENDIF
						REPLACE X->CODPROD WITH PL2->CODPROD, X->DESCPROD WITH PL2->DESCPROD,;
							X->GRUPO WITH aux1, X->PORC WITH aux2
						SELECT 99
					ENDIF
					REPLACE X->CANTIDAD WITH X->CANTIDAD+PL2->CANTIDAD, ;
						X->IMPORTE WITH X->IMPORTE + PL2->IMPORTE, X->TOTPORC WITH X->IMPORTE * X->PORC / 100
				ENDIF
				SKIP 1 ALIAS PL2
			ENDDO
			RECUPAN()
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			SELECT X
			INDEX ON X->GRUPO TO &base
			GO TOP
			aux := -1
			STORE 0 TO M->IMPORTE, M->TOTPORC, M->TIMPORTE, M->TTOTPORC
			DO WHILE !EOF() .AND. !SALIR()
				IF X->GRUPO # aux
					IF !I_INI
						CABEZA(1)
						? I_esp + ARMOLIN(I_cab+2)
						I_CL = I_CL + 1
					ENDIF
					CABEZA(2)
					?
					? FGRUPO(X->GRUPO)
					aux := X->GRUPO
					I_CL = I_CL + 2
					STORE 0 TO M->IMPORTE, M->TOTPORC
				ENDIF
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
				M->TOTPORC = M->TOTPORC + X->TOTPORC
				M->IMPORTE  = M->IMPORTE  + X->IMPORTE
				M->TTOTPORC += X->TOTPORC
				M->TIMPORTE += X->IMPORTE
				SKIP
			ENDDO
			CABEZA( 4 )
			I_CL = I_CL + 4
			?  I_esp + ARMOLIN(I_cab+2)
			?  I_esp + ARMOLIN(I_cab)
			?  I_esp + ARMOLIN(I_cab+3)
			?  I_esp + ARMOLIN(I_cab)
			RECUPAN()
		ENDIF
		
	ELSEIF listado == "VENTXPRD"
  	IF MARCARPROD()
     	aaux := {};  DBEVAL( {|| AADD(aaux,PRD->CODPROD)}, {|| PRD->MARCA==''} )
			IF QUEFECHA2( 10, 30 )
				MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
				FBASES({"PLAN","PLAN2"})
				SELECT 99;	DBCLOSEAREA()
				base = XNAME("XAUX")
				CREARBASE( base, 'CODPROD N 5 0', 'DESCPROD C 30', 'RUBRO N 2', ;
					'CANTIDAD N 8 1', 'PRECBASE N 10 2', 'IMPINT N 10 2', 'IVA N 10 2', ;
					'IMPORTE N 10 2' )
				USE (base) ALIAS X EXCLUSIVE
				INDEX ON X->CODPROD TO (base)
				SELECT PL2
				SET ORDER TO 1
				SET SOFTSEEK ON
				SEEK FTOC(DESDE)
				SET SOFTSEEK OFF
				SELECT 99
				DO WHILE PL2->FECHA >= DESDE .AND. PL2->FECHA <= HASTA
           	IF ASCAN(aaux, PL2->CODPROD) # 0
						SEEK PL2->CODPROD
						IF !FOUND()
							APPEND BLANK
                    FPRODUCTO(PL2->CODPROD)
							REPLACE X->CODPROD WITH PL2->CODPROD, X->DESCPROD WITH PL2->DESCPROD, X->RUBRO WITH NRUBRO
						ENDIF
						REPLACE X->CANTIDAD WITH X->CANTIDAD+PL2->CANTIDAD, X->PRECBASE WITH X->PRECBASE+(PL2->PRECBASE*PL2->CANTIDAD),;
							X->IMPINT WITH X->IMPINT+(PL2->IMPINT*PL2->CANTIDAD), X->IVA WITH X->IVA + (PL2->IVA*PL2->CANTIDAD),;
							X->IMPORTE WITH X->IMPORTE + PL2->IMPORTE
              ENDIF
					SKIP 1 ALIAS PL2
				ENDDO
           SELECT X
				INDEX ON STR(X->RUBRO)+STR(X->CODPROD) TO (base)
				RECUPAN()
				if !SETIMPRESORA("INI");  break(nil);  endif
				DO ICARGA WITH listado
				GO TOP
           I_I := -1
				STORE 0 TO M->CANTIDAD, M->PRECBASE, M->IMPINT, M->PIVA, M->IMPORTE
				DO WHILE !EOF() .AND. !SALIR()
           	IF I_I # X->RUBRO
              	IF !I_INI
							CABEZA( 2 )
							I_CL += 2
							? I_esp + ARMOLIN(I_cab)
							? I_esp + ARMOLIN(I_cab+2)
                 ENDIF
						CABEZA( 2 )
						I_CL += 2
              	?
              	? I_esp + FVECTOR(vrubro,X->RUBRO)
           		I_I := X->RUBRO
						STORE 0 TO M->CANTIDAD, M->PRECBASE, M->IMPINT, M->PIVA, M->IMPORTE
              ENDIF
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
              M->CANTIDAD += X->CANTIDAD
					M->PRECBASE += X->PRECBASE
					M->IMPINT   += X->IMPINT
					M->PIVA      += X->IVA
					M->IMPORTE  += X->IMPORTE
					SKIP
				ENDDO
				CABEZA( 2 )
				I_CL = I_CL + 2
				? I_esp + ARMOLIN(I_cab)
				?  I_esp + ARMOLIN(I_cab+2)
				RECUPAN()
			ENDIF
     ENDIF
		
	ELSEIF listado == "VENTXGRU"
		IF QUEFECHA2( 10, 30 )
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			FBASES({"PLAN2"})
			cBaseAux = XNAME("XAUX")
			SELECT 99;	DBCLOSEAREA()
			CREARBASE( cBaseAux, "GRUPO N 2", "CANTIDAD N 10 3", "IMPORTE N 12 2", "PROMLXDIA N 10 3", "VTAEST N 12 3", "COMPRAL N 12 3", "ESCOMBUST C 1", "FECHADDE D 8", "FECHAHTA D 8" )
			SELECT 99
			USE (cBaseAux) ALIAS X EXCLUSIVE
			INDEX ON X->GRUPO TO (cBaseAux)
			SELECT PL2
			SET SOFTSEEK ON
			SEEK FTOC(DESDE)
			SET SOFTSEEK OFF
			SELECT 99
			DO WHILE PL2->FECHA >= DESDE .AND. PL2->FECHA <= HASTA
				IF !EMPTY(FPRODUCTO(PL2->CODPROD))
					SEEK PRD->GRUPO
					IF !FOUND()
						APPEND BLANK
						REPLACE X->GRUPO WITH PRD->GRUPO, X->FECHADDE WITH PL2->FECHA
					ENDIF
					REPLACE X->CANTIDAD WITH X->CANTIDAD + PL2->CANTIDAD,;
						X->IMPORTE WITH X->IMPORTE + PL2->IMPORTE, X->FECHAHTA WITH PL2->FECHA
				ENDIF
				SKIP 1 ALIAS PL2
			ENDDO
        	*** Compras
			FBASES({"COMPRAS","COMPRAS2"})
			SELECT CO
        DBSETORDER(FORDER({"FECHA","CODPROV"}))
			SET SOFTSEEK ON
			SEEK FTOC(DESDE)
			SET SOFTSEEK OFF
			DO WHILE CO->FECHA >= DESDE .AND. CO->FECHA <= HASTA
        	SELECT CO2
           SEEK STR(CO->CODPROV)+CO->NUMFAC
           DO WHILE CO2->CODPROV==CO->CODPROV .AND. CO2->NUMFAC==CO->NUMFAC
					SELECT 99
					IF !EMPTY(FPRODUCTO(CO2->CODPROD))
						SEEK PRD->GRUPO
						IF !FOUND()
							APPEND BLANK
							REPLACE X->GRUPO WITH PRD->GRUPO
						ENDIF
						X->COMPRAL += CO2->CANTIDAD
					ENDIF
					SKIP 1 ALIAS CO2
				ENDDO
           SKIP 1 ALIAS CO
        ENDDO
        SELECT CO
        SET ORDER TO 1
        SELECT X
        DBGOTOP()
        DO WHILE !EOF()
				IF !EMPTY(FGRUPO(X->GRUPO))
           	X->ESCOMBUST := FESCOMBUST
           ENDIF
        	SKIP
        ENDDO
			RECUPAN()
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			SELECT 99
        SET ORDER TO 1
			GO TOP
			M->TOTAL := M->CANTIDAD := M->PROMLXDIA := M->VTAEST := M->COMPRAL := 0
        dxm   := DIASXMES(YEAR(HASTA),MONTH(HASTA))
        xcant := CTOD( STR(dxm,2) + SUBSTR(DTOC(HASTA),3) )
        xcant := xcant - DESDE + 1
			CABEZA(1); I_CL += 1
			? I_esp + "* * *    COMBUSTIBLES   * * *"
			DO WHILE !EOF() .AND. !SALIR()
           IF X->ESCOMBUST == "S"
        		REPLACE X->PROMLXDIA WITH X->CANTIDAD/(X->FECHAHTA-X->FECHADDE+1), X->VTAEST WITH X->PROMLXDIA*xcant
					CABEZA(1); I_CL += 1
					? I_esp + ARMOLIN(I_cab+1)
					M->TOTAL     += X->IMPORTE
           	M->CANTIDAD  += X->CANTIDAD
					M->PROMLXDIA += X->PROMLXDIA
           	M->VTAEST    += X->VTAEST
           	M->COMPRAL   += X->COMPRAL
           ENDIF
				SKIP
			ENDDO
			CABEZA( 3 )
			I_CL += 3
			?  I_esp + strtran(ARMOLIN(I_cab),"=","-")
			?  I_esp + ARMOLIN(I_cab+2)
			?
        GO TOP
			DO WHILE !EOF() .AND. !SALIR()
           IF X->ESCOMBUST # "S"
					CABEZA(2)
					I_CL += 2
              ?
					? I_esp + ARMOLIN(I_cab+1)
					M->TOTAL     += X->IMPORTE
           	M->CANTIDAD  += X->CANTIDAD
					M->PROMLXDIA += X->PROMLXDIA
           	M->VTAEST    += X->VTAEST
           	M->COMPRAL   += X->COMPRAL
           ENDIF
				SKIP
			ENDDO
			CABEZA( 4 )
			I_CL = I_CL + 4
			?
			?  I_esp + ARMOLIN(I_cab)
			?  I_esp + ARMOLIN(I_cab+2)
			?  I_esp + ARMOLIN(I_cab)
			RECUPAN()
		ENDIF

	ELSEIF listado == "BANCO"
		IF QUEFECHA2( 10, 30 )
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			SELECT BA
			I_codaux = 0
			STORE 0 TO M->INGRESO, M->EGRESO, TINGRESO, TEGRESO
			SET SOFTSEEK ON
			SEEK FTOC(DESDE)
			DO WHILE !EOF() .AND. !SALIR()
				IF BA->FECHA >= DESDE .AND. BA->FECHA <= HASTA
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
					M->INGRESO = M->INGRESO + BA->INGRESO
					M->EGRESO = M->EGRESO + BA->EGRESO
					TINGRESO = TINGRESO + BA->INGRESO
					TEGRESO = TEGRESO + BA->EGRESO
				ENDIF
				SKIP
			ENDDO
			SET SOFTSEEK OFF
			RECUPAN()
		ENDIF
		
	ELSEIF listado $ "PLAN"
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		aux = .F.
     M->FECHA := APLA[ED_CONT,AX_FECHA]
		STORE 0 TO M->TOTAL
		FOR n=1 TO LEN(AXR)
			IF AXR[n,RG_CODPROD] # 0 	//.AND. AXR[n,RG_SURTIDOR] # 0
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
				M->TOTAL += AXR[n,RG_IMPORTE]
			ENDIF
		NEXT
		CABEZA( 2 )
		I_CL = I_CL + 2
		?
		? I_esp + ARMOLIN(I_cab+2)
		RECUPAN()
		
	ELSEIF listado = "COPCAR"
		IF QUEFECHA2( 10, 30 )
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
     	SELECT 99; DBCLOSEAREA()
			SELECT COP
     	xreg := RECNO()
     	xorder := INDEXORD()
    		DBSETORDER( FORDER({"COP->ESTADO"}) )
     	DBSEEK( "CAR",.T. )
     	IF COP->ESTADO=="CAR"
				base := XNAME("XAUX")
        	COPY TO (base) FOR MONTO#0 .AND. FECHA>=DESDE .AND. FECHA<=HASTA WHILE ESTADO=="CAR"
				SELECT 99
				USE (base) ALIAS X
*				INDEX ON FTOC(X->FECHPRES) TO (base)
        	GO TOP
				I_TOTAL := 0
				DO WHILE !EOF() .AND. !SALIR()
					CABEZA( 1 )
					++I_CL
					? I_esp + ARMOLIN(I_cab+1)
					I_TOTAL += X->MONTO
					SKIP
				ENDDO
				CABEZA( 1 )
				++I_CL
				?  I_esp + ARMOLIN(I_cab+2)
     	ENDIF
     	SELECT COP
     	DBSETORDER( xorder )
     	DBGOTO( xreg )
			RECUPAN()
     ENDIF

	ELSEIF listado = "COPAPRE"
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
     SELECT 99; DBCLOSEAREA()
		SELECT COP
     xreg := RECNO()
     xorder := INDEXORD()
    	DBSETORDER( FORDER({"COP->ESTADO"}) )
     DBSEEK( "CAR",.T.)
     IF COP->ESTADO=="CAR"
			base := XNAME("XAUX")
        COPY TO (base) FOR !EMPTY(FECHPRES) .AND. MONTO#0 WHILE ESTADO=="CAR"
			SELECT 99
			USE (base) ALIAS X
			INDEX ON FTOC(X->FECHPRES) TO (base)
        GO TOP
			I_TOTAL := 0
			DO WHILE !EOF() .AND. !SALIR()
				CABEZA( 1 )
				++I_CL
				? I_esp + ARMOLIN(I_cab+1)
				I_TOTAL += X->MONTO
				SKIP
			ENDDO
			CABEZA( 1 )
			++I_CL
			?  I_esp + ARMOLIN(I_cab+2)
     ENDIF
     SELECT COP
     DBSETORDER( xorder )
     DBGOTO( xreg )
		RECUPAN()
		
	ELSEIF listado = "CHEQAPAG"
		IF QUEFECHA2( 10, 30 )
			if !SETIMPRESORA("INI");  break(nil);  endif
			DO ICARGA WITH listado
			FBASES({"CHEQUES"})
			SELECT CH
			base = XNAME("XAUX")
			INDEX ON CH->ESTADO+CH->BANCO TO &base
			aux = .F.
			I_codaux="@"
			I_TOTAL = 0
			SET SOFTSEEK ON
			SEEK "C"
			DO WHILE CH->ESTADO=="C" .AND. !SALIR()
				IF CH->FECHA >=DESDE .AND. CH->FECHA <= HASTA .AND. CH->CODCLI == -1
					IF I_codaux # CH->BANCO
						IF I_codaux # "@"
							CABEZA( 1 )
							I_CL = I_CL + 1
							?  I_esp + ARMOLIN(I_cab+2)
						ENDIF
						CABEZA( 2 )
						I_CL = I_CL + 2
						?
						? I_esp + FVECTOR(vbanco,CH->BANCO)
						I_codaux = CH->BANCO
						I_TOTAL = 0
						aux = .T.
					ENDIF
					CABEZA( 2 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
					I_TOTAL = I_TOTAL + CH->MONTO
				ENDIF
				SKIP
			ENDDO
			CABEZA( 1 )
			I_CL = I_CL + 1
			?  I_esp + ARMOLIN(I_cab+2)
			RECUPAN()
		ENDIF
		FBASES({"CHEQUES"})
		IF aux
			IF PREGUNTA( 7, "¨ PONGO LOS CHEQUES COMO COBRADOS [ S / N ] ?", "SsNn" ) $ "Ss"
				MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
				FFLOCK()
				SET ORDER TO
				REPLACE CH->ESTADO WITH "U" FOR CH->ESTADO=="C" .AND. CH->FECHA >= DESDE .AND. CH->FECHA <= HASTA .AND. CH->CODCLI==-1
				UNLOCK
				RECUPAN()
			ENDIF
		ENDIF
		
	ELSEIF listado = "TARJAPAG"
		IF QUEFECHA2( 10, 30 )
			MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
			FBASES({"TARJETAS"})
			base = XNAME("XAUX")
			SELECT TA
			SEEK "C"
			COPY TO &base REST WHILE TA->ESTADO=="C"
			USE &base ALIAS TA
			INDEX ON TA->CODTARJ TO &base
			RECUPAN()
			aux = .F.
			IF LASTREC() > 0
				DO ICARGA WITH listado
				if !SETIMPRESORA("INI");  break(nil);  endif
				GO TOP
				I_codaux="@"
				I_TOTAL = 0
				DO WHILE !EOF() .AND. !SALIR()
					IF TA->FECHCOBRO >=DESDE .AND. TA->FECHCOBRO <= HASTA .AND. TA->CODCLI = -1
						IF I_codaux # TA->CODTARJ
							IF I_codaux # "@"
								CABEZA( 1 )
								I_CL = I_CL + 1
								?  I_esp + ARMOLIN(I_cab+2)
							ENDIF
							CABEZA( 2 )
							I_CL = I_CL + 2
							?
							? I_esp + FVECTOR(vtarjeta,TA->CODTARJ)
							I_codaux = TA->CODTARJ
							I_TOTAL = 0
							aux = .T.
						ENDIF
						CABEZA( 2 )
						I_CL = I_CL + 1
						? I_esp + ARMOLIN(I_cab+1)
						I_TOTAL = I_TOTAL + TA->MONTO
					ENDIF
					SKIP
				ENDDO
				CABEZA( 1 )
				I_CL = I_CL + 1
				?  I_esp + ARMOLIN(I_cab+2)
				RECUPAN()
			ENDIF
			FBASES({"TARJETAS"})
			IF aux
				IF PREGUNTA( 7, "¨ PONGO LAS TARJETAS COMO PAGADAS [ S / N ] ?", "SsNn" ) $ "Ss"
					MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
					FFLOCK()
					SET ORDER TO
					REPLACE TA->ESTADO WITH "P" FOR TA->ESTADO=="C" .AND. TA->FECHCOBRO >= DESDE .AND. TA->FECHCOBRO <= HASTA .AND. TA->CODCLI==-1
					UNLOCK
					RECUPAN()
				ENDIF
			ENDIF
		ENDIF
		
	ELSEIF listado $ "FACTA FACTB"
		DO ICARGA WITH listado
		if !SETIMPRESORA("INI");  break(nil);  endif
		FOR y=1 TO LEN(AXR)
			IF AXR[y,RG_CANTIDAD] > 0
				CABEZA( 1 )
				? I_esp + ARMOLIN(I_cab+1)
				I_CL = I_CL + 1
			ENDIF
		NEXT
		FOR y=I_cab+2 TO LEN(LI)
			? I_esp + ARMOLIN(y)
			I_CL = I_CL + 1
		NEXT

     FBASES({"+REM"},.F.)
     aaux := {}
     M->TOTAL := 0
     SELECT RE
     DBSETORDER( FORDER({"CODCLI","FECHCIERRE"}) )
     SEEK STR(FA->CODCLI) + FTOC(M->FECHA)
     DO WHILE RE->CODCLI == FA->CODCLI .AND. RE->FECHCIERRE==M->FECHA
     	AADD( aaux, STR(RE->NUMFAC) +" "+ DTOC(RE->FECHA) + STR(RE->TOTAL,12,2) + SPACE(8) )
        M->TOTAL += RE->TOTAL
     	SKIP
     ENDDO
     IF LEN(aaux) > 0
     	?
 			? I_esp + ARMOLIN(I_cab)
     	? chr(15)
     	i := 0
     	bb := {|| IF(++i>LEN(aaux),"",aaux[i])}
     	DO WHILE i <= LEN(aaux)
        	? EVAL(bb) + EVAL(bb) + EVAL(bb)
     	ENDDO
 			? I_esp + ARMOLIN(I_cab)
     	? "              TOTAL:=", STR(M->TOTAL,12,2)
     	?? "          Cantidad de Remitos:", STR(LEN(aaux),5)
     	?
 		ENDIF
     SELECT FA
		RECUPAN()
		
	ELSEIF listado == "REMITO"
		DO ICARGA WITH listado
		if !SETIMPRESORA("INI");  break(nil);  endif
     FOR z=1 TO 2
			I_CL = UT_largo + 1
			CABEZA( 1 )
        FOR I_L=1 TO 9
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
			NEXT
			? I_esp + ARMOLIN(I_cab+2)
			? I_esp + ARMOLIN(I_cab+3)
			? I_esp + ARMOLIN(I_cab+4)
        ? SPACE(70)+{"ORIGINAL","DUPLICADO"}[z]
        if z==1
        	?;  ?
        endif
		NEXT
		? CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
		?? CHR(12)
		I_CL  := UT_largo+1
		RECUPAN()
		
	ELSEIF listado == "CCAPAG"
		IF MARCARPROV()
			DO ICARGA WITH listado
			if !SETIMPRESORA("INI");  break(nil);  endif
			M->TSALDO := M->TREMITOS := M->TTOTAL := 0
			SELECT PRV
			GO TOP
			DO WHILE !PRV->(EOF())
				IF PRV->MARCA==""
           	aaux := DEUDAXPROV( PRV->CODPROV )
						* * *   junta todas las cuentas no pagas
					M->SALDO := aaux[1]
					M->REMITOS := aaux[2]
					
					M->TOTAL := M->SALDO + M->REMITOS
					IF M->TOTAL != 0
						CABEZA( 2 )
						?
						? I_esp + ARMOLIN(I_cab+1)
						I_CL = I_CL + 2
						TSALDO   += M->SALDO
						TREMITOS += M->REMITOS
						TTOTAL   += M->TOTAL
					ENDIF
				ENDIF
				SKIP 1 ALIAS PRV
			ENDDO
			CABEZA( 3 )
			?
			? I_esp + ARMOLIN(I_cab)
			? I_esp + ARMOLIN(I_cab+2)
			I_CL = I_CL + 3
			RECUPAN()
		ENDIF
	ELSEIF listado = "PROD"
		SETCOLOR(C_MENU)
		op = MENUFLASH( 11, 30, 1, .T., " Imprimir Productos ", "ORDENADO POR CODIGO", "ORDENADO POR DESCRIPCION" )
		SELECT PRD
		lastreg = RECNO()
		DO ICARGA WITH listado
		STORE 0 TO I_cantidad, I_uxc, I_pre1, I_pre2, I_pre3, I_stock
		I_cambio = "@"
		I_subtitulo = ""
		aux = XNAME( "XAUX" ) + ".NTX"
		IF op = 1               &&.POR CODIGO
			SET ORDER TO 1
			if !SETIMPRESORA("INI");  break(nil);  endif
			GO TOP
			DO WHILE !EOF() .AND. !SALIR()
				IF PRD->CODPROD >= DESDE .AND. PRD->CODPROD <= HASTA .AND. !EMPTY(PRD->DESCPROD)
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
				ENDIF
				SKIP
			ENDDO
			RECUPAN()
		ELSEIF op = 2           &&.POR DESCRIPCION
			MENSAJE(0, 0, 0, .F., " ORDENANDO . . .")
			INDEX ON PRD->DESCPROD TO &aux
			RECUPAN()
			if !SETIMPRESORA("INI");  break(nil);  endif
			I_cambio = "@"
			GO TOP
			DO WHILE !EOF() .AND. !SALIR()
				IF PRD->CODPROD >= DESDE .AND. PRD->CODPROD <= HASTA .AND. !EMPTY(PRD->DESCPROD)
					IF I_cambio # UPPER(LEFT(PRD->DESCPROD,1))
						I_cambio = UPPER(LEFT(PRD->DESCPROD,1))
						CABEZA(2)
						I_CL = I_CL + 2
						?
						? I_esp + SPACE(20) + CHR(14) + I_cambio
					ENDIF
					CABEZA( 1 )
					I_CL = I_CL + 1
					? I_esp + ARMOLIN(I_cab+1)
					I_cantidad = I_cantidad + 1
				ENDIF
				SKIP
			ENDDO
			RECUPAN()
		ENDIF
		FBASES({ "+PROD" },.F.)
		SELECT PRD
		GO lastreg
		
	ELSEIF listado=="CLA" .OR. listado=="CLIENTES"
		IF listado == "CLA"
			SELECT CLA
			SET ORDER TO FORDER({"RAZONSOC"})
			DO ICARGA WITH listado
			if !SETIMPRESORA("INI");  break(nil);  endif
			GO TOP
			I_cantidad := 0
     	I_LETRA := "@"
			DO WHILE !EOF() .AND. !SALIR()
        	if FIELD->CODCLI#0
					IF I_LETRA # LEFT(CLA->RAZONSOC,1)
						I_LETRA := LEFT(CLA->RAZONSOC,1)
						CABEZA( 2 )
						I_CL += 2
						?
						? I_esp + CHR(14)+I_LETRA
					ENDIF
					CABEZA( 1 )
					I_CL += 1
					? I_esp + ARMOLIN(I_cab+1)
					++I_cantidad
           endif
				SKIP
			ENDDO
     	SET ORDER TO norder
			RECUPAN()
		ELSEIF listado == "CLIENTES"
			DO ICARGA WITH listado
			if !SETIMPRESORA("INI");  break(nil);  endif
			SELECT CL
			GO TOP
			I_cantidad := 0
			DO WHILE !EOF() .AND. !SALIR()
        	if FIELD->CODCLI#0
					CABEZA( 1 )
					I_CL += 1
					? I_esp + ARMOLIN(I_cab+1)
					++I_cantidad
           endif
				SKIP
			ENDDO
			RECUPAN()
     ENDIF
		
	ELSEIF listado = "REPOS"
		SELECT PRD
*		aux = XNAME( "XAUX" )
*		MENSAJE(0, 0, 0, .F., " ORDENANDO POR GRUPO Y POR CODIGO . . .")
*		INDEX ON STR(PRD->GRUPO) + STR(PRD->CODPROD) TO (aux)
*		RECUPAN()
		DO ICARGA WITH listado
		if !SETIMPRESORA("INI");  break(nil);  endif
		GO TOP
		I_cantidad = 0
		DO WHILE !EOF() .AND. !SALIR()
*			IF PRD->CONDEP=='S' .AND. PRD->REPONER # 0
			IF PRD->CONSTOCK=='S' .AND. PRD->STOCKACT+PRD->DEPOSITO <= PRD->STOCKMIN
				CABEZA( 1 )
				I_CL = I_CL + 1
				? I_esp + ARMOLIN(I_cab+1)
*				I_cantidad = I_cantidad 		//+ PRD->REPONER
			ENDIF
			SKIP
		ENDDO
		RECUPAN()
	ENDIF
	break(nil)

end sequence

ErrorBlock(bLastErr)
IF I_errores < 1
	RECUPAN()
ENDIF
ENDIF
CLEARTYPEAHEAD()
DBCOMMITALL()
if I_IMPRIMIO
  IF ES_LASER_TINTA
  	EJECT
  ELSE
		FOR i=I_CL TO UT_largo
			?
		NEXT i
  ENDIF
	?? CHR(27)+"@"
	SETIMPRESORA("FIN")
	RELEASE ALL LIKE I_*
	TONE(1000, 1)
	IF EST->SALIDA # "IMP"
		cAux:=SAVESCREEN(0,0,24,79)
*		RUN ..\VERTXT LISTADO.TXT
  	cArchAux := XNAME("XLIS")+".TXT"
  	TXT( cArchAux )
		RESTSCREEN(0,0,24,79,cAux)
	ENDIF
	if listado == "PLA@@@@@" .and. EST->SALIDA=="IMP"
		MENSAJE(99, 99, 0, .F., "presione P para detener la Impresi¢n.")
*		RUN SIDEWAYS LISTADO.TXT >NUL
		SAVE ALL LIKE UT_* TO SIDEWAYS.BAK
     QUIT
	endif
ELSE
	SETIMPRESORA("FIN")
	RELEASE ALL LIKE I_*
	TONE(1000, 1)
endif
SEMAFORO( "ON" )

RETURN



***********

FUNC CABEZA

***********
PARAMETERS mas

IF I_CL + mas < UT_largo - IF( I_prihoja, 2, 3 )
	RETURN .T.
ENDIF
IF !I_INI
	?? CHR(10)
  IF ES_LASER_TINTA
  	EJECT
  ELSE
		FOR x = 1 TO UT_largo-I_CL
			?
		NEXT x
  ENDIF
ENDIF
I_NH = I_NH + 1
I_prihoja = IF( I_INI, .T., .F. )
? I_seteo
?? I_esp + LEFT(ARMOLIN(1), I_ancho)
FOR n = 2 TO I_cab
	? I_esp + LEFT(ARMOLIN(n), I_ancho)
NEXT n
I_IMPRIMIO := .T.
I_CL = I_cab + IF( I_INI, 1, 0 )
I_INI = .F.

RETURN .T.



**********

FUNC SALIR

**********

K = INKEY()
IF K = 27
	GO BOTTOM
	RETURN .T.
ENDIF

RETURN .F.


***********

PROC ICARGA

***********
PARAMETERS archivo
PRIVATE na, buffer, x, bytes

arch = ALLTRIM(LEFT(archivo, 8) ) + ".PRN"
na = FOPEN( arch )

block = 20
buffer = SPACE(block)
FSEEK(na, 0)
bytes = FREAD( na, @buffer, block )
PUBLIC aI[VAL(buffer),2]
aeval(aI,{|a,i|aI[i,1]:=0,aI[i,2]:=""})

bytes = FREAD( na, @buffer, block )
PUBLIC LI[ VAL(buffer) ]
AFILL(LI, "")

bytes = FREAD( na, @buffer, block )
I_largo = VAL(buffer)

bytes = FREAD( na, @buffer, block )
block = VAL(buffer)

buffer = SPACE(block)
FOR x = 1 TO LEN(aI)
	bytes = FREAD( na, @buffer, block )
	aI[x,1] = VAL(buffer)
	aI[x,2] = RTRIM(SUBSTR(buffer, 3, RAT("³", buffer)-4))
NEXT x
I_cab := I_pie := 0
FOR x = 1 TO LEN(LI)
	bytes = FREAD( na, @buffer, block )
	LI[x] = LEFT(buffer, RAT("³", buffer)-1)
	IF "" $ buffer
		I_cab = x
		i := AT('',LI[x])
		LI[x] = STUFF(LI[x], i, 1, substr(LI[x],i+1,1))
	ENDIF
	IF "" $ buffer
		I_pie = x
		i := AT('',LI[x])
		LI[x] = STUFF(LI[x], i, 1, substr(LI[x],i+1,1))
	ENDIF
	IF left(LI[x],1) == "ð"
		LI[x] = JUSTIF(substr(LI[x],2), len(LI[x]), '=' )
	ENDIF
NEXT x
FCLOSE(na)

block = LEN(LI[1])
IF ES_LASER_TINTA
	IF block > 137
		I_ancho = 160
		I_seteo = CHR(27) + "(s18H"
	ELSEIF block > 80
		I_ancho = 137
		I_seteo = CHR(27) + "(s18H"
	ELSE
		I_ancho = 80
		I_seteo = CHR(27) + "(s10H"
	ENDIF
ELSE
	IF block > 137
		I_ancho = 160
		I_seteo = CHR(27) + CHR(77) + CHR(15)
	ELSEIF block > 80
		I_ancho = 137
		I_seteo = CHR(15)
	ELSE
		I_ancho = 80
		I_seteo = CHR(18)
	ENDIF
ENDIF
I_esp = SPACE((I_ancho - block) / 2)

RETURN


************

FUNC ARMOLIN

************
PARAMETERS cual
PRIVATE xx, I, r1, r2

xx = ASCAN(aI,{|a| a[1]==cual})
IF xx < 1
	RETURN RTRIM( LI[cual] )
ENDIF
I = LI[cual]
DO WHILE aI[xx,1] = cual
	r1  = AT("þ", I)
	r2 = AT("º", I) - r1 + 1
	otro = aI[xx,2]
	otro = LEFT(&otro+SPACE(100), r2)
	I = STUFF(I, r1, r2, otro)
	xx = xx + 1
	IF xx > LEN(aI)
		EXIT
	ENDIF
ENDDO

RETURN RTRIM( I )


***********************************

FUNC SETIMPRESORA( cModo, listado )

***********************************
local archivo, xSal, cAux

IF cModo == "INI"
	op2 = IF(EST->SALIDA="IMP",1,2)
	op2 = MENUFLASH( 10, 30, op2, .T., "", "IMPRESORA", "PANTALLA" )
	IF LASTKEY() == K_ENTER
		cAux := IF( op2==1, "IMP", "PAN" )
		IF EST->SALIDA # cAux
  		FRLOCK("EST")
			EST->SALIDA	:= cAux
     	DBUNLOCKALL()
  	ENDIF
  ELSE
  	RETURN .F.
  ENDIF
ENDIF

IF EST->SALIDA == "IMP"
	xSal := "LPT" + IF( EST->IMPRESORA==0, "1", STR(EST->IMPRESORA,1) )
ELSE
  xSal := XNAME("XLIS")+".TXT"
* xSal := "LISTADO.TXT"
ENDIF
IF cModo == "INI"
	MENSAJE(30, 80, 0, .F., " IMPRIMIENDO . . . ")
  SET PRINTER TO (xSal)
	SET DEVICE TO PRINTER
	SET PRINT ON
	SET CONSOLE OFF
ELSEIF cModo == "ON"
	SET DEVICE TO PRINTER
	SET PRINT ON
	SET CONSOLE OFF
ELSEIF cModo == "OFF"
	SET DEVICE TO SCREEN
	SET PRINT OFF
	SET PRINTER TO
	SET CONSOLE ON
ELSEIF cModo == "FIN"
	SET DEVICE TO SCREEN
	SET PRINT OFF
	SET PRINTER TO
	SET CONSOLE ON
ENDIF

RETURN .T.
