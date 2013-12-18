#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), nB, xmenu

aTicket  := {0,0,0,0}
aTdde := {0,0,0,0}
aThta := {0,0,0,0}

aFactura := {0,0,0,0}
aRemito  := {0,0,0,0}
aTotal   := {0,0,0,0}


cDturno := cHturno := "1"
MARCO( 10, 20, 12, 60, "", "S", .T. )
SET(_SET_CURSOR,SC_ON)
@10,20 SAY "      Fecha:" GET DESDE
@11,20 SAY "Desde Turno:" GET cDturno PICT "!" VALID cDturno $ '1234'
@12,20 SAY "Hasta Turno:" GET cHturno PICT "!" VALID cHturno $ '1234' .AND. cHturno>=cDturno
READ
HASTA := DESDE + IF(cHturno=='4', 1, 0 )
xaux := ""
FOR i=VAL(cDturno) TO VAL(cHturno)
	xaux += FTOC(IF(i==4,HASTA,DESDE)) + STR(i,1) +" "
NEXT
IF LASTKEY() == K_ENTER
	MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
  SELECT TI
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE TI->FECHA>=DESDE .AND. TI->FECHA<=HASTA .AND.!TI->(EOF())
     IF FTOC(TI->FECHA)+TI->TURNO+" " $ xaux
     	aTdde[VAL(TI->TURNO)] := IF( aTdde[VAL(TI->TURNO)]==0, TI->NUMFAC, MIN(TI->NUMFAC,aTdde[VAL(TI->TURNO)]) )
     	aThta[VAL(TI->TURNO)] := MAX( TI->NUMFAC, aThta[VAL(TI->TURNO)] )
     	SELECT TI2
        DBSEEK(TI->NUMFAC)
        DO WHILE TI2->NUMFAC == TI->NUMFAC
        	aTicket[VAL(TI->TURNO)]   += TI2->IMPORTE
           SKIP 1 ALIAS TI2
        ENDDO
     ENDIF
     SKIP 1 ALIAS TI
	ENDDO
  SELECT TI
  SET ORDER TO 1

  SELECT FA
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE FA->FECHA>=DESDE .AND. FA->FECHA<=HASTA .AND.!FA->(EOF())
  	IF FTOC(FA->FECHA)+FA->TURNO+" " $ xaux
     	SELECT FA2
       	DBSEEK(FA->NUMFAC)
        DO WHILE FA2->NUMFAC == FA->NUMFAC
       		IF FA2->NEGOCIO == '*'
              aFactura[VAL(FA->TURNO)] += FA2->IMPORTE
           ENDIF
          	SKIP 1 ALIAS FA2
        ENDDO
     ENDIF
     SKIP 1 ALIAS FA
	ENDDO
  SELECT FA
  SET ORDER TO 1

  SELECT FB
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE FB->FECHA>=DESDE .AND. FB->FECHA<=HASTA .AND.!FB->(EOF())
  	IF FTOC(FB->FECHA)+FB->TURNO+" " $ xaux
     	SELECT FB2
        DBSEEK(FB->NUMFAC)
        DO WHILE FB2->NUMFAC == FB->NUMFAC
        	IF FB2->NEGOCIO == '*'
              aFactura[VAL(FB->TURNO)] += FB2->IMPORTE
           ENDIF
           SKIP 1 ALIAS FB2
        ENDDO
     ENDIF
     SKIP 1 ALIAS FB
	ENDDO
  SELECT FB
  SET ORDER TO 1

  SELECT RE
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE RE->FECHA>=DESDE .AND. RE->FECHA<=HASTA .AND.!RE->(EOF())
  	IF FTOC(RE->FECHA)+RE->TURNO+" " $ xaux
     	SELECT RE2
        DBSEEK(RE->NUMFAC)
        DO WHILE RE2->NUMFAC == RE->NUMFAC
       		IF RE2->NEGOCIO == '*'
              aRemito[VAL(RE->TURNO)] += RE2->IMPORTE
           ENDIF
           SKIP 1 ALIAS RE2
        ENDDO
		ENDIF
     SKIP 1 ALIAS RE
	ENDDO
  SELECT RE
  SET ORDER TO 1
  SELECT (cBase)
  GO nReg
  RECUPAN()

*	IF EST->SALIDA == "PAN"
*		mbuz:=MENUDOWN({"  <+>  º  ESC   ",;
*						 	 "       º        ",;
*						 	 " mueve º  sale  "})
*		MARCO( 1, 1, 20, 78, "", "D", .T., 0 )
*		MEMOEDIT( MEMOREAD('LISTADO.TXT'), 1, 1, 20, 78, .F., "FOUND()", 99 )
*		RECUPAN()
* 	PONEPAN(mbuz)
*	ENDIF
*	CLEARTYPEAHEAD()

	aTicket[3]  += aTicket[4]	;ASIZE(aTicket,3)
  aThta[3] := aThta[4]
	aFactura[3] += aFactura[4] ;ASIZE(aFactura,3)
	aRemito[3]  += aRemito[4]  ;ASIZE(aRemito,3)
	aTotal[3]   += aTotal[4]   ;ASIZE(aTotal,3)

	DO LISTADOR WITH "X"

ENDIF
GO nReg
RECUPAN()

RETURN
