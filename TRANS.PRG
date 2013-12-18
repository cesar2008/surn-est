#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOCAL r := .T., lEstaBase1, lEstaBase2
CLEAR

#define  TR_TIPO 	1
#define  TR_BASE		2
#define  TR_BASE2	3
#define  TR_ALIAS	4
#define  TR_ALIAS2	5
#define  TR_NUM		6
#define  TR_TIT		7


IF !lPUBLICO
	MENSAJE( 0, 0, 10, .T., "NO SE PUEDE TRASMITIR DESDE EL PUESTO "+STR(nPUESTO,2)+" !!!" )
  RETURN .F.
ENDIF
IF FT_DEFAULT() == LEFT(cDiscoCentral,1)
	MENSAJE( 0, 0, 10, .T., "EL DISCO DE LA CENTRAL DEBE SER DISTINTO AL ACTUAL  !!!" )
  RETURN .F.
ENDIF
SELECT 1
ABRIR_BASE("TRANS","TRN")
IF LASTREC() == 0
	APPEND BLANK
ENDIF

xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
						"       º graba y º        ",;
						" mueve º procede º  sale  "})
SELECT TRN
aaux := NEWEDIT( "TRANS",,.T. )
FEDITOR( aaux, "LEER" )
aaux[ED_I] := 1
aaux[ED_REGISTRO] := RECNO()
aaux[ED_MODE] = "MOSTRARTODO"
DO WHILE .T.
	FEDITAR( aaux, { K_F10 } )
	IF aaux[ED_UPDATE]
		aaux[ED_MODE] = "MOSTRAR"
  	EDPONE(aaux,,IF(EDCONT(aaux)==' ',' ','S'))
	ELSEIF ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_F10
		FEDITOR(aaux,"GRABAR",.F.)
		EXIT
	ELSEIF aaux[ED_TECLA] == K_ESC
		EXIT
	ENDIF
ENDDO
FEDITOR(aaux,"SACAPAN")
MENUDOWN(xmenu)
IF aaux[ED_TECLA] == K_ESC
	RETURN .F.
ENDIF


aaux := ARRAY( 3 )
aaux[1] := {"XFACA", "FACA","FACA2", "FA","FA2", "NUMFAC", "FACTURAS A" }
aaux[2] := {"XFACB", "FACB","FACB2", "FB","FB2", "NUMFAC", "FACTURAS B" }
aaux[3] := {"XREM",  "REM","REM2",   "RE","RE2", "NUMFAC", "REMITOS" }

