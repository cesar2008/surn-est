#include "BL.CH"
#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PARAMETERS cual, lSoloEnc
LOCAL aux := .F.
DEFAULT cual TO VA->CUALIMP
DEFAULT lSoloEnc TO .F.

*#ifdef ESFISCAL
	if nB==4
  	return FISCAL()
  endif
*#endif

#ifdef ARIES
	DO WHILE !aux
		IF PROCNAME(3) == "EST"
			aux := .T.
			cSalida:="LPT1"
			cBoleta := {"FACA","FACB","REM","TICKET"}[nB]
		ELSE
			IF nB==1                      // Facturas A
				aux := FT_ISPRINT("LPT3")
				cSalida  :="LPT3"
				cBoleta  := "FACA"
				nXcopias := VA->CANTFA
			ELSEIF nB==2                  // Facturas B
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "FACB"
				nXcopias := VA->CANTFB
			ELSEIF nB==3                  // Remitos  X
				aux := FT_ISPRINT("LPT2")
				cSalida  :="LPT2"
				cBoleta  := "REM"
				nXcopias := VA->CANTRE
			ELSEIF nB==4                  // TICKETS
				aux := FT_ISPRINT("LPT1")
				aux := .T.
				cSalida  :="LPT1"
				cBoleta  := "TICKET"
				nXcopias := 1
			ENDIF
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 3, .T., "LA IMPRESORA NO ESTA LISTA !!!", " ","ESC  cancela impresi¢n " )
			IF LASTKEY() == K_ESC
				RETURN .F.
			ENDIF
		ENDIF
	ENDDO
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . . " )
	SET CONSOLE OFF
	SET DEVICE TO PRINTER
	SET PRINTER ON
	IF cSalida=="LPT1"
		SET PRINTER TO LPT1
	ELSEIF cSalida=="LPT2"
		SET PRINTER TO LPT2
	ELSEIF cSalida=="LPT3"
		SET PRINTER TO LPT3
	ELSEIF cSalida=="COM1"
		SET PRINTER TO COM1
	ENDIF
	
	IF nB==4                   // TICKETS
		*  ? CHR(27)+"x"+CHR(0)
		? ""
		? "       ESTACION DE SERVICIO  "
		? "              Y.P.F."
		? "      ARIES COMBUSTIBLES S.R.L."
		? "      Diag.74 Esquina 31 La Plata    "
		? "   CUIT:33-67721531-9 IVA:RESP.INS."
		? "     ING.BRUTOS 33-BPP-67721531-6"
		? " FECHA:",DATE(),"     TICKET NRO:",STR(nNUMERO,6)
		? " Turno:", cTurno +"             "+TIME()
		? "----------------------------------------"
		? "   C¢d   Cant   Descripci¢n      Importe"
		? "----------------------------------------"
		*  IF lSoloEnc
		FOR F=1 TO LEN(AXR)
			IF AXR[f,RG_IMPORTE]#0
				? CHR(15)
				?? STR(AXR[F,RG_CODPROD],6)
				?? STR(AXR[F,RG_CANTIDAD],6)
				?? "  "+ LEFT(AXR[F,RG_DESCPROD],16)
				?? STR(AXR[F,RG_IMPORTE],10,2)
			ENDIF
		NEXT F
		? "                              -----------"
		? "              TOTAL........$ ",TRANS(M->TOTAL,"#######.##")
		?
		? "            A CONSUMIDOR FINAL"
		FOR x=1 TO 9
			?
		NEXT
*		?? CHR(27) + "C" + CHR(1)
*		?? CHR(12)
		SET PRINTER OFF
		* ENDIF
	ELSE
		PRIVATE aimprimir:={ 0 }
		FOR i=1 TO LEN(AXR)
			IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
				AADD( aimprimir, i )
			ENDIF
		NEXT
		SET DEVICE TO PRINTER
		SET PRINTER ON
		SET CONSOLE OFF
		FOR nCopia=1 TO IF(nB==1,3,2)
			aux := PCOL()
			@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
			@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETINI]),'',&(asetprn[BL_SETINI]))
			@ PROW(), aux SAY ""
			IMPRBL( cBoleta )
			@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETFIN]),'',&(asetprn[BL_SETFIN]))
			@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
			@ PROW(), 1 SAY CHR(12)
		NEXT
		SET DEVICE TO SCREEN
		SET PRINTER OFF
		SET PRINTER TO
		SET CONSOLE ON
	ENDIF
	SET DEVICE TO SCREEN
	SET CONSOLE ON
	RECUPAN()
