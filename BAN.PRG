#include "INKEY.CH"
#include "SETCURS.CH"
#include "EDI.CH"
#include "TB.CH"
#include "COMMON.CH"

PARAMETERS ym2, xm2, nCual
LOCAL xreg   := RECNO(), OX, aCpo, cBase:=DBF()
LOCAL xmenu  :=MENUDOWN({ "º  <+>  º PgUp   º    F2    º   F5   º ENTER  º ESC  º",;
									"º       º PgDown º          º        º elige  º      º",;
									"º mueve º mueve+ º modifica º agrega º y sale º sale º"})
DEFAULT nCual TO 0
ym2 := IF(ym2==NIL,10,ym2)
xm2 := IF(xm2==NIL,10,xm2)
SELECT BA
if nCual<1.OR.nCual>lastrec()
	go top
ELSE
	go nCual
endif

aCpo := {	                                                                     ;
		{ "STRZERO(RECNO(),3)","C¢d; ",                   '999', 'F', 'F',  3, 0 },;
		{ "NOMBANCO",       "Nombre; ",                      '', 'E',  '',  0, 0 },;
		{ "NUMCTA",         "N£mero;Cuenta",                 '', 'E',  '',  0, 0 },;
		{ "CATIVA",         "Cat;IVA",                       '', 'E',  '',  0, 0 },;
		{ "CUIT",           "CUIT; ",                        '', 'E',  '',  0, 0 } }

aCpo := FARRAYAUX( aCpo )
MARCO( ym2, xm2, ym2+6, xm2+40, "<< CUENTAS >>", "D", .T., 0 )
OX := MYBROWSE(  ym2, xm2, ym2+6, xm2+40, aCpo )
OX:CARGO[TB_REFRESH] := 0
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F5} )
	IF OX:Cargo[TB_MSGE] == "MODIF"
  	FRLOCK()
		FIELD->&(TBNOC(OX)) := OX:CARGO[TB_CONT]
     DBUNLOCK()
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_F5
  	SET DELETED OFF
  	LOCATE FOR EMPTY(FIELD->NOMBANCO)
     IF !FOUND() .OR. LASTREC()==0
     	ADD_REC()
     ENDIF
     FRLOCK()
     RECALL
     DBUNLOCK()
  	SET DELETED ON
		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_ESC
		GO xreg
     EXIT
	ELSEIF OX:Cargo[TB_RET] == K_ENTER
     EXIT
	ENDIF
ENDDO
DBSELECTAREA( cBase )
RECUPAN()
PONEPAN(xmenu)

RETURN IF( OX:Cargo[TB_RET]==K_ENTER, BA->(RECNO()), 0 )
