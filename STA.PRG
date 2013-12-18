LOCAL aCpo, oGET, nReg, cBase:=DBF()
LOCAL lActFecha := .F., cMenu

#include "TB.CH"
#include "EDI.CH"
#include "EST.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

aCpo:={;
	{ "CODPROD",           "C¢digo; ",                             '', 'F',  '',  0, 0 },;
	{ "DESCPROD",          "Descripci¢n",              REPLIC('!',20), 'F',  '',  0, 0 },;
	{ "FECHA",             "Fecha;Inven;tario",                    '', 'E',  '',  0, 0 },;
	{ "STOCKACT",          "Stock;Actual;Local",                   '', 'M',  '',  0, 0 },;
	{ "CONDEP",            "Con;Dep",                             '!', 'E',  '',  0, 0 },;
	{ "STOCKACTD",         "Stock;Actual;Dep¢sito",                '', 'E',  '',  0, 0 },;
	{ "STOCKINI",          "Stock;Inicial;Local",                  '', 'E',  '',  0, 0 },;
	{ "STOCKINID",         "Stock;Inicial;Dep¢sito",               '', 'E',  '',  0, 0 },;
	{ "ART->STOCKACT+ART->STOCKACTD","Stock;Actual",               '999999.999', 'F', 'F', 10, 3 } }

select ART
aCpo := FBASEAUX( aCpo, "ART", SELECT(), .F. )
M->FECHA := DATE()

SETCOLOR( "W/N,N/W" )
MARCO( 5, 1, 19, 78, "STOCK PRODUCTOS SERVICOMPRAS", "D", .T., 0 )
OX := MYBROWSE( 5, 1, 19, 78, aCpo )
OX:CARGO[TB_REFRESH] := 5

cMenu:=MENUDOWN({"  <+>  º ESC  ",;
			  			"       º      ",;
						" mueve º sale "})
DO WHILE .T.
	MOVBROW( OX, {||nK==9.OR.nK==K_ESC.OR.nK==K_F9.OR.nK==K_F3.OR.nK==K_F4.OR.nK==K_F8.or.upper(chr(nK))$'ABCDEFGHIJKLMNOPQRSTUVWXYZ¥¤0123456789' } )

	IF OX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
     IF TBNOC(OX) == "STOCKACT"
     	ART->STOCKINI := ART->STOCKACT
        ART->FECHA  := M->FECHA
     ENDIF
		DBUNLOCK()
		OX:REFRESHCURRENT()
	ELSEIF upper(chr(OX:Cargo[TB_RET])) $ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ¥¤0123456789'
  	cAux:=space(20)
  	keyboard upper(chr(OX:Cargo[TB_RET]))
		SET KEY 10 TO CLEAR_GETS()
		cAux := INGRVAL( 10, 20, "Producto:", cAux, "", "")
		SET KEY 10 TO
     if lastkey()==K_ENTER .or. lastkey()==10
     	nReg:=recno()
     	cAux:=alltrim(cAux)
     	if val(cAux)==0
				r := SELECTAR( cAux )
				IF r # 0
					if dbseek(r);  nReg:=0;  endif
				endif
        elseif len(cAux)>7		// busca x c¢digo scaner
        	set order to ART_CODSCAN
        	if dbseek(cAux,.T.);  nReg:=0;  endif
        else
        	set order to 1
        	if dbseek(val(cAux));  nReg:=0;  endif
        endif
       	set order to 1
        if nReg#0;  go nReg;  endif
     endif
     TBPOS(OX,.T.)

	ELSEIF OX:Cargo[TB_RET] == K_F3 .OR. OX:Cargo[TB_RET] == K_F4
  	BUSCADOR( OX:CARGO[TB_RET], OX )

	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
ENDDO
RECUPAN()
SELECT (cBase)

RETURN
