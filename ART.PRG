#include "MIN.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "EDI.CH"
#include "TB.CH"

LOCAL AX
op = MENUFLASH( ym2, xm2, 1, .T., "", "ACTUALIZAR PRODUCTOS"    ,;
													"INVENTARIO / STOCK  "  ,;
				      "ACTUALIZ.DE PRECIOS "  ,;
				      "PRODUCTOS COMPUESTOS"  ,;
				      "UNIFICAR CODIGOS    "  ,;
				      "BORRAR PRODUCTOS    " )

IF op == 1
	SETCOLOR("N/W,W/N,,,N/W")
	LOGO(.T., " ACTUALIZACION DE PRODUCTOS " )
	MENUDOWN({"     º  ENTER   º   F3   º   F5   º   F6    º   TAB    º ESC ",;
				 "       º  o  F2   º busca  º        º         º  elige   º     ",;
				 " mueve º modifica º CODIGO º agrega º elimina º producto º sale"})
	SELECT ART
	aX := NEWEDIT( "PROD" )
	DO WHILE .T.
		k := FVERREG( aX, {||K==9.OR.K==-4.OR.K==-5.OR.K==-6.OR.K==-2} )
		IF k == K_TAB
			PRIVATE bcamp[2], bmasc[2], bcab[2], bedit
			bcamp[ 1] = "ART->CODPROD"
			bcamp[ 2] = "ART->DESCPROD"
			bmasc[ 1] = ""
			bmasc[ 2] = ""
			bcab[ 1] = "C¢digo"
			bcab[ 2] = "Descripci¢n"
			bedit = "FF"
			lastcolor = SETCOLOR("W/N,N/W")
			xmenu2:=MENUDOWN({"  <+>  ³  F3   ³  F4    ³ ENTER  ³ ESC  ",;
									"       ³       ³        ³ elige  ³      ",;
									" mueve ³ busca ³ busca+ ³ y sale ³ sale "})
			lastreg = RECNO()
			BROW( 10, 15, 20, 65, "STOCK", bcamp, bmasc, bcab, bedit )
			RECUPAN()
			IF LASTKEY() # K_ENTER
				GO lastreg
			ENDIF
			SETCOLOR(lastcolor)
			PONEPAN(xmenu2)
			
		ELSEIF k == K_F3
	aux := ART->CODPROD
			aux := INGRVAL( 10, 20, "C¢digo Prod.:", aux, "9999", "")
	IF LASTKEY() == K_ENTER
		SET ORDER TO 1
	   SET SOFTSEEK ON
		SEEK aux
	   IF ART->CODPROD # aux
		TONE(100,1)
	   ENDIF
	   SET SOFTSEEK OFF
	ENDIF
			
		ELSEIF k == K_ENTER .OR. K==K_F2 .OR. k == K_F5
			FEDPROD( AX, K )
			
		ELSEIF K == K_F6
			FEDITOR( aX, "ELIMINAR" )
		ELSEIF K == K_F7
			LISTADOR("STOCK")
		ELSEIF K == K_ESC
			EXIT
		ENDIF
	ENDDO
	FEDITOR( aX, "SACAPAN" )
ELSEIF op == 2
	DO STI
ELSEIF op == 3
	DO PRE
ELSEIF op == 4
	DO COMP
ELSEIF op == 5
	DO UC
ELSEIF op == 6
	DO ELI
ENDIF

RETURN


*************************************

FUNC FEDPROD( AX, K, acual1, acual2 )

*************************************
LOCAL xmenu, xorder, r

xmenu:=MENUDOWN({"     º  F2  º ALT M  º presione TAB para obtener una º  F10   º ESC  ",;
						"       º modi-º calcu- º lista de opciones. (solo fun- º graba  º      ",;
						" mueve º fica º ladora º ciona en los campos con  ).  º y sale º sale "})
FEDITOR( aX, "SETVARS", K, .F. )
IF K == K_F5
	xorder := INDEXORD()
	SET ORDER TO 1
  SET SOFTSEEK OFF
  SEEK 0
	AX[ED_REGISTRO] := IF( FOUND(), RECNO(), LASTREC()+1 )
  SET ORDER TO xorder
	EDPONE(aX,"ART->UNXCAJA", 1 )
	EDPONE(aX,"ART->EXENTO", 1 )
	EDPONE(aX,"ART->FECHALTA", DATE() )
	DBGOBOTTOM()
	aX[ED_I]    := 1
	aX[ED_MODE] := "MOSTRARTODO"
