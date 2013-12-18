#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

parameters cCual
LOCAL nReg:=RECNO(), OX, aCpo, cBase:=DBF()
LOCAL AX, xmenu, xmenu2, nAux, nAux2, nAux3

FBASES({"OPAG","COMPRASV","PROVEEV"})
aCpo:={;
		{ "NUMOPAG",        "Orden;Pago",                    '', 'E',  '',  0, 0 },;
		{ "FECHA",          "Fecha; ",                       '', 'E',  '',  0, 0 },;
 		{ "EFECTIVO",       "Efectivo",                      '', 'E',  '',  0, 0 },;
 		{ "CHEQUE",         "Cheque",                        '', 'F',  '',  0, 0 },;
 		{ "TARJETA",        "Tarjeta",                       '', 'E',  '',  0, 0 },;
		{ "OTROS",          "Otros",                         '', 'F',  '',  0, 0 },;
 		{ "DESCR",          "Descr.",                        '', 'F',  '',  0, 0 }}
SELECT OPG
IF cCual==NIL .OR. cCual==0
 	DBGOTOP()
ELSE
	IF !DBSEEK( cCual )
  	GO nReg
  ENDIF
ENDIF
xmenu:=MENUDOWN({"  <+>  º    F2    º   F5   º  F6   º  F8  º  ENTER   º ESC  ",;
			  			"       º          º        º       ºrecal-º confirma º      ",;
						" mueve º modifica º agrega ºeliminaº cula º elecci¢n º sale "})

SETCOLOR( "W/N,N/W" )
MARCO( 7, 1, 20, 78, "<< ORDENES DE PAGO >>", "D", .T., 0 )
OX := MYBROWSE( 7, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 0
nreg := RECNO()
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F8} )
	IF OX:Cargo[TB_MSGE] == "MODIF"
	ELSEIF OX:Cargo[TB_RET] == K_F2 .OR. OX:Cargo[TB_RET] == K_F5
		IF EDOPG( OX:Cargo[TB_RET] )
     	TBPOS(OX,.T.)
     ENDIF
	ELSEIF OX:Cargo[TB_RET] == K_F8
		MENSAJE( 99, 99, 0, .F., "RECALCULANDO..." )
     SELECT CO
     nAux := RECNO()
     nAux2 := 0
     nAux3 := LASTREC()
     GO TOP
     SELECT CO2
     DO WHILE !CO->(EOF())
     	IF CO->NUMOPAG == OPG->NUMOPAG
				SEEK STR(CO->CODPROV)+CO->NUMFAC
 				DO WHILE CO2->CODPROV==CO->CODPROV .AND. CO2->NUMFAC==CO->NUMFAC .AND. !CO2->(EOF())
           	IF OPG->CODPROD==0 .OR. OPG->CODPROD==CO2->CODPROD
              	nAux2 += CO2->CANTIDAD
              ENDIF
              SKIP
           ENDDO
        ENDIF
        @ 24,70 SAY --nAux3 PICT "9999"
     	SKIP 1 ALIAS CO
     ENDDO
     SELECT CO
     go nAux
     SELECT OPG
     FRLOCK()
     OPG->CANTUSADO := nAux2
     DBUNLOCK()
		RECUPAN()
     TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_ESC
  	GO nreg
     EXIT
	ELSEIF OX:Cargo[TB_RET] == K_ENTER
		EXIT
	ENDIF
ENDDO
SELECT (cBase)
RECUPAN()
MENUDOWN(xmenu)
DBSELECTAREA(cBase)

RETURN ( OX:Cargo[TB_RET]==K_ENTER )


*************

FUNC EDOPG(K)

*************
xmenu2:=MENUDOWN({"     º si el C¢digo del  º   F10   º  ESC   ",;
						 "       º Producto es 0 la  º graba y º        ",;
						 " mueve º Orden es GENERICA º procede º  sale  "})
AX := NEWEDIT( "OPAG",,.T. )
FEDITOR( AX, "SETVARS", K,.F. )
IF K==K_F5
	GO BOTTOM
  EDPONE(AX,"OPG->NUMOPAG",NUEVOCOD(dbf(),"NUMOPAG",1))
ENDIF
AX[ED_MODE] = "MOSTRARTODO"
DO WHILE .T.
	FEDITAR( AX, { K_F10 } )
	IF AX[ED_UPDATE]
		AX[ED_MODE] = "MOSTRAR"
     IF EDNOM(AX) == "OPG->NUMOPAG"
			IF FREPEAT( EDCONT(AX), AX[ED_MODAPP] )
				MENSAJE ( 0, 0, 10, .T.,"CODIGO REPETIDO !!! ")
				EDPONE( AX,, AX[ED_LAST] )
				AX[ED_TECLA] := 0
			ENDIF
			AX[ED_MODE] := "MOSTRARTODO"
		ENDIF
	ELSEIF AX[ED_TECLA] == K_TAB
		IF EDNOM(AX) == "OPG->CODPROD"
			IF FELEGIR( "PRODUCTO", EDCONT(AX) ) # 0
				EDPONE( AX,, PRD->CODPROD )
			ENDIF
		ELSEIF EDNOM(AX) == "OPG->TIPOCOMPRA"
			ele = PP_SELEC( AX[ED_Y], AX[ED_X], 0, 0, atipoventa, EDCONT(AX), "", "S", .T.,.T.)
			IF LASTKEY() == K_ENTER
				EDPONE(AX,,VAL(atipoventa[ele]) )
			ENDIF
			RECUPAN()
		ENDIF
		AX[ED_MODE] = "MOSTRARTODO"
	ELSEIF AX[ED_TECLA] == K_ESC .OR. AX[ED_TECLA] == K_F10
		IF AX[ED_TECLA] == K_ESC
     	aux := "S"
			IF FEDITOR( aX, "HUBOCAMBIOS" )
				aux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
			ENDIF
		ELSE
        aux :="G"
     ENDIF
     IF aux == "G"
			IF OX:Cargo[TB_RET]==K_F5
        	GO TOP
           IF OPG->NUMOPAG#0 .OR. LASTREC()==0
           	ADD_REC()
           ENDIF
			ENDIF
        AX[ED_REGISTRO]:=RECNO()
			FEDITOR(AX,"GRABAR",.F.)
        EXIT
		ELSEIF aux == "S"
        exit
		ENDIF
	ENDIF
ENDDO
FEDITOR(AX,"SACAPAN")
MENUDOWN(xmenu2)
TBPOS(OX,.T.)

return
