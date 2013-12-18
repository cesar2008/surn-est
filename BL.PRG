#include "BL.CH"
#include "INKEY.CH"
#include "SETCURS.CH"


PARAMETERS _y, _x
LOCAL r, y:=_y, x:=_x
PRIVATE aux

MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
IF !FILE("_BL.DBF")
	CREARBASE( "_BL", "ORDEN N 2", "NOMBL C 30", "CODBL C 5", "COPIAS N 3", "LADOS N 2", "COND C 50" )
ENDIF
IF !FILE("_BL2.DBF")
	CREARBASE( "_BL2", "NUMBL N 3", "POSY N 3", "POSX N 3", "TIPOLETRA N 1", "PASADAS N 2", "DESC C 25", "MACRO C 99", "LADO N 1", "IMPRIMIR C 1", "COND C 3" )
ENDIF
FBASES({ "+_BL", "+_BL2" } )

DO CARGAVEC WITH "LETRA", 11

RECUPAN()

pantaux := GUARDOPAN( 0, 0, 24, 79 )
DO WHILE .T.

	MENUDOWN({"  <+>  º F3 busca  º    F2    º   F5   º   F6    º   F10    º   ENTER    ºESC ",;
	          "       º           º modifica º        º         º modifica º            º    ",;
	          " mueve º F4 busca+ º  nombre  º agrega º elimina º  boleta  º selecciona ºsale"} )

	SETCOLOR("W/N,N/W")

	PRIVATE bcamp[2], bmasc[2], bcab[2], bedit
	bcamp[ 1] = "_BL->ORDEN"
	bcamp[ 2] = "_BL->NOMBL"
	bmasc[ 1] = "99"
	bmasc[ 2] = "@!"
	bcab[ 1] = "Orden"
	bcab[ 2] = "Boleta"
	bedit = "EE"

	SELECT _BL
	BROW( y, x, 20, x+35, "", bcamp, bmasc, bcab, bedit, "REEBL(tecla,cur_field)", "tecla=-4.OR.tecla=-5.OR.tecla=-1.OR.tecla=-6.OR.tecla=-9" )

	IF LASTKEY() == -9
		MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
     SELECT 99
		DBCLOSEAREA()
		aux = XNAME("XAUX")
		CREARBASE( aux, "POSY N 3", "POSX N 3", "TIPOLETRA N 1", "PASADAS N 2", "DESC C 25", "MACRO C 99", "LADO N 1", "IMPRIMIR C 1", "COND C 3", "REGISTRO N 6" )
		USE &aux ALIAS XBL EXCLUSIVE
		INDEX ON STR(XBL->LADO)+STR(XBL->POSY)+STR(XBL->POSX) TO &aux
     SELECT XBL
     ZAP
     AFIELDS( aaux:=ARRAY(FCOUNT()-1) )
     SELECT _BL2
     SET SOFTSEEK ON
     SEEK STR(_BL->(RECNO()),3)
     SELECT XBL
     DO WHILE _BL2->NUMBL == _BL->(RECNO())
     	APPEND BLANK
			AEVAL( aaux, {|a,i| XBL->&(a):=_BL2->&(a)} )
        XBL->REGISTRO = _BL2->(RECNO())
     	SKIP 1 ALIAS _BL2
     ENDDO
     SET SOFTSEEK OFF
     IF LASTREC() == 0
     	APPEND BLANK
     ENDIF
     RECUPAN()

		MENUDOWN({"  <+>  º F3 busca  º  F2   º   F5   º  F6  º   F8   º     F9     º  TAB  º ESC  ",;
		          "       º           º modi- º        º eli- º dupli- º   repite   º tipos º      ",;
		          " mueve º F4 busca+ º fica  º agrega º mina º   ca   ºhacia abajo º letra º sale "} )

  	SETCOLOR( "+W/N,N/W")
		PRIVATE bcamp[9], bmasc[9], bcab[9], bedit
		bcamp[ 1] = "XBL->POSY"
		bcamp[ 2] = "XBL->POSX"
		bcamp[ 3] = "XBL->TIPOLETRA"
		bcamp[ 4] = "XBL->PASADAS"
		bcamp[ 5] = "XBL->DESC"
		bcamp[ 6] = "XBL->LADO"
		bcamp[ 7] = "XBL->IMPRIMIR"
		bcamp[ 8] = "XBL->COND"
		bcamp[ 9] = "XBL->MACRO"
		bmasc[ 1] = "999"
		bmasc[ 2] = "999"
		bmasc[ 3] = "9"
		bmasc[ 4] = "99"
		bmasc[ 5] = REPLICATE("X",LEN(XBL->DESC))
		bmasc[ 6] = "9"
		bmasc[ 7] = "!"
		bmasc[ 8] = ""
		bmasc[ 9] = "@S40"
		bcab[ 1] = "Y;mm"
		bcab[ 2] = "X;mm"
		bcab[ 3] = "Tipo;Letra"
		bcab[ 4] = "Pasa;das"
		bcab[ 5] = "Descripci¢n"
		bcab[ 6] = "Lado"
		bcab[ 7] = "Impr"
		bcab[ 8] = "Con;dic"
		bcab[ 9] = "Macro"
		bedit = "MMMMEMMME"

		SELECT XBL
     GO TOP
