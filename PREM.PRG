LOCAL aCpo, oGET, xreg, aaux, areg, xaux, aux

#include "EST.CH"
#include "TB.CH"
#include "EDI.CH"
#include "INKEY.CH"
#include "SETCURS.CH"

LOGO(.T., ' PRECIOS MAYORISTA ' )


MENSAJE( 0, 0, 0, .F., " AGUARDE ... " )

aCpo:={{ "CODPROD",           "C¢digo; ",                           '', 'F',  '',  0, 0 },;
		  { "DESCPROD",          "Descripci¢n",            REPLIC('X',20), 'F', 'C', 20, 0 },;
		  { "UNXCAJA",           "UxC",                                '', 'F',  '',  0, 0 },;
		  { "CAPACIDAD",         "Env",                     '@Z ####.###', 'F',  '',  0, 0 },;
		  { "NETOCOMPRM",        "A",                    '@Z #####.#####', 'F',  '',  0, 0 },;
		  { "PUTILM",            "%",                         '@Z 999.99', 'M',  '',  0, 0 },;
 		  { "PRECVENTAM",        "Precio;Venta",          '@Z #######.##', 'M',  '',  0, 0 } }

select PRD
aCpo := FBASEAUX( aCpo, "PRD", SELECT(), .F. )
DBGOTOP()
RECUPAN()

SETCOLOR(C_MENU)
OX := MYBROWSE( 8, 1, 20, 78, aCpo )
OX:CARGO[TB_REFRESH] := 10
OX:FREEZE(2)
	
MENUDOWN({"  <+>  º   F8   º ESC  ",;
			  "       º cambio º      ",;
			  " mueve º  de %  º sale "})
	
aaux := NEWEDIT( "PREM",,.T. )
FVERREG( aaux,, .T. )
DO WHILE .T.
	MOVBROW( OX, {||nK==9.OR.nK==-9.OR.nK==27.OR.nK==-6.OR.nK==K_F8.OR.nK==43.OR.nK==45.OR.nK==K_F10 }, {||NK==999}, {||FIELD->FECHA>VA->FECHSEG} )

	IF OX:Cargo[TB_MSGE] == "MODIF"
  	lAux := .T.
		FRLOCK()
		xAux := PRD->&(TBNOC(OX))
		PRD->&(TBNOC(OX)) := oX:CARGO[TB_CONT]
		if TBNOC(OX) == "PRECVENTAM"
     	PRD->NETOCOMPRM := PRD->NETOCOMPRA + (PRD->NETOCOMPRA * VA->PIVA1 / 100)
     	nAux := PRD->PRECVENTAM - PRD->NETOCOMPRM
 			PRD->PUTILM := nAux * 100 / PRD->PRECVENTAM
		elseif TBNOC(OX) == "PUTILM"
     	PRD->NETOCOMPRM := PRD->NETOCOMPRA + (PRD->NETOCOMPRA * VA->PIVA1 / 100)
			PRD->PRECVENTAM := PRD->NETOCOMPRM + (NETOCOMPRM*PRD->PUTILM/100)
		endif
     frlock();  PRD->FECHMODIF:=date();  dbunlock()
		TBPOS(OX)

	ELSEIF oX:Cargo[TB_RET] == K_F8
		xmenu:=MENUDOWN({"     º   F10   º  ESC   ",;
							  "       º graba y º        ",;
							  " mueve º procede º  sale  "})
		FEDITOR( aaux, "LEER" )
		aaux[ED_I] := 1
		aaux[ED_REGISTRO] := RECNO()
		aaux[ED_MODE] = "MOSTRARTODO"
		do while .T.
			FEDITAR( aaux, { K_F10 } )
			IF aaux[ED_UPDATE]
				aaux[ED_MODE] = "MOSTRAR"
			ELSEIF ( aaux[ED_TECLA] == K_ENTER .AND. aaux[ED_I] == LEN(aaux[ED_EDIT]) ) .OR. aaux[ED_TECLA] == K_F10
				MENSAJE(99,99,0,.F.,"RECALCULANDO..." )
           FRLOCK("VA")
				FEDITOR(aaux,"GRABAR",.F.)
           nAux := 0
           select PRD
           nReg:=recno()
           dbgotop()
           do while !eof()
           	if PRD->CAPACIDAD # 0
						frlock()
              	if PRD->CAPACIDAD > 19
                 	PRD->PUTILM := VA->PENVMAYOR
                 else
                 	PRD->PUTILM := VA->PENVMENOR
                 endif
     				PRD->NETOCOMPRM := PRD->NETOCOMPRA + (PRD->NETOCOMPRA * VA->PIVA1 / 100)
						PRD->PRECVENTAM := PRD->NETOCOMPRM + (NETOCOMPRM*PRD->PUTILM/100)
                 dbunlock()
                 @24,70 say ++nAux pict "####"
              endif
           	skip
           enddo
           go nReg
           RECUPAN()
				exit
			ELSEIF aaux[ED_TECLA] == K_ESC
				EXIT
			ENDIF
		ENDDO
		MENUDOWN(xmenu)
		TBPOS(OX,.T.)

	ELSEIF OX:Cargo[TB_RET] == K_ESC
		EXIT
	ENDIF

ENDDO
	

RETURN
