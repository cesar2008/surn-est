LOCAL aCpo, oGET, nReg, aaux, areg, xaux, aux

*#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

aCpo:={{ "NOMBASE",    "Nombre;archivo",                     '', 'E',  '',  0, 0 },;
		  { "DISCO",      "Disco",                            '!:', 'M',  '',  0, 0 },;
		  { "CAMINO",     "Camino",                             '', 'E',  '',  0, 0 },;
		  { "SISTEMA",    "Sistema",                            '', 'E',  '',  0, 0 },;
		  { "SUBSISTEMA", "SubSist",                            '', 'E',  '',  0, 0 } }

SELECT 1
ABRIRBASE2( "DBFS","DBF",{{"DBF->NOMBASE"}} )
SELECT DBF

CLEAR
MENUDOWN({" <+> ºF2 modif.º  F5  º    F6       ºSH F8 al-ºESC  ",;
			  "     ºF3 busca º      ºelimina l¡neaº   macenaº     ",;
			  "mueveºF4 busca+ºagregaºF7    imprimeºF8 repiteºsale "})

SETCOLOR( "W/N,N/W" )

PRIVATE oX := MYBROWSE( 1, 1, 20, 78, aCpo )

oX:CARGO[TB_REFRESH] := 0
oX:GOTOP()
xRep:=""
DO WHILE .T.
	
	MOVBROW( oX, {||nK==K_TAB.OR.nK==K_F5.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_F8.OR.nK==K_F7.OR.nK==K_F9.OR.nK==K_SH_F8} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_TAB .AND. EMPTY(DBF->FECHCIERRE)
		IF TBNOC(OX) == "CODTARJ"
			e = ABRW( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 'vtarjeta', DBF->CODTARJ, 'TARJETAS')
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->CODTARJ := LEFT( vtarjeta[e], 3 )
			ENDIF
		ELSEIF TBNOC(OX) == "TURNO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aturno, DBF->TURNO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->TURNO := LEFT(aturno[e],1)
			ENDIF
			RECUPAN()
		ELSEIF TBNOC(OX) == "ESTADO"
			e = PP_SELEC( oX:CARGO[TB_FILA], oX:CARGO[TB_COL], 0, 0, aestado, FIELD->ESTADO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
				FRLOCK()
				FIELD->ESTADO := LEFT(aestado[e],3)
			ENDIF
			RECUPAN()
		ENDIF
		TBPOS(OX)
	ELSEIF oX:Cargo[TB_RET] == K_F5
		GO TOP
		IF !EMPTY(DBF->NOMBASE) .OR. LASTREC()==0
			ADD_REC()
		ENDIF
     frlock()
     dbrecall()
     dbunlock()
		TBPOS(OX,.T.)
	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	nReg:=RECNO(); SKIP -1; nReg2:=RECNO(); GO nReg
			BLANKREG(.T.)
			GO nReg2
			TBPOS(OX,.T.)
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_SH_F8
  	xRep := FIELD->&(TBNOC(OX))
		xRep := INGRVAL(10,20, "Repetir:", xRep, "", "")
	ELSEIF oX:Cargo[TB_RET] == K_F8
		IF TBNOC(OX) # "NOMBASE"
			FRLOCK()
			FIELD->&(TBNOC(OX)) := xRep
			TBPOS(OX)
     ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_F8
		IF TBNOC(OX) # "NOMBASE"
  		nReg:=RECNO()
     	SKIP -1
			aux := FIELD->&(TBNOC(OX))
     	GO nReg
			FRLOCK()
			FIELD->&(TBNOC(OX)) := aux
			TBPOS(OX)
     ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F9
		op = MENUFLASH( 10, 30, 1, .T., "UTILIDADES","VER LA BASE DE DATOS ",;
 																	"RECOLECTAR BASES     ",;
 																	"PACK                 " )
		IF op == 1
        aux := ALLTRIM(DBF->DISCO)+ALLTRIM(DBF->CAMINO)+ALLTRIM(DBF->NOMBASE)
        IF FILE(aux)
     		SELECT 2
        	ABRIRBASE2( aux )
        	DBEDIT()
        ENDIF
        SELECT 1
			TBPOS(OX,.T.)
		ELSEIF op == 2
     	aaux := DIRECTORY("*.DBF")
        FOR i=1 TO LEN(aaux)
        	IF !DBSEEK(aaux[i,1])
        		IF !DBSEEK(SPACE(LEN(DBF->NOMBASE))) .OR. LASTREC()==0
           		ADD_REC()
                 FRLOCK()
                 DBF->NOMBASE := aaux[i,1]
                 DBF->CAMINO  := "UT_SISTEMA+'"+ SUBSTR(CURDIR(),RAT('\',CURDIR())) +"\'"
                 DBUNLOCK()
              ENDIF
           ENDIF
        NEXT
			TBPOS(OX,.T.)
		ELSEIF op == 3
			SELECT DBF
			ABRIRBASE2( "DBFS","DBF",{{"DBF->NOMBASE"}},,.F. )
			SELECT DBF
     	PACK
			SELECT DBF
			ABRIRBASE2( "DBFS","DBF",{{"DBF->NOMBASE"}} )
			TBPOS(OX,.T.)
     ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_F7
*		LISTADOR( "TARJAPRE" )
		
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
  DBUNLOCK()

ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN
