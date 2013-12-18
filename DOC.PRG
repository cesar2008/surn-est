#include "SETCURS.CH"
#include "INKEY.CH"

PARAMETERS ym3, xm3
LOCAL pantaux
SELECT 99
ABRIR_BASE( "DOCS", "DOC", "LEFT(DOC->NOMDOC,10)+VER('')" )

MENUDOWN({"     º F3 busca  º    F2    º   F5   º   F6    º   F7    º   ENTER   º ESC  ",;
	"PgUp/Dnº           º modifica º        º         º         º modifica  º      ",;
	" mueve º F4 busca+ º  nombre  º agrega º elimina º imprime º documento º sale "})
SETCOLOR("W/N,N/W")

PRIVATE bcamp[1], bmasc[1], bcab[1], bedit
bcamp[ 1] = "DOC->NOMDOC"
bmasc[ 1] = "@!"
bcab[ 1] = "TEXTOS/DOCUMENTOS"
bedit = "E"
SELECT DOC
pantaux := GUARDOPAN( 0, 0, 24, 79 )
DO WHILE .T.
	BROW( ym3, xm3, 21, xm3+20, "", bcamp, bmasc, bcab, bedit, "REEDOC(tecla)", "tecla=-4.OR.tecla=-5.OR.tecla=-1.OR.tecla=-6" )
	IF LASTKEY() == K_ENTER
		MENUDOWN({"       º Ctrl Y º Ctrl T  º    DEL    º    INS     º   F7    º  F10   º ESC  ",;
			" PgUp/Dn º borra  º borra   º   borra   º sobreescr. º         º utili- º      ",;
			"  mueve  º l¡nea  º palabra º una letra º  Si o No   º imprime º dades  º sale "})
		SETCOLOR( "+W/N,N/W")
		@ 0,0 TO 21,79
		@ 0, CENTRO(80,LEN(ALLTRIM(DOC->NOMDOC))) SAY ALLTRIM(DOC->NOMDOC)
		SETCOLOR( "W/N,N/W")
		@ 21, 1 SAY "fila:      columna:    "
		me_tab = 4
		me_row = 0
		me_col = 0
		me_relrow = 0
		me_relcol = 0
		me_cambio = .F.
		me_modo = 1
		me_aux = SPACE(34)
		READINSERT(.T.)
		me_ins = READINSERT()
		me_cursor = SETCURSOR()
		KEYBOARD CHR(22)
		mfunc( 22, me_row, me_col )
		auxaux = DOC->DOCUMENTO
		DO WHILE me_modo # 0
			me_modo = 1
			auxaux = MEMOEDIT( auxaux, 1, 1, 20, 78, .T., "mfunc", 132, me_tab, me_row, me_col, me_relrow, me_relcol )
			IF me_modo == 0
				IF me_cambio
					IF PREGUNTA( 12, " ¨ GRABO LOS CAMBIOS ?   [ S / N ]", "SsNn") $ "Ss"
						MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
						FRLOCK()
						REPLACE DOC->DOCUMENTO WITH auxaux
						UNLOCK
						RECUPAN()
					ENDIF
				ENDIF
			ELSEIF me_modo == -6
				LISTADOR( "DOCS" )
				SETCURSOR( me_cursor )
			ELSEIF me_modo == -9.1
				MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
				aux = XNAME( "XDOC" ) + ".DOC"
				MEMOWRIT( aux, auxaux )
				SETCURSOR( me_cursor )
				RECUPAN()
			ELSEIF me_modo == -9.2
				MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
				aux = XNAME( "XDOC" ) + ".DOC"
				IF FILE( aux )
					auxaux = MEMOREAD( aux )
					me_cambio = .T.
				ELSE
					MENSAJE( 0, 0, 10, .T., "NO HAY NADA EN EL PORTAPAPELES !!!" )
				ENDIF
				SETCURSOR( me_cursor )
				RECUPAN()
			ELSEIF me_modo == -9.3
				IF FILE( me_aux )
					MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
					auxaux = auxaux + MEMOREAD( me_aux )
					me_cambio = .T.
					RECUPAN()
				ELSE
					MENSAJE( 0, 0, 10, .T., "ARCHIVO NO ENCONTRADO !!!" )
				ENDIF
				SETCURSOR( me_cursor )
			ENDIF
		ENDDO
	ELSEIF LASTKEY() == 27
		RECUPAN()
		EXIT
	ENDIF
	PONEPAN( pantaux )
	RECUPAN()
ENDDO

RETURN .T.


***********

FUNC REEDOC

***********
PARAMETERS tecla
PRIVATE r

r = 1
IF tecla == -1
	contenido = GET( fila, columna, cur_field, "E" )
	IF UPDATED()
		FRLOCK()
		REPLACE &cur_field WITH contenido
		UNLOCK
	ENDIF
	r = 2
	CLEARTYPEAHEAD()
