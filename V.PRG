#include "INKEY.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "COMMON.CH"
#include "FILEIO.CH"

****************

FUNC FBASES( aa, lConMensaje )

****************
LOCAL bLastErr := ErrorBlock(), bErr, aaux:={}, i, x, _cerrar:=.T.
LOCAL lAbrieronTodos
lConMensaje := IF( lConMensaje==NIL, .T., lConMensaje )

IF lConMensaje == .T.
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
ENDIF
BEGIN SEQUENCE
 	bErr := ErrorBlock( { |eObj| eObj:Cargo:="ERROR", Break(eObj), .F. } )
  __abase[1,1] := __abase[1,1]
  RECOVER USING eObj
  IF eObj:Cargo == "ERROR"
  	PUBLIC __abase := {}
  ENDIF
END SEQUENCE
ErrorBlock(bLastErr)

AEVAL( aa, {|a,i| IF( LEFT(a,1)$" *-+",, aa[i]:=" "+a ), _cerrar:=IF(LEFT(a,1)$'+-',.F.,_cerrar) } )
AEVAL( __abase, {|a,i| AADD(aaux, IF( LEFT(a[1],1)=="*", .T., (!_cerrar) )) } )
*AEVAL( __abase, {|a,i| AADD(aaux,.T.) } )

FOR x=1 TO LEN( aa )
	i := ASCAN( __abase, {|a| SUBSTR(a[1],2)==SUBSTR(aa[x],2) } )
	IF i == 0
  	IF LEFT(aa[x],1) # "-"
			i := ascan(__abase,{|a,i|a[1]==""})
        if i == 0
 				AADD( __abase, ARRAY(2) )
				AADD( aaux, .T. )
           i := len(__abase)
        endif
			__abase[i,1] := aa[x]
        aaux[i] := .T.
     ENDIF
  ELSE
     IF LEFT(__abase[i,1],1) # "*"
     	__abase[i,1] := aa[x]
     ENDIF
     if left(aa[x],1)=="-"
     	aaux[i] := .F.
        _cerrar := .T.
     else
     	aaux[i] := .T.
     endif
  ENDIF
NEXT
FOR i=1 TO LEN(__abase)
	IF __abase[i,2] # NIL
		IF LEFT(__abase[i,1],1) == '-'
			DBSELECTAREA( __abase[i,2] )
     	DBCLOSEAREA()
     	aaux[i] := .F.
		ELSEIF _cerrar .AND. !aaux[i]
			DBSELECTAREA( __abase[i,2] )
     	DBCLOSEAREA()
     	aaux[i] := .F.
  	ENDIF
  ENDIF
NEXT
lAbrieronTodos := .F.
DO WHILE !lAbrieronTodos
	lAbrieronTodos := .T.
	FOR i=1 TO LEN(__abase)
		IF !empty(__abase[i,1]) .and. aaux[i] .and. __abase[i,2]==NIL
  		eval( bOPENBASES, i )
        IF DBF() # __abase[i,2]
				lAbrieronTodos := .F.
        ENDIF
  	ENDIF
	NEXT
ENDDO
i := ASCAN( aaux, .F. )
DO WHILE i != 0
	__abase[i,1] := ""
  __abase[i,2] := nil
  aaux[i] := .t.
	i := ASCAN( aaux, .F. )
ENDDO
do while __abase[len(__abase),2]==NIL
	asize( __abase, len(__abase)-1 )
enddo
IF lConMensaje == .T.
	RECUPAN()
ENDIF

RETURN NIL


*******************

FUNC FALIAS( cual, cualI )

*******************
DBSELECTAREA( cualI )
__abase[cualI,2] := cual

RETURN cualI


*******************

FUNC F_ABASE( aAlias, cModo )

*******************
LOCAL i, n, x, aa:={}, r:=.f.

if cModo=="CERRAR"
	for x=1 to len(aAlias)
 		n := ascan(__aBase,{|a,i|a[2]==aAlias[x]})
  	if n # 0
  		aadd(aa,"-"+substr(__aBase[n,1],2))
  	endif
	next x
	if len(aa) # 0
		FBASES(aa,.f.)
     r := .t.
	endif
elseif cModo=="?"
 	n := ascan(__aBase,{|a,i|a[2]==aAlias})
  r := (n>0)
endif

RETURN r


*******************

FUNC FREABRIR( aa )

*******************
LOCAL i, x, r := 0

FOR i=1 TO LEN(aa)
	x := ASCAN( __abase, {|a| SUBSTR(a[1],2) == aa[i] } )
  IF x # 0
  	eval( bOPENBASES, x )
     ++r
  ENDIF
NEXT

RETURN r


*************************

FUNC FMENU2( y1, x1, aa, opc, sep, acolor, bBlock )

*************************
LOCAL i:=0, _ancho, r, aq := {}, xcolor:=SETCOLOR()
LOCAL bx := { |x| x1 + IF(x==1,0,(x-1)*LEN(aa[1,1])+sep) }
sep := IF( sep==NIL, 5, sep )
acolor := IF( acolor==NIL, {"N/W","W/N"}, acolor )
bBlock := IF( bBlock==NIL, {||.F.}, bBlock )

SET(_SET_CURSOR,SC_OFF)

SETCOLOR(acolor[1])
*IF opc == NIL
	DISPBEGIN()
	_ancho := ( LEN(aa[1,1]) + sep ) * LEN(aa[1])
	*x1 := ( 79 - _ancho) / 2
	FOR x=1 TO LEN(aa[1])
		MARCO( y1, EVAL(bx,x), y1+LEN(aa)-1, EVAL(bx,x)+LEN(aa[1,1]), "", "        ", .F., 0 )
	NEXT
	FOR x=1 TO LEN(aa[1])
		FOR y=1 TO LEN(aa)
			AADD( aq, IF(EMPTY(aa[y,x]),0,++i) )
			@ y1+y-1, EVAL(bx,x) SAY aa[y,x]
  	NEXT
	NEXT
	DISPEND()
*	RETURN {}
*ELSE
*	FOR x=1 TO LEN(aa[1])
*		FOR y=1 TO LEN(aa)
*			AADD( aq, IF(EMPTY(aa[y,x]),0,++i) )
* 	NEXT
*	NEXT
*ENDIF

