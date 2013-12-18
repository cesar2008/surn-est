#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

**********

FUNC ZZ(_como)

**********
LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), nB, xmenu
LOCAL cHORA
DEFAULT _como TO .F.

aRubro := {}
nDde  := 0
nHta  := 0
cDturno := "1"
cHturno := "3"
DESDE := DATE()
cHORA := LEFT(TIME(),5)
FBASES({"+Z","+Z2"})
SELECT Z
DBGOBOTTOM()
nZ := Z->(LASTREC())+IF(Z->NUMZ==0,0,1)
IF _como
	DESDE := Z->FECHA
	MARCO( 10, 20, 13, 60, " Z ", "D", .T. )
	SET(_SET_CURSOR,SC_ON)
	@10,20 SAY "      Fecha:" GET DESDE
  READ
  @ 10, 60 SAY " "
  IF DBSEEK( FTOC(DESDE) )
  	cHora := Z->HORA
     nZ    := RECNO()
     @ 10, 60 SAY "E"
  ENDIF
	@12,20 SAY "       Hora:" GET cHora PICT "99:99"
	@13,20 SAY "       n§ Z:" GET nZ PICT '99999'
	READ
	RECUPAN()
ENDIF
IF LASTKEY() == K_ENTER .OR. !_como
	MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
	X_CODRUB     = 1
  X_DESCRUB    = 2
	X_TPRECBASE  = 3
	X_TNETO      = 4
	X_TIMPINT    = 5
	X_TIVA1      = 6
	X_TIVA2      = 7
	X_TEXENTO    = 8
	X_IMPORTE    = 9
	X_PORC       = 10

	HASTA := DESDE
	SELECT RU
	GO TOP
	DO WHILE !EOF()
		IF !DELETED()
  		AADD( aRubro,AFILL(ARRAY(X_PORC),0) )
        i := LEN(aRubro)
  		aRubro[i,X_CODRUB]  := RECNO()
			aRubro[i,X_DESCRUB] := FIELD->DESCRUB
			aRubro[i,X_PORC]    := FIELD->PORC
  	ENDIF
  	SKIP
	ENDDO

  SELECT TI
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE TI->FECHA>=DESDE .AND. TI->FECHA<=HASTA .AND.!TI->(EOF())
     nDde := IF( nDde==0, TI->NUMFAC, MIN(TI->NUMFAC,nDde) )
     nHta := MAX( TI->NUMFAC, nHta )
     SELECT TI2
     DBSEEK(TI->NUMFAC)
     DO WHILE TI2->NUMFAC == TI->NUMFAC
        FPRODUCTO(TI2->CODPROD,'*')
        i := ASCAN(aRubro,{|a| a[1]==NGRUPO} )
        IF i # 0
  			aRubro[i,X_TPRECBASE] += TI2->TPRECBASE
				aRubro[i,X_TIMPINT  ] += TI2->TIMPINT
        	aRubro[i,X_TIVA1    ] += TI2->TIVA1
  			aRubro[i,X_TIVA2    ] += TI2->TIVA2
				aRubro[i,X_IMPORTE  ] += TI2->IMPORTE
        ENDIF
        SKIP 1 ALIAS TI2
     ENDDO
     SKIP 1 ALIAS TI
	ENDDO
  SELECT TI
  SET ORDER TO 1

  cTXT := "Z\Z"+STRZERO(DAY(DESDE),2)+STRZERO(MONTH(DESDE),2)+"."
	SET ALTERNATE TO (cTXT)
	SET ALTERNATE ON
  SET CONSOLE OFF
  aux:=LEFT(CURDIR(),AT('\',CURDIR())-1) +".ID"
  IF FILE( aux )
  	aux := MEMOREAD( aux )
  ELSE
  	aux := ""
  ENDIF
	FOR i=1 TO MLCOUNT(aux,80)
  	? &( RTRIM(MEMOLINE(aux,80,i)) )
	NEXT
	? " FECHA:",DESDE,"     ",cHORA
	? "       DESDE TICKET NRO:",STRZERO(nDde,8)
	? "       HASTA TICKET NRO:",STRZERO(nHta,8)
	? "                  nro Z:",STRZERO(nZ,6)
  ? "--- ------------------------ -----------"
	? "C¢d Rubro                        Importe"
  ? "--- ------------------------ -----------"
  ?
	nTPRECBASE := 0
	nTNETO     := 0
	nTIMPINT   := 0
	nTIVA1     := 0
	nTIVA2     := 0
	nTEXENTO   := 0
	nIMPORTE   := 0
  nTOTAL     := 0
	FOR i=1 TO LEN(aRubro)
     IF aRubro[i,X_IMPORTE] # 0
     	nTOTAL += aRubro[i,X_IMPORTE  ]
  		IF _como
  			aRubro[i,X_TPRECBASE] -= ( aRubro[i,X_TPRECBASE]*aRubro[i,X_PORC]/100 )
				aRubro[i,X_TNETO    ] -= ( aRubro[i,X_TNETO    ]*aRubro[i,X_PORC]/100 )
				aRubro[i,X_TIMPINT  ] -= ( aRubro[i,X_TIMPINT  ]*aRubro[i,X_PORC]/100 )
        	aRubro[i,X_TIVA1    ] -= ( aRubro[i,X_TIVA1    ]*aRubro[i,X_PORC]/100 )
  			aRubro[i,X_TIVA2    ] -= ( aRubro[i,X_TIVA2    ]*aRubro[i,X_PORC]/100 )
				aRubro[i,X_TEXENTO  ] -= ( aRubro[i,X_TEXENTO  ]*aRubro[i,X_PORC]/100 )
				aRubro[i,X_IMPORTE  ] -= ( aRubro[i,X_IMPORTE    ]*aRubro[i,X_PORC]/100 )
     	ENDIF
			nTPRECBASE += aRubro[i,X_TPRECBASE]
			nTNETO     += aRubro[i,X_TNETO    ]
			nTIMPINT   += aRubro[i,X_TIMPINT  ]
			nTIVA1     += aRubro[i,X_TIVA1    ]
			nTIVA2     += aRubro[i,X_TIVA2    ]
			nTEXENTO   += aRubro[i,X_TEXENTO  ]
			nIMPORTE   += aRubro[i,X_IMPORTE    ]
  		? STR(aRubro[i,1],3)+" "+ PADR(aRubro[i,2],25,' ')+STR(aRubro[i,X_IMPORTE],11,2)
     ENDIF
  NEXT
  ? SPACE(29)+'-----------'
  ? SPACE(29)+STR(nIMPORTE,11,2)
  FOR x=1 TO 9
		?
	NEXT
  ? CHR(27)+CHR(105)
	SET ALTERNATE TO
  SET CONSOLE ON
  RECUPAN()

	TONE(500,1)
	xmenu:=MENUDOWN({"  <+>  º   F10   º  ESC   ",;
					 	  "       º graba e º        ",;
					 	  " mueve º imprime º  sale  "})
	MARCO( 1, 1, 19, 78, "", "D", .T., 0 )
	aux := MEMOREAD(cTXT)
	IF _como
  	SET(_SET_CURSOR,SC_ON)
  	@ 20, 1 SAY nTOTAL PICT "########.##"
  	@ 20,21 SAY nTOTAL-nIMPORTE PICT "########.##"
	ELSE
  	SET(_SET_CURSOR,SC_OFF)
  ENDIF
  lImpreso := .F.
	MEMOEDIT( aux, 1, 1, 19, 78, .F., "mcontrol", 99 )
  IF lImpreso
		MENSAJE( 99, 99, 0, .F., "GRABANDO Z . . ." )
    	SELECT Z
     IF nZ > 0 .AND. nZ <= LASTREC()
     	GO nZ
     ELSE
    		DO WHILE .T.
				IF LASTREC() >= nZ
           	EXIT
           ENDIF
     		ADD_REC()
     	ENDDO
     	GO nZ
     ENDIF
     FRLOCK()
     Z->FECHA     := DESDE
     Z->HORA      := cHORA
     Z->DDETICKET := nDde
   	Z->HTATICKET := nHta
   	Z->NUMZ      := Z->(RECNO())
		Z->TPRECBASE := nTPRECBASE
		Z->TNETO     := nTNETO
		Z->TIMPINT   := nTIMPINT
		Z->TIVA1     := nTIVA1
		Z->TIVA2     := nTIVA2
		Z->TEXENTO   := nTEXENTO
		Z->TOTAL     := nIMPORTE
		SELECT Z2
     DO WHILE DBSEEK( Z->NUMZ )
     	BLANKREG()
     ENDDO
   	FFLOCK()
     FOR i=1 TO LEN(aRubro)
     	IF aRubro[i,X_IMPORTE] # 0
     		GO TOP
        	IF Z2->NUMZ#0 .OR. LASTREC()==0
        		ADD_REC()
        	ENDIF
        	FRLOCK()
       		Z2->NUMZ      := Z->(RECNO())
        	Z2->FECHA     := DESDE
				Z2->TPRECBASE := aRubro[i,X_TPRECBASE]
				Z2->TNETO     := aRubro[i,X_TNETO    ]
				Z2->TIMPINT   := aRubro[i,X_TIMPINT  ]
				Z2->TIVA1     := aRubro[i,X_TIVA1    ]
				Z2->TIVA2     := aRubro[i,X_TIVA2    ]
				Z2->TEXENTO   := aRubro[i,X_TEXENTO  ]
				Z2->IMPORTE   := aRubro[i,X_IMPORTE  ]
        ENDIF
		NEXT
     SELECT Z
 		IF FT_ISPRINT("COM1")
			MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO  Z . . . " )
			SET CONSOLE OFF
			SET DEVICE TO PRINTER
			SET PRINTER ON
			SET PRINTER TO COM1
			FOR i=1 TO MLCOUNT(aux,80)
				? MEMOLINE(aux,80,i)
			NEXT
			SET CONSOLE ON
			SET DEVICE TO SCREEN
			SET PRINTER OFF
			SET PRINTER TO
  		RECUPAN()
  	ENDIF
   	DBUNLOCKALL()
     DBCOMMITALL()
     RECUPAN()
  ENDIF
	RECUPAN()
	PONEPAN(xmenu)
	CLEARTYPEAHEAD()

ENDIF
FBASES({"-Z","-Z2"})
SELECT (cBase)
GO nReg

RETURN


*************

FUNC mcontrol

*************
PARAMETERS nMode, nLine, nCol

r = 0
K = LASTKEY()
IF nMode == 344
	r = 34
ELSEIF K == K_F10
	lImpreso := .T.
  r = 23
ELSEIF K == 27
	r = 23
ENDIF

RETURN r

**********
FUNC XV(x)
**********
RETURN IF(_como,x,UPPER(x))



**********
FUNC XX()
**********
LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), nB, xmenu

aTicket := {0,0,0,0}
aTdde   := {0,0,0,0}
aThta   := {0,0,0,0}

aFactura := {0,0,0,0}
aRemito  := {0,0,0,0}
aTotal   := {0,0,0,0}


cDturno := "1"
cHturno := "2"
MARCO( 10, 20, 12, 60, "", "S", .T. )
SET(_SET_CURSOR,SC_ON)
@10,20 SAY "      Fecha:" GET DESDE
*@11,20 SAY "Desde Turno:" GET cDturno PICT "!" VALID cDturno $ '1234'
*@12,20 SAY "Hasta Turno:" GET cHturno PICT "!" VALID cHturno $ '1234' .AND. cHturno>=cDturno
READ
HASTA := DESDE

IF LASTKEY() == K_ENTER
	MENSAJE( 99, 99, 0, .F., "AGUARDE . . ." )
  SELECT TI
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE TI->FECHA>=DESDE .AND. TI->FECHA<=HASTA .AND.!TI->(EOF())
    	aTdde[VAL(TI->TURNO)] := IF( aTdde[VAL(TI->TURNO)]==0, TI->NUMFAC, MIN(TI->NUMFAC,aTdde[VAL(TI->TURNO)]) )
     aThta[VAL(TI->TURNO)] := MAX( TI->NUMFAC, aThta[VAL(TI->TURNO)] )
     SELECT TI2
     DBSEEK(TI->NUMFAC)
     DO WHILE TI2->NUMFAC == TI->NUMFAC
        aTicket[VAL(TI->TURNO)]   += TI2->IMPORTE
        SKIP 1 ALIAS TI2
     ENDDO
     SKIP 1 ALIAS TI
	ENDDO
  SELECT TI
  SET ORDER TO 1

  SELECT FA
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE FA->FECHA>=DESDE .AND. FA->FECHA<=HASTA .AND.!FA->(EOF())
     SELECT FA2
     DBSEEK(FA->NUMFAC)
     DO WHILE FA2->NUMFAC == FA->NUMFAC
     	IF FA2->NEGOCIO == '*'
           aFactura[VAL(FA->TURNO)] += FA2->IMPORTE
        ENDIF
        SKIP 1 ALIAS FA2
     ENDDO
     SKIP 1 ALIAS FA
	ENDDO
  SELECT FA
  SET ORDER TO 1

  SELECT FB
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE FB->FECHA>=DESDE .AND. FB->FECHA<=HASTA .AND.!FB->(EOF())
     SELECT FB2
     DBSEEK(FB->NUMFAC)
     DO WHILE FB2->NUMFAC == FB->NUMFAC
     	IF FB2->NEGOCIO == '*'
        	aFactura[VAL(FB->TURNO)] += FB2->IMPORTE
        ENDIF
        SKIP 1 ALIAS FB2
     ENDDO
     SKIP 1 ALIAS FB
	ENDDO
  SELECT FB
  SET ORDER TO 1

  SELECT RE
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE RE->FECHA>=DESDE .AND. RE->FECHA<=HASTA .AND.!RE->(EOF())
     SELECT RE2
     DBSEEK(RE->NUMFAC)
     DO WHILE RE2->NUMFAC == RE->NUMFAC
			IF RE2->NEGOCIO == '*'
        	aRemito[VAL(RE->TURNO)] += RE2->IMPORTE
        ENDIF
        SKIP 1 ALIAS RE2
     ENDDO
     SKIP 1 ALIAS RE
	ENDDO
  SELECT RE
  SET ORDER TO 1
  SELECT (cBase)
  GO nReg
  RECUPAN()

	aTicket[3]  += aTicket[4]	;ASIZE(aTicket,3)
  aThta[3]    := aThta[4]
	aFactura[3] += aFactura[4] ;ASIZE(aFactura,3)
	aRemito[3]  += aRemito[4]  ;ASIZE(aRemito,3)
	aTotal[3]   += aTotal[4]   ;ASIZE(aTotal,3)

	DO LISTADOR WITH "X"

ENDIF
GO nReg
RECUPAN()

RETURN
