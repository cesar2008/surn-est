#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

PARAMETERS AXR
LOCAL cPantAux := GUARDOPAN(0,0,24,79), cColor:=SETCOLOR(), aCpo, xAux


aCpo:={	                                                                      ;
	{ "CODPROD",    "C¢digo;Prod.",                       '', 'M',  '',  0, 0 },;
	{ "CANTIDAD",   "Cant.; ",                            '', 'M',  '',  0, 0 },;
	{ "DESCPROD",   "Descripci¢n; ",                      '', 'E',  '',  0, 0 },;
	{ "PRECBASE",   "Neto; ",                             '', 'M', 'N', 10, 4 },;
	{ "PRECUNIT",   "Precio;Unitario",                    '', 'E',  '',  0, 0 },;
	{ "IMPORTE",    "Importe; ",                          '', 'M',  '',  0, 0 },;
	{ "PORCDESC",   "%;Dcto",                             '', 'M',  '',  0, 0 },;
	{ "DESCUENTO",  "Dcto; ",                             '', 'E', 'N', 10, 3 },;
	{ "IMPINT",     "Imp.;Int.",                          '', 'E', 'N', 10, 5 },;
	{ "IVA1",       "IVA;Prod",                           '', 'E', 'N', 10, 5 },;
	{ "IVA2",       "IVA NI;Prod",                        '', 'E', 'N', 10, 5 },;
	{ "TPRECBASE",  "Neto;total",                         '', 'E',  '',  0, 0 },;
	{ "TDESCUENTO", "Total;Dcto",                         '', 'F',  '',  0, 0 },;
	{ "TIMPINT",    "Total;Imp.Int",                      '', 'F',  '',  0, 0 },;
	{ "TIVA1",      "I.V.A.;"+STR(VA->PIVA1)+"%",          '', 'E',  '',  0, 0 },;
	{ "TIVA2",      "IVA NI;"+STR(VA->PIVA2)+"%",          '', 'E',  '',  0, 0 } }

SELECT (XF2)
aCpo := FARRAYAUX( aCpo )
SELECT (XF)

SETCOLOR( "W/N,N/W" )
MARCO( 8, 1, 18, 78, "", "S", .F., 0 )
OX := MYABROWSE( 8, 1, 18, 78, aCpo, AXR, "AXR" )
OX:CARGO[TB_REFRESH] := 0
OX:GOTOP()
OX:CARGO[TB_EDIT] := UPPER( OX:CARGO[TB_EDIT] )
	
MENUDOWN({"  <+>  º    F2    º    F3    º  %   º    TAB   º   F8   º   F10   º ESC  ",;
			  "       º          º  busca   º      º  elegir  º cambia º graba y º      ",;
			  " mueve º modifica º producto º desc º producto º n§Fact º  sale   º sale "})
	
DO WHILE .T.
		
	MOVABROW( OX, AXR, {||nK==9.OR.nK==37.OR.nK==27.OR.nK==K_F7.OR.nK==-2.OR.nK==-9.OR.nk==-5.OR.nK==K_F8},;
		{||nK==999} )
		
	IF ( OX:Cargo[TB_MSGE] == "MODIF" .OR. OX:Cargo[TB_RET] == K_TAB )
		xLastVal := AXR[NROW,OX:ColPos]
		IF OX:CARGO[TB_MSGE] == "MODIF"
			AXR[NROW,OX:ColPos] := OX:CARGO[TB_CONT]
     ENDIF
		IF TBNOC(OX) $ "CODPROD"
			IF OX:CARGO[TB_MSGE] == "MODIF"
				IF TBNOC(OX) == "DESCPROD"
					AXR[NROW,RG_CODPROD] := VAL(AXR[NROW,RG_DESCPROD])
           ELSE
					AXR[NROW,RG_DESCPROD] := STR(AXR[NROW,RG_CODPROD],6)
           ENDIF
			ENDIF
			IF OX:Cargo[TB_RET] == K_TAB
				IF FELEGIR( "PRODUCTO", AXR[NROW,RG_CODPROD] ) # 0
     			AXR[NROW,RG_CODPROD] := PRD->CODPROD
     			AXR[NROW,RG_NEGOCIO] := " "
              KEYBOARD CHR(K_ENTER)
				ENDIF
        ELSEIF VAL(AXR[NROW,RG_DESCPROD]) # 0
				IF !EMPTY( FPRODUCTO(VAL(AXR[NROW,RG_DESCPROD])) )
     			AXR[NROW,RG_CODPROD] := VAL(AXR[NROW,RG_DESCPROD])
     			AXR[NROW,RG_NEGOCIO] := " "
              KEYBOARD CHR(K_ENTER)
           ENDIF
        ELSEIF !EMPTY( AXR[NROW,RG_DESCPROD] )
				r := SELECTPRD( AXR[NROW,RG_DESCPROD] )
				IF r # 0
     			AXR[NROW,RG_CODPROD] := r
     			AXR[NROW,RG_NEGOCIO] := " "
              KEYBOARD CHR(K_ENTER)
				ENDIF
        ELSEIF EMPTY( AXR[NROW,RG_DESCPROD] )
        	AXR[NROW,RG_CODPROD] := 0
        ENDIF
        IF nB == 3
        	FOR i=1 TO 3
           	IF CL->&("CODPROD"+STR(i,1)) == AXR[NROW,RG_CODPROD]
              	AXR[NROW,RG_PORCDESC] := CL->&("PORCDESC"+STR(i,1))
              ENDIF
        	NEXT
        ELSE
        	IF nCODCLI > 0
        		FOR i=1 TO 3
           		IF CLA->&("CODPROD"+STR(i,1)) == AXR[NROW,RG_CODPROD]
              		AXR[NROW,RG_PORCDESC] := CLA->&("PORCDESC"+STR(i,1))
              	ENDIF
        		NEXT
           ENDIF
        ENDIF
			AXR[ NROW, RG_DESCPROD   ] := LEFT(FPRODUCTO(AXR[NROW,RG_CODPROD],AXR[NROW,RG_NEGOCIO]),20)
			AXR[ NROW, RG_RUBRO      ] := NRUBRO
			AXR[ NROW, RG_PRECBASE   ] := FPRECBASE
			AXR[ NROW, RG_TIPOIMPINT ] := FTIPOIMPINT
			AXR[ NROW, RG_IMPINT     ] := FIMPINT
			AXR[ NROW, RG_IVA1       ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 / 100
			AXR[ NROW, RG_IVA2       ] := AXR[NROW,RG_PRECBASE] * M->PIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[NROW,RG_RUBRO]==1.AND.AXR[NROW,RG_NEGOCIO]==" ",0,1)
 			AXR[ NROW, RG_PRECUNIT   ] := FPRECVENTA
		ELSEIF TBNOC(OX) $ "IMPORTE"
			AXR[NROW,RG_CANTIDAD] := AXR[NROW,RG_IMPORTE] / AXR[NROW,RG_PRECUNIT]
     ENDIF
		IF TBNOC(OX) $ "PRECBASE IMPINT IMPORTE"
			IF .NOT. TBNOC(OX) $ "IMPINT"
				IF AXR[NROW,RG_TIPOIMPINT] == "%"
     			FGRUPO(NGRUPO)
					AXR[ NROW, RG_IMPINT  ] := AXR[NROW,RG_PRECBASE] * FIMPINT / 100
				ENDIF
        ENDIF
			AXR[ NROW, RG_IVA1       ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 / 100
			AXR[ NROW, RG_IVA2       ] := AXR[NROW,RG_PRECBASE] * M->PIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[NROW,RG_RUBRO]==1.AND.AXR[NROW,RG_NEGOCIO]==" ",0,1)
 			AXR[ NROW, RG_PRECUNIT   ] := AXR[NROW,RG_PRECBASE] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA1] + AXR[NROW,RG_IVA2]
 			AXR[ NROW, RG_DESCUENTO  ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_PORCDESC] / 100
 			AXR[ NROW, RG_PRECUNIT   ] := AXR[NROW,RG_PRECUNIT] - AXR[NROW,RG_DESCUENTO]
		ELSE
			IF TBNOC(OX) $ "PORCDESC"