ELSE
	r := ASCAN( aX[ED_FIELDS], "ART->RUBRO" )
  IF r # 0
	aX[ED_EDIT] := STUFF( aX[ED_EDIT], r, 1, "F" )
  ENDIF
*       r := ASCAN( aX[ED_FIELDS], "ART->CODPROD" )
* IF r # 0
*       aX[ED_EDIT] := STUFF( aX[ED_EDIT], r, 1, "F" )
* ENDIF
ENDIF
IF acual1 # NIL
	AEVAL( acual1, {|a,i| EDPONE(aX,a,acual2[i])} )
ENDIF
DO WHILE .T.
	FEDITAR( aX, { K_TAB, K_F10, K_ESC } )
	IF aX[ED_UPDATE]
		aX[ED_MODE] := "MOSTRAR"
		IF EDNOM(aX) == "ART->CODPROD"                          //.AND. AX[ED_MODAPP] == "AGREGAR"
			EDPONE(aX, "ART->CODPROD", EDCONT(aX) )
			SET ORDER TO 1
			IF FREPEAT( EDCONT(aX), aX[ED_MODAPP] )
				MENSAJE (0, 0, 10, .T.,"CODIGO REPETIDO !!! ")
				EDPONE( aX,, aX[ED_LAST] )
				aX[ED_TECLA] := 0
			ENDIF
			aX[ED_MODE] := "MOSTRARTODO"
		ELSEIF EDNOM(aX) == "ART->PRECIO"
			EDPONE(aX,EDNOM(AX), EDCONT(aX) )
			FOR i=1 TO 4
				IF EDCONT(aX,"ART->NETO"+STR(i,1)) == 0
					EDPONE( aX, "ART->UTIL"+STR(i,1), 0 )
				ELSE
					EDPONE( aX, "ART->UTIL"+STR(i,1), EDCONT(aX,"ART->PRECIO")-EDCONT(aX,"ART->COSTO"+STR(i,1)) )
				ENDIF
			NEXT
			aX[ED_MODE] := "MOSTRARTODO"
		ELSEIF "NETO"$EDNOM(aX) .OR. EDNOM(aX) $ "ART->IMPINT ART->EXENTO"
			EDPONE(aX,,EDCONT(aX) )
			IF "NETOBASE"$EDNOM(aX)
		aux := RIGHT(EDNOM(aX),1)
				IF EDCONT( aX,"ART->NETO"+aux ) == 0
					EDPONE( aX, "ART->NETO"+aux, EDCONT(aX) )
	   ENDIF
			ELSEIF "NETO"$EDNOM(aX)
		aux := RIGHT(EDNOM(aX),1)
				IF EDCONT( aX,"ART->NETOBASE"+aux ) == 0
					EDPONE( aX, "ART->NETOBASE"+aux, EDCONT(aX) )
	   ENDIF
	ENDIF
			FOR i=1 TO 4
				IF EDCONT( aX, "ART->NETO"+STR(i,1)) == 0
					EDPONE( aX, "ART->IVA"+STR(i,1), 0 )
					EDPONE( aX, "ART->COSTO"+STR(i,1), 0 )
					EDPONE( aX, "ART->UTIL"+STR(i,1), 0 )
				ELSE
					EDPONE( aX, "ART->IVA"+STR(i,1), EDCONT(aX,"ART->NETO"+STR(i,1))*VA->PIVA1/100*EDCONT(aX,"ART->EXENTO") )
					EDPONE( aX, "ART->COSTO"+STR(i,1), EDCONT(aX,"ART->NETO"+STR(i,1))+EDCONT(aX,"ART->IVA"+STR(i,1))+EDCONT(AX,"ART->IMPINT") )
					EDPONE( aX, "ART->UTIL"+STR(i,1), EDCONT(aX,"ART->PRECIO")-EDCONT(aX,"ART->COSTO"+STR(i,1)) )
				ENDIF
			NEXT
			aX[ED_MODE] := "MOSTRARTODO"
		ELSEIF EDNOM(aX) == "ART->RUBRO" .AND. AX[ED_MODAPP] == "AGREGAR"
			EDPONE(aX, "ART->RUBRO", EDCONT(aX) )
			aux := PROXCOD(EDCONT(AX,"ART->RUBRO"))
			IF aux == 0
				IF !EMPTY(FRUBRO(EDCONT(AX,"ART->RUBRO")))
					EDPONE(AX,"ART->CODPROD",RU->DESDECOD)
				ENDIF
			ELSE
		IF aux+1 > RU->HASTACOD
					MENSAJE ( 0, 0, 10, .T.,"NO HAY MAS ESPACIO DENTRO DE ESTE RUBRO !!! ")
	   ELSE
					EDPONE(AX,"ART->CODPROD",aux+1)
				ENDIF
			ENDIF
			aX[ED_MODE] = "MOSTRARTODO"
		ENDIF
	ELSEIF aX[ED_TECLA] == K_TAB
		IF EDNOM(aX) == "ART->RUBRO"
			IF FELERUB(EDCONT(AX)) # 0
				EDPONE( aX, "ART->RUBRO", RU->(RECNO()) )
				aux := PROXCOD(EDCONT(AX,"ART->RUBRO"))
				IF aux == 0
					IF !EMPTY(FRUBRO(EDCONT(AX,"ART->RUBRO")))
						EDPONE(AX,"ART->CODPROD",RU->DESDECOD)
					ENDIF
				ELSE
			IF aux+1 > RU->HASTACOD
						MENSAJE ( 0, 0, 10, .T.,"NO HAY MAS ESPACIO DENTRO DE ESTE RUBRO !!! ")
		ELSE
						EDPONE(AX,"ART->CODPROD",aux+1)
					ENDIF
				ENDIF
			ENDIF
		ELSEIF "CODPROV" $ EDNOM(aX)
			IF FELEGIR( "PRO", EDCONT(AX) ) # 0
				EDPONE( aX,, PRV->CODPROV )
			ENDIF
		ENDIF
		aX[ED_MODE] = "MOSTRARTODO"
	ELSEIF aX[ED_TECLA]==K_ESC .OR. ( aX[ED_TECLA]==K_ENTER .AND. aX[ED_I]==LEN(aX[ED_FIELDS]) ) .OR. aX[ED_TECLA] == K_F10
	nCodAnt := ART->CODPROD
		aux := "S"
		IF aX[ED_TECLA] == K_F10
			aux := "G"
		ELSE
			IF FEDITOR( aX, "HUBOCAMBIOS" )
				aux := UPPER( PREGUNTA( 0, "¨ [ G ] graba     [ S ] sale     [ C ] contin£a ", "GgSsCc" ) )
			ENDIF
		ENDIF
     IF aux == "G"
	IF EDCONT(AX,"ART->CODPROD")==0
				MENSAJE (0, 0, 10, .T.,"FALTA CODIGO  !!! ")
	   aux := "C"
	ELSEIF EDCONT(AX,"ART->RUBRO") == 0
				MENSAJE (0, 0, 10, .T.,"FALTA RUBRO !!! ")
	   aux := "C"
	ELSEIF EMPTY(EDCONT(AX,"ART->DESCPROD"))
				MENSAJE (0, 0, 10, .T.,"FALTA DESCRIPCION !!! ")
	   aux := "C"
	ENDIF
	IF aux == "G"
		IF "AGRE" $ aX[ED_MODAPP]
					AX[ED_REGISTRO] := IF( DBSEEK(0), RECNO(), LASTREC()+1 )
	   ENDIF
				FEDITOR( aX, "GRABAR", .F. )
		FPROM(.T.)
		IF ART->CODPROD # nCodAnt .AND. "MOD" $ aX[ED_MODAPP]   .AND. (2==1)            // PROVISORIO
					MENSAJE (0, 0, 0, .F., " REEMPLAZANDO CODIGOS EN COMPRAS Y VENTAS ... ")
	      aaux :={{"TICKETS2","TI2"},;
		      {"FACA2","FA2"},;
		      {"FACB2","FB2"},;
		      {"REM2","RE2"} }
					FOR z=1 TO LEN(aaux)
						FBASES({aaux[z,1]}, .F. )
		 SET ORDER TO
			SELECT (aaux[z,2])
		 LOCATE FOR FIELD->CODPROD==nCodAnt .AND. FIELD->NEGOCIO=="*"
			DO WHILE !EOF()
			FRLOCK()
				(aaux[z,2])->CODPROD := ART->CODPROD
				DBUNLOCK()
			LOCATE FOR (aaux[z,2])->CODPROD==nCodAnt .AND. FIELD->NEGOCIO=="*" REST
		 ENDDO
	      NEXT
					FBASES({"COMPRAS2"}, .F. )
	      SET ORDER TO
	      FFLOCK()
	      REPLACE CO2->CODPROD WITH ART->CODPROD FOR CO2->CODPROD==nCodAnt
		DBUNLOCK()
	      SET ORDER TO 1
		RECUPAN()
	   ENDIF
	ENDIF
	SELECT ART
			EXIT
		ELSEIF aux == "S"
			EXIT
		ENDIF
	ENDIF
