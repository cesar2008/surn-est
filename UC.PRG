PRIVATE aCPO

#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
SELECT 99;  DBCLOSEAREA()
IF !FILE("UC.DBF")
	CREARBASE("UC", "CODPROD N 5", "DESCPROD C 30", "CODPROD2 N 5", "DESCPROD2 C 30" )
ENDIF
SELECT 99
ABRIR_BASE( "UC", "UC", "UC->CODPROD", "UCPRD" )
ABRIR_BASE( "UC", "UC", "UC->CODPROD2", "UCPRD2" )
USE UC ALIAS UC EXCLUSIVE INDEX UCPRD, UCPRD2

aCpo:={;
	{ "CODPROD",    "C¢d;Prod.",                          '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                      '', 'E',  '',  0, 0 },;
	{ "CODPROD2",   "C¢d.;Prod.",                         '', 'M',  '',  0, 0 },;
	{ "DESCPROD2",  "Descripci¢n; ",                      '', 'E',  '',  0, 0 } }

SELECT UC
aCpo := FARRAYAUX( aCpo )
IF LASTREC() == 0
	APPEND BLANK
ENDIF
SET ORDER TO
DBGOBOTTOM()
RECUPAN()


ym2 = 3
xm2 = 5

	LOGO(.T., " CAMBIAR PRODUCTOS ")
	SET INTENSITY ON
	SETCOLOR( "W/N,N/W" )
	OX := MYBROWSE( 5, 1, 20, 78, aCpo )
  oTB := OX:GETCOLUMN(3)
	oTB:HEADSEP := "Õ€Õ"
	oTB:COLSEP  := " € "
  OX:SETCOLUMN(3,oTB)
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	
	
	MENUDOWN({"  <+>  ∫    F2    ∫   F6    ∫   F10   ∫ ALT F6  ∫    TAB    ∫ ESC  ",;
				 "       ∫          ∫ elimina ∫         ∫ elimina ∫           ∫      ",;
				 " mueve ∫ modifica ∫  l°nea  ∫ unifica ∫  todo   ∫ productos ∫ sale "})
	
	
	guardar = .F.
	DO WHILE .T.
		
		MOVBROW( OX, {||nK==9.OR.nK==27.OR.nK==K_F6.OR.nK==K_F10.OR.nK==K_ALT_F6},;
			{||nK==999} )
		
		IF OX:Cargo[TB_RET] == K_TAB
			IF TBNOC(OX) == "CODPROD"
				IF FELEGIR( "PRODUCTO", FIELD->CODPROD ) == 0
           	LOOP
          	ELSE
           	IF CODREP(PRD->CODPROD,1)
						FIELD->CODPROD   := PRD->CODPROD
						FIELD->DESCPROD  := PRD->DESCPROD
						FIELD->DESCPROD2 := PRD->DESCPROD
              ENDIF
				ENDIF
			ELSEIF TBNOC(OX) == "CODPROD2"
				IF FELEGIR( "PRODUCTO", FIELD->CODPROD2 ) == 0
           	LOOP
          	ELSE
           	IF CODREP(PRD->CODPROD,2)
						FIELD->CODPROD2  := PRD->CODPROD
 						FIELD->DESCPROD2 := FIELD->DESCPROD
              ENDIF
				ENDIF
        ENDIF
			TBPOS(OX)
				
		ELSEIF OX:Cargo[TB_MSGE] == "MODIF"
			IF TBNOC(OX) == "CODPROD"
 				IF OX:CARGO[TB_CONT] == 0
					FIELD->&(TBNOC(oX)) := OX:CARGO[TB_CONT]
 					FIELD->DESCPROD := ""
 					FIELD->DESCPROD2 := ""
           ELSEIF CODREP(OX:CARGO[TB_CONT],1)
					FIELD->&(TBNOC(oX)) := OX:CARGO[TB_CONT]
  				FIELD->DESCPROD  := FPROD( FIELD->CODPROD )
           ENDIF
			ELSEIF TBNOC(OX) == "CODPROD2"
 				IF OX:CARGO[TB_CONT] == 0
					FIELD->&(TBNOC(oX)) := OX:CARGO[TB_CONT]
 					FIELD->DESCPROD2 := ""
           ELSEIF CODREP(OX:CARGO[TB_CONT],2) .AND. OX:CARGO[TB_CONT]#0
					FIELD->&(TBNOC(oX)) := OX:CARGO[TB_CONT]
 					FIELD->DESCPROD2 := FIELD->DESCPROD
           ENDIF
        ELSE
				FIELD->&(TBNOC(oX)) := OX:CARGO[TB_CONT]
			ENDIF
			TBPOS(OX)
			
		ELSEIF OX:Cargo[TB_RET] == 999
     	nReg := RECNO()
  		SKIP
     	IF EOF()
				DBGOBOTTOM()
				IF FIELD->CODPROD#0 .AND. FIELD->CODPROD2#0
					APPEND BLANK
					TBPOS(OX,.T.)
        	ENDIF
        ELSE
        	GO nReg
				TBPOS(OX)
     	ENDIF
        CLEARTYPEAHEAD()
			
		ELSEIF OX:Cargo[TB_RET] == K_F6
			IF PREGUNTA( 12, "® Est†s Seguro  [ S / N ] ?", "SsNn") $ "Ss"
        	SELECT UC
           ZAP
           APPEND BLANK
				TBPOS(OX,.T.)
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_ALT_F6
			IF PREGUNTA( 12, "® Est†s Seguro  [ S / N ] ?", "SsNn") $ "Ss"
        	ZAP
           APPEND BLANK
				TBPOS(OX,.T.)
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F10
 			IF UPPER( PREGUNTA( 12, "®  COMIENZO PROCESO   [ S / N ] ?", "SsNn") ) == "S"
				MENSAJE (99, 99, 0, .F., "REEMPLAZANDO CODIGOS EN COMPRAS, PLANILLAS, FACTURAS, REMITOS, ETC ...")
				aaux := {{"COMPRAS2","CO2"},{"PLAN2","PL2"},{"AJUSTES","AJ"},{"VARI","VR"},;
							{"FACA2","FA2"},{"FACB2","FB2"},{"REM2","RE2"},{"LUB2","LU2"}}
				SELECT UC
           DELETE FOR UC->CODPROD==0 .OR. UC->CODPROD2==0 .OR. EMPTY(UC->DESCPROD)
           PACK
           FOR b=1 TO LEN(aaux)
           	@ 24,60 SAY PADC(aaux[b,1],10,' ')
					FBASES({"+"+aaux[b,1]}, .F. )
           	SELECT (aaux[b,2])
           	SET ORDER TO
              GO TOP
              SELECT UC
              SET ORDER TO 1
              DO WHILE !(aaux[b,2])->(EOF())
              	IF DBSEEK( (aaux[b,2])->CODPROD ) .AND. (aaux[b,2])->CODPROD#0
              		IF aaux[b,2] $ "FA2 FB2 RE2"
 								IF (aaux[b,2])->NEGOCIO==' '
              				SELECT (aaux[b,2])
 									FRLOCK()
 									FIELD->CODPROD  := UC->CODPROD2
                       	FIELD->DESCPROD := UC->DESCPROD2
 									DBUNLOCK()
                       ENDIF
                    ELSE
              			SELECT (aaux[b,2])
 								FRLOCK()
 								FIELD->CODPROD  := UC->CODPROD2
                       FIELD->DESCPROD := UC->DESCPROD2
 								DBUNLOCK()
                    ENDIF
                 	SELECT UC
                 ENDIF
                 @ 24,70 SAY (aaux[b,2])->FECHA
                 SKIP 1 ALIAS (aaux[b,2])
              ENDDO
					FBASES({"-"+aaux[b,1]}, .F. )
				NEXT b
           @ 24,60 SAY PADC("PROD",10,' ')
				SELECT PRD
           SET ORDER TO
        	GO TOP
        	SELECT UC
        	SET ORDER TO 1
        	DO WHILE !PRD->(EOF())
              IF PRD->CODPROD # 0
        			IF DBSEEK( PRD->CODPROD )
                 	SELECT PRD
 							FRLOCK()
 							FIELD->CODPROD  := UC->CODPROD2
                    FIELD->DESCPROD := UC->DESCPROD2
 							DBUNLOCK()
                    SELECT UC
           		ENDIF
              ENDIF
              @ 24,70 SAY PRD->(LASTREC())-PRD->(RECNO())
           	SKIP 1 ALIAS PRD
        	ENDDO
				SELECT PRD
           SET ORDER TO 1
				SELECT UC
           SET ORDER TO 1
           GO TOP
				RECUPAN()
			ENDIF

		ELSEIF OX:Cargo[TB_RET] == K_ESC
			EXIT
		ENDIF

	ENDDO
	DBUNLOCKALL()
	DBCOMMITALL()

SELECT 99;  DBCLOSEAREA()

RETURN


***************************

STATIC FUNC CODREP( cualcod, cualpos )

***************************
LOCAL r := .T., nOrder:=INDEXORD(), nReg:=RECNO()

SET ORDER TO cualpos
SEEK cualcod
DO WHILE UC->CODPROD2 == cualcod .AND. !EOF()
  IF RECNO() # nReg
		MENSAJE( 0, 0, 10, .T., " ESTE CODIGO YA FUE CARGADO  !!! " )
     r := .F.
     EXIT
  ENDIF
  SKIP
ENDDO
SET ORDER TO nOrder
GO nReg

RETURN r