i := ASCAN( aq, opc )
i := IF( i==0, 1, i )
y := i - ( ( INT(i/LEN(aa)) + IF( MOD(i,LEN(aa))==0, 0, 1 ) -1 ) * LEN(aa) )
x := INT( i/LEN(aa) ) + IF( MOD(i,LEN(aa))==0, 0, 1 )

SETCOLOR(acolor[2])
@ y1+y-1, EVAL(bx,x) SAY aa[y,x]
DBUNLOCKALL()
DBCOMMITALL()
DO WHILE .T.
  K := INKEY(10)
	SETCOLOR(acolor[1])
	@ y1+y-1, EVAL(bx,x) SAY aa[y,x]
  IF EVAL(bBlock,K)
  	EXIT
  ELSEIF K == K_LEFT
  	--x
     IF x < 1
     	x := 1
     ENDIF
     FOR i=y TO LEN(aa)
     	IF !EMPTY(aa[i,x])
     		y := i
           EXIT
        ENDIF
     NEXT
     FOR i=y TO 1 STEP -1
     	IF !EMPTY(aa[i,x])
     		y := i
           EXIT
        ENDIF
     NEXT
  ELSEIF K == K_RIGHT
  	++x
     IF x>LEN(aa[y])
     	x := LEN(aa[y])
     ENDIF
     FOR i=y TO LEN(aa)
     	IF !EMPTY(aa[i,x])
     		y := i
           EXIT
        ENDIF
     NEXT
     FOR i=y TO 1 STEP -1
     	IF !EMPTY(aa[i,x])
     		y := i
           EXIT
        ENDIF
     NEXT
  ELSEIF K == K_UP
     FOR i=y-1 TO 1 STEP -1
     	IF !EMPTY(aa[i,x])
     		y := i
           EXIT
        ENDIF
     NEXT
  ELSEIF K == K_DOWN
     FOR i=y+1 TO LEN(aa)
     	IF !EMPTY(aa[i,x])
     		y := i
           EXIT
        ENDIF
     NEXT
  ELSEIF K == K_HOME
  	y := x := 1
     IF EMPTY(aa[y,x])
     	y := ASCAN( aa,{|a| ISALPHA(a[x]) } )
     ENDIF
  ELSEIF K == K_END
  	y := LEN(aa)
     x := LEN(aa[1])
     IF EMPTY(aa[y,x])
     	y := ASCAN( aa,{|a| ISALPHA(a[x]) }, LEN(aa), -LEN(aa) )
     ENDIF
  ELSEIF K == K_ENTER
  	EXIT
  ELSEIF K == 0
		DBUNLOCKALL()
		DBCOMMITALL()
  ELSE
     i  := y
     ii := x
  	FOR n=1 to 2
  		i := ASCAN( aa, {|a| UPPER(LEFT(LTRIM(a[ii]),1))==UPPER(CHR(K)) }, i+1 )
  		DO WHILE i == 0 .AND. ++ii <= LEN(aa[1])
  			i := ASCAN( aa, {|a| UPPER(LEFT(LTRIM(a[ii]),1))==UPPER(CHR(K)) }, i+1 )
     	ENDDO
        IF i == 0
        	IF n == 1
           	i  := 0
					ii := 1
           ENDIF
     	ELSE
     		y := i
        	x := ii
           EXIT
     	ENDIF
     NEXT
  ENDIF
	SETCOLOR(acolor[2])
	@ y1+y-1, EVAL(bx,x) SAY aa[y,x]
ENDDO
SETCOLOR(C_ELEGIDO1)
@ y1+y-1, EVAL(bx,x) SAY aa[y,x]
IF CHR(26) $ aa[y,x]
	@ y1+y-1, EVAL(bx,x)+AT(CHR(26),aa[y,x])-1 SAY REPLICATE("Ä",LEN(aa[y,x])-AT(CHR(26),aa[y,x]))+""
ENDIF
SETCOLOR(xcolor)

r := aa[y,x]
i := aq[  ( x - 1) * LEN(aa) + y  ]
x := EVAL(bx,x) + LEN(aa[y,x]) + 2
y := y1+y-1

RETURN { i, y, x, r, K }


**************

FUNC QUEFECHA( _y, _x, _fecha )

**************
LOCAL lastcolor:=SETCOLOR(C_GET), lastintensity:=SET(_SET_INTENSITY,.T.), r, lastbase:=dbf(), xmenu
_y = IF( PCOUNT()<1, ym2, _y )
_x = IF( PCOUNT()<2, xm2, _x )
_fecha := IF( _fecha=NIL, DATE(), _fecha )
r := _fecha

xmenu:=MENUDOWN({ "    TAB     º      ESC      º     ENTER     ",;
						 " visualiza  º    deja la    º               ",;
						 " calendario º fecha inicial º toma la fecha " })

FBASES( {"+FERIADOS"} )
MARCO( _y, _x, _y, _x+21, "", "S", .T., 0 )
SET CONFIRM ON
DO WHILE .T.
	READEXIT(.T.)
	SETCURSOR( 1 )
	SETCOLOR( C_GET )
	SET INTENSITY OFF
	SET KEY K_TAB TO CLEAR_GETS()
	@ _y, _x SAY "FECHA:" GET r
	READ
	SET KEY K_TAB TO
	SETCOLOR(C_GET)
	IF LASTKEY() == K_ENTER
		EXIT
	ELSEIF LASTKEY() == K_TAB
		r := FERIADOS( r )
	ELSEIF LASTKEY() == K_ESC
  	r := _fecha
		EXIT
	ENDIF
ENDDO
RECUPAN()
SET CONFIRM OFF
SETCOLOR( lastcolor )
SET(_SET_INTENSITY,lastintensity)
DBSELECTAREA(lastbase)
PONEPAN(xmenu)

RETURN ( r )


**************

FUNC QUEFECHA2

**************
PARAMETERS _y, _x
LOCAL lastcolor, lastintensity, i,xmenu
PRIVATE campo
_y = IF( PCOUNT()<1, ym2, _y )
_x = IF( PCOUNT()<2, xm2, _x )

