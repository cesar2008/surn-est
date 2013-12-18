#include "SCR.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
parameters cArch
tiempo := 60

SET PROC TO SCR4
SET TALK OFF
SET( _SET_SCOREBOARD, .F. )
SET STATUS OFF


PUBLIC __arranco := .F., F8 := SPACE(50)
PUBLIC mRrel := mele := 0
PUBLIC vRrel := vele := 0

IF FILE("FUNCS.DB")
	SELECT 99
	USE FUNCS.DB ALIAS FU
ENDIF

PUBLIC amenu1[3], acolor[9], afunc
amenu1[1] = "Pantallas"
amenu1[2] = "Bases    "
amenu1[3] = "Salir    "

acolor[1] = "W/N"
acolor[2] = "N/W"
acolor[3] = "+W/N"
acolor[4] = "U/N"
acolor[5] = "UW+/N"
acolor[6] = "*W/N"
acolor[7] = "*N/W"
AA = 1
YY = 24
cNOMARCH = SPACE(8)
NBASE = 0
cSET = ""
afunc := ARRAY(9)
AFILL(afunc,"")
FOR i=1 TO LEN(afunc)
	SET FUNCTION (i+20) TO ""
NEXT

MINY := 10
MINX := 10
MAXY := 20
MAXX := 60

PUBLIC LI[25], ACAMPO[25], AVER[25], menuaux
AFILL( LI, SPACE(80) )
AFILL( ACAMPO, REPL('',80) )
AFILL( AVER, REPL('',80) )

MVAR:={}
MVER:={}

PUBLIC ABASE:={}, AALIAS:={}, AELE:={}, apos:={1,1}

CFONDO = "W/N  "
CGET   = "N/W  "
CSAY   = "W+/N "
CFUNC  = "W/N  "

SETCOLOR("W/N")
RELLENAPAN(0,0,24,79,"≤")
@ SCRS(MINY), SCRS(MINX) CLEAR TO SCRS(MAXY), SCRS(MAXX)

SETKEY( K_ALT_H, {|| VERBASES()} )
SETKEY( K_INS, {|| INSTOGGLE()} )

py := MINY
px := MINX
menuaux = SAVESCREEN( YY, 0, YY, 79 )
tiempo1 := SECONDS()
if cArch#nil
	if !".SCR" $ cArch
  	cArch += ".SCR"
  endif
	CARGAR(cArch)
