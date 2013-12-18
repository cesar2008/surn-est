#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"


*************************

FUNC FEDITAR( aa, akey )

*************************
LOCAL nL, cPanta
PRIVATE K, nxreg := aa[ED_REGISTRO]
SET(_SET_CURSOR,SC_OFF)
SET(_SET_INTENSITY,.T.)

DISPBEGIN()
IF aa[ED_MODE] == "MOSTRAR"
	SETCOLOR(aa[ED_CFUNC])
	FOR i=1 TO LEN(aa[ED_VPOSY])
 		@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY SPACE( LEN(aa[ED_VPICTS,i]) )
 		@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY EVAL(aa[ED_VFUNCS,i],aa[ED_CONT]) PICT aa[ED_VPICTS,i]
	NEXT i
ELSEIF aa[ED_MODE] == "MOSTRARTODO"
	FOR i=1 TO LEN(aa[ED_POSY])
		IF SUBSTR(aa[ED_EDIT],i,1) == 'f'
			SETCOLOR(aa[ED_CFUNC])
     ELSE
			SETCOLOR(aa[ED_CSAY])
     ENDIF
		@ ED_CTON(aa[ED_POSY],i), ED_CTON(aa[ED_POSX],i) SAY aa[ED_CONT][i] PICT aa[ED_PICTS,i]
	NEXT
	SETCOLOR(aa[ED_CFUNC])
	FOR i=1 TO LEN(aa[ED_VPOSY])
 		@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY SPACE( LEN(aa[ED_VPICTS,i]) )
 		@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY EVAL(aa[ED_VFUNCS,i],aa[ED_CONT]) PICT aa[ED_VPICTS,i]
	NEXT i
ENDIF
DISPEND()

*aa[ED_I]   = FPOS2( aa[ED_POSY], aa[ED_POSX], aa[ED_I], aa[ED_TECLA] )
aa[ED_I]    = FPOS2( aa, aa[ED_TECLA] )
aa[ED_LAST] = aa[ED_CONT][aa[ED_I]]
aa[ED_Y] = ED_CTON(aa[ED_POSY],aa[ED_I])
aa[ED_X] = ED_CTON(aa[ED_POSX],aa[ED_I])
aa[ED_UPDATE] = .F.
IF SUBSTR(aa[ED_EDIT],aa[ED_I],1) # 'M'
	SETCURSOR(SC_OFF)
	SETCOLOR( aa[ED_CGET] )
	@ aa[ED_Y], aa[ED_X] SAY aa[ED_CONT,aa[ED_I]] PICT aa[ED_PICTS,aa[ED_I]]
  k := INKEY(0)
  lCtrl := FT_CTRL()
  IF (K==K_CTRL_C.AND.lCtrl) .OR. K==K_ALT_M
  	CALC()
  ENDIF
ELSE
	READEXIT( .T. )
	SETCURSOR(SC_ON)
	SETCOLOR( aa[ED_CFONDO]+","+aa[ED_CGET]+",,,"+aa[ED_CSAY] )
  DO WHILE .T.
		FOR i=1 TO LEN(akey)
			SET KEY akey[i] TO CLEAR_GETS
		NEXT i
		SET KEY K_CTRL_C TO CLEAR_GETS
		SET KEY K_ALT_M TO CLEAR_GETS
		SET KEY 19 TO CLEAR_GETS
		SET KEY 4 TO CLEAR_GETS
		SET KEY -1 TO CLEAR_GETS
		SET KEY K_CTRL_RET TO CLEAR_GETS
		@ aa[ED_Y], aa[ED_X] GET aa[ED_CONT,aa[ED_I]] PICT aa[ED_PICTS,aa[ED_I]]
		READ
  	lCtrl := FT_CTRL()
		SET KEY K_CTRL_RET TO
		SET KEY 19 TO
		SET KEY 4 TO
		SET KEY -1 TO
		SET KEY K_CTRL_C TO
		SET KEY K_ALT_M TO
		FOR i=1 TO LEN(akey)
			SET KEY akey[i] TO
		NEXT i
  	IF (LASTKEY()==K_CTRL_C .AND. lCtrl) .OR. LASTKEY()==K_ALT_M
  		CALC()
     ELSE
     	EXIT
  	ENDIF
  ENDDO
	aa[ED_UPDATE] = UPDATED()