xmenu:=MENUDOWN({ "     º    TAB     º      ESC      º     ENTER     ",;
						 "       º visualiza  º    deja la    º               ",;
						 " mueve º calendario º fecha inicial º toma la fecha " })
FBASES( {"+FERIADOS"} )
IF TYPE("DESDE") # "D"
	STORE DATE() TO DESDE, HASTA
ENDIF
lastcolor = SETCOLOR(C_GET)
lastintensity = SET(_SET_INTENSITY,.T.)
MARCO( _y, _x, _y+1, _x+23, "", "S", .T., 0 )
@ _y, _x  SAY "DESDE FECHA: " + DTOC(DESDE)
@ _y+1,_x SAY "HASTA FECHA: " + DTOC(HASTA)
SET CONFIRM ON
i = 1
DO WHILE .T.
	READEXIT(.T.)
	SETCURSOR( 1 )
	SETCOLOR(C_GET)
	SET INTENSITY OFF
	SET KEY 9 TO CLEAR_GETS()
	campo = IF( i==1, "DESDE", "HASTA" )
	@ _y+i-1, _x+14 GET &campo
	READ
	SET KEY 9 TO
	SETCOLOR(C_GET2)
	@ _y+i-1, _x+14 SAY &campo
	IF LASTKEY() == 24
		i = 2
	ELSEIF LASTKEY() == 5
		i = 1
	ELSEIF LASTKEY() == 13
		IF i == 2
			EXIT
		ELSE
			i = 2
		ENDIF
	ELSEIF LASTKEY() == 9
		&campo = FERIADOS(&campo)
	ELSEIF LASTKEY() == 27
		EXIT
	ENDIF
ENDDO
RECUPAN()
SET CONFIRM OFF
SETCOLOR( lastcolor )
SET(_SET_INTENSITY,lastintensity)
PONEPAN(xmenu)

RETURN ( LASTKEY()==13 )



************

FUNC VERBASES

************
LOCAL aaux:={}, op, op1, lastreg, i, x, lastbase, lastorder

SALVAPAN( 0, 0, 24, 79 )
lastbase = DBF()
lastreg = RECNO()
lastorder := INDEXORD()
FOR i=1 TO 99
	DBSELECTAREA(i)
  IF !EMPTY(DBF())
  	AADD( aaux, DBF() )
  ENDIF
NEXT
op = PP_SELEC( 1, 1, LEN(aaux), 0, aaux, ASCAN(aaux, lastbase), "", "S", .F. )
IF LASTKEY() == K_ENTER
	DBSELECTAREA(aaux[op])
	@ 0, 0 CLEAR TO 24, 79
	@0,0 SAY DBF()
	?? SELECT(), "³LASTREC()"+STR(LASTREC(),3), "RECNO()"+STR(RECNO(),3)
	aaux := {}
	FOR i=1 TO 7
		SET ORDER TO i
		IF EMPTY(INDEXKEY(i))
			EXIT
		ELSE
			AADD( aaux, INDEXKEY(i) )
			? i, INDEXKEY(i)
		ENDIF
	NEXT
	op1 = PP_SELEC( 1, 1, LEN(aaux), 0, aaux, INDEXORD(), "", "S", .F. )
	IF LASTKEY() == K_ENTER
		SET ORDER TO op1
		BROWSE()
	ENDIF
ENDIF
RECUPAN()
CLEARTYPEAHEAD()
DBSELECTAREA(lastbase)
SET ORDER TO lastorder
GO lastreg

RETURN .T.


***********

FUNC FAARCH( archivo, que, aa )

***********
LOCAL na, i, buffer, block, npos, bytes, _largo, r

archivo += IF("."$archivo,"",".SEQ" )
IF que == "CARGAR"
	PRIVATE aaux:={}
	block := 256
	npos := 0
	na = FOPEN(archivo)
	_largo := FSEEK(na,0,2)
	DO WHILE npos <= _largo
		FSEEK( na, npos )
		buffer := FREADSTR( na, block )
		x = AT( CHR(13)+CHR(10), buffer )
     IF x == 0
     	EXIT
     ENDIF
		AADD( aaux, LEFT( buffer, x-1 ) )
		npos += ( x+1 )
	ENDDO
	FCLOSE(na)
  r := ACLONE(aaux)
ELSEIF que == "GRABAR"
	buffer := ""
	AEVAL( aa, {|a| buffer+=a+CHR(13)+CHR(10)} )
	na = FCREATE(archivo,0)
  r := .F.
	IF FERROR() == 0
		FSEEK( na, 0 )
		block = LEN(buffer)
		bytes = FWRITE( na, buffer, block )
  	r := .T.
	ENDIF
	FCLOSE( na )
ENDIF

RETURN r


*********

FUNC FTOCI
* Compacta una __fecha en orden descendente
*********
PARAMETERS __fecha
PRIVATE aux

RETURN ( CHR(2099-YEAR(__fecha)) + CHR(12-MONTH(__fecha)) + CHR(31-DAY(__fecha)) )


*****************

FUNC FORDER( aa )

*****************
LOCAL r := INDEXORD(), i := 0, lr := .T., nPos, nPos2, x

DO WHILE !EMPTY( INDEXKEY(++i) )
  lr := .T.
	nPos := AT( aa[1], INDEXKEY(i) )
  IF LEN(aa) < 2
  	IF nPos == 0
     	lr := .F.
     ENDIF
  ELSE
  	FOR x=2 TO LEN(aa)
			nPos2 := AT( aa[x], INDEXKEY(i) )
			IF nPos2 > nPos .AND. nPos#0 .AND. nPos2#0
     		nPos := nPos2
     	ELSE
     		lr := .F.
     		EXIT
     	ENDIF
 		NEXT
  ENDIF
  IF lr
  	r := i
     EXIT
  ENDIF
ENDDO

RETURN r


*****************************

FUNC FREPEAT( cualcod, modo )

*****************************
LOCAL r, lastreg

r = .F.
lastreg = RECNO()
IF modo $ "APPEND AGREGAR"
	SEEK cualcod
	IF FOUND()
		r = .T.
	ENDIF
