LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " VARILLADA " )

RG_FECHA     :=  1
RG_CODPROD   :=  2
RG_DESCPROD  :=  3
RG_CANTIDAD  :=  4

MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
FBASES({ "VARI" },.F.)
aCpo:={	                                                                  ;
	{ "FECHA",             "Fecha; ",                 '', 'M',  '',  0, 0 },;
  { "CODPROD",           "C¢d;Prod",                '', 'M',  '',  0, 0 },;
	{ "DESCPROD",          "Descripci¢n",             '', 'F',  '',  0, 0 },;
	{ "CANTIDAD",          "Cantidad",                '', 'M',  '',  0, 0 } }
SELECT VR
aCpo := FARRAYAUX( aCpo )
DBGOBOTTOM()

RECUPAN()

MENUDOWN({"  <+>  º F2 modif. º F6  Shift F6  º    TAB    º  ESC   ",;
			  "       º F3 busca  º               º productos º        ",;
			  " mueve º F4 busca+ º elimina l¡nea º conceptos º  sale  "})

SETCOLOR( "W/N,N/W" )

oX := MYBROWSE( 4, 1, 20, 78, aCpo )

oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()

DO WHILE .T.
	
	MOVBROW( oX, {||nK==9.OR.nK==-4.OR.nK==-5.OR.nK==27.OR.nK==-8.OR.nK==-7.OR.nk==-6.OR.nK==K_SH_F6}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )
	
	IF oX:Cargo[TB_MSGE] == "MODIF"
		IF TBNOC(OX) == "CODPROD"
     	ACTSTOCK(-1)
  		FPROD( OX:CARGO[TB_CONT] )
        FRLOCK()
			FIELD->CODPROD   := PRD->CODPROD
			FIELD->DESCPROD  := PRD->DESCPROD
        DBUNLOCK()
     	ACTSTOCK(1)
		ELSEIF TBNOC(OX) $ "FECHA CANTIDAD"
     	ACTSTOCK(-1)
			FRLOCK()
			FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
			UNLOCK
     	ACTSTOCK(1)
     ELSE
			FRLOCK()
			FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
			UNLOCK
		ENDIF
		TBPOS(OX)
		
	ELSEIF OX:Cargo[TB_RET] == K_TAB
		IF TBNOC(OX) == "CODPROD"
  		IF FELEGIR('PRODUCTO', FIELD->CODPROD ) # 0
     		ACTSTOCK(-1)
           FRLOCK()
				FIELD->CODPROD   := PRD->CODPROD
				FIELD->DESCPROD  := PRD->DESCPROD
           DBUNLOCK()
     		ACTSTOCK(1)
     	ENDIF
		ENDIF
		TBPOS(OX)

	ELSEIF OX:Cargo[TB_RET] == K_F5
		DBGOBOTTOM()
     aux := FIELD->FECHA
  	GO TOP
     IF !EMPTY(FIELD->FECHA) .OR. LASTREC()==0
     	ADD_REC()
     ENDIF
     FRLOCK()
     FIELD->FECHA := IF(EMPTY(aux),DATE(),aux)
  	DBUNLOCK()
		TBPOS(OX,.T.)

	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	ACTSTOCK(-1)
     	aux := FIELD->FECHA
			BLANKREG(.T.)
        DBSEEK( aux, .T. )
			TBPOS(OX,.T.)
		ENDIF

	ELSEIF oX:Cargo[TB_RET] == K_SH_F6
     ACTSTOCK(-1)
     aux := FIELD->FECHA
		BLANKREG(.T.)
     DBSEEK( aux, .T. )
		TBPOS(OX,.T.)

	ELSEIF oX:Cargo[TB_RET] == K_F7
		LISTADOR( "VARILLADA" )
		TBPOS(OX,.T.)

	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT

	ENDIF

ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN


******************

STATIC FUNC ACTSTOCK( cual )

******************
LOCAL nReg
RETURN								// BORRAR
SELECT PRD
nReg := RECNO()
SET ORDER TO 1
FFLOCK()
SEEK VR->CODPROD
IF FOUND() .AND. VR->FECHA >= PRD->FECHA
	FRLOCK()
 	PRD->AJUSTES += ( VR->CANTIDAD * cual )
  PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
  DBUNLOCK()
ENDIF
GO nReg
SELECT VR

RETURN