#endif

#ifdef SUR
	DO WHILE !aux
		IF PROCNAME(3) == "EST"
			aux := .T.
			cSalida:="LPT1"
			cBoleta := {"FACA","FACB","REM","TICKET"}[nB]
		ELSE
			IF nB==1                      // Facturas A
				aux := FT_ISPRINT("LPT3")
				cSalida  :="LPT3"
				cBoleta  := "FACA"
				nXcopias := VA->CANTFA
			ELSEIF nB==2                  // Facturas B
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "FACB"
				nXcopias := VA->CANTFB
			ELSEIF nB==3                  // Remitos  X
				aux := FT_ISPRINT("LPT2")
				cSalida  :="LPT2"
				cBoleta  := "REM"
				nXcopias := VA->CANTRE
			ELSEIF nB==4                  // TICKETS
				aux := FT_ISPRINT("COM2")
				aux := .T.
				cSalida  :="COM2"
				cBoleta  := "TICKET"
				nXcopias := 1
				IF 'SUR2' $ CURDIR()
					aux := FT_ISPRINT("COM2")
					cSalida  :="COM2"
           ENDIF
			ENDIF
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 3, .T., "LA IMPRESORA NO ESTA LISTA !!!", " ","ESC  cancela impresi¢n " )
			IF LASTKEY() == K_ESC
				RETURN .F.
			ENDIF
		ENDIF
	ENDDO
	
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . . " )
	SET CONSOLE OFF
	SET DEVICE TO PRINTER
	SET PRINTER ON
	IF cSalida=="LPT1"
		SET PRINTER TO LPT1
	ELSEIF cSalida=="LPT2"
		SET PRINTER TO LPT2
	ELSEIF cSalida=="LPT3"
		SET PRINTER TO LPT3
	ELSEIF cSalida=="COM1"
		SET PRINTER TO COM1
	ELSEIF cSalida=="COM2"
		SET PRINTER TO COM2
	ENDIF
	
	IF nB==4                   // TICKETS
		*  ? CHR(27)+"x"+CHR(0)
		? ""
		? "      ESTACION DE SERVICIO  "
		? "             Y.P.F."
		? "       SUR COMBUSTIBLES S.R.L."
		? "    Calle 44 Esquina 31 La Plata    "
		? "  CUIT:30-63973431-1 IVA:RESP.INS."
		? "      ING.BRUTOS 055-106600-4"
		? " FECHA:"+dtoc(DATE())+"   TICKET N§:"+STR(nNUMERO,6)
		? " Turno:", cTurno +"             "+TIME()
		? "----------------------------------"
		? "   C¢d Cant  Descripci¢n   Importe"
		? "----------------------------------"
		*  12345612345 123456789-123412345678
		FOR F=1 TO LEN(AXR)
			IF AXR[f,RG_IMPORTE]#0
				? STR(AXR[F,RG_CODPROD],6)
				?? STR(AXR[F,RG_CANTIDAD],5)
				?? " "+ LEFT(AXR[F,RG_DESCPROD],14)
				?? STR(AXR[F,RG_IMPORTE],8,2)
			ENDIF
		NEXT F
		? "                        ----------"
		? "        TOTAL........$ "+TRANS(M->TOTAL,"#######.##")
		?
		? "        A CONSUMIDOR FINAL"
		FOR x=1 TO 11
			?
		NEXT
		? CHR(27)+CHR(105)
		SET PRINTER OFF
		* ENDIF
	ELSE
		PRIVATE aimprimir:={ 0 }
		FOR i=1 TO LEN(AXR)
			IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
				AADD( aimprimir, i )
			ENDIF
		NEXT
		SET DEVICE TO PRINTER
		SET PRINTER ON
		SET CONSOLE OFF
		FOR nCopia=1 TO IF(nB==1,3,2)
			aux := PCOL()
			@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
			@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETINI]),'',&(asetprn[BL_SETINI]))
			@ PROW(), aux SAY ""
			IMPRBL( cBoleta )
			@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETFIN]),'',&(asetprn[BL_SETFIN]))
			@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
			@ PROW(), 1 SAY CHR(12)
		NEXT
		SET DEVICE TO SCREEN
		SET PRINTER OFF
		SET PRINTER TO
		SET CONSOLE ON
	ENDIF
	SET DEVICE TO SCREEN
	SET CONSOLE ON
	RECUPAN()
