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
		{ "OPROVIS",        "n§Orden",                       '', 'E',  '',  0, 0 },;
		{ "FECHA",          "Fecha; ",                       '', 'E',  '',  0, 0 },;
 		{ "TIPOORDEN",      "Tipo;Orden",                    '', 'F',  '',  0, 0 },;
 		{ "FECHVENC",       "Venc.",                         '', 'F',  '',  0, 0 },;
 		{ "FECHBAJA",       "Fecha;Baja",                    '', 'F',  '',  0, 0 },;
 		{ "TIPOCOMPRA",     "T;C",                           '', 'F',  '',  0, 0 },;
 		{ "OBSERV",         "Observaciones",                 '', 'F',  '',  0, 0 }}

select OP
IF nCual==NIL .OR. nCual==0
 	DBGOTOP()
ELSE
	IF !DBSEEK( nCual )
  	GO nReg
  ENDIF
ENDIF
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
cMenu:=MENUDOWN({" <+> º  TAB  º   F2   º   F5   º  F6   º  F7   º  F8  º  F9  º  ENTER   º ESC ",;
			  			"     º  ver  º        º        º       º       ºcierraºrecal-º confirma º     ",;
						"mueveºdetalleºmodificaº agrega ºeliminaºimprimeºO.Pag.º cula º elecci¢n º sale"})

