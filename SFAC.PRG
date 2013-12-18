#include "EST.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"

#define ym1  4

LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), XF, XF2, ATOT

*FBASES({"+"+cDiscoCentral+UT_SISTEMA+"\EST\GRUPO"})
IF QUEFECHA2( 10,30 )
	AXR := {}
	STORE 0 TO M->TDESCUENTO, M->TNETO_VENTA, M->TIVA1, M->TIVA2, M->TOTAL,;
		M->TPRECBASE, M->TIMPINT, M->PORCDESC
	FOR i=1 TO 12
  	AADD( AXR, ARRAY(RG_REGISTRO) )
		EVAL( bRegVacio, @AXR, i )
	NEXT
	M->PIVA1      := VA->PIVA1
	M->PIVA2      := 0
  aCant    := {0,0}
  aFecha   := {ctod(''),ctod('')}
  aanulada := {0,0}

	ATOT := NEWEDIT2( "SFAC",,.F. )
	MENSAJE( 99, 99, 0, .F., " AGUARDE  . . . " )

 	SELECT GR
 	i:= 0
 	DBEVAL( {|| ++i ,;
 		AXR[i,RG_CODPROD ]:=RECNO() 							,;
 		AXR[i,RG_DESCPROD]:=GR->DESCGRUP 				  },;
 		{|| !DELETED() } )

	FVERREG( ATOT,, .T. )
	***************************  FACTURAS  ************************
  XF := "FA"
  aux := 0
  FOR z=1 TO 2
  	XF2 := XF + "2"
		DBSELECTAREA(XF)
		SET ORDER TO FORDER({"FECHA"})
		DBSEEK(FTOC(DESDE),.T.)
  	SELECT (XF2)
		DO WHILE (XF)->FECHA>=DESDE .AND. (XF)->FECHA<=HASTA .AND. !(XF)->(EOF())
     	IF (XF)->CODCLI == -2
        	++aanulada[z]
        ELSE
  			SEEK (XF)->NUMFAC
     		DO WHILE (XF2)->NUMFAC == (XF)->NUMFAC
					FPRODUCTO((XF2)->CODPROD)
					i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO} )
					IF i == 0
						i := ASCAN( AXR, {|a| a[RG_CODPROD]==0} )
						AXR[i,RG_DESCPROD] := JUSTIF("OTROS",LEN(AXR[i,RG_DESCPROD]),"<")
					ENDIF

					AXR[ i,RG_CANTIDAD   ] += FIELD->CANTIDAD
					AXR[ i,RG_PRECBASE   ] := FIELD->TPRECBASE / FIELD->CANTIDAD
					AXR[ i,RG_TIPOIMPINT ] := FTIPOIMPINT
					AXR[ i,RG_IMPINT     ] := FIELD->TIMPINT / FIELD->CANTIDAD
					AXR[ i,RG_IVA1       ] := FIELD->TIVA1 / FIELD->CANTIDAD
					AXR[ i,RG_PRECUNIT   ] := FIELD->PRECUNIT
					AXR[ i,RG_TPRECBASE  ] += FIELD->TPRECBASE
					AXR[ i,RG_TIMPINT    ] += FIELD->TIMPINT
					AXR[ i,RG_TIVA1      ] += FIELD->TIVA1
					AXR[ i,RG_IMPORTE    ] += FIELD->IMPORTE
           	M->TOTAL += FIELD->IMPORTE
              ++aCant[z]
        		SKIP
				ENDDO
        ENDIF
        aFecha[z] := MAX(aFecha[z],(XF)->FECHA)
        IF ++aux % 10 == 0
				FVERREG( ATOT,, .T. )
           aux := 0
        ENDIF

			SKIP 1 ALIAS (XF)

		ENDDO
		SET ORDER TO FORDER({"NUMFAC"})
     XF := "FB"
  NEXT
	FVERREG( ATOT,, .T. )
	RECUPAN()
  K:=INKEY(0)
	FEDITOR(ATOT,"SACAPAN")
ENDIF
DBSELECTAREA(cBase)
SET ORDER TO nOrder
GO nReg

RETURN
