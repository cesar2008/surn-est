LOCAL aCpo, oX, oGET, xreg

#include "EST.CH"
#include "TB.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO( .T., " VENTA MAYORISTA " )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

aCpo:={;
	{ "FECHA",     "Fecha",                               '', 'M',  '',  0, 0 },;
	{ "CODCLI",    "C¢d",                                 '', 'M',  '',  0, 0 },;
	{ "FCLIENTE(VM->CODCLI)",;
						"Cliente",                   REPL('X',20), 'F',  '',  0, 0 },;
	{ "CODPROD",   "C¢d;Prod",                            '', 'M',  '',  0, 0 },;
	{ "FPROD(VM->CODPROD)",;
						"Producto",                  REPL('X',20), 'F',  '',  0, 0 },;
	{ "CANTIDAD",  "Cantidad",                            '', 'M',  '',  0, 0 },;
	{ "PRECVENTA", "Precio;Unitario",                     '', 'M',  '',  0, 0 },;
	{ "IMPORTE",   "Importe",                             '', 'F',  '',  0, 0 },;
	{ "PRECBASE",  "Precio;Base",                         '', 'F',  '',  0, 0 },;
	{ "IVA",       "IVA",                                 '', 'F',  '',  0, 0 },;
	{ "IMPINT",    "Imp.Int",                             '', 'F',  '',  0, 0 }}

FBASES({ "VM", "CLIENTES" })

SELECT VM
aCpo := FBASEAUX( aCpo, DBF(), SELECT(), .F. )
DBGOBOTTOM()

MENUDOWN({"  <+>  º F2 modif. º    F6   º   F7    º    TAB    º  ESC   ",;
			  "       º F3 busca  º         º         º Clientes  º        ",;
			  " mueve º F4 busca+ º elimina º imprime º Productos º  sale  "})

SETCOLOR( C_MENU )
oX := MYBROWSE( 4, 1, 20, 78, aCpo )
oX:CARGO[TB_REFRESH] := 10
oX:GOBOTTOM()

DO WHILE .T.
  lRecalc:=.F.
	
	MOVBROW( oX, {||nK==K_TAB.OR.nK==K_F2.OR.nK==K_F5.OR.nK==K_ESC.OR.nk==K_F7}, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )
	
	IF OX:Cargo[TB_MSGE] == "MODIF"
		FRLOCK()
		FIELD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		IF TBNOC(OX) == "PRECVENTA"
			lRecalc := .T.
		ELSEIF TBNOC(OX) == "CODPROD"
     	VM->PRECVENTA := PRD->PRECVENTA
			lRecalc := .T.
		ENDIF
		DBUNLOCK()
		TBPOS(OX)

	ELSEIF oX:Cargo[TB_RET] == K_TAB
		FRLOCK()
		IF TBNOC(oX) == "CODCLI"
			IF FELEGIR("CLI")#0
				VM->CODCLI := CL->CODCLI
			ENDIF
		ELSEIF TBNOC(oX) == "CODPROD"
			IF FELEGIR("PRODUCTO")#0
        	VM->CODPROD := PRD->CODPROD
     		VM->PRECVENTA := PRD->PRECVENTA
           lRecalc := .T.
        ENDIF
		ENDIF
		DBUNLOCK()
		TBPOS(OX)

	ELSEIF OX:Cargo[TB_RET] == K_F7
		op2 = MENUFLASH( 10, 30, 1, .T., "", "Venta Mayorista",;
                                          "Venta Mayorista Facturada" )
		if op2==1
  		LISTAR("VM")
		elseif op2==2
  		LISTAR("VMFAC")
     endif

	ELSEIF OX:Cargo[TB_RET] == K_F5
		DBGOBOTTOM()
		aux  := FIELD->FECHA
     F_ALTA({||!empty(FIELD->FECHA)})
		FRLOCK()
		FIELD->FECHA := aux
		TBPOS(OX,.T.)

	ELSEIF oX:Cargo[TB_RET] == K_F8
     select VM
     TBPOS(OX,.T.)

	ELSEIF oX:Cargo[TB_RET] == K_F6
		IF UPPER( PREGUNTA( 12, "¨ SEGURO  [ S / N ] ?", "SsNn") ) == "S"
     	xAux:=&(indexkey())
			BLANKREG(.T.)
			dbseek(xAux,.T.)
			TBPOS(OX,.T.)
		ENDIF
	ELSEIF oX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF
	IF lRecalc
		FRLOCK()
		VM->PRECBASE  := FNETOVENTA( PRD->GRUPO, VM->PRECVENTA, PRD->CONIMPINT )
     VM->PIVA       := VM->PRECBASE * VA->PIVA1 / 100
		VM->IMPINT    := IF( FTIPOIMPINT="%", VM->PRECBASE*FIMPINT/100*PRD->CONIMPINT, FIMPINT ) * PRD->CONIMPINT
     VM->IMPORTE   := VM->PRECVENTA * VM->CANTIDAD
		DBUNLOCK()
	ENDIF
	TBPOS(OX)
