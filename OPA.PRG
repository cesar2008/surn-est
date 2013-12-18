parameters nCual, EDX

#include "EST.CH"
#include "EDI.CH"
#include "TB.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
#include "COMMON.CH"

LOCAL nReg:=RECNO(), OX, aCpo, cBase:=DBF()
LOCAL AX, cMenu, cMenu2, nAux, nAux2, nAux3
PRIVATE EDX, lModif

aCpo:={;
		{ "OPAGO",          "n§Orden",                       '', 'E',  '',  0, 0 },;
		{ "FECHA",          "Fecha; ",                       '', 'E',  '',  0, 0 },;
 		{ "TIPOORDEN",      "Tipo;Orden",                    '', 'F',  '',  0, 0 },;
 		{ "FECHVENC",       "Venc.",                         '', 'F',  '',  0, 0 },;
 		{ "TIPOCOMPRA",     "T;C",                           '', 'F',  '',  0, 0 }}

select OPA
IF nCual==NIL .OR. nCual==0
 	DBGOTOP()
ELSE
	IF !DBSEEK( nCual )
  	GO nReg
  ENDIF
ENDIF
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
cMenu:=MENUDOWN({"  <+>  º  TAB  º   F2   º   F5   º  F6   º  F7   º  F9  º  ENTER   º ESC  ",;
			  			"       º  ver  º        º        º       º       ºrecal-º confirma º      ",;
						" mueve ºdetalleºmodificaº agrega ºeliminaºimprimeº cula º elecci¢n º sale "})

setcolor(C_MENU)
MARCO( 7, 5, 20, 58, "<< ORDENES DE PAGO >>", "D", .T., 0 )
OX := MYBROWSE( 7, 5, 20, 58, aCpo )
OX:CARGO[TB_REFRESH] := 0
nreg := RECNO()
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F9.or.nK==K_TAB} )
	IF OX:Cargo[TB_MSGE] == "MODIF"

	ELSEIF OX:Cargo[TB_RET] == K_TAB
  	aaux := {}
		select OPA2
		dbseek( str(OPA->OPAGO,10), .T. )
		DO WHILE OPA2->OPAGO==OPA->OPAGO .AND. !OPA2->(EOF())
			aadd(aaux, str(OPA2->CODPROD) +'³'+;
        	FPROD(OPA2->CODPROD) +'³'+;
				str(OPA2->CANTPROVIS) +'³'+;
				str(OPA2->CANTUSADO)  +'³'+;
 				str(OPA2->CANTPROVIS-OPA2->CANTUSADO,6) )
			skip 1 alias OPA2
		ENDDO
     select OP
     if len(aaux)#0
			cMenu2:=MENUDOWN({"     º  ENTER   ",;
					 				"       º  o ESC   ",;
					 				" mueve º confirma "})
			aux := { "C¢d. ³Descripci¢n                   ³Provis³ Usado³ Queda",;
						"ÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄ" }
			ele := PP_SELEC( 10, 20, 0, 0, aaux, 1, {aux,{""}}, "S", .T.)
			RECUPAN()
			MENUDOWN(cMenu2)
     endif
	ELSEIF OX:Cargo[TB_RET] == K_F2 .OR. OX:Cargo[TB_RET] == K_F5
		cMenu2:=MENUDOWN({"     º     TAB   º   F10   º  ESC   ",;
								"       º  Detalle  º graba y º        ",;
								" mueve º Productos º procede º  sale  "})
  	lModif := .F.
     aaux:=OPA2->(dbstruct())
     aadd( aaux, {"REGISTRO","N",5,0})
     CREARBASEAUX( aaux )
		AX := NEWEDIT( "OPAGO",,.T. )
		FEDITOR( AX, "SETVARS", OX:CARGO[TB_RET],.F. )
		nOPAGO := EDCONT(AX,"OP->OPAGO")
		IF OX:Cargo[TB_RET]==K_F5
     	GO BOTTOM
        AX[ED_EDIT] := STUFF(AX[ED_EDIT],1,1,"M")
        EDPONE( AX, "OP->TIPOCOMPRA", EDCONT(EDX,"CO->TIPOCOMPRA") )
     ENDIF
		aCp:={;
 			{ "CODPROD",     "C¢d;Prod",                      '', 'M',  '',  0, 0 },;
 			{ "FPROD(CODPROD)","Producto",     REPLICATE('X',15), 'F', 'F', 15, 0 },;
 			{ "CANTPROVIS",  "Provisi¢n",                     '', 'M',  '',  0, 0 },;
 			{ "CANTUSADO",   "Usado",                         '', 'E',  '',  0, 0 },;
			{ "CANTPROVIS-CANTUSADO",   "Queda",        '######', 'F', 'F',  6, 0 },;
			{ "REGISTRO",    "",                              '',  '',  '',  0, 0 }}
		aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
		select OPA2
		dbseek( str(nOPAGO,10), .T. )
     select X
		DO WHILE OPA2->OPAGO==nOPAGO .AND. !OPA2->(EOF())
     	append blank
			X->CODPROD    := OPA2->CODPROD
			X->CANTPROVIS := OPA2->CANTPROVIS
			X->CANTUSADO  := OPA2->CANTUSADO