endif
DO WHILE .T.
	FSTATUS()
	SETCURSOR(SC_ON)
	@ SCRS(py), SCRS(px) SAY ""
	K = INKEY(1)
	IF K == K_DOWN
		++py
	ELSEIF K == K_UP
		--py
	ELSEIF K == K_RIGHT
		++px
	ELSEIF K == K_LEFT
		--px
	ELSEIF K == K_ENTER
		++py
		px = 1
	ELSEIF K == K_ESC
  	dbunlockall()
		cAux := upper(PREGUNTA( 10, "[ G ] graba      [ S ] sale      [ C ] contin£a ", "GgSsCc" ))
		if cAux == "G"
			GRABAR()
			EXIT
		elseif cAux == "S"
			EXIT
		endif
	ELSEIF K == K_HOME
		px = MINX
	ELSEIF K == K_END
		px = MAXX
	ELSEIF K == K_DEL
		IF SUBSTR( ACAMPO[py], px, 1 ) == "" .AND. SUBSTR( AVER[py], px, 1 ) == ""
			LI[py] = STUFF( LI[py], px, 1, "" ) + " "
			ACAMPO[py] = STUFF( ACAMPO[py], px, 1, "" ) + ''
			AVER[py] = STUFF( AVER[py], px, 1, "" ) + ''
			y:=SCRS(py)
			x1:=SCRS(px)
			x2:=SCRS(MAXX)
			RESTSCREEN( y, x1, y, x2-1, SAVESCREEN( y, x1+1, y, x2 ) )
			i := ASCAN( MVAR, {|a| a[SR_Y]==py} )
			DO WHILE i > 0
				IF MVAR[i,SR_X] >= px
					--MVAR[i,SR_X]
				ENDIF
				i := ASCAN( MVAR, {|a| a[SR_Y]==py}, i+1 )
			ENDDO
			i := ASCAN( MVER, {|a| a[SR_Y]==py} )
			DO WHILE i > 0
				IF MVER[i,SR_X] >= px
					--MVER[i,SR_X]
				ENDIF
				i := ASCAN( MVER, {|a| a[SR_Y]==py}, i+1 )
			ENDDO
			SETCOLOR(CFONDO)
			@ SCRS(py), SCRS(MAXX) SAY " "
		ELSE
			TONE( 100, 1 )
		ENDIF
	ELSEIF K == K_BS
		IF SUBSTR( ACAMPO[py], px, 1 ) == "" .AND. SUBSTR( AVER[py], px, 1 ) == "" .AND. px > MINX
			LI[py] = STUFF( LI[py], px, 1, "" ) + " "
			ACAMPO[py] = STUFF( ACAMPO[py], px, 1, "" ) + ''
			AVER[py] = STUFF( AVER[py], px, 1, "" ) + ''
			RESTSCREEN( SCRS(py), SCRS(px)-1, SCRS(py), SCRS(MAXX)-1, SAVESCREEN( SCRS(py), SCRS(px), SCRS(py), SCRS(MAXX) ) )
			i := ASCAN( MVAR, {|a| a[SR_Y]==py} )
			DO WHILE i > 0
				IF MVAR[i,SR_X] >= px
					--MVAR[i,SR_X]
				ENDIF
				i := ASCAN( MVAR, {|a| a[SR_Y]==py}, i+1 )
			ENDDO
			i := ASCAN( MVER, {|a| a[SR_Y]==py} )
			DO WHILE i > 0
				IF MVER[i,SR_X] >= px
					--MVER[i,SR_X]
				ENDIF
				i := ASCAN( MVER, {|a| a[SR_Y]==py}, i+1 )
			ENDDO
			SETCOLOR(acolor[AA])
			@ SCRS(py), SCRS(MAXX) SAY " "
			px = px - 1
		ELSE
			TONE( 100, 1 )
		ENDIF
		
	ELSEIF K == K_ALT_O
		SETCOLOR( "+W/N,N/W" )
		op = PP_SELEC( 1, 1, 0, 0, acolor, AA, "ATRIBUTOS", "S", .T. )
		AA = IF( LASTKEY()==13, op, AA )
		RECUPAN()
		
	ELSEIF K == K_ALT_U
		SETCOLOR( "+W/N,N/W" )
		AEVAL(afunc,{|a,i| afunc[i]:=STR(i,2)+": "+ a } )
		DO WHILE .T.
			op := PP_SELEC( 1, 1, 0, 0, afunc, AA, "ATRIBUTOS", "S", .T. )
			IF LASTKEY() == K_ENTER
				MARCO( 2, op, 2, 40, "F"+STR(op,1), "S", .T. )
				aux := LEFT(SUBSTR(afunc[op],5)+SPACE(40),40)
				aux := FGET( 2, op, aux, "", ".F." )
				afunc[op] := STR(op,2)+": "+ RTRIM(aux)
				RECUPAN()
			ELSEIF LASTKEY() == K_ESC
				RECUPAN()
				EXIT
			ENDIF
			RECUPAN()
		ENDDO
		FOR i=1 TO LEN(afunc)
			afunc[i] := SUBSTR( RTRIM(afunc[i]), 5 )
			SET FUNCTION -(i+19) TO afunc[i]
		NEXT
		SETCOLOR(acolor[AA])
		
	ELSEIF K == K_ALT_E
		IF LEN(ABASE) # 0
			SETCOLOR( "+W/N,N/W" )
			op = PP_SELEC( 1, 1, LEN(ABASE), 0, ABASE, 1, "EN USO", "S", .T. )
			IF LASTKEY() == 13
				NBASE = op
				KEYBOARD CHR(-9)
			ENDIF
			RECUPAN()
		ENDIF
		
	ELSEIF K == K_ALT_B
		aux = ADIR( "*.DBF" )
		IF aux > 0
			DECLARE aaux[aux]
			ADIR( "*.DBF", aaux )
			FOR i=1 TO LEN(ABASE)
				x = ASCAN( aaux, ABASE[i])
				IF x > 0
					ADEL( aaux, x )
					ASIZE( aaux, LEN(aaux)-1 )
				ENDIF
			NEXT
			IF LEN(aaux) > 0
				SETCOLOR( "+W/N,N/W" )
				op = PP_SELEC( 1, 1, 0, 0, aaux, 1, "BASES", "S", .T. )
				IF LASTKEY() == 13
					aux = INGRVAL(10, 30, "Alias:", "     ", "!!!!!")
					IF !EMPTY(aux) .AND. LASTKEY() == 13
						FBASE( aaux[op], aux )
					ENDIF
				ENDIF
				RECUPAN()
			ENDIF
		ENDIF
		
		* * *  traÇr una pantalla ya grabada * * *
	ELSEIF K == K_F11
		CARGAR()
		
		
	ELSEIF K == K_F2						&& TAMA•O
		aaux := { MINY, MINX, MAXY, MAXX, SAVESCREEN( 0, 0, 24, 79 ) }
		RESTSCREEN( YY, 0, YY, 79, menuaux )
		aaux2 := ARRAY( MAXY-MINY+1 )
		AEVAL( aaux2, {|a,i| aaux2[i]:=SAVESCREEN( SCRS(MINY)+i-1, SCRS(MINX), SCRS(MINY)+i-1, SCRS(MAXX)) } )
		SETCURSOR( SC_OFF )
		KEYBOARD " "
		i := 1
		SETCOLOR(CFONDO)
		DO WHILE .T.
			K := INKEY(.3)
			@ SCRS(MAXY), SCRS(MAXX) SAY " "
			IF K == K_UP
				IF ASCAN( MVAR, {|a| a[SR_Y]==MAXY} )==0 .AND. ASCAN( MVER, {|a| a[SR_Y]==MAXY} )==0 .AND. MAXY > MINY
					DISPBOX( SCRS(MAXY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), "≤", "W/N" )
					--MAXY
				ENDIF
			ELSEIF K == K_DOWN
				IF MAXY < 25
					++MAXY
					DISPBOX( SCRS(MAXY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), " ", CFONDO )
				ENDIF
			ELSEIF K == K_LEFT
				r := .F.
				AEVAL( ACAMPO, {|a| r:=IF(SUBSTR(a,MAXX,1)=='',r,.T.)} )
				AEVAL( AVER, {|a| r:=IF(SUBSTR(a,MAXX,1)=='',r,.T.)} )
				IF !r .AND. MAXX > MINX
					DISPBOX( SCRS(MINY), SCRS(MAXX), SCRS(MAXY), SCRS(MAXX), "≤", "W/N" )
					--MAXX
				ENDIF
			ELSEIF K == K_RIGHT
				IF MAXX < 80
					++MAXX
					DISPBOX( SCRS(MINY), SCRS(MAXX), SCRS(MAXY), SCRS(MAXX), " ", CFONDO )
				ENDIF
			ELSEIF K == K_ESC
				MINY := aaux[1]
				MINX := aaux[2]
				MAXY := aaux[3]
				MAXX := aaux[4]
				RESTSCREEN( 0, 0, 24, 79, aaux[5] )
				EXIT
			ELSEIF K == K_ENTER
				y2 := MIN( aaux[3], MAXY )
				x2 := MIN( aaux[4], MAXX )
				AEVAL( aaux2, {|a,i| RESTSCREEN( SCRS(MINY)+i-1, SCRS(MINX), SCRS(MINY)+i-1, SCRS(x2), a)},1,y2-MINY+1)
				EXIT
			ENDIF
			IF MAXY <= aaux[3] .OR. MAXX <= aaux[4]
				y2 := MIN( aaux[3], MAXY )
				x2 := MIN( aaux[4], MAXX )
				AEVAL( aaux2, {|a,i| RESTSCREEN( SCRS(MINY)+i-1, SCRS(MINX), SCRS(MINY)+i-1, SCRS(x2), a)}, 1, y2-MINY+1 )
			ENDIF
			@ SCRS(MAXY), SCRS(MAXX) SAY SUBSTR(""+CHR(26)+""+CHR(27),EVAL({||i:=IF(i+1>4,i:=0,i),++i}),1)
		ENDDO
		menuaux = SAVESCREEN( YY, 0, YY, 79 )
		SETCURSOR( SC_ON )
		SETCOLOR(acolor[AA])
		
		
	ELSEIF K == K_F3							&& MOVER
		aaux := { MINY, MINX, MAXY, MAXX, SAVESCREEN( 0, 0, 24, 79 ) }
		RESTSCREEN( YY, 0, YY, 79, menuaux )
		SETCURSOR( SC_OFF )
		aux := SAVESCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX) )
		RELLENAPAN(0,0,24,79,"≤")
		KEYBOARD " "
		i:=1
		DO WHILE .T.
			K := INKEY(.3)
			RELLENAPAN(0,0,24,79,"≤")
			IF K == K_UP
				IF MINY > 1
					--MINY
					--MAXY
				ENDIF
			ELSEIF K == K_DOWN
				IF MAXY < 25
					++MINY
					++MAXY
				ENDIF
			ELSEIF K == K_LEFT
				IF MINX > 1
					--MINX
					--MAXX
				ENDIF
			ELSEIF K == K_RIGHT
				IF MAXX < 80
					++MINX
					++MAXX
				ENDIF
			ELSEIF K == K_ESC
				MINY := aaux[1]
				MINX := aaux[2]
				MAXY := aaux[3]
				MAXX := aaux[4]
				RESTSCREEN( 0, 0, 24, 79, aaux[5] )
				EXIT
			ELSEIF K == K_ENTER
				dify := aaux[1] - MINY
				difx := aaux[2] - MINX
				AEVAL( MVAR, {|a,i|                      ;
					MVAR[i,SR_Y] := MVAR[i,SR_Y] - dify,  ;
					MVAR[i,SR_X] := MVAR[i,SR_X] - difx } )
				AEVAL( MVER, { |a,i|                     ;
					MVER[i,SR_Y] := MVER[i,SR_Y] - dify,  ;
					MVER[i,SR_X] := MVER[i,SR_X] - difx } )
				AFILL( ACAMPO, REPLICATE('',80) )
				AFILL( AVER, REPLICATE('',80) )
				FOR i=1 TO LEN(MVAR)
					IF MVAR[i,SR_Y] > 0
						ACAMPO[MVAR[i,SR_Y]] := STUFF( ACAMPO[MVAR[i,SR_Y]], MVAR[i,SR_X], LEN(MVAR[i,SR_PIC]), REPLIC(CHR(i+1),LEN(MVAR[i,SR_PIC])) )
					ENDIF
				NEXT
				FOR i=1 TO LEN(MVER)
					IF MVER[i,SR_Y] > 0
						AVER[MVER[i,SR_Y]] := STUFF( AVER[MVER[i,SR_Y]], MVER[i,SR_X], LEN(MVER[i,SR_PIC]), REPLIC(CHR(i+1),LEN(MVER[i,SR_PIC])) )
					ENDIF
				NEXT
				RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
				EXIT
			ENDIF
			RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
			@ SCRS(MINY), SCRS(MINX) SAY SUBSTR(""+CHR(26)+""+CHR(27),EVAL({||i:=IF(i+1>4,i:=0,i),++i}),1)
		ENDDO
		menuaux = SAVESCREEN( YY, 0, YY, 79 )
		SETCURSOR( SC_ON )
		
	ELSEIF K == K_F4
		aaux := SAVESCREEN( 0, 0, 24, 79 )
		aaux2 := { ;
			{ "…",  "Õ",   "—",  "À",  "ª",   "⁄",   "ƒ",   "“",   "¬",   "ø",  "ö",  "õ",  "ú",  "ù",  "û",  "ü",   "†"  },;
			{ "∫",  " ",   "≥",  "«",  "∂",   "≥",   " ",   "∫",   "∆",   "µ",  "§",  "•",  "¶",  "ß",  "®",  "©",   "™"  },;
			{ "Ã",  "Õ",   "ÿ",  "Œ",  "π",   "√",   "ƒ",   "◊",   "≈",   "¥",  "Æ",  "Ø",  "∞",  "±",  "≤",  "∑",   "∏"  },;
			{ "»",  "Õ",   "œ",  " ",  "º",   "¿",   "ƒ",   "–",   "¡",   "Ÿ",  "’",  "÷",  "€",  "‹",  "›",  "ﬁ",   "ﬂ"  },;
			{ "",  "",   "",  "",  "",   "",   "?",CHR(8),CHR(9),CHR(10), "„",  "‰",  "Â",  "Ê",  "Á",  "Ë",   "È"  },;
			{ "",  "",CHR(13), "",  "",   "",   "",   "",   "",   "",  "Ì",  "Ó",  "Ô",  "",  "Ò",  "Ú",   "Û"  },;
			{ "",  "",   "",  "",  "",CHR(26),CHR(27), "",   "",   "",  "˜",  "¯",  "˘",  "˙",  "˚",  "¸",   "˝"  },;
			{ "",  "!",CHR(34), "",  "Ä",   "Å",   "Ç",   "É",   "Ñ",   "Ö",  "°",  "¢",  "£",  "‡",  "·",  "‚",   "˛"  },;
			{ "Ü",  "á",   "à",  "â",  "ä",   "ã",   "å",   " ",   "é",   "è",  "´",  "¨",  "≠",  "Í",  "Î",  "Ï",CHR(255)},;
			{ "ê",  "ë",   "í",  "ì",  "î",   "ï",   "ñ",   "ó",   "ò",   "ô",  "Ω",  "”",  "‘",  "Ù",  "ı",  "ˆ",   "@"  } }
		RESTSCREEN( YY, 0, YY, 79, menuaux )
		DO WHILE .T.
			SETCURSOR(SC_OFF)
			SETCOLOR("N/W,W/N")
			MARCO( 2, 2, LEN(aaux2)*2, LEN(aaux2[1])*2, "para llamarme F4", "S", .T. )
			DISPBEGIN()
			FOR y=1 TO LEN(aaux2)
				AEVAL( aaux2[y], {|a,x| SETCOLOR("N/W"), DEVPOS(y*2,x*2), QQOUT(a)})
			NEXT
			DISPEND()
			KEYBOARD " "
			DO WHILE .T.
				K := INKEY(0)
				@ apos[1]*2,apos[2]*2 SAY aaux2[apos[1],apos[2]]
				IF K == K_UP
					apos[1] := IF( apos[1]-1<1, 1, --apos[1] )
				ELSEIF K == K_DOWN
					apos[1] := IF( apos[1]+1>LEN(aaux2), LEN(aaux2), ++apos[1] )
				ELSEIF K == K_LEFT
					apos[2] := IF( apos[2]-1<1, 1, --apos[2] )
				ELSEIF K == K_RIGHT
					apos[2] := IF( apos[2]+1>LEN(aaux2[1]), LEN(aaux2[1]), ++apos[2] )
				ELSEIF K == K_ENTER
					EXIT
				ELSEIF K == K_ESC
					EXIT
				ENDIF
				@ 1,2 SAY ASC(aaux2[apos[1],apos[2]]) PICT "999"
				SETCOLOR("*W+/N,N/W")
				@ apos[1]*2,apos[2]*2 SAY aaux2[apos[1],apos[2]]
				SETCOLOR("N/W,W/N")
			ENDDO
			RECUPAN()
			IF K == K_ESC
				EXIT
			ELSE
				aaux := SAVESCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX) )
				KEYBOARD " "
				i := 1
				SETCOLOR(acolor[AA])
				DO WHILE .T.
					K := INKEY(.3)
					IF SUBSTR(ACAMPO[py],px,1) == '' .AND. SUBSTR(AVER[py],px,1) == ''
						@ SCRS(py), SCRS(px) SAY aaux2[apos[1],apos[2]]
					ENDIF
					IF K == K_UP
						py := IF( py-1<MINY, MINY, --py )
					ELSEIF K == K_DOWN
						py := IF( py+1>MAXY, MAXY, ++py )
					ELSEIF K == K_LEFT
						px := IF( px-1<MINX, MINX, --px )
					ELSEIF K == K_RIGHT
						px := IF( px+1>MAXX, MAXX, ++px )
					ELSEIF K == K_F4
						EXIT
					ELSEIF K == K_ENTER
						EXIT
					ELSEIF K == K_ESC
						RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aaux )
						EXIT
					ENDIF
					@ SCRS(py), SCRS(px) SAY SUBSTR(""+CHR(26)+""+CHR(27),EVAL({||i:=IF(i+1>4,i:=0,i),++i}),1)
				ENDDO
				IF K == K_ENTER
					EXIT
				ENDIF
			ENDIF
		ENDDO
		menuaux = SAVESCREEN( YY, 0, YY, 79 )
		SETCURSOR( SC_ON )
		SETCOLOR( acolor[AA] )
		
		
	ELSEIF K == K_F5
		r = .T.
		IF ASCAN( MVAR, {|a|a[SR_Y]==MAXY} ) > 0 .OR. ASCAN( MVER, {|a|a[SR_Y]==MAXY} ) > 0
			r = .F.
			IF PREGUNTA( 0, "SE PERDERA LA ULTIMA LINEA, ESTA SEGURO [ S / N ] ? ", "SsNn" ) $ "Ss"
				r = .T.
			ENDIF
		ENDIF
		IF r
			FOR i=1 TO LEN(MVAR)
				IF MVAR[i,SR_Y] == MAXY
					ADEL( MVAR, i )
					ASIZE( MVAR, LEN(MVAR)-1 )
				ELSEIF MVAR[i,SR_Y] >= py
					++MVAR[i,SR_Y]
				ENDIF
			NEXT
			FOR i=1 TO LEN(MVER)
				IF MVER[i,SR_Y] == MAXY
					ADEL( MVER, i )
					ASIZE( MVER, LEN(MVER)-1 )
				ELSEIF MVER[i,SR_Y] >= py
					++MVER[i,SR_Y]
				ENDIF
			NEXT
			AINS( ACAMPO, py )
			AINS( AVER, py )
			ACAMPO[py] = REPLICATE('',80)
			AVER[py] = REPLICATE('',80)
			RESTSCREEN( YY, 0, YY, 79, menuaux )
			aux = SAVESCREEN( SCRS(py), SCRS(MINX), SCRS(MAXY-1), SCRS(MAXX) )
			RESTSCREEN( SCRS(py+1), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
			SETCOLOR(acolor[AA])
			@ SCRS(py), SCRS(MINX) CLEAR TO SCRS(py), SCRS(MAXX)
			menuaux = SAVESCREEN( YY, 0, YY, 79 )
		ENDIF
		
		
	ELSEIF K == K_F6
		r = .T.
		IF ASCAN( MVAR, {|a| a[SR_Y]==py} ) > 0 .OR. ASCAN( MVER, {|a|a[SR_X]==py} ) > 0
			r = .F.
			IF PREGUNTA( 0, "SE PERDERAN LOS CAMPOS DE LA LINEA, ESTA SEGURO [ S / N ] ? ", "SsNn" ) $ "Ss"
				r = .T.
			ENDIF
		ENDIF
		IF r
			FOR i=1 TO LEN(MVAR)
				IF MVAR[i,SR_Y] == py
					ADEL( MVAR, i )
					ASIZE( MVAR, LEN(MVAR)-1 )
				ELSEIF MVAR[i,SR_Y] > py
					--MVAR[i,SR_Y]
				ENDIF
			NEXT
			FOR i=1 TO LEN(MVER)
				IF MVER[i,SR_Y] == py
					ADEL( MVER, i )
					ASIZE( MVER, LEN(MVER)-1 )
				ELSEIF MVER[i,SR_Y] > py
					--MVER[i,SR_Y]
				ENDIF
			NEXT
			ADEL( ACAMPO, py )
			ADEL( AVER, py )
			ACAMPO[25] = REPLICATE('',80)
			AVER[25] = REPLICATE('',80)
			RESTSCREEN( YY, 0, YY, SCRS(MAXX), menuaux )
			aux = SAVESCREEN( SCRS(py+1), SCRS(MINX), SCRS(MAXY), SCRS(MAXX) )
			RESTSCREEN( SCRS(py), SCRS(MINX), SCRS(MAXY-1), SCRS(MAXX), aux )
			SETCOLOR(acolor[AA])
			@ SCRS(MAXY), SCRS(MINX) CLEAR TO SCRS(MAXY), SCRS(MAXX)
			menuaux = SAVESCREEN( YY, 0, YY, 79 )
		ENDIF
		
		
	ELSEIF K == K_F8
		VERARCH()
		
	ELSEIF K == K_ALT_F8
		aux:=MEMOREAD("QQ")
     KEYBOARD aux
		
		
	ELSEIF K == K_ALT_M
		RESTSCREEN( YY, 0, YY, 79, menuaux )
		SETCURSOR( SC_OFF )
		aux := SAVESCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX) )
		i:=1
		y1 := y2 := py
		x1 := x2 := px
		DO WHILE .T.
			K := INKEY(.3)
			IF K == K_UP
				y2 -= IF( y2-1<y1, 0, 1 )
			ELSEIF K == K_DOWN
				y2 += IF( y2+1>MAXY, 0, 1 )
			ELSEIF K == K_LEFT
				x2 -= IF( x2-1<x1, 0, 1 )
			ELSEIF K == K_RIGHT
				x2 += IF( x2+1>MAXX, 0, 1 )
			ELSEIF K == K_ESC
				RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
				EXIT
			ELSEIF K == K_ENTER
				r := .T.
				FOR i=y1 TO y2
					IF x2+1 < MAXX
						IF SUBSTR(ACAMPO[i],x2+1,1) # '' .OR. SUBSTR(AVER[i],x2+1,1) # ''
							TONE(100,1)
							r := .F.
							EXIT
						ENDIF
					ENDIF
				NEXT
				IF r
					ry1 := y1
					rx1 := x1
					ry2 := y2
					rx2 := x2
					DO WHILE .T.
						K := INKEY(.3)
						IF K == K_UP
							IF y1-1 >= MINY
								--y1
								--y2
							ENDIF
						ELSEIF K == K_DOWN
							IF y2+1 <= MAXY
								++y1
								++y2
							ENDIF
						ELSEIF K == K_LEFT
							IF x1-1 >= MINX
								--x1
								--x2
							ENDIF
						ELSEIF K == K_RIGHT
							IF x2+1 <= MAXX
								++x1
								++x2
							ENDIF
						ELSEIF K == K_ESC
							RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
							EXIT
						ELSEIF K == K_ENTER
							FOR i=1 TO LEN(MVAR)
								IF MVAR[i,SR_Y] >= ry1 .AND. MVAR[i,SR_Y] <= ry2 .AND. MVAR[i,SR_X] >= rx1 .AND. MVAR[i,SR_X] <= rx2
									ACAMPO[MVAR[i,SR_Y]] := STUFF( ACAMPO[MVAR[i,SR_Y]], MVAR[i,SR_X], LEN(MVAR[i,SR_PIC]), REPLICATE('',LEN(MVAR[i,SR_PIC])) )
									MVAR[i,SR_Y] += ( y1 - ry1 )
									MVAR[i,SR_X] += ( x1 - rx1 )
									ACAMPO[MVAR[i,SR_Y]] := STUFF( ACAMPO[MVAR[i,SR_Y]], MVAR[i,SR_X], LEN(MVAR[i,SR_PIC]), REPLICATE(CHR(i+1),LEN(MVAR[i,SR_PIC])) )
								ENDIF
							NEXT
							FOR i=1 TO LEN(MVER)
								IF MVER[i,SR_Y] >= ry1 .AND. MVER[i,SR_Y] <= ry2 .AND. MVER[i,SR_X] >= rx1 .AND. MVER[i,SR_X] <= rx2
									AVER[MVER[i,SR_Y]] := STUFF( AVER[MVER[i,SR_Y]], MVER[i,SR_X], LEN(MVER[i,SR_PIC]), REPLICATE('',LEN(MVER[i,SR_PIC])) )
									MVER[i,SR_Y] += ( y1 - ry1 )
									MVER[i,SR_X] += ( x1 - rx1 )
									AVER[MVER[i,SR_Y]] := STUFF( AVER[MVER[i,SR_Y]], MVER[i,SR_X], LEN(MVER[i,SR_PIC]), REPLICATE(CHR(i+1),LEN(MVER[i,SR_PIC])) )
								ENDIF
							NEXT
							RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
							RESTSCREEN( SCRS(y1), SCRS(x1), SCRS(y2), SCRS(x2), aux2 )
							EXIT
						ENDIF
						RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
						RESTSCREEN( SCRS(y1), SCRS(x1), SCRS(y2), SCRS(x2),;
							TRANSFORM( aux2, REPLICATE("X"+CHR(130),(SCRS(y2)-SCRS(y1)+1)*(SCRS(x2)-(SCRS(x1)-2)+1)*2) ) )
						@ SCRS(y1), SCRS(x1) SAY SUBSTR(""+CHR(26)+""+CHR(27),EVAL({||i:=IF(i+1>4,i:=0,i),++i}),1)
					ENDDO
					DISPALL()
					manuaux := SAVESCREEN( YY, 0, YY, 79 )
					EXIT
				ENDIF
			ENDIF
			RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
			aux2 := SAVESCREEN( SCRS(y1), SCRS(x1), SCRS(y2), SCRS(x2) )
			RESTSCREEN( SCRS(y1), SCRS(x1), SCRS(y2), SCRS(x2),;
				TRANSFORM( aux2, REPLICATE("X"+CHR(130),(SCRS(y2)-SCRS(y1)+1)*(SCRS(x2)-(SCRS(x1)-2)+1)*2) ) )
			@ SCRS(y2), SCRS(x2) SAY SUBSTR(""+CHR(26)+""+CHR(27),EVAL({||i:=IF(i+1>4,i:=0,i),++i}),1)
		ENDDO
		SETCURSOR( SC_ON )
		SETCOLOR( acolor[AA] )
		
		
	ELSEIF K == K_ALT_M
		SETCOLOR( "*N/W" )
		ry = py
		rx = px
		RESTSCREEN( YY, 0, YY, 79, menuaux )
		aux = SAVESCREEN( ry, rx, 24, 79 )
		DO WHILE .T.
			K = INKEY(0)
			IF K == 24
				py = py + 1
			ELSEIF K == 5
				py = py - 1
			ELSEIF K == 4
				px = px + 1
			ELSEIF K == 19
				px = px - 1
			ELSEIF K == 13
				py = py + 1
				px = 0
			ELSEIF K == K_ESC
				EXIT
			ELSEIF K == 1              			&& HOME
				px = 0
			ELSEIF K == 6								&& END
				px = 79
			ENDIF
			IF py < ry
				py = ry
			ELSEIF py > 24
				py = 24
			ENDIF
			IF px < rx
				px = rx
			ELSEIF px > 79
				px = 79
			ENDIF
			*			RESTSCREEN( ry,rx,py,px, TRANSFORM( aux, REPLICATE("X"+CHR(7),(ry-ry+1)*(px-(px-2)+1)*2) ) )
			RESTSCREEN( ry,rx,24,79, aux )
			RESTSCREEN( ry,rx,py,px, TRANSFORM( SAVESCREEN(ry,rx,py,px), REPLICATE("X"+CHR(240),(py-ry+1)*(px-rx+1)*2) ) )
			@ SCRS(py), SCRS(px) SAY "€"
			@ SCRS(py), SCRS(px) SAY ""
		ENDDO
		RESTSCREEN( ry,rx,24,79, aux )
		SETCOLOR( acolor[AA] )
		
		
	ELSEIF K == K_ALT_A
		SETCOLOR("W/N,N/W,,,+W/N,N/W" )
		MARCO( 1, 1, 4, 50, "COLORES DE EDICION", "S", .T. )
		@ 1,1 SAY "Fondo:" GET CFONDO PICT "!!!!!"
		@ 2,1 SAY "  Get:" GET CGET   PICT "!!!!!"
		@ 3,1 SAY "  Say:" GET CSAY   PICT "!!!!!"
		@ 4,1 SAY "Func.:" GET CFUNC  PICT "!!!!!"
		READ
		RECUPAN()
		aaux:={{"U/N","UW+/N","W+/N","N/W","*W/N","*W+/N" },;
			{    1,      9,    10,  112,   130,   137  }}
		i := ASCAN( aaux[1], {|a| a == ALLTRIM(CFONDO)})
		IF i > 0
			RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX),;
				TRANSFORM( SAVESCREEN(SCRS(MINY),SCRS(MINX),SCRS(MAXY),SCRS(MAXX)),;
				REPLICATE("X"+CHR(aaux[2,i]),(SCRS(MAXY)-SCRS(MINY)+1)*(SCRS(MAXX)-(SCRS(MINX)-2)+1)*2) ) )
		ENDIF
		*		SETCOLOR( CGET )
		*		FOR i=1 TO LEN(MVAR)
		*			@ SCRS(MVAR[i,SR_Y]), SCRS(MVAR[i,SR_X]) SAY MVAR[i,SR_PIC]
		*		NEXT
		*		SETCOLOR( CFUNC )
		*		FOR i=1 TO LEN(MVER)
		*			@ SCRS(MVER[i,SR_Y]), SCRS(MVER[i,SR_X]) SAY MVER[i,SR_PIC]
		*		NEXT
		DISPALL()
		SETCOLOR( acolor[AA] )
		
		
	ELSEIF K == K_ALT_R
		ADOSAR()
		
	ELSEIF K == K_F12
		GRABAR()
		
	ELSEIF K == K_F1
		SALVAPAN( 0, 0, 24, 79 )
		MEMOEDIT( MEMOREAD("AYUDA.DOC"), 0, 0, 24, 79, .F., "FOUND" )
		RECUPAN()
		
		* * *   Funciones   * * *
	ELSEIF K == K_F9
		ym4 = 2
		xm4 = 1
		modo = IF( LEN(MVER)==0, K_F5, 0 )
		ateclas = "k=-1.OR.k=-4.OR.K=-5.OR.K==32"
		salir = .F.
		SETCOLOR("W/N,N/W")
		ym44 = ym4 + LEN(MVER) + 1
		ym44 = IF( ym44+2>21, 21, ym44 )
		MARCO( 1, 1, 20, 75, "CAMPOS", "S", .T. )
		DO WHILE !salir
			aaux := ARRAY( LEN(MVER) )
			AEVAL( MVER, {|a,i| aaux[i] := LEFT(a[SR_NOMBRE]+SPACE(25),25) })
			SETCOLOR("W/N,N/W,,,W/N,N/W")
			@ 1, 1 CLEAR TO 20, 75
			ele = ACHOICE( 1, 1, 20, 75, aaux, .T., "achfunc", mele, (mele) )
			SETCOLOR("N/W,W/N")
			IF modo == K_F2							&& Modifica
				mele := ele
				picaux := rpic := MVER[ele,SR_PIC]
				nomaux := MVER[ele,SR_NOMBRE]
				MARCO( 9, 1, 9, 75, "", "S", .T. )
				DO WHILE .T.
					nomaux = LEFT( nomaux+SPACE(150), 150 )
					nomaux := FGET( 9, 1, nomaux, "@S75", "nK==9" )
					IF LASTKEY() == K_TAB .AND. NBASE != 0
						anom = "anom" + STR(NBASE,1)
						amasc = "amasc" + STR(NBASE,1)
						SETCOLOR( "+W/N,N/W" )
						op = PP_SELEC( 1, 1, 0, 60, &anom, AELE[NBASE], ABASE[NBASE], "S", .T. )
						RECUPAN()
						IF LASTKEY() == K_ENTER
							nomaux := AALIAS[NBASE] +"->"+ LEFT(&anom[op],10)
							picaux := IF( EMPTY(&(amasc)[op]), "X", &(amasc)[op] )
						ENDIF
					ELSEIF LASTKEY() == K_ENTER
						MARCO( 11, 1, 11, 75, " MASCARA ", "S", .T. )
						picaux := LEFT(picaux+SPACE(75),75)
						picaux := FGET( 11, 1, picaux, "@S75" )
						IF LASTKEY() == K_ENTER
							picaux := IF( EMPTY(picaux), 'X', ALLTRIM(picaux) )
							MVER[ele,SR_NOMBRE] = ALLTRIM(nomaux)
							MVER[ele,SR_DBF] = IF( ASCAN(aaux,MVER[ele,SR_NOMBRE])==0 .OR. NBASE==0, "", AALIAS[NBASE] )
							MVER[ele,SR_PIC] = picaux
							IF MVER[ele,SR_Y] != 0
								AVER[MVER[ele,SR_Y]] = STUFF( AVER[MVER[ele,SR_Y]], MVER[ele,SR_X], LEN(rpic), REPLIC('',LEN(rpic)) )
								AVER[MVER[ele,SR_Y]] = STUFF( AVER[MVER[ele,SR_Y]], MVER[ele,SR_X], LEN(MVER[ele,SR_PIC]), REPLIC(CHR(ele+1),LEN(MVER[ele,SR_PIC])) )
							ENDIF
						ENDIF
						RECUPAN()
						EXIT
					ELSEIF LASTKEY() == K_ESC
						EXIT
					ENDIF
				ENDDO
				RECUPAN()
			ELSEIF modo == K_F5
				picaux = SPACE(75)
				nomaux = SPACE(150)
				MARCO( 9, 1, 9, 75, "", "S", .T. )
				DO WHILE .T.
					nomaux = LEFT( nomaux+SPACE(150), 150 )
					nomaux := FGET( 9, 1, nomaux, "@S75", "nK==9" )
					READ
					SET KEY K_TAB TO
					IF LASTKEY() == K_TAB .AND. NBASE != 0
						anom = "anom" + STR(NBASE,1)
						amasc = "amasc" + STR(NBASE,1)
						SETCOLOR( "+W/N,N/W" )
						op = PP_SELEC( 1, 1, 0, 60, &anom, AELE[NBASE], ABASE[NBASE], "S", .T. )
						RECUPAN()
						IF LASTKEY() == K_ENTER
							nomaux := AALIAS[NBASE] +"->"+ LEFT(&anom[op],10)
							picaux := IF( EMPTY(&(amasc)[op]), "X", &(amasc)[op] )
						ENDIF
					ELSEIF LASTKEY() == K_ENTER
						MARCO( 11, 1, 11, 75, " MASCARA ", "S", .T. )
						picaux := LEFT(picaux+SPACE(75),75)
						picaux := FGET( 11, 1, picaux, "@S75" )
						IF LASTKEY() == K_ENTER
							AADD( MVER, ARRAY(SR_X) )
							mele := LEN(MVER)
							picaux := IF( EMPTY(picaux), 'X', ALLTRIM(picaux) )
							MVER[LEN(MVER),SR_NOMBRE] = ALLTRIM(nomaux)
							MVER[LEN(MVER),SR_DBF] = IF( ASCAN(aaux,MVER[LEN(MVER),SR_NOMBRE])==0.OR.NBASE==0, "", AALIAS[NBASE] )
							MVER[LEN(MVER),SR_PIC] = picaux
							MVER[LEN(MVER),SR_X] := 0
							MVER[LEN(MVER),SR_Y] := 0
							MVER[LEN(MVER),SR_EDIT] := 'M'
						ENDIF
						RECUPAN()
						EXIT
					ELSEIF LASTKEY() == K_ESC
						EXIT
					ENDIF
				ENDDO
				RECUPAN()
				IF LEN(MVER) == 0
					salir := .T.
				ENDIF
			ELSEIF modo == K_F6
				IF MVER[ele,SR_Y] > 0
					IF PREGUNTA( 10, "ESTA SEGURO   [ S / N ] ? ", "SsNn" ) $ "Ss"
						AVER[MVER[ele,SR_Y]] = STUFF( AVER[MVER[ele,SR_Y]], MVER[ele,SR_X], LEN(MVER[ele,SR_PIC]), REPLIC("",LEN(MVER[ele,SR_PIC])) )
						MVER[ele,SR_PIC] := MVER[ele,SR_DBF] := MVER[ele,SR_EDIT] := ''
						MVER[ele,SR_Y] := MVER[ele,SR_X] := 0
						mele := ele - 1
					ENDIF
				ELSE
					TONE(100,1)
				ENDIF
			ELSEIF modo == K_ENTER .AND. MVER[ele,SR_Y] == 0
				IF ENTRA( py, px, MVER[ele,SR_PIC], CHR(ele+1) )
					mele := ele
					MVER[ele,SR_X] = px
					MVER[ele,SR_Y] = py
					LI[py] = STUFF( LI[py], px, LEN(MVER[ele,SR_PIC]), MVER[ele,SR_PIC] )
					AVER[py] = STUFF( AVER[py], px, LEN(MVER[ele,SR_PIC]), REPLIC(CHR(ele+1),LEN(MVER[ele,SR_PIC])) )
					salir = .T.
				ENDIF
			ELSEIF modo == K_ESC
				salir = .T.
			ENDIF
			modo = 0
		ENDDO
		RECUPAN()
		DISPALL()
		SETCOLOR( acolor[AA] )
		
		
		* * *   Campos   * * *
	ELSEIF K == K_F7
	 	aaux2 := FAARCH("TEC.SEQ","CARGAR")
		ym4   := 2
		xm4   := 1
		modo  := IF( LEN(MVAR)==0, K_F5, 0 )
		ateclas := "CHR(K)$'VvTt'"
		salir   := .F.
		SETCOLOR("W/N,N/W")
		ym44 := ym4 + LEN(MVAR) + 1
		ym44 := IF( ym44+2>21, 21, ym44 )
		MARCO( 1, 1, 20, 75, "CAMPOS", "S", .T. )
		DO WHILE !salir
			aaux := ARRAY( LEN(MVAR) )
			AEVAL( MVAR, {|a,i| aaux[i] := LEFT(a[SR_NOMBRE]+SPACE(25),25)     +;
				"("+ LEFT(a[SR_DBF]+SPACE(5),5) +")"                            +;
				"["+ a[SR_EDIT] +"]" 												       +;
 				"{"+ IF(a[SR_TAB]==NIL," ","T") +"}"                            +;
 				"("+ IF(EMPTY(MVAR[i,SR_VAL])," ","V") +")"                     })
			SETCOLOR("W/N,N/W,,,W/N,N/W")
			@ 1, 1 CLEAR TO 20, 75
			ele = ACHOICE( 1, 1, 20, 75, aaux, .T., "achfunc", mele, (mele) )
			SETCOLOR("N/W,W/N")
			IF CHR(modo) $ "Vv"

			ELSEIF CHR(modo) $ "Tt"
        	IF MVAR[ele,SR_TAB]==NIL
           	_btecla := SPACE(50)
           	_bfunc  := SPACE(50)
        	ELSE
           	_btecla := LEFT( _btecla+SPACE(50), 50 )
           	_bfunc  := LEFT( _bfunc+SPACE(50), 50 )
				ENDIF
           SETCOLOR("W+/N,N/W,,,W/N")
				MARCO( 1, 1, 2, 70, "CODE BLOCK ASOCIADO", "S", .T. )
           DO WHILE .T.
           	SET KEY K_TAB TO CLEAR_GETS()
           	SET KEY K_F10 TO CLEAR_GETS()
           	SET(_SET_CURSOR,SC_ON)
					@ 1,1 SAY "  Tecla:" GET _btecla
					@ 2,1 SAY "Funci¢n:" GET _bfunc
           	READ
           	SET KEY K_TAB TO
           	SET KEY K_F10 TO
              IF LASTKEY() == K_TAB
						op := PP_SELEC( 1, 10, 0, 0, aaux2, 1, "", "S", .T. )
                 IF LASTKEY()==K_ENTER
                 	_bfunc := aaux2[op]
                 ENDIF
                 RECUPAN()
              ELSEIF LASTKEY() == K_F10 .OR. LASTKEY()==K_ESC
              	EXIT
              ENDIF
           ENDDO
           RECUPAN()
           IF LASTKEY()==K_ESC
           	IF EMPTY(_btecla+_bfunc)
           		MVAR[ele,SR_TAB] := NIL
           	ELSE
           		MVAR[ele,SR_TAB] := { _btecla, _bfunc }
           	ENDIF
           ENDIF
			ELSEIF modo == K_ESC
				salir = .T.
			ENDIF
			modo = 0
		ENDDO
		RECUPAN()
		DISPALL()
		SETCOLOR( acolor[AA] )
		
		
		* * *   Campos   * * *
	ELSEIF K == K_F10
		ym4 = 2
		xm4 = 1
		modo = IF( LEN(MVAR)==0, K_F5, 0 )
		ateclas = "k=-1.OR.k=-4.OR.K=-5.OR.K==32"
		salir = .F.
		SETCOLOR("W/N,N/W")
		ym44 = ym4 + LEN(MVAR) + 1
		ym44 = IF( ym44+2>21, 21, ym44 )
		MARCO( 1, 1, 20, 75, "CAMPOS", "S", .T. )
		DO WHILE !salir
			aaux := ARRAY( LEN(MVAR) )
			AEVAL( MVAR, {|a,i| aaux[i] := LEFT(a[SR_NOMBRE]+SPACE(25),25)+;
				"("+ LEFT(a[SR_DBF]+SPACE(5),5) +")"+		;
				"["+ a[SR_EDIT] +"]" } )
			SETCOLOR("W/N,N/W,,,W/N,N/W")
			@ 1, 1 CLEAR TO 20, 75
			ele = ACHOICE( 1, 1, 20, 75, aaux, .T., "achfunc", mele, (mele) )
			SETCOLOR("N/W,W/N")
			IF modo == K_F2							&& Modifica
				mele := ele
				dbfaux := MVAR[ele,SR_DBF]
				picaux := rpic := MVAR[ele,SR_PIC]
				nomaux := MVAR[ele,SR_NOMBRE]
				MARCO( 9, 1, 9, 75, "", "S", .T. )
				DO WHILE .T.
					nomaux = LEFT( nomaux+SPACE(150), 150 )
					nomaux := FGET( 9, 1, nomaux, "@S75", "nK==9" )
					IF LASTKEY() == K_TAB .AND. NBASE != 0
						anom = "anom" + STR(NBASE,1)
						amasc = "amasc" + STR(NBASE,1)
						SETCOLOR( "+W/N,N/W" )
						op = PP_SELEC( 1, 1, 0, 60, &anom, AELE[NBASE], ABASE[NBASE], "S", .T. )
						RECUPAN()
						IF LASTKEY() == K_ENTER
							nomaux := LEFT(&anom[op],10)
							picaux := IF( EMPTY(&(amasc)[op]), "X", &(amasc)[op] )
							dbfaux := AALIAS[NBASE]
							AELE[NBASE] := op
						ENDIF
					ELSEIF LASTKEY() == K_ENTER
						MARCO( 11, 1, 11, 75, " MASCARA ", "S", .T. )
						picaux := LEFT(picaux+SPACE(75),75)
						picaux := FGET( 11, 1, picaux, "@S75" )
						IF LASTKEY() == K_ENTER
							picaux := IF( EMPTY(picaux), 'X', ALLTRIM(picaux) )
							MVAR[ele,SR_NOMBRE] = ALLTRIM(nomaux)
							MVAR[ele,SR_DBF] = IF( ASCAN(aaux,MVAR[ele,SR_NOMBRE])==0 .OR. NBASE==0, "", AALIAS[NBASE] )
							MVAR[ele,SR_PIC] = picaux
							aux := SUBSTR(picaux,AT(" ",picaux)+1)
							IF MVAR[ele,SR_Y] != 0
								ACAMPO[MVAR[ele,SR_Y]] = STUFF( ACAMPO[MVAR[ele,SR_Y]], MVAR[ele,SR_X], LEN(rpic), REPLIC('',LEN(rpic)) )
								*								ACAMPO[MVAR[ele,SR_Y]] = STUFF( ACAMPO[MVAR[ele,SR_Y]], MVAR[ele,SR_X], LEN(MVAR[ele,SR_PIC]), REPLIC(CHR(ele+1),LEN(MVAR[ele,SR_PIC])) )
								ACAMPO[MVAR[ele,SR_Y]] = STUFF( ACAMPO[MVAR[ele,SR_Y]], MVAR[ele,SR_X], LEN(aux), REPLIC(CHR(ele+1),LEN(aux)) )
							ENDIF
						ENDIF
						RECUPAN()
						EXIT
					ELSEIF LASTKEY() == K_ESC
						EXIT
					ENDIF
				ENDDO
				RECUPAN()
			ELSEIF modo == K_F5
				dbfaux = IF(NBASE==0,"",AALIAS[NBASE])
				picaux = SPACE(75)
				nomaux = SPACE(150)
				MARCO( 9, 1, 9, 75, "", "S", .T. )
				DO WHILE .T.
					nomaux = LEFT( nomaux+SPACE(150), 150 )
					nomaux := FGET( 9, 1, nomaux, "@S75", "nK==9" )
					SET KEY K_TAB TO
					IF LASTKEY() == K_TAB .AND. NBASE != 0
						anom = "anom" + STR(NBASE,1)
						amasc = "amasc" + STR(NBASE,1)
						SETCOLOR( "+W/N,N/W" )
						op = PP_SELEC( 1, 1, 0, 60, &anom, AELE[NBASE], ABASE[NBASE], "S", .T. )
						RECUPAN()
						IF LASTKEY() == K_ENTER
							nomaux := LEFT(&anom[op],10)
							picaux := IF( EMPTY(&(amasc)[op]), "X", &(amasc)[op] )
							dbfaux := AALIAS[NBASE]
							AELE[NBASE] := op
						ENDIF
					ELSEIF LASTKEY() == K_ENTER
						MARCO( 11, 1, 11, 75, " MASCARA ", "S", .T. )
						picaux := LEFT(picaux+SPACE(75),75)
						picaux := FGET( 11, 1, picaux, "@S75" )
						IF LASTKEY() == K_ENTER
							AADD( MVAR, ARRAY(SR_VAL) )
							mele := LEN(MVAR)
							picaux := IF( EMPTY(picaux), 'X', ALLTRIM(picaux) )
							MVAR[LEN(MVAR),SR_NOMBRE] = ALLTRIM(nomaux)
							MVAR[LEN(MVAR),SR_DBF] = IF( ASCAN(aaux,MVAR[LEN(MVAR),SR_NOMBRE])==0.OR.NBASE==0, "", AALIAS[NBASE] )
							MVAR[LEN(MVAR),SR_PIC] = picaux
							MVAR[LEN(MVAR),SR_X] := 0
							MVAR[LEN(MVAR),SR_Y] := 0
							MVAR[LEN(MVAR),SR_EDIT] := 'M'
						ENDIF
						RECUPAN()
						EXIT
					ELSEIF LASTKEY() == K_ESC
						EXIT
					ENDIF
				ENDDO
				RECUPAN()
				IF LEN(MVAR) == 0
					salir := .T.
				ENDIF
			ELSEIF modo == K_F6
				IF MVAR[ele,SR_Y] > 0
					IF PREGUNTA( 10, "ESTA SEGURO   [ S / N ] ? ", "SsNn" ) $ "Ss"
              	IF MVAR[ele,SR_EDIT] $ "Oo"
                 	FOR i=1 TO LEN(ACAMPO)
								ACAMPO[i] := STRTRAN( ACAMPO[i], CHR(ele+1), "" )
							NEXT
                 ELSE
							ACAMPO[MVAR[ele,SR_Y]] = STUFF( ACAMPO[MVAR[ele,SR_Y]], MVAR[ele,SR_X], LEN(MVAR[ele,SR_PIC]), REPLIC("",LEN(MVAR[ele,SR_PIC])) )
                 ENDIF
						MVAR[ele,SR_PIC] := MVAR[ele,SR_DBF] := MVAR[ele,SR_EDIT] := ''
						MVAR[ele,SR_Y] := MVAR[ele,SR_X] := 0
						mele := ele - 1
					ENDIF
				ELSE
					TONE(100,1)
				ENDIF
			ELSEIF modo == 32
				mele := ele
           aux  := AT( MVAR[mele,SR_EDIT], "MmEeFf" ) + 1
           aux  := IF( aux>6, 1, aux )
				MVAR[mele,SR_EDIT] := SUBSTR( "MmEeFf", aux, 1 )
			ELSEIF CHR(modo) $ "Oo"
				RECUPAN()
				mele := ele
				*****<<<<<
				
				RESTSCREEN( YY, 0, YY, 79, menuaux )
				SETCURSOR( SC_OFF )
				aux := SAVESCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX) )
				i:=1
				y1 := y2 := py
				x1 := x2 := px
				DO WHILE .T.
					K := INKEY(.3)
					IF K == K_UP
						y2 -= IF( y2-1<y1, 0, 1 )
					ELSEIF K == K_DOWN
						y2 += IF( y2+1>MAXY, 0, 1 )
					ELSEIF K == K_LEFT
						x2 -= IF( x2-1<x1, 0, 1 )
					ELSEIF K == K_RIGHT
						x2 += IF( x2+1>MAXX, 0, 1 )
					ELSEIF K == K_ESC
						RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
						EXIT
					ELSEIF K == K_ENTER
						r := .T.
						FOR i=y1 TO y2
							IF x2+1 < MAXX
								IF SUBSTR(ACAMPO[i],x2+1,1) # '' .OR. SUBSTR(AVER[i],x2+1,1) # ''
									TONE(100,1)
									r := .F.
									EXIT
								ENDIF
							ENDIF
						NEXT
						IF r
							RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
							MVAR[mele,SR_EDIT] := "O"
							MVAR[mele,SR_PIC]  := STR(y2-y1,2) + STR(x2-x1+1,2)
							FOR i=y1 TO y2
								ACAMPO[i] := STUFF( ACAMPO[i], x1, x2-x1+1, REPLIC(CHR(ele+1),x2-x1+1) )
							NEXT
							DISPALL()
							manuaux := SAVESCREEN( YY, 0, YY, 79 )
							EXIT
						ENDIF
					ENDIF
					RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), aux )
					aux2 := SAVESCREEN( SCRS(y1), SCRS(x1), SCRS(y2), SCRS(x2) )
					RESTSCREEN( SCRS(y1), SCRS(x1), SCRS(y2), SCRS(x2),;
						TRANSFORM( aux2, REPLICATE("X"+CHR(130),(SCRS(y2)-SCRS(y1)+1)*(SCRS(x2)-(SCRS(x1)-2)+1)*2) ) )
					@ SCRS(y2), SCRS(x2) SAY SUBSTR(""+CHR(26)+""+CHR(27),EVAL({||i:=IF(i+1>4,i:=0,i),++i}),1)
				ENDDO
				MARCO( 1, 1, 20, 75, "CAMPOS", "S", .T. )
				
			ELSEIF modo == K_ENTER .AND. MVAR[ele,SR_Y] == 0
				IF ENTRA( py, px, MVAR[ele,SR_PIC], CHR(ele+1) )
					mele := ele
					MVAR[ele,SR_X] = px
					MVAR[ele,SR_Y] = py
					LI[py] = STUFF( LI[py], px, LEN(MVAR[ele,SR_PIC]), MVAR[ele,SR_PIC] )
					ACAMPO[py] = STUFF( ACAMPO[py], px, LEN(MVAR[ele,SR_PIC]), REPLIC(CHR(ele+1),LEN(MVAR[ele,SR_PIC])) )
					salir = .T.
				ENDIF
			ELSEIF modo == K_ESC
				salir = .T.
			ENDIF
			modo = 0
		ENDDO
		RECUPAN()
		DISPALL()
		SETCOLOR( acolor[AA] )
		
		
	ELSEIF K == K_ALT_E
		IF LEN(ABASE) # 0
			SETCOLOR( "+W/N,N/W" )
			op = PP_SELEC( 1, 1, LEN(ABASE), 0, ABASE, 1, "EN USO", "S", .T. )
			IF LASTKEY() == 13
				NBASE = op
				KEYBOARD CHR(K_F10)
			ENDIF
			RECUPAN()
		ENDIF
		
	ELSEIF K == K_INS
		INSTOGGLE()
		
	ELSEIF K == 0
		IF SECONDS() - tiempo1 > tiempo
			GRABAR("zzz")
		ENDIF
		
	ELSE
		IF ( SUBSTR(ACAMPO[py],px,1) # "" .OR. SUBSTR(AVER[py],px,1) # "" ) 		&&.AND. !READINSERT()
			TONE(100,1)
		ELSE
			SETCOLOR( acolor[AA] )
			IF READINSERT()
				IF SUBSTR(ACAMPO[py],MAXX,1)=="" .AND. SUBSTR(AVER[py],MAXX,1)==""
					LI[py] = LEFT( STUFF( LI[py], px, 0, CHR(K) ), 80 )
					ACAMPO[py] = LEFT( STUFF( ACAMPO[py], px, 0, '' ), 80 )
					AVER[py] = LEFT( STUFF( AVER[py], px, 0, '' ), 80 )
					RESTSCREEN( SCRS(py), SCRS(px)+1, SCRS(py), SCRS(MAXX), SAVESCREEN( SCRS(py), SCRS(px), SCRS(py), SCRS(MAXX)-1 ) )
					i := ASCAN( MVAR, {|a| a[SR_Y]==py} )
					DO WHILE i > 0
						IF MVAR[i,SR_X] >= px
							++MVAR[i,SR_X]
						ENDIF
						i := ASCAN( MVAR, {|a| a[SR_Y]==py}, i+1 )
					ENDDO
					i := ASCAN( MVER, {|a| a[SR_Y]==py} )
					DO WHILE i > 0
						IF MVER[i,SR_X] >= px
							++MVER[i,SR_X]
						ENDIF
						i := ASCAN( MVER, {|a| a[SR_Y]==py}, i+1 )
					ENDDO
					@ SCRS(py), SCRS(px) SAY CHR(K)
					++px
				ELSE
					TONE( 100, 1 )
				ENDIF
			ELSE
				LI[py] = STUFF( LI[py], px, 1, CHR(K) )
				ACAMPO[py] = STUFF( ACAMPO[py], px, 1, '' )
				AVER[py] = STUFF( AVER[py], px, 1, '' )
				@ SCRS(py), SCRS(px) SAY SUBSTR( LI[py], px, 1 )
				++px
			ENDIF
		ENDIF
	ENDIF
	IF py < MINY
		py = MINY
	ELSEIF py > MAXY
		py = MAXY
	ENDIF
	IF px < MINX
		px = MINX
	ELSEIF px > MAXX
		px = MAXX
	ENDIF
ENDDO

QUIT


************

FUNC FSTATUS

************
PRIVATE i

IF py == 25 .AND. YY == 24
	YY = 0
	RESTSCREEN( 24, 0, 24, 79, menuaux )
	menuaux = SAVESCREEN( 0, 0, 0, 79 )
ELSEIF py == 1 .AND. YY == 0
	YY = 24
	RESTSCREEN( 0, 0, 0, 79, menuaux )
	menuaux = SAVESCREEN( 24, 0, 24, 79 )
ENDIF
SETCOLOR("N/W")
@ YY,0 SAY "f:## c:##                                                                       "
@ YY,2 SAY SCRS(py) PICT "##"
@ YY,7 SAY SCRS(px) PICT "##"
IF SUBSTR( ACAMPO[py], px, 1 ) # ''
	i := ASC(SUBSTR(ACAMPO[py],px,1))-1
	@ YY, 10 SAY "Cmpo["+MVAR[i,SR_EDIT]+"]" + IF( EMPTY(MVAR[i,SR_DBF]), "", MVAR[i,SR_DBF]+"->" )
	?? MVAR[i,SR_NOMBRE]
ELSEIF SUBSTR( AVER[py], px, 1 ) # ''
	i = ASC(SUBSTR(AVER[py],px,1))-1
	@ YY, 10 SAY "Func:" + MVER[i,SR_NOMBRE]
ELSE
	@ YY, 10 SAY SPACE(60)
ENDIF
@ YY,76 SAY IF(READINSERT(),"INS","   ")

RETURN .T.


************

FUNC FGROSOR

************
PARAMETERS cual
PRIVATE r

IF TYPE(cual) == "C"
	r = LEN(cual)
ELSEIF TYPE(cual) == "N"
	r = LEN(STR(cual))
ELSEIF TYPE(cual) == "D"
	r = 8
ELSEIF TYPE(cual) == "L"
	r = 1
ELSE
	r = 10
ENDIF

RETURN r


**********

FUNC FMASC

**********
PARAMETERS cual
PRIVATE r

IF TYPE(cual) == "C"
	r = REPLICATE( "", LEN(cual) )
ELSEIF TYPE(cual) == "N"
	r = REPLICATE( "", LEN(STR(cual)) )
	IF "." $ STR(&cual)
		r = STUFF( r, AT(".",STR(&cual)), 1, "." )
	ENDIF
ELSEIF TYPE(cual) == "D"
	r = ""
ELSEIF TYPE(cual) == "L"
	r = ""
ELSE
	r = ""
ENDIF

RETURN r


**********

FUNC FBASE

**********
PARAMETERS cualbase, cualalias, cargo
PRIVATE r
cargo = IF(PCOUNT()>2, cargo, .T. )

cualalias = ALLTRIM(cualalias)
NBASE := ASCAN( AALIAS, cualalias )
IF NBASE == 0
	AADD( ABASE,  '' )
	AADD( AALIAS, '' )
	AADD( AELE, 1 )
	NBASE := LEN( ABASE )
ENDIF
ABASE[NBASE]  := cualbase
AALIAS[NBASE] := cualalias
anom = "anom" + STR(NBASE,1)
atipo = "atipo" + STR(NBASE,1)
aancho = "aancho" + STR(NBASE,1)
adec = "adec" + STR(NBASE,1)
amasc = "amasc" + STR(NBASE,1)
IF cargo
	IF FILE( ABASE[NBASE] )
		ABRIR_BASE( ABASE[NBASE], AALIAS[NBASE] )
		PUBLIC &anom[FCOUNT()], &atipo[FCOUNT()], &aancho[FCOUNT()], &adec[FCOUNT()], &amasc[FCOUNT()]
		AFIELDS( &anom, &atipo, &aancho, &adec )
		FOR i=1 TO FCOUNT()
			IF &atipo[i] == "C"
				&amasc[i] = REPLICATE( "X", &aancho[i] )
			ELSEIF &atipo[i] == "N"
				&amasc[i] = REPLICATE( "9", &aancho[i] )
				IF &adec[i] # 0
					&amasc[i] = STUFF( &amasc[i], &aancho[i]-&adec[i], 1, "." )
				ENDIF
			ELSEIF &atipo[i] == "D"
				&amasc[i] = "99/99/99"
			ELSEIF &atipo[i] == "L"
				&amasc[i] = "L"
			ELSE
				&amasc[i] = "M"
			ENDIF
			*		&anom[i] = LEFT(AALIAS[1] +"->"+ &anom[i]+SPACE(20),15) +"≥"+ &atipo[i] +"≥"+ &amasc[i]
			&anom[i] = LEFT(&anom[i]+SPACE(10),10) +"≥"+ &atipo[i] +"≥"+ &amasc[i]
		NEXT i
		*FOR i=1 TO FCOUNT()
		*  MPIC[LEN(MVAR)] = REPLICATE( CHR(AT(atipo[i],"CNDLM")), aancho[i] )
		*	MVAR[i] = LEFT(AALIAS[1] +"->"+ anom[i]+SPACE(20),15) +"≥"+ atipo[i] +"≥"+ MPIC[i]
		*	MVAR[i] = AALIAS[1] +"->"+ anom[i] +"≥"+ atipo[i] +"≥"+ MPIC[i]
		*NEXT i
	ENDIF
ENDIF

RETURN NBASE


******************************

FUNC ENTRA( y, x, masc, cual )

******************************
PRIVATE r, i

r = .T.
FOR i=1 TO LEN(masc)
	IF !SUBSTR(ACAMPO[y],x,1)$""+cual .OR. !SUBSTR(AVER[y],x,1)$""+cual
		MENSAJE( 0, 0, 10, .T., "NO ENTRA   !!!", "CORRETE O ACHICA LA MASCARA" )
		r = .F.
		EXIT
	ENDIF
NEXT

RETURN r


***********

FUNC GRABAR( _narch )

***********
LOCAL MVARG, xcolor
LOCAL MVERG

AEVAL( MVAR, {|a,i| MVAR[i,SR_EDIT]:=IF(a[SR_EDIT]==NIL.OR.a[SR_EDIT]=="","M",a[SR_EDIT]) } )

MVARG := ACLONE(MVAR)
MVERG := ACLONE(MVER)
PRIVATE r, i

r = .F.
IF _narch == NIL
	cNOMARCH = LEFT(cNOMARCH+SPACE(8), 8 )
	cNOMARCH = INGRVAL(10, 30, "NOMBRE:", (cNOMARCH), "!!!!!!!!")
	K := LASTKEY()
	_narch := cNOMARCH
ELSE
	K := K_ENTER
ENDIF
IF K == K_ENTER
	IF FILE( cNOMARCH+".SCR" ) .AND. _narch==cNOMARCH
		COPY FILE &(cNOMARCH+".SCR") TO &(cNOMARCH+".RES")
	ENDIF
	
	pos = 0
	
	* * *   Ordena los Campos  * * *
	aux := .T.
	DO WHILE aux
		aux = .F.
		FOR i=1 TO LEN(MVAR)-1
			IF CHR(MVARG[i,SR_Y])+CHR(MVARG[i,SR_X]) > CHR(MVARG[i+1,SR_Y])+CHR(MVARG[i+1,SR_X])
				EVAL( {|i| x:=MVARG[i,SR_X], MVARG[i,SR_X]:=MVARG[i+1,SR_X], MVARG[i+1,SR_X]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_Y], MVARG[i,SR_Y]:=MVARG[i+1,SR_Y], MVARG[i+1,SR_Y]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_NOMBRE], MVARG[i,SR_NOMBRE]:=MVARG[i+1,SR_NOMBRE], MVARG[i+1,SR_NOMBRE]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_PIC], MVARG[i,SR_PIC]:=MVARG[i+1,SR_PIC], MVARG[i+1,SR_PIC]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_EDIT], MVARG[i,SR_EDIT]:=MVARG[i+1,SR_EDIT], MVARG[i+1,SR_EDIT]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_DBF], MVARG[i,SR_DBF]:=MVARG[i+1,SR_DBF], MVARG[i+1,SR_DBF]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_TAB], MVARG[i,SR_TAB]:=MVARG[i+1,SR_TAB], MVARG[i+1,SR_TAB]:=x}, i )
				EVAL( {|i| x:=MVARG[i,SR_VAL], MVARG[i,SR_VAL]:=MVARG[i+1,SR_VAL], MVARG[i+1,SR_VAL]:=x}, i )
				aux = .T.
			ENDIF
		NEXT
	ENDDO
	
	* * *   Ordena las Funciones   * * *
	aux := .T.
	DO WHILE aux
		aux = .F.
		FOR i=1 TO LEN(MVER)-1
			IF CHR(MVERG[i,SR_Y])+CHR(MVERG[i,SR_X]) > CHR(MVERG[i+1,SR_Y])+CHR(MVERG[i+1,SR_X])
				EVAL( {|i| x:=MVERG[i,SR_X], MVERG[i,SR_X]:=MVERG[i+1,SR_X], MVERG[i+1,SR_X]:=x}, i )
				EVAL( {|i| x:=MVERG[i,SR_Y], MVERG[i,SR_Y]:=MVERG[i+1,SR_Y], MVERG[i+1,SR_Y]:=x}, i )
				EVAL( {|i| x:=MVERG[i,SR_NOMBRE], MVERG[i,SR_NOMBRE]:=MVERG[i+1,SR_NOMBRE], MVERG[i+1,SR_NOMBRE]:=x}, i )
				EVAL( {|i| x:=MVERG[i,SR_PIC], MVERG[i,SR_PIC]:=MVERG[i+1,SR_PIC], MVERG[i+1,SR_PIC]:=x}, i )
				aux = .T.
			ENDIF
		NEXT
	ENDDO
	
	
	na = FCREATE( ALLTRIM(_narch)+".SCR", 0 )
	*** graba tama§o de la pantalla
	FSEEK( na, 0 )
	buffer = LEFT( STR(MINY,2)+STR(MINX,2)+STR(MAXY,2)+STR(MAXX,2)+"  "+CFONDO+CGET+CSAY+CFUNC + SPACE(30), 30 )
	block = 30
	bytes = FWRITE( na, buffer, block )
	pos += block
	*** graba la pantalla con sus atributos
	FSEEK( na, pos+1 )
	RESTSCREEN( YY, 0, YY, 79, menuaux )
	
	xcolor := SETCOLOR(CSAY)
	FOR i=1 TO LEN(MVAR)
		IF MVAR[i,SR_EDIT] != "O"
			@ SCRS(MVAR[i,SR_Y]), SCRS(MVAR[i,SR_X]) SAY SPACE(LEN(MVAR[i,SR_PIC])-AT(" ",MVAR[i,SR_PIC]))
		ELSE
			FOR y=SCRS(MVAR[i,SR_Y]) TO SCRS(MVAR[i,SR_Y])+VAL(SUBSTR(MVAR[i,SR_PIC],1,2))
				@ y, SCRS(MVAR[i,SR_X]) SAY SPACE( VAL(SUBSTR(MVAR[i,SR_PIC],3,2)) )
			NEXT
		ENDIF
	NEXT
	AEVAL( MVER, {|a,i| DEVPOS( SCRS(a[SR_Y]), SCRS(a[SR_X]) ), QQOUT(SPACE(LEN(a[SR_PIC]))) } )
	SETCOLOR(xcolor)
	
	buffer = SAVESCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX) )
	DISPALL()
	
	block = (MAXY-MINY+1) * (MAXX-MINX+1) * 2
	bytes = FWRITE( na, buffer, block )
	pos += block
	
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
	
	*** graba las bases usadas
	PRIVATE aaux[LEN(ABASE)]
	AFILL( aaux, 0 )
	FOR i=1 TO LEN(ABASE)
		FOR y=1 TO LEN(MVAR)
			IF ALLTRIM(AALIAS[i]) $ MVAR[y,SR_DBF]
				aaux[i] := 1
				EXIT
			ENDIF
		NEXT
	NEXT
	cantaux := 0
	AEVAL( aaux, {|a| cantaux += a} )
	FSEEK( na, pos+1 )
	bytes = FWRITE( na, STR(cantaux,2), 2 )				&& cant.de bases 2Bytes
	pos += 2
	FSEEK( na, pos+1 )
	FOR i=1 TO LEN(aaux)
		IF aaux[i] == 1
			block = 20
			*** nombre de la base 12 Bytes + alias 8 Bytes = 20 Bytes
			buffer = LEFT(ABASE[i]+SPACE(12),12) + LEFT(AALIAS[i]+SPACE(8),8)
			bytes = FWRITE( na, buffer, block )
			pos += block
		ENDIF
	NEXT i
	
	*** deja 3 Bytes para guardar la cantidad de campos
	rpos = pos + 1
	FSEEK( na, rpos )
	block = 3
	buffer = SPACE(block)
	bytes = FWRITE( na, buffer, block )
	pos += block
	
	*** graba las posiciones de los campos, lo que ocupa,
	*** el nombre del campo y la mascara
	FSEEK( na, pos+1 )
	cantaux = 0
	FOR i=1 TO LEN(MVAR)
		IF MVARG[i,SR_Y] > 0
			++cantaux
				***   y  +  x  +  ancho  +  nß campo  +  edit  +  ancho del nombre del campo  +  campo  + mascara
			cCampo := ALLTRIM( IF(EMPTY(MVARG[i,SR_DBF]),"",MVARG[i,SR_DBF]+"->")+MVARG[i,SR_NOMBRE] )
			buffer := STR(MVARG[i,SR_Y]-1,2) + STR(MVARG[i,SR_X]-1,2) +;
				STR(LEN(MVARG[i,SR_PIC]),2) + STR(i,2) + MVARG[i,SR_EDIT]+ CHR(LEN(cCampo)+32) +;
				cCampo + MVARG[i,SR_PIC]
			block = LEN(buffer)
			bytes = FWRITE( na, buffer, block )
			pos += block
		ENDIF
	NEXT
	*** graba la cantidad de campos
	FSEEK( na, rpos )
	block = 3
	buffer = STR(cantaux,block)
	bytes = FWRITE( na, buffer, block )
	
	*** deja 3 Bytes para guardar la cantidad de funciones
	rpos = pos + 1
	FSEEK( na, rpos )
	block = 3
	buffer = SPACE(block)
	bytes = FWRITE( na, buffer, block )
	pos += block
	
	*** graba las posiciones de las funciones, lo que ocupan,
	*** el nombre de las funciones y las mascaras
	FSEEK( na, pos+1 )
	cantaux = 0

  aaux:=ARRAY(LEN(MVARG),2)
  AEVAL(MVARG, {|a,i| aaux[i,1]:=ALLTRIM(a[SR_NOMBRE]), aaux[i,2]:=i} )
  ASORT( aaux,,,{|x,y| LEN(x[1]) > LEN(y[1]) } )

	FOR i=1 TO LEN(MVER)
		IF MVERG[i,SR_Y] > 0
			++cantaux
			aux = MVERG[i,SR_NOMBRE]
			FOR z=1 TO LEN(aaux)
        	n := aaux[z,2]
				aux2 := ALLTRIM(MVARG[n,SR_DBF])
				aux2 := aux2 + IF( aux2=="","","->") + ALLTRIM(MVARG[n,SR_NOMBRE])
				x := AT( aux2, aux )
				DO WHILE x > 0
					IF .NOT. UPPER(SUBSTR( aux, x+LEN(aux2), 1 )) $ "QWERTYUIOPASDFGHJKLZXCVBNM"
						aux := LEFT( aux, x-1 ) + "a["+LTRIM(STR(n,2))+"]" + SUBSTR( aux, x+LEN(aux2) )
					ENDIF
					x := SAT( aux2, aux, x+LEN(aux2) )
				ENDDO
			NEXT z
			aux = "{|a| "+ aux +"}"
			***             y               +            x           + ancho de la funcion            + ancho de func2  + largo de la mascara         + funcion            + fun2+ mascara
			buffer = STR(MVERG[i,SR_Y]-1,2) + STR(MVERG[i,SR_X]-1,2) + STR(LEN(MVERG[i,SR_NOMBRE]),2) + STR(LEN(aux),2) + STR(LEN(MVERG[i,SR_PIC]),2) + MVERG[i,SR_NOMBRE] + aux + MVERG[i,SR_PIC]
			block = LEN(buffer)
			bytes = FWRITE( na, buffer, block )
			pos += block
		ENDIF
	NEXT
	*** graba la cantidad de campos
	FSEEK( na, rpos )
	block = 3
	buffer = STR(cantaux,block)
	bytes = FWRITE( na, buffer, block )
	
	FCLOSE( na )
	tiempo1 := SECONDS()

	RECUPAN()
	r = .T.
	
