#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PARAMETERS cualfecha
LOCAL ym2:=2, xm2:=0, lastcolor, pfm, udm, px, xdia, r
LOCAL xmes, xanio, aux, y1, x1, y2, x2, aCal, aaux
DEFAULT cualfecha TO DATE()

lastcolor = SETCOLOR("W/N")
xdia = DAY(cualfecha)
xmes = MONTH(cualfecha)
xanio = YEAR(cualfecha)

LOGO(.T., " CALENDARIO DE VENCIMIENTOS ")

MENUDOWN({ "  <+> pasa de  º   PgUp/PgDn   º    ENTER    º ESC  ",;
				" un d¡a a otro º cambia de mes º ver detalle º sale "})

BOTON( 10,55, "S", .F.,"E  estaci¢n            ", "S  servicompras        " )
BOTON( 17, 60, "S", .F., "D¡as Transc.", "desde " + DTOC(cualfecha), " " )
*SELECT FE
DO WHILE .T.

	MENSAJE( 99, 99, 0, .F., " AGUARDE . . ." )
  DISPBEGIN()
	NEWEDIT2("CAL")
	mesanio = "/"+ STR(xmes,2,0) +"/"+ STR(xanio-1900,2,0)
	pfm = CTOD( "01" + mesanio )
	udm = DIASXMES( xanio, xmes )
	px  = DOW( pfm )
	xdia = IF( xdia>udm, udm, xdia )
	
  aCal := {}
  F_ABASE({"PRV","CO","CO2"},"CERRAR")
	FBASES({"-PROVEE"})
	FBASES({"-"+UT_SISTEMA+"\MIN\COMPRAS","-"+UT_SISTEMA+"\MIN\PROVEE"})
	FBASES({"+"+UT_SISTEMA+"\EST\COMPRAS","+"+UT_SISTEMA+"\EST\PROVEE"})
  SELECT CO
  DBSETORDER( FORDER({"FECHVENC"}) )
  DBSEEK( FTOC(pfm), .T. )
  DO WHILE MONTH(CO->FECHVENC)==xmes .AND. YEAR(CO->FECHVENC)==xanio
     IF CO->TIPOCOMPRA == 2 .AND. EMPTY(CO->FECHCC)
  		i := ASCAN( aCal, {|a| a[1]==DAY(CO->FECHVENC)} )
     	IF i==0
     		AADD( aCal, {DAY(CO->FECHVENC),0,0} )
        	i := LEN(aCal)
     	ENDIF
     	++aCal[i,2]
       ENDIF
  	SKIP
  ENDDO

	FBASES({"-"+UT_SISTEMA+"\EST\COMPRAS","-"+UT_SISTEMA+"\EST\PROVEE"})
	FBASES({"+"+UT_SISTEMA+"\MIN\COMPRAS","+"+UT_SISTEMA+"\MIN\PROVEE"})
  SELECT CO
  DBSETORDER( FORDER({"FECHVENC"}) )
  DBSEEK( FTOC(pfm), .T. )
  DO WHILE MONTH(CO->FECHVENC)==xmes .AND. YEAR(CO->FECHVENC)==xanio
     IF CO->TIPOCOMPRA == 2 .AND. EMPTY(CO->FECHCC)
  		i := ASCAN( aCal, {|a| a[1]==DAY(CO->FECHVENC)} )
     	IF i==0
     		AADD( aCal, {DAY(CO->FECHVENC),0,0} )
        	i := LEN(aCal)
     	ENDIF
     	++aCal[i,3]
       ENDIF
  	SKIP
  ENDDO
	FBASES({"-"+UT_SISTEMA+"\MIN\COMPRAS","-"+UT_SISTEMA+"\MIN\PROVEE"})

  bY := {|x|ym2+FY(x,px)*3}
  bX := {|x|xm2-6+FX(x)*7}
	FOR i = 1 TO udm
		y:=EVAL(bY,i)
		x:=EVAL(bX,i)
		@ y,x SAY i PICT "99" COLOR IF(x==1,"UW/N","W/N")
     z := ASCAN( aCal, {|a|a[1]==i} )
     IF z # 0