*				AXR[ NROW, RG_DESCUENTO  ] := AXR[NROW,RG_PRECUNIT] * xLastVal / 100
 				AXR[ NROW, RG_PRECUNIT   ] := AXR[NROW,RG_PRECUNIT] + AXR[NROW,RG_DESCUENTO]
        ENDIF
 			AXR[ NROW, RG_DESCUENTO  ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_PORCDESC] / 100
 			AXR[ NROW, RG_PRECUNIT   ] := AXR[NROW,RG_PRECUNIT] - AXR[NROW,RG_DESCUENTO]
			IF AXR[NROW,RG_TIPOIMPINT] == "%"
     		FGRUPO(NGRUPO)
				AXR[ NROW, RG_PRECBASE   ] := AXR[NROW,RG_PRECUNIT] / (1+(FIMPINT+M->PIVA1)/100)
				AXR[ NROW, RG_IMPINT     ] := AXR[NROW,RG_PRECBASE] * FIMPINT / 100
     	ELSE
				AXR[ NROW, RG_PRECUNIT   ] -= AXR[NROW,RG_IMPINT]
				AXR[ NROW, RG_PRECBASE   ] := AXR[NROW,RG_PRECUNIT] / (1+(M->PIVA1)/100)
			ENDIF
			AXR[ NROW, RG_IVA1       ] := AXR[NROW,RG_PRECBASE] * M->PIVA1 / 100
			AXR[ NROW, RG_IVA2       ] := AXR[NROW,RG_PRECBASE] * M->PIVA2 / 100 * IF(cCATIVA=="RNI".AND.AXR[NROW,RG_RUBRO]==1.AND.AXR[NROW,RG_NEGOCIO]==" ",0,1)
 			AXR[ NROW, RG_PRECUNIT   ] := AXR[NROW,RG_PRECBASE] + AXR[NROW,RG_IMPINT] + AXR[NROW,RG_IVA1] + AXR[NROW,RG_IVA2]
     ENDIF
		IF .NOT. TBNOC(OX) $ "DESCPROD"
			AXR[ NROW, RG_TPRECBASE  ] := AXR[NROW,RG_PRECBASE] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TIMPINT    ] := AXR[NROW,RG_IMPINT] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TIVA1      ] := AXR[NROW,RG_IVA1] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TIVA2      ] := AXR[NROW,RG_IVA2] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_TDESCUENTO ] := AXR[NROW,RG_DESCUENTO] * AXR[NROW,RG_CANTIDAD]
			AXR[ NROW, RG_IMPORTE    ] := AXR[NROW,RG_PRECUNIT] * AXR[NROW,RG_CANTIDAD]
			FXTOTAL()
			EVAL( bTot )
     ENDIF
		OX:RefreshCurrent()

	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
	ELSEIF OX:Cargo[TB_RET] == K_F10
		EXIT

	ENDIF

ENDDO
PONEPAN(cPantAux)
SETCOLOR(cColor)

RETURN .T.