ELSEIF modo $ "EDIT MODIFICAR"
	SEEK cualcod
	DO WHILE FOUND()
		IF RECNO() # lastreg
			r = .T.
			EXIT
		ENDIF
		SKIP
	ENDDO
ENDIF
GO lastreg

RETURN r


*************

FUNC FERIADOS

*************
PARAMETERS cualfecha
LOCAL ym2:=10, xm2:=40, r, lastcolor, lastbase
DEFAULT cualfecha TO DATE()
cualfecha := IF( EMPTY(cualfecha), DATE(), cualfecha )

lastcolor = SETCOLOR(C_MENU)
PUBLIC L_[6]
L_[1] = REPLICATE( "Ä", 32 )
L_[2] = "   " + CHR(27) +" "+ CHR(26)+"   ùcambia de d¡a"
L_[3] = " PgUp PgDn ùcambia de mes      "
L_[4] = " Home End  ùcambia de a¤o      "
L_[5] = " F  ùpone y saca los feriados  "
L_[6] = " ENTER ùconfirma ³ ESC ùsale   "

xdia = DAY(cualfecha)
xmes = MONTH(cualfecha)
xanio = YEAR(cualfecha)
lastbase = DBF()
SELECT FE
MARCO( ym2, xm2, ym2+6, xm2+32, ALLTRIM(nomes[xmes]) + STR(xanio,5,0), "S", .T., LEN(L_) )
DO WHILE .T.
	
	MARCO( ym2, xm2, ym2+6, xm2+32, ALLTRIM(nomes[xmes]) + STR(xanio,5,0), "S", .F., LEN(L_) )
	FOR d = 1 TO 7
		@ ym2, xm2-1+d*4 SAY LEFT( nomsemana[d], 2 )
	NEXT d
	mesanio = "/"+ STR(xmes,2,0) +"/"+ STR(xanio-1900,2,0)
	pfm = CTOD( "01" + mesanio )
	udm = DIASXMES( xanio, xmes )
	STORE DOW( pfm ) TO px, ux
	STORE ym2+1 TO uy
	xdia = IF( xdia>udm, udm, xdia )
	
	FOR x = 1 TO udm
		IF ESFERIADO( CTOD(STR(x,2)+mesanio) )
			@ uy, (xm2-1+ux*4)-1 SAY "(  )"
		ENDIF
		@ uy, xm2-1+ux*4 SAY x PICT "99"
		ux = ux + 1
		IF ux > 7
			ux = 1
			uy = uy + 1
		ENDIF
	NEXT x
	ix = DOW( CTOD( STR(xdia,2,0) + mesanio ) )
	iy = ym2 + (( xdia + px - 2 ) / 7 ) + 1
	
	@ ym2+7, xm2 SAY "D¡as Transc.desde " + DTOC(cualfecha) +":"
	KEYBOARD " "
	DO WHILE .T.
		SETCURSOR( 0 )
		SET COLOR TO C_ELEGIDO
		@ ym2+7, xm2+27 SAY CTOD(STR(xdia,2)+mesanio) - cualfecha PICT "9999"
		K = INKEY(0)
		@ iy, xm2-1+ix*4 SAY xdia PICT "99"
		IF CHR(k) $ "Ff" .AND. DOW(CTOD(STR(xdia,2,0)+mesanio))#1      &&. F
			IF ESFERIADO( CTOD(STR(xdia,2)+mesanio) )
				@ iy, (xm2-1+ix*4)-1 SAY xdia PICT "    "
				FRLOCK()
				REPLACE FE->FERIADO WITH CTOD("")
			ELSE
				@ iy, (xm2-1+ix*4)-1 SAY xdia PICT "(  )"
				DBGOTOP()
				IF FE->FERIADO > ( DATE()-365*2 )
					ADD_REC()
				ENDIF
				FRLOCK()
				REPLACE FE->FERIADO WITH CTOD(STR(xdia,2,0)+mesanio)
			ENDIF
			UNLOCK
			SKIP 0
		ELSEIF LASTKEY() = -8
			EXIT
		ELSEIF k = 24                                &&. Baja
			xdia = xdia + 7
		ELSEIF k = 5                                 &&. Sube
			xdia = xdia - 7
		ELSEIF k = 4                                 &&. ->
			xdia = xdia + 1
		ELSEIF k = 19                                &&. <-
			xdia = xdia - 1
		ELSEIF K == 3                           		&&. PgUp
			xmes = xmes + 1
			IF xmes > 12
				xanio = xanio + 1
				xmes = 1
			ENDIF
			EXIT
		ELSEIF K == 6                           		&&. End
			xanio = xanio + 1
			EXIT
		ELSEIF K == 1                           		&&. Home
			xanio = xanio - 1
			EXIT
		ELSEIF K == 18                           		&&. PgDn
			xmes = xmes - 1
			IF xmes < 1
				xanio = xanio - 1
				xmes = 12
			ENDIF
			EXIT
		ELSEIF k = 13                                &&. ENTER
			EXIT
		ELSEIF k = 27                                &&. Esc
			EXIT
		ENDIF
		IF xdia >= udm
			xdia = udm
			iy = uy
		ELSEIF xdia < 1
			xdia = 1
			iy = ym2 + 1
		ENDIF
		iy = ym2 + (( xdia + px - 2 ) / 7 ) + 1
		ix = DOW( CTOD( STR(xdia,2,0) + mesanio ) )
		SETCOLOR("*"+C_ELEGIDO1)
		@ iy, xm2-1+ix*4 SAY xdia PICT "99" COLOR "*"+C_ELEGIDO1
		
	ENDDO
	IF LASTKEY()=27
		r = cualfecha
		EXIT
	ELSEIF LASTKEY()=13
		r = CTOD( STR(xdia,2,0) + mesanio )
		EXIT
	ENDIF
	
ENDDO
SETCOLOR(lastcolor)
DBSELECTAREA(lastbase)
RECUPAN()

RETURN r


**************

FUNC ESFERIADO

**************
PARAMETERS _fecha
LOCAL lastbase, r

IF DOW( _fecha ) == 1
	r = .T.
ELSE
	lastbase := DBF()
	SELECT FE
	SEEK DTOS( _fecha )
	r := FOUND()
	DBSELECTAREA(lastbase)
