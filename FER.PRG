*************

PROC FERIADOS

*************
ym2=7
xm2=10

PUBLIC L_[5]
L_[1] = REPLICATE( "Ä", 32 )
L_[2] = "   " + CHR(27) +" "+ CHR(26)+"   ùcambia de d¡a"
L_[3] = " PgUp PgDn ùcambia de mes      "
L_[4] = " F  ùpone y saca los feriados  "
L_[5] = " ESC ùsale                     "

xdia = DAY(DATE())
SELECT FE
DO WHILE .T.
	
	MARCO( ym2, xm2, ym2+6, xm2+32, ALLTRIM(nomes[UT_mes]) + STR(UT_anio,5,0), "S", .F., LEN(L_) )
	FOR d = 1 TO 7
		@ ym2, xm2-1+d*4 SAY LEFT( nomsemana[d], 2 )
	NEXT d
	mesanio = "/"+ STR(UT_mes,2,0) +"/"+ STR(UT_anio-1900,2,0)
	pfm = CTOD( "01" + mesanio )
	udm = DIASXMES( UT_anio, UT_mes )
	STORE DOW( pfm ) TO px, ux
	STORE ym2+1 TO uy
	xdia = IF( xdia>udm, udm, xdia )
	
	FOR x = 1 TO udm
		IF FERIADO( x, UT_mes, UT_anio )
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
	
	KEYBOARD " "
	DO WHILE .T.
		SETCURSOR( 0 )
		K = INKEY(0)
		SET COLOR TO N/W
		@ iy, xm2-1+ix*4 SAY xdia PICT "99"
		IF CHR(k) $ "Ff"                                  &&. Enter
			IF FERIADO( xdia, UT_mes, UT_anio )
				@ iy, (xm2-1+ix*4)-1 SAY xdia PICT "    "
				REPLACE FE->FERIADO WITH CTOD("")
			ELSE
				@ iy, (xm2-1+ix*4)-1 SAY xdia PICT "(  )"
           IF FE->FECHA # CTOD(STR(xdia,2,0)+mesanio)
					SEEK FTOC(CTOD(""))
					IF !FOUND()
              	DBGOTOP()
                 IF FE->FECHA < DATE()-(365*2)
                 ELSE
							ADD_REC()
                 ENDIF
					ENDIF
					FRLOCK()
          		REPLACE FE->FECHA WITH CTOD(STR(xdia,2,0)+mesanio)
				ENDIF
			ENDIF
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
		ELSEIF CHR(K) $ ""                          &&. PgUp
			UT_mes = UT_mes + 1
			IF UT_mes > 12
				UT_anio = UT_anio + 1
				UT_mes = 1
			ENDIF
			EXIT
		ELSEIF CHR(K) $ ""                          &&. PgDn
			UT_mes = UT_mes - 1
			IF UT_mes < 1
				UT_anio = UT_anio - 1
				UT_mes = 12
			ENDIF
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
		SET COLOR TO *+W/N
		@ iy, xm2-1+ix*4 SAY xdia PICT "99"
		
	ENDDO
	IF LASTKEY()=27
		EXIT
  ENDIF
	
ENDDO
SET COLOR TO N/W

RETURN


************

FUNC FERIADO

************
PARAMETERS _dia, _mes, _anio
PRIVATE lastbase, r

lastbase = DBF()

SELECT FE
SEEK FTOC( CTOD(STR(_dia,2,0)+mesanio) )
r = FOUND()

SELECT &lastbase

RETURN r