ENDDO
PONEPAN(xmenu)

RETURN ( aux=="G" )


********************

FUNC PROXCOD( xrub )

********************
LOCAL xbase:=DBF(), r:=0, xreg :=RECNO(), xorder:=INDEXORD()

MENSAJE (99, 99, 0, .F.,"BUSCANDO...")
SELECT RU
IF xrub>0 .AND. xrub<=LASTREC()
	GO xrub
ENDIF
IF !DELETED()
	SELECT ART
	SET ORDER TO 1
	DBSEEK( RU->DESDECOD, .T. )
  r := 9999
	DO WHILE ART->CODPROD>=RU->DESDECOD .AND. ART->CODPROD<=RU->HASTACOD
	@ 24,70 SAY ART->CODPROD
	IF ART->CODPROD - r > 1
	EXIT
     ENDIF
		r := ART->CODPROD
     SKIP
  ENDDO
  IF r == 9999
	r := RU->DESDECOD
  ENDIF
ENDIF
DBSELECTAREA(xbase)
SET ORDER TO xorder
GO xreg
RECUPAN()

RETURN r



**********

FUNC UAXR( xrub )

**********
LOCAL xbase:=DBF(), r:=0, xreg :=RECNO(), xorder:=INDEXORD()

SELECT ART
SET ORDER TO 2
SET SOFTSEEK ON
SEEK STR(xrub+1,3)
SKIP -1
IF ART->RUBRO == xrub
	r := ART->CODPROD