#endif
	
#ifdef TRESSAN
	DO WHILE !aux
		IF PROCNAME(3) == "EST"
			aux := .T.
			cSalida:="LPT1"
			cBoleta := {"FACA","FACB","REM","TICKET"}[nB]
		ELSE
			IF nB==1                      // Facturas A
				aux := FT_ISPRINT("LPT3")
				cSalida  :="LPT3"
				cBoleta  := "FACA"
				nXcopias := VA->CANTFA
			ELSEIF nB==2                  // Facturas B
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "FACB"
				nXcopias := VA->CANTFB
			ELSEIF nB==3                  // Remitos  X
				aux := FT_ISPRINT("LPT2")
				cSalida  :="LPT2"
				cBoleta  := "REM"
				nXcopias := VA->CANTRE
			ELSEIF nB==4                  // TICKETS
				aux := FT_ISPRINT("COM1")
				aux := .T.
				cSalida  :="COM1"
				cBoleta  := "TICKET"
				nXcopias := 1
			ENDIF
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 3, .T., "LA IMPRESORA NO ESTA LISTA !!!", " ","ESC  cancela impresi¢n " )
			IF LASTKEY() == K_ESC
				RETURN .F.
			ENDIF
		ENDIF
	ENDDO
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . . " )
	SET CONSOLE OFF
	SET DEVICE TO PRINTER
	SET PRINTER ON
	IF cSalida=="LPT1"
		SET PRINTER TO LPT1
	ELSEIF cSalida=="LPT2"
		SET PRINTER TO LPT2
	ELSEIF cSalida=="LPT3"
		SET PRINTER TO LPT3
	ELSEIF cSalida=="COM1"
		SET PRINTER TO COM1
	ENDIF
	IF nB==4                   // TICKETS
		*  ? CHR(27)+"x"+CHR(0)
		?
		? "        ESTACION DE SERVICIO  "
		? "              Y.P.F."
		? "          de TRESSAN S.R.L."
		? "     Calle 7 Esquina 32 La Plata    "
		? "   CUIT:30-62066253-0 IVA:RESP.INS."
		? "       ING.BRUTOS 055-101927-6"
		? " FECHA:",DATE()," TICKET NRO:",STR(nNUMERO,6)
		? " Turno:", cTurno +"             "+TIME()
		? "-----------------------------------"
		? "   C¢d  Cant   Descripci¢n  Importe"
		? "-----------------------------------"
		FOR F=1 TO LEN(AXR)
			IF AXR[f,RG_IMPORTE]#0
				? CHR(15)
				?? STR(AXR[F,RG_CODPROD],6)
				?? STR(AXR[F,RG_CANTIDAD],6)
				?? " "+ LEFT(AXR[F,RG_DESCPROD],15)
				?? STR(AXR[F,RG_IMPORTE],7,2)
			ENDIF
		NEXT F
		? "                         ----------"
		? "         TOTAL........$ "+TRANS(M->TOTAL,"#######.##")
		?
		? "            A CONSUMIDOR FINAL"
		FOR i=1 TO 9+2
			?
		NEXT
		SET PRINTER OFF
	ELSE
		PRIVATE aimprimir:={ 0 }
		FOR i=1 TO LEN(AXR)
			IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
				AADD( aimprimir, i )
			ENDIF
		NEXT
		aux := PROW()
		@ aux, 0 SAY FSETIMP("LX300","INI")
		FOR nCopia=1 TO nXcopias
			IMPRBL( cBoleta )
		NEXT
		aux := PROW()
		@ aux, 0 SAY FSETIMP("LX300",'FIN')
		INKEY(1)
		SET PRINTER OFF
	ENDIF
	SET DEVICE TO SCREEN
	SET CONSOLE ON
	RECUPAN()