*			@   y,x+4 SAY " " COLOR "*N/W"
*			@ y+1,x+4 SAY " " COLOR "*N/W"
			IF aCal[z,2] # 0
				@   y,x+3 SAY TRANS(aCal[z,2],"E99") COLOR "*N/W"
        ENDIF
			IF aCal[z,3] # 0
				@ y+1,x+3 SAY TRANS(aCal[z,3],"S99") COLOR "*N/W"
        ENDIF
     ENDIF
	NEXT i
  SELECT FE
  DBSEEK(DTOS(pfm),.T.)
  DO WHILE YEAR(FE->FERIADO)==xanio .AND. MONTH(FE->FERIADO)==xmes .AND. !EOF()
		y:=EVAL(bY,DAY(FE->FERIADO))
		x:=EVAL(bX,DAY(FE->FERIADO))
		@ y,x SAY i PICT "99" COLOR "UW/N"
     SKIP
	ENDDO
  IF YEAR(DATE())==xanio .AND. MONTH(DATE())==xmes
		@ EVAL(bY,DAY(DATE())), EVAL(bX,DAY(DATE())) SAY DAY(DATE()) PICT "99" COLOR "+W/N"
  ENDIF
	BOTON( ym2+3, 57, "S", .F., PADC(ALLTRIM(nomes[xmes])+STR(xanio,5),16) )
  DISPEND()
  RECUPAN()

	KEYBOARD " "
	DO WHILE .T.
		y1:=EVAL(bY,xdia)-1; y2:=y1+3
		x1:=EVAL(bX,xdia)-1; x2:=x1+7
  	aux:=SAVESCREEN( y1, x1, y2, x2 )
 		DISPBOX( y1, x1, y2, x2, "±±±±±±±±", "W/N" )

		SETCURSOR( 0 )
 		@ 19, 64 SAY CTOD(STR(xdia,2)+mesanio) - cualfecha PICT "9999" COLOR "N/W"
		K = INKEY(0)

  	RESTSCREEN( y1, x1, y2, x2, aux )
		IF LASTKEY() = -8
			EXIT
		ELSEIF k = K_DOWN                            &&. Baja
			xdia = xdia + 7
		ELSEIF k = K_UP                              &&. Sube
			xdia = xdia - 7
		ELSEIF k = K_RIGHT                           &&. ->
			xdia = xdia + 1
		ELSEIF k = K_LEFT                            &&. <-
			xdia = xdia - 1
		ELSEIF K == 3                           		&&. PgUp
			IF ++xmes > 12
				xanio = xanio + 1
				xmes = 1
			ENDIF
			EXIT
		ELSEIF K == K_END                       		&&. End
			xanio = xanio + 1
			EXIT
		ELSEIF K == K_HOME                      		&&. Home
			xanio = xanio - 1
			EXIT
		ELSEIF K == 18                           		&&. PgDn
			xmes = xmes - 1
			IF xmes < 1
				xanio = xanio - 1
				xmes = 12
			ENDIF
			EXIT
		ELSEIF k == K_ENTER                          &&. ENTER
 			DISPBOX( y1, x1, y2, x2, "±±±±±±±±", "W/N" )
     	xaux := CTOD(STR(xdia,2)+mesanio)
        aaux := {}
			FBASES({"-"+UT_SISTEMA+"\MIN\COMPRAS","-"+UT_SISTEMA+"\MIN\PROVEE"})
			FBASES({"+"+UT_SISTEMA+"\EST\COMPRAS","+"+UT_SISTEMA+"\EST\PROVEE"})
  		SELECT CO
  		DBSETORDER( FORDER({"FECHVENC"}) )
  		DBSEEK( FTOC(xaux) )
  		DO WHILE CO->FECHVENC==xaux .AND. !EOF()
     		IF CO->TIPOCOMPRA == 2 .AND. EMPTY(CO->FECHCC)
  				AADD( aaux, LEFT(CO->NUMFAC,13) +'³'+ FPROVEE(CO->CODPROV) +'³'+ DTOC(CO->FECHA) +'³'+ STR(CO->TOTAL) )
           ENDIF
  			SKIP
  		ENDDO
        IF LEN(aaux) # 0
        	AADD( aaux, PADC("SERVICOMPRAS",LEN(aaux[1]),"Ä") )
        ENDIF

			FBASES({"-"+UT_SISTEMA+"\EST\COMPRAS","-"+UT_SISTEMA+"\EST\PROVEE"})
			FBASES({"+"+UT_SISTEMA+"\MIN\COMPRAS","+"+UT_SISTEMA+"\MIN\PROVEE"})
  		SELECT CO
  		DBSETORDER( FORDER({"FECHVENC"}) )
  		DBSEEK( FTOC(xaux) )
  		DO WHILE CO->FECHVENC==xaux .AND. !EOF()
     		IF CO->TIPOCOMPRA == 2 .AND. EMPTY(CO->FECHCC)
  				AADD( aaux, LEFT(CO->NUMFAC,13) +'³'+ FPROVEE(CO->CODPROV) +'³'+ DTOC(CO->FECHA) +'³'+ STR(CO->TOTAL) )
           ENDIF
  			SKIP
  		ENDDO
        IF LEN(aaux) # 0
				op = PP_SELEC(7, 1, 0, 0, aaux, 1, "FACTURAS QUE VENCEN", "S", .T. )
        	RECUPAN()
        ENDIF
  		RESTSCREEN( y1, x1, y2, x2, aux )
		ELSEIF k == K_ESC                            &&. Esc
			EXIT
		ENDIF
		IF xdia >= udm
			xdia = udm
		ELSEIF xdia < 1
			xdia = 1
		ENDIF
		
	ENDDO
	IF LASTKEY()==K_ESC
		r = cualfecha
		EXIT
	ELSEIF LASTKEY()==K_ENTER
		r = CTOD( STR(xdia,2,0) + mesanio )
		EXIT
	ENDIF
	
ENDDO
SETCOLOR(lastcolor)
FBASES({"-"+UT_SISTEMA+"\EST\COMPRAS","-"+UT_SISTEMA+"\EST\PROVEE"})
FBASES({"-"+UT_SISTEMA+"\MIN\COMPRAS","-"+UT_SISTEMA+"\MIN\PROVEE"})

RETURN r


******************
STATIC FUNC FY(cual,_col)
******************
RETURN INT( (cual+_col-2)/7 )+1

*************
STATIC FUNC FX(cual)
*************
RETURN DOW(CTOD(STR(cual,2)+mesanio))