ENDIF
SET SOFTSEEK OFF
SET ORDER TO xorder
GO xreg
DBSELECTAREA(xbase)

RETURN r


********************

FUNC FELERUB( cual )

********************
LOCAL xcolor :=SETCOLOR("+W/N,N/W")
LOCAL xbase  := DBF()
LOCAL xreg   := RECNO()
LOCAL xmenu  :=MENUDOWN({ "º  <+>  º PgUp   º  F2   º  F3   º   F4   º   F5   º ENTER  º ESC  º",;
									"º       º PgDown º       º       º        º        º elige  º      º",;
									"º mueve º mueve+ º modif.º busca º busca+ º agrega º y sale º sale º"})
LOCAL aCpo:={                                                                         ;
	{ "STR(RECNO(),3)", "C¢d;Rub",                       '', 'F', 'F',  3, 0 },;
	{ "DESCRUB",        "Descripci¢n; ",                 '', 'F',  '',  0, 0 },;
	{ "DESDECOD",       "Desde;pro.",                    '', 'F',  '',  0, 0 },;
	{ "HASTACOD",       "Hasta;pro.",                    '', 'F',  '',  0, 0 } }
LOCAL OX, aX, xmenu2

SELECT RU
aCpo := FARRAYAUX( aCpo )

MARCO( 10, 20, 20, 78, "<< RUBROS >>", "D", .T., 0 )
OX := MYBROWSE( 10, 20, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 0
IF cual>0 .AND. cual<=LASTREC()
	GO cual
ELSE
	OX:GOTOP()
ENDIF

DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_F7.OR.nK==K_F5.OR.nK==K_F2.OR.nK==K_ENTER} )
	
	IF OX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
		UNLOCK
		TBPOS(OX)
		
	ELSEIF OX:Cargo[TB_RET] == K_F2 .OR. OX:Cargo[TB_RET] == K_F5
		xmenu2:=MENUDOWN({"º  <+>  º  F2   º   F10   º ESC  º",;
								"º       º       º graba y º      º",;
								"º mueve º modif.º  sale   º sale º"})
		aX := NEWEDIT( "RUBRO" )
		FEDITOR( aX, "SETVARS", OX:Cargo[TB_RET], .T. )
		IF OX:CARGO[TB_RET] == K_F5
	xreg := RECNO()
	DBGOBOTTOM()
			EDPONE(aX,"RU->DESDECOD", RU->HASTACOD+1 )
			EDPONE( aX, "RU->HASTACOD", EDCONT(AX,"RU->DESDECOD")+199 )
			aX[ED_I]        := 1
			aX[ED_MODE]     := "MOSTRARTODO"
	aX[ED_REGISTRO] := LASTREC()+1
	GO xreg
		ENDIF
		DO WHILE .T.
			FEDITAR( aX, { K_TAB, K_F10, K_ESC } )
			IF aX[ED_UPDATE]
				aX[ED_MODE] := "MOSTRAR"
				IF EDNOM(aX) == "RU->CODRUB"
					EDPONE(aX, "RU->CODRUB", EDCONT(aX) )
					SET ORDER TO 1
					IF FREPEAT( EDCONT(aX), aX[ED_MODAPP] )
						MENSAJE (0, 0, 10, .T.,"CODIGO REPETIDO !!! ")
						EDPONE( aX,, aX[ED_LAST] )
						aX[ED_TECLA] := 0
					ENDIF
					aX[ED_MODE] := "MOSTRARTODO"
				ELSEIF EDNOM(aX) $ "RU->HASTACOD"
					IF EDNOM(aX) == "RU->DESDECOD"
			EDPONE(AX,"RU->HASTACOD",EDCONT(AX,"RU->DESDECOD"))
	      ENDIF
		SELECT ART
	      SET ORDER TO 1
	      SEEK EDCONT(AX,"RU->DESDECOD")
	      r := .T.
	      DO WHILE ART->CODPROD>=EDCONT(AX,"RU->DESDECOD") .AND. ART->CODPROD<=EDCONT(AX,"RU->HASTACOD")
						IF ART->RUBRO # EDCONT(AX,"RU->RUBRO")
			r := .F.
		    EXIT
		 ENDIF
						SKIP
	      ENDDO
	      IF !r
						MENSAJE (0, 0, 10, .T.,"YA EXISTEN PRODUCTOS", "CON OTRO RUBRO EN", "ESTE RANGO DE CODIGOS !!!" )
		 EDPONE( AX, EDCONT(AX), AX[ED_LAST] )
	      ENDIF
	      SELECT RU
					aX[ED_MODE] := "MOSTRARTODO"
				ENDIF
			ELSEIF aX[ED_TECLA]==K_ESC .OR. ( aX[ED_TECLA]==K_ENTER .AND. aX[ED_I]==LEN(aX[ED_FIELDS]) ) .OR. aX[ED_TECLA] == K_F10
				aux := "S"
				IF aX[ED_TECLA] == K_F10
					FEDITOR( aX, "GRABAR", .F. )
					aux := "G"
				ELSE
					IF FEDITOR( aX, "HUBOCAMBIOS" )
						aux := FEDITOR( aX, "GRABAR", .T. )
					ENDIF
				ENDIF
				IF aux $ "GS"
					EXIT
				ENDIF
			ENDIF
		ENDDO
		FEDITOR( aX, "SACAPAN" )
		PONEPAN(xmenu2)
		TBPOS(OX,.T.)
		
	ELSEIF OX:Cargo[TB_RET] == K_ESC .OR. OX:Cargo[TB_RET] == K_ENTER
		EXIT
		
	ENDIF
ENDDO

IF LASTKEY() == K_ENTER
	xreg := RECNO()
ELSE
	GO xreg
	xreg := 0
ENDIF
DBSELECTAREA( xbase )
SETCOLOR( xcolor )
RECUPAN()
PONEPAN(xmenu)

RETURN xreg


*********************

FUNC FCOD( aX, xrub )

*********************
LOCAL r := 0

SET ORDER TO 1
IF FREPEAT( EDCONT(aX), aX[ED_MODAPP] )
	MENSAJE (0, 0, 10, .T.,"CODIGO REPETIDO !!! ")
	EDPONE( aX,, aX[ED_LAST] )
	aX[ED_TECLA] := 0
ENDIF

RETURN r
