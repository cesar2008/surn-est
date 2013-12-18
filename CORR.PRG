#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "COMMON.CH"

PARAMETERS nCual, lBrowser, lMarcar
LOCAL nReg := RECNO(), OX2, cAux, cBase:=DBF(), r:=.F.
DEFAULT lBrowser TO .F.
DEFAULT lMarcar TO .F.

FBASES({"+CORR"},.F.)
SELECT COR
set order to 1
if nCual # NIL
	r := dbseek( nCual )
endif
if !lBrowser
	if r
  	r := COR->CORREDOR
  else
  	r := space(len(COR->CORREDOR))
  endif
  SELECT (cBase)
 	RETURN(r)
endif
if eof()
	go top
endif


aCp:={;
     { "CODCORR",     "C¢d",              '', 'F',  '',  0, 0 },;
     { "CORREDOR",    "Corredor",         '', 'F',  '',  0, 0 } }
if lMarcar
	aadd(aCp,;
     { "MARCA",       "Mca",             '!', 'F',  '',  0, 0 } )
endif

SELECT COR
aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
aCp[2,ATB_TIPO] := "C"
SETCOLOR( "W/N,N/W" )
MARCO( 7, 30, 17, 77, "³ CORREDORES ³", "S", .T., 0 )
OX2 := MYBROWSE( 7, 30, 17, 77, aCp )
OX2:CARGO[TB_REFRESH] := 10
if lMarcar
cAux := MENUDOWN({"  <+>  º F3 busca  º    F2    º   F5   º   F6    º  ESC  ",;
                  "       º           º          º        º         º       ",;
                  " mueve º F4 busca+ º modifica º agrega º elimina º  sale "})
else
cAux := MENUDOWN({"  <+>  º F3 busca  º   +   º     -    º ESPACIO  º  ESC  ",;
                  "       º           º marca º desmarca º marca /  º       ",;
                  " mueve º F4 busca+ º      º         º desmarca º  sale "})
endif
DO WHILE .T.
	MOVBROW( OX2, {||nK==K_F2.OR.nK==K_F6.OR.nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F5.OR.CHR(nK)$" +-"} )
	IF OX2:Cargo[TB_MSGE] == "MODIF"
	ELSEIF OX2:CARGO[TB_RET] == K_F2 .OR. OX2:CARGO[TB_RET] == K_F5
		EDCORR( OX2:CARGO[TB_RET] )
		OX2:REFRESHALL()
	ELSEIF OX2:CARGO[TB_RET] == K_ENTER
		r := .T.
		EXIT
	ELSEIF OX2:CARGO[TB_RET] == K_F6
		IF PREGUNTA( 11, "¨ ESTA SEGURO  [ S / N ] ?", "SsNn")$ "Ss"
     	xAux := &(INDEXKEY())
			BLANKREG()
        dbseek(xAux,.t.)
			OX2:REFRESHALL()
     ENDIF
	ELSEIF OX2:CARGO[TB_RET] == 43			// +
		MENSAJE( 99, 99, 0, .F., "MARCANDO . . ." )
		FFLOCK()
		lastreg = RECNO()
		REPLACE MARCA WITH "" FOR ROSCA().AND.MARCA # "" REST
		GO lastreg
		UNLOCK ALL
		RECUPAN()
		CLEARTYPEAHEAD()
		OX2:REFRESHCURRENT()
	ELSEIF OX2:CARGO[TB_RET] == 45			// -
		MENSAJE( 99, 99, 0, .F., "DESMARCANDO . . ." )
		FFLOCK()
		lastreg = RECNO()
		REPLACE MARCA WITH " " FOR ROSCA().AND.MARCA # " " REST
		GO lastreg
		UNLOCK ALL
		RECUPAN()
		CLEARTYPEAHEAD()
		OX2:REFRESHCURRENT()
	ELSEIF OX2:CARGO[TB_RET] == 32
		FRLOCK()
		REPLACE MARCA WITH IF( MARCA=='', '', '' )
		UNLOCK
		CLEARTYPEAHEAD()
		OX2:REFRESHCURRENT()
     KEYBOARD CHR(K_DOWN)
	ELSEIF OX2:CARGO[TB_RET] == K_ESC
		r := .F.
		EXIT
	ENDIF
