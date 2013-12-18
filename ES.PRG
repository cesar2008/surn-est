#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

X_CODGRUPO  := 1
X_DESCGRUPO := 2
X_CANTV     := 3
X_VENTA     := 4
X_CANTC     := 5
X_COMPRA    := 6
X_CANTA     := 7
X_AJUSTE    := 8
X_RUBRO     := 9


HASTA := QUEFECHA( 10, 25, DATE() )
DESDE := HASTA
IF LASTKEY() == K_ENTER

	FBASES({"ESTSIT"})
  DBSEEK( FTOC(HASTA) )
  lAux := .T.
  IF ES->FECHA == HASTA
  	IF PREGUNTA( 10, "CREAR ESTADO DE SITUACION NUEVAMENTE  [ S / N ] ?", "SsNn") $ "Nn"
     	lAux := .F.
     ENDIF
  ENDIF

	IF lAux

		MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
     nValRef := 0
		cRaya1 := replic('Ä',60)
		cRaya2 := replic('Í',60)
 		aEs := { 'É'+ replic('Í',60) +'»',;
		        padc('CUADRO DE SITUACION AL '+DTOC(HASTA),60,' ') }

			* * *   Stock Actual  * * *
		aadd( aEs,cRaya2 )
		aadd( aEs, padr("STOCK COMBUSTIBLES ",60,' ') )
		aadd( aEs,cRaya1 )
  	INVENTARIAR( {||PRD->RUBRO==1}, .F. )
     select X
     GO TOP
     DO WHILE !EOF()
     	aadd( aEs, padr(padr( str(X->CODPROD)+' '+FPROD(X->CODPROD),20,' ') +'³'+ str(X->STOCKACT) +'³'+ STR(X->STOCKACT*X->PRECVENTA,10,3),60,' ') )
     	nValRef += ( X->STOCKACT*X->PRECVENTA )
     	SKIP
     ENDDO

			* * *   C.C. Proveedores   * * *
		aadd( aEs,cRaya2 )
		aadd( aEs, padr("CTA.CTE.PROVEEDORES",60,' ') )
		aadd( aEs,cRaya1 )
		FBASES({"PROVEE","CCC","CCC2","COMPRAS"})
  	nAux := 0
  	SELECT PRV
  	GO TOP
  	DO WHILE !PRV->(EOF())
  		aaux := DEUDAXPROV( PRV->CODPROV, HASTA )
     	nAux += aaux[1] + aaux[2]
  		SKIP 1 ALIAS PRV
  	ENDDO
		aadd( aEs, padr(padr("PLAYA",40,' ')+"³"+str(nAux,10,2),60,' ') )
    	nValRef -= nAux

			* * *   C.C. Clientes    * * *
		FBASES({"CLIENTES","CCV","CCV2","REM"})
  	nAux := 0
  	SELECT CL
  	GO TOP
  	DO WHILE !CL->(EOF())
  		aaux := DEUDAXCLI( CL->CODCLI, HASTA )
     	nAux += aaux[1] + aaux[2]
  		SKIP 1 ALIAS CL
  	ENDDO
		aadd( aEs,cRaya2 )
		aadd( aEs, padr(padr("CTA.CTE.VENTA",40,' ')+"³"+str(nAux,10,2),60,' ') )
    	nValRef += nAux

			* * *   Bancos   * * *
		aadd( aEs,cRaya2 )
		aadd( aEs, padr("BANCOS",60,' ') )
		aadd( aEs,cRaya1 )
		FBASES({"..\ADM\BANCO"})
  	SELECT BA
     GO TOP
  	DO WHILE !BA->(EOF())
     	nAux := 0
     	FBASES({"+..\ADM\LIBANCO"+STR(BA->(RECNO()),1) })
     	select LI
  		dbseek(FTOC(HASTA),.T.)
        do while LI->FECHA<=HASTA .and. !eof()
     		nAux := LI->SALDO
        	skip
        enddo
			aadd( aEs, padr(padr(BA->NOMBANCO +"("+BA->NUMCTA+")",40,' ')+"³"+str(nAux,10,2),60,' ') )
    		nValRef += nAux
     	FBASES({"-..\ADM\LIBANCO"+STR(BA->(RECNO()),1) })
  		SKIP 1 ALIAS BA
  	ENDDO

			* * *   Tarjetas    * * *
		FBASES({"TARJETAS"})
  	nAux := 0
  	SELECT TA
		DBSETORDER( FORDER({"TA->ESTADO"}) )
  	SEEK "PRE"
  	DO WHILE TA->ESTADO == "PRE" .AND. !EOF()
     	nAux += TA->MONTO
  		SKIP
  	ENDDO
     aadd( aEs,cRaya2 )
		aadd( aEs, padr(padr("TARJETAS PRESENTADAS",40,' ') +"³"+ str(nAux,10,2),60,' ') )
    	nValRef += nAux
  	SEEK "CAR"
  	DO WHILE TA->ESTADO == "CAR" .AND. !EOF()
     	nAux += TA->MONTO
  		SKIP
  	ENDDO
		aadd( aEs, padr(padr("TARJETAS EN CARTERA",40,' ') +"³"+ str(nAux,10,2),60,' ') )
    	nValRef += nAux

			* * *   Caja Chica  * * *
		FBASES({"CAJCH"})
  	SELECT CAC
  	GO BOTTOM
     aadd( aEs,cRaya2 )
		aadd( aEs, padr(padr("CAJA CHICA",40,' ') +"³"+ str(CAC->SALDO),60,' ') )
    	nValRef += CAC->SALDO

			* * *   Cheques    * * *
		FBASES({"CHEQUES"})
  	nAux := 0
  	SELECT CH
		DBSETORDER( FORDER({"CH->ESTADO"}) )
  	SEEK "CAR"
  	DO WHILE CH->ESTADO == "CAR" .and. !eof()
     	nAux += CH->MONTO
  		SKIP
  	ENDDO
     aadd( aEs,cRaya2 )
		aadd( aEs, padr(padr("CHEQUES EN CARTERA",40,' ')+"³"+ str(nAux,10,2),60,' ') )
    	nValRef += nAux

			* * *   Efectivo  * * *
		FBASES({"CAJA"})
     nAux := 0
  	select CA
  	DBSEEK( FTOC(HASTA), .T. )
  	DO WHILE CA->FECHA==HASTA .AND. !EOF()
     	if ca->codconc == 'EF '
     		nAux += CA->INGRESO - CA->EGRESO
        endif
  		SKIP
  	ENDDO
     aadd( aEs,cRaya2 )
		aadd( aEs, padr(padr("EFECTIVO",40,' ')+"³"+ str(nAux,10,2),60,' ') )
    	nValRef += nAux

			* * *   CHEQUES DIFERIDOS   * * *
     aadd( aEs,cRaya2 )
		aadd( aEs, padr("CHEQUES DIFERIDOS",60,' ') )
     aadd( aEs,cRaya1 )
		FBASES({"..\ADM\BANCO"})
  	SELECT BA
     GO TOP
  	DO WHILE !BA->(EOF())
     	FBASES({"+..\ADM\CHEQUES"+STR(BA->(RECNO()),1) })
     	select CH
  		GO TOP
  		nAux := 0
        sum CH->MONTO to nAux for!empty(FECHA)
			aadd( aEs, padr(padr(BA->NOMBANCO +"("+BA->NUMCTA+")",40,' ')+'³'+ str(nAux,10,2),60,' ') )
    		nValRef -= nAux
     	FBASES({"-..\ADM\CHEQUES"+STR(BA->(RECNO()),1) })
  		SKIP 1 ALIAS BA
  	ENDDO
     aadd( aEs,cRaya2 )
		aadd( aEs, padr(padr("VALOR REFERENCIA",40,' ')+"³"+str(nValRef,0,2),60,' ') )
     aeval( aEs,{|a,i| aEs[i] := 'º'+ a +'º'},2)
     aadd( aEs, 'È'+ replic('Í',60) +'¼' )

		RECUPAN()


  	IF PREGUNTA( 10, "DESEA GRABAR ESTA INFORMACION  [ S / N ] ?", "SsNn") $ "Ss"
			FBASES({"ESTSIT"})
  		DBSEEK( FTOC(HASTA) )
  		IF !FOUND()
     		GO TOP
        	IF !EMPTY(ES->FECHA) .OR. LASTREC() == 0
        		ADD_REC()
        	ENDIF
     	ENDIF
     	FRLOCK()
     	ES->FECHA := HASTA
     	ES->ESTADO := ATOS(aEs)
     	DBUNLOCK()
  	ENDIF
  ELSE

  	aEs := STOA( ES->ESTADO )
	ENDIF

  LISTADOR("INI")
	SETIMPRESORA( "INI", "CUADRO SITUACION...")
  for i=1 to len(aEs)
  	? aEs[i]
  next
  I_CL := len(aEs)
  I_IMPRIMIO := .t.
	LISTADOR("FIN")

	CLEARTYPEAHEAD()

ENDIF

RETURN
