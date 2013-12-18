PARAMETERS cualbanco
PRIVATE aCpo, OX, oGET, xreg

#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

PROCESO = PROCNAME()
aux = "BANCO"+STR(cualbanco,1)
IF !FILE(aux+".DBF")
	FBASES({ "BANCO1" })
	COPY STRU TO (aux)
ENDIF
FBASES({ aux, "CHEQUEST", "CHEQUES" })

LOGO(.T., " LIBRO BANCO ("+ ALLTRIM(FVECTOR(vbancocta,cualbanco)) +")" )


MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
aCpo:={{ "FECHA",      "Fecha",                              '', 'M',  '',  0, 0 },;
		  { "CODCONC",    "C¢d; ",                              '', 'M',  '',  0, 0 },;
		  { "CONCEPTO",   "Concepto",                           '', 'M',  '',  0, 0 },;
		  { "NUMCHEQUE",  "N§",                                 '', 'M',  '',  0, 0 },;
		  { "DEPOSITO",   "Dep¢sito",                           '', 'M',  '',  0, 2 },;
		  { "CHEQUE",     "Extracci¢n",                         '', 'M',  '',  0, 0 },;
		  { "SALDO",      "Saldo",                              '', 'F',  '',  0, 0 }}

SELECT BA
aCpo := FBASEAUX( aCpo, "BA", SELECT(), .F. )
aCpo[3,3] := "@S15 !XXXXXXXXXXXXXXX"
aCpo[5,3] := "@Z "+ aCpo[5,3]
aCpo[6,3] := "@Z "+ aCpo[6,3]
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º   F5   º    F8    º   F9    º   F10   º    TAB    º ESC  ",;
			  "       º F3 busca  º        º cheques  ºrecalculaº cheques º           º      ",;
			  " mueve º F4 busca+ º agrega ºen carteraº saldos  º a a pag.º conceptos º sale "})

SETCOLOR( "W/N,N/W" )

OX := MYBROWSE( 4, 1, 20, 78, aCpo )

oTC := OX:GETCOLUMN(3)
oTC:Width := 17
OX:SETCOLUMN( 3, oTC )
OX:CARGO[TB_REFRESH] := 10
OX:GOBOTTOM()
aedits := TBCOLEDIT( "SETEAR", "BANCOS", OX, aedits )
TBCOLOR(OX)

	DO WHILE .T.

		MOVBROW( OX, {||nK==K_TAB.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_F9.OR.nK==K_F8.OR.nK==K_F10.OR.nK==K_F7} )

     IF OX:Cargo[TB_MSGE] == "MODIF"
    		IF OX:CARGO[TB_NOMBRE,OX:ColPos] $ "DEPOSITO CHEQUE"
        	FRLOCK()
        	FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]) := OX:CARGO[TB_CONT]
        	FSALDAR()
        	OX:RefreshAll()
    		ELSEIF OX:CARGO[TB_NOMBRE,OX:ColPos] $ "FECHA"
           xreg := RECNO()
        	FRLOCK()
        	FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]) := OX:CARGO[TB_CONT]
        	FSALDAR()
        	OX:RefreshAll()
           DBGOTO( xreg )
			ELSEIF OX:CARGO[TB_NOMBRE,OX:ColPos] == "CODCONC"
     		FRLOCK()
				FIELD->CODCONC  := OX:CARGO[TB_CONT]
				FIELD->CONCEPTO := FVECTOR( voperac, FIELD->CODCONC )
				DBUNLOCK()
        	OX:RefreshCurrent()
        ELSE
        	FRLOCK()
        	FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]) := OX:CARGO[TB_CONT]
           UNLOCK
        	OX:RefreshCurrent()
			ENDIF

     ELSEIF OX:Cargo[TB_RET] == K_TAB .AND. TBNOC(OX) == "CODCONC"
			xmenu:=MENUDOWN({	"º     º    F2    º   F5   º  ENTER   º ESC  º",;
									"º       º          º        º          º      º",;
									"º mueve º modifica º agrega º confirma º sale º"})
			aux := ABRW( 10, 40, 0, 'voperac', FIELD->&(OX:CARGO[TB_NOMBRE,OX:ColPos]), 'CONCEPTOS')
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->CODCONC  := voperac[aux]
				FIELD->CONCEPTO := SUBSTR(voperac[aux],5)
				DBUNLOCK()
			ENDIF
			PONEPAN(xmenu)
       	OX:RefreshCurrent()
     ELSEIF OX:Cargo[TB_RET] == K_F5
     	DBGOBOTTOM()
        aux := BA->FECHA
			F_ALTA( FTOC(CTOD('')) )
        FRLOCK()
        BA->FECHA := aux
			OX:PANHOME()
        OX:GOBOTTOM()
        OX:RefreshAll()
     ELSEIF OX:Cargo[TB_RET] == K_F6
			IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
        	BLANKREG(.T.)
           SKIP -1
       		FSALDAR()
        	OX:RefreshAll()
        ENDIF
     ELSEIF OX:Cargo[TB_RET] == K_F7
     	LISTADOR("LB")
