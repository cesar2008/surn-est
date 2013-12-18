#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

PARAMETERS _como
LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), nB, xmenu
LOCAL cHORA
DEFAULT _como TO .F.

aRubro := {}
nDde  := 0
nHta  := 0
cDturno := "1"
cHturno := "4"
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

	HASTA := DESDE + IF(cHturno=='4', 1, 0 )
	xaux := ""
	FOR i=VAL(cDturno) TO VAL(cHturno)
		xaux += DTOS(IF(i==4,HASTA,DESDE)) + STR(i,1) +" "
	NEXT
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

	nTOTAL := 0
  SELECT TI
  SET ORDER TO FORDER({"FECHA"})
  DBSEEK( FTOC(DESDE), .T. )
  DO WHILE ROSCA() .AND. TI->FECHA>=DESDE .AND. TI->FECHA<=HASTA .AND.!TI->(EOF())
     IF DTOS(TI->FECHA)+TI->TURNO+" " $ xaux
     	nDde := IF( nDde==0, TI->NUMFAC, MIN(TI->NUMFAC,nDde) )
     	nHta := MAX( TI->NUMFAC, nHta )
     	SELECT TI2
        DBSEEK(TI->NUMFAC)
        DO WHILE TI2->NUMFAC == TI->NUMFAC
        	FPRODUCTO(TI2->CODPROD,'*')
           i := ASCAN(aRubro,{|a| a[1]==NGRUPO} )
           IF i # 0
  				aRubro[i,X_TPRECBASE] += TI2->TPRECBASE
*					aRubro[i,X_TNETO    ] += TI2->TNETO
					aRubro[i,X_TIMPINT  ] += TI2->TIMPINT
        		aRubro[i,X_TIVA1    ] += TI2->TIVA1
  				aRubro[i,X_TIVA2    ] += TI2->TIVA2
*					aRubro[i,X_TEXENTO  ] += TI2->TEXENTO
					aRubro[i,X_IMPORTE  ] += TI2->IMPORTE
           ENDIF
           SKIP 1 ALIAS TI2
        ENDDO
     	NTOTAL += TI->TOTAL
     ENDIF
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
	? " FECHA:",DESDE,"    ",cHORA
	? "     DESDE TICKET NRO:",STRZERO(nDde,8)
	? "     HASTA TICKET NRO:",STRZERO(nHta,8)
	? "                  nro Z:",STRZERO(nZ,6)
  ? "--- ------------------- ----------"
	? "C¢d Rubro                  Importe"
  ? "--- ------------------- ----------"
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
  		? STR(aRubro[i,1],3)+" "+ PADR(left(aRubro[i,2],20),20,' ')+STR(aRubro[i,X_IMPORTE],10,2)
     ENDIF
  NEXT
  ? SPACE(24)+'----------'
  ? SPACE(24)+STR(nIMPORTE,10,2)
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
				Z2->CODRUB    := aRubro[i,X_CODRUB   ]
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
 		IF FT_ISPRINT("COM2")
			MENSAJE( 99, 99, 0, .F., " IMPRIMIENDO  Z . . . " )
			SET CONSOLE OFF
			SET DEVICE TO PRINTER
			SET PRINTER ON
			SET PRINTER TO COM2
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