ENDIF
k = LASTKEY()
IF k==K_F2 .AND. SUBSTR(aa[ED_EDIT],aa[ED_I],1)$'ME' .AND. ASCAN(akey,k)==0
	READEXIT( .T. )
	SETCURSOR(SC_ON)
	SET COLOR TO +W/N
  nL := at(" ",aa[ED_PICTS,aa[ED_I]])+1
  nL := len(substr(aa[ED_PICTS,aa[ED_I]],nL))
	cPanta:=savescreen( aa[ED_Y]-1, aa[ED_X]-1, aa[ED_Y]+1, aa[ED_X]+nL )
	@ aa[ED_Y]-1, aa[ED_X]-1 to aa[ED_Y]+1, aa[ED_X]+nL
  DO WHILE .T.
		SET KEY K_CTRL_C TO CLEAR_GETS
		SET KEY K_ALT_M TO CLEAR_GETS
		@ aa[ED_Y], aa[ED_X] GET aa[ED_CONT,aa[ED_I]] PICT aa[ED_PICTS,aa[ED_I]]
		READ
  	lCtrl := FT_CTRL()
		SET KEY K_CTRL_C TO
		SET KEY K_ALT_M TO
  	IF ( LASTKEY() == K_CTRL_C .AND. lCtrl ) .OR. LASTKEY()==K_ALT_M
  		CALC()
     ELSE
     	EXIT
  	ENDIF
  ENDDO
	restscreen( aa[ED_Y]-1, aa[ED_X]-1, aa[ED_Y]+1, aa[ED_X]+nL, cPanta )
	aa[ED_UPDATE] = UPDATED()
ENDIF
aa[ED_MODE] = ""
SETCURSOR(SC_OFF)
SETCOLOR(aa[ED_CSAY])
@ aa[ED_Y], aa[ED_X] SAY aa[ED_CONT,aa[ED_I]] PICT aa[ED_PICTS,aa[ED_I]]
IF aa[ED_CONT,aa[ED_I]] # aa[ED_LAST]
	aa[ED_CAMBIO] := .T.
ENDIF

aa[ED_TECLA] := LASTKEY()

RETURN .T.


******************************

FUNC FPOS2( aa, k )

******************************
LOCAL posy := aa[ED_POSS,1]
LOCAL posx := aa[ED_POSS,2]
LOCAL ii   := AT( CHR(aa[ED_I]), aa[ED_POSS,3] )
LOCAL auxy, auxx, _i

IF k == K_ENTER
	ii = ii + 1
ELSEIF k = K_LEFT
	ii = ii - 1
ELSEIF k == K_RIGHT
	ii = ii + 1
ELSEIF k == K_DOWN
	auxy = SUBSTR(posy,ii,1)
	auxx = SUBSTR(posx,ii,1)
	FOR _i = ii TO LEN(posy)
		IF SUBSTR(posy,_i,1)>auxy
			ii = _i
			auxy = SUBSTR(posy,ii,1)
			DO WHILE SUBSTR(posy,_i,1)==auxy .AND. _i<=LEN(posx)
				IF SUBSTR(posx,_i,1) = auxx
              ii = _i
					EXIT
				ELSEIF SUBSTR(posx,_i,1) > auxx
              ii = _i
					EXIT
				ENDIF
				++_i
			ENDDO
			EXIT
		ENDIF
	NEXT _i
