LOCAL aCpo, oX, oGET, xreg

#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " SUMA DE REMITOS " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

IF FILE("SREM.DBF")
	FBASES({"SREM"},.F.)
	IF FCOUNT() # CL->(LASTREC())
		FBASES({"-SREM"},.F.)
  	FERASE("SREM.DBF")
  	FERASE("SREM.SEQ")
	ENDIF
ENDIF
IF !FILE("SREM.DBF")
	aCpo := ARRAY( CL->(LASTREC()), 4 )
  AEVAL( aCpo, {|a,i| aCpo[i,1]:="IMPORTE"+STRZERO(i,2), aCpo[i,2]:='N', aCpo[i,3]:=10, aCpo[i,4]:=3} )
	DBCREATE( "SREM.DBF", aCpo )
ENDIF
FBASES({"SREM"},.F.)

aCpo := {}
SELECT CL
FOR i=1 TO CL->(LASTREC())
	GO i
	AADD( aCpo, ARRAY(7) )
  i:=LEN(aCpo)
	aCpo[i, ATB_NOMBRE ] := "IMPORTE" + STRZERO(RECNO(),2)
	aCpo[i, ATB_CABE   ] := IF(EMPTY(CL->RAZONSOC),"@",STRTRAN(ALLTRIM(CL->RAZONSOC)," ",";"))
	aCpo[i, ATB_MASC   ] := ''
	aCpo[i, ATB_EDIT   ] := 'M'
	aCpo[i, ATB_TIPO   ] := ''
	aCpo[i, ATB_LARGO  ] := 0
	aCpo[i, ATB_DEC    ] := 0
NEXT

SELECT SR
aCpo := FBASEAUX( aCpo, "SR", SELECT(), .F. )
DBGOTOP()

MENUDOWN({"  <+>  º F2 modif. º     F6       º    F9     º  ESC   ",;
			  "       º F3 busca  º   pone la    º           º        ",;
			  " mueve º F4 busca+ º columna en 0 º recalcula º  sale  "})

SETCOLOR( "W/N,N/W" )

oX := MYBROWSE( 4, 0, 20, 79, aCpo )

oX:CARGO[TB_REFRESH] := 0

IF FILE("SREM.SEQ")
	atot := STOA( MEMOREAD("SREM.SEQ") )
	FOR i=LEN(atot) TO FCOUNT()
		AADD( atot, { 0, 0 } )
	NEXT
ELSE
	atot := ARRAY( FCOUNT(), 2 ); AEVAL( atot,{|a,i| AFILL( atot[i], 0 ) })
ENDIF
IF FCOUNT() < LEN(atot)
	atot := ASIZE(atot,FCOUNT())
ENDIF
GO TOP
DO WHILE !EOF()
	AEVAL( atot, {|a,i| atot[i,1]+=&("SR->IMPORTE"+STRZERO(i,2)) })
 	SKIP
ENDDO
FOR i=1 TO FCOUNT()
 oTC:=oX:GETCOLUMN(i)
 oTC:FootSep := "Ä"
 oTC:Footing := TRANS( atot[i,1], '######.###' ) +";"+ TRANS(atot[i,2],'######.###') +";"+ TRANS(atot[i,1]-atot[i,2],'######.###')
 oX:SetColumn(i,oTC)
NEXT


DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==K_F9.OR.nK==-5.OR.nK==27.OR.nK==-9.OR.nK==-6.OR.NK==K_ENTER}, {||NK==999} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF" .OR. oX:Cargo[TB_RET] == K_ENTER
		IF "IMPORTE" $ TBNOC(OX) .AND. oX:Cargo[TB_MSGE] == "MODIF"
     	nc := VAL(RIGHT(TBNOC(OX),2))
     	atot[nc,1] -= FIELD->&(TBNOC(OX))
			FRLOCK()
			FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
     	atot[nc,1] += FIELD->&(TBNOC(OX))
 			oTC:=oX:GETCOLUMN(nc)
 			oTC:Footing := TRANS( atot[nc,1], '######.###' ) +";"+ TRANS(atot[nc,2],'######.###') +";"+ TRANS(atot[nc,1]-atot[nc,2],'######.###')
 			oX:SetColumn(nc,oTC)
			IF FIELD->&(TBNOC(OX)) # 0 .AND. RECNO() == LASTREC()
				oX:Cargo[TB_RET] := 0
  			ADD_REC()
     	ELSE
				oX:Cargo[TB_RET] := K_DOWN
        ENDIF
			oX:RefreshCurrent()
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F9
  	IF QUEFECHA2(10,30)
			MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
     	FBASES({"+REM"},.F.)
			AEVAL( atot,{|a,i| AFILL( atot[i], 0 ) })
			SELECT RE
     	DBSETORDER( FORDER({"FECHA","TURNO"}) )
        SET SOFTSEEK ON
        SEEK FTOC(DESDE)
        DO WHILE RE->FECHA>=DESDE .AND. RE->FECHA<=HASTA
        	IF RE->CODCLI>0 .AND. RE->CODCLI <= LEN(atot)
					atot[RE->CODCLI,2] += RE->TOTAL
           ENDIF
        	SKIP
        ENDDO
     	SELECT SR
     	dbgotop()
			DO WHILE !EOF()
				AEVAL( atot, {|a,i| atot[i,1]+=&("SR->IMPORTE"+STRZERO(i,2)) })
  			SKIP
			ENDDO
			FOR i=1 TO FCOUNT()
 				oTC:=oX:GETCOLUMN(i)
 				oTC:FootSep := "Ä"
 				oTC:Footing := TRANS( atot[i,1], '######.###' ) +";"+ TRANS(atot[i,2],'######.###') +";"+ TRANS(atot[i,1]-atot[i,2],'######.###')
 				oX:SetColumn(i,oTC)
			NEXT
			oX:RefreshAll()
        RECUPAN()
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F6
  	FFLOCK()
  	xreg := RECNO()
     nc := VAL(RIGHT(TBNOC(OX),2))
     REPLACE SR->&(TBNOC(OX)) WITH 0 REST
     atot[nc,1]:=0; DBGOTOP(); DBEVAL( {|| atot[nc,1]+=SR->&(TBNOC(OX))} )
     GO xreg
 		oTC:=oX:GETCOLUMN(nc)
 		oTC:Footing := TRANS( atot[nc,1], '######.###' ) +";"+ TRANS(atot[nc,2],'######.###') +";"+ TRANS(atot[nc,1]-atot[nc,2],'######.###')
 		oX:SetColumn(nc,oTC)
		oX:RefreshAll()
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
			BLANKREG(.T.)
			SKIP -1
			oX:RefreshAll()
		ENDIF
	ELSEIF OX:Cargo[TB_RET] == 999
		IF FIELD->&(TBNOC(OX)) # 0 .AND. RECNO() == LASTREC()
  		ADD_REC()
		ENDIF
		oX:RefreshAll()
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
*	CLEARTYPEAHEAD()
ENDDO

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
MEMOWRIT( "SREM.SEQ", ATOS(atot) )
RECUPAN()

DBUNLOCKALL()
DBCOMMITALL()

RETURN
