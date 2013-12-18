local aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO(.T., ' CABIO DE PRECIOS ' )


MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
M->FECHA    := RFECHA := VA->FECHA
M->STOCKACT := 0
M->DEPOSITO := 0
M->COMPRAS  := 0
M->VENTAS   := 0

aCpo:={{ "CODPROD",           "C¢digo; ",                           '', 'F',  '',  0, 0 },;
		  { "DESCPROD",          "Descripci¢n",            REPLIC('X',20), 'F', 'C', 20, 0 },;
		  { "CONIMPINT",         "con;II",                             '', 'F',  '',  0, 0 },;
		  { "PRECBASE",          "Neto; ",                  '#####.#####', 'F',  '',  0, 0 },;
		  { "PRECBASE*VA->PIVA1/100", "IVA; ",                 '999999.99', 'F', 'F',  0, 0 },;
		  { "IMPINT",            "Imp.Int; ",               '#####.#####', 'F',  '',  0, 0 },;
		  { "PRECVENTA",         "Precio;Final",            '#####.#####', 'M',  '',  0, 0 } }

select PRD
aCpo := FBASEAUX( aCpo, "PRD", SELECT(), .F. )
DBGOTOP()
RECUPAN()

SETCOLOR( "W/N,N/W" )
OX := MYBROWSE( 5, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 10
OX:FREEZE(2)
	
MENUDOWN({"  <+>  º    F8     º ESC  ",;
			  "       º cambio de º      ",;
			  " mueve º  precio   º sale "})
	
DO WHILE .T.

	MOVBROW( OX, {||nK==9.OR.nK==-9.OR.nK==27.OR.nK==-6.OR.nK==K_F8.OR.nK==43.OR.nK==45.OR.nK==K_F10 }, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )

	IF OX:Cargo[TB_MSGE] == "MODIF"
		IF TBNOC(OX) $ "PRD->PRECVENTA PRD->GRUPO PRD->CONIMPINT"
			FRLOCK()
			PRD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
			DBUNLOCK()
			aux := .T.
		ELSEIF TBNOC(OX) == "PRD->PRECBASE"
			FRLOCK()
			M->PIVA1 := PRD->PRECBASE * VA->PIVA1 / 100
			PRD->PRECVENTA := PRD->PRECBASE + PRD->IMPINT + M->PIVA1
			DBUNLOCK()
		ENDIF
		IF aux
			FRLOCK()
			PRD->PRECBASE := FNETOVENTA( PRD->GRUPO, PRD->PRECVENTA, PRD->CONIMPINT )
			M->TIPOIMPINT := FTIPOIMPINT
			PRD->IMPINT   := IF( M->TIPOIMPINT="%", PRD->PRECBASE*FIMPINT/100*PRD->CONIMPINT, FIMPINT ) * PRD->CONIMPINT
			DBUNLOCK()
		ENDIF
     FRLOCK();  PRD->FECHMODIF:=date();  DBUNLOCK()
		TBPOS(OX)

	ELSEIF oX:Cargo[TB_RET] == K_F8
     nReg := RECNO()
		op = MENUFLASH( 10, 30, 1, .F., "",  "Aumento x Rubro" )
     if op==1
			if FELEGIR("GRUPO") # 0
     		nAumento := 0
				nAumento := INGRVAL( 10, 20, "% Aumento:", nAumento, "999.999", "")
        	if lastkey() == K_ENTER
					MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
     			select PRD
        		go top
        		locate for PRD->GRUPO == GR->(RECNO())
        		do while !eof()
        			if PRD->GRUPO == GR->(RECNO())
							FRLOCK()
                 	PRD->PRECVENTA := round( PRD->PRECVENTA + ( PRD->PRECVENTA * nAumento / 100 ), 1 )
							PRD->PRECBASE  := FNETOVENTA( PRD->GRUPO, PRD->PRECVENTA, PRD->CONIMPINT )
							M->TIPOIMPINT  := FTIPOIMPINT
							PRD->IMPINT    := IF( M->TIPOIMPINT="%", PRD->PRECBASE*FIMPINT/100*PRD->CONIMPINT, FIMPINT ) * PRD->CONIMPINT
              		dbunlock()
						endif
        			skip
        		enddo
        		RECUPAN()
           endif
        endif
		endif
     go nReg
		TBPOS(OX,.T.)

	elseif OX:Cargo[TB_RET] == K_ESC
		exit
	endif

enddo
	

return


**********

FUNC PREXP

**********
local aCpo, oGET, xreg, aaux, areg, xaux, aux

LOGO(.T., ' CAMBIO DE PRECIOS ' )

MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )
cBaseAux := xname("XPRE")
select 99;  dbclosearea()
select PRD
sort on CODPROD to (cBaseAux)
select 99
use (cBaseAux) alias X exclusive
replace CONDEP with "", RECARGO with 0, DEPOSITO with PRECVENTA all

