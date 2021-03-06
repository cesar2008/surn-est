#include "MIN.CH"
#include "INKEY.CH"
#include "SETCURS.CH"
#include "EDI.CH"
#include "TB.CH"

LOCAL xcolor :=SETCOLOR("+W/N,N/W")
LOCAL xbase  := DBF()
LOCAL xreg   := RECNO()
LOCAL xmenu  :=MENUDOWN({ "�  <+>  � PgUp   �  F2   �  F3   �   F4   �   F5   � ENTER  � ESC  �",;
									"�       � PgDown �       �       �        �        � elige  �      �",;
									"� mueve � mueve+ � modif.� busca � busca+ � agrega � y sale � sale �"})
LOCAL aCpo:={	                                                                      ;
	{ "STR(RECNO(),3)", "C�d;Rub",                 '', 'F', 'F',  3, 0 },;
	{ "DESCRUB",        "Descripci�n; ",           '', 'F',  '',  0, 0 },;
	{ "PORC",           " % ; ",                   '', 'M',  '',  0, 0 } }
LOCAL OX, aX, xmenu2

SELECT RU
aCpo := FARRAYAUX( aCpo )

MARCO( 10, 20, 20, 78, "<< RUBROS >>", "D", .T., 0 )
OX := MYBROWSE( 10, 20, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 5
OX:GOTOP()

DO WHILE .T.
	
	MOVBROW( OX, {||nK==K_ESC} )
	
	IF OX:Cargo[TB_MSGE] == "MODIF"
  	FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		TBPOS(OX)
		
	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
		
	ENDIF
ENDDO
DBSELECTAREA( xbase )
SETCOLOR( xcolor )
RECUPAN()
PONEPAN(xmenu)

RETURN .T.
