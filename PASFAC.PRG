LOCAL aux:=SAVESCREEN(0,0,24,79)

#include "BL.CH"
#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

IF QUEFECHA2( 10, 25 )
	FBASES({"+FACA","+FACA2","+FACB","+FACB2"})
	aaux:=FALTAN({DESDE,HASTA},"AB")
  IF aaux[2]+aaux[3] # 0
		MENSAJE( 0, 0, 10, .T., "FALTAN FACTURAS !!!","OPERACION CANCELADA." )
  ENDIF
	cDisco := INGRVAL( 10, 20, "A QUE DISCO:", "A:", "!:", "")
  IF LASTKEY() == K_ENTER
  	DO WHILE !DISCOESTA(LEFT(cDisco,1))
			MENSAJE( 0, 0, 0, .F., "No Puedo Grabar en el disco "+cDisco,"ENTER reintenta","ESC cancela" )
     	INKEY(0)
     	RECUPAN()
 			IF LASTKEY() == K_ESC
     		RETURN .F.
     	ENDIF
  	ENDDO

     cDestino := cDisco+"\EST"
     n := 10
    	DO WHILE LEN(DIRECTORY(cDestino,"D")) == 0 .AND. --n # 0
     	FT_MKDIR( cDestino )
     ENDDO
     IF LEN(DIRECTORY(cDestino,"D")) == 0
			MENSAJE( 0, 0, 0, .F., "No Puedo Grabar en "+cDestino,"ENTER reintenta","ESC cancela" )
     	INKEY(0)
     	RECUPAN()
 			IF LASTKEY() == K_ESC
     		RETURN .F.
     	ENDIF
  	ENDIF

		MENSAJE( 99, 99, 0, .F., "   AGUARDE   . . .", " ", " ", " " )

		xcant := 0
  	@ 20,60 say "Fact. A"
		FBASES({"FACA"},.F.)
  	SELECT FA
		COPY TO (cDestino+"\FACA") FOR FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. EVAL({||DEVPOS(20,70),DEVOUTPICT(++xcant,"99999"),.T.})

		xcant:=0
  	@ 21,60 say "Fact. B"
		FBASES({"FACB"},.F.)
  	SELECT FB
		COPY TO (cDestino+"\FACB") FOR FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. EVAL({||DEVPOS(21,70),DEVOUTPICT(++xcant,"99999"),.T.})

		xcant:=0
  	@ 22,60 say "Compras"
		FBASES({"COMPRAS"},.F.)
  	SELECT CO
		COPY TO (cDestino+"\COMPRAS") FOR FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. EVAL({||DEVPOS(22,70),DEVOUTPICT(++xcant,"99999"),.T.})

		xcant:=0
  	@ 23,60 say "Compras V."
		FBASES({"COMPRASV"},.F.)
  	SELECT CV
		COPY TO (cDestino+"\COMPRASV") FOR FIELD->FECHA>=DESDE .AND. FIELD->FECHA<=HASTA .AND. EVAL({||DEVPOS(23,70),DEVOUTPICT(++xcant,"99999"),.T.})

		RECUPAN()
  ENDIF

ENDIF
RESTSCREEN(0,0,24,79,aux)

RETURN