*    ELSEIF OX:Cargo[TB_RET] == K_F8
*    	DO CHE
*      	OX:RefreshAll()
     ELSEIF OX:Cargo[TB_RET] == K_F9
       	FSALDAR()
       	OX:RefreshAll()

		ELSEIF OX:Cargo[TB_RET] == K_F8
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			aaux := {}
			xreg := RECNO()
			SELECT CH
     	DBSETORDER( FORDER({"FTOC(CH->ESTADO"}) )
			SEEK "CAR"
			DO WHILE CH->ESTADO == "CAR" .AND. !EOF()
				AADD( aaux, DTOC(CH->FECHA) +"³"+ LEFT(FVECTOR(vbanco,CH->BANCO),14)+"³"+ CH->NUMCHEQUE +"³"+ STR(CH->MONTO) +"³"+ CH->ESTADO + IF(CH->FECHA<=DATE(),'',' ')  +STR(RECNO(),5) )
				SKIP
			ENDDO
			ASORT(aaux,,,{|x,y| CTOD(LEFT(x,8)) < CTOD(left(y,8)) } )
			areg := ARRAY( LEN(aaux) )
			AEVAL( aaux, {|a,i| areg[i]:=VAL(RIGHT(a,5)), aaux[i]:=LEFT(a,LEN(a)-5)} )
			RECUPAN()
        IF LEN(aaux) > 0
				aach := NEWACHO( aaux,,{7,30,20,0} )
				IF MARCARACH( 7, 20, aaux,,{"Fecha   ³Banco         ³N§ Cheque ³Monto     ³Est.",;
     									 	 	 "ÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄ"}) == K_ENTER
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					SELECT BA
					FOR i=1 TO LEN(aaux)
        			IF RIGHT(aaux[i],1) == ''
							SELECT CH
 							DBGOTO(areg[i])
 							FRLOCK()
 							CH->ESTADO:="DEP"
							SELECT BA
							F_ALTA( FTOC(CTOD('')) )
							FRLOCK()
							BA->FECHA    := CH->FECHA
							BA->CODCONC  := "DEP"
							BA->CONCEPTO := IF(EMPTY(CH->CHEQUEDE), FVECTOR(voperac,BA->CODCONC), CH->CHEQUEDE )
           			BA->NUMCHEQUE:= CH->NUMCHEQUE
							BA->CHEQUE   := CH->MONTO
           		ENDIF
					NEXT
           	SELECT BA
					DBGOTOP()
					FSALDAR()
					RECUPAN()
     		ENDIF
        ELSE
				MENSAJE( 0, 0, 10, .T., "NO SE ENCONTRARON", "CHEQUES EN CARTERA !!!" )
        ENDIF
     	SELECT BA
			DBGOTO( xreg )
			DBUNLOCKALL()
     	TBPOS(OX,.T.)

		ELSEIF OX:Cargo[TB_RET] == K_F10
			MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
			aaux := {}
			xreg := RECNO()
			SELECT CHC
     	DBSETORDER( FORDER({"FTOC(CHC->ESTADO"}) )
			SEEK "CCC"
			DO WHILE CHC->ESTADO == "CCC" .AND. !EOF()
				AADD( aaux, DTOC(CHC->FECHA) +"³"+ LEFT(FVECTOR(vbancocta,CHC->BANCO),14)+"³"+ CHC->NUMCHEQUE +"³"+ STR(CHC->MONTO) +"³"+ CHC->ESTADO + IF(CHC->FECHA<=DATE(),'',' ')  +STR(RECNO(),5) )
				SKIP
			ENDDO
			SEEK "CHE"
			DO WHILE CHC->ESTADO == "CHE" .AND. !EOF()
				AADD( aaux, DTOC(CHC->FECHA) +"³"+ LEFT(FVECTOR(vbancocta,CHC->BANCO),14)+"³"+ CHC->NUMCHEQUE +"³"+ STR(CHC->MONTO) +"³"+ CHC->ESTADO + IF(CHC->FECHA<=DATE(),'',' ')  +STR(RECNO(),5) )
				SKIP
			ENDDO
			ASORT(aaux,,,{|x,y| CTOD(LEFT(x,8)) < CTOD(left(y,8)) } )
			areg := ARRAY( LEN(aaux) )
			AEVAL( aaux, {|a,i| areg[i]:=VAL(RIGHT(a,5)), aaux[i]:=LEFT(a,LEN(a)-5)} )
			RECUPAN()
        IF LEN(aaux) > 0
				aach := NEWACHO( aaux,,{7,30,20,0} )
				IF MARCARACH( 7, 20, aaux,,{"Fecha   ³Banco         ³N§ Cheque ³Monto     ³Est.",;
     									 	 	 "ÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄ"}) == K_ENTER
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					SELECT BA
					FOR i=1 TO LEN(aaux)
        			IF RIGHT(aaux[i],1) == ''
							SELECT CHC
 							DBGOTO(areg[i])
 							FRLOCK()
 							CHC->ESTADO:="COB"
							CHC->NBANCO:=cualbanco
							SELECT BA
							F_ALTA( FTOC(CTOD('')) )
							FRLOCK()
							BA->FECHA    := CHC->FECHA
							BA->CODCONC  := "EXT"
							BA->CONCEPTO := IF(EMPTY(CHC->CHEQUEPARA), FVECTOR(voperac,BA->CODCONC), CHC->CHEQUEPARA )
           			BA->NUMCHEQUE:= CHC->NUMCHEQUE
							BA->CHEQUE   := CHC->MONTO
           		ENDIF
					NEXT
           	SELECT BA
					DBGOTOP()
					FSALDAR()
					RECUPAN()
     		ENDIF
        ELSE
				MENSAJE( 0, 0, 10, .T., "NO SE ENCONTRARON", "CHEQUES PARA EXTRACCION !!!" )
        ENDIF
     	SELECT BA
			DBGOTO( xreg )
			DBUNLOCKALL()
     	TBPOS(OX,.T.)



     ELSEIF OX:Cargo[TB_RET] == K_F10
     	SETCURSOR(SC_ON)
			MARCO( 10, 30, 11, 60, "", "S", .T., 0 )
        @ 10, 30 SAY "Desde:" GET DESDE
        @ 11, 30 SAY "Hasta:" GET HASTA
        READ
        RECUPAN()
        IF LASTKEY() == K_ENTER
     		MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
        	aaux := {}
     		xreg := RECNO()
     		SELECT CH
           SET SOFTSEEK ON
        	SEEK FTOC(DESDE)
           SET SOFTSEEK OFF
        	SELECT BA
        	DO WHILE CH->FECHA >= DESDE .AND. CH->FECHA <= HASTA
					F_ALTA( FTOC(CTOD('')) )
           	BA->FECHA    := CH->FECHA
           	BA->NUMERO   := CH->NUMERO
           	BA->CONCEPTO := CH->CONCEPTO
           	BA->CHEQUE   := CH->MONTO
           	AADD( aaux, CH->(RECNO()) )
        		SKIP 1 ALIAS CH
        	ENDDO
        	SELECT CH
        	AEVAL( aaux, {|a| DBGOTO(a), BLANKREG(.T.)} )
        	SELECT BA
        	DBGOTOP()
       		FSALDAR()
       		OX:RefreshAll()
        	DBGOTO( xreg )
        	RECUPAN()
        ENDIF
     ELSEIF OX:Cargo[TB_RET] == K_ESC
*			IF UPPER( PREGUNTA( 12, "[ S ] sale.       [ C ] contin£a.", "SsCc") ) == "S"
				EXIT
*       ENDIF
     ENDIF
*		CLEARTYPEAHEAD()
	ENDDO

	DBUNLOCKALL()
	DBCOMMITALL()

RETURN


************

FUNC FSALDAR

************
LOCAL xreg := RECNO(), xsaldo

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
FFLOCK()
GO TOP
SKIP -1
IF RECNO() == xreg
	BA->SALDO := BA->DEPOSITO - BA->CHEQUE
ENDIF
xsaldo := BA->SALDO
SKIP
DO WHILE !EOF()
	BA->SALDO := xsaldo + BA->DEPOSITO - BA->CHEQUE
	xsaldo := BA->SALDO
  SKIP
ENDDO
DBGOTO( xreg )
UNLOCK
RECUPAN()

RETURN .T.


*********

FUNC FF_ALTA( cual )

*********
LOCAL xsetdel := SET(_SET_DELETED, .F. )

SEEK cual
IF FOUND()
	FRLOCK()
  RECALL
ELSE
  ADD_REC()
ENDIF
SET(_SET_DELETED, xsetdel )

RETURN( RECNO() )
