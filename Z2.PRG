#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOCAL r:=.T., cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), nB, xmenu

M->FECHA := FIELD->FECHA
M->TURNO := FIELD->TURNO
MARCO( 10, 20, 11, 50, "", "D", .T., 0 )
SET(_SET_CURSOR,SC_ON)
@10,20 SAY "FECHA:" GET M->FECHA
@11,20 SAY "TURNO:" GET M->TURNO
READ
RECUPAN()
SET(_SET_CURSOR,SC_OFF)

IF LASTKEY() == K_ENTER
	MENSAJE( 99, 99, 0, .F., "  REVISANDO . . . ", DTOC(M->FECHA)+"  turno "+M->TURNO+"." )
	#define  TR_TIPO 		1
	#define  TR_BASE		2
	#define  TR_BASE2		3
	#define  TR_ALIAS		4
	#define  TR_ALIAS2	5
	#define  TR_NUM		6
	#define  TR_TIT		7
	aaux := ARRAY( 3 )
	aaux[1] := {"XFACA", "FACA","FACA2", "FA","FA2", "NUMFAC", "FACTURAS A" }
	aaux[2] := {"XFACB", "FACB","FACB2", "FB","FB2", "NUMFAC", "FACTURAS B" }
	aaux[3] := {"XREM",  "REM","REM2",   "RE","RE2", "NUMFAC", "REMITOS" }

 	anum   := { {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0} }
  afalta := {{},{},{}}
  aTotal := {0,{}}
	FOR nB=1 TO LEN(aaux)
  	@ 24,75 SAY aaux[nB,TR_BASE]
		DBSELECTAREA(aaux[nB,TR_ALIAS])
		LOCATE FOR FIELD->FECHA==M->FECHA .AND. FIELD->TURNO==M->TURNO
  	anum[nB,1] := FIELD->&(aaux[nB,TR_NUM])
     nUltNum    := FIELD->&(aaux[nB,TR_NUM])
     K:=0
  	DO WHILE !EOF()
  		IF FIELD->FECHA == M->FECHA .AND. FIELD->TURNO==M->TURNO
  			anum[nB,1] := MIN( anum[nB,1], FIELD->&(aaux[nB,TR_NUM]) )
  			anum[nB,2] := MAX( anum[nB,2], FIELD->&(aaux[nB,TR_NUM]) )
           IF FIELD->CODCLI == -2
  				++anum[nB,3]
           ENDIF
     		IF FIELD->&(aaux[nB,TR_NUM]) > nUltNum+1
     			FOR i=nUltNum+1 TO FIELD->&(aaux[nB,TR_NUM])-1
           		AADD( afalta[nB], STRZERO(i,8) )
  					++anum[nB,5]
           	NEXT
           ENDIF
     		nUltNum := FIELD->&(aaux[nB,TR_NUM])
  			++anum[nB,4]
           IF nB # 3
           	IF FIELD->NEGOCIO == "*"
              	aux := 0
						DBSELECTAREA(aaux[nB,TR_ALIAS2])
  					SEEK (aaux[nB,TR_ALIAS])->NUMFAC
  					DO WHILE FIELD->NUMFAC == (aaux[nB,TR_ALIAS])->NUMFAC .AND. !EOF()
                 	IF FIELD->NEGOCIO == "*"
                    	aux += FIELD->IMPORTE
                    ENDIF
							SKIP
						ENDDO
						DBSELECTAREA(aaux[nB,TR_ALIAS])
                 AADD( aTotal[2], DBF()+" "+STRZERO(FIELD->NUMFAC,8)+"³"+DTOC(FIELD->FECHA)+"³"+STR(aux,10,2) )
                	aTotal[1] += aux
              ENDIF
           ENDIF
        ENDIF
  		SKIP
        K := INKEY()
        IF K == K_ESC
        	EXIT
        ENDIF
  	ENDDO
     DBGOBOTTOM()
     IF K == K_ESC
        EXIT
     ENDIF
	NEXT nB
* AEVAL( anum, {|a,i| anum[i,5]:=LEN(afalta[i])} )
	RECUPAN()

	IF K == K_ESC
		DBSELECTAREA(cBase)
		GO nReg
  	RETURN
  ENDIF

	xmenu:=MENUDOWN({"     º presione TAB º  ESC   ",;
						  "       º para ver las º        ",;
						  " mueve º que faltan.  º  sale  "})
	aed := NEWEDIT2( "RES",,.T. )
	aed[ED_MODE] = "MOSTRARTODO"
	aed[ED_I] := 1
	DO WHILE .T.
		FEDITAR2( aed, { K_TAB } )
		IF aed[ED_UPDATE]
			aed[ED_MODE] = "MOSTRAR"
		ELSEIF aed[ED_TECLA] == K_TAB .AND. "anum"$EDNOM(aed)
     	aux := VAL(STRTRAN(EDNOM(aed),"anum[",""))
        IF LEN(afalta[aux]) == 0
        	TONE(100,1)
        ELSE
				PP_SELEC( aed[ED_Y]-5, aed[ED_X], 0, 0, afalta[aux], 1, "(FALTAN)", "S", .T.)
        	RECUPAN()
        ENDIF
		ELSEIF aed[ED_TECLA] == K_TAB .AND. "aTot"$EDNOM(aed)
        IF LEN(aTotal[2]) == 0
        	TONE(100,1)
        ELSE
				PP_SELEC( aed[ED_Y]-5, aed[ED_X], 0, 0, aTotal[2], 1, "FACTURAS", "S", .T.)
        	RECUPAN()
        ENDIF
		ELSEIF aed[ED_TECLA] == K_ESC
			EXIT
		ENDIF
	ENDDO
	FEDITOR(aed,"SACAPAN")
 	MENUDOWN(xmenu)

ENDIF
DBSELECTAREA(cBase)
GO nReg


RETURN
