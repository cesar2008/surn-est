#INCLUDE "TB.CH"
#INCLUDE "INKEY.CH"
#INCLUDE "SETCURS.CH"

***
*   MYoTB()
*   CREATE A TBROWSE OBJECT AND BROWSE WITH IT.
*

FUNCTION MYBROWSE( y1, x1, y2, x2, aCampo )

LOCAL oTB := TBROWSEDB( y1, x1, y2, x2 ), nn, aux

oTB:SKIPBLOCK := { |X| SKIPPER(X, oTB) }

oTB:HEADSEP := "ÑÍ"
oTB:COLSEP  := "³"

oTB:COLORSPEC := "W/N, W+/N, N/W"

oTB:cargo := ARRAY( TB_RET )
oTB:cargo[TB_EDIT   ] := ''              //  1
oTB:cargo[TB_NOMBRE ] := {}              //  2
oTB:cargo[TB_MASC   ] := {}              //  3
oTB:cargo[TB_CONT   ] := NIL             //  4
oTB:cargo[TB_TIPO   ] := ''              //  5
oTB:cargo[TB_FILA   ] := 0               //  6
oTB:cargo[TB_COL    ] := 0               //  7
oTB:cargo[TB_NCOL   ] := 0               //  8
oTB:cargo[TB_MSGE   ] := ''              //  9
oTB:cargo[TB_LAST   ] := NIL             //  10
oTB:cargo[TB_XXX    ] := .T.             //  11
oTB:cargo[TB_REFRESH] := 0               //  12
oTB:cargo[TB_BUSCAR ] := NIL             //  13
oTB:cargo[TB_RET    ] := 0               //  14

FOR nn := 1 TO LEN(aCampo)
	IF !EMPTY(aCampo[nn,ATB_CABE])
 		IF aCampo[nn,ATB_MASC] == ''
 			IF aCampo[nn,ATB_TIPO] == "F" .OR. "->"$aCampo[nn,ATB_NOMBRE]
 				aux := ( "{|| "+ aCampo[nn,ATB_NOMBRE] +" }" )
        ELSE
 				aux := ( "{|| FIELD->"+ aCampo[nn,ATB_NOMBRE] +" }" )
        ENDIF
     ELSE
 			IF aCampo[nn,ATB_TIPO] == "F" .OR. "->"$aCampo[nn,ATB_NOMBRE]
 				aux := ( "{|| TRANSFORM("+ aCampo[nn,ATB_NOMBRE] +",'"+ aCampo[nn,ATB_MASC] +"') }" )
        ELSE
 				aux := ( "{|| TRANSFORM(FIELD->"+ aCampo[nn,ATB_NOMBRE] +",'"+ aCampo[nn,ATB_MASC] +"') }" )
        ENDIF
     ENDIF
		oTC := TBCOLUMNNEW( aCampo[nn,ATB_CABE], &aux )
     oTC:DefColor := IF( aCampo[nn,ATB_EDIT]='M', {2,3}, {1,3} )
     oTB:cargo[TB_EDIT] += aCampo[nn,ATB_EDIT]
     oTB:cargo[TB_TIPO] += aCampo[nn,ATB_TIPO]
     AADD( oTB:cargo[TB_NOMBRE], aCampo[nn,ATB_NOMBRE] )
     AADD( oTB:cargo[TB_MASC], aCampo[nn,ATB_MASC] )
		oTB:ADDCOLUMN(oTC)
  ENDIF
NEXT

RETURN oTB



************

FUNC MOVBROW( oTB, bExit1, bExit2, _bBlock )

************
LOCAL lMore := .T., coefX, coefY, oGET, oTC
_bBlock := IF( _bBlock==NIL,{||.F.},_bBlock )
PRIVATE xAux
bExit2 := IF( bExit2==NIL,{||.F.},bExit2 )
oTB:CARGO[TB_MSGE]:=''