ELSEIF k == K_UP
	auxy = SUBSTR(posy,ii,1)
	auxx = SUBSTR(posx,ii,1)
	FOR _i = ii TO 1 STEP -1
		IF SUBSTR(posy,_i,1)<auxy
			ii = _i
			auxy = SUBSTR(posy,ii,1)
			DO WHILE SUBSTR(posy,ii,1)=auxy .AND. ii>0
				ii = ii - 1
				IF SUBSTR(posx,ii,1) = auxx
					EXIT
				ELSEIF SUBSTR(posx,ii,1) < auxx
					ii = ii + 1
					EXIT
				ENDIF
			ENDDO
			ii = ii + IF(SUBSTR(posy,ii,1)<auxy, 1, 0 )
			EXIT
		ENDIF
	NEXT _i
ELSEIF K == K_PGDN
	ii = ii + LEN(posx) / 5
ELSEIF K == K_PGUP
	ii = ii - LEN(posx) / 5
ELSEIF K == K_HOME .OR. K == K_END
	salir = .T.
ENDIF
IF ii < 1
	ii = 1
ELSEIF ii > LEN(posy)
	ii = LEN(posy)
ENDIF

ii := ASC( SUBSTR(aa[ED_POSS,3],ii) )

RETURN ii

***********************

FUNC NEWEDIT( nomarch, mostrar, sombra )

***********************
LOCAL aa:=ARRAY(ED_FCOUNT), nAnchoCampo
PRIVATE a, pos, block , buffer
mostrar := IF( mostrar==NIL, .T., mostrar )
sombra := IF( sombra==NIL, .T., sombra )

aa[ED_EDIT]    = ""
aa[ED_MODE]    = ""
aa[ED_UPDATE]  = .F.
aa[ED_LAST]    = NIL
aa[ED_I]       = 1
aa[ED_REFRESH] = 5
aa[ED_CONT]    = {}
aa[ED_POSY]    = ""
aa[ED_POSX] 	 = ""
aa[ED_Y]       = 0
aa[ED_X]       = 0
aa[ED_FIELDS]  = {}
aa[ED_PICTS]   = {}
aa[ED_VPOSY]   = ""
aa[ED_VPOSX]   = ""
aa[ED_VFIELDS] = {}
aa[ED_VPICTS]  = {}
aa[ED_VFUNCS]  = {}
aa[ED_TECLA]   = 0
aa[ED_CAMBIO]  = .F.
aa[ED_REGISTRO]= RECNO()
aa[ED_CFONDO]  = "W/N"
aa[ED_CGET]    = "N/W"
aa[ED_CSAY]    = "W/N"
aa[ED_CFUNC]   = "W/N"
aa[ED_MODAPP]  = ""
aa[ED_POSS]    = {"","",""}
aa[ED_FCOUNT]  = ""

na := -1
DO WHILE na == -1
	na = FOPEN(nomarch+".SCR",0)
ENDDO
pos = 0
block = 30
buffer = SPACE(block)
bytes = FREAD( na, @buffer, block )
y1 = VAL( SUBSTR(buffer,1,2) ) - 1
x1 = VAL( SUBSTR(buffer,3,2) ) - 1
y2 = VAL( SUBSTR(buffer,5,2) ) - 1
x2 = VAL( SUBSTR(buffer,7,2) ) - 1
aa[ED_CFONDO] = SUBSTR(buffer,11,5)
aa[ED_CGET]   = SUBSTR(buffer,16,5)
aa[ED_CSAY]   = SUBSTR(buffer,21,5)
aa[ED_CFUNC]  = SUBSTR(buffer,26,5)
aa[ED_FCOUNT] = ""
pos += block
FSEEK( na, pos+1 )

block = (y2-y1+1) * (x2-x1+1) * 2
buffer = SPACE(block)
bytes = FREAD( na, @buffer, block )
IF mostrar
	IF sombra
  	aa[ED_FCOUNT] := CHR(y1)+CHR(x1)+CHR(y2)+CHR(x2) + "S" + SAVESCREEN( y1, x1, y2+1, x2+2 )
		SOMBRA( y1+1, x1+2, y2+1, x2+2 )
  ELSE
  	aa[ED_FCOUNT] := CHR(y1)+CHR(x1)+CHR(y2)+CHR(x2) + "N" + SAVESCREEN( y1, x1, y2, x2 )
  ENDIF
	RESTSCREEN( y1, x1, y2, x2, buffer )