#endif
	
	
#ifdef MARQ
	DO WHILE !aux
		IF nB==1                      // Facturas A
			aux := FT_ISPRINT("LPT3")
			SET PRINTER TO LPT3
			cBoleta := "FACA"
			nXcopias := VA->CANTFA
		ELSEIF nB==2                  // Facturas B
			aux := FT_ISPRINT("LPT1")
			SET PRINTER TO LPT1
			cBoleta := "FACB"
			nXcopias := VA->CANTFB
		ELSEIF nB==3                  // Remitos  X
			aux := FT_ISPRINT("LPT2")
			SET PRINTER TO LPT2
			cBoleta := "REM"
			nXcopias := VA->CANTRE
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 10, .T., "LA IMPRESORA NO ESTA LISTA !!!" )
		ENDIF
	ENDDO
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . " )
	
	PRIVATE aimprimir:={ 0 }
	FOR i=1 TO LEN(AXR)
		IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
			AADD( aimprimir, i )
		ENDIF
	NEXT
	SET DEVICE TO PRINTER
	SET PRINTER ON
	SET CONSOLE OFF
	
	FOR nCopia=1 TO nXcopias
		aux := PCOL()
		@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
		@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETINI]),'',&(asetprn[BL_SETINI]))
		@ PROW(), aux SAY ""
		IMPRBL( cBoleta )
		?? CHR(27)+"C"+CHR(1)  // set‚a el largo de la pagina en l¡neas
		?? CHR(12)
		@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETFIN]),'',&(asetprn[BL_SETFIN]))
		@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
		@ PROW(), 1 SAY CHR(12)
	NEXT
	SET DEVICE TO SCREEN
	SET PRINTER OFF
	SET PRINTER TO
	SET CONSOLE ON
	RECUPAN()
#endif
	
#ifdef DOCSA
	if nB==3
  	LISTADOR("REMITO")
     return .t.
  endif
	nXcopias := 2
	DO WHILE !aux
		IF PROCNAME(3) == "EST"		// .AND. 1==2
			aux := .T.
			cSalida:="LPT1"
			cBoleta := {"FACA","FACB","REM","TICKET"}[nB]
		ELSE
			IF nB==1                      // Facturas A
				aux := FT_ISPRINT("COM2")
				cSalida  :="COM2"
				cBoleta  := "FACA"
				nXcopias := VA->CANTFA
			ELSEIF nB==2                  // Facturas B
				aux := FT_ISPRINT("LPT3")
				cSalida  :="LPT3"
				cBoleta  := "FACB"
				nXcopias := VA->CANTFB
			ELSEIF nB==3                  // Remitos  X
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "REM"
				nXcopias := VA->CANTRE
			ELSEIF nB==4                  // TICKETS
				aux := FT_ISPRINT("LPT2")
				aux := .T.
				cSalida  :="LPT2"
				cBoleta  := "TICKET"
				nXcopias := 1
			ENDIF
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 3, .T., "LA IMPRESORA NO ESTA LISTA !!!", " ","ESC  cancela impresi¢n " )
			IF LASTKEY() == K_ESC
				RETURN .F.
			ENDIF
		ENDIF
	ENDDO
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . . " )
	SET CONSOLE OFF
	SET DEVICE TO PRINTER
	SET PRINTER ON
	IF cSalida=="LPT1"
		SET PRINTER TO LPT1
	ELSEIF cSalida=="LPT2"
		SET PRINTER TO LPT2
	ELSEIF cSalida=="LPT3"
		SET PRINTER TO LPT3
	ELSEIF cSalida=="COM1"
		SET PRINTER TO COM1
	ELSEIF cSalida=="COM2"
		SET PRINTER TO COM2
	ENDIF
	IF nB==4                   // TICKETS
		*  ? CHR(27)+"x"+CHR(0)
		?
		? "        ESTACION DE SERVICIO  "
		? "              Y.P.F."
		? "           de D.O.C. S.A."
		? "   Diag.73 N§16 Esquina 72 La Plata"
		? "   CUIT:30-67794582-2 IVA:RESP.INS."
		? "       ING.BRUTOS 30BPP677945820"
		? " FECHA:",DATE(),"    TICKET NRO:",STR(nNUMERO,7)
		? " Turno:", cTurno +"             "+TIME()
		? "----------------------------------------"
		? "   C¢d   Cant   Descripci¢n      Importe"
		? "----------------------------------------"
		FOR F=1 TO LEN(AXR)
			IF AXR[f,RG_IMPORTE]#0
				? CHR(15)
				?? STR(AXR[F,RG_CODPROD],6)
				?? STR(AXR[F,RG_CANTIDAD],6)
				?? "  "+ LEFT(AXR[F,RG_DESCPROD],16)
				?? STR(AXR[F,RG_IMPORTE],10,2)
			ENDIF
		NEXT F
		? "                              -----------"
		? "              TOTAL........$ ",TRANS(M->TOTAL,"#######.##")
		?
		? "            A CONSUMIDOR FINAL"
		FOR i=1 TO 9
			?
		NEXT
		SET PRINTER OFF
	ELSE
		PRIVATE aimprimir:={ 0 }
		FOR i=1 TO LEN(AXR)
			IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
				AADD( aimprimir, i )
			ENDIF
		NEXT
		aux := PROW()
		@ aux, 0 SAY FSETIMP("LX300","INI")
		FOR nCopia=1 TO nXcopias
			IMPRBL( cBoleta )
		NEXT
		aux := PROW()
		@ aux, 0 SAY FSETIMP("LX300",'FIN')
		INKEY(1)
		SET PRINTER OFF
	ENDIF
	SET DEVICE TO SCREEN
	SET CONSOLE ON
	RECUPAN()