ELSEIF tecla = -4
	cur_field = bcamp[1]
	contenido = GET( by2, bx1, cur_field, "A" )
	IF LASTKEY() == 13
		SET DELETED OFF
		GO TOP
		IF !EMPTY(DOC->DOCUMENTO) .OR. LASTREC() < 1
			ADD_REC()
		ELSE
			FRLOCK()
			RECALL
		ENDIF
		FRLOCK()
		REPLACE &cur_field WITH contenido
		UNLOCK
		SET DELETED ON
	ENDIF
	r = 2
	CLEARTYPEAHEAD()
ELSEIF tecla = -5
	IF PREGUNTA( 0, "¨ ESTA SEGURO [ S / N ] ?", "SsNn" ) $ "Ss"
		BLANKREG(.T.)
		UNLOCK
		GO TOP
	ENDIF
	r = 2
	CLEARTYPEAHEAD()
ELSEIF tecla = -6
	auxaux = DOC->DOCUMENTO
	LISTADOR( "DOCS" )
ENDIF

RETURN r


**********

FUNC mfunc

**********
PARAMETERS nMode, nLine, nCol
PRIVATE r, k, e, aux, i, lastdir

me_relrow = ROW()
me_relcol = COL()
r = 0
K = LASTKEY()
IF nMode == 344
	r = 34
ELSEIF K == 22
	SETCOLOR( "+W/N,N/W" )
	IF me_ins
		me_ins = .F.
		me_cursor = 1
		SETCURSOR( me_cursor )
		@ 21, 30 SAY "ÄÄÄ"
	ELSE
		me_ins = .T.
		me_cursor = 2
		SETCURSOR( me_cursor )
		@ 21, 30 SAY "INS"
	ENDIF
	SETCOLOR( "W/N,N/W" )
	r = 22
ELSEIF CHR(K) $ "" 				&& ^T ^Y DEL
	me_cambio = .T.
ELSEIF K == 27
	me_modo = 0
	r = 23
ELSEIF K == -6
	me_modo = -6
	r = 23
ELSEIF K == -9
	SETCOLOR( "N/W,W/N" )
	op = MENUFLASH( 10, 25, 1, .T., "UTILIDADES", "GUARDAR ESTE TEXTO EN ARCHIVO AUXILIAR", "TRAER TEXTO DEL ARCHIVO AUXILIAR", "CARGAR UN ARCHIVO DE TEXTOS" )
	IF op == 1
		me_modo = -9.1
		r = 23
	ELSEIF op == 2
		me_modo = -9.2
		r = 23
		* * *   adosador de archivos   * * *
	ELSEIF op == 3
		MARCO( 10, 1, 10, 78, "", "S", .T., 0 )
		aux = LEFT( me_aux+SPACE(40), 40 )
		aux = "*.*                              "
		DO WHILE .T.
			SETCURSOR( me_cursor )
			SET KEY 9 TO CLEAR_GETS()
			@ 10, 1 SAY "Nombre del archivo (TAB p/elegir):" GET aux PICT "@!"
			READ
			SET KEY 9 TO
			IF LASTKEY() == 13
				me_aux = ALLTRIM(aux)
				me_modo = -9.3
				r = 23
				EXIT
			ELSEIF LASTKEY() == 9
				lastdir = "\"+CURDIR()
				DO WHILE .T.
					MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
					cantaux = ADIR(aux) + 20
					PRIVATE aaux[cantaux], aaux2[cantaux]
					ADIR( aux, aaux,,,, aaux2 )
					IF aaux[1] == NIL
						RECUPAN()
						EXIT
					ENDIF
					IF LEFT(aaux[1],1) == "."
						ADEL( aaux, 1 )
						ADEL( aaux2, 1 )
					ENDIF
					cantaux = 1
					DO WHILE aaux[cantaux] # NIL
						IF .NOT. aaux2[cantaux] $ "AD"
							ADEL( aaux, cantaux )
							ADEL( aaux2, cantaux )
						ELSE
							IF aaux2[cantaux] == "D" .AND. LEFT(aaux[cantaux],2) # ".."
								aaux[cantaux] = "\" + aaux[cantaux]
							ENDIF
							cantaux += 1
						ENDIF
					ENDDO
					RECUPAN()
					e = PP_SELEC( 10, 50, cantaux, 13, aaux, 1, "", "S", .T.)
					RECUPAN()
					IF LASTKEY() == 13
						IF aaux2[e] == "D"
							MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
							IF LEFT(aaux[e],2) == ".."
								RUN CD ..
							ELSE
								e = STRTRAN( "cd \"+CURDIR() + aaux[e], "\\", "\" )
								RUN &e
							ENDIF
							RECUPAN()
						ELSE
							aux = "\"+ CURDIR() +"\"+ aaux[e]
							EXIT
						ENDIF
					ELSE
						EXIT
					ENDIF
				ENDDO
				RUN C:
				RUN CD &lastdir
			ELSEIF LASTKEY() == 27
				EXIT
			ENDIF
		ENDDO
		RECUPAN()
	ENDIF
ELSEIF K > 31
	me_cambio = .T.
ENDIF

SETCOLOR("+W/N")
@ 21, 6 SAY nLine PICT "9999"
@ 21, 20 SAY nCol+1 PICT "999"
SETCOLOR("W/N,N/W")

RETURN r