axrem  := FAARCH(cDiscoCentral+"\SUR\EST\REMUS.SEQ","CARGAR")
IF FILE(cDiscoCentral+"\SUR\EST\REM.DBF")
	FOR nB=1 TO LEN(aaux)
		IF TRN->&(aaux[nB,TR_TIPO]) == 'S'
			MENSAJE( 99, 99, 0, .F., " TRASLADANDO "+aaux[nB,TR_TIT]+"  A CENTRAL ... " )

     	FBASES({"+"+cDiscoCentral+"\SUR\EST\"+aaux[nB,TR_BASE], "+"+cDiscoCentral+"\SUR\EST\"+aaux[nB,TR_BASE2]})
  		SELECT 98;	lEstaBase1 := ABRIR_BASE( aaux[nB,TR_BASE], "X" )
  		SELECT 99;	lEstaBase2 := ABRIR_BASE( aaux[nB,TR_BASE2], "X2" )

			dUltFecha := DATE()
			nCantidad := 0
			IF lEstaBase1 .AND. lEstaBase2
        	SELECT X2
				INDEX ON &("X2->"+aaux[nB,TR_NUM]) TO XX2

				SELECT X
  			LOCATE FOR X->PASADO == ' '
     		SELECT (aaux[nB,TR_ALIAS])
     		SET ORDER TO FORDER({aaux[nB,TR_NUM]})
     		DO WHILE !X->(EOF())
     			SEEK X->&(aaux[nB,TR_NUM])
        		IF !FOUND()
        			GO TOP
           		IF (aaux[nB,TR_ALIAS])->&(aaux[nB,TR_NUM])#0 .OR. LASTREC()==0
           			ADD_REC()
           		ELSE
           			RLOCK()
              		DBRECALL()
           		ENDIF
              ENDIF
           	FRLOCK()
     			FOR i=1 TO FCOUNT(); (aaux[nB,TR_ALIAS])->&(FIELD(i)):=X->&(FIELD(i)); NEXT
              	// borra las boletas2 para reemplazarlas
           	SELECT (aaux[nB,TR_ALIAS2])
					SEEK X->&(aaux[nB,TR_NUM])
					DO WHILE FOUND().AND.!(aaux[nB,TR_ALIAS2])->(EOF())
						BLANKREG()
						SEEK X->&(aaux[nB,TR_NUM])
					ENDDO
              	//
					SELECT X2
           	SEEK X->&(aaux[nB,TR_NUM])
           	SELECT (aaux[nB,TR_ALIAS2])
           	DO WHILE X2->&(aaux[nB,TR_NUM]) == X->&(aaux[nB,TR_NUM]) .AND. !X2->(EOF())
        			GO TOP
           		IF (aaux[nB,TR_ALIAS2])->&(aaux[nB,TR_NUM])#0 .OR. LASTREC()==0
           			ADD_REC()
           		ELSE
           			FRLOCK()
              		DBRECALL()
           		ENDIF
           		FRLOCK()
     				FOR i=1 TO FCOUNT(); (aaux[nB,TR_ALIAS2])->&(FIELD(i)):=X2->&(FIELD(i)); NEXT
						SKIP 1 ALIAS X2
					ENDDO
        		@ 23,72 SAY ++nCantidad PICT "9999"
        		SELECT (aaux[nB,TR_ALIAS])
					dUltFecha := MAX( dUltFecha, X->FECHA )
           	X->PASADO := "S"
     			SKIP 1 ALIAS X
     		ENDDO
  		ENDIF
        dUltFecha -= 45
        RECUPAN()
			MENSAJE( 99, 99, 0, .F., " BORRANDO  "+aaux[nB,TR_TIT], " ANTERIORES A "+DTOC(dUltFecha) +"..." )
			nCantidad := 0
        SELECT X
        IF !FILE("C:\SUR\EST\PASADO\"+aaux[nB,TR_BASE]+".DBF")
           SELECT X
           COPY STRU TO ("C:\SUR\EST\PASADO\"+aaux[nB,TR_BASE]+".DBF")
        ENDIF
        IF !FILE("C:\SUR\EST\PASADO\"+aaux[nB,TR_BASE2]+".DBF")
        	SELECT X2
          	COPY STRU TO ("C:\SUR\EST\PASADO\"+aaux[nB,TR_BASE2]+".DBF")
        ENDIF
       	SELECT 33
        ABRIR_BASE("C:\SUR\EST\PASADO\"+aaux[nB,TR_BASE],"PA")
       	SELECT 34
        ABRIR_BASE("C:\SUR\EST\PASADO\"+aaux[nB,TR_BASE2],"PA2")

			lBorrar := .T.
        SET DELETED OFF
			SELECT X
        LOCATE FOR X->FECHA < dUltFecha
        DO WHILE !X->(EOF())
        	IF X->FECHA<dUltFecha .AND. X->PASADO == 'S'
           	IF lBorrar
           		ERASEFILE( "F*.NTX" )
          			ERASEFILE( "R*.NTX" )
           	ENDIF
					lBorrar := .T.
        		SELECT X2
           	SEEK X->&(aaux[nB,TR_NUM])
           	DO WHILE X2->&(aaux[nB,TR_NUM])==X->&(aaux[nB,TR_NUM])
              	SELECT PA2
                 APPEND BLANK
     				FOR i=1 TO FCOUNT(); PA2->&(FIELD(i)):=X2->&(FIELD(i)); NEXT
                 SELECT X2
           		DELETE
           		SKIP
           	ENDDO
              SELECT PA
              APPEND BLANK
     			FOR i=1 TO FCOUNT(); PA->&(FIELD(i)):=X->&(FIELD(i)); NEXT
           	SELECT X
           	DELETE
        		@ 23,72 SAY ++nCantidad PICT "9999"
           ENDIF
           SKIP 1 ALIAS X
        ENDDO
        IF nCantidad # 0
        	SELECT X
        	PACK
        	SELECT X2
        	PACK
*          ERASEFILE( LEFT(aaux[nB,TR_BASE],2)+"*.NTX" )
        ENDIF
  		RECUPAN()
     ENDIF
  NEXT



	IF TRN->XCLA == 'S'
  	DO WHILE .T.
  		r := .T.
  		SELECT 99
  		IF !ABRIR_BASE(cDiscoCentral+"\SUR\EST\CLA", 'X')
     		MENSAJE( 0, 0, 60, .T., "EL ARCHIVO DE CLIENTES EN OTROS",;
											"PUESTO/S NO DEBE SER USADO",;
                             	"DURANTE ESTE PROCESO !!!",;
                                "<<< [C] cancela    [ENTER] reintenta >>>" )
				r := .F.
           IF CHR(LASTKEY()) $ "Cc"
           	EXIT
           ENDIF
        ELSE
        	EXIT
  		ENDIF
     ENDDO
  	SELECT 99;	DBCLOSEAREA()
  	IF r
			MENSAJE( 99, 99, 0, .F., " TRASLADANDO CLIENTES CON CUIT A CENTAL ... " )
			COPY FILE C:\SUR\EST\CLA.DBF TO (cDiscoCentral+"\SUR\EST\CLA.DBF")
        ERASEFILE( cDiscoCentral+"\SUR\EST\CLA*.NTX" )
 			RECUPAN()
  	ENDIF
  ENDIF


	IF TRN->XPROD == 'S'
		MENSAJE( 99, 99, 0, .F., " ACTUALIZANDO PRODUCTOS ... " )
		COPY FILE (cDiscoCentral+"\SUR\EST\PROD.DBF") TO C:\SUR\EST\PROD.DBF
		ERASE PRDCOD.NTX
		ERASE PRDDESC.NTX
  	RECUPAN()
  ENDIF

	IF TRN->XCLCC == 'S'
		MENSAJE( 99, 99, 0, .F., " ACTUALIZANDO CLIENTES CTACTE ... " )
		COPY FILE (cDiscoCentral+"\SUR\EST\CLIENTES.DBF") TO C:\SUR\EST\CLIENTES.DBF
		ERASE CLRAZSOC.NTX
		ERASE CLCUIT.NTX
  	RECUPAN()
  ENDIF

	IF TRN->XART == 'S'
		MENSAJE( 99, 99, 0, .F., " ACTUALIZANDO ARTICULOS DEL SERVICOMPRAS ... " )
		COPY FILE (cDiscoCentral+"\SUR\MIN\PROD.DBF") TO C:\SUR\MIN\PROD.DBF
		ERASE \SUR\MIN\ARTCOD.NTX
  	RECUPAN()
  ENDIF

ELSE
	MENSAJE( 0, 0, 10, .T., "NO ESTAMOS CONECTADOS CON LA CENTRAL !!!" )
  r := .F.

ENDIF

RETURN r



***************************************

STATIC FUNC ABRIR_BASE( cBase, cAlias )

***************************************

USE (cBase) ALIAS (cAlias) EXCLUSIVE

RETURN ( !NETERR() )