#endif
	
#ifdef POWEROIL
	nXcopias := 1
	DO WHILE !aux
		IF PROCNAME(3) == "EST"
			aux := .T.
			cSalida:="LPT1"
			cBoleta := {"FACA","FACB","REM","TICKET"}[nB]
		ELSE
			IF nB==1                      // Facturas A
				aux := FT_ISPRINT("LPT2")
				cSalida  :="LPT2"
				cBoleta  := "FACA"
				nXcopias := VA->CANTFA
			ELSEIF nB==2                  // Facturas B
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "FACB"
				nXcopias := VA->CANTFB
			ELSEIF nB==3                  // Remitos  X
				aux := FT_ISPRINT("LPT3")
				cSalida  :="LPT3"
				cBoleta  := "REM"
				nXcopias := VA->CANTRE
			ENDIF
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 3, .T., "LA IMPRESORA NO ESTA LISTA !!!", " ","ESC  cancela impresi¢n " )
			IF LASTKEY() == K_ESC
				RETURN .F.
			ENDIF
		ENDIF
	ENDDO
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . . " )
	SET CONSOLE OFF
	SET DEVICE TO PRINTER
	SET PRINTER ON
	IF cSalida=="LPT1"
		SET PRINTER TO LPT1
	ELSEIF cSalida=="LPT2"
		SET PRINTER TO LPT2
	ELSEIF cSalida=="LPT3"
		SET PRINTER TO LPT3
	ELSEIF cSalida=="COM1"
		SET PRINTER TO COM1
	ELSEIF cSalida=="COM2"
		SET PRINTER TO COM2
	ENDIF
		PRIVATE aimprimir:={ 0 }
		FOR i=1 TO LEN(AXR)
			IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
				AADD( aimprimir, i )
			ENDIF
		NEXT
		aux := PROW()
		@ aux, 0 SAY FSETIMP("LX300","INI")
		FOR nCopia=1 TO nXcopias
			IMPRBL( cBoleta )
		NEXT
		aux := PROW()
		@ aux, 0 SAY FSETIMP("LX300",'FIN')
		INKEY(1)
		SET PRINTER OFF

	SET DEVICE TO SCREEN
	SET CONSOLE ON
	SET DEVICE TO SCREEN
	SET CONSOLE ON
	RECUPAN()
#endif