ENDDO

DBUNLOCKALL()
DBCOMMITALL()

RETURN
		

*****************************

STATIC FUNC LISTAR( listado )

*****************************
local nReg:=VM->(recno())
IF listado == "VM"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
		DO ICARGA WITH listado
		xreg := RECNO()
		SELECT 99
		DBCLOSEAREA()
		SELECT VM
		base := XNAME("XAUX")
		dbseek(ftoc(DESDE),.T.)
		copy to (base) rest for FECHA>=DESDE WHILE FECHA<=HASTA
		select 99
		use (base) alias X exclusive
		index on X->CODPROD to (base)
		nCANTIDAD:= nIMPORTE:= 0
		dbgotop()
		I_codaux := "@@@"
		do while !salir().and.!eof()
			if I_codaux # X->CODPROD
				if !I_INI
					CABEZA( 2 )
					I_CL += 2
					?  I_esp + ARMOLIN(I_cab)
					?  I_esp + ARMOLIN(I_cab+2)
					nCANTIDAD:= nIMPORTE:= 0
				endif
				CABEZA( 2 )
				?
				? I_esp + str(X->CODPROD)+' '+ FPROD(X->CODPROD)
				I_CL = I_CL + 2
				I_codaux = X->CODPROD
			endif
			CABEZA( 1 )
			++I_CL
			? I_esp + ARMOLIN(I_cab+1)
			nCANTIDAD += X->CANTIDAD
        nIMPORTE  += X->IMPORTE
			skip
		enddo
		CABEZA( 2 )
		I_CL += 2
		?  I_esp + ARMOLIN(I_cab)
		?  I_esp + ARMOLIN(I_cab+2)
     SELECT 99
     DBCLOSEAREA()
		LISTADOR( "FIN" )
		RECUPAN()
	endif
elseif listado == "VMFAC"
	IF QUEFECHA2( 10, 30 )
		LISTADOR( "INI" )
		if !SETIMPRESORA("INI");  break(nil);  endif
*		DO ICARGA WITH listado
		xreg := RECNO()
		base := XNAME("XAUX")
		SELECT 99;  DBCLOSEAREA()
		dbcreate(base,{{"CODCLI","N",4,0},{"RAZONSOC","C",35,0}})
		select 99
		use (base) alias X exclusive
     index on X->CODCLI to (base)
		select VM
		dbseek(ftoc(DESDE),.T.)
     select X
		do while VM->FECHA>=DESDE .and. VM->FECHA<=HASTA
     	if !dbseek(VM->CODCLI)
     		append blank
        	X->CODCLI := VM->CODCLI
           X->RAZONSOC := FCLIENTE(X->CODCLI)
        endif
     	skip 1 alias VM
     enddo
*    index on X->RAZONSOC to (base)
     FBASES({"+FACA"},.F.)
     set order to forder({"FECHA"})
		dbseek(ftoc(DESDE),.T.)
     select X
		do while FA->FECHA>=DESDE .and. FA->FECHA<=HASTA
*    	aaux:=FPARSER(FA->RAZONSOC)
*       nAux:=0
*       for i=1 to len(aaux)
*    		dbseek(aaux[i],.T.)
*          if FA->RAZONSOC $ aaux[i]
*          	++nAux
*          endif
*       next
*       if nAux==len(aaux)
			if dbseek(FA->CODCLI)
        	? FA->NUMFAC, FA->FECHA, FA->RAZONSOC, FA->TOTAL
        endif
			skip 1 alias FA
     enddo
     SELECT 99;  DBCLOSEAREA()
		LISTADOR( "FIN" )
		RECUPAN()
	endif
endif
select VM
DBGOTO( nreg )

return


*********************
FUNC FPARSER( cCual )
*********************
local i, cAux:=alltrim(cCual), aaux:={}

i:=at(" ",cAux)
do while i>0 .and. len(aaux)<3
	aadd(aaux,strtran(left(cAux,i-1),".",""))
  cAux:=substr(cAux,i+1)
	i:=at(" ",cAux)
enddo

return aaux
