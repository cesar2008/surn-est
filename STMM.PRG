LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO(.T., " INVENTARIO / STOCK " )

MENSAJE( 0, 0, 0, .F., "AGUARDE ..." )

aCpo:={;
	{ "CODPROD",           "C¢digo; ",                             '', 'F',  '',  0, 0 },;
	{ "DESCPROD",          "Descripci¢n",              REPLIC('!',20), 'F',  '',  0, 0 },;
	{ "CONDEP",            "Con;Dep",                             '!', 'F',  '',  0, 0 },;
	{ "STOCKACT+STOCKACTD","Stock;Actual",               '999999.999', 'F', 'F', 10, 3 },;
	{ "STOCKMIN",          "Stock;M¡nimo;Local",                   '', 'M',  '',  0, 0 },;
	{ "STOCKMIND",         "Stock;M¡nimo;Dep¢sito",                '', 'M',  '',  0, 0 },;
	{ "STOCKMAX",          "Stock;M ximo;Local",                   '', 'M',  '',  0, 0 },;
	{ "STOCKMAXD",         "Stock;M ximo;Dep¢sito",                '', 'M',  '',  0, 0 } }

SELECT ART
aCpo := FBASEAUX( aCpo, "ART", SELECT(), .F. )
IF EOF()
	SKIP -10
ENDIF
RECUPAN()