ELSE
 	aa[ED_FCOUNT] := CHR(y1)+CHR(x1)+CHR(y2)+CHR(x2) + IF(sombra,"s","n") + buffer
ENDIF
pos += block
FSEEK( na, pos+1 )

*** carga las bases usadas
block = 2
buffer = SPACE(block)
bytes = FREAD( na, @buffer, block )				&& cant.de bases 2 Bytes
block = VAL(buffer) * 20
pos += block + 2
FSEEK( na, pos+1 )

*** carga los campos usados con sus mascaras
block = 3
buffer = SPACE(block)
bytes = FREAD( na, @buffer, block )
pos += block
FSEEK( na, pos+1 )
CANTVAR = VAL(buffer)
FOR i=1 TO CANTVAR
	block = 10
  buffer = SPACE(block)
	bytes = FREAD( na, @buffer, block )
  aa[ED_POSY] += CHR((VAL(SUBSTR(buffer,1,2))))
  aa[ED_POSX] += CHR((VAL(SUBSTR(buffer,3,2))))
  aa[ED_EDIT] += SUBSTR(buffer,9,1)
  IF SUBSTR(buffer,9,1) # 'f'
		aa[ED_POSS,1] += CHR((VAL(SUBSTR(buffer,1,2))))
		aa[ED_POSS,2] += CHR((VAL(SUBSTR(buffer,3,2))))
		aa[ED_POSS,3] += CHR(i)
  ENDIF
	nAnchoCampo := 17
	IF ASC( SUBSTR( buffer, 10, 1 ) ) > 32
		nAnchoCampo := ASC( SUBSTR( buffer, 10, 1 ) ) - 32
  ENDIF
	pos += block
  block = VAL(SUBSTR(buffer,5,2)) + nAnchoCampo
  buffer = SPACE(block)
	bytes = FREAD( na, @buffer, block )
 	AADD( aa[ED_FIELDS], ALLTRIM(LEFT(buffer,nAnchoCampo)) )
	AADD( aa[ED_PICTS], ALLTRIM(SUBSTR(buffer,nAnchoCampo+1)) )
	AADD( aa[ED_CONT], &(aa[ED_FIELDS][i]) )
  pos += block
  FSEEK( na, pos+1 )
NEXT i

*** carga las funciones
block = 3
buffer = SPACE(block)
bytes = FREAD( na, @buffer, block )
pos += block
FSEEK( na, pos+1 )
CANTVER = VAL(buffer)
FOR i=1 TO CANTVER
	block = 10
  buffer = SPACE(block)
	bytes = FREAD( na, @buffer, block )
  aa[ED_VPOSY] += CHR((VAL(SUBSTR(buffer,1,2))))
  aa[ED_VPOSX] += CHR((VAL(SUBSTR(buffer,3,2))))
	pos += block
  f1 = VAL(SUBSTR(buffer,5,2))
  f2 = VAL(SUBSTR(buffer,7,2))
  mm = VAL(SUBSTR(buffer,9,2))
  block = f1 + f2 + mm
  buffer = SPACE(block)
	bytes = FREAD( na, @buffer, block )
 	AADD( aa[ED_VFIELDS], LEFT(buffer,f1) )
	AADD( aa[ED_VFUNCS], &(SUBSTR(buffer,f1+1,f2)) )
	AADD( aa[ED_VPICTS], SUBSTR(buffer,f1+f2+1) )
  pos += block
  FSEEK( na, pos+1 )
NEXT i

FCLOSE( na )

RETURN aa


********************************

FUNC FVERREG( aa, bKeys, lSalir, bPre_, bPost_ )

********************************
PRIVATE K := 0, nxreg
bKeys := IF( bKeys==NIL, {||.F.}, bKeys )
lSalir := IF( lSalir==NIL, .F., lSalir )
bPre_ := IF( bPre_==NIL, {||.f.}, bPre_ )
bPost_ := IF( bPost_==NIL, {||.f.}, bPost_ )