ENDIF

RETURN r


*************************************

FUNC MARCABRW( ym3, xm3, aa, length, xTecla, _titulo )

*************************************
LOCAL xmnu, ym33, aux, marcados, lastcolor:=SETCOLOR(C_MENU), ele
PRIVATE RELE:=0, Rrel:=0, modo :=''
PRIVATE bTecla := IF( xTecla==NIL, {|k|k==43.OR.k==45.OR.k==32}, xTecla )
DEFAULT _titulo TO ""
xmnu:=MENUDOWN({"     º   +   º    -     º ESPACIO  º  ENTER  º ESC  ",;
					  "PgUp/Dnº marca º desmarca º marca y  º         º      ",;
					  " mueve º todo  º   todo   º desmarca º procede º sale "})
lenght := IF( length==NIL, LEN(aa), length )
ym33 := IF( ym3+length>20, 20, ym3+length-1 )
aux := LEN(aa[1])-1
MARCO( ym3, xm3, ym33, xm3+LEN(aa[1]), _titulo, "S", .T. )
marcados := 0
AEVAL( aa, {|a| marcados+=IF(RIGHT(a,1)=="",1,0)} )
DO WHILE .T.
	@ ym33+1, xm3 SAY "marcados:"+STR(marcados,3)
	ele := ACHOICE(ym3, xm3, ym33, xm3+LEN(aa[1]), aa, .T., "achfunc", RELE, Rrel )
	IF modo==K_ENTER .OR. modo==K_ESC
		EXIT
	ELSEIF modo == 43
		AEVAL( aa, {|a,i| aa[i]:=LEFT(a,aux) + ""}, 1, length )
		marcados := length
	ELSEIF modo == 45
		AEVAL( aa, {|a,i| aa[i]:=LEFT(a,aux) + " "}, 1, length )
		marcados := 0
	ELSEIF modo == K_SPACE
		IF RIGHT(aa[ele],1)==""
			aa[ele] = LEFT(aa[ele],aux) + " "
			--marcados
		ELSE
			aa[ele] = LEFT(aa[ele],aux) + ""
			++marcados
		ENDIF
     KEYBOARD CHR(K_DOWN)
	ENDIF
ENDDO
RECUPAN()
IF LASTKEY()#K_ENTER .OR. marcados == 0
	marcados := 0
ENDIF
PONEPAN(xmnu)
SETCOLOR(lastcolor)

RETURN marcados

****************

FUNCTION achfunc

****************
PARAMETERS amod, sel, rel
LOCAL srow:=ROW(), scol:=COL(), csel, crel, lastcolor
PRIVATE k, r

r    := 2
modo := 0
IF amod == 3
	k := LASTKEY()
	DO CASE
		
	CASE EVAL(bTecla,k)
		modo := K
		r = 1
		
	CASE k == K_ESC
		modo := k
		r = 0
		
	CASE k == K_ENTER
		modo := k
		r = 1
		
	CASE k == K_HOME
		modo := k
		KEYBOARD CHR(31)
		
	CASE k == K_END
		modo := k
		KEYBOARD CHR(30)
		
	OTHERWISE
		r = 3
		
	ENDCASE
ENDIF

RREL := rel
RELE := sel

RETURN r


***************

FUNC ATOS( aa, _delimitador )

***************
LOCAL i, aux:="{"
_delimitador := IF( _delimitador==NIL, CHR(13)+CHR(10), _delimitador )
aux:="{"+_delimitador

FOR i=1 TO LEN(aa)
	IF VALTYPE(aa[i]) == "N"
		aux += ALLTRIM(STR(aa[i]))
	ELSEIF VALTYPE(aa[i]) == "C"
		aux += CHR(34)+ aa[i] +CHR(34)
	ELSEIF VALTYPE(aa[i]) == "D"
		aux += "CTOD("+ CHR(34)+DTOC(aa[i])+CHR(34) +")"
	ELSEIF VALTYPE(aa[i]) == "B"
		aux += "{||"+ aa[i] +"}"
	ELSEIF VALTYPE(aa[i]) == "A"
		aux += ATOS( aa[i], _delimitador )
	ENDIF
	aux += _delimitador + IF( i==LEN(aa), "}", "" )
NEXT

RETURN aux


*****************

FUNC STOA( ss, _delimitador )

*****************
LOCAL aa:={}, npos:=0
STATIC _veces:=0
PRIVATE buffer
_delimitador := IF( _delimitador==NIL, CHR(13)+CHR(10), _delimitador )

DO WHILE .T.
	npos = AT( _delimitador, ss )
  IF npos == 0
  	buffer := ALLTRIM(ss)
     npos := 1
  ELSE
		buffer := ALLTRIM(LEFT( ss, npos-1 ))
		npos += 2
  ENDIF
  ss := SUBSTR( ss, npos )
  IF buffer == "{"
  	IF _veces # 0
  		AADD( aa, STOA( @ss, _delimitador ) )
     ENDIF
		++_veces
  ELSEIF buffer == "}" .OR. buffer==''
  	EXIT
  ELSE
  	AADD( aa, &buffer )
  ENDIF
ENDDO
_veces := 0

RETURN aa


***************

FUNC FLEN(_que)

***************
IF VALTYPE(_que)=="N"
	RETURN LEN(STR(_que))
ELSEIF VALTYPE(_que)=="D"
	RETURN 8
ELSEIF VALTYPE(_que)=="L"
	RETURN 1
ELSE
	RETURN LEN(_que)
ENDIF


********************

FUNC VOLUMEN(cDisco)

********************
LOCAL aDir, r := ""
DEFAULT cDisco TO ""