DO WHILE lMore

  DO WHILE ( .NOT. oTB:Stabilize() )
  	nK := INKEY()
     IF ( nK <> 0 )
     	EXIT
     ENDIF
  ENDDO

 	oTB:CARGO[TB_FILA] := ROW()
 	oTB:CARGO[TB_COL]  := COL()
  EVAL( _bBlock )
	IF SUBSTR(oTB:Cargo[TB_EDIT],oTB:ColPos,1) == 'M'
		SETCURSOR( SC_ON )
  ELSE
  	SETCURSOR( SC_NONE )
  ENDIF
  @ oTB:CARGO[TB_FILA], oTB:CARGO[TB_COL] SAY ""

  IF ( oTB:stable )
  	IF ( oTB:hitTop .OR. oTB:hitBottom )
     	Tone(125, 0)
     ENDIF
     nK := INKEY( oTB:CARGO[TB_REFRESH] )
  ENDIF
  lCtrl := FT_CTRL()


*	IF oTB:Stable
		DO CASE
     CASE EVAL(bExit1)
			oTB:CARGO[TB_RET] := nK
        lMore = .F.
		CASE nK == K_DOWN
			oTB:DOWN()
		CASE nK == K_PGDN
			oTB:PAGEDOWN()
		CASE nK == K_CTRL_PGDN
			oTB:GOBOTTOM()
		CASE nK == K_UP
			oTB:UP()
		CASE nK == K_PGUP
			oTB:PAGEUP()
		CASE nK == K_CTRL_PGUP
			oTB:GOTOP()
		CASE nK == K_RIGHT
			oTB:RIGHT()
		CASE nK == K_LEFT
			oTB:LEFT()
		CASE nK == K_HOME
			oTB:GOTOP()
		CASE nK == K_END
			oTB:GOBOTTOM()
		CASE nK == K_CTRL_LEFT
			oTB:PANLEFT()
		CASE nK == K_CTRL_RIGHT
			oTB:PANRIGHT()
		CASE nK == K_CTRL_HOME
			oTB:PANHOME()
		CASE nK == K_CTRL_END
			oTB:PANEND()
		CASE nK == K_ENTER
     	X := AT( "M", SUBSTR(OTB:CARGO[TB_EDIT],OTB:COLPOS+1) )
        IF X == 0
				OTB:PANHOME()
				OTB:DOWN()
     		X := AT( "M", OTB:CARGO[TB_EDIT] )
        	FOR I=1 TO X-1
					OTB:RIGHT()
           NEXT
           nK := 999
        ELSE
        	FOR I=1 TO X
					OTB:RIGHT()
           NEXT
        ENDIF
		CASE nK == K_INS
			INSTOGGLE()
		CASE nK > 31 .AND. nK < 255 .OR. (NK==K_CTRL_C.AND.lCtrl) .OR. NK==K_ALT_M
     	OTB:CARGO[TB_LAST] := &(oTB:CARGO[TB_NOMBRE,OTB:COLPOS])
 			IF SUBSTR(OTB:CARGO[TB_EDIT],OTB:COLPOS,1) == 'M'
        	IF (NK == K_CTRL_C .AND. lCtrl) .OR. NK==K_ALT_M
           	CALC()
           ELSE
 					KEYBOARD CHR(NK)
           ENDIF

  			DO WHILE ( .NOT. oTB:Stabilize() )
  			ENDDO
 				oTB:CARGO[TB_FILA] := ROW()
 				oTB:CARGO[TB_COL]  := COL()
				READEXIT(.T.)

				oTC := oTB:GETCOLUMN(oTB:COLPOS)
				vGET := aux := FIELD->&(oTB:CARGO[TB_NOMBRE,OTB:COLPOS])
           DO WHILE .T.
           	SET KEY K_LEFT TO CLEAR_GETS()
           	SET KEY K_RIGHT TO CLEAR_GETS()
           	SET KEY 10 TO CLEAR_GETS()
              IF TYPE("VGET") == "N"
           		SET KEY 43 TO CLEAR_GETS()
              ENDIF
					oGET := GETNEW( oTB:CARGO[TB_FILA], oTB:CARGO[TB_COL],;
									MEMVARBLOCK("vGET"), OTC:HEADING, OTB:CARGO[TB_MASC,OTB:COLPOS] )
					READMODAL( {oGET} )
           	SET KEY K_LEFT TO
           	SET KEY K_RIGHT TO
           	SET KEY 10 TO
              IF TYPE("VGET") == "N"
           		SET KEY 43 TO
              	IF LASTKEY() == 43
                 	aux += VGET
              		VGET := aux
                 ELSE
              		IF CHR(LASTKEY()) $ CHR(13)+""
              			KEYBOARD CHR(LASTKEY())
                 	ENDIF
                 	EXIT
              	ENDIF
              ELSE
             		IF CHR(LASTKEY()) $ CHR(13)+""
              		KEYBOARD CHR(LASTKEY())
                 ENDIF
              	EXIT
              ENDIF
           ENDDO
				oTB:CARGO[TB_RET]  := LASTKEY()
				oTB:CARGO[TB_CONT] := vGET
				oTB:CARGO[TB_MSGE] := "MODIF"
        	lMore = .F.
			ELSEIF (NK == K_CTRL_C .AND. lCtrl) .OR. NK=K_ALT_M
        	CALC()
			ENDIF
		CASE nK == K_F2
     	OTB:CARGO[TB_LAST] := &(oTB:CARGO[TB_NOMBRE,OTB:COLPOS])
 			IF SUBSTR(OTB:CARGO[TB_EDIT],OTB:COLPOS,1) != 'F'
				READEXIT(.T.)
				oTC := oTB:GETCOLUMN(oTB:COLPOS)
				vGET := FIELD->&(oTB:CARGO[TB_NOMBRE,OTB:COLPOS])
           SETCURSOR( SC_ON )
           SET KEY K_CTRL_C TO CALC()
           SET KEY K_ALT_M TO CALC()
				aux := IF( oTC:WIDTH==NIL, LEN(OTB:CARGO[TB_MASC,OTB:COLPOS]), oTC:WIDTH )
				MARCO( oTB:CARGO[TB_FILA], oTB:CARGO[TB_COL], oTB:CARGO[TB_FILA], oTB:CARGO[TB_COL]+aux-1, "", "S", .T., 0 )
				oGET := GETNEW( oTB:CARGO[TB_FILA], oTB:CARGO[TB_COL],;
									MEMVARBLOCK("vGET"), OTC:HEADING, OTB:CARGO[TB_MASC,OTB:COLPOS] )
				READMODAL( {oGET} )
           RECUPAN()
           SET KEY K_CTRL_C TO
           SET KEY K_ALT_M TO
				oTB:CARGO[TB_RET] := LASTKEY()
				oTB:CARGO[TB_CONT] := vGET
				oTB:CARGO[TB_MSGE] := "MODIF"
        	lMore = .F.
			ENDIF
		CASE nK == K_F3 .OR. nK==K_SH_F3
 			IF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) $ 'N C D F'
				oTC := oTB:GETCOLUMN(oTB:COLPOS)
				oTB:CARGO[TB_BUSCAR] := EVAL( OTC:BLOCK )
           aux := EVAL( OTC:BLOCK )
           IF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == "N"
           	aux := VAL(aux)
           ELSEIF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == "D"
           	aux := CTOD(aux)
           ENDIF
				KEYBOARD CHR(25)
				oTB:CARGO[TB_BUSCAR] := INGRVAL(OTB:CARGO[TB_FILA], OTB:CARGO[TB_COL], "BUSCAR", aux, OTB:CARGO[TB_MASC,OTB:COLPOS], "")
				IF LASTKEY() == K_ENTER
					xreg := RECNO()
					MENSAJE(0, 0, 0, .F., " BUSCANDO... ")
              cAlias:=if("->"$oTB:CARGO[TB_NOMBRE,oTB:COLPOS].or."("$oTB:CARGO[TB_NOMBRE,oTB:COLPOS],"","FIELD->")
					IF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) $ 'C F'
						oTB:CARGO[TB_BUSCAR] := STRTRAN( oTB:CARGO[TB_BUSCAR], CHR(34), "" )
						oTB:CARGO[TB_BUSCAR] = "'"+ UPPER(ALLTRIM(STRTRAN(oTB:CARGO[TB_BUSCAR],".",""))) + "' $ STRTRAN(UPPER("+ cAlias + oTB:CARGO[TB_NOMBRE,oTB:COLPOS] +"),'.','') "
					ELSEIF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == 'N'
						oTB:CARGO[TB_BUSCAR] = cAlias + oTB:CARGO[TB_NOMBRE,oTB:COLPOS] +" ==" + STR(oTB:CARGO[TB_BUSCAR])
					ELSEIF SUBSTR(OTB:CARGO[TB_TIPO],OTB:COLPOS,1) == 'D'
						oTB:CARGO[TB_BUSCAR] = "DTOC("+ cAlias + oTB:CARGO[TB_NOMBRE,oTB:COLPOS] +")='" + DTOC(oTB:CARGO[TB_BUSCAR]) +"'"
					ENDIF
					oTB:CARGO[TB_BUSCAR] := oTB:CARGO[TB_BUSCAR] + ".AND. CORTAR()"
              xAux := oTB:CARGO[TB_BUSCAR]
              IF nK == K_F3
						LOCATE FOR &(xAux)
              ELSE
						LOCATE FOR &(xAux) REST
              ENDIF
					IF .NOT. FOUND()
						MENSAJE(0, 0, 10, .T., "Lo siento NO lo ENCUENTRO !")
						oTB:CARGO[TB_BUSCAR] = NIL
						GO xreg
					ENDIF
					RECUPAN()
				ELSE
					oTB:CARGO[TB_BUSCAR] = NIL
				ENDIF
			ENDIF
        oTB:RefreshAll()
			CLEARTYPEAHEAD()
		CASE nK == K_F4
			IF oTB:CARGO[TB_BUSCAR] != NIL
				xreg = RECNO()
				SKIP
				MENSAJE(0, 0, 0, .F., " CONTINUO BUSCANDO... ")
				aux := oTB:CARGO[TB_BUSCAR]
           IF VALTYPE(aux) == "B"
					LOCATE REST FOR EVAL(aux)
           ELSE
					LOCATE REST FOR &(aux)
           ENDIF
				IF !FOUND()
					MENSAJE( 0, 0, 10, .T., "Lo siento NO lo ENCUENTRO !")
					oTB:CARGO[TB_BUSCAR] = NIL
					GO xreg
				ENDIF
				RECUPAN()
			ENDIF
        oTB:RefreshAll()
			CLEARTYPEAHEAD()
		CASE nK == K_F6
			IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
        	BLANKREG(.T.)
           SKIP -1
        	oTB:RefreshAll()
        ENDIF
 		CASE nK == K_ESC
			aux = UPPER( PREGUNTA( 12, "[ G ] guarda y sale.   [ S ] sale y no guarda.    [ C ] continuar.", "GgSsCc") )
			IF aux == "G"
				oTB:Cargo[TB_RET] = nK
				oTB:Cargo[TB_MSGE] = "GRABAR"
				lMore := .F.
			ELSEIF aux == "S"
				oTB:Cargo[TB_RET] = nK
				oTB:Cargo[TB_MSGE] = "SALIR"
				lMore := .F.
			ELSE
				oTB:Cargo[TB_RET] = 0
				oTB:Cargo[TB_MSGE] = ""
				lMore := .T.
			ENDIF
		CASE nK == K_ALT_E
			aux := MENUFLASH( OTB:ROWPOS, OTB:COLPOS, AT( SUBSTR(OTB:CARGO[TB_EDIT],OTB:COLPOS,1),"MEF"), .T., "", "Modificable", "Editable", "No modificable" )
        IF LASTKEY() == K_ENTER
        	aux := SUBSTR("MEF",aux,1)
        	oTB:CARGO[TB_EDIT] := STUFF( OTB:CARGO[TB_EDIT], OTB:COLPOS, 1, aux )
				OTC:=OTB:GETCOLUMN( oTB:COLPOS )
     		OTC:DEFCOLOR:=IF( aux=="M", {2,3}, {1,3} )
				OTB:SETCOLUMN( oTB:ColPos, oTC )
     		oTB:INVALIDATE()
     		oTB:REFRESHALL()
			ENDIF
		CASE nK == 0
     	oTB:REFRESHALL()
		ENDCASE

     IF EVAL(bExit2)
			oTB:CARGO[TB_RET] := nK
        lMore = .F.
     ENDIF