ENDDO
RECUPAN()
PONEPAN(cAux)
if F_ABASE(cBase,"?")
	select (cBase)
endif

RETURN r


***********************

STATIC FUNC EDCORR( K )

***********************
LOCAL aux, EDX, xmenu, nOrder

xmenu:=MENUDOWN({"     º presione TAB en los cam- º  F10  º  ESC   ",;
                 "       º pos con  p/obtener una  º       º        ",;
                 " mueve º lista de de opciones.    º graba º  sale  "})

SELECT COR
EDX := NEWEDIT( "CORR" )
IF K == K_F5
	FEDITOR( EDX, "SETVARS", K, .F. )
	SET ORDER TO 1
	nAux := RECNO()
	GO nAux
ELSE
	FEDITOR( EDX, "SETVARS", K, .F. )
ENDIF
IF EDCONT(EDX,"COR->CODCORR") == 0
	EDPONE(EDX,"COR->CODCORR",ULTIMO(DBF(),"COR->CODCORR")+1)
ENDIF
EDX[ED_MODE] = "MOSTRARTODO"

DO WHILE .T.
	FEDITAR( EDX, { K_F10 } )
	IF EDX[ED_UPDATE]
		EDX[ED_MODE] = "MOSTRAR"
		IF EDNOM(EDX) == "COR->CUIT"
			nOrden := INDEXORD()
			DBSETORDER( FORDER({"CUIT"}) )
			IF FREPEAT( EDCONT(EDX), EDX[ED_MODAPP] )
				MENSAJE( 0, 0, 10, .T., "ESTE C.U.I.T. YA FUE REGISTRADO !!!" )
				EDPONE( EDX,, EDX[ED_LAST] )
			ENDIF
			DBSETORDER( nOrden )
		ENDIF
	ELSEIF EDX[ED_TECLA] == K_TAB
		EDX[ED_MODE] = "MOSTRARTODO"
		IF EDNOM(EDX) == "COR->CATIVA"
			ele = PP_SELEC( EDX[ED_Y], EDX[ED_X], 0, 0, acativa, EDCONT(EDX), "", "S", .T.)
			IF LASTKEY() == K_ENTER
				EDPONE( EDX, , LEFT(acativa[ele],3) )
			ENDIF
			RECUPAN()
		ELSEIF EDNOM(EDX) $ "COR->LOCALIDAD COR->CODPOS"
			IF CP( EDCONT(EDX,"COR->LOCALIDAD") )
				EDPONE(EDX,"COR->LOCALIDAD",CP->LOCALIDAD)
				EDPONE(EDX,"COR->CODPOS",CP->CODPOS)
				EDX[ED_MODE] = "MOSTRARTODO"
			ENDIF
		ENDIF
	ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
		aux := "S"
		IF EDX[ED_TECLA] == K_F10
			aux := "G"
		ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
		ENDIF
		IF aux == "G"
			IF EMPTY(EDCONT(EDX,"COR->CORREDOR"))
				MENSAJE( 0, 0, 10, .T., " FALTA NOMBRE CORREDOR !!!" )
			ELSE
     		if "AGREG" $ EDX[ED_MODAPP]
        		F_ALTA({|| !empty(FIELD->CODCORR)})
           	EDX[ED_REGISTRO] := recno()
        	endif
				FEDITOR( EDX, "GRABAR", .F. )
				EXIT
			ENDIF
		ELSEIF aux == "S"
			EXIT
		ENDIF
	ENDIF
ENDDO
FEDITOR(EDX,"SACAPAN")
MENUDOWN(xmenu)

RETURN ( aux=="G" )