ENDIF

RETURN r


*************

FUNC CARGAR(cArch)

*************
LOCAL aux := "S"

if cArch#nil
	IF !EMPTY(cNOMARCH)
		aux := PREGUNTA( 10, " Seguro  (  L E E R  )    [ S / N ] ?", "SsNn" )
	ENDIF
endif
IF aux $ "Ss"
	if cArch#nil
		DECLARE aaux[1]
		ADIR( cArch, aaux )
     op := 1
  	aux:=.T.
  else
		aux = ADIR( "*.SCR" ) + 1
		DECLARE aaux[aux]
		ADIR( "*.SCR", aaux )
		aaux[aux] = "* NUEVO *"
		ASORT( aaux )
		SETCOLOR( "+W/N,N/W" )
		op = PP_SELEC( 1, 1, 0, 0, aaux, 1, "PANTALLAS", "S", .T. )
		RECUPAN()
		aux := ( lastkey() == K_ENTER )
  endif
  if aux
		CLOSE DATABASES
		IF FILE("FUNCS.DB")
			SELECT 99
			USE FUNCS.DB ALIAS FU
		ENDIF
		AFILL( LI, SPACE(80) )
		AFILL( ACAMPO, REPLICATE("",80) )
		AFILL( AVER, REPLICATE("",80) )
		MVAR   := {}
		MVER   := {}
		AELE   := {}
		ABASE  := {}
		AALIAS := {}
		SETCOLOR( acolor[AA] )
		CLEAR SCREEN
		IF .NOT. "*" $ aaux[op]
			SETCOLOR( "W/N" )
			cNOMARCH = LEFT( aaux[op], AT(".",aaux[op])-1 )
  		cArch := cNOMARCH
			na = FOPEN(cNOMARCH+".SCR",0)
			pos = 0
			block = 30
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			MINY = VAL( SUBSTR(buffer,1,2) )
			MINX = VAL( SUBSTR(buffer,3,2) )
			MAXY = VAL( SUBSTR(buffer,5,2) )
			MAXX = VAL( SUBSTR(buffer,7,2) )
			CFONDO = SUBSTR(buffer,11,5)
			CGET   = SUBSTR(buffer,16,5)
			CSAY   = SUBSTR(buffer,21,5)
			CFUNC  = SUBSTR(buffer,26,5)
			pos += block
			FSEEK( na, ++pos )
			block = (MAXY-MINY+1) * (MAXX-MINX+1) * 2
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			pos += block
			
			SETCOLOR("W/N")
			RELLENAPAN(0,0,24,79,"≤")
			@ SCRS(MINY), SCRS(MINX) CLEAR TO SCRS(MAXY), SCRS(MAXX)
			SETCOLOR( CFONDO )
			RESTSCREEN( SCRS(MINY), SCRS(MINX), SCRS(MAXY), SCRS(MAXX), buffer )
			menuaux = SAVESCREEN( YY, 0, YY, 79 )
			
				*** carga las bases usadas
			FSEEK( na, pos )
			block = 2
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )				&& cant.de bases 2 Bytes
			cantaux = VAL(buffer)
			pos += block
			FSEEK( na, pos )
			FOR i=1 TO cantaux
				*** nombre de la base 12 Bytes + alias 8 Bytes = 20 Bytes
				block = 20
				buffer = SPACE(block)
				bytes = FREAD( na, @buffer, block )
				AADD( ABASE, LEFT(buffer,12) )
				AADD( AALIAS, ALLTRIM(SUBSTR(buffer,13)) )
				AADD( AELE, 1 )
				pos += block
				FSEEK( na, pos )
			NEXT i
			FOR i=1 TO cantaux
				FBASE( ABASE[i], (AALIAS[i]), .T. )
			NEXT i
				*** carga los campos usados con sus mascaras
			FSEEK( na, pos )
			block = 3
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			xaux := VAL(buffer)
			pos += block
			FSEEK( na, pos )
			FOR i=1 TO xaux
				block = 10
				buffer = SPACE(block)
				bytes = FREAD( na, @buffer, block )
				y1 = VAL(SUBSTR(buffer,1,2)) + 1
				x1 = VAL(SUBSTR(buffer,3,2)) + 1
				aux := SUBSTR( buffer, 9, 1 )
				nAnchoCampo := 17
				IF ASC( SUBSTR( buffer, 10, 1 ) ) > 32
					nAnchoCampo := ASC( SUBSTR( buffer, 10, 1 ) ) - 32
           ENDIF
				pos += block
				block = VAL(SUBSTR(buffer,5,2)) + nAnchoCampo
				buffer = SPACE(block)
				bytes = FREAD( na, @buffer, block )
				AADD( MVAR, ARRAY(SR_VAL) )
				MVAR[i,SR_EDIT] := IF( aux$'EeMmFfOo',aux,'M' )
				aux = AT( "->", buffer )
				IF aux == 0
					MVAR[i,SR_DBF]    := ''
					MVAR[i,SR_NOMBRE] := LEFT(buffer,nAnchoCampo)
				ELSE
					MVAR[i,SR_DBF]    := LEFT( buffer, aux-1 )
					MVAR[i,SR_NOMBRE] := SUBSTR( LEFT(buffer,nAnchoCampo), aux+2 )
				ENDIF
				MVAR[i,SR_PIC]   := SUBSTR(buffer,nAnchoCampo+1)
				IF MVAR[i,SR_EDIT] != 'O'
					ACAMPO[y1] = STUFF( ACAMPO[y1], x1, block-nAnchoCampo, REPLIC(CHR(i+1),block-nAnchoCampo) )
				ELSE
					FOR y=y1 TO y1+VAL(SUBSTR(MVAR[i,SR_PIC],1,2))
						ACAMPO[y] = STUFF( ACAMPO[y], x1, VAL(SUBSTR(MVAR[i,SR_PIC],3,2)), REPLIC(CHR(i+1),VAL(SUBSTR(MVAR[i,SR_PIC],3,2))) )
					NEXT
				ENDIF
				MVAR[i,SR_Y] = y1
				MVAR[i,SR_X] = x1
				pos += block
			NEXT i
				*** carga las funciones
			FSEEK( na, pos )
			block = 3
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			xaux = VAL(buffer)
			pos += block
			FSEEK( na, pos )
			FOR i=1 TO xaux
				block = 10
				buffer = SPACE(block)
				bytes = FREAD( na, @buffer, block )
				AADD( MVER, ARRAY(SR_X) )
				MVER[i,SR_Y] = VAL(SUBSTR(buffer,1,2)) + 1
				MVER[i,SR_X] = VAL(SUBSTR(buffer,3,2)) + 1
				f1 = VAL(SUBSTR(buffer,5,2))
				f2 = VAL(SUBSTR(buffer,7,2))
				mm = VAL(SUBSTR(buffer,9,2))
				pos += block
				block = f1 + f2 + mm
				buffer = SPACE(block)
				bytes = FREAD( na, @buffer, block )
				MVER[i,SR_NOMBRE] = LEFT( buffer, f1 )
				MVER[i,SR_PIC] = SUBSTR(buffer,f1+f2+1)
				AVER[MVER[i,SR_Y]] = STUFF( AVER[MVER[i,SR_Y]], MVER[i,SR_X], LEN(MVER[i,SR_PIC]), REPLIC(CHR(i+1),LEN(MVER[i,SR_PIC])) )
				pos += block
			NEXT i
			FCLOSE( na )
			DISPALL()
		ELSE
			FSTATUS()
			menuaux = SAVESCREEN( YY, 0, YY, 79 )
		ENDIF
	ENDIF
	tiempo1 := SECONDS()