SETCURSOR(SC_OFF)

DO WHILE .T.
	IF RECNO() > LASTREC() .OR. DELETED()
  	DBGOBOTTOM()
  ENDIF
	nxreg := RECNO()
	FOR i=1 TO LEN(aa[ED_POSY])
		IF SUBSTR(aa[ED_EDIT],i,1) == 'f'
			SETCOLOR(aa[ED_CFUNC])
     ELSE
			SETCOLOR(aa[ED_CSAY])
     ENDIF
		@ ED_CTON(aa[ED_POSY],i), ED_CTON(aa[ED_POSX],i) SAY &(aa[ED_FIELDS,i]) PICT aa[ED_PICTS,i]
	NEXT
	SETCOLOR(aa[ED_CFUNC])
	FOR i=1 TO LEN(aa[ED_VPOSY])
		@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY SPACE( LEN(aa[ED_VPICTS,i]) )
 		@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY &(aa[ED_VFIELDS,i]) PICT aa[ED_VPICTS,i]
	NEXT i
  IF lSalir
  	EXIT
  ENDIF
	K := INKEY(aa[ED_REFRESH])
  lCtrl := FT_CTRL()
  if EVAL(bPre_,K); exit;  endif
  IF EVAL(bKeys,K)
  	EXIT
  ELSEIF K == K_ENTER .OR. K == K_F2
  	EXIT
  ELSEIF K == K_ESC
  	EXIT
  ELSEIF (K == K_CTRL_C .AND. lCtrl) .OR. K==K_ALT_M
  	CALC()
  ELSEIF K == K_UP
  	nxreg := RECNO()
  	SKIP -1
     DO WHILE !BOF()
     	IF !DELETED()
        	EXIT
        ENDIF
  		SKIP -1
     ENDDO
  	IF RECNO() < 1 .OR. DELETED()
     	DBGOTO(nxreg)
     ENDIF
  ELSEIF K == K_DOWN
  	nxreg := RECNO()
  	SKIP
     DO WHILE !EOF()
     	IF !DELETED()
        	EXIT
        ENDIF
  		SKIP
     ENDDO
  	IF RECNO() > LASTREC() .OR. DELETED()
     	DBGOTO(nxreg)
     ENDIF
  ELSEIF K == K_HOME
  	DBGOTOP()
  ELSEIF K == K_END
  	DBGOBOTTOM()
  ELSEIF K == K_PGUP
  	SKIP -5
  	IF RECNO() < 1 .OR. DELETED() .OR. BOF()
     	DBGOTOP()
     ENDIF
  ELSEIF K == K_PGDN
  	SKIP 5
  	IF RECNO() > LASTREC() .OR. DELETED() .OR. EOF()
     	DBGOBOTTOM()
     ENDIF
  ENDIF
  if EVAL(bPost_,K);  exit;  endif
ENDDO

RETURN ( K )


*********************************

FUNC FEDITOR( aa, cualop, param3, param4 )

*********************************
LOCAL r:=.F., y1, x1, y2, x2
PRIVATE i, nxreg := aa[ED_REGISTRO]

IF cualop == "LEER"
	AEVAL( aa[ED_FIELDS], {|a,i| aa[ED_CONT,i]:=&(aa[ED_FIELDS,i]) } )

ELSEIF cualop == "HUBOCAMBIOS"
	IF aa[ED_CAMBIO]
  	r := .T.
  ELSE
  	FOR i=1 TO LEN(aa[ED_FIELDS])
			IF &(aa[ED_FIELDS,i]) # aa[ED_CONT,i]
				r := .T.
           EXIT
        ENDIF
     NEXT
  ENDIF