SETCOLOR( "W/N,N/W" )
OX := MYBROWSE( 5, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 5

MENUDOWN({ "  <+>  º                F10               º ESC  ",;
			  	"       º sugiere el stock M ximo y M¡nimo º      ",;
				" mueve º en base a las compras y ventas.  º sale "})
DO WHILE .T.
	
	MOVBROW( OX, {||nK==9.OR.nK==K_ESC.OR.nK==K_F10.OR.nK==K_F9.OR.nK==K_F3.OR.nK==K_F4.OR.nK==K_F8.OR.nK==K_ALT_E } )

	IF OX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
     IF TBNOC(OX) $ "STOCKACT"
     	ART->STOCKINI := ART->STOCKACT
        ART->FECHA    := M->FECHA
     ELSEIF TBNOC(OX) $ "STOCKACTD"
     	ART->STOCKINID := ART->STOCKACTD
        ART->FECHA     := M->FECHA
        IF ART->STOCKINID # 0
        	ART->CONDEP := 'S'
        ENDIF
     ELSEIF TBNOC(OX) == "CONDEP"
     	IF ART->CONDEP # "S"
        	ART->STOCKACT  += ART->STOCKACTD
        	ART->STOCKACTD := 0
        ENDIF
     ENDIF
		DBUNLOCK()
		TBPOS(OX)

	ELSEIF OX:Cargo[TB_RET] == K_F10
		IF PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") $ "Ss"
			MENSAJE( 99, 99, 0, .F., "PROCESANDO... " )
       	restscr := 1
    		SELECT ART
        SET ORDER TO
     	xreg := RECNO()
        FFLOCK()
        REPLACE  ART->STOCKACT WITH ART->STOCKINI,;
        			ART->STOCKACTD WITH ART->STOCKINID
     	SET ORDER TO FORDER({"CODPROD"})
     	DBUNLOCKALL()

           ++restscr
    			FBASES({"COMPRAS2"})
				INIVER(" COMPRAS ",10,10,60)
				verindex = .T.
     		GO TOP
     		SELECT ART
     		DO WHILE !CO2->(EOF())
          		SEEK CO2->CODPROD
           	IF FOUND() .AND. CO2->FECHA>=ART->FECHA
              	FRLOCK()
                 IF ART->CONDEP == 'S'
        			ART->STOCKACTD += FCANT( CO2->CANTIDAD, CO2->UNXCAJA )
                 ELSE
        				ART->STOCKACT  += FCANT( CO2->CANTIDAD, CO2->UNXCAJA )
                 ENDIF
              	DBUNLOCK()
        		ENDIF
					VER('')
           	SKIP 1 ALIAS CO2
				ENDDO

           ++restscr
    			FBASES({"TICKETS2"})
				SELECT TI2
				INIVER(" TICKETS ",12,10,60)
     		GO TOP
     		SELECT ART
     		DO WHILE !TI2->(EOF())
          		SEEK TI2->CODPROD
           	IF FOUND() .AND. TI2->FECHA>=ART->FECHA
              	FRLOCK()
        			ART->STOCKACT -= TI2->CANTIDAD
              	DBUNLOCK()
        		ENDIF
					VER('')
           	SKIP 1 ALIAS TI2
				ENDDO

           ++restscr
    			FBASES({"AJUSTES"})
				INIVER(" AJUSTES ",14,10,60)
     		GO TOP
     		SELECT ART
     		DO WHILE !AJU->(EOF())
           	SEEK AJU->CODPROD
           	IF FOUND() .AND. AJU->FECHA>=ART->FECHA
              	FRLOCK()
        			ART->AJUSTES += AJU->CANTIDAD
        			ART->STOCKACT := ART->STOCKINI + ART->COMPRAS - ART->VENTAS + ART->AJUSTES - ART->FACTURAS
              	DBUNLOCK()
        		ENDIF
					VER('')
           	SKIP 1 ALIAS AJU
				ENDDO

				++restscr
    			FBASES({"\SUR\EST\FACA","\SUR\EST\FACA2"})
     		SELECT FA2
				INIVER(" FACTURAS A ",16,10,60)
           LOCATE FOR FA2->NEGOCIO=="*"
     		DO WHILE !FA2->(EOF())
           	IF FA2->NEGOCIO == "*"
           		SELECT FA; SEEK FA2->NUMFAC; aux:=FA->FECHA
     				SELECT ART
           		SEEK FA2->CODPROD
           		IF FOUND() .AND. aux>=ART->FECHA
              		FRLOCK()
        				ART->FACTURAS += FA2->CANTIDAD
        				ART->STOCKACT := ART->STOCKINI + ART->COMPRAS - ART->VENTAS + ART->AJUSTES - ART->FACTURAS
              		DBUNLOCK()
        			ENDIF
              ENDIF
					VER('')
           	SKIP 1 ALIAS FA2
				ENDDO
				++restscr
    			FBASES({"\SUR\EST\FACB","\SUR\EST\FACB2"})
     		SELECT FB2
				INIVER(" FACTURAS B ",18,10,60)
           LOCATE FOR FB2->NEGOCIO=="*"
     		DO WHILE !FB2->(EOF())
           	IF FB2->NEGOCIO == "*"
           		SELECT FB; SEEK FB2->NUMFAC; aux:=FB->FECHA
     				SELECT ART
           		SEEK FB2->CODPROD
           		IF FOUND() .AND. aux>=ART->FECHA
              		FRLOCK()
        				ART->FACTURAS += FB2->CANTIDAD
        				ART->STOCKACT := ART->STOCKINI + ART->COMPRAS - ART->VENTAS + ART->AJUSTES - ART->FACTURAS
              		DBUNLOCK()
        			ENDIF
              ENDIF
					VER('')
           	SKIP 1 ALIAS FB2
				ENDDO
				++restscr
    			FBASES({"\SUR\EST\REM","\SUR\EST\REM2"})
     		SELECT RE2
				INIVER(" REMITOS ",20,10,60)
           LOCATE FOR RE2->NEGOCIO=="*"
     		DO WHILE !RE2->(EOF())
           	IF RE2->NEGOCIO == "*"
           		SELECT RE; SEEK RE2->NUMFAC; aux:=RE->FECHA
     				SELECT ART
           		SEEK RE2->CODPROD
           		IF FOUND() .AND. aux>=ART->FECHA
              		FRLOCK()
        				ART->FACTURAS += RE2->CANTIDAD
        				ART->STOCKACT := ART->STOCKINI + ART->COMPRAS - ART->VENTAS + ART->AJUSTES - ART->FACTURAS
              		DBUNLOCK()
        			ENDIF
              ENDIF
					VER('')
           	SKIP 1 ALIAS RE2
				ENDDO

        FOR i=1 TO restscr
     		RECUPAN()
        NEXT
        SELECT ART
     	DBUNLOCKALL()
     	GO xreg
 			TBPOS(OX,.T.)
     ENDIF

	ELSEIF OX:Cargo[TB_RET] == K_F3 .OR. OX:Cargo[TB_RET] == K_F4
  	BUSCADOR( OX:CARGO[TB_RET], OX )

	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF

ENDDO


RETURN