#ifdef ELPINAR
	DO WHILE !aux
		IF PROCNAME(3) == "EST"
			aux := .T.
			cSalida:="LPT1"
			cBoleta := {"FACA","FACB","REM","TICKET"}[nB]
		ELSE
			IF nB==1                      // Facturas A
				aux := FT_ISPRINT("LPT3")
				cSalida  :="LPT3"
				cBoleta  := "FACA"
				nXcopias := VA->CANTFA
			ELSEIF nB==2                  // Facturas B
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "FACB"
				nXcopias := VA->CANTFB
			ELSEIF nB==3                  // Remitos  X
				aux := FT_ISPRINT("LPT2")
				cSalida  :="LPT2"
				cBoleta  := "REM"
				nXcopias := VA->CANTRE
			ELSEIF nB==4                  // TICKETS
				aux := FT_ISPRINT("LPT1")
				cSalida  :="LPT1"
				cBoleta  := "TICKET"
				nXcopias := 1
			ENDIF
		ENDIF
		IF !aux
			MENSAJE( 0, 0, 3, .T., "LA IMPRESORA NO ESTA LISTA !!!", " ","ESC  cancela impresi¢n " )
			IF LASTKEY() == K_ESC
				RETURN .F.
			ENDIF
		ENDIF
	ENDDO
	
	
	MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO . . . " )
	SET CONSOLE OFF
	SET DEVICE TO PRINTER
	SET PRINTER ON
	IF cSalida=="LPT1"
		SET PRINTER TO LPT1
	ELSEIF cSalida=="LPT2"
		SET PRINTER TO LPT2
	ELSEIF cSalida=="LPT3"
		SET PRINTER TO LPT3
	ELSEIF cSalida=="COM1"
		SET PRINTER TO COM1
	ELSEIF cSalida=="COM2"
		SET PRINTER TO COM2
	ENDIF
	
	IF nB==4                   // TICKETS
		? ""
		? "      ESTACION DE SERVICIO  "
		? "             Y.P.F."
		? "         E L   P I N A R"
		? "  Calle 520 Esquina 3 bis La Plata"
		? "  CUIT:27-01411746-1 IVA:RESP.INS."
		? " FECHA:"+dtoc(DATE())+"   TICKET N§:"+STR(nNUMERO,6)
		? " Turno:", cTurno +"             "+TIME()
		? "----------------------------------"
		? "   C¢d Cant  Descripci¢n   Importe"
		? "----------------------------------"
		*  12345612345 123456789-123412345678
		FOR F=1 TO LEN(AXR)
			IF AXR[f,RG_IMPORTE]#0
				? STR(AXR[F,RG_CODPROD],6)
				?? STR(AXR[F,RG_CANTIDAD],5)
				?? " "+ LEFT(AXR[F,RG_DESCPROD],14)
				?? STR(AXR[F,RG_IMPORTE],8,2)
			ENDIF
		NEXT F
		? "                        ----------"
		? "        TOTAL........$ "+TRANS(M->TOTAL,"#######.##")
		?
		? "        A CONSUMIDOR FINAL"
		FOR x=1 TO 11+5
			?
		NEXT
		? CHR(27)+CHR(105)
		SET PRINTER OFF
	ELSE
		PRIVATE aimprimir:={ 0 }
		FOR i=1 TO LEN(AXR)
			IF !EMPTY(AXR[i,RG_DESCPROD]) .AND. AXR[i,RG_IMPORTE] # 0
				AADD( aimprimir, i )
			ENDIF
		NEXT
		SET DEVICE TO PRINTER
		SET PRINTER ON
		SET CONSOLE OFF
		FOR nCopia=1 TO IF(nB==1,3,2)
			aux := PCOL()
			@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
			@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETINI]),'',&(asetprn[BL_SETINI]))
			@ PROW(), aux SAY ""
			IMPRBL( cBoleta )
			@ PROW(), 1 SAY IF(EMPTY(asetprn[BL_SETFIN]),'',&(asetprn[BL_SETFIN]))
			@ PROW(), 1 SAY CHR(27) + "C" + CHR(1)    // Set Page Length in Lines    ESC C n
			@ PROW(), 1 SAY CHR(12)
		NEXT
		SET DEVICE TO SCREEN
		SET PRINTER OFF
		SET PRINTER TO
		SET CONSOLE ON
	ENDIF
	SET DEVICE TO SCREEN
	SET CONSOLE ON
	RECUPAN()
#endif

RETURN .T.