*	ENDIF
	NK := 0
	
ENDDO

RETURN .T.



****
*   SKIPPER()
*   HANDLE RECORD MOVEMENT REQUESTS FROM THE ToTB OBJECT.
*
*   THIS IS A SPECIAL "SKIPPER" THAT HANDLES APPEND MODE. IT
*   TAKES TWO PARAMETERS INSTEAD OF THE USUAL ONE. THE SECOND
*   PARAMETER IS A REFERENCE TO THE ToTB OBJECT ITSELF. THE
*   ToTB'S "CARGO" VARIABLE CONTAINS INFORMATION ON WHETHER
*   APPEND MODE IS TURNED ON.
*
*   NOTE: USES THE CARGO #DEFINES SHOWN AT THE TOP OF TBDEMO.PRG
*
STATIC FUNCTION SKIPPER(N, oTB)

LOCAL I := 0

IF N == 0 .OR. LASTREC() == 0
	SKIP 0
	
ELSEIF N > 0 .AND. RECNO() != LASTREC() + 1
	DO WHILE I < N
		SKIP 1
		IF ( EOF() )
			SKIP -1
			EXIT
		ENDIF
		I++
	ENDDO

ELSEIF N < 0
	DO WHILE I > N
		SKIP -1
		IF ( BOF() )
			EXIT
		ENDIF
		I--
	ENDDO
	