aDir:=DIRECTORY( ALLTRIM(cDisco)+"\", "V" )
IF LEN(aDir) # 0
	r := aDir[1,1]
ENDIF

RETURN( r )


************************

FUNC DISCOESTA( cDrive, lConMnsaje )

************************
LOCAL bLastErr:=ErrorBlock(), bErr, r:=.T.
LOCAL nDrive := ASC(UPPER(cDrive))-64

MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
BEGIN SEQUENCE
 	bErr := ErrorBlock( { |eObj| eObj:Cargo:="ERROR", Break(eObj), .F. } )
  nAux := DISKSPACE(nDrive)
  RECOVER USING eObj
  IF eObj:Cargo == "ERROR"
  	r := .F.
  ENDIF
END SEQUENCE
ErrorBlock(bLastErr)
RECUPAN()

RETURN r


***********************

FUNC ADEJAR( aaux, aCual )

***********************
LOCAL i, aa:={}

FOR x=1 TO LEN(aaux)
	i := ASCAN( aCual, aaux[x,1] )
  IF i # 0
  	AADD( aa, aaux[x] )
  ENDIF
NEXT

RETURN aa


****************

FUNC TERMINOBIEN

****************
LOCAL aaux, r:=""

aaux := DIRECTORY("INI*.MAL")
IF LEN(aaux) # 0
	FOR i=1 TO LEN(aaux)
  	na := FOPEN( aaux[i,1], FO_READ + FO_EXCLUSIVE )
     IF FERROR() == 0
     	r += ", "+SUBSTR(aaux[i,1],4,2)
			FCLOSE( na )
			na := FERASE( aaux[i] )
     ELSE
			na := FCLOSE( na )
     ENDIF
  NEXT
ENDIF

RETURN( SUBSTR(r,3) )


***********************

FUNC SEMAFORO( _como )

***********************
cMalArch := "INI"+STRZERO(_NPUESTO_,2)+".MAL"
PUBLIC nSemaforo

IF _como == "ON"
	DO WHILE .T.
		IF !FILE( cMalArch )
			nSemaforo := FCREATE( cMalArch, FC_NORMAL )
        FCLOSE( nSemaforo )
		ENDIF
		nSemaforo := FOPEN( cMalArch, FO_WRITE+FO_EXCLUSIVE )
     IF FERROR() == 0
     	EXIT
     ENDIF
  ENDDO
ELSEIF _como == "OFF"
	FCLOSE( nSemaforo )
  IF FILE( cMalArch )
		na := FERASE( cMalArch )
  ENDIF
  nSemaforo := -1
ENDIF

RETURN( nSemaforo )


*************************

FUNC MAADD( aCual, aQue )

*************************
LOCAL i

FOR i=1 TO LEN(aQue)
	AADD( aCual, aQue[i] )
NEXT

RETURN aCual


****************

FUNC ABRIRBASE2

****************
PARAMETERS cBase, cAliasBase, aIndice, lReindexar, lShared, nVeces
LOCAL lastcolor, nn:=0, nAux, nMax, i, cPath:="", cBase2:=cBase
if "\" $ cBase
	cPath  := left( cBase, rat("\",cBase) )
	cBase2 := substr( cBase, len(cPath)+1 )
endif

DEFAULT lReindexar TO .F.
DEFAULT lShared TO .T.
DEFAULT nVeces TO 5
IF aIndice == NIL
	aIndice := {}
ENDIF

DO WHILE nVeces-- > 0
 	DBUSEAREA(,,cBase, cAliasBase, lShared )
	IF !NETERR()
  	IF !EMPTY(DBF())
			EXIT
     ENDIF
	ENDIF
ENDDO
IF NETERR() .OR. EMPTY(DBF())
	RETURN .F.
ENDIF

FFLOCK()
FOR nI=1 TO LEN(aIndice)
	IF LEN(aIndice[nI]) < 2			// agrega "" al nombre del indice
 		AADD(aIndice[nI],"")
  ENDIF
	IF LEN(aIndice[nI]) < 3			// agrega UNIQUE OFF por defecto
 		AADD(aIndice[nI],.F.)
  ENDIF
	if empty(aIndice[nI,2])
		aIndice[nI,2] := cBase
     if nI > 1
			aIndice[nI,2] := left(cBase,len(cBase)-1)+str(nI,1)
     endif
  endif
 	aIndice[nI,2] := strtran( aIndice[nI,2], ".DBF", INDEXEXT() )
 	aIndice[nI,2] := aIndice[nI,2] + IF( "."$RIGHT(aIndice[nI,2],4), "", INDEXEXT() )
	IF !FILE(aIndice[nI,2]) .OR. lReindexar
		MARCO( 22, 20, 22, 20+40, "Indexando .."+RIGHT(cBase,12), "S", .T. )
		@ 22,20 SAY REPLICATE( "Û", 40 )
		por_donde = 0
		SET UNIQUE OFF
     IF LEN(aIndice[nI]) > 2
     	IF aIndice[nI,3]
				SET UNIQUE ON
        ENDIF
     ENDIF
     IF LASTREC() < 40
     	nAux := LASTREC()
     	nMas := 40/nAux
     ELSE
     	nAux := INT(LASTREC()/40)
     	nAux := lastrec()/nAux
     	nMas := 40/nAux
     ENDIF
		INDEX ON &(aIndice[nI,1]) TO (aIndice[nI,2]) EVAL {||DEVPOS(22,20),DEVOUT(REPLICATE("°",por_donde)),por_donde+=nMas,.T.} EVERY LASTREC()/40
		@ 22,20 SAY REPLICATE( "°", 40 )
		RECUPAN()
  ENDIF
NEXT
SET INDEX TO
FOR nI=1 TO LEN(aIndice)
	DBSETINDEX( aIndice[nI,2] )
NEXT
DBUNLOCK()
DBCOMMIT()
SELECT (cAliasBase)

RETURN .T.

**************************

INIT PROCEDURE _CONFIGURAR

**************************
LOCAL cArch:=IF(ISCOLOR(),"COLOR","MONO")+".MEM"

PUBLIC C_FONDO1  :="W+/N", C_FONDO2  :="N/W",  C_FONDO3  :="", C_FONDO4  :="", C_FONDO5  :="W/N" ,;
       C_MENU1   :="N/W",  C_MENU2   :="+W/N", C_MENU3   :="", C_MENU4   :="", C_MENU5   :="W+/N",;
		  C_MENUDN1 :="N/W",  C_MENUDN2 :="W/N",  C_MENUDN3 :="", C_MENUDN4 :="", C_MENUDN5 :="W+/N",;
		  C_ELEGIDO1:="W+/N", C_ELEGIDO2:="N/W",  C_ELEGIDO3:="", C_ELEGIDO4:="", C_ELEGIDO5:="W+/N",;
		  C_MENSAJE1:="N*+/W",C_MENSAJE2:="N+/W", C_MENSAJE3:="", C_MENSAJE4:="", C_MENSAJE5:="N+/W",;
		  C_GET1    :="W+/N", C_GET2    :="N/W",  C_GET3    :="", C_GET4    :="", C_GET5    :="W+/N"

PUBLIC  C_FONDO   := C_FONDO1  +','+ C_FONDO2  +','+ C_FONDO3  +','+ C_FONDO4  +','+ C_FONDO5,;
        C_MENU    := C_MENU1   +','+ C_MENU2   +','+ C_MENU3   +','+ C_MENU4   +','+ C_MENU5,;
        C_MENUDN  := C_MENUDN1 +','+ C_MENUDN2 +','+ C_MENUDN3 +','+ C_MENUDN4 +','+ C_MENUDN5,;
        C_ELEGIDO := C_ELEGIDO1+','+ C_ELEGIDO2+','+ C_ELEGIDO3+','+ C_ELEGIDO4+','+ C_ELEGIDO5,;
     	C_MENSAJE := C_MENSAJE1+','+ C_MENSAJE2+','+ C_MENSAJE3+','+ C_MENSAJE4+','+ C_MENSAJE5,;
     	C_GET     := C_GET1    +','+ C_GET2    +','+ C_GET3    +','+ C_GET4    +','+ C_GET5

if file(cArch)
	RESTORE FROM (cArch) ADDITIVE
endif

PUBLIC nomes[12]
nomes[ 1] = "ENERO    "
nomes[ 2] = "FEBRERO  "
nomes[ 3] = "MARZO    "
nomes[ 4] = "ABRIL    "
nomes[ 5] = "MAYO     "
nomes[ 6] = "JUNIO    "
nomes[ 7] = "JULIO    "
nomes[ 8] = "AGOSTO   "
nomes[ 9] = "SETIEMBRE"
nomes[10] = "OCTUBRE  "
nomes[11] = "NOVIEMBRE"
nomes[12] = "DICIEMBRE"

PUBLIC nomsemana[7]
nomsemana[ 1] = "Domingo  "
nomsemana[ 2] = "Lunes    "
nomsemana[ 3] = "Martes   "
nomsemana[ 4] = "Miercoles"
nomsemana[ 5] = "Jueves   "
nomsemana[ 6] = "Viernes  "
nomsemana[ 7] = "Sabado   "

PUBLIC UNI[29], DEC[9], CENT[9]
UNI[1] = "UN"
UNI[2] = "DOS"
UNI[3] = "TRES"
UNI[4] = "CUATRO"
UNI[5] = "CINCO"
UNI[6] = "SEIS"
UNI[7] = "SIETE"
UNI[8] = "OCHO"
UNI[9] = "NUEVE"
UNI[10] = "DIEZ"
UNI[11] = "ONCE"
UNI[12] = "DOCE"
UNI[13] = "TRECE"
UNI[14] = "CATORCE"
UNI[15] = "QUINCE"
UNI[16] = "DIECISEIS"
UNI[17] = "DIECISIETE"
UNI[18] = "DIECIOCHO"
UNI[19] = "DIECINUEVE"
UNI[20] = "VEINTE"
UNI[21] = "VEINTIUN"
UNI[22] = "VEINTIDOS"
UNI[23] = "VEINTITRES"
UNI[24] = "VEINTICUATRO"
UNI[25] = "VEINTICINCO"
UNI[26] = "VEINTISEIS"
UNI[27] = "VEINTISIETE"
UNI[28] = "VEINTIOCHO"
UNI[29] = "VEINTINUEVE"

DEC[3] = "TREINTA"
DEC[4] = "CUARENTA"
DEC[5] = "CINCUENTA"
DEC[6] = "SESENTA"
DEC[7] = "SETENTA"
DEC[8] = "OCHENTA"
DEC[9] = "NOVENTA"

CENT[1] = "CIENTO"
CENT[2] = "DOSCIENTOS"
CENT[3] = "TRESCIENTOS"
CENT[4] = "CUATROCIENTOS"
CENT[5] = "QUINIENTOS"
CENT[6] = "SEISCIENTOS"
CENT[7] = "SETECIENTOS"
CENT[8] = "OCHOCIENTOS"
CENT[9] = "NOVECIENTOS"

PUBLIC aSexo:={"FÄFemenino","MÄMasculino"}
PUBLIC aTipoDoc:={"DNI","LC ","LE ","CI "}
PUBLIC aNacion:={"AÄArgentino","EÄExtranjero"}
PUBLIC aEstCiv:={"SÄSoltero","CÄCasado","VÄViudo","DÄDivorciado"}

PUBLIC aRosca := {"|","/","-","\"}, nRosca:=1, _ID:=0
PUBLIC bOPENBASES:={|b| BASES_SISTEMA(b)}

RETURN


***************

FUNC CFGCOLOR()

***************
LOCAL cArch:=IF(ISCOLOR(),"COLOR","MONO")+".MEM", cMenu, aColor, aAtrib, lAux
LOCAL aa:={"C_FONDO","C_MENU","C_MENUDN","C_ELEGIDO","C_MENSAJE","C_GET"}
PRIVATE cAux, cAux2

#define y1       10
#define x1       10
#define yy       7
cMenu:=MENUDOWN({"     º presione TAB º  ESC   ",;
						"       º para ver las º        ",;
						" mueve º opciones.    º  sale  "})
if file(cArch)
	RESTORE FROM (cArch) ADDITIVE
endif

aColor := {"Negro               N  ",;
			   "Azul                B  ",;
           "Verde               G  ",;
           "Celeste             BG ",;
           "Rojo                R  ",;
           "Magenta             RB ",;
           "Marr¢n              GR ",;
           "Blanco              W  ",;
           "Gris                N+ ",;
           "Azul Brilloso       B+ ",;
           "Marr¢n Brilloso     G+ ",;
           "Celeste Brilloso    BG+",;
           "Rojo Brilloso       R+ ",;
           "Magenta Brilloso    RB+",;
           "Amarillo Brilloso   GR+",;
           "Blanco Brilloso     W+ " }
aAtrib := {{"Subrayado","Inverso","Intermitente"},{"U","I","*"}}

SETCOLOR(C_GET)
MARCO( y1, x1, y1+LEN(aa), 60, "", "S", .T., 0 )
aG:=ARRAY(LEN(aa)*5)
i:=0
for x=1 to 5
	@ y1,x1+10+x*yy+3 SAY x pict "9"
next
FOR y=1 TO LEN(aa)
	@ y1+y,x1 SAY aa[y]
  for x=1 to 5
  	cAux := aa[y]+str(x,1)
  	aG[++i] := PADR(&cAux,yy,' ')
  NEXT
NEXT

lAux := .F.
SETCURSOR(_SET_CURSOR,SC_ON)
DO WHILE .T.
	SET KEY K_TAB TO CLEAR_GETS()
	SET KEY K_F10 TO CLEAR_GETS()
	i:=0
	FOR y=1 TO LEN(aa)
  	for x=1 to 5
			@ y1+y, x1+10+x*yy GET aG[++i] PICT "!!!!!!"
  	NEXT
	NEXT
	READ
  if !lAux;  lAux:=UPDATED();  ENDIF
	SET KEY K_TAB TO
	SET KEY K_F10 TO
	IF LASTKEY() == K_TAB
		i = PP_SELEC(10, 20, i, 0, aColor, 1, "COLORES", "S", .T.)
  	RECUPAN()
	ELSEIF LASTKEY() == K_F10
		cAux := "G"
		EXIT
	ELSEIF LASTKEY() == K_ESC
  	IF lAux
			cAux := UPPER(PREGUNTA( 10, " [ G ] graba     [ S ] sale     [ C ] contin£a ","GgSsCc"))
  		IF cAux $ "GS"
				EXIT
  		ENDIF
     ELSE
  		cAux := "S"
     	EXIT
     ENDIF
	ENDIF
ENDDO
RECUPAN()
MENUDOWN(cMenu)
if cAux == "G"
	i := 0
	for y=1 TO LEN(aa)
  	cAux2 := aa[y]
     &cAux2 := ""
  	for x=1 to 5
  		cAux  := aa[y]+str(x,1)
  		&cAux := alltrim(aG[++i])
        &cAux2 += ','+ &cAux
  	next
     &cAux2 := SUBSTR(&cAux2,2)
	next
	SAVE ALL LIKE C_* TO (cArch)
endif

RETURN NIL

************************************************

FUNC ULTIMO( cCualBase, xCualCampo, nCualOrder )

************************************************
LOCAL nReg, cBase:=DBF(), r, nOrder:=INDEXORD()
DEFAULT cCualBase TO DBF()

SELECT (cCualBase)
nReg=RECNO()
if nCualOrder # nil
	set order to nCualOrder
endif
DBGOBOTTOM()
r := &(xCualCampo)
GO nReg
set order to nOrder
SELECT (cBase)

RETURN r


***********

func F_ID()

***********
local r, cAux, x

if ++_ID>99999;  _ID:=0;  endif
cAux:=  ' '+dtos(date()) + strzero(seconds(),5) +strzero(_ID,5)
r := ''
for x=1 to 9
	r += chr(32+val(substr(cAux,x*2,2)))
next

return r


*********************************

func aReplace( cAlias1, cAlias2 )

*********************************
local aa1:=(cAlias1)->(dbstruct()), aa2:=(cAlias2)->(dbstruct()), aa:={}

for i=1 to len(aa1)
	n := ascan( aa2, {|a| a[1]==aa1[i,1] })
  if n#0
  	aadd(aa,aa2[n,1])
  endif
next

return aa

********************

FUNC FMARCA( nK, cContador, bCond, bBlock )

********************
local nReg:=recno(), lRecontar:=.F., nAux:=0, cAlias, nMas:=1
if cContador # nil
	nAux := &(cContador)
endif
DEFAULT bCond TO {||.T.}
DEFAULT bBlock TO {||.T.}

if nK == 32
  FRLOCK()
  if FIELD->MARCA # ' '
		FIELD->MARCA := ''
     --nAux
  	eval(bBlock,-1)
  else
		FIELD->MARCA := ''
  	eval(bBlock,1)
     ++nAux
  endif
  DBUNLOCK()
elseif nK == 43		// +
	MENSAJE( 99, 99, 0, .F., "MARCANDO..." )
  FFLOCK()
  do while ROSCA().and.eval(bCond).and.!eof()
  	if FIELD->MARCA == ' '
			FIELD->MARCA := ''
     	eval(bBlock,1)
     	@ 24,70 say ++nAux pict "999999"
     endif
     SKIP
  enddo
  DBUNLOCK()
  RECUPAN()
elseif nK == 45		// -
	MENSAJE( 99, 99, 0, .F., "DESMARCANDO..." )
  nMas := -1
  FFLOCK()
  do while ROSCA().and.eval(bCond).and.!eof()
  	if FIELD->MARCA # ' '
			FIELD->MARCA := ''
     	eval(bBlock,-1)
     	@ 24,70 say --nAux pict "999999"
     endif
     SKIP
  enddo
  DBUNLOCK()
  RECUPAN()
elseif nK == K_F9
	lRecontar := .T.
endif
if lRecontar .or. nAux<0
	MENSAJE( 99, 99, 0, .F., "CONTANDO..." )
*	count for ROSCA().and.eval(bCond).and.FIELD->MARCA#' ' to nAux
	nAux:=0
  dbeval( {||++nAux,eval(bBlock,1)},;
				{||ROSCA().and.eval(bCond).and.FIELD->MARCA#' '} )
  RECUPAN()
endif
GO nReg
if cContador # nil
	cAlias := left(cContador,at('->',cContador)-1)
  if cAlias=="M";  cAlias:="";  endif
  if !empty(cAlias);  FRLOCK(cAlias);  endif
	&(cContador) := nAux
  if !empty(cAlias);  (cAlias)->(DBUNLOCK());  endif
endif

return nAux