*			X->QUEDA      := OPA2->CANTPROVIS-OPA2->CANTUSADO
			X->REGISTRO   := OPA2->(recno())
			skip 1 alias OPA2
		ENDDO
     append blank
     select OP
		AX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( AX, { K_F10 } )
			IF AX[ED_UPDATE]
				AX[ED_MODE] = "MOSTRAR"
           IF EDNOM(AX) == "OP->OPAGO"
					IF FREPEAT( EDCONT(AX), AX[ED_MODAPP] )
						MENSAJE ( 0, 0, 10, .T.,"N§ O.P. REPETIDO !!! ")
						EDPONE( AX,, AX[ED_LAST] )
						AX[ED_TECLA] := 0
					ENDIF
					AX[ED_MODE] := "MOSTRARTODO"
           ENDIF

			ELSEIF AX[ED_TECLA] == K_TAB
           IF EDNOM(AX) == "OP->CANTPROD"
           	select X
					cMenu3:=MENUDOWN({"  <+>  º    F2    º   F5   º  F6    º ESC  ",;
			  								"       º          º        º        º      ",;
											" mueve º modifica º agrega ºelimina º sale "})
					MARCO( 9, 10, 20, 78, "detalle ORD.PROVIS", "S", .T., 0 )
					OX2 := MYBROWSE( 9, 10, 20, 78, aCp )
					OX2:CARGO[TB_REFRESH] := 0
					OX2:GOTOP()
					DO WHILE .T.
						MOVBROW( OX2, {||nK==K_ESC.OR.nK==K_TAB.OR.nK==K_F5.or.nK==K_F6} )
						IF OX2:Cargo[TB_MSGE] == "MODIF" .OR. OX2:Cargo[TB_RET]==K_TAB
							IF TBNOC(OX2) == "CODPROD" 	//.AND. OX2:Cargo[TB_RET]==K_TAB
								IF OX2:Cargo[TB_RET]==K_TAB
									IF FELEGIR( "PRODUCTO", X->CODPROD ) # 0
										X->CODPROD := PRD->CODPROD
                          	lModif := .T.
                          	TBPOS(OX2)
									ENDIF
                       ELSE
                       	IF !EMPTY( FPROD(OX2:CARGO[TB_CONT]) )
                       		lModif := .T.
                    			TBPUT(OX2)
                          ENDIF
                       ENDIF
							ELSE
                    	TBPUT(OX2)
                       lModif := .T.
                       TBPOS(OX2)
                    ENDIF
                    TBPOS(OX2,.T.)
						ELSEIF OX2:Cargo[TB_RET]==K_F5
                 	dbgobottom()
                    if X->CODPROD#0 .or. eof()
                    	append blank
                       TBPOS(OX2,.T.)
                    endif
						ELSEIF OX2:Cargo[TB_RET]==K_F6
							if PREGUNTA( 0, "¨ est s Seguro ? [ S / N ]", "SsNn" ) $ "Ss"
                 		BLANKREG(.F.,{"REGISTRO"})
                    	TBPOS(OX2,.T.)
                    endif
						ELSEIF OX2:Cargo[TB_RET]==K_F10 .OR. OX2:Cargo[TB_RET]==K_ESC
							EXIT
						ENDIF
					ENDDO
              count to nCant for CODPROD#0
              EDPONE(AX,"OP->CANTPROD",nCant)
              select OP
              RECUPAN()
					MENUDOWN(cMenu3)
           ELSEIF EDNOM(AX) == "OP->TIPOCOMPRA"
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
					IF FEDITOR( aX, "HUBOCAMBIOS" ) .or. lModif
						aux := UPPER( PREGUNTA( 0, "¨ [G] guarda.   [S] sale.   [C] contin£a.", "GgSsCc" ) )
					ENDIF
           ELSE
           	aux :="G"
           ENDIF
           IF aux == "G"
					MENSAJE( 0, 0, 0, .F., "GRABANDO..." )
					IF "AGREG"$AX[ED_MODAPP]
              	F_ALTA({|| OP->OPAGO#0} )
           	ENDIF
           	AX[ED_REGISTRO]:=RECNO()
					FEDITOR(AX,"GRABAR",.F.)
              select X;  dbgotop()
              select OPA2
              nCant:=0
					do while !X->(eof())
              	if X->CODPROD==0
              		if X->REGISTRO#0
                    	go X->REGISTRO
                 		BLANKREG()
                 	endif
                 else
              		if X->REGISTRO#0
                    	go X->REGISTRO
                    else
              			F_ALTA({|| OPA2->OPAGO#0} )
                    endif
     					frlock()
                 	OPA2->OPAGO    := OP->OPAGO
							OPA2->CODPROD    := X->CODPROD
							OPA2->CANTPROVIS := X->CANTPROVIS
							OPA2->CANTUSADO  := X->CANTUSADO
                 	dbunlock()
                 	++nCant
                 endif
						skip 1 alias X
					ENDDO
              select OP
              RECUPAN()
              EXIT
           ELSEIF aux == "S"
           	exit
				ENDIF
			ENDIF
		ENDDO
		FEDITOR(AX,"SACAPAN")
		MENUDOWN(cMenu2)
 		TBPOS(OX,.T.)
	ELSEIF OX:Cargo[TB_RET] == K_F7
  	LISTAR("OPAGO")
	ELSEIF OX:Cargo[TB_RET] == K_F9 .and. OP->OPAGO#0
		MENSAJE( 99, 99, 0, .F., "RECALCULANDO..." )
     nAux := RECNO()
     select OPA2
     dbseek(str(OP->OPAGO),.T.)
     fflock()
     do while OPA2->OPAGO==OP->OPAGO .and. !OPA2->(eof())
     	OPA2->CANTUSADO := 0
        skip 1 alias OPA2
     enddo
     dbunlock()
     select CO
     locate for ROSCA().and.CO->OPAGO==OP->OPAGO
     do while ROSCA().and.!CO->(eof())
     	if CO->OPAGO==OP->OPAGO
     		select CO2
     		dbseek( str(CO->CODPROV)+CO->NUMFAC )
           select OPA2
 				do while CO2->CODPROV==CO->CODPROV .and. CO2->NUMFAC==CO->NUMFAC .AND. !CO2->(EOF())
           	if dbseek( str(CO->OPAGO)+str(CO2->CODPROD) )
          			frlock()
              	OPA2->CANTUSADO += CO2->CANTIDAD
                 dbunlock()
              endif
           	skip 1 alias CO2
				enddo
        endif
        skip 1 alias CO
     enddo
     select OP
     go nAux
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
MENUDOWN(cMenu)
DBSELECTAREA(cBase)

RETURN ( OX:Cargo[TB_RET]==K_ENTER )

*******************

FUNC CREARBASEAUX( aStru )

*******************
local cBase:=dbf(), cBaseAux:=XNAME('XAUX')

select 99;  dbclosearea()
dbcreate( cBaseAux, aStru )

select 99
use (cBaseAux) alias X exclusive

*select (cBase)

return cBaseAux