ENDIF

RETURN I



*************

FUNC FBASEAUX( aCampo, nombase, numbase, lCrear )

*************
LOCAL aaux:=DBSTRUCT(), i, x
lCrear := IF( lCrear==NIL, .T., lCrear )

FOR i=1 TO LEN(aCampo)
	x := ASCAN( aaux, {|a| a[1]==aCampo[i,ATB_NOMBRE]} )
	IF x == 0
     AADD( aCampo[i], .F. )
  ELSEIF EMPTY(aCampo[i,ATB_MASC])
		aCampo[i,ATB_TIPO ] := aaux[x,2]
		aCampo[i,ATB_LARGO] := aaux[x,3]
		aCampo[i,ATB_DEC  ] := aaux[x,4]
     AADD( aCampo[i], .T. )
	ENDIF
NEXT
FOR i=1 TO LEN(aCampo)
	IF aCampo[i,ATB_TIPO] == "N"
		aCampo[i,ATB_MASC] := REPLICATE( "#",aCampo[i,ATB_LARGO] )
		aCampo[i,ATB_MASC] := IF(aCampo[i,ATB_DEC]==0, aCampo[i,ATB_MASC], STUFF(aCampo[i,ATB_MASC],aCampo[i,ATB_LARGO]-aCampo[i,ATB_DEC],1,".") )
	ELSEIF aCampo[i,ATB_TIPO] == "C" .AND. EMPTY(aCampo[i,ATB_MASC])
		aCampo[i,ATB_MASC] := REPLICATE( "!",aCampo[i,ATB_LARGO] )
	ELSEIF aCampo[i,ATB_TIPO] == "D"
		aCampo[i,ATB_MASC] := "99/99/99"
  ENDIF
