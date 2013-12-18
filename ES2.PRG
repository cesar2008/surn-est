#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

*LOGO( .T., " ESTADO DE SITUACION " )

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
  aux := .T.
  IF ES->FECHA == HASTA
  	IF PREGUNTA( 10, "CREAR ESTADO DE SITUACION NUEVAMENTE  [ S / N ] ?", "SsNn") $ "Nn"
     	aux := .F.
     ENDIF
  ENDIF

	IF aux
	MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

	aEs := {}

		* * *   Ventas   * * *
	FBASES({"PLAN2"})
	SET ORDER TO FORDER({"FECHA","TURNO"})
	DBSEEK(FTOC(DESDE),.T.)
	DO WHILE PL2->FECHA >= DESDE .AND. PL2->FECHA <= HASTA
		IF !EMPTY(FPRODUCTO(PL2->CODPROD))
     	i := ASCAN( aEs,{|a,i| a[X_CODGRUPO]==NGRUPO} )
        IF i == 0
        	AADD( aEs, {NGRUPO,FGRUPO(NGRUPO),0,0,0,0,0,0,NRUBRO} )
        ELSE
           aEs[i,X_CANTV] += PL2->CANTIDAD
           aEs[i,X_VENTA] += PL2->IMPORTE
        ENDIF
		ENDIF
     SKIP 1 ALIAS PL2
  ENDDO


		* * *   Compras   * * *
	FBASES({"COMPRAS","COMPRAS2"})
  SELECT CO
	SET ORDER TO FORDER({"FECHA","CODPROV"})
	DBSEEK(FTOC(DESDE),.T.)
  SELECT CO2
	DO WHILE CO->FECHA >= DESDE .AND. CO->FECHA <= HASTA
		DBSEEK( STR(CO->CODPROV)+CO->NUMFAC )
  	DO WHILE CO2->CODPROV==CO->CODPROV .AND. CO2->NUMFAC==CO->NUMFAC
			IF !EMPTY(FPRODUCTO(CO2->CODPROD))
     		i := ASCAN( aEs,{|a,i| a[X_CODGRUPO]==NGRUPO} )
        	IF i == 0
        		AADD( aEs, {NGRUPO,FGRUPO(NGRUPO),0,0,0,0,0,0,NRUBRO} )
        	ELSE
           	aEs[i,X_CANTC ] += CO2->CANTIDAD
           	aEs[i,X_COMPRA] += CO2->IMPORTE
        	ENDIF
			ENDIF
     	SKIP 1 ALIAS CO2
     ENDDO
     SKIP 1 ALIAS CO
  ENDDO


		* * *   Ajustes   * * *
	FBASES({"AJUSTES"})
	SET ORDER TO FORDER({"FECHA","CODPROD"})
	DBSEEK(FTOC(DESDE),.T.)
	DO WHILE AJ->FECHA >= DESDE .AND. AJ->FECHA <= HASTA
		IF !EMPTY(FPRODUCTO(AJ->CODPROD))
     	i := ASCAN( aEs,{|a,i| a[X_CODGRUPO]==NGRUPO} )
        IF i == 0
        	AADD( aEs, {NGRUPO,FGRUPO(NGRUPO),0,0,0,0,0,0,NRUBRO} )
        ELSE
           aEs[i,X_CANTA ] += AJ->CANTIDAD
           aEs[i,X_AJUSTE] += AJ->IMPORTE
        ENDIF
		ENDIF
     SKIP 1 ALIAS AJ
  ENDDO
  ASORT(aEs,,,{|x,y| CHR(x[X_RUBRO])+CHR(x[X_CODGRUPO])<CHR(y[X_RUBRO])+CHR(y[X_CODGRUPO])})



		* * *   Proveedores    * * *
	FBASES({"PROVEE","CCC","CCC2","COMPRAS"})
  aux := 0
  SELECT PRV
  GO TOP
  DO WHILE !PRV->(EOF())
  	aaux := DEUDAXPROV( PRV->(RECNO()), HASTA )
     aux += aaux[1] + aaux[2]
  	SKIP 1 ALIAS PRV
  ENDDO
	AADD( aEs, { "CCC","CTA CTE PROVEEDORES", 0, aux } )


		* * *   Clientes    * * *
	FBASES({"CLIENTES","CCV","CCV2","REM"})
  aux := 0
  SELECT CL
  GO TOP
  DO WHILE !CL->(EOF())
  	aaux := DEUDAXCLI( CL->(RECNO()), HASTA )
     aux += aaux[1] + aaux[2]
  	SKIP 1 ALIAS CL
  ENDDO
	AADD( aEs, { "CCV","CTA CTE VENTA      ", 0, aux } )



		* * *   Tarjetas    * * *
	FBASES({"TARJETAS"})
  aux1 := aux2 := 0
  aux12 := aux22 := 0
  SELECT TA
	DBSETORDER( FORDER({"TA->ESTADO"}) )
  SEEK "CAR"
  DO WHILE TA->ESTADO == "CAR"
  	IF EMPTY(TA->FECHPRES)
     	aux1 += TA->MONTO
        ++aux12
     ELSE
     	aux2 += TA->MONTO
        ++aux22
     ENDIF
  	SKIP
  ENDDO
	AADD( aEs, { "TARA","TARJETAS A PRESENTAR", aux12, aux1 } )
	AADD( aEs, { "TARC","TARJETAS PRESENTADAS", aux22, aux2 } )


		* * *   Cheques    * * *
	FBASES({"CHEQUES"})
  aux1 := aux2 := 0
  SELECT CH
	DBSETORDER( FORDER({"CH->ESTADO"}) )
  SEEK "CAR"
  DO WHILE CH->ESTADO == "CAR"
     aux1 += CH->MONTO
     ++aux12
  	SKIP
  ENDDO
	AADD( aEs, { "CHEC","CHEQUES EN CARTERA  ", aux12, aux1 } )


		* * *   Copres    * * *
	FBASES({"COPRES"})
  aux1 := aux2 := 0
  SELECT CO
	DBSETORDER( FORDER({"CO->ESTADO"}) )
  SEEK "CAR"
  DO WHILE CO->ESTADO == "CAR"
     aux1 += CO->MONTO
     ++aux12
  	SKIP
  ENDDO
	AADD( aEs, { "COPC","COPRES EN CARTERA   ", aux12, aux1 } )

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

  for i=1 to X_RUBRO
  	if len(aEs)<i
			aadd( aEs, { "","", 0, 0 } )
     endif
  next
	SETIMPRESORA( "INI", "ES" )
  aux := ASCAN( aEs, {|a| VALTYPE(a[1])=="C"})
  nCANTV := nVENTA := nCANTC := nCOMPRA := nCANTA := nAJUSTE := 0
  nTCANTV := nTVENTA := nTCANTC := nTCOMPRA := nTCANTA := nTAJUSTE := 0
  ncant := 0
  nRubro := aEs[1,X_RUBRO]
  ? "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
  ? "³ ESTADO DE SITUACION AL "+ DTOC(HASTA) +" ³"
  ? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
  ? "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
  ? "³                    ³        VENTAS         ³        COMPRAS        ³        AJUSTES        ³"
  ? "³DESCRIPCION         ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ´"
  ? "³                    ³  Cantidad³     Importe³  Cantidad³     Importe³  Cantidad³     Importe³"
  ? "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´"
  FOR y=1 TO aux-1
		IF aEs[y,X_RUBRO] # nRubro
  		? "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´"
     	IF ncant > 1
  			? "³"+SPACE(20)               +"³"+STR(nCANTV,10,3)+"³"+STR(nVENTA,12,3)+;
  	                             	 	 	 "³"+STR(nCANTC,10,0)+"³"+STR(nCOMPRA,12,0)+;
  	                             	 	 	 "³"+STR(nCANTA,10,3)+"³"+STR(nAJUSTE,12,3)+"³"
  			? "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´"
        ENDIF
  		nCANTV := nVENTA := nCANTC := nCOMPRA := nCANTA := nAJUSTE := 0
        ncant := 0
        nRubro := aEs[y,X_RUBRO]
     ENDIF
  	? "³"+PADR(aEs[y,X_DESCGRUPO],20)+"³"+STR(aEs[y,X_CANTV],10,3)+"³"+STR(aEs[y,X_VENTA],12,3)+;
  	                              	 "³"+STR(aEs[y,X_CANTC],10,0)+"³"+STR(aEs[y,X_COMPRA],12,0)+;
  	                              	 "³"+STR(aEs[y,X_CANTA],10,3)+"³"+STR(aEs[y,X_AJUSTE],12,3)+"³"
     ++ncant
		nCANTV  += aEs[y,X_CANTV ]
     nVENTA  += aEs[y,X_VENTA ]
     nCANTC  += aEs[y,X_CANTC ]
     nCOMPRA += aEs[y,X_COMPRA]
     nCANTA  += aEs[y,X_CANTA ]
     nAJUSTE += aEs[y,X_AJUSTE]

		nTCANTV  += aEs[y,X_CANTV ]
     nTVENTA  += aEs[y,X_VENTA ]
     nTCANTC  += aEs[y,X_CANTC ]
     nTCOMPRA += aEs[y,X_COMPRA]
     nTCANTA  += aEs[y,X_CANTA ]
     nTAJUSTE += aEs[y,X_AJUSTE]
  NEXT
  ? "ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍµ"
  ? "³"+SPACE(20)               +"³"+STR(nTCANTV,10,3)+"³"+STR(nTVENTA,12,3)+;
  	                            "³"+STR(nTCANTC,10,0)+"³"+STR(nTCOMPRA,12,0)+;
  	                            "³"+STR(nTCANTA,10,3)+"³"+STR(nTAJUSTE,12,3)+"³"
  ? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ"
  ?
  nTVENTA := 0
  ? "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿"
  ? "³DESCRIPCION         ³Cantidad³     Importe³"
  ? "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´"
  FOR y=aux TO LEN(aEs)
  	? "³"+PADR(aEs[y,X_DESCGRUPO],20)+"³"+STR(aEs[y,X_CANTV],8)+"³"+STR(aEs[y,X_VENTA],12,2)+"³"
     nTVENTA += aEs[y,X_VENTA]
  NEXT
* ? "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´"
* ? "³"+SPACE(29)+"³"+STR(nTVENTA,12,2)+"³"
  ? "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ"

	SETIMPRESORA("FIN")
	SET DEVICE TO SCREEN
	SET ALTERNATE TO
	SET PRINTER OFF
	SET PRINTER TO
	SET CONSOLE ON
	IF EST->SALIDA == "PAN" .AND. FILE("..\VERTXT.COM")
		SALVAPAN( 0, 0, 24, 79 )
*		RUN ..\VERTXT LISTADO.TXT
  	aux := "..\VERTXT "+ XNAME("XLIS")+".TXT"
 		RUN &aux
		RECUPAN()
	ENDIF
	CLEARTYPEAHEAD()

ENDIF

RETURN
