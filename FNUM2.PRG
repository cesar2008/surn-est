#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
xaux := 0
aaux := {}
areg := {}
DBSELECTAREA(XF2)
DBSEEK( (XF)->NUMFAC )
DO WHILE (XF2)->NUMFAC == (XF)->NUMFAC
	AADD( aaux, STR((XF2)->NUMFAC) +'³'+ (XF2)->DESCPROD +'³'+ STR((XF2)->IMPORTE) )
  AADD( areg, RECNO() )
  xaux += (XF2)->IMPORTE
  SKIP
ENDDO
RECUPAN()
IF LEN(aaux) == 0
	DBSELECTAREA(XF)
	RETURN NIL
ENDIF

xmenu:=MENUDOWN({"     º ESPACIO  º     F5     º     F6     º  F9    º   ENTER    º ESC  ",;
                 "       º marca y  º   marca    º  desmarca  º recal- º pone suma  º      ",;
                 " mueve º desmarca ºhacia abajo ºhacia abajo º  cula  º en Cta.Cte º sale "})
lastcolor = SETCOLOR("+W/N,N/W")
aach := NEWACHO(aaux,,{7,20,0,0} )
aach[ACH_CONDEXIT] := {||k==K_F5.OR.k==K_F6.OR.k==43.OR.k==K_ENTER.OR.K==45}
MARCO( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], " FACTURAS ", "S", .T. )
DO WHILE .T.
   @ aach[ACH_Y2]+1, aach[ACH_X2]-10 SAY xaux PICT "#######.##"
   e := ACHOICE( aach[ACH_Y1], aach[ACH_X1], aach[ACH_Y2], aach[ACH_X2], aaux, .T., "funcacho", aach[ACH_ELE], aach[ACH_REL] )
   IF aach[ACH_TECLA] == 43		// +
      FOR i=1 TO LEN(aaux)
         aux := VAL(aaux[i]) + 1
         aaux[i] := STR(aux,8) + SUBSTR(aaux[i],9)
      NEXT
   ELSEIF aach[ACH_TECLA] == 45		// -
      FOR i=1 TO LEN(aaux)
         aux := VAL(aaux[i]) - 1
         aaux[i] := STR(aux,8) + SUBSTR(aaux[i],9)
      NEXT
   ELSEIF aach[ACH_TECLA] == K_ESC .OR. aach[ACH_TECLA]==K_ENTER
      EXIT
   ENDIF
ENDDO
RECUPAN()
IF aach[ACH_TECLA] == K_ENTER
  MENSAJE( 0, 0, 0, .F., "AGUARDE . . ." )
  DBSELECTAREA(XF2)
  FFLOCK()
  FOR i=1 TO LEN(aaux)
  	GO areg[i]
  	(XF2)->NUMFAC := VAL(aaux[i])
	NEXT
	RECUPAN()
ENDIF
PONEPAN(xmenu)
SETCOLOR(lastcolor)
DBSELECTAREA(XF)

RETURN NIL