NEXT
aaux := ARRAY( LEN(aCampo), 4 )
FOR i=1 TO LEN(aaux)
	aaux[i,1] := aCampo[i,ATB_NOMBRE]
	aaux[i,2] := aCampo[i,ATB_TIPO]
	aaux[i,3] := aCampo[i,ATB_LARGO]
	aaux[i,4] := aCampo[i,ATB_DEC]
NEXT

IF lCrear
	SELECT(numbase)
	FSELECT( "-"+DBF() )
	DBCLOSEAREA()
	DBCREATE( nombase, aaux )
ENDIF

RETURN aCampo


***************

FUNC TRANSFERIR( aCampo, debase, abase )

***************
LOCAL i

FOR i=1 TO LEN(aCampo)
	IF aCampo[i,ATB_TRANSFER]
		campo := aCampo[i,ATB_NOMBRE]
		&abase->&campo := &debase->&campo
	ENDIF
NEXT

RETURN .T.

*********

FUNC F_ALTA( xCual, nCualOrden )

*********
LOCAL lSetdel := SET(_SET_DELETED, .F. )
LOCAL nOrder := indexord()

if valtype(xCual)=="B"
	if nCualOrden # nil
  	set order to nCualOrden
  endif
	GO TOP
  if eval(xCual) .or. lastrec()==0
  	add_rec()
  else
		frlock()
  	recall
  endif