aCpo:={{ "CODPROD",           "C¢digo; ",                           '', 'F',  '',  0, 0 },;
		  { "DESCPROD",          "Descripci¢n",            REPLIC('X',20), 'F', 'C', 20, 0 },;
		  { "RECARGO",           "%;Aumto",                  '@Z ####.##', 'F',  '',  0, 0 },;
		  { "PRECBASE",          "Neto; ",                  '#####.#####', 'F',  '',  0, 0 },;
		  { "PRECBASE*VA->PIVA1/100", "IVA; ",                '999999.99', 'F', 'F',  0, 0 },;
		  { "PRECVENTA",         "Precio;Final",            '#####.#####', 'F',  '',  0, 0 },;
		  { "IMPINT",            "Imp.Int; ",               '#####.#####', 'F',  '',  0, 0 }}

select X
aCpo := FBASEAUX( aCpo, alias(), select(), .F. )
dbgotop()
RECUPAN()

SETCOLOR(C_MENU)
OX := MYBROWSE( 5, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 10
OX:FREEZE(2)
	
MENUDOWN({"  <+>  º    ESPACIO   º    F8     º ESC  ",;
			  "       º   aplica o   º cambio de º      ",;
			  " mueve º saca aumento º    %      º sale "})
	
nAumento := 0
nRedondeo := 1
lPreguntar := .T.
do while .T.
	if lPreguntar
		nAumento := INGRVAL( 10, 20, "% Aumento:", nAumento, "999.999", "")
		nRedondeo := INGRVAL( 10, 20, "% Redondeo:", nRedondeo, "999", "")
		lPreguntar := .F.
  	setcolor("W/N")
		@ 3,1 clear to 3,78
		@ 3,5 say "% aumento: "+str(nAumento,6,2)
		@ 3,40 say "Redondeo: "+str(nRedondeo,3) +" decimales"
  	setcolor(C_MENU)
  endif
	MOVBROW( OX, {||nK==9.OR.nK==-9.OR.nK==27.OR.nK==-6.OR.nK==K_F8.OR.nK==43.OR.nK==45.OR.nK==K_F10.OR.nK==K_SPACE }, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )

	if OX:Cargo[TB_MSGE] == "MODIF"
		if TBNOC(OX) $ "X->PRECVENTA X->GRUPO X->CONIMPINT"
			FRLOCK()
			X->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
			DBUNLOCK()
			aux := .T.
		endif
     frlock();  X->FECHMODIF:=date();  dbunlock()
		TBPOS(OX)

	elseif oX:Cargo[TB_RET] == K_SPACE
  	if X->RECARGO==0
     	X->PRECVENTA := round( X->PRECVENTA + ( X->PRECVENTA * nAumento / 100 ), nRedondeo )
        X->RECARGO   := nAumento
     	frlock();  X->FECHMODIF:=date();  dbunlock()
     else
     	X->PRECVENTA := X->DEPOSITO
        X->RECARGO   := 0
     endif
		X->PRECBASE   := FNETOVENTA( X->GRUPO, X->PRECVENTA, X->CONIMPINT )
		M->TIPOIMPINT := FTIPOIMPINT
		X->IMPINT     := IF( M->TIPOIMPINT="%", X->PRECBASE*FIMPINT/100*X->CONIMPINT, FIMPINT ) * X->CONIMPINT
		TBPOS(OX)

	elseif oX:Cargo[TB_RET] == K_F8
  	lPreguntar := .T.

	elseif OX:Cargo[TB_RET] == K_ESC
		exit
	endif

enddo
if upper(PREGUNTA( 10, "Actualizar lo precios   [ S / N ] ","SsNn")) == "S"
	MENSAJE( 0, 0, 0, .F., "ACTUALIZANDO..." )
	locate for RECARGO # 0
	select PRD
  do while !X->(eof())
  	if X->RECARGO # 0
  		if dbseek(X->CODPROD)
     		frlock()
     		PRD->PRECVENTA := X->PRECVENTA
				PRD->PRECBASE  := X->PRECBASE
				PRD->IMPINT    := X->IMPINT
        	dbunlock()
        endif
     endif
  	skip 1 alias X
  enddo
  RECUPAN()
endif

return
