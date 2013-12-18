PARAMETERS afecha, cModo
LOCAL cXF, cBase:=DBF(), nReg:=RECNO(), aux:=SAVESCREEN(0,0,24,79), acant:={0,0,0}

#include "BL.CH"
#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

DEFAULT cModo TO "RAB"

r := .T.
IF aFecha == NIL
	r := QUEFECHA2( 10, 25 )
ELSE
	DESDE := afecha[1]
  HASTA := afecha[2]
ENDIF
IF r
	MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
 	SET CONSOLE OFF
	SET ALTERNATE TO QQ
	SET ALTERNATE ON


	IF "R" $ cModo
		SELECT RE
		?
		? "<<<   REMITOS   >>>"
*		LOCATE FOR FIELD->FECHA>=DESDE
     SET ORDER TO FORDER({"FECHA"})
		DBSEEK( FTOC(DESDE),.T.)
     SET ORDER TO 1
		R := FIELD->NUMFAC+1
		SKIP
		DO WHILE FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. !EOF()
			IF FIELD->NUMFAC > R
  			IF ( FIELD->NUMFAC-1 - R ) > 100
     			? FIELD->FECHA, "(", ALLTRIM(STR(R)) ,"...", ALLTRIM(STR(FIELD->NUMFAC-1)), ")"
        		acant[1]   += (FIELD->NUMFAC-1 - R)
        	ELSE
  				FOR x=R TO FIELD->NUMFAC-1
     				? FIELD->FECHA,"(", ALLTRIM(STR(x)), ")"
        			++acant[1]
					NEXT
        	ENDIF
			ENDIF
			R := FIELD->NUMFAC+1
			SKIP
		ENDDO
		? "---------------"
		? acant[1]
  ENDIF


	IF "A" $ cModo
		?
		? "<<<   FACTURAS  A   >>>"
		DBSELECTAREA("FA")
*		LOCATE FOR FIELD->FECHA>=DESDE
     SET ORDER TO FORDER({"FECHA"})
		DBSEEK( FTOC(DESDE),.T.)
     SET ORDER TO 1
		R=FIELD->NUMFAC+1
		SKIP
		DO WHILE FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. !EOF()
			IF FIELD->NUMFAC > R
  			IF ( FIELD->NUMFAC-1 - R ) > 100
     			? FIELD->FECHA,"(", ALLTRIM(STR(R)),"...", ALLTRIM(STR(FIELD->NUMFAC-1)), ")"
        		acant[2]   += (FIELD->NUMFAC-1 - R)
           ELSE
  				FOR x=R TO FIELD->NUMFAC-1
     				? FIELD->FECHA,"(", ALLTRIM(STR(x)), ")"
           		++acant[2]
					NEXT
           ENDIF
			ENDIF
			R := FIELD->NUMFAC+1
			SKIP
		ENDDO
		? "---------------"
  	? acant[2]
  ENDIF


	IF "B" $ cModo
		?
		? "<<<   FACTURAS  B   >>>"
		DBSELECTAREA("FB")
*		LOCATE FOR FIELD->FECHA>=DESDE
     SET ORDER TO FORDER({"FECHA"})
		DBSEEK( FTOC(DESDE),.T.)
     SET ORDER TO 1
		R=FIELD->NUMFAC+1
		SKIP
		DO WHILE FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. !EOF()
			IF FIELD->NUMFAC > R
  			IF ( FIELD->NUMFAC-1 - R ) > 100
     			? FIELD->FECHA,"(", ALLTRIM(STR(R)),"...", ALLTRIM(STR(FIELD->NUMFAC-1)), ")"
        		acant[3]   += (FIELD->NUMFAC-1 - R)
           ELSE
  				FOR x=R TO FIELD->NUMFAC-1
     				? FIELD->FECHA,"(", ALLTRIM(STR(x)), ")"
           		++acant[3]
					NEXT
           ENDIF
			ENDIF
			R := FIELD->NUMFAC+1
			SKIP
		ENDDO
		? "---------------"
  	? acant[3]
  ENDIF

	SET ALTERNATE OFF
	SET ALTERNATE TO
	SET CONSOLE ON
	SET SOFTSEEK OFF
	DBSELECTAREA(cBase)
	GO nReg
	RECUPAN()

  IF (acant[1]+acant[2]+acant[3]) # 0
  	DO WHILE .T.
			op = MENUFLASH( 12, 30, 1, .T., "", "VER BOLETAS QUE FALTAN     ",;
														   "IMPRIMIR BOLETAS QUE FALTAN" )
			IF op == 1
				RUN ..\VERTXT QQ.TXT
     	ELSEIF op == 2
				RUN TYPE QQ.TXT>LPT1
     	ELSEIF LASTKEY() == K_ESC
        	EXIT
			ENDIF
     ENDDO
  ENDIF

ENDIF
RESTSCREEN(0,0,24,79,aux)

RETURN acant