else
	SEEK xCual
	IF FOUND()
		FRLOCK()
  	RECALL
	ELSE
  	ADD_REC()
	ENDIF
endif
set order to nOrder
SET(_SET_DELETED, lSetdel )

RETURN( RECNO() )


*****************

FUNC TBCOLOR(OTB)

*****************
LOCAL OTC

FOR i=1 TO LEN(OTB:CARGO[TB_NOMBRE])
	OTC:=OTB:GETCOLUMN( i )
	OTC:DEFCOLOR:=IF( SUBSTR(OTB:CARGO[TB_EDIT],i,1)=="M", {2,3}, {1,3} )
	OTB:SETCOLUMN( i, oTC )
NEXT
oTB:INVALIDATE()

RETURN NIL


***

PROCEDURE TBPOS(OTB,lREPANT,XOLDKEY)

***
LOCAL COL, GET, NKEY
LOCAL XNEWKEY, lREACOMODO := .F.

lREPANT := IF( lREPANT==NIL, .F., lREPANT )
XOLDKEY := IF( XOLDKEY==NIL, OTB:CARGO[TB_LAST], XOLDKEY )


DO WHILE ( .NOT. oTB:Stabilize() )
ENDDO

IF !EMPTY( INDEXKEY() )
	IF oTB:CARGO[TB_NOMBRE,OTB:COLPOS] $ INDEXKEY()
*   IF &(oTB:CARGO[TB_NOMBRE,OTB:COLPOS]) # XOLDKEY
    		XNEWKEY := &(INDEXKEY())
     	lREACOMODO := .T.
			lREPANT    := .F.
*		ENDIF
  ENDIF
ENDIF

IF lREPANT
	OTB:REFRESHALL()
	DO WHILE ( .NOT. oTB:Stabilize() )
	ENDDO

ELSEIF lREACOMODO

	OTB:REFRESHALL()
	DO WHILE ( .NOT. oTB:Stabilize() )
	ENDDO

	DO WHILE &(INDEXKEY()) > XNEWKEY .AND. .NOT. OTB:HITTOP()
		OTB:UP()
		DO WHILE ( .NOT. oTB:Stabilize() )
 		ENDDO

	ENDDO

ELSE
	OTB:REFRESHCURRENT()

ENDIF


RETURN



**************************

FUNC TBCOLEDIT( que, cual, OX, aa, arch )

**************************
LOCAL i, aaux, xmenu, lastcolor, nedit

IF que == "SETEAR"
	aaux := OX:CARGO[TB_EDIT]
	i := ASCAN(aa,{|a|a[1]==cual})
	IF i==0
		AADD( aa, {cual,OX:CARGO[TB_EDIT],OX:CARGO[TB_EDIT]} )
     i := LEN(aa)
	ELSE
		OX:CARGO[TB_EDIT] := aa[i,2]
	ENDIF
	aa[i,3] := aaux
