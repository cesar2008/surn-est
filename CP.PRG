#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PARAMETERS cCualLoc, lBuscar
LOCAL cBase:=DBF(), cMenu, aCpo, OCP, r:=.f.
DEFAULT cCualLoc TO ""
DEFAULT lBuscar TO .F.

FBASES( {"+CODPOS"} )
select CP
set order to 2
dbseek( cCualLoc, .T. )
if eof()
	go top
endif

aCpo:={;
	{ "CODLOC",     "C¢digo",                 '', 'F',  '',  0, 0 },;
	{ "LOCALIDAD",  "Localidad",              '', 'E',  '',  0, 0 },;
	{ "CODPOS",     "C¢d.Post",               '', 'E',  '',  0, 0 },;
	{ "PARTIDO",    "Partido",                '', 'E',  '',  0, 0 } }

aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )

cMenu:=MENUDOWN({"  <+>  º    F2    º   F5   º   F3  º   O    º  ESC  ",;
			  			"       º          º        º       º cambia º       ",;
			  			" mueve º modifica º agrega º busca º orden  º  sale "})

SETCOLOR( "N/W+,W/N,N/W" )
MARCO( 8, 25, 18, 78, "³ LOCALIDADES ³", "S", .T., 0 )
OCP := MYBROWSE( 8, 25, 18, 78, aCpo )
OCP:CARGO[TB_REFRESH] := 10
cBuscar := ""
DO WHILE .T.

	MOVBROW( OCP, {||nK==27.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F3.OR.nK==K_F4.OR.nK==K_ENTER.OR.CHR(nK)$'Oo'} )

	IF OCP:Cargo[TB_MSGE] == "MODIF"
		auxtb := FIELD->&(TBNOC(OCP))
		FRLOCK()
		FIELD->&(TBNOC(OCP)) := OCP:CARGO[TB_CONT]
		TBPOS(OCP,.T.)

	ELSEIF OCP:CARGO[TB_RET] == K_F2 .OR. OCP:CARGO[TB_RET] == K_F5
		EDCP( OCP:CARGO[TB_RET] )
		OCP:REFRESHALL()

	ELSEIF OCP:Cargo[TB_RET] == K_F3
  	xAux := FIELD->&(TBNOC(OCP))
  	IF TBNOC(OCP) == "CALLE"
  		xAux := SPACE(20)
     ENDIF
		xAux = ALLTRIM(INGRVAL( 10, 0, "Buscar:", xAux, "@K!", "") )
     if lastkey() == K_ENTER
     	cBuscar := ""
     	xAux := ALLTRIM(xAux)
        nOrder := INDEXORD()
  		IF TBNOC(OCP) == "CALLE"
				SET ORDER TO FORDER({"CALLE","DENOM_PROV"})
        	DBSEEK(xAux,.T.)
  		ELSEIF TBNOC(OCP) == "CODPOS"
				SET ORDER TO FORDER({"CODPOS","CALLE"})
        	DBSEEK(xAux,.T.)
        ELSEIF !EMPTY(xAux)
				MENSAJE( 0, 0, 0, .f., "BUSCANDO..." )
        	cBuscar := "'"+xAux+"'$"+TBNOC(OCP)
        	LOCATE FOR &(cBuscar)
           RECUPAN()
           IF !FOUND()
					MENSAJE( 0, 0, 10, .T., "NO ENCONTRADO !!" )
     			cBuscar := ""
           ENDIF
			ENDIF
        SET ORDER TO nOrder
     endif
     TBPOS(OCP,.T.)

	ELSEIF OCP:Cargo[TB_RET] == K_F4 .AND. !EMPTY(cBuscar)
		MENSAJE( 0, 0, 0, .f., "BUSCANDO..." )
    	LOCATE FOR &(cBuscar) REST
     RECUPAN()
     IF !FOUND()
			MENSAJE( 0, 0, 10, .T., "NO ENCONTRADO !!" )
     	cBuscar := ""
     ENDIF
     TBPOS(OCP,.T.)

	ELSEIF CHR(OCP:Cargo[TB_RET]) $ 'Oo'
		op2 := MENUFLASH( 10, 30, INDEXORD(), .T., "", "ordenado x LOCALIDAD", "ordenado x CODIGO POSTAL" )
     IF LASTKEY() == K_ENTER
			SET ORDER TO op2
     ENDIF
     TBPOS(OCP,.T.)

	ELSEIF OCP:Cargo[TB_RET] == K_ESC .OR. OCP:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
RECUPAN()
PONEPAN(cMenu)
SELECT (cBase)

RETURN (OCP:Cargo[TB_RET]==K_ENTER)


***************

FUNC EDCP( K )

***************
LOCAL aux, EDX, xmenu, nOrder

xmenu:=MENUDOWN({"      º  F10  º  ESC   ",;
                 "        º       º        ",;
                 " mueve  º graba º  sale  "})

SELECT CP
EDX := NEWEDIT( "CP" )
IF K == K_F5
	FEDITOR( EDX, "SETVARS", K, .F. )
ELSE
	FEDITOR( EDX, "SETVARS", K, .F. )
ENDIF
IF EDCONT(EDX,"CP->CODLOC") == 0
	EDPONE(EDX,"CP->CODLOC",ULTIMO(dbf(),"CODLOC",1)+1)
ENDIF
EDX[ED_MODE] = "MOSTRARTODO"

DO WHILE .T.
	FEDITAR( EDX, { K_F10 } )
	IF EDX[ED_UPDATE]
		EDX[ED_MODE] = "MOSTRAR"
	ELSEIF EDX[ED_TECLA] == K_ESC .OR. ( EDX[ED_TECLA]==K_ENTER .AND. EDX[ED_I]==LEN(EDX[ED_FIELDS]) ) .OR. EDX[ED_TECLA] == K_F10
		aux := "S"
		IF EDX[ED_TECLA] == K_F10
			aux := "G"
		ELSEIF FEDITOR( EDX, "HUBOCAMBIOS" )
			aux := UPPER( PREGUNTA( 11, "¨ [G] graba    [S] sale    [C] contin£a", "GgSsCc") )
		ENDIF
		IF aux == "G"
			IF EMPTY(EDCONT(EDX,"CP->LOCALIDAD"))
				MENSAJE( 0, 0, 10, .T., " FALTA LOCALIDAD !!!" )
			ELSE
     		if "AGREG" $ EDX[ED_MODAPP]
        		F_ALTA({|| !empty(FIELD->CODLOC)})
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