ENDIF

RETURN .T.


**************
FUNC DISPALL()
**************
LOCAL xcolor := SETCOLOR(CGET)
FOR i=1 TO LEN(MVAR)
	IF MVAR[i,SR_EDIT] $ "Oo"
		FOR y=SCRS(MVAR[i,SR_Y]) TO SCRS(MVAR[i,SR_Y])+VAL(SUBSTR(MVAR[i,SR_PIC],1,2))
			@ y, SCRS(MVAR[i,SR_X]) SAY REPLIC( "M", VAL(SUBSTR(MVAR[i,SR_PIC],3,2)) )
		NEXT
	ELSE
		@ SCRS(MVAR[i,SR_Y]), SCRS(MVAR[i,SR_X]) SAY SUBSTR( MVAR[i,SR_PIC], AT(" ",MVAR[i,SR_PIC])+1 )
	ENDIF
NEXT
xcolor := SETCOLOR(CFUNC)
AEVAL( MVER, {|a,i| DEVPOS( SCRS(a[SR_Y]), SCRS(a[SR_X]) ), QQOUT(a[SR_PIC]) } )
SETCOLOR(xcolor)

RETURN .T.


***********************
FUNC SAT( s1, s2, dde )
***********************
LOCAL r

r := AT( s1, SUBSTR(s2,dde) )
IF r != 0
	r := r + dde - 1