ELSEIF que == "CAMBIAR"
	nedit:=ASCAN(aa,{|a|a[1]==cual})
	aaux := ARRAY( 2, LEN(OX:CARGO[TB_NOMBRE]) )
	FOR i=1 TO LEN(OX:CARGO[TB_NOMBRE])
		aaux[1,i] := OX:CARGO[TB_NOMBRE,i] + SPACE(20-LEN(OX:CARGO[TB_NOMBRE,i])) + SUBSTR(OX:CARGO[TB_EDIT],i,1)
		aaux[2,i] := IF( SUBSTR(OX:CARGO[TB_EDIT],i,1)$"EM", .T., .F. )
	NEXT
	IF ASCAN( aaux[2], .T. ) # 0
		xmenu:=MENUDOWN({"     º ESPACIO º    F8     º  ENTER    º     ESC     ",;
							  "       º         º deja como º set‚a las º sale y deja ",;
							  " mueve º cambia  º  estaba   º columnas  º como estaba "})
		lastcolor = SETCOLOR("+W/N,N/W,,,W/N")
		aach := NEWACHO(aaux[1],,{7,30,0,0} )
		aach[ACH_CONDEXIT] := {||k==32.OR.k==K_ENTER.OR.K==K_F8}
		MARCO( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], " CAMPOS ", "S", .T. )
		DO WHILE .T.
			e := ACHOICE( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], aaux[1], aaux[2], "funcacho", aach[ACH_ELE], aach[ACH_REL] )
			IF aach[ACH_TECLA] == K_SPACE
				IF RIGHT(aaux[1][e],1) = "M"
					aaux[1][e] := LEFT(aaux[1][e],LEN(aaux[1][e])-1) + "E"
				ELSEIF RIGHT(aaux[1][e],1) = "E"
					aaux[1][e] := LEFT(aaux[1][e],LEN(aaux[1][e])-1) + "M"
				ENDIF
			ELSEIF aach[ACH_TECLA] == K_F8
				OX:CARGO[TB_EDIT] := aa[nedit,3]
				FOR i=1 TO LEN(OX:CARGO[TB_NOMBRE])
					aaux[1,i] := OX:CARGO[TB_NOMBRE,i] + SPACE(20-LEN(OX:CARGO[TB_NOMBRE,i])) + SUBSTR(OX:CARGO[TB_EDIT],i,1)
					aaux[2,i] := IF( SUBSTR(OX:CARGO[TB_EDIT],i,1)$"EM", .T., .F. )
				NEXT
			ELSEIF aach[ACH_TECLA] == K_ESC .OR. aach[ACH_TECLA]==K_ENTER
				EXIT
			ENDIF
		ENDDO
		RECUPAN()
		MENUDOWN(xmenu)
		IF aach[ACH_TECLA] == K_ENTER
			OX:CARGO[TB_EDIT] := ""
			FOR i=1 TO LEN(OX:CARGO[TB_NOMBRE])
				OX:CARGO[TB_EDIT] += RIGHT(aaux[1,i],1)
			NEXT
			TBCOLOR(OX)
			aa[nedit,2] := OX:CARGO[TB_EDIT]
			MEMOWRIT(arch, ATOS(aa) )
		ENDIF
	ENDIF
ELSEIF que == "CARGAR"
	IF FILE(arch)
		aa := MEMOTRAN( MEMOREAD(arch), " ", " " )
		aa := IF( EMPTY(aa), {}, STOA(MEMOREAD(arch)) )
	ELSE
		aa := {}
	ENDIF
ENDIF

RETURN aa


*************

FUNC TBPUT(o)

*************

FRLOCK()
FIELD->&(o:CARGO[TB_NOMBRE,o:COLPOS]) := o:CARGO[TB_CONT]
DBUNLOCK()

RETURN .T.
