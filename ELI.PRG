PRIVATE aCPO

#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
SELECT 99;  DBCLOSEAREA()
IF !FILE("ELI.DBF")
	CREARBASE("ELI", "CODPROD N 4", "DESCPROD C 20", "PRECIO N 10 2" )
ENDIF
SELECT 99
ABRIR_BASE( "ELI", "ELI", "ELI->CODPROD", "ELIART" )
USE ELI ALIAS ELI EXCLUSIVE INDEX ELIART

aCpo:={;
	{ "CODPROD",    "C¢d;Prod.",                          '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                      '', 'F',  '',  0, 0 },;
	{ "PRECIO",     "Precio; ",                           '', 'F',  '',  0, 0 } }

SELECT ELI
aCpo := FARRAYAUX( aCpo )
IF LASTREC() == 0
	APPEND BLANK
ENDIF
SET ORDER TO
DBGOBOTTOM()
RECUPAN()


ym2 = 3
xm2 = 5

	LOGO(.T., " ELIMINAR CODIGOS ")
	***
	* Ingreso de Fecha
	***

	SET INTENSITY ON
	SETCOLOR( "W/N,N/W" )
	OX := MYBROWSE( 5, 1, 20, 78, aCpo )
	OX:CARGO[TB_REFRESH] := 0
	OX:GOTOP()
	
	
	MENUDOWN({"  <+>  º    F2    º   F6    º   F10   º ALT F6  º    TAB    º ESC  ",;
				 "       º          º elimina º borra   º elimina º           º      ",;
				 " mueve º modifica º  l¡nea  º los cod.º  todo   º productos º sale "})
	
	
	guardar = .F.
	DO WHILE .T.
		
		MOVBROW( OX, {||nK==9.OR.nK==27.OR.nK==K_F6.OR.nK==K_F10.OR.nK==K_ALT_F6},;
			{||nK==999} )
		
		IF OX:Cargo[TB_RET] == K_TAB
			IF TBNOC(OX) == "CODPROD"
				IF FELEPROD( FIELD->CODPROD ) == 0
           	LOOP
          	ELSE
           	IF CODREP(ART->CODPROD,1)
						FIELD->CODPROD  := ART->CODPROD
						FIELD->DESCPROD := ART->DESCPROD
                 FIELD->PRECIO   := ART->PRECIO
              ENDIF
				ENDIF
        ENDIF
			TBPOS(OX)
				
		ELSEIF OX:Cargo[TB_MSGE] == "MODIF"
			IF TBNOC(OX) == "CODPROD"
           IF CODREP(OX:CARGO[TB_CONT],1)
					FIELD->&(TBNOC(oX)) := OX:CARGO[TB_CONT]
  				FIELD->DESCPROD  := FPROD( FIELD->CODPROD )
           	FIELD->PRECIO    := nPRECIO
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
				IF FIELD->CODPROD#0
           	SET ORDER TO 1
					xreg := F_ALTA( 0 )
           	SET ORDER TO
     			DBGOTO(xreg)
					TBPOS(OX,.T.)
        	ENDIF
        ELSE
        	GO nReg
				TBPOS(OX)
     	ENDIF
        CLEARTYPEAHEAD()
			
		ELSEIF OX:Cargo[TB_RET] == K_F6
			IF PREGUNTA( 12, "¨ Est s Seguro  [ S / N ] ?", "SsNn") $ "Ss"
        	BLANKREG()
				TBPOS(OX,.T.)
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_ALT_F6
			IF PREGUNTA( 12, "¨ Est s Seguro  [ S / N ] ?", "SsNn") $ "Ss"
        	ZAP
           APPEND BLANK
				TBPOS(OX,.T.)
			ENDIF
			
		ELSEIF OX:Cargo[TB_RET] == K_F10
 			IF UPPER( PREGUNTA( 12, "¨  PROCEDO A ELIMINAR CODIGOS  [ S / N ] ?", "SsNn") ) == "S"
				MENSAJE( 99, 99, 0, .F., " ELIMINANDO CODIGOS . . .", "                " )
           nReg := RECNO()

        	SELECT ELI
        	GO TOP
        	SELECT ART
        	SET ORDER TO 1
        	DO WHILE !ELI->(EOF())
           	@ 23, 60 SAY STR(ELI->CODPROD)
					?? LEFT(ELI->DESCPROD,15)
           	SEEK ELI->CODPROD
           	DO WHILE FOUND()
              	BLANKREG(.T.)
                 DBUNLOCK()
           		SEEK ELI->CODPROD
           	ENDDO
        		SKIP 1 ALIAS ELI
        	ENDDO

				SELECT ELI
           ZAP
        	APPEND BLANK
        	SET ORDER TO
				RECUPAN()
			ENDIF
     	SELECT ELI
     	OX:GOTOP()
			
		ELSEIF OX:Cargo[TB_RET] == K_F10
        FBASES({"VENTAS"})
        SET ORDER TO FORDER({"FTOC(VE->FECHA+VE->HORA"})
        SET SOFTSEEK ON
        SEEK FTOC(DATE())
        SET SOFTSEEK OFF
        IF VE->FECHA < DATE() .AND. VA->CTRLZ=='S'
				MENSAJE( 0, 0, 10, .T., "ANTES DE ELIMINAR PRODUCTOS", "HAY QUE SACAR LA 'Z' DEL DIA !!!" )
        ELSE
 				IF UPPER( PREGUNTA( 12, "¨  PROCEDO A ELIMINAR CODIGOS  [ S / N ] ?", "SsNn") ) == "S"
					MENSAJE( 0, 0, 0, .F., " ELIMINANDO CODIGOS . . ." )
           	nReg := RECNO()
  				SELECT ART
     			nBase := SELECT(); DBCLOSEAREA()
					DBSELECTAREA( nBase )
					USE PROD ALIAS ART EXCLUSIVE
     			IF NETERR()
						MENSAJE( 0, 0, 10, .T., "PARA ESTE PROCESO LOS ARCHIVOS", "NO DEBEN SER COMPARTIDOS  !!!" )
					ELSE
              	SELECT ELI
                 GO TOP
                 SELECT VA
        			SET ORDER TO FORDER({"BORRADO"})
                 FFLOCK()
                 DO WHILE !ELI->(EOF())
                 	SEEK STR(ELI->CODPROD)+" "
                    DO WHILE FOUND()
                 		VA->BORRADO := "S"
                 		SEEK STR(ELI->CODPROD)+" "
                    ENDDO
                 	SKIP 1 ALIAS ELI
                 ENDDO

              	SELECT ELI
                 GO TOP
                 FBASES({"COMPRAS2"})
                 SELECT CO2
        			SET ORDER TO FORDER({"BORRADO"})
                 FFLOCK()
                 SET SOFTSEEK ON
                 DO WHILE !ELI->(EOF())
                 	SEEK STR(ELI->CODPROD)
                    DO WHILE CO2->CODPROD==ELI->CODPROD
                 		CO2->BORRADO := "S"
                 		SKIP
                    ENDDO
                 	SKIP 1 ALIAS ELI
                 ENDDO
                 SET SOFTSEEK OFF

						SELECT ART
        			GO TOP
        			SELECT ELI
        			SET ORDER TO 1
        			DO WHILE !ART->(EOF())
              		IF ART->CODPROD # 0
        					SEEK ART->CODPROD
           				IF FOUND()
                 			SELECT ART
           					DELETE
                    		SELECT ELI
           				ENDIF
              		ENDIF
           			SKIP 1 ALIAS ART
        			ENDDO
           		PACK
              	ERASEFILE("ART*.NTX")
           	ENDIF
     			FREABRIR({"PROD"})
					SELECT ELI
           	SET ORDER TO
           	GO nReg
					RECUPAN()
           ENDIF
			ENDIF
        SELECT ELI
        OX:GOTOP()

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

SET ORDER TO 1
SEEK cualcod
DO WHILE ELI->CODPROD == cualcod .AND. !EOF()
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
