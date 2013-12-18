#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PARAMETERS nCual, lBrowser, lMarcar
LOCAL cBase:=DBF(), cMenu, aCpo, OPC, r:=.f., nReg:=PC->(recno())
DEFAULT lBrowser TO .F.
DEFAULT lMarcar TO .F.

select PC
set order to 1
if nCual # NIL
	r := dbseek( nCual )
endif
if !lBrowser
	if r
  	r := PC->DESCPLAN
  else
  	r := space(len(PC->DESCPLAN))
  endif
  SELECT (cBase)
 	RETURN(r)
endif
if eof()
	go nReg
endif
if eof()
	go top
endif

aCpo:={;
	{ "CODPLAN",           "C¢digo",     replic('X',16), 'F', 'F', 16, 0 },;
	{ "DESCPLAN",          "Descripci¢n",            '', 'E',  '',  0, 0 },;
	{ "TIPO",              "Tipo",                   '', 'E',  '',  0, 0 }}
if lMarcar
	aadd(aCpo,{ "MARCA",   "MARCA",                  '', 'F',  '',  0, 0 })
	cMenu:=MENUDOWN({"  <+>  º    +     º   F5   º F3 busca  º ESC  ",;
			  			  "       º          º        º           º      ",;
			  			  " mueve º marcaica º agrega º F4 busca+ º sale "})
else
	cMenu:=MENUDOWN({"  <+>  º    F2    º   F5   º F3 busca  º    F7   º ESC  ",;
			  			  "       º          º        º           º         º      ",;
			  			  " mueve º modifica º agrega º F4 busca+ º imprime º sale "})
endif
aCpo := FBASEAUX( aCpo, dbf(), select(), .F. )

SETCOLOR( "N/W+,W/N,N/W" )
MARCO( 8, 25, 18, 78, "³ PLAN DE CUENTAS ³", "S", .T., 0 )
OPC := MYBROWSE( 8, 25, 18, 78, aCpo )
OPC:CARGO[TB_REFRESH] := 10
cBuscar := ""
DO WHILE .T.

	MOVBROW( OPC, {||nK==27.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F7.OR.nK==K_F9.OR.nK==K_ENTER.OR.CHR(nK)$'Ss+- Ii'} )

	IF OPC:Cargo[TB_MSGE] == "MODIF"
		auxtb := FIELD->&(TBNOC(OPC))
		FRLOCK()
		FIELD->&(TBNOC(OPC)) := OPC:CARGO[TB_CONT]
		TBPOS(OPC,.T.)

  ELSEIF chr(OPC:Cargo[TB_RET])$" +-" .or. OPC:Cargo[TB_RET]==K_F9
* 	FMARCA( OPC:Cargo[TB_RET], ,{||PC->TIPO=="I"})
  	FMARCA( OPC:Cargo[TB_RET] )
     TBPOS(OPC,.T.)

  ELSEIF chr(OPC:Cargo[TB_RET])$"Ii"
		FRLOCK()
     PC->TIPO := if( PC->TIPO=="I", "", "I" )
     DBUNLOCK()
     TBPOS(OPC)

	ELSEIF OPC:CARGO[TB_RET] == K_F7
		LISTAR("..\CG\PC")

	ELSEIF OPC:CARGO[TB_RET] == K_F2 .OR. OPC:CARGO[TB_RET]==K_F5
		EDPC( OPC:CARGO[TB_RET] )
		OPC:REFRESHALL()

	ELSEIF chr(OPC:CARGO[TB_RET]) $ "Ss"
  	//1234567890
  	//9.9.99.999
		nReg:=recno()
     FFLOCK()
     go top
     do while !eof()
     	n:=6
     	n-=if(substr(PC->CODPLAN,3,1)==' ',1,0)
     	n-=if(substr(PC->CODPLAN,5,1)==' ',2,0)
     	n-=if(substr(PC->CODPLAN,8,1)==' ',3,0)
        PC->ESPACIO:=n
     	skip
     enddo
     go nReg
     DBUNLOCK()
     TBPOS(OPC,.T.)

	ELSEIF OPC:Cargo[TB_RET] == K_ESC .OR. OPC:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
RECUPAN()
PONEPAN(cMenu)
SELECT (cBase)

RETURN (OPC:Cargo[TB_RET]==K_ENTER)


*********************

STATIC FUNC EDPC( K )

*********************
LOCAL aux, EDX, xmenu, nOrder

xmenu:=MENUDOWN({"      º  F10  º  ESC   ",;
                 "        º       º        ",;
                 " mueve  º graba º  sale  "})

SELECT PC
SET ORDER TO 1
EDX := NEWEDIT( "..\CG\PLANCTA" )
IF K == K_F5
*	go bottom
  cAux := left(PC->CODPLAN,7)
  cAux2:=PC->CODPLAN
	do while left(PC->CODPLAN,7)==cAux .and. !eof()
  	cAux2:=PC->CODPLAN
     skip
  enddo
	FEDITOR( EDX, "SETVARS", K, .F. )
  EDPONE(EDX,"PC->CODPLAN",left(cAux2,7)+strzero(val(right(cAux2,3))+1,3) )
ELSE
	FEDITOR( EDX, "SETVARS", K, .F. )
ENDIF
EDX[ED_MODE] = "MOSTRARTODO"

DO WHILE .T.
	FEDITAR( EDX, { K_F10 } )
	IF EDX[ED_UPDATE]
		EDX[ED_MODE] = "MOSTRARTODO"
     IF EDNOM(EDX)=="PC->CODPLAN"
			IF FREPEAT( EDCONT(EDX), EDX[ED_MODAPP] )
				MENSAJE (0, 0, 10, .T.,"CODIGO REPETIDO !!! ")
				EDPONE( EDX,, EDX[ED_LAST] )
				EDX[ED_TECLA] := 0
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
			IF EMPTY(EDCONT(EDX,"PC->CODPLAN"))
				MENSAJE( 0, 0, 10, .T., "FALTA CODIGO !!!" )
			ELSEIF EMPTY(EDCONT(EDX,"PC->DESCPLAN"))
				MENSAJE( 0, 0, 10, .T., "FALTA DESCRIPCION !!!" )
			ELSE
     		if "AGREG" $ EDX[ED_MODAPP]
        		F_ALTA({|| !empty(FIELD->CODPLAN)})
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

***********
FUNC JFPC()
***********
return left( space(PC->ESPACIO)+PC->CODPLAN+space(16), 16 )
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
if listado == "PC"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	DO ICARGA WITH listado
	xreg := RECNO()
	dbgotop()
	do while !salir() .and.!eof()
		CABEZA( 1 );  I_CL+=1
		? I_esp + ARMOLIN(I_cab+1)
		skip
	enddo
	CABEZA( 1 )
	I_CL += 1
	?  I_esp + ARMOLIN(I_cab)
	dbgoto( xreg )
	LISTADOR( "FIN" )
endif
RECUPAN()

return
