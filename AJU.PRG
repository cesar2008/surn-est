LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " AJUSTES " )

RG_CODCONC   :=  1
RG_DESCONC   :=  2
RG_CODPROD   :=  3
RG_DESCPROD  :=  4
RG_CANTIDAD  :=  5
RG_REGISTRO  :=  6

MENSAJE( 0, 0, 0, .F., " AGUARDE . . . " )
DO CARGAVEC WITH "AJUSTES", 50
FBASES({ "AJUSTES" },.F.)
aCpo:={	                                                                  ;
	{ "FECHA",             "Fecha; ",                 '', 'M',  '',  0, 0 },;
	{ "CODCONC",           "C¢d;Conc",             '!!!', 'M',  '',  0, 0 },;
  { "DESCONC",			  "Descripci¢n; ",           '', 'F',  '',  0, 0 },;
  { "CODPROD",           "C¢d;Prod",                '', 'M',  '',  0, 0 },;
	{ "DESCPROD",          "Descripci¢n",             '', 'F',  '',  0, 0 },;
	{ "CANTIDAD",          "Cantidad",                '', 'M',  '',  0, 0 },;
	{ "PRECBASE",          "Precio;base",             '', '',  '',  0, 0 },;
	{ "IMPINT",            "Imp.;Int",                '', '',  '',  0, 0 },;
	{ "PRECUNIT",          "Precio;Unit",             '', '',  '',  0, 0 },;
	{ "IMPORTE",           "Importe; ",               '', '',  '',  0, 0 } }
SELECT AJ
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
        FIELD->PRECBASE  := PRD->PRECBASE
        FIELD->IMPINT    := PRD->IMPINT
        FIELD->IVA       := PRD->PRECBASE * VA->PIVA1 / 100
        FIELD->PRECUNIT  := PRD->PRECVENTA
        DBUNLOCK()
     	ACTSTOCK(1)
		ELSEIF TBNOC(OX) $ "FECHA CANTIDAD"
     	ACTSTOCK(-1)
			FRLOCK()
			FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
        FIELD->IMPORTE := FIELD->PRECUNIT * FIELD->CANTIDAD
			UNLOCK
     	ACTSTOCK(1)
     ELSE
			FRLOCK()
			FIELD->&(oX:CARGO[TB_NOMBRE,oX:ColPos]) := oX:CARGO[TB_CONT]
			UNLOCK
		ENDIF
		TBPOS(OX)
		
	ELSEIF OX:Cargo[TB_RET] == K_TAB
		IF TBNOC(OX) == "CODCONC"
			xmenu:=MENUDOWN({	"º     º    F2    º   F5   º  ENTER   º ESC  º",;
									"º       º          º        º          º      º",;
									"º mueve º modifica º agrega º confirma º sale º"})
			ele := ABRW( 5, 10, 0, 'vajustes', FIELD->CODCONC, 'CONCEPTOS')
			IF LASTKEY() == K_ENTER
           FRLOCK()
				FIELD->CODCONC := LEFT(vajustes[ele],3)
           FIELD->DESCONC := FVECTOR(vajustes,FIELD->CODCONC)
           DBUNLOCK()
			ENDIF
			PONEPAN(xmenu)
				
		ELSEIF TBNOC(OX) == "TURNO"
			ele = PP_SELEC( 10, 30, 0, 0, aturno, FIELD->TURNO, "", "S", .T.)
			IF LASTKEY() == K_ENTER
           FRLOCK()
				FIELD->TURNO := LEFT(aturno[ele],1)
           DBUNLOCK()
			ENDIF
        RECUPAN()
			
		ELSEIF TBNOC(OX) == "CODPROD"
  		IF FELEGIR('PRODUCTO', FIELD->CODPROD ) # 0
     		ACTSTOCK(-1)
           FRLOCK()
				FIELD->CODPROD   := PRD->CODPROD
				FIELD->DESCPROD  := PRD->DESCPROD
           FIELD->PRECBASE  := PRD->PRECBASE
           FIELD->IMPINT    := PRD->IMPINT
           FIELD->IVA       := PRD->PRECBASE * VA->PIVA1 / 100
           FIELD->PRECUNIT  := PRD->PRECVENTA
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
		IF MARCABRW( 7, 30, vajustes, LV(vajustes) ) # 0
			LISTADOR( "AJUSTES" )
		ENDIF
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
SELECT PRD
nReg := RECNO()
SET ORDER TO 1
FFLOCK()
SEEK AJ->CODPROD
IF FOUND() .AND. AJ->FECHA >= PRD->FECHA
	FRLOCK()
	PRD->AJUSTES += ( AJ->CANTIDAD * cual )
  PRD->STOCKACT := PRD->STOCKINI + PRD->COMPRAS - PRD->VENTAS + PRD->AJUSTES
  DBUNLOCK()
ENDIF
GO nReg
SELECT AJ

RETURN