setcolor(C_MENU)
MARCO( 7, 5, 20, 78, "<< ORDENES PROVISION >>", "D", .T., 0 )
OX := MYBROWSE( 7, 5, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 0
nreg := RECNO()
DO WHILE .T.
	MOVBROW( OX, {||nK==K_ESC.OR.nK==K_ENTER.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_F9.or.nK==K_TAB.or.nK==K_F7.or.nK==K_F8} )
	IF OX:Cargo[TB_MSGE] == "MODIF"

	ELSEIF OX:Cargo[TB_RET] == K_TAB
  	aaux := {}
		select OP2
		dbseek( str(OP->OPROVIS,10), .T. )
		DO WHILE OP2->OPROVIS==OP->OPROVIS .AND. !OP2->(EOF())
			aadd(aaux, str(OP2->CODPROD) +'³'+;
        	FPROD(OP2->CODPROD) +'³'+;
				str(OP2->CANTPROVIS) +'³'+;
				str(OP2->CANTUSADO) +'³'+;
 				str(OP2->CANTPROVIS-OP2->CANTUSADO,6) +'³'+;
           str(OP2->PORCDESC) +'³'+;
           str(OP2->PLAZO) )
			skip 1 alias OP2
		ENDDO
     select OP
     if len(aaux)#0
			cMenu2:=MENUDOWN({"     º  ENTER   ",;
					 				"       º  o ESC   ",;
					 				" mueve º confirma "})
			aux := { "C¢d. ³Descripci¢n                   ³Provis³ Usado³ Queda³% Dcto³Plaz",;
						"ÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄ" }
			ele := PP_SELEC( 10, 10, 0, 0, aaux, 1, {aux,{""}}, "S", .T.)
			RECUPAN()
			MENUDOWN(cMenu2)
     endif
	ELSEIF OX:Cargo[TB_RET] == K_F2 .OR. OX:Cargo[TB_RET] == K_F5
		cMenu2:=MENUDOWN({"     º     TAB   º   F10   º  ESC   ",;
								"       º  Detalle  º graba y º        ",;
								" mueve º Productos º procede º  sale  "})
  	lModif := .F.
     aaux:=OP2->(dbstruct())
     aadd( aaux, {"REGISTRO","N",5,0})
     CREARBASEAUX( aaux )
		AX := NEWEDIT( "OPROVIS",,.T. )
		FEDITOR( AX, "SETVARS", OX:CARGO[TB_RET],.F. )
		nOPROVIS := EDCONT(AX,"OP->OPROVIS")
		IF OX:Cargo[TB_RET]==K_F5
     	GO BOTTOM
        AX[ED_EDIT] := STUFF(AX[ED_EDIT],1,1,"M")
        IF PROCNAME(1)=="COM"
        	EDPONE( AX, "OP->TIPOCOMPRA", EDCONT(EDX,"CO->TIPOCOMPRA") )
        ENDIF
     ENDIF
		aCp:={;
 			{ "CODPROD",       "C¢d;Prod",                    '', 'M',  '',  0, 0 },;
 			{ "FPROD(CODPROD)","Producto",     REPLICATE('X',15), 'F', 'F', 15, 0 },;
 			{ "CANTPROVIS",    "Provisi¢n",                   '', 'M',  '',  0, 0 },;
 			{ "CANTUSADO",     "Usado",                       '', 'E',  '',  0, 0 },;
			{ "CANTPROVIS-CANTUSADO",   "Queda",        '######', 'F', 'F',  6, 0 },;
 			{ "PORCDESC",      "% Dcto",                      '', 'M',  '',  0, 0 },;
 			{ "PLAZO",         "Plazo",                       '', 'M',  '',  0, 0 },;
			{ "REGISTRO",    "",                              '',  '',  '',  0, 0 }}
		aCp := FBASEAUX( aCp, DBF(), SELECT(), .F. )
		select OP2
		dbseek( str(nOPROVIS,10), .T. )
     select X
		DO WHILE OP2->OPROVIS==nOPROVIS .AND. !OP2->(EOF())
     	append blank
			X->CODPROD    := OP2->CODPROD
			X->CANTPROVIS := OP2->CANTPROVIS
			X->CANTUSADO  := OP2->CANTUSADO
        X->PORCDESC   := OP2->PORCDESC
        X->PLAZO      := OP2->PLAZO
*			X->QUEDA      := OP2->CANTPROVIS-OP2->CANTUSADO
			X->REGISTRO   := OP2->(recno())
			skip 1 alias OP2
		ENDDO
     append blank
     select OP
		AX[ED_MODE] = "MOSTRARTODO"
		DO WHILE .T.
			FEDITAR( AX, { K_F10 } )
			IF AX[ED_UPDATE]
				AX[ED_MODE] = "MOSTRAR"
           IF EDNOM(AX) == "OP->OPROVIS"
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
              	F_ALTA({|| OP->OPROVIS#0} )
           	ENDIF
           	AX[ED_REGISTRO]:=RECNO()
					FEDITOR(AX,"GRABAR",.F.)
              select X;  dbgotop()
              select OP2
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
              			F_ALTA({|| OP2->OPROVIS#0} )
                    endif
     					frlock()
                 	OP2->OPROVIS    := OP->OPROVIS
							OP2->CODPROD    := X->CODPROD
							OP2->CANTPROVIS := X->CANTPROVIS
							OP2->CANTUSADO  := X->CANTUSADO
                    OP2->PORCDESC   := X->PORCDESC
        				OP2->PLAZO      := X->PLAZO
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
	ELSEIF OX:Cargo[TB_RET] == K_F8
		MENSAJE( 10, 10, 0, .F.,"REVISANDO...")
  	nReg:=recno()
     locate for empty(OP->FECHBAJA)
     FFLOCK()
     do while !OP->(eof())
        if !empty(OP->FECHVENC) .and. date()>OP->FECHVENC
            OP->FECHBAJA:=OP->FECHVENC
        endif
     	skip 1
     enddo
     DBUNLOCK()
     go nReg
     RECUPAN()
     TBPOS(OX,.T.)

	ELSEIF OX:Cargo[TB_RET] == K_F7
		op = MENUFLASH( 10, 30, 1, .t., "",  "ORDENES DE PROVISION","PROVISION X PRODUCTO" )
     if op==1
  		LISTAR("OPROVIS")
     elseif op==2
  		LISTAR("OPRXPRD")
     endif

	ELSEIF OX:Cargo[TB_RET] == K_F9 .and. OP->OPROVIS#0
		MENSAJE( 99, 99, 0, .F., "RECALCULANDO..." )
     nAux := RECNO()
     select OP2
     dbseek(str(OP->OPROVIS),.T.)
     fflock()
     do while OP2->OPROVIS==OP->OPROVIS .and. !OP2->(eof())
     	OP2->CANTUSADO := 0
        skip 1 alias OP2
     enddo
     dbunlock()
     select CO
     locate for ROSCA().and.CO->OPROVIS==OP->OPROVIS
     do while ROSCA().and.!CO->(eof())
     	if CO->OPROVIS==OP->OPROVIS
     		select CO2
     		dbseek( str(CO->CODPROV)+CO->NUMFAC )
           select OP2
 				do while CO2->CODPROV==CO->CODPROV .and. CO2->NUMFAC==CO->NUMFAC .AND. !CO2->(EOF())
           	if dbseek( str(CO->OPROVIS)+str(CO2->CODPROD) )
          			frlock()
              	OP2->CANTUSADO += CO2->CANTIDAD
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
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nReg:=recno()

IF listado == "OPROVIS"
  select OP
  IF QUEFECHA2(10,30)
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
     set order to forder({"FECHA"})
     DBSEEK(FTOC(DESDE),.T.)
     select OP2
     do while OP->FECHA>=DESDE .and. OP->FECHA<=HASTA .and. !OP->(eof())
     	nAux:=0
        dbseek(str(OP->OPROVIS),.T.)
        do while OP2->OPROVIS==OP->OPROVIS .and. !OP2->(eof())
        	if nAux==0
					CABEZA( 2 ); I_CL += 2
        		?
					? I_esp + ARMOLIN(I_cab+1)
           else
					CABEZA( 1 ); ++I_CL
					? I_esp + ARMOLIN(I_cab+2)
           endif
           ++nAux
           skip
        enddo
        skip 1 alias OP
  	enddo
     select OP
     set order to 1
		RECUPAN()
		LISTADOR( "FIN" )
	ENDIF
  go nReg
ELSEIF listado == "OPRXPRD"
	LISTADOR( "INI" )
	if !SETIMPRESORA("INI");  break(nil);  endif
	cBaseAux:=xname('XAUX')
  select OP2
  set relation to OP2->OPROVIS into OP
  index on str(OP2->CODPROD)+str(OP2->OPROVIS) to (cBaseAux) for OP->OPROVIS#0.and.empty(OP->FECHBAJA)
	DO ICARGA WITH listado
  go top
  I_CODPROD := -1
  do while !OP2->(eof())
  	if I_CODPROD # OP2->CODPROD
     	if !I_INI
				CABEZA( 2 ); I_CL+=2
				? I_esp + ARMOLIN(I_cab)
				? I_esp + ARMOLIN(I_cab+2)
        endif
			CABEZA( 2 ); I_CL+=2
        ?
			? I_esp + str(OP2->CODPROD)+' - '+FPROD(OP2->CODPROD)
  		I_CODPROD := OP2->CODPROD
			nCANTPROVIS := 0
			nCANTUSADO  := 0
     endif
		CABEZA( 1 ); I_CL+=1
		? I_esp + ARMOLIN(I_cab+1)
		nCANTPROVIS += OP2->CANTPROVIS
		nCANTUSADO  += OP2->CANTUSADO
  	skip
  enddo
	CABEZA( 2 ); I_CL+=2
	? I_esp + ARMOLIN(I_cab)
	? I_esp + ARMOLIN(I_cab+2)
	RECUPAN()
	LISTADOR( "FIN" )
  FREABRIR({"OPROVIS2"})
  select OP
  go nReg
endif

return
