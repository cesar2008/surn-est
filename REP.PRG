PRIVATE AXR, ATOT, aCPO

#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

RG_CODPROD   :=  1
RG_DESCPROD  :=  2
RG_CANTIDAD  :=  3
RG_RUBRO     :=  4
RG_UNXCAJA   :=  5
RG_REGISTRO  :=  6

MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
FBASES({"REP"},.F.)
aCpo:={	                                                                  ;
  { "CODPROD",           "C¢digo",                  '', 'M',  '',  0, 0 },;
	{ "DESCPROD",          "Descripci¢n",             '', 'F',  '',  0, 0 },;
	{ "CANTIDAD",          "Cantidad",                '', 'M',  '',  0, 0 },;
	{ "RUBRO",             "",                        '',  '',  '',  0, 0 },;
	{ "UNXCAJA",           "",                        '',  '',  '',  0, 0 },;
	{ "REGISTRO",          "",                        '',  '', 'N',  6, 0 } }
SELECT REP
aCpo := FARRAYAUX( aCpo )
RECUPAN()


M->FECHA := DATE()
DO WHILE .T.
	LOGO(.T., " REPOSICION ")
	SELECT REP
	SETCOLOR("W/N,N/W")
	MENUDOWN({"  +   º  -   º  TAB  º  ENTER   º ESC  ",;
				 "      º      º       º          º      ",;
 				 " sig. º ant. º tabla º confirma º sale "})
	EDX := NEWEDIT2( "FECHA" )
	EDX[ED_MODE] := "MOSTRARTODO"
	DO WHILE .T.
		FEDITAR2( EDX, { K_TAB, 43, 45 } )
		EDX[ED_MODE] := "MOSTRAR"
		IF EDX[ED_UPDATE]
			EDX[ED_MODE] := "MOSTRAR"
		ELSEIF EDX[ED_TECLA] == 43					// +
     	++M->FECHA
		ELSEIF EDX[ED_TECLA] == 45					// -
     	--M->FECHA
		ELSEIF EDX[ED_TECLA] == K_TAB
			SELECT REP
			SET ORDER TO 2
			PRIVATE bcamp[1], bmasc[1], bcab[1], bedit
			bcamp[ 1] = "REP->FECHA"
			bmasc[ 1] = ""
			bcab[ 1] = "Fecha"
			bedit = "F"
			aXmenuD:=MENUDOWN({"  <+>  º  F3   º   F4   º  ENTER  º  ESC   ",;
								 	 "       º       º        º elige y º        ",;
								 	 " mueve º busca º busca+ º  sale   º  sale  "})
			nReg = RECNO()
        DBSEEK(FTOC(M->FECHA),.T.)
			BROW( 8, 20, 18, 30, "REPOSICIONES", bcamp, bmasc, bcab, bedit )
			IF LASTKEY() == K_ENTER
				M->FECHA := REP->FECHA
			ELSE
				GO nReg
			ENDIF
			SET ORDER TO 1
			RECUPAN()
			PONEPAN(aXmenuD)
			EDX[ED_MODE] = "MOSTRARTODO"
		ELSEIF EDX[ED_TECLA] == K_ESC .OR. EDX[ED_TECLA] == K_ENTER
			EXIT
		ENDIF
	ENDDO
	IF EDX[ED_TECLA] == K_ESC
		EXIT
	ENDIF
	MODIFICABLE = .T.
	
	************************
	* Carga
	************************
	MENSAJE( 0, 0, 0, .F., " AGUARDE . . ." )
	AXR := {}
	SELECT REP
	SET ORDER TO 1
	SEEK FTOC(M->FECHA)
	IF FOUND()
		NUEVO = .F.
		DO WHILE REP->FECHA==M->FECHA
			AADD( AXR, ARRAY( RG_REGISTRO ) )
			i := LEN(AXR)
			AXR[i,RG_CODPROD ] := REP->CODPROD
			AXR[i,RG_DESCPROD] := REP->DESCPROD
			AXR[i,RG_CANTIDAD] := REP->CANTIDAD
			AXR[i,RG_RUBRO   ] := REP->RUBRO
			AXR[i,RG_UNXCAJA ] := REP->UNXCAJA
			AXR[i,RG_REGISTRO] := RECNO()
			SKIP
		ENDDO
	ELSE
		NUEVO = .T.
	ENDIF
	IF MODIFICABLE .OR. LEN(AXR) == 0
		AADD( AXR, AREG0( aCpo ) )
	ENDIF
	RECUPAN()
	
	
	SETCOLOR( "W/N,N/W" )
	OX := MYABROWSE( 7, 1, 20, 78, aCpo, AXR, "AXR" )
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	MENUDOWN({"  <+>  º    F2    º   F6    º    F7    º    TAB    º ESC  ",;
				 "       º          º elimina º          º           º      ",;
				 " mueve º modifica º  l¡nea  º imprimir º productos º sale "})
	guardar = .F.
	DO WHILE .T.
		
		MOVABROW( OX, AXR, {||nK==9.OR.nK==27.OR.nK==K_F6.OR.nK==K_F10.OR.nK==K_F7},;
			{||nK==999} )
		
		IF OX:Cargo[TB_RET] == K_TAB
			IF TBNOC(OX) == "CODPROD"
  			IF FELEPROD( AXR[NROW,RG_CODPROD] ) # 0
					AXR[NROW,RG_CODPROD]  := ART->CODPROD
					AXR[NROW,RG_DESCPROD] := ART->DESCPROD
					AXR[NROW,RG_RUBRO  ]  := ART->RUBRO
					AXR[NROW,RG_UNXCAJA]  := ART->UNXCAJA
     		ENDIF
			ENDIF
			TBPOS(OX)
			
		ELSEIF OX:Cargo[TB_MSGE] == "MODIF"
			IF TBNOC(OX) == "CODPROD"
  			FPROD( OX:CARGO[TB_CONT] )
				AXR[NROW,RG_CODPROD]  := ART->CODPROD
				AXR[NROW,RG_DESCPROD] := ART->DESCPROD
				AXR[NROW,RG_RUBRO  ]  := ART->RUBRO
				AXR[NROW,RG_UNXCAJA]  := ART->UNXCAJA
        ELSE
				AXR[NROW,OX:COLPOS] := OX:CARGO[TB_CONT]
			ENDIF
			TBPOS(OX)
			
		ELSEIF OX:Cargo[TB_RET] == 999 .AND. MODIFICABLE
			IF AXR[NROW,RG_CODPROD]#0 .AND.AXR[NROW,RG_CANTIDAD]#0 .AND. NROW==LEN(AXR)
				AADD( AXR, AREG0(aCpo) )
				++NROW
				TBPOS(OX,.T.)
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F6
			IF PREGUNTA( 12, "¨ Est s Seguro  [ S / N ] ?", "SsNn") $ "Ss"
           nReg      := AXR[NROW,RG_REGISTRO]
				AXR[NROW] := AREG0(aCpo,{RG_REGISTRO})
           AXR[NROW,RG_REGISTRO] := nReg
				TBPOS(OX,.T.)
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F7
			LISTADOR("REP")
			
		ELSEIF OX:Cargo[TB_RET] == K_F10
			IF MODIFICABLE
				aux := "G"
				guardar := .T.
				EXIT
			ELSE
				EXIT
			ENDIF
		ELSEIF OX:Cargo[TB_RET] == K_ESC
			IF MODIFICABLE
				aux := UPPER( PREGUNTA( 12, "[ G ] graba.       [ S ] sale.       [ C ] contin£a.", "GgSsCc") )
				IF aux $ "GS"
					guardar := ( aux == "G" )
					EXIT
				ENDIF
			ELSE
				EXIT
			ENDIF
		ENDIF

	ENDDO
	

	MENSAJE( 0, 0, 0, .F., " GRABANDO . . ." )
	IF guardar
			*** deja el Stock como estaba
		SELECT REP
		SET ORDER TO 1
		SEEK FTOC(M->FECHA)
		SELECT ART
		SET ORDER TO 1
		FFLOCK()
		DO WHILE REP->FECHA==M->FECHA .AND. !REP->(EOF())
			IF DBSEEK( REP->CODPROD )
           IF REP->FECHA >= ART->FECHA
					ART->STOCKACT  -= REP->CANTIDAD
              IF ART->CONDEP == 'S'
						ART->STOCKACTD += REP->CANTIDAD
              ENDIF
              IF ART->COMPUESTO # 0
                 FCOMPUESTO(ART->CODPROD,-REP->CANTIDAD,REP->FECHA)
              ENDIF
				ENDIF
			ENDIF
			SKIP 1 ALIAS REP
		ENDDO
			***

     SELECT REP
		FOR i=1 TO LEN(AXR)
			IF AXR[i,RG_CODPROD]+AXR[i,RG_CANTIDAD] == 0
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
					BLANKREG()
				ENDIF
			ELSE
				IF AXR[i,RG_REGISTRO] # 0
					GO AXR[i,RG_REGISTRO]
				ELSE
					GO TOP
					IF !EMPTY(REP->FECHA) .OR. LASTREC()==0
						ADD_REC()
					ENDIF
				ENDIF
				FRLOCK()
				REP->FECHA      := M->FECHA
				REP->CODPROD    := AXR[i,RG_CODPROD]
				REP->CANTIDAD   := AXR[i,RG_CANTIDAD]
				REP->DESCPROD   := AXR[i,RG_DESCPROD]
           REP->RUBRO      := AXR[i,RG_RUBRO]
           REP->UNXCAJA    := AXR[i,RG_UNXCAJA]
			ENDIF
		NEXT

			*** actualiza el Stock
		SELECT ART
		SET ORDER TO 1
		FFLOCK()
		FOR i=1 TO LEN(AXR)
			IF DBSEEK( AXR[i,RG_CODPROD] )
        	IF M->FECHA >= ART->FECHA
           	ART->STOCKACT  += AXR[i,RG_CANTIDAD]
              IF ART->CONDEP == 'S'
						ART->STOCKACTD -= AXR[i,RG_CANTIDAD]
              ENDIF
              IF ART->COMPUESTO # 0
                 FCOMPUESTO(ART->CODPROD,+AXR[i,RG_CANTIDAD],M->FECHA)
              ENDIF
				ENDIF
        ENDIF
		NEXT i
     SELECT REP
			***
	ENDIF
 	DBCOMMITALL()
 	DBUNLOCKALL()
	RECUPAN()
	
ENDDO

RETURN
