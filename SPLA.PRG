#include "EST.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "BL.CH"

#define ym1  4

LOCAL cBase:=DBF(), nOrder:=INDEXORD(), nReg:=RECNO(), XF, XF2, ATOT

FBASES({"+"+cDiscoCentral+UT_SISTEMA+"\EST\GRUPO","+PLAN2"})
IF QUEFECHA2( 10,30 )
RG_CODPROD    := 1
RG_CANTIDAD   := 2
RG_DESCPROD   := 3
RG_PRECBASE   := 4
RG_PRECUNIT   := 5
RG_IMPORTE    := 6
RG_PORCDESC   := 7
RG_DESCUENTO  := 8
RG_NETO_VENTA := 9
RG_IMPINT     := 10
RG_IVA1       := 11
RG_IVA2       := 12
RG_TPRECBASE  := 13
RG_TDESCUENTO := 14
RG_TNETO_VENTA:= 15
RG_TIMPINT    := 16
RG_TIVA1      := 17
RG_TIVA2      := 18
RG_RUBRO      := 19
RG_TIPOIMPINT := 20
RG_NEGOCIO    := 21
RG_REGISTRO   := 22

bRegVacio := {|a,i|                     ;
	a[i,RG_CODPROD    ] := 0             ,;
	a[i,RG_DESCPROD   ] := SPACE(20)     ,;
	a[i,RG_CANTIDAD   ] := 0             ,;
	a[i,RG_RUBRO      ] := 0             ,;
	a[i,RG_PRECBASE   ] := 0             ,;
	a[i,RG_PORCDESC   ] := 0             ,;
	a[i,RG_DESCUENTO  ] := 0             ,;
	a[i,RG_NETO_VENTA ] := 0             ,;
	a[i,RG_TIPOIMPINT ] := 0             ,;
	a[i,RG_IMPINT     ] := 0             ,;
	a[i,RG_IVA1       ] := 0             ,;
	a[i,RG_IVA2       ] := 0             ,;
	a[i,RG_TPRECBASE  ] := 0             ,;
	a[i,RG_TDESCUENTO ] := 0             ,;
	a[i,RG_TNETO_VENTA] := 0             ,;
  a[i,RG_TIMPINT    ] := 0             ,;
  a[i,RG_TIVA1      ] := 0             ,;
	a[i,RG_TIVA2      ] := 0             ,;
	a[i,RG_PRECUNIT   ] := 0             ,;
  a[i,RG_IMPORTE    ] := 0             ,;
  a[i,RG_NEGOCIO    ] := " "           ,;
  a[i,RG_REGISTRO   ] := 0             }
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

	ATOT := NEWEDIT2( "SPLA",,.F. )
	MENSAJE( 99, 99, 0, .F., " AGUARDE  . . . " )

 	SELECT GR
 	i:= 0
 	DBEVAL( {|| ++i ,;
 		AXR[i,RG_CODPROD ]:=RECNO() 							,;
 		AXR[i,RG_DESCPROD]:=GR->DESCGRUP 				  },;
 		{|| !DELETED() } )

	FVERREG( ATOT,, .T. )
	***************************  PLANILLAS   ************************
  aux := 0
	SELECT PL2
	SET ORDER TO FORDER({"FECHA"})
	DBSEEK(FTOC(DESDE),.T.)
	DO WHILE PL2->FECHA>=DESDE .AND. PL2->FECHA<=HASTA .AND. !PL2->(EOF())
		FPRODUCTO(PL2->CODPROD)
		i := ASCAN( AXR, {|a| a[RG_CODPROD]==NGRUPO} )
		IF i == 0
			i := ASCAN( AXR, {|a| a[RG_CODPROD]==0} )
			AXR[i,RG_DESCPROD] := JUSTIF("OTROS",LEN(AXR[i,RG_DESCPROD]),"<")
		ENDIF
		AXR[ i,RG_CANTIDAD   ] += FIELD->CANTIDAD
		AXR[ i,RG_PRECBASE   ] := FIELD->PRECBASE
		AXR[ i,RG_IMPINT     ] := FIELD->IMPINT
		AXR[ i,RG_IVA1       ] := FIELD->IVA
		AXR[ i,RG_PRECUNIT   ] := FIELD->PRECUNIT
		AXR[ i,RG_TPRECBASE  ] += FIELD->PRECBASE * FIELD->CANTIDAD
		AXR[ i,RG_TIMPINT    ] += FIELD->IMPINT * FIELD->CANTIDAD
		AXR[ i,RG_TIVA1      ] += FIELD->IVA * FIELD->CANTIDAD
		AXR[ i,RG_IMPORTE    ] += FIELD->IMPORTE
     M->TOTAL += FIELD->IMPORTE
    	++aCant[1]
  	aFecha[1] := MAX(aFecha[1],PL2->FECHA)
  	IF ++aux % 10 == 0
			FVERREG( ATOT,, .T. )
        aux := 0
		ENDIF
		SKIP 1 ALIAS PL2
  ENDDO
	FVERREG( ATOT,, .T. )
	RECUPAN()
  K:=INKEY(0)
* IF K == K_F7
  	ERASE LTRS_PLA.TXT
  	SET CONSOLE OFF
  	SET ALTERNATE TO LTRS_PLA.TXT
  	SET ALTERNATE ON
     ? "***   VENTA REAL   ***"
		? "C¢d. Descripci¢n             Litros       Importe"
		? "==== ==================== ========= ============="
     FOR i=1 TO LEN(AXR)
			? STR(AXR[i,RG_CODPROD],4)
			?? " "+AXR[i,RG_DESCPROD]
			?? STR(AXR[i,RG_CANTIDAD],10,3)
			?? STR(AXR[i,RG_IMPORTE],14,2)
     NEXT
  	SET ALTERNATE TO
  	SET CONSOLE ON
		IF PREGUNTA( 12, " ¨ lo paso al A: ?   [ S / N ]", "SsNn") $ "Ss"
     	COPY FILE LTRS_PLA.TXT TO A:LTRS_PLA.TXT
     ENDIF
* ENDIF
	FEDITOR(ATOT,"SACAPAN")
ENDIF
DBSELECTAREA(cBase)
SET ORDER TO nOrder
GO nReg

RETURN