ELSEIF cualop == "GRABAR"
	r := "G"
  IF param3
		r := UPPER(PREGUNTA( 0, "[ G ] guarda     [ S ] sale      [ C ] contin£a ", "GgSsCc" ) )
  ENDIF
  IF r == "G"
		IF aa[ED_REGISTRO] != 0
			IF aa[ED_REGISTRO]>LASTREC() .OR. aa[ED_REGISTRO]==0
				ADD_REC()
				aa[ED_REGISTRO] := RECNO()
  		ELSE
				DBGOTO( aa[ED_REGISTRO] )
     		FRLOCK()
				DBRECALL()
			ENDIF
     ENDIF
     FRLOCK()
		AEVAL( aa[ED_FIELDS], {|a,i| &(aa[ED_FIELDS,i]):=aa[ED_CONT,i] } )
     DBUNLOCK()
		nxreg := aa[ED_REGISTRO]
  ENDIF
	DBCOMMITALL()

ELSEIF cualop == "PONER"
	i := ASCAN( aa[ED_FIELDS], param3 )
  IF i == 0
  	r := .F.
  ELSE
  	aa[ED_CONT,i] := param4
     r := .T.
  ENDIF

ELSEIF cualop == "PONERED"
	r := 0
	FOR x=1 TO LEN(param3)
		i := ASCAN( aa[ED_FIELDS], param3[x] )
  	IF i != 0
  		aa[ED_EDIT] := STUFF( aa[ED_EDIT], i, 1, IF(param4,UPPER(SUBSTR(aa[ED_EDIT],i,1)),LOWER(SUBSTR(aa[ED_EDIT],i,1))) )
        ++r
     ENDIF
  NEXT


ELSEIF cualop == "CONTENIDO"
	i := ASCAN( aa[ED_FIELDS], param3 )
  IF i == 0
  	r := param4
  ELSE
  	r := aa[ED_CONT,i]
  ENDIF


ELSEIF cualop == "PONEPAN"
	y1 = ASC( SUBSTR(aa[ED_FCOUNT],1,1) )
	x1 = ASC( SUBSTR(aa[ED_FCOUNT],2,1) )
	y2 = ASC( SUBSTR(aa[ED_FCOUNT],3,1) )
	x2 = ASC( SUBSTR(aa[ED_FCOUNT],4,1) )
  IF SUBSTR( aa[ED_FCOUNT], 5, 1 ) $ "Ss"
		aux := LEFT(aa[ED_FCOUNT],4) +'S'+ SAVESCREEN( y1, x1, y2+1, x2+2 )
		SOMBRA( y1+1, x1+2, y2+1, x2+2 )
  ELSE
		aux := LEFT(aa[ED_FCOUNT],4) +'N'+ SAVESCREEN( y1, x1, y2, x2 )
  ENDIF
	RESTSCREEN( y1, x1, y2, x2, SUBSTR( aa[ED_FCOUNT], 6 ) )
	aa[ED_FCOUNT] := aux


ELSEIF cualop == "SACAPAN"
	y1 = ASC( SUBSTR(aa[ED_FCOUNT],1,1) )
	x1 = ASC( SUBSTR(aa[ED_FCOUNT],2,1) )
	y2 = ASC( SUBSTR(aa[ED_FCOUNT],3,1) )
	x2 = ASC( SUBSTR(aa[ED_FCOUNT],4,1) )
	aux := LEFT(aa[ED_FCOUNT],4) +LOWER(SUBSTR(aa[ED_FCOUNT],5,1))+ SAVESCREEN( y1, x1, y2, x2 )
  IF SUBSTR( aa[ED_FCOUNT], 5, 1 ) $ "Ss"
		RESTSCREEN( y1, x1, y2+1, x2+2, SUBSTR( aa[ED_FCOUNT], 6 ) )
  ELSE
		RESTSCREEN( y1, x1, y2, x2, SUBSTR( aa[ED_FCOUNT], 6 ) )
  ENDIF
	aa[ED_FCOUNT] := aux