ENDIF

RETURN r


*************

FUNC ADOSAR()

*************
aux = ADIR( "*.SCR" )
DECLARE aaux[aux]
ADIR( "*.SCR", aaux )
SETCOLOR( "+W/N,N/W" )
op = PP_SELEC( 1, 1, 0, 0, aaux, 1, "PANTALLAS", "S", .T. )
RECUPAN()
IF LASTKEY() == K_ENTER
	IF op < aux
		SETCOLOR( "W/N" )
		cNOMARCH = LEFT( aaux[op], AT(".",aaux[op])-1 )
		na = FOPEN(cNOMARCH+".SCR",0)
		pos = 0
		block = 30
		buffer = SPACE(block)
		bytes = FREAD( na, @buffer, block )
		miY = VAL( SUBSTR(buffer,1,2) )
		miX = VAL( SUBSTR(buffer,3,2) )
		dy := py - miy
		dx := px - mix
		dm := LEN(MVAR)
		dv := LEN(MVER)
		maY = VAL( SUBSTR(buffer,5,2) ) + dy
		maX = VAL( SUBSTR(buffer,7,2) ) + dx
		miY = py
		miX = px
		pos += block
		FSEEK( na, ++pos )
		block = (maY-miY+1) * (maX-miX+1) * 2
		buffer = SPACE(block)
		bytes = FREAD( na, @buffer, block )
		pos += block
		
		RESTSCREEN( SCRS(miY), SCRS(miX), SCRS(maY), SCRS(maX), buffer )
		menuaux = SAVESCREEN( YY, 0, YY, 79 )
		
		*** carga las bases usadas
		FSEEK( na, pos )
		block = 2
		buffer = SPACE(block)
		bytes = FREAD( na, @buffer, block )				&& cant.de bases 2 Bytes
		cantaux = VAL(buffer)
		pos += block
		FSEEK( na, pos )
		aux := LEN(ABASE)
		FOR i=1 TO cantaux
			*** nombre de la base 12 Bytes + alias 8 Bytes = 20 Bytes
			block = 20
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			IF ASCAN( ABASE, LEFT(buffer,12) ) == 0
				AADD( ABASE, LEFT(buffer,12) )
				AADD( AALIAS, ALLTRIM(SUBSTR(buffer,13)) )
				AADD( AELE, 1 )
			ENDIF
			pos += block
			FSEEK( na, pos )
		NEXT i
		FOR i=1 TO cantaux
			FBASE( ABASE[aux+i], (AALIAS[aux+i]), .T. )
		NEXT i
		*** carga los campos usados con sus mascaras
		FSEEK( na, pos )
		block = 3
		buffer = SPACE(block)
		bytes = FREAD( na, @buffer, block )
		xaux := VAL(buffer)
		pos += block
		FSEEK( na, pos )
		FOR i=1 TO xaux
			block = 10
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			y1 = VAL(SUBSTR(buffer,1,2)) + dy + 1
			x1 = VAL(SUBSTR(buffer,3,2)) + dx + 1
			aux := SUBSTR( buffer, 9, 1 )
			pos += block
			block = VAL(SUBSTR(buffer,5,2)) + nAnchoCampo
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			AADD( MVAR, ARRAY(SR_VAL) )
			MVAR[dm+i,SR_EDIT] := IF( aux$'EMF',aux,'M' )
			aux = AT( "->", buffer )
			IF aux == 0
				MVAR[dm+i,SR_DBF]    := ''
				MVAR[dm+i,SR_NOMBRE] := LEFT(buffer,nAnchoCampo)
			ELSE
				MVAR[dm+i,SR_DBF]    := LEFT( buffer, aux-1 )
				MVAR[dm+i,SR_NOMBRE] := SUBSTR( LEFT(buffer,nAnchoCampo), aux+2 )
			ENDIF
			MVAR[dm+i,SR_PIC]   := ALLTRIM( SUBSTR(buffer,nAnchoCampo+1) )
			ACAMPO[y1] = STUFF( ACAMPO[y1], x1, block-nAnchoCampo, REPLIC(CHR(dm+i+1),block-nAnchoCampo) )
			MVAR[dm+i,SR_Y] = y1
			MVAR[dm+i,SR_X] = x1
			pos += block
		NEXT i
		*** carga las funciones
		FSEEK( na, pos )
		block = 3
		buffer = SPACE(block)
		bytes = FREAD( na, @buffer, block )
		xaux = VAL(buffer)
		pos += block
		FSEEK( na, pos )
		FOR i=1 TO xaux
			block = 10
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			AADD( MVER, ARRAY(SR_X) )
			MVER[dv+i,SR_Y] = VAL(SUBSTR(buffer,1,2)) + dy + 1
			MVER[dv+i,SR_X] = VAL(SUBSTR(buffer,3,2)) + dx + 1
			f1 = VAL(SUBSTR(buffer,5,2))
			f2 = VAL(SUBSTR(buffer,7,2))
			mm = VAL(SUBSTR(buffer,9,2))
			pos += block
			block = f1 + f2 + mm
			buffer = SPACE(block)
			bytes = FREAD( na, @buffer, block )
			MVER[dv+i,SR_NOMBRE] = LEFT( buffer, f1 )
			MVER[dv+i,SR_PIC] = SUBSTR(buffer,f1+f2+1)
			AVER[MVER[dv+i,SR_Y]] = STUFF( AVER[MVER[dv+i,SR_Y]], MVER[dv+i,SR_X], LEN(MVER[dv+i,SR_PIC]), REPLIC(CHR(dv+i+1),LEN(MVER[dv+i,SR_PIC])) )
			pos += block
		NEXT i
		FCLOSE( na )
		DISPALL()
	ELSE
		FSTATUS()
		menuaux = SAVESCREEN( YY, 0, YY, 79 )
	ENDIF
ENDIF

RETURN .T.