***		BROW( 5, 1, 20, 78, ALLTRIM(_BL->NOMBL), bcamp, bmasc, bcab, bedit, "REEBL(tecla,cur_field)", "tecla=-4.OR.tecla=-5.OR.tecla=-1.OR.tecla=9.OR.tecla=13.OR.tecla==-7.OR.tecla=-8" )
     * * *
		MARCO( 5, 1, 19, 78, ALLTRIM(_BL->NOMBL), "D", .T., 0 )
 		lastcolor := SETCOLOR()
		STORE "" TO buscar
		i = 1
		READEXIT(.T.)
		CLEARTYPEAHEAD()
		SET CONFIRM ON
     grabar = .F.
     DO WHILE .T.
			DBEDIT( 5, 1, 19, 78, bcamp, "XBOL", bmasc, bcab, "ÑÍ", "³" )
	 		SETCOLOR( lastcolor )
			aux = PREGUNTA( 0, "¨ [ G ] graba        [ M ] modificar        [ S ] sale ?", "GgMmSs" )
        IF aux $ "Gg"
        	grabar = .T.
           EXIT
        ELSEIF aux $ "Ss"
        	grabar = .F.
           exit
        ENDIF
     ENDDO
     	* * *
		IF grabar
			MENSAJE( 0, 0, 0, .F., "GRABANDO..." )
     	SELECT XBL
        SET DELETED OFF
        GO TOP
     	AFIELDS( aaux:=ARRAY(FCOUNT()-1) )
        SELECT _BL2
        DO WHILE !XBL->(EOF())
        	IF XBL->(DELETED())
        		IF XBL->REGISTRO # 0
              	GO XBL->REGISTRO
                 BLANKREG()
              ENDIF
           ELSE
        		IF XBL->REGISTRO == 0
        			GO TOP
           		IF _BL2->NUMBL#0 .OR. LASTREC() == 0
           			ADD_REC()
           		ENDIF
                 FRLOCK()
        			_BL2->NUMBL := _BL->(RECNO())
        		ELSE
        			GO XBL->REGISTRO
        		ENDIF
           	FRLOCK()
					AEVAL( aaux, {|a,i| IF(_BL2->&(a)#XBL->&(a), _BL2->&(a):=XBL->&(a), NIL)} )
           ENDIF
     		SKIP 1 ALIAS XBL
     	ENDDO
        SET DELETED ON
        DBCOMMITALL()
        DBUNLOCKALL()
        RECUPAN()
     ENDIF
		RECUPAN()

	ELSEIF LASTKEY() == 13
  	r = _BL->(RECNO())
		EXIT
	ELSEIF LASTKEY() == 27
  	r = 0
		EXIT
	ENDIF

ENDDO
PONEPAN( pantaux )

RETURN r


******************************

FUNC REEBL( tecla, cur_field )

******************************
LOCAL r:=1

IF DBF() == "_BL"
	IF tecla == -1 .OR. tecla == -4
		SETCOLOR("N/W")
		MARCO( 12, 12, 17, 70, "", "S", .T., 0 )
		PRIVATE aaux := { "ORDEN", "NOMBL", "CODBL", "LADOS", "COPIAS", "COND" }
		AEVAL(aaux, {|a| M->&(a):=_BL->&(a)} )
		IF tecla == -4
     	DBGOBOTTOM()
        M->ORDEN := _BL->ORDEN + 1
			KEYBOARD ''+CHR(13)+''+CHR(13)+''+CHR(13)+''+CHR(13)+CHR(13)
		ENDIF
		SET( _SET_CURSOR, 1 )
		SETCOLOR("N/W,W/N,,,N/W")
		DO WHILE .T.
			@ 12, 15 SAY "      N§ Orden:" GET M->ORDEN PICT "999" VALID !FREPEAT(M->&(aaux[1]),IF(tecla==-1,"EDIT","APPEND"))
			@ 13, 15 SAY "Nombre Listado:" GET M->NOMBL
			@ 14, 15 SAY "C¢digo Listado:" GET M->CODBL PICT "@!"
			@ 15, 15 SAY "Lados x boleta:" GET M->LADOS PICT "99"
			@ 16, 15 SAY "Cant.de copias:" GET M->COPIAS PICT "999"
			@ 17, 15 SAY "     Condici¢n:" GET M->COND PICT "@S40"
			READ
			IF LASTKEY() == K_TAB
				op = PP_SELEC( 14, 20, LEN(aBol), 0, aBol, M->CODBL, "BOLETAS", "S", .T. )
           IF LASTKEY() == 13
           	M->CODBL = aBol[op]
           ENDIF
           RECUPAN()
			ELSEIF LASTKEY() == K_ESC
           M->COND := IF(EMPTY(M->COND), ".T.", M->COND)
				IF tecla == -1
					r = .F.
					AEVAL( aaux, {|a| r:=IF(M->&(a)#_BL->&(a),.T.,r) } )
				ELSE
					r = .T.
				ENDIF
				IF r
					IF PREGUNTA( 0, "GRABO LOS CAMBIOS  [ S / N ] ", "SsNn", "Ss" ) $ "Ss"
						IF M->ORDEN == 0 .OR. EMPTY(M->NOMBL)
							MENSAJE( 0, 0, 10, .T., " DATOS INCOMPLETOS !!!" )
							LOOP
						ENDIF
						IF tecla == -4
							SET( _SET_DELETED, .F. )
							SEEK 0
							IF FOUND() .AND. LASTREC() # 0
								FRLOCK()
								RECALL
							ELSE
								ADD_REC()
							ENDIF
							SET( _SET_DELETED, .T. )
						ENDIF
						FRLOCK()
						AEVAL(aaux, {|a| _BL->&(a):=M->&(a)} )
						DBUNLOCK()
					ENDIF
				ENDIF
				EXIT
			ENDIF
		ENDDO
		r = 2
		CLEARTYPEAHEAD()
		RECUPAN()
	ELSEIF tecla = -5
		IF PREGUNTA( 0, "ESTAS SEGURO  [ S / N ]", "SsNn" ) $ "Ss"
			MENSAJE( 0, 0, 0, .F., "ELIMINANDO . . ." )
			BLANKREG(.T.)
			GO TOP
			r = 2
			CLEARTYPEAHEAD()
			RECUPAN()
		ENDIF
	ELSEIF tecla==27 .OR. tecla==13 .OR. tecla == -9
		r = 0
	ENDIF

ENDIF

RETURN r



*********

FUNC XBOL

*********
PARAMETERS modo, i
LOCAL lastreg, contenido, campo
PRIVATE tecla

fila = ROW()
columna = COL()

cur_field = bcamp[i]
IF LASTKEY() == 1
	KEYBOARD CHR(0)
	KEYBOARD CHR(31)
	r = 2
ELSEIF LASTKEY() == 6
	KEYBOARD CHR(0)
	KEYBOARD CHR(30)
	r = 2
ENDIF

tecla := LASTKEY()
DO CASE
	CASE tecla == 9
		IF cur_field == "XBL->TIPOLETRA"
			e = ABRW( 17, 10, 40, 'vletra', XBL->TIPOLETRA, '( TIPOS DE LETRA )' )
			IF LASTKEY() == 13
				REPLACE XBL->TIPOLETRA WITH e
			ENDIF
    	ELSEIF cur_field == "XBL->DESC"
 			e = ABRW( 10, 10, 50, vcavec, XBL->DESC, '( DESCRIPCION )', "K==-1.OR.K==-4.or.k==-5.OR.k==-9", "FUNCAUX2(modo,ele,LASTKEY())"  )
    		SALVAPAN( 22, 0, 24, 79 )
			IF LASTKEY() == 13
				REPLACE XBL->DESC WITH &vcavec[e]
			ELSEIF LASTKEY() == -9
				REPLACE XBL->DESC WITH &vcavec[e], XBL->MACRO WITH SUBSTR(&vcavec[e],AT('-',&vcavec[e])+1)
			ENDIF
        RECUPAN()
     ENDIF
		CLEARTYPEAHEAD()
     r = 2
	CASE tecla == -1
		contenido = GET2( fila, columna, &cur_field, "E", bmasc[i] )
*		contenido = GET( fila, columna, cur_field, "E" )
		IF UPDATED() .AND. LASTKEY() # 27
			REPLACE &cur_field WITH contenido
		ENDIF
  	r = 1
		CLEARTYPEAHEAD()
	CASE tecla>31 .AND. tecla<132 .AND. SUBSTR(bedit,i,1)="M"
		contenido = GET2( fila, columna, &cur_field, "M", bmasc[i] )
		IF UPDATED() .AND. LASTKEY() # 27
			REPLACE &cur_field WITH contenido
		ENDIF
		r = 2
 		CLEARTYPEAHEAD()
  CASE tecla == -4
     SET DELETED OFF
     LOCATE FOR DELETED()
		IF FOUND()
     	RECALL
     ELSE
     	APPEND BLANK
     ENDIF
     REPLACE XBL->PASADAS WITH 1, XBL->IMPRIMIR WITH "S"
		CLEARTYPEAHEAD()
     SET DELETED ON
  	r = 2
  CASE tecla == -7						&& F8
  	MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
  	PRIVATE aaux[FCOUNT()-1]
     AEVAL( aaux, {|a,i| aaux[i]:=FIELDGET(i) } )
     SET DELETED OFF
     LOCATE FOR DELETED()
		IF FOUND()
     	RECALL
     ELSE
     	APPEND BLANK
     ENDIF
     AEVAL( aaux, {|a,i| FIELDPUT(i,aaux[i]) } )
		CLEARTYPEAHEAD()
     SET DELETED ON
  	r = 2
     RECUPAN()
  CASE tecla == -8						&& F9
  	MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )
  	lastreg = RECNO()
     rcontenido = &cur_field
     REPLACE &(cur_field) WITH rcontenido REST
     GO lastreg
		CLEARTYPEAHEAD()
     SET DELETED ON
  	r = 2
     RECUPAN()
  CASE tecla == -5
		IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
			EVAL( {|| aux:=XBL->REGISTRO, BLANKREG(.T.), XBL->REGISTRO:=aux } )
        SKIP 1
		ENDIF
		CLEARTYPEAHEAD()
  	r = 2
  CASE tecla == 13
  	r = 1

	CASE tecla = 45			&& -
		IF TYPE(cur_field) == "N"
     	--&cur_field
     ENDIF
     r = 1

	CASE tecla = 43			&& +
		IF TYPE(cur_field) == "N"
     	++&cur_field
     ENDIF
     r = 1
	
	***
	* REEMPLAZO
	***
	CASE tecla = K_F10
		IF TYPE(cur_field) $ "C N D "
     	SET(_SET_CURSOR,SC_ON)
        SETCOLOR("W+/N,N/W,,,W/N")
			Buscar := Reempl := &cur_field
			KEYBOARD CHR(25)
			MARCO( 10, 10, 11, 70, "REEMPLAZO", "D", .T., 0 )
			IF TYPE(cur_field) == "C"
				@ 10, 10 SAY "    Buscar:" GET Buscar PICT "@S49"
				@ 11, 10 SAY "Reemplazar:" GET Reempl PICT "@S49"
        ELSE
				@ 10, 10 SAY "    Buscar:" GET Buscar PICT MASCARA(cur_field)
				@ 11, 10 SAY "Reemplazar:" GET Reempl PICT MASCARA(cur_field)
        ENDIF
        READ
			MARCO( 15, 20, 16, 60, " CAMBIO ", "D", .T., 0 )
			IF LASTKEY() # 27
				__nregistro = RECNO()
				MENSAJE(20, 60, 0, .F., " Reemplazando... ")
           op := ""
           DO WHILE !EOF()
           	r := .F.
					IF TYPE(cur_field) == "C"
           		Buscar := ALLTRIM(Buscar)
           		Reempl := ALLTRIM(Reempl)
              	r := ( Buscar $ &cur_field )
					ELSEIF TYPE(cur_field) == "N"
						r := ( &cur_field == Buscar )
					ELSEIF TYPE(cur_field) == "D"
						r := ( &cur_field == Buscar )
					ENDIF
              IF r
              	@ 15, 20 CLEAR TO 16,60
						IF TYPE(cur_field) == "C"
							aux := STRTRAN( &cur_field, Buscar, Reempl )
							@ 15, 20 SAY LEFT(&cur_field,49)
							@ 16, 20 SAY LEFT(aux,49)
                 ELSE
                 	aux := Reempl
							@ 15, 20 SAY &cur_field
							@ 16, 20 SAY aux
                 ENDIF
                 IF op # "T"
							op := UPPER( PREGUNTA( 20, "[R] reemplaza    [T] reemplaza todo    [N] no reemplaza   [C] cancela", "RrTtNnCc") )
                 ENDIF
                 IF op $ "RT"
              		&cur_field := aux
                 ELSEIF op == "C"
                 	DBGOBOTTOM()
						ENDIF
              ENDIF
              SKIP
				ENDDO
				RECUPAN()
				GO __nregistro
			ENDIF
        RECUPAN()
        RECUPAN()
		ENDIF
		SET CURSOR OFF
		CLEARTYPEAHEAD()
		r = 2
	
	***
	* Busqueda
	***
	CASE LASTKEY() = -2                   &&.-BUSCAR
		IF TYPE(cur_field) $ "C N D "
			Buscar = &cur_field
			KEYBOARD CHR(25)
			Buscar = INGRVAL(fila, 10, "BUSCAR", Buscar, MASCARA(cur_field), "")
			IF LASTKEY() # 27
				__nregistro = RECNO()
				MENSAJE(0, 0, 0, .F., " Buscando... ")
				IF TYPE(cur_field) = "C"
					Buscar = STRTRAN( Buscar, CHR(34), "" )
					Buscar = CHR(34)+ UPPER(ALLTRIM(STRTRAN(Buscar,".",""))) +CHR(34)+ " $ STRTRAN(UPPER(" + cur_field +"),'.','') "
				ELSEIF TYPE(cur_field) = "N"
					Buscar = "&cur_field =" + STR(Buscar)
				ELSEIF TYPE(cur_field) = "D"
					Buscar = "DTOC(" + cur_field +")='" + DTOC(Buscar) +"'"
				ENDIF
				Buscar = Buscar + ".and. cortar()"
				LOCATE FOR &Buscar
				IF .NOT. FOUND()
					MENSAJE(0, 0, 10, .T., "Lo siento NO lo ENCUENTRO !")
					Buscar = ""
					GO __nregistro
				ENDIF
				RECUPAN()
			ELSE
				Buscar = ""
			ENDIF
		ENDIF
		SET CURSOR OFF
		CLEAR TYPEAHEAD
		KEYBOARD CHR(0)
		r = 2
	
	
	***
	* Contun£a busqueda
	***
	CASE LASTKEY() = -3
		IF .NOT. EMPTY(Buscar)
			__nregistro = RECNO()
			SKIP
			MENSAJE(0, 0, 0, .F., " Contin£o Buscando... ")
			LOCATE REST FOR &Buscar
			IF !FOUND()
				MENSAJE( 0, 0, 10, .T., "Lo siento NO lo ENCUENTRO !")
				Buscar = ""
				GO __nregistro
			ENDIF
			RECUPAN()
		ENDIF
		CLEAR TYPEAHEAD
		KEYBOARD CHR(0)
		r = 2

	CASE LASTKEY() = 27
  	r = 0

	OTHERWISE
		r = 1
	
ENDCASE
@ 21,0 SAY LEFT(XBL->MACRO,79)

IF (CHR(LASTKEY())$"".AND.BOF()) .OR. (CHR(LASTKEY())$CHR(24)+"".AND.EOF())
	TONE (100,1)
ENDIF
IF SUBS(bedit,i,1) = "M"
	SETCURSOR( IF(READINSERT(), SC_INSERT, SC_NORMAL) )
ELSE
	SETCURSOR(SC_NONE)
ENDIF
@ fila, columna SAY ""

RETURN(r)


*************

FUNC FUNCAUX2(modo, ele, tecla )

*************
LOCAL long:=LEN(&vcavec), long_1:=LEN(&vcavec)-1

IF modo == "-1"
  masc1 := LEFT(&vcavec[long], AT('-',&vcavec[long])-1 )
	aux1 := LEFT( &vcavec[ele], LEN(masc1) )
  masc2 := ALLTRIM(SUBSTR( &vcavec[long], LEN(masc1)+2 ))
  aux2 := SUBSTR( &vcavec[ele], LEN(masc1)+2 )
	MARCO( 20, 10, 21, 78, '', "D", .T., 0 )
  SETCOLOR("W+/N,N/W,,,W/N,W/N")
	SETCURSOR( SC_ON )
	@ 20, 10 GET aux1 PICT masc1
	@ 21, 10 GET aux2 PICT masc2
	READ
  IF UPDATED()
  	&vcavec[ele]=aux1 +"-"+ aux2
		PONEVEC( "M", vcavec, ele )
  ENDIF
  RECUPAN()
ELSEIF modo == "-4"
  masc1 := LEFT(&vcavec[long], AT('-',&vcavec[long])-1 )
	aux1 := SPACE( LEN(masc1) )
  masc2 := ALLTRIM(SUBSTR( &vcavec[long], LEN(masc1)+2 ))
  aux2 := SPACE( LEN( SUBSTR(&vcavec[long],LEN(masc1)+2) ) )
	MARCO( 20, 10, 21, 78, '', "D", .T., 0 )
  SETCOLOR("W+/N,N/W,,,W/N,W/N")
	SETCURSOR( SC_ON )
	@ 20, 10 GET aux1 PICT masc1
	@ 21, 10 GET aux2 PICT masc2
	READ
  IF UPDATED()
		ele := &vcavec[long_1] := &vcavec[long_1] + 1
  	&vcavec[ele]=aux1 +"-"+ aux2
		fila = fila + 1
		PONEVEC( "A", vcavec, ele )
		y2 = IF(y2<20, y2+1, 20 )
		vez = .T.
  ENDIF
  RECUPAN()
ELSEIF modo == "-5"
	IF &vcavec[long_1] > 0
		IF PREGUNTA( 0, "¨ LO BORRO ( S / N ) ?", "SsNn" ) $ "Ss"
			ADEL(&vcavec, ele )
			AINS(&vcavec, long_1-1)
			&vcavec[long_1] = &vcavec[long_1] - 1
			BORRAVEC( "B", vcavec, long_1 )
			y2 = y2 - 1
			y2 = IF(y2<=y1, y1+1, y2 )
			vez = .T.
		ENDIF
	ENDIF
ELSEIF modo == "-9"
	modo = "Q"
  RETURN .F.
		
ENDIF
modo = "N"

RETURN .t.


***********

FUNC IMPRBL( cualcod )

***********
LOCAL x, y, xcant
cualcod := LEFT( cualcod+SPACE(5), 5 )
FBASES( { "+_BL", "+_BL2"},.F. )
SELECT _BL
LOCATE FOR _BL->CODBL == cualcod
IF !FOUND()
	RETURN .F.
ENDIF

FOR xcant=1 TO _BL->COPIAS
	Ry := 0
	SELECT _BL2
	SET SOFTSEEK ON
	SEEK STR(_BL->(RECNO()),3)
	DO WHILE _BL2->NUMBL == _BL->(RECNO())
  	lAux := .T.
		IF "SOLO ULTIMA" $ _BL2->DESC
     	IF nCopia == nXcopias
  			lAux := .F.
        ENDIF
     ENDIF
		IF _BL2->IMPRIMIR == "S" .AND. &(_BL->COND) .AND. lAux
			y = FPOSY(_BL2->POSY)
			x = FPOSX(_BL2->POSX,_BL2->TIPOLETRA)
     	x := IF( x>0, x, 0 )
     	IF Ry # y
     		?? CHR(27)+"C"+CHR(y-Ry)	// set‚a el largo de la pagina en l¡neas
        	?? CHR(12)
        	Ry := y
     	ENDIF
			FOR i=1 TO _BL2->PASADAS
				IF _BL2->TIPOLETRA > 0 .AND. _BL2->TIPOLETRA <= vletra[10]
					r := ALLTRIM( SUBSTR( vletra[_BL2->TIPOLETRA],RAT("-",vletra[_BL2->TIPOLETRA])+1) )
					@ PROW(), x SAY &r
				ENDIF
				@ PROW(), x SAY &(_BL2->MACRO)
				I_IMPRIMIO := .T.
			NEXT i
		ELSE
			aux = &(_BL2->MACRO)
		ENDIF
		SKIP 1 ALIAS _BL2
	ENDDO
NEXT

RETURN .T.


*************
STATIC FUNC FPOSY(y)
*************
LOCAL r, d:=SET( _SET_DECIMALS, 10 )
r := IF( y-asetprn[BL_MMINI]<=0, 0, y-asetprn[BL_MMINI] )
r := INT( r * ( 10 / 7 ) )
SET( _SET_DECIMALS, d )

RETURN r


***************
STATIC FUNC FPOSX(x,l)
***************
PRIVATE r

IF l>0.AND.l<=vletra[10]
	r = VAL( SUBSTR( vletra[l], AT("-",vletra[l])+1 ) )
	r = x * r
ELSE
	r = x
ENDIF
RETURN r