ELSEIF cualop == "SETVARS"
	IF param3 == K_F5
  	param4 := IF( param4==NIL, .T., .F.)
		aa[ED_MODE] := aa[ED_MODAPP] := "AGREGAR"
 		aa[ED_I   ] := 1
     IF param4
			SET(_SET_DELETED, .F. )
			i := RECNO()
  		LOCATE FOR DELETED()
  		IF !FOUND()
  			r := LASTREC() + 1
  		ELSE
  			r := RECNO()
  		ENDIF
			SET(_SET_DELETED, .T. )
  		DBGOTO( i )
			aa[ED_REGISTRO] := nxreg := r
     ELSE
     	nxreg := aa[ED_REGISTRO]
     ENDIF
		FOR i=1 TO LEN(aa[ED_CONT])
			IF VALTYPE(&(aa[ED_FIELDS,i])) == "N"
				aa[ED_CONT,i] := 0
			ELSEIF VALTYPE(&(aa[ED_FIELDS,i])) == "C"
				aa[ED_CONT,i] := SPACE(LEN(&(aa[ED_FIELDS,i])))
			ELSEIF VALTYPE(&(aa[ED_FIELDS,i])) == "D"
				aa[ED_CONT,i] := CTOD('')
			ELSEIF VALTYPE(&(aa[ED_FIELDS,i])) == "L"
				aa[ED_CONT,i] := .F.
			ELSEIF VALTYPE(&(aa[ED_FIELDS,i])) == "M"
				aa[ED_CONT,i] := SPACE(LEN(&(aa[ED_FIELDS,i])))
  		ENDIF
		NEXT
  ELSE
  	aa[ED_MODE    ] := aa[ED_MODAPP] := "MODIFICAR"
		aa[ED_REGISTRO] := nxreg := RECNO()
* 	aa[ED_I       ] := 1
		AEVAL( aa[ED_FIELDS], {|a,i| aa[ED_CONT,i]:=&(aa[ED_FIELDS,i]) } )
  ENDIF
  IF SUBSTR(aa[ED_FCOUNT],5,1) $ "NS"
		FOR i=1 TO LEN(aa[ED_POSY])
			IF SUBSTR(aa[ED_EDIT],i,1) == 'f'
				SETCOLOR(aa[ED_CFUNC])
     	ELSE
				SETCOLOR(aa[ED_CSAY])
     	ENDIF
			@ ED_CTON(aa[ED_POSY],i), ED_CTON(aa[ED_POSX],i) SAY aa[ED_CONT][i] PICT aa[ED_PICTS,i]
		NEXT
		SETCOLOR(aa[ED_CFUNC])
		FOR i=1 TO LEN(aa[ED_VPOSY])
 			@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY SPACE( LEN(aa[ED_VPICTS,i]) )
 			@ ED_CTON(aa[ED_VPOSY],i), ED_CTON(aa[ED_VPOSX],i) SAY EVAL(aa[ED_VFUNCS,i],aa[ED_CONT]) PICT aa[ED_VPICTS,i]
		NEXT i
  ENDIF


ELSEIF cualop == "ELIMINAR"
	r := .F.
	IF PREGUNTA( 12, "¨ ESTAS SEGURO DE ELIMINARLO  [ S / N ]", "SsNn") $ "Ss"
     BLANKREG(.T.)
     DBGOTOP()
		r := .T.
  ENDIF

ENDIF

RETURN ( r )

******************************

FUNC EDPONE( aa, cual, que )

******************************
LOCAL i := IF( cual==NIL, aa[ED_I], ASCAN(aa[ED_FIELDS],cual) ), r
IF i == 0
  r := .F.
ELSE
  aa[ED_CONT,i] := 	que
  r := .T.
ENDIF

RETURN( r )


****************************

FUNC EDCONT( aa, cual, que )

****************************
LOCAL i := IF( cual==NIL, aa[ED_I], ASCAN(aa[ED_FIELDS],cual) ), r
IF i == 0
  r := que
ELSE
  r := aa[ED_CONT,i]
ENDIF

RETURN( r )


****************

FUNC EDMODA( aa )

****************
LOCAL  r := aa[ED_MODAPP]

RETURN( r )